// 六爻纳甲参考资料
//
// 包含六神、世应、旬空、旺衰、纳甲等基础知识

library;
/// 六神详解
class LiuShenInfo {
  final String name;
  final String wuXing;
  final String season;
  final String meaning;
  final String colorHex;

  const LiuShenInfo({
    required this.name,
    required this.wuXing,
    required this.season,
    required this.meaning,
    required this.colorHex,
  });
}

/// 旬空表条目
class XunKongEntry {
  final String jiaZi;
  final String kongWang;

  const XunKongEntry({required this.jiaZi, required this.kongWang});
}

/// 纳甲表条目
class NaJiaEntry {
  final String gua;
  final String innerGan;
  final String outerGan;

  const NaJiaEntry({
    required this.gua,
    required this.innerGan,
    required this.outerGan,
  });
}

// ==================== 数据 ====================

/// 六神列表
const liuShenList = <LiuShenInfo>[
  LiuShenInfo(
    name: '青龙',
    wuXing: '木',
    season: '春',
    meaning: '主吉庆、喜事、财禄。性格耿直、仁慈。若临吉神则大吉，凶神则减凶。',
    colorHex: '#2E7D32',
  ),
  LiuShenInfo(
    name: '朱雀',
    wuXing: '火',
    season: '夏',
    meaning: '主口舌、官非、文书、信息。性格急躁、善辩。临旺相主文章佳，休囚主口舌是非。',
    colorHex: '#D32F2F',
  ),
  LiuShenInfo(
    name: '勾陈',
    wuXing: '土',
    season: '四季',
    meaning: '主田土、房产、迟滞、忧虑。性格稳重、迟缓。占田土房产为吉，占功名为迟。',
    colorHex: '#EF6C00',
  ),
  LiuShenInfo(
    name: '螣蛇',
    wuXing: '土',
    season: '四季',
    meaning: '主虚惊、怪异、梦幻、缠绕。性格多疑、善变。占梦主怪异，占病主缠绵。',
    colorHex: '#9C27B0',
  ),
  LiuShenInfo(
    name: '白虎',
    wuXing: '金',
    season: '秋',
    meaning: '主凶丧、血光、刑戮、疾病。性格刚烈、勇猛。占病主重，占官主刑。',
    colorHex: '#BDBDBD',
  ),
  LiuShenInfo(
    name: '玄武',
    wuXing: '水',
    season: '冬',
    meaning: '主盗贼、暗昧、隐秘、偷情。性格阴柔、隐秘。占遗失主被盗，占感情主暧昧。',
    colorHex: '#37474F',
  ),
];

/// 八宫世应表（八纯卦世应位置）
const shiYingTable = <Map<String, String>>[
  {'宫': '乾宫', '世': '上爻', '应': '三爻'},
  {'宫': '兑宫', '世': '上爻', '应': '三爻'},
  {'宫': '离宫', '世': '上爻', '应': '三爻'},
  {'宫': '震宫', '世': '上爻', '应': '三爻'},
  {'宫': '巽宫', '世': '四爻', '应': '一爻'},
  {'宫': '坎宫', '世': '五爻', '应': '二爻'},
  {'宫': '艮宫', '世': '三爻', '应': '上爻'},
  {'宫': '坤宫', '世': '三爻', '应': '上爻'},
];

/// 旬空表（六十甲子旬空）
const xunKongTable = <XunKongEntry>[
  XunKongEntry(jiaZi: '甲子旬', kongWang: '戌亥'),
  XunKongEntry(jiaZi: '甲戌旬', kongWang: '申酉'),
  XunKongEntry(jiaZi: '甲申旬', kongWang: '午未'),
  XunKongEntry(jiaZi: '甲午旬', kongWang: '辰巳'),
  XunKongEntry(jiaZi: '甲辰旬', kongWang: '寅卯'),
  XunKongEntry(jiaZi: '甲寅旬', kongWang: '子丑'),
];

/// 五行旺衰表（月建对五行）
const wangShuaiTable = <Map<String, String>>[
  {'月建': '寅卯月(春)', '旺': '木', '相': '火', '休': '水', '囚': '金', '死': '土'},
  {'月建': '巳午月(夏)', '旺': '火', '相': '土', '休': '木', '囚': '水', '死': '金'},
  {'月建': '申酉月(秋)', '旺': '金', '相': '水', '休': '土', '囚': '火', '死': '木'},
  {'月建': '亥子月(冬)', '旺': '水', '相': '木', '休': '金', '囚': '土', '死': '火'},
  {'月建': '辰戌丑未月(四季)', '旺': '土', '相': '金', '休': '火', '囚': '木', '死': '水'},
];

/// 纳甲表
const naJiaTable = <NaJiaEntry>[
  NaJiaEntry(gua: '乾', innerGan: '甲子', outerGan: '甲午'),
  NaJiaEntry(gua: '兑', innerGan: '丁巳', outerGan: '丁亥'),
  NaJiaEntry(gua: '离', innerGan: '己卯', outerGan: '己酉'),
  NaJiaEntry(gua: '震', innerGan: '庚子', outerGan: '庚午'),
  NaJiaEntry(gua: '巽', innerGan: '辛丑', outerGan: '辛未'),
  NaJiaEntry(gua: '坎', innerGan: '戊寅', outerGan: '戊申'),
  NaJiaEntry(gua: '艮', innerGan: '丙辰', outerGan: '丙戌'),
  NaJiaEntry(gua: '坤', innerGan: '乙未', outerGan: '乙丑'),
];

/// 五行生克（六爻用法）
const wuXingRelation = [
  '生我者为父母（生扶）',
  '我生者为子孙（泄气）',
  '克我者为官鬼（克制）',
  '我克者为妻财（耗力）',
  '同我者为兄弟（比和）',
];

/// 六爻六亲含义
const liuQinMeanings = <Map<String, String>>[
  {'亲': '父母', '含义': '主辛苦、文书、长辈、房屋、车辆、舟车'},
  {'亲': '兄弟', '含义': '主竞争、破财、同辈、朋友、手足'},
  {'亲': '官鬼', '含义': '主官非、疾病、丈夫、事业、压力'},
  {'亲': '妻财', '含义': '主财富、妻子、仆从、金钱、货物'},
  {'亲': '子孙', '含义': '主福禄、子女、医生、僧道、消灾'},
];
