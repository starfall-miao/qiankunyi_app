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
    yearZhu: _parseSiZhu(j['yearZhu'] as String? ?? ''),
    monthZhu: _parseSiZhu(j['monthZhu'] as String? ?? ''),
    dayZhu: _parseSiZhu(j['dayZhu'] as String? ?? ''),
    hourZhu: _parseSiZhu(j['hourZhu'] as String? ?? ''),
    daYun: (j['daYun'] as List?)?.map((e) => _parseDaYun(e as String? ?? '')).toList() ?? [],
    liuNian: j['liuNian'] as String?,
  );

  /// 从干支字符串解析 SiZhu（兼容旧数据）
  static SiZhu _parseSiZhu(String ganZhi) {
    if (ganZhi.length < 2) return SiZhu(ganZhi: ganZhi, tianGan: '', diZhi: '', tianGanCN: '', diZhiCN: '', wuXing: '', cangGan: {});
    final tg = ganZhi[0];
    final dz = ganZhi[1];
    return SiZhu(
      ganZhi: ganZhi,
      tianGan: tg,
      diZhi: dz,
      tianGanCN: tg,
      diZhiCN: _diZhiNameCN(dz),
      wuXing: _tianGanWuXing(tg),
      cangGan: _cangGanMap(dz),
    );
  }

  static DaYun _parseDaYun(String ganZhi) {
    if (ganZhi.length < 2) return DaYun(startAge: 0, ganZhi: ganZhi, tianGan: '', diZhi: '');
    return DaYun(startAge: 0, ganZhi: ganZhi, tianGan: ganZhi[0], diZhi: ganZhi[1]);
  }

  /// 地支中文名
  static String _diZhiNameCN(String dz) {
    const names = {'子':'子','丑':'丑','寅':'寅','卯':'卯','辰':'辰','巳':'巳','午':'午','未':'未','申':'申','酉':'酉','戌':'戌','亥':'亥'};
    return names[dz] ?? dz;
  }

  /// 天干五行
  static String _tianGanWuXing(String tg) {
    const map = {'甲':'木','乙':'木','丙':'火','丁':'火','戊':'土','己':'土','庚':'金','辛':'金','壬':'水','癸':'水'};
    return map[tg] ?? '';
  }

  /// 地支藏干
  static Map<String, String> _cangGanMap(String dz) {
    const map = {
      '子': {'本气': '癸'},
      '丑': {'本气': '己', '中气': '癸', '余气': '辛'},
      '寅': {'本气': '甲', '中气': '丙', '余气': '戊'},
      '卯': {'本气': '乙'},
      '辰': {'本气': '戊', '中气': '乙', '余气': '癸'},
      '巳': {'本气': '丙', '中气': '庚', '余气': '戊'},
      '午': {'本气': '丁', '中气': '己'},
      '未': {'本气': '己', '中气': '丁', '余气': '乙'},
      '申': {'本气': '庚', '中气': '壬', '余气': '戊'},
      '酉': {'本气': '辛'},
      '戌': {'本气': '戊', '中气': '辛', '余气': '丁'},
      '亥': {'本气': '壬', '中气': '甲'},
    };
    return map[dz] ?? {};
  }
}
