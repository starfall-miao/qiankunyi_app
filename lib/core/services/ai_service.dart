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
    int maxTokens = 2048,
    double temperature = 0.7,
  }) async {
    try {
      // 构建 URL
      String url = endpoint.trim();
      if (url.endsWith('/')) url = url.substring(0, url.length - 1);
      if (!url.contains('/chat/completions')) {
        url = '$url/chat/completions';
      }

      // 全链路日志：请求（endpoint、model、messages 数量、maxTokens；apiKey 打码不泄漏明文）
      Logger.instance.info('AI解卦请求',
          'endpoint: $url | model: $model | messages: ${messages.length} | '
          'maxTokens: $maxTokens | apiKey: ${_maskApiKey(apiKey)}');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': model,
          'messages': messages,
          'max_tokens': maxTokens,
          'temperature': temperature,
        }),
      );

      // 全链路日志：响应（statusCode + body 前 300 字符摘要）
      Logger.instance.info('AI解卦响应',
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
        Logger.instance.info('AI解卦成功',
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

  /// 从单个 choice 中健壮地提取文本内容。
  /// 兼容 OpenAI 标准（content 为 String）与 opencode 网关变体：
  /// - content 为 List（分段数组，如 [{'type':'text','text':'...'}, ...] 或 ['...', ...]）
  /// - content 为 null / 缺失 / 其他类型
  /// 提取结果为空（null 或空白）时返回 null，由调用方判定为格式异常。
  String? _extractContent(dynamic choice) {
    if (choice is! Map) return null;
    final message = choice['message'];
    if (message is! Map) return null;
    final content = message['content'];
    if (content == null) return null;
    if (content is String) {
      final s = content.trim();
      return s.isEmpty ? null : s;
    }
    if (content is List) {
      final buf = StringBuffer();
      for (final seg in content) {
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
    final s = content.toString().trim();
    return s.isEmpty ? null : s;
  }

  /// apiKey 日志打码：只显示前 4 位 + 后 4 位，中间 ****
  static String _maskApiKey(String key) {
    if (key.length <= 8) return '****';
    return '${key.substring(0, 4)}****${key.substring(key.length - 4)}';
  }

  /// 日志摘要：超长文本截断到前 300 字符
  static String _preview(String s) =>
      s.length > 300 ? '${s.substring(0, 300)}...' : s;

  /// 构建 AI 解卦提示词 — 六爻
  String buildJieGuaPrompt(String paipanInfo) {
    return '''你是一位精通《周易》六爻占卜的资深术数专家。请根据以下排盘信息进行详细解卦。

排盘信息：
$paipanInfo

请从以下几个方面进行分析：
1. 卦象总论：本卦、变卦、互卦的基本含义
2. 世应关系：世爻和应爻的位置与关系
3. 六亲分析：各爻六亲的含义及其相互关系
4. 六神分析：六神所主吉凶
5. 旺衰判断：各爻的旺衰状态对事情的影响
6. 综合断语：给出最终的判断和建议

请用通俗易懂的语言解释，避免过于晦涩的术语。''';
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
