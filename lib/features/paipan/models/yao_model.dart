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
    'sanHeJu': sanHeJu,
  };
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
