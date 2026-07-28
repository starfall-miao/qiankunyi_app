/// 八字排盘数据模型
library;

/// 四柱（年月日时）
class SiZhu {
  /// 干支字符串，如 "甲子"
  final String ganZhi;
  /// 天干，如 "甲"
  final String tianGan;
  /// 地支，如 "子"
  final String diZhi;
  /// 天干中文名
  final String tianGanCN;
  /// 地支中文名
  final String diZhiCN;
  /// 天干五行属性
  final String wuXing;
  /// 藏干映射 {本气/中气/余气: 干}
  final Map<String, String> cangGan;

  const SiZhu({
    required this.ganZhi,
    required this.tianGan,
    required this.diZhi,
    required this.tianGanCN,
    required this.diZhiCN,
    required this.wuXing,
    required this.cangGan,
  });
}

/// 大运条目
class DaYun {
  /// 起运年龄
  final int startAge;
  /// 大运干支，如 "甲子"
  final String ganZhi;
  /// 大运天干
  final String tianGan;
  /// 大运地支
  final String diZhi;

  const DaYun({
    required this.startAge,
    required this.ganZhi,
    required this.tianGan,
    required this.diZhi,
  });
}

/// 八字排盘结果
class BaziResult {
  /// 出生时间
  final DateTime birth;
  /// 性别（true=男，false=女；大运顺逆用）
  final bool isMale;
  /// 年柱
  final SiZhu yearZhu;
  /// 月柱
  final SiZhu monthZhu;
  /// 日柱（日元，命主）
  final SiZhu dayZhu;
  /// 时柱
  final SiZhu hourZhu;
  /// 大运列表（通常8步）
  final List<DaYun> daYun;
  /// 当年流年干支
  final String? liuNian;
  /// 五行数量统计 {木: N, 火: N, 土: N, 金: N, 水: N}
  final Map<String, int> wuXingCounts;
  /// 五行旺衰 {木: 旺, 火: 相, ...}
  final Map<String, String> wuXingWangShuai;
  /// 十神映射 {年干: 正财, 月干: 正官, 时干: 伤官, 年支藏干: ..., ...}
  final Map<String, String> shiShenMap;

  const BaziResult({
    required this.birth,
    required this.isMale,
    required this.yearZhu,
    required this.monthZhu,
    required this.dayZhu,
    required this.hourZhu,
    required this.daYun,
    this.liuNian,
    this.wuXingCounts = const {},
    this.wuXingWangShuai = const {},
    this.shiShenMap = const {},
  });

  /// 序列化为 JSON
  Map<String, dynamic> toJson() => {
    'birth': birth.toIso8601String(),
    'isMale': isMale,
    'yearZhu': yearZhu.ganZhi,
    'monthZhu': monthZhu.ganZhi,
    'dayZhu': dayZhu.ganZhi,
    'hourZhu': hourZhu.ganZhi,
    'daYun': daYun.map((d) => d.ganZhi).toList(),
    'liuNian': liuNian,
  };

  /// 从 JSON 反序列化（保留柱的简略信息）
  factory BaziResult.fromJson(Map<String, dynamic> j) => BaziResult(
    birth: DateTime.parse(j['birth'] as String),
    isMale: j['isMale'] as bool? ?? true,
    yearZhu: SiZhu(ganZhi: j['yearZhu'] as String, tianGan: '', diZhi: '', tianGanCN: '', diZhiCN: '', wuXing: '', cangGan: {}),
    monthZhu: SiZhu(ganZhi: j['monthZhu'] as String, tianGan: '', diZhi: '', tianGanCN: '', diZhiCN: '', wuXing: '', cangGan: {}),
    dayZhu: SiZhu(ganZhi: j['dayZhu'] as String, tianGan: '', diZhi: '', tianGanCN: '', diZhiCN: '', wuXing: '', cangGan: {}),
    hourZhu: SiZhu(ganZhi: j['hourZhu'] as String, tianGan: '', diZhi: '', tianGanCN: '', diZhiCN: '', wuXing: '', cangGan: {}),
    daYun: (j['daYun'] as List).map((e) => DaYun(startAge: 0, ganZhi: e as String, tianGan: '', diZhi: '')).toList(),
    liuNian: j['liuNian'] as String?,
  );
}
