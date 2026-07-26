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

  factory PaipanResult.fromJson(Map<String, dynamic> j) => PaipanResult(
    benGua: GuaModel.fromJson(j['benGua'] as Map<String, dynamic>),
    bianGua: j['bianGua'] != null ? GuaModel.fromJson(j['bianGua'] as Map<String, dynamic>) : null,
    huGua: j['huGua'] != null ? GuaModel.fromJson(j['huGua'] as Map<String, dynamic>) : null,
    paipanTime: DateTime.parse(j['paipanTime'] as String),
    method: j['method'] as String,
    shenSha: (j['shenSha'] as List?)?.cast<String>() ?? [],
    naYin: j['naYin'] as String?,
  );
}
