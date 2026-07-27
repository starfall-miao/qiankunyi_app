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
    this.sanHeJu = const [],
  });

  /// 爻位显示名称
  String get positionName {
    switch (position) {
      case YaoPosition.chu: return '初';
      case YaoPosition.er: return '二';
      case YaoPosition.san: return '三';
      case YaoPosition.si: return '四';
      case YaoPosition.wu: return '五';
      case YaoPosition.shang: return '上';
    }
  }

  /// 爻的显示符号
  String get symbol => yinYang == YaoYinYang.yang ? '———' : '- -';

  /// 是否为老阴或老阳（动爻）
  bool get isOldYao => isMoving;

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

/// 地支中文名
const diZhiCN = <DiZhi, String>{
  DiZhi.zi: '子', DiZhi.chou: '丑', DiZhi.yin: '寅', DiZhi.mao: '卯',
  DiZhi.chen: '辰', DiZhi.si: '巳', DiZhi.wu: '午', DiZhi.wei: '未',
  DiZhi.shen: '申', DiZhi.you: '酉', DiZhi.xu: '戌', DiZhi.hai: '亥',
};

/// 地支五行
const diZhiWuXing = <DiZhi, WuXing>{
  DiZhi.zi: WuXing.shui,
  DiZhi.chou: WuXing.tu,
  DiZhi.yin: WuXing.mu,
  DiZhi.mao: WuXing.mu,
  DiZhi.chen: WuXing.tu,
  DiZhi.si: WuXing.huo,
  DiZhi.wu: WuXing.huo,
  DiZhi.wei: WuXing.tu,
  DiZhi.shen: WuXing.jin,
  DiZhi.you: WuXing.jin,
  DiZhi.xu: WuXing.tu,
  DiZhi.hai: WuXing.shui,
};

/// 地支六冲
const diZhiChong = <DiZhi, DiZhi>{
  DiZhi.zi: DiZhi.wu, DiZhi.chou: DiZhi.wei,
  DiZhi.yin: DiZhi.shen, DiZhi.mao: DiZhi.you,
  DiZhi.chen: DiZhi.xu, DiZhi.si: DiZhi.hai,
  DiZhi.wu: DiZhi.zi, DiZhi.wei: DiZhi.chou,
  DiZhi.shen: DiZhi.yin, DiZhi.you: DiZhi.mao,
  DiZhi.xu: DiZhi.chen, DiZhi.hai: DiZhi.si,
};
