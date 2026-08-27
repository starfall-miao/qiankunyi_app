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
  /// 纳音（六十甲子纳音，如"海中金"）
  final String? naYin;

  const SiZhu({
    required this.ganZhi,
    required this.tianGan,
    required this.diZhi,
    required this.tianGanCN,
    required this.diZhiCN,
    required this.wuXing,
    required this.cangGan,
    this.naYin,
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
  /// 大运纳音，如 "海中金"
  final String? naYin;

  const DaYun({
    required this.startAge,
    required this.ganZhi,
    required this.tianGan,
    required this.diZhi,
    this.naYin,
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
  /// 旬空（空亡地支列表，如 ["戌", "亥"]）
  final List<String> kongWang;

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
    this.kongWang = const [],
  });

  /// 序列化为 JSON
  Map<String, dynamic> toJson() => {
    'birth': birth.toIso8601String(),
    'isMale': isMale,
    'yearZhu': yearZhu.ganZhi,
    'monthZhu': monthZhu.ganZhi,
    'dayZhu': dayZhu.ganZhi,
    'hourZhu': hourZhu.ganZhi,
    'daYun': daYun.map((d) => {'ganZhi': d.ganZhi, 'startAge': d.startAge}).toList(),
    'liuNian': liuNian,
    'wuXingCounts': wuXingCounts,
    'wuXingWangShuai': wuXingWangShuai,
    'shishenMap': shiShenMap,
    'kongWang': kongWang,
  };

  /// 从 JSON 反序列化（保留柱的简略信息）
  factory BaziResult.fromJson(Map<String, dynamic> j) => BaziResult(
    birth: DateTime.parse(j['birth'] as String),
    isMale: j['isMale'] as bool? ?? true,
    yearZhu: _parseSiZhu(j['yearZhu'] as String? ?? ''),
    monthZhu: _parseSiZhu(j['monthZhu'] as String? ?? ''),
    dayZhu: _parseSiZhu(j['dayZhu'] as String? ?? ''),
    hourZhu: _parseSiZhu(j['hourZhu'] as String? ?? ''),
    daYun: () {
      final raw = j['daYun'] as List? ?? [];
      return raw.asMap().entries.map((entry) {
        final i = entry.key;
        final e = entry.value;
        if (e is Map) {
          // New format: list of maps
          final ganZhi = (e['ganZhi'] as String?) ?? '';
          final startAge = (e['startAge'] as int?) ?? (i + 1) * 10;
          return DaYun(
            startAge: startAge,
            ganZhi: ganZhi,
            tianGan: ganZhi.isNotEmpty ? ganZhi[0] : '',
            diZhi: ganZhi.length > 1 ? ganZhi[1] : '',
          );
        }
        // Old format: list of strings — regenerate age
        final ganZhi = (e as String?) ?? '';
        return DaYun(
          startAge: (i + 1) * 10,
          ganZhi: ganZhi,
          tianGan: ganZhi.isNotEmpty ? ganZhi[0] : '',
          diZhi: ganZhi.length > 1 ? ganZhi[1] : '',
        );
      }).toList();
    }(),
    liuNian: j['liuNian'] as String?,
    wuXingCounts: (j['wuXingCounts'] as Map<String, dynamic>?)?.map((k, v) => MapEntry(k, (v as num).toInt())) ?? {},
    wuXingWangShuai: (j['wuXingWangShuai'] as Map<String, dynamic>?)?.cast<String, String>() ?? {},
    shiShenMap: (j['shiShenMap'] as Map<String, dynamic>?)?.cast<String, String>() ?? {},
    kongWang: (j['kongWang'] as List?)?.cast<String>() ?? [],
  );

  /// 从干支字符串解析 SiZhu（兼容旧数据）
  static SiZhu _parseSiZhu(String ganZhi) {
    if (ganZhi.length < 2) {
      return SiZhu(ganZhi: ganZhi, tianGan: '', diZhi: '', tianGanCN: '', diZhiCN: '', wuXing: '', cangGan: {});
    }
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
      naYin: _calcNaYin(tg, dz),
    );
  }

  /// 纳音计算
  static String? _calcNaYin(String gan, String zhi) {
    const ganList = ['甲','乙','丙','丁','戊','己','庚','辛','壬','癸'];
    const zhiList = ['子','丑','寅','卯','辰','巳','午','未','申','酉','戌','亥'];
    final ganIdx = ganList.indexOf(gan);
    final zhiIdx = zhiList.indexOf(zhi);
    if (ganIdx < 0 || zhiIdx < 0) return null;
    // 六十甲子纳音索引：(天干/2)*6 + (地支/2)
    final idx = (ganIdx % 10) ~/ 2 * 6 + (zhiIdx % 12) ~/ 2;
    const naYinNames = [
      '海中金','炉中火','大林木','路旁土','剑锋金','山头火',
      '涧下水','城头土','白蜡金','杨柳木','泉中水','屋上土',
      '霹雳火','松柏木','长流水','砂石金','山下火','平地木',
      '壁上土','金箔金','覆灯火','天河水','大驿土','钗钏金',
      '桑柘木','大溪水','沙中土','天上火','石榴木','大海水',
    ];
    if (idx < 0 || idx >= naYinNames.length) return null;
    return naYinNames[idx];
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
