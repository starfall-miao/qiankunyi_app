/// AI 解卦服务 — 调用 OpenAI 兼容接口
library;

import 'dart:convert';
import 'package:http/http.dart' as http;

import '../utils/logger.dart';

/// AI 解卦结果
class AiResult {
  final String content;
  final bool success;
  final String? errorMessage;
  final int? statusCode;

  AiResult({
    required this.content,
    required this.success,
    this.errorMessage,
    this.statusCode,
  });

  factory AiResult.error(String msg, {int? statusCode}) =>
      AiResult(content: '', success: false, errorMessage: msg, statusCode: statusCode);
}

/// 流式请求异常（非 2xx 响应或解析失败），由调用方捕获后回退非流式 chat()
class AiStreamException implements Exception {
  final String message;
  final int? statusCode;

  AiStreamException(this.message, {this.statusCode});

  @override
  String toString() =>
      statusCode == null ? message : 'HTTP $statusCode: $message';
}

/// 流式增量片段：区分正式答案与推理过程。
/// - [isReasoning] == false：标准 content 增量，应拼入最终消息（打字机效果）
/// - [isReasoning] == true：reasoning_content 增量（DeepSeek 推理模型的思考
///   过程），**不拼入最终消息**，仅用于流式活性判定（防止被误判"流式无内容"
///   而回退），避免"思考过程+答案"拼接污染展示。
class AiStreamPiece {
  final String text;
  final bool isReasoning;

  const AiStreamPiece(this.text, {this.isReasoning = false});
}

/// AI 解卦服务
class AiService {
  static final AiService _instance = AiService._();
  factory AiService() => _instance;
  AiService._();

  /// 调用 OpenAI 兼容的 API
  Future<AiResult> chat({
    required String endpoint,
    required String apiKey,
    required String model,
    required List<Map<String, String>> messages,
    /// 日志标签（解卦/追问共用本方法时区分日志，默认 'AI解卦'）
    String logTag = 'AI解卦',
    // 实测结论（2026-08-02）：max_tokens 必须显式发送——
    //   · 不传 → deepseek-v4-flash-free 思考无限长（120s+ 仍在 reasoning，
    //     content 永远为空，流式永不完成 → UI 卡死无结果）
    //   · 16384 → 思考较长时耗光配额，正式答案被截断（用户反馈结果变短）
    // 65536：思考（可长达 2 万+ 字符 ≈1 万 token）+ 详细正式答案都有充足
    // 空间，避免"思考越长、答案越短"的配额挤占；上下文保护上限约 131k，
    // 生成上限 65k 处于安全区间。
    int maxTokens = 65536,
    double temperature = 0.7,
  }) async {
    try {
      // 构建 URL
      String url = endpoint.trim();
      if (url.endsWith('/')) url = url.substring(0, url.length - 1);
      if (!url.contains('/chat/completions')) {
        url = '$url/chat/completions';
      }

      final body = <String, dynamic>{
        'model': model,
        'messages': messages,
        'temperature': temperature,
        'max_tokens': maxTokens,
      };

      // 全链路日志：请求（endpoint、model、messages 数量、maxTokens；apiKey 打码不泄漏明文）
      Logger.instance.info('$logTag请求',
          'endpoint: $url | model: $model | messages: ${messages.length} | '
          'maxTokens: $maxTokens | apiKey: ${_maskApiKey(apiKey)}');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      // 全链路日志：响应（statusCode + body 前 300 字符摘要）
      Logger.instance.info('$logTag响应',
          'statusCode: ${response.statusCode} | body: ${_preview(response.body)}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final rawChoices = data['choices'];
        final choices = rawChoices is List ? rawChoices : null;
        if (choices == null || choices.isEmpty) {
          Logger.instance.error('AI返回空', 'HTTP ${response.statusCode} choices为空或缺失');
          return AiResult.error('AI 返回内容为空或格式异常', statusCode: response.statusCode);
        }
        // 健壮解析：content 可能为 String / List（分段）/ null / 缺失
        final content = _extractContent(choices[0]);
        if (content == null || content.isEmpty) {
          Logger.instance.error('AI返回内容为空',
              'HTTP ${response.statusCode} 解析出的 content 为空（null/缺失/空数组段）');
          return AiResult.error('AI 返回内容为空或格式异常', statusCode: response.statusCode);
        }
        Logger.instance.info('$logTag成功',
            'choices: ${choices.length} | content长度: ${content.length}');
        return AiResult(content: content, success: true);
      } else {
        final body = response.body;
        String msg = 'HTTP ${response.statusCode}';
        try {
          final err = jsonDecode(body);
          msg = '${err['error']?['message'] ?? body}';
        } catch (_) {
          msg = body.length > 200 ? '${body.substring(0, 200)}...' : body;
        }
        Logger.instance.error('AI API错误', 'HTTP ${response.statusCode}: $msg');
        return AiResult.error(msg, statusCode: response.statusCode);
      }
    } catch (e) {
      Logger.instance.error('AI网络错误', '请求异常: $e');
      return AiResult.error('网络错误: $e');
    }
  }

