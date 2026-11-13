/// 爻的阴阳
enum YaoYinYang { yin, yang }

/// 爻位：初、二、三、四、五、上
enum YaoPosition { chu, er, san, si, wu, shang }

/// 天干
enum TianGan { jia, yi, bing, ding, wu, ji, geng, xin, ren, gui }

/// 地支
enum DiZhi { zi, chou, yin, mao, chen, si, wu, wei, shen, you, xu, hai }

/// 六亲
enum LiuQin { parent, brother, officer, wife, child, none }

/// 六神（青龙、朱雀、勾陈、螣蛇、白虎、玄武）
enum LiuShen {
  qingLong,   // 青龙
  zhuQue,     // 朱雀
  gouChen,    // 勾陈
  tengShe,    // 螣蛇
  baiHu,      // 白虎
  xuanWu,     // 玄武
}

/// 化进神 / 化退神（仅动爻有意义）
///
/// 化进神：变爻与本爻同五行且地支顺进（亥→子、寅→卯、巳→午、申→酉、
/// 丑→辰、辰→未、未→戌、戌→丑），主力量增强、事情往有利方向推进；
/// 化退神：反向（子→亥、卯→寅…），主力量衰退、事情退步。
enum HuaJinTui {
  jin('化进神'),
  tui('化退神');

  final String label;
  const HuaJinTui(this.label);
}

/// 旺衰等级
enum WangShuaiLevel {
  wang(3, '旺'),
  xiang(2, '相'),
  xiu(1, '休'),
  qiu(0, '囚'),
  si(-1, '死');

  final int value;
  final String label;
  const WangShuaiLevel(this.value, this.label);
}

/// 单个爻模型
class YaoModel {
  final YaoYinYang yinYang;
  final YaoPosition position;
  final bool isMoving;
  TianGan? tianGan;
  DiZhi? diZhi;
  LiuQin liuQin;
  LiuShen? liuShen;
  WangShuaiLevel? wangShuai;
  bool isShi;
  bool isYing;
  bool isXing;
  bool isChong;
  bool isHe;
  bool isHai;
  bool isKongWang; // 旬空
  bool isRiPo;     // 日破（日辰冲休囚之爻）
  bool isAnDong;   // 暗动（日辰冲旺相之爻）
  bool isYuePo;    // 月破（月建冲克之爻，静动皆可论）
  /// 化进神/化退神（仅动爻，依据本爻与变爻地支是否顺进/逆退判定）
  HuaJinTui? huaJinTui;
  /// 该爻干支的六十甲子纳音（如「甲子」→「海中金」）
  String? naYin;
  /// 该爻所带神煞（天乙贵人/驿马/桃花/华盖/将星/劫煞/亡神/羊刃/禄神/文昌）
  List<String> shenSha;
  List<String> sanHeJu;

  YaoModel({
    required this.yinYang,
    required this.position,
    this.isMoving = false,
    this.tianGan,
    this.diZhi,
    this.liuQin = LiuQin.none,
    this.liuShen,
    this.wangShuai,
    this.isShi = false,
    this.isYing = false,
    this.isXing = false,
    this.isChong = false,
    this.isHe = false,
    this.isHai = false,
    this.isKongWang = false,
    this.isRiPo = false,
    this.isAnDong = false,
    this.isYuePo = false,
    this.huaJinTui,
    this.naYin,
    this.shenSha = const [],
    this.sanHeJu = const [],
  });

  /// 爻位中文名
  String get positionName {
    const names = ['初', '二', '三', '四', '五', '上'];
    return names[position.index];
  }

  Map<String, dynamic> toJson() => {
    'yinYang': yinYang.name,
    'position': position.name,
    'isMoving': isMoving,
    'tianGan': tianGan?.name,
    'diZhi': diZhi?.name,
    'liuQin': liuQin.name,
    'liuShen': liuShen?.name,
    'wangShuai': wangShuai?.name,
    'isShi': isShi,
    'isYing': isYing,
    'isXing': isXing,
    'isChong': isChong,
    'isHe': isHe,
    'isHai': isHai,
    'isKongWang': isKongWang,
    'isRiPo': isRiPo,
    'isAnDong': isAnDong,
    'isYuePo': isYuePo,
    'huaJinTui': huaJinTui?.name,
    'naYin': naYin,
    'shenSha': shenSha,
    'sanHeJu': sanHeJu,
  };

  factory YaoModel.fromJson(Map<String, dynamic> j) => YaoModel(
    yinYang: YaoYinYang.values.firstWhere((e) => e.name == j['yinYang']),
    position: YaoPosition.values.firstWhere((e) => e.name == j['position']),
    isMoving: j['isMoving'] as bool? ?? false,
    tianGan: j['tianGan'] != null ? TianGan.values.firstWhere((e) => e.name == j['tianGan']) : null,
    diZhi: j['diZhi'] != null ? DiZhi.values.firstWhere((e) => e.name == j['diZhi']) : null,
    liuQin: LiuQin.values.firstWhere((e) => e.name == (j['liuQin'] ?? 'none')),
    liuShen: j['liuShen'] != null ? LiuShen.values.firstWhere((e) => e.name == j['liuShen']) : null,
    wangShuai: j['wangShuai'] != null ? WangShuaiLevel.values.firstWhere((e) => e.name == j['wangShuai']) : null,
    isShi: j['isShi'] as bool? ?? false,
    isYing: j['isYing'] as bool? ?? false,
    isXing: j['isXing'] as bool? ?? false,
    isChong: j['isChong'] as bool? ?? false,
    isHe: j['isHe'] as bool? ?? false,
    isHai: j['isHai'] as bool? ?? false,
    isKongWang: j['isKongWang'] as bool? ?? false,
    isRiPo: j['isRiPo'] as bool? ?? false,
    isAnDong: j['isAnDong'] as bool? ?? false,
    isYuePo: j['isYuePo'] as bool? ?? false,
    naYin: j['naYin'] as String?,
    shenSha: (j['shenSha'] as List?)?.cast<String>() ?? const [],
    huaJinTui: () {
      final raw = j['huaJinTui'];
      if (raw is String) {
        for (final v in HuaJinTui.values) {
          if (v.name == raw) return v;
        }
      }
      return null;
    }(),
    sanHeJu: (j['sanHeJu'] as List?)?.cast<String>() ?? [],
  );
}

/// 六神中文名
const liuShenCN = <LiuShen, String>{
  LiuShen.qingLong: '青龙',
  LiuShen.zhuQue: '朱雀',
  LiuShen.gouChen: '勾陈',
  LiuShen.tengShe: '螣蛇',
  LiuShen.baiHu: '白虎',
  LiuShen.xuanWu: '玄武',
};
