/// AI 解卦服务 — 调用 OpenAI 兼容接口
library;

import 'dart:convert';
import 'package:http/http.dart' as http;

/// AI 解卦结果
class AiResult {
  final String content;
  final bool success;
  final String? errorMessage;

  AiResult({required this.content, required this.success, this.errorMessage});

  factory AiResult.error(String msg) => AiResult(content: '', success: false, errorMessage: msg);
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

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final choices = data['choices'] as List?;
        if (choices != null && choices.isNotEmpty) {
          final content = choices[0]['message']['content'] as String? ?? '';
          return AiResult(content: content, success: true);
        }
        return AiResult.error('API 返回为空');
      } else {
        final body = response.body;
        String msg = 'HTTP ${response.statusCode}';
        try {
          final err = jsonDecode(body);
          msg = '${err['error']?['message'] ?? body}';
        } catch (_) {
          msg = body.length > 200 ? '${body.substring(0, 200)}...' : body;
        }
        return AiResult.error(msg);
      }
    } catch (e) {
      return AiResult.error('网络错误: $e');
    }
  }

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