  /// 流式聊天：基于 SSE（text/event-stream）逐块读取 body，产出增量文本块。
  ///
  /// 兼容两种网关响应：
  /// - OpenAI 兼容 SSE：`data: {"choices":[{"delta":{"content":"..."}}]}`，解析 delta.content
  /// - 纯文本 chunk：非 JSON 的 data 行直接作为增量文本（非 SSE 网关兜底）
  /// 以 `data: [DONE]` 结束；非 SSE 的一次性 JSON 响应也按行累积输出。
  ///
  /// 异常处理：非 2xx 或网络异常时在流上抛错（emit error），由调用方回退非流式 chat()。
  /// 返回的 Stream 上每个事件是一段增量（[AiStreamPiece]，区分答案/推理）；
  /// 调用方自行累积得到完整 content（只累积 isReasoning == false 的片段）。
  Stream<AiStreamPiece> chatStream({
    required String endpoint,
    required String apiKey,
    required String model,
    required List<Map<String, String>> messages,
    /// 日志标签（解卦/追问共用本方法时区分日志，默认 'AI解卦'）
    String logTag = 'AI解卦',
    // 实测结论（2026-08-02）：max_tokens 必须显式发送——
    //   · 不传 → deepseek-v4-flash-free 思考无限长（120s+ 仍在 reasoning，
    //     content 永远为空，流式永不完成 → UI 卡死无结果）
    //   · 16384 → 思考较长时耗光配额，正式答案被截断（用户反馈结果变短）
    // 65536：思考（可长达 2 万+ 字符 ≈1 万 token）+ 详细正式答案都有充足
    // 空间，避免"思考越长、答案越短"的配额挤占；上下文保护上限约 131k，
    // 生成上限 65k 处于安全区间。
    int maxTokens = 65536,
    double temperature = 0.7,
  }) async* {
    // 构建 URL（与 chat() 保持一致）
    String url = endpoint.trim();
    if (url.endsWith('/')) url = url.substring(0, url.length - 1);
    if (!url.contains('/chat/completions')) {
      url = '$url/chat/completions';
    }

    final body = <String, dynamic>{
      'model': model,
      'messages': messages,
      'temperature': temperature,
      'stream': true,
      'max_tokens': maxTokens,
    };

    // 全链路日志：请求（apiKey 打码，不泄漏明文）
    Logger.instance.info('$logTag流式请求',
        'endpoint: $url | model: $model | messages: ${messages.length} | '
        'maxTokens: $maxTokens | apiKey: ${_maskApiKey(apiKey)}');

    final client = http.Client();
    try {
      final req = http.Request('POST', Uri.parse(url));
      req.headers['Authorization'] = 'Bearer $apiKey';
      req.headers['Content-Type'] = 'application/json';
      req.headers['Accept'] = 'text/event-stream';
      req.body = jsonEncode(body);

      final res = await client.send(req);
      Logger.instance.info('$logTag流式响应',
          'statusCode: ${res.statusCode} | '
          'content-type: ${res.headers['content-type'] ?? 'N/A'}');

      if (res.statusCode != 200) {
        final errBody = await utf8.decodeStream(res.stream);
        String msg = 'HTTP ${res.statusCode}';
        try {
          final err = jsonDecode(errBody);
          msg = '${err['error']?['message'] ?? errBody}';
        } catch (_) {
          msg = errBody.length > 200 ? '${errBody.substring(0, 200)}...' : errBody;
        }
        Logger.instance.error('$logTag流式失败', msg);
        throw AiStreamException(msg, statusCode: res.statusCode);
      }

      // SSE 解析：逐行处理。跨 chunk 的多字节字符由 utf8.decoder（StreamTransformer
      // 内部保留不完整序列）自动补全；无换行的残余半行留到下一 chunk 处理。
      // 是否识别到 SSE（出现 data: 行）：SSE 响应只解析 data: 行；纯文本响应
      // （从未出现 data:）则把非空行直接当作增量文本累积。
      final lineBuf = StringBuffer();
      var sawSseData = false;
      await for (final chunk in res.stream.transform(utf8.decoder)) {
        lineBuf.write(chunk);
        var rest = lineBuf.toString();
        while (true) {
          final nl = rest.indexOf('\n');
          if (nl < 0) break;
          final raw = rest.substring(0, nl);
          rest = rest.substring(nl + 1);
          // 兼容 CRLF 行尾
          final line = raw.endsWith('\r') ? raw.substring(0, raw.length - 1) : raw;
          if (line.isEmpty) continue; // SSE 空行分隔 event
          if (line.startsWith('data:')) {
            sawSseData = true;
            final data = _stripDataPrefix(line);
            if (data.trim() == '[DONE]') return;
            final piece = _extractStreamPiece(data, sseMode: true);
            if (piece != null && piece.text.isNotEmpty) {
              yield piece;
            }
          } else if (line.startsWith('event:') ||
              line.startsWith('id:') ||
              line.startsWith('retry:')) {
            // event:/id:/retry: 等其它 SSE 字段忽略
          } else if (!sawSseData && line.trim().isNotEmpty) {
            // 非 SSE 纯文本响应：直接累积为文本
            final piece = _extractStreamPiece(line.trim());
            if (piece != null && piece.text.isNotEmpty) {
              yield piece;
            }
          }
        }
        lineBuf.clear();
        lineBuf.write(rest);
      }
      // 流结束：处理最后一段无换行的残余
      final tail = lineBuf.toString();
      if (tail.isNotEmpty) {
        final line =
            tail.endsWith('\r') ? tail.substring(0, tail.length - 1) : tail;
        if (line.startsWith('data:')) {
          final data = _stripDataPrefix(line);
          if (data.trim() != '[DONE]') {
            final piece = _extractStreamPiece(data, sseMode: true);
            if (piece != null && piece.text.isNotEmpty) {
              yield piece;
            }
          }
        } else if (!sawSseData && line.trim().isNotEmpty) {
          final piece = _extractStreamPiece(line.trim());
          if (piece != null && piece.text.isNotEmpty) {
            yield piece;
          }
        }
      }
    } finally {
      client.close();
    }
  }

