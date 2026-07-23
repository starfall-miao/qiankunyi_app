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
}
