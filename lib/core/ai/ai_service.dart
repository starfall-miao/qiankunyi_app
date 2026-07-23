/// AI 推理服务抽象接口
/// 为未来接入本地 AI 解卦功能预留架构
library;

/// 解卦请求
class AiReadingRequest {
  final String guaName;
  final String guaGong;
  final String method;
  final String question;
  final String paipanData;

  const AiReadingRequest({
    required this.guaName,
    required this.guaGong,
    required this.method,
    this.question = '',
    this.paipanData = '{}',
  });
}

/// 解卦结果
class AiReadingResult {
  final String interpretation;
  final double confidence;
  final bool isOffline;
  final int inferenceTimeMs;

  const AiReadingResult({
    required this.interpretation,
    required this.confidence,
    this.isOffline = true,
    this.inferenceTimeMs = 0,
  });
}

/// AI 推理服务抽象接口
abstract class AiService {
  String get name;
  bool get isAvailable;
  Future<bool> initialize();
  Future<AiReadingResult> reading(AiReadingRequest request);
  Future<void> dispose();
}

/// 占位实现
class PlaceholderAiService implements AiService {
  @override
  String get name => '占位服务';

  @override
  bool get isAvailable => true;

  @override
  Future<bool> initialize() async => true;

  @override
  Future<AiReadingResult> reading(AiReadingRequest request) async {
    return AiReadingResult(
      interpretation: '【AI解卦功能开发中】\n\n'
          '当前排盘：${request.guaName}（${request.guaGong}宫）\n'
          '起卦方式：${request.method}\n\n'
          '请参考六十四卦卦辞自行解读。\n\n'
          '计划支持的本地推理引擎：\n'
          '• llama.cpp（量化模型）\n'
          '• ONNX Runtime\n'
          '• MediaPipe',
      confidence: 0.0,
      inferenceTimeMs: 0,
    );
  }

  @override
  Future<void> dispose() async {}
}

/// AI 服务管理器
class AiServiceManager {
  static final AiServiceManager _instance = AiServiceManager._();
  factory AiServiceManager() => _instance;
  AiServiceManager._();

  AiService? _service;
  bool _initialized = false;

  bool get isInitialized => _initialized;
  AiService? get service => _service;

  Future<void> initialize({AiService? customService}) async {
    if (_initialized) return;
    _service = customService ?? PlaceholderAiService();
    await _service!.initialize();
    _initialized = true;
  }

  Future<AiReadingResult> reading(AiReadingRequest request) async {
    if (!_initialized) {
      return const AiReadingResult(
        interpretation: 'AI服务未初始化',
        confidence: 0,
        inferenceTimeMs: 0,
      );
    }
    return _service!.reading(request);
  }
}