  /// 从单个 choice 中健壮地提取文本内容。
  /// 兼容 OpenAI 标准（content 为 String）与 opencode 网关变体：
  /// - content 为 List（分段数组，如 [{'type':'text','text':'...'}, ...] 或 ['...', ...]）
  /// - content 为 null / 缺失 / 其他类型
  /// - DeepSeek 推理模型：content 为空但 reasoning_content 有内容（思考过程），
  ///   此时用 reasoning_content 兜底，避免将推理模型的回复误判为"内容为空"。
  /// 提取结果为空（null 或空白）时返回 null，由调用方判定为格式异常。
  String? _extractContent(dynamic choice) {
    if (choice is! Map) return null;
    final message = choice['message'];
    if (message is! Map) return null;
    final content = _extractContentField(message['content']);
    if (content != null) return content;
    // DeepSeek 推理模型兜底：content 缺失/为空时读取 reasoning_content
    final reasoning = _extractContentField(message['reasoning_content']);
    if (reasoning != null) return reasoning;
    return null;
  }

  /// 从单个内容字段（content / reasoning_content）提取文本。
  /// 兼容 String / 分段 List（[{'type':'text','text':'...'}, ...] 或 ['...', ...]）/
  /// 其他类型兜底转字符串。字段为 null 或空白时返回 null。
  String? _extractContentField(dynamic field) {
    if (field == null) return null;
    if (field is String) {
      final s = field.trim();
      return s.isEmpty ? null : s;
    }
    if (field is List) {
      final buf = StringBuffer();
      for (final seg in field) {
        if (seg is String) {
          buf.write(seg);
        } else if (seg is Map) {
          final text = seg['text'];
          if (text != null) buf.write(text.toString());
        }
      }
      final s = buf.toString().trim();
      return s.isEmpty ? null : s;
    }
    // 其他类型（数字/布尔等）兜底转字符串
    final s = field.toString().trim();
    return s.isEmpty ? null : s;
  }

  /// 去掉 SSE 行首的 'data:' 前缀：按规范移除紧跟其后的一个空格
  /// （保留数据自身的缩进，避免破坏 markdown 代码块等场景）
  static String _stripDataPrefix(String line) {
    var s = line.substring(5);
    if (s.startsWith(' ')) s = s.substring(1);
    return s;
  }

