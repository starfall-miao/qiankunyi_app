import 'yao_model.dart';

/// 八宫
enum GuaGong { qian, dui, li, zhen, xun, kan, gen, kun }

/// 五行
enum WuXing { jin, mu, shui, huo, tu }

/// 六十四卦名
enum GuaName {
  qian, kun, zhun, meng, xu, song, shi, bi,
  xiaoXu, lv, tai, pi, tongRen, daYou, qian2, yu,
  sui, gu, lin, guan, shiHe, bi2, bo, fu,
  wuWang, daXu, yi, daGuo, kan, li, xian, heng,
  dun, daZhuang, jin, mingYi, jiaRen, kui, jian, jie,
  sun, yi2, guai, gou, cui, sheng, kun2, jing,
  ge, ding, zhen, gen, jian2, guiMei, feng, lv2,
  xun, dui, huan, jie2, zhongFu, xiaoGuo, jiJi, weiJi,
}

/// 卦的五行属性
const Map<GuaGong, WuXing> guaGongWuXing = {
  GuaGong.qian: WuXing.jin,
  GuaGong.dui: WuXing.jin,
  GuaGong.li: WuXing.huo,
  GuaGong.zhen: WuXing.mu,
  GuaGong.xun: WuXing.mu,
  GuaGong.kan: WuXing.shui,
  GuaGong.gen: WuXing.tu,
  GuaGong.kun: WuXing.tu,
};

/// 卦模型
class GuaModel {
  final GuaName name;
  final GuaGong gong;
  final List<YaoModel> yaos;
  final int shiYaoIndex;
  final int yingYaoIndex;

  const GuaModel({
    required this.name,
    required this.gong,
    required this.yaos,
    required this.shiYaoIndex,
    required this.yingYaoIndex,
  });

  WuXing get wuXing => guaGongWuXing[gong]!;

  Map<String, dynamic> toJson() => {
    'name': name.name,
    'gong': gong.name,
    'yaos': yaos.map((y) => y.toJson()).toList(),
    'shiYaoIndex': shiYaoIndex,
    'yingYaoIndex': yingYaoIndex,
  };

  factory GuaModel.fromJson(Map<String, dynamic> j) => GuaModel(
    name: GuaName.values.firstWhere((e) => e.name == j['name']),
    gong: GuaGong.values.firstWhere((e) => e.name == j['gong']),
    yaos: (j['yaos'] as List).map((y) => YaoModel.fromJson(y as Map<String, dynamic>)).toList(),
    shiYaoIndex: j['shiYaoIndex'] as int,
    yingYaoIndex: j['yingYaoIndex'] as int,
  );
}

/// 卦名中文映射（单一来源：cases/paipan 各层共用）
const guaNameCN = <GuaName, String>{
  GuaName.qian: '乾为天', GuaName.kun: '坤为地', GuaName.zhun: '水雷屯',
  GuaName.meng: '山水蒙', GuaName.xu: '水天需', GuaName.song: '天水讼',
  GuaName.shi: '地水师', GuaName.bi: '水地比', GuaName.xiaoXu: '风天小畜',
  GuaName.lv: '天泽履', GuaName.tai: '地天泰', GuaName.pi: '天地否',
  GuaName.tongRen: '天火同人', GuaName.daYou: '火天大有', GuaName.qian2: '地山谦',
  GuaName.yu: '雷地豫', GuaName.sui: '泽雷随', GuaName.gu: '山风蛊',
  GuaName.lin: '地泽临', GuaName.guan: '风地观', GuaName.shiHe: '火雷噬嗑',
  GuaName.bi2: '山火贲', GuaName.bo: '山地剥', GuaName.fu: '地雷复',
  GuaName.wuWang: '天雷无妄', GuaName.daXu: '山天大畜', GuaName.yi: '山雷颐',
  GuaName.daGuo: '泽风大过', GuaName.kan: '坎为水', GuaName.li: '离为火',
  GuaName.xian: '泽山咸', GuaName.heng: '雷风恒', GuaName.dun: '天山遁',
  GuaName.daZhuang: '雷天大壮', GuaName.jin: '火地晋', GuaName.mingYi: '地火明夷',
  GuaName.jiaRen: '风火家人', GuaName.kui: '火泽睽', GuaName.jian: '水山蹇',
  GuaName.jie: '雷水解', GuaName.sun: '山泽损', GuaName.yi2: '风雷益',
  GuaName.guai: '泽天夬', GuaName.gou: '天风姤', GuaName.cui: '泽地萃',
  GuaName.sheng: '地风升', GuaName.kun2: '泽水困', GuaName.jing: '水风井',
  GuaName.ge: '泽火革', GuaName.ding: '火风鼎', GuaName.zhen: '震为雷',
  GuaName.gen: '艮为山', GuaName.jian2: '风山渐', GuaName.guiMei: '雷泽归妹',
  GuaName.feng: '雷火丰', GuaName.lv2: '火山旅', GuaName.xun: '巽为风',
  GuaName.dui: '兑为泽', GuaName.huan: '风水涣', GuaName.jie2: '水泽节',
  GuaName.zhongFu: '风泽中孚', GuaName.xiaoGuo: '雷山小过', GuaName.jiJi: '水火既济',
  GuaName.weiJi: '火水未济',
};

/// 获取中文卦名
String guaNameToCN(GuaName name) => guaNameCN[name] ?? name.name;
