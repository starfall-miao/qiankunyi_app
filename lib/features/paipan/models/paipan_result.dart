import 'gua_model.dart';

/// 排盘结果
class PaipanResult {
  final GuaModel benGua;       // 本卦
  final GuaModel? bianGua;     // 变卦
  final GuaModel? huGua;       // 互卦
  final DateTime paipanTime;   // 排盘时间
  final String method;         // 起卦方式
  final List<String> shenSha;  // 神煞列表
  final String? naYin;         // 纳音

  PaipanResult({
    required this.benGua,
    this.bianGua,
    this.huGua,
    required this.paipanTime,
    required this.method,
    this.shenSha = const [],
    this.naYin,
  });

  Map<String, dynamic> toJson() => {
    'benGua': benGua.toJson(),
    'bianGua': bianGua?.toJson(),
    'huGua': huGua?.toJson(),
    'paipanTime': paipanTime.toIso8601String(),
    'method': method,
    'shenSha': shenSha,
    'naYin': naYin,
  };
}
