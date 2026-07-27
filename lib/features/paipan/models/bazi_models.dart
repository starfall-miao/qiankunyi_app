/// 八字排盘数据模型
library;

/// 四柱（年月日时）
class SiZhu {
  final String ganZhi;      // 干支，如 "甲子"
  final String tianGan;     // 天干
  final String diZhi;       // 地支
  final String tianGanCN;   // 天干中文
  final String diZhiCN;     // 地支中文
  final String wuXing;      // 日干五行
  final Map<String, String> cangGan;  // 藏干 {干: 地支, ...}

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
  final int startAge;       // 起运年龄
  final String ganZhi;      // 大运干支
  final String tianGan;
  final String diZhi;

  const DaYun({
    required this.startAge,
    required this.ganZhi,
    required this.tianGan,
    required this.diZhi,
  });
}

/// 十神
enum ShiShen {
  none('无'),
  biHe('比肩'),
  jieCai('劫财'),
  fuMu('父母'),
  shiShen('食神'),
  shangGuan('伤官'),
  guiRen('官鬼'),
  qiXiao('妻财'),
  ziSun('子孙');

  final String label;
  const ShiShen(this.label);
}

/// 八字排盘结果
class BaziResult {
  final DateTime birth;     // 出生时间
  final bool isMale;        // 性别（大运顺/逆用）
  final SiZhu yearZhu;      // 年柱
  final SiZhu monthZhu;     // 月柱
  final SiZhu dayZhu;       // 日柱
  final SiZhu hourZhu;      // 时柱
  final List<DaYun> daYun;  // 大运列表
  final String? liuNian;    // 流年（当年）

  const BaziResult({
    required this.birth,
    required this.isMale,
    required this.yearZhu,
    required this.monthZhu,
    required this.dayZhu,
    required this.hourZhu,
    required this.daYun,
    this.liuNian,
  });

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

  factory BaziResult.fromJson(Map<String, dynamic> j) => BaziResult(
    birth: DateTime.parse(j['birth'] as String),
    isMale: j['isMale'] as bool? ?? true,
    yearZhu: SiZhu(ganZhi: j['yearZhu'] as String, tianGan: '', diZhi: '', tianGanCN: '', diZhiCN: '', wuXing: '', cangGan: {}),
    monthZhu: SiZhu(ganZhi: j['monthZhu'] as String, tianGan: '', diZhi: '', diZhiCN: '', wuXing: '', cangGan: {}),
    dayZhu: SiZhu(ganZhi: j['dayZhu'] as String, tianGan: '', diZhi: '', diZhiCN: '', wuXing: '', cangGan: {}),
    hourZhu: SiZhu(ganZhi: j['hourZhu'] as String, tianGan: '', diZhi: '', diZhiCN: '', wuXing: '', cangGan: {}),
    daYun: (j['daYun'] as List).map((e) => DaYun(startAge: 0, ganZhi: e as String, tianGan: '', diZhi: '')).toList(),
    liuNian: j['liuNian'] as String?,
  );
}
