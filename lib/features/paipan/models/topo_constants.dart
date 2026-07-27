/// 六爻/梅花易数 常用拓扑常量
///
/// 将 diZhiCN / diZhiWuXing / diZhiChong / liuShenCN 从 yao_model.dart
/// 拆出，避免 gua_model.dart ⇄ yao_model.dart 循环引用。
library;

import 'yao_model.dart';
import 'gua_model.dart';

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
