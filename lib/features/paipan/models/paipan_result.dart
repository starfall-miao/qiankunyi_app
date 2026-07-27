import 'gua_model.dart';

/// 六爻流派
enum LiuyaoSchool {
  jingFangJianBan,   // 京房简版（默认）
  jingFangZhengZong, // 京房正宗
}

/// 排盘结果
class PaipanResult {
  final GuaModel benGua;       // 本卦
  final GuaModel? bianGua;     // 变卦
  final GuaModel? huGua;       // 互卦
  final DateTime paipanTime;   // 排盘时间
  final String method;         // 起卦方式
  final LiuyaoSchool school;   // 流派
  final String? monthZhi;      // 月建（月的地支名）
  final String? monthGanZhi;   // 月柱（干支）
  final String? dayGanZhi;     // 日辰（日干支）
  final List<String> shenSha;  // 神煞列表
  final List<String>? kongWang; // 旬空（空亡的地支名列表）
  final String? naYin;         // 纳音

  PaipanResult({
    required this.benGua,
    this.bianGua,
    this.huGua,
    required this.paipanTime,
    required this.method,
    this.school = LiuyaoSchool.jingFangJianBan,
    this.monthZhi,
    this.monthGanZhi,
    this.dayGanZhi,
    this.shenSha = const [],
    this.kongWang,
    this.naYin,
  });

  Map<String, dynamic> toJson() => {
    'benGua': benGua.toJson(),
    'bianGua': bianGua?.toJson(),
    'huGua': huGua?.toJson(),
    'paipanTime': paipanTime.toIso8601String(),
    'method': method,
    'school': school.name,
    'monthZhi': monthZhi,
    'monthGanZhi': monthGanZhi,
    'dayGanZhi': dayGanZhi,
    'shenSha': shenSha,
    'kongWang': kongWang,
    'naYin': naYin,
  };

  factory PaipanResult.fromJson(Map<String, dynamic> j) => PaipanResult(
    benGua: GuaModel.fromJson(j['benGua'] as Map<String, dynamic>),
    bianGua: j['bianGua'] != null ? GuaModel.fromJson(j['bianGua'] as Map<String, dynamic>) : null,
    huGua: j['huGua'] != null ? GuaModel.fromJson(j['huGua'] as Map<String, dynamic>) : null,
    paipanTime: DateTime.parse(j['paipanTime'] as String),
    method: j['method'] as String,
    school: LiuyaoSchool.values.firstWhere((e) => e.name == (j['school'] ?? 'jingFangJianBan')),
    monthZhi: j['monthZhi'] as String?,
    monthGanZhi: j['monthGanZhi'] as String?,
    dayGanZhi: j['dayGanZhi'] as String?,
    shenSha: (j['shenSha'] as List?)?.cast<String>() ?? [],
    kongWang: (j['kongWang'] as List?)?.cast<String>() ?? [],
    naYin: j['naYin'] as String?,
  );
}