  /// 从 SSE 的 data 行提取增量文本块。
  /// - OpenAI 兼容 SSE：data 为 JSON（choices[0].delta.content，兼容 String / 分段 List）
  /// - 纯文本 chunk：data 非 JSON 时原样返回（非 SSE 网关直接输出文本）
  /// [sseMode] 为 true 表示该行来自 SSE 的 data: 行：若 `{` 开头但 JSON 解析失败
  /// （如多行 JSON 被拆行产生的碎片），直接丢弃返回 null，避免碎片污染 content。
  /// 纯文本模式（sseMode=false）保持原累积行为。
  /// 返回 null 表示该行无有效增量（如 role/usage 事件、空 choices、解析失败碎片）。
  AiStreamPiece? _extractStreamPiece(String data, {bool sseMode = false}) {
    final s = data.trim();
    if (s.isEmpty) return null;
    if (s.startsWith('{')) {
      try {
        final obj = jsonDecode(s);
        if (obj is Map) {
          final choices = obj['choices'];
          if (choices is List && choices.isNotEmpty) {
            final choice = choices[0];
            if (choice is Map) {
              // OpenAI 兼容 SSE：增量在 delta.content；
              // DeepSeek 推理模型：推理阶段增量在 delta.reasoning_content
              // （content 为空）。两者任一非空即产出：content 增量标记为正式
              // 答案（isReasoning=false），reasoning_content 增量标记为推理
              // 过程（isReasoning=true），调用方只把前者拼入最终消息，避免
              // "思考过程+答案"拼接污染展示。
              final delta = choice['delta'];
              if (delta is Map) {
                final content = _extractStreamField(delta['content']);
                if (content != null && content.isNotEmpty) {
                  return AiStreamPiece(content);
                }
                final reasoning = _extractStreamField(delta['reasoning_content']);
                if (reasoning != null && reasoning.isNotEmpty) {
                  return AiStreamPiece(reasoning, isReasoning: true);
                }
                return null;
              }
              // 兼容部分网关直接返回 message.content / message.reasoning_content
              //（非流式增量结构）
              final message = choice['message'];
              if (message is Map) {
                final content = _extractStreamField(message['content']);
                if (content != null && content.isNotEmpty) {
                  return AiStreamPiece(content);
                }
                final reasoning =
                    _extractStreamField(message['reasoning_content']);
                if (reasoning != null && reasoning.isNotEmpty) {
                  return AiStreamPiece(reasoning, isReasoning: true);
                }
              }
            }
          }
        }
        // 是 JSON 但没有可提取的增量（role/usage/空 choices 等）→ 忽略
        return null;
      } catch (_) {
        // JSON 解析失败：SSE 模式下丢弃该行（多行拆分 JSON 的碎片会污染
        // content）；纯文本模式按原样累积（可能是以 { 开头的普通文本）。
        if (sseMode) return null;
      }
    }
    return AiStreamPiece(s);
  }

  /// 从增量字段（content / reasoning_content）提取文本。
  /// 兼容 String / 分段 List；字段为 null 或空白时返回 null。
  String? _extractStreamField(dynamic field) {
    if (field == null) return null;
    if (field is String) return field.isEmpty ? null : field;
    if (field is List) {
      final buf = StringBuffer();
      for (final seg in field) {
        if (seg is String) {
          buf.write(seg);
        } else if (seg is Map) {
          final text = seg['text'];
          if (text != null) buf.write(text.toString());
        }
      }
      final t = buf.toString();
      return t.isEmpty ? null : t;
    }
    return field.toString();
  }

  /// apiKey 日志打码：只显示前 4 位 + 后 4 位，中间 ****
  static String _maskApiKey(String key) {
    if (key.length <= 8) return '****';
    return '${key.substring(0, 4)}****${key.substring(key.length - 4)}';
  }

  /// 日志摘要：超长文本截断到前 300 字符
  static String _preview(String s) =>
      s.length > 300 ? '${s.substring(0, 300)}...' : s;

  /// 构建 AI 解卦提示词 — 六爻/梅花
  /// 精简中文 prompt：直接输出正式解卦结果（不要求任何包裹标记——旧用
  /// >>>解卦<<< 会破坏 Markdown 渲染，已废除），各爻逐行输出；明确
  /// "思考简短、正式输出详细有条理"（避免推理模型把 token 全花在思考阶段
  /// 导致 content 为空 / finish_reason=length 被截断）。
  String buildJieGuaPrompt(String paipanInfo) {
    return '''你是六爻/梅花解卦专家。根据下面排盘信息，给出详细、清晰、有条理的解卦结果。

【要求】
1. 思考过程尽量简短，不要复述排盘数据；把篇幅全部用于正式解卦结果
2. 直接输出正式解卦结果全文，不要附加任何包裹标记
3. 结果要详细有条理：先总论卦象，再逐爻分析，最后综合判断与建议
4. 各爻逐行输出，格式：初爻：…／二爻：…／三爻：…／四爻：…／五爻：…／上爻：…（自下而上）
5. 不同爻位、不同要点之间必须换行，禁止挤在一行
6. 语言通俗易懂，结合世应、六亲、六神、旺衰、旬空等信息展开

排盘信息：
$paipanInfo''';
  }

  /// 构建 AI 纠错提示词
  String buildCorrectionPrompt(String originalBreak, String followUp) {
    final buf = StringBuffer();
    buf.writeln('你是一位精通《周易》六爻占卜的资深术数专家。请复核以下断语的合理性并给出改进建议。');
    if (originalBreak.isNotEmpty) {
      buf.writeln('\n原断语：$originalBreak');
    }
    if (followUp.isNotEmpty) {
      buf.writeln('\n追问：$followUp');
    }
    return buf.toString();
  }
}
