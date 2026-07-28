/// 八字参考资料数据 — 类结构版（参照六爻 LiuShenInfo 风格）
library;

/// 天干信息
class TianGanInfo {
  /// 天干名
  final String name;
  /// 五行属性
  final String wuXing;
  /// 阴阳（阳/阴）
  final String yinYang;
  /// 类象描述
  final String image;
  /// 方位
  final String direction;
  /// 对应身体
  final String body;

  const TianGanInfo({
    required this.name,
    required this.wuXing,
    required this.yinYang,
    required this.image,
    required this.direction,
    required this.body,
  });
}

/// 地支信息
class DiZhiInfo {
  /// 地支名
  final String name;
  /// 生肖
  final String shengXiao;
  /// 五行属性
  final String wuXing;
  /// 阴阳
  final String yinYang;
  /// 月份范围
  final String month;
  /// 时辰范围
  final String hourRange;
  /// 类象描述
  final String image;
  /// 方位
  final String direction;

  const DiZhiInfo({
    required this.name,
    required this.shengXiao,
    required this.wuXing,
    required this.yinYang,
    required this.month,
    required this.hourRange,
    required this.image,
    required this.direction,
  });
}

/// 藏干条目
class CangGanEntry {
  /// 地支
  final String diZhi;
  /// 本气（主气）
  final String benQi;
  /// 中气
  final String zhongQi;
  /// 余气
  final String yuQi;

  const CangGanEntry({
    required this.diZhi,
    required this.benQi,
    required this.zhongQi,
    required this.yuQi,
  });
}

/// 十神关系
class ShiShenRelation {
  /// 关系名
  final String name;
  /// 以日干为基准的关系描述
  final String description;
  /// 吉凶偏向
  final String nature;
  /// 六亲对应
  final String relation;
  /// 事物类象
  final String image;

  const ShiShenRelation({
    required this.name,
    required this.description,
    required this.nature,
    required this.relation,
    required this.image,
  });
}

/// 五行旺衰状态
class WuXingWangShuaiInfo {
  /// 五行
  final String wuXing;
  /// 状态（旺相休囚死）
  final String status;
  /// 含义
  final String meaning;

  const WuXingWangShuaiInfo({
    required this.wuXing,
    required this.status,
    required this.meaning,
  });
}

// ==================== 数据 ====================

/// 十天干表
const tianGanList = <TianGanInfo>[
  TianGanInfo(
    name: '甲', wuXing: '木', yinYang: '阳',
    image: '参天大树，栋梁之材，象征正直、积极向上',
    direction: '东方', body: '头、胆',
  ),
  TianGanInfo(
    name: '乙', wuXing: '木', yinYang: '阴',
    image: '花草藤蔓，柔韧曲折，象征灵活、适应力强',
    direction: '东方', body: '肩、肝',
  ),
  TianGanInfo(
    name: '丙', wuXing: '火', yinYang: '阳',
    image: '太阳之火，光明温暖，象征热情、威严',
    direction: '南方', body: '小肠、肩',
  ),
  TianGanInfo(
    name: '丁', wuXing: '火', yinYang: '阴',
    image: '灯烛之火，温和明亮，象征文明、细腻',
    direction: '南方', body: '心、血液',
  ),
  TianGanInfo(
    name: '戊', wuXing: '土', yinYang: '阳',
    image: '高岗厚土，稳重包容，象征诚信、厚重',
    direction: '中央', body: '胃、鼻',
  ),
  TianGanInfo(
    name: '己', wuXing: '土', yinYang: '阴',
    image: '田园沃土，滋养万物，象征谦逊、包容',
    direction: '中央', body: '脾、腹',
  ),
  TianGanInfo(
    name: '庚', wuXing: '金', yinYang: '阳',
    image: '刀剑斧钺，刚健锐利，象征果断、变革',
    direction: '西方', body: '大肠、骨',
  ),
  TianGanInfo(
    name: '辛', wuXing: '金', yinYang: '阴',
    image: '珠玉金银，精致珍贵，象征敏感、才华',
    direction: '西方', body: '肺、皮毛',
  ),
  TianGanInfo(
    name: '壬', wuXing: '水', yinYang: '阳',
    image: '江河大海，浩瀚奔流，象征智慧、气魄',
    direction: '北方', body: '膀胱、耳',
  ),
  TianGanInfo(
    name: '癸', wuXing: '水', yinYang: '阴',
    image: '雨露甘霖，润物无声，象征细腻、谋略',
    direction: '北方', body: '肾、私处',
  ),
];

/// 十二地支表
const diZhiList = <DiZhiInfo>[
  DiZhiInfo(
    name: '子', shengXiao: '鼠', wuXing: '水', yinYang: '阳',
    month: '11月', hourRange: '23:00-01:00',
    image: '墨池之水，暗藏生机，主智谋变化',
    direction: '北方',
  ),
  DiZhiInfo(
    name: '丑', shengXiao: '牛', wuXing: '土', yinYang: '阴',
    month: '12月', hourRange: '01:00-03:00',
    image: '寒湿冻土，含金藏水，主勤恳积蓄',
    direction: '东北',
  ),
  DiZhiInfo(
    name: '寅', shengXiao: '虎', wuXing: '木', yinYang: '阳',
    month: '1月', hourRange: '03:00-05:00',
    image: '深山巨木，蕴火藏土，主开创进取',
    direction: '东北',
  ),
  DiZhiInfo(
    name: '卯', shengXiao: '兔', wuXing: '木', yinYang: '阴',
    month: '2月', hourRange: '05:00-07:00',
    image: '花木繁茂，秀美柔顺，主温和文雅',
    direction: '东方',
  ),
  DiZhiInfo(
    name: '辰', shengXiao: '龙', wuXing: '土', yinYang: '阳',
    month: '3月', hourRange: '07:00-09:00',
    image: '湿地沃土，蓄水藏木，主包容变通',
    direction: '东南',
  ),
  DiZhiInfo(
    name: '巳', shengXiao: '蛇', wuXing: '火', yinYang: '阴',
    month: '4月', hourRange: '09:00-11:00',
    image: '炉冶之火，炼金成器，主智谋变化',
    direction: '东南',
  ),
  DiZhiInfo(
    name: '午', shengXiao: '马', wuXing: '火', yinYang: '阳',
    month: '5月', hourRange: '11:00-13:00',
    image: '当空烈日，光明炽盛，主热情奔放',
    direction: '南方',
  ),
  DiZhiInfo(
    name: '未', shengXiao: '羊', wuXing: '土', yinYang: '阴',
    month: '6月', hourRange: '13:00-15:00',
    image: '园林之土，藏火生木，主温和滋养',
    direction: '西南',
  ),
  DiZhiInfo(
    name: '申', shengXiao: '猴', wuXing: '金', yinYang: '阳',
    month: '7月', hourRange: '15:00-17:00',
    image: '刀剑寒金，霜雪肃杀，主果断刚毅',
    direction: '西南',
  ),
  DiZhiInfo(
    name: '酉', shengXiao: '鸡', wuXing: '金', yinYang: '阴',
    month: '8月', hourRange: '17:00-19:00',
    image: '珠宝美玉，精致玲珑，主工艺才华',
    direction: '西方',
  ),
  DiZhiInfo(
    name: '戌', shengXiao: '狗', wuXing: '土', yinYang: '阳',
    month: '9月', hourRange: '19:00-21:00',
    image: '燥土熔炉，藏金纳火，主忠厚刚直',
    direction: '西北',
  ),
  DiZhiInfo(
    name: '亥', shengXiao: '猪', wuXing: '水', yinYang: '阴',
    month: '10月', hourRange: '21:00-23:00',
    image: '江海静水，藏木纳甲，主智慧深沉',
    direction: '西北',
  ),
];

/// 藏干表
const cangGanList = <CangGanEntry>[
  CangGanEntry(diZhi: '子', benQi: '癸', zhongQi: '—', yuQi: '—'),
  CangGanEntry(diZhi: '丑', benQi: '己', zhongQi: '癸', yuQi: '辛'),
  CangGanEntry(diZhi: '寅', benQi: '甲', zhongQi: '丙', yuQi: '戊'),
  CangGanEntry(diZhi: '卯', benQi: '乙', zhongQi: '—', yuQi: '—'),
  CangGanEntry(diZhi: '辰', benQi: '戊', zhongQi: '乙', yuQi: '癸'),
  CangGanEntry(diZhi: '巳', benQi: '丙', zhongQi: '庚', yuQi: '戊'),
  CangGanEntry(diZhi: '午', benQi: '丁', zhongQi: '己', yuQi: '—'),
  CangGanEntry(diZhi: '未', benQi: '己', zhongQi: '丁', yuQi: '乙'),
  CangGanEntry(diZhi: '申', benQi: '庚', zhongQi: '壬', yuQi: '戊'),
  CangGanEntry(diZhi: '酉', benQi: '辛', zhongQi: '—', yuQi: '—'),
  CangGanEntry(diZhi: '戌', benQi: '戊', zhongQi: '辛', yuQi: '丁'),
  CangGanEntry(diZhi: '亥', benQi: '壬', zhongQi: '甲', yuQi: '—'),
];

/// 十神表
const shiShenList = <ShiShenRelation>[
  ShiShenRelation(
    name: '比肩', description: '与日干五行相同、阴阳相同',
    nature: '中性偏吉', relation: '兄弟姐妹、朋友、同事',
    image: '竞争、合作、自我、手足之情',
  ),
  ShiShenRelation(
    name: '劫财', description: '与日干五行相同、阴阳相反',
    nature: '凶中藏吉', relation: '姐妹兄弟、合伙人、对手',
    image: '争夺、损耗、合作、破财',
  ),
  ShiShenRelation(
    name: '食神', description: '日干所生、阴阳相同（我生）',
    nature: '吉神', relation: '晚辈、学生、下属',
    image: '才华、福气、享乐、口福、艺术',
  ),
  ShiShenRelation(
    name: '伤官', description: '日干所生、阴阳相反（我生）',
    nature: '凶神', relation: '女儿（女命）、晚辈',
    image: '才华、傲气、叛逆、变动、伤灾',
  ),
  ShiShenRelation(
    name: '偏财', description: '日干所克、阴阳相同（我克）',
    nature: '吉神', relation: '父亲、偏妻、男命情人',
    image: '意外之财、投资、大方、商业',
  ),
  ShiShenRelation(
    name: '正财', description: '日干所克、阴阳相反（我克）',
    nature: '吉神', relation: '妻子（男命）、正妻',
    image: '正当收入、节俭、稳定、婚姻',
  ),
  ShiShenRelation(
    name: '偏印', description: '生日干、阴阳相同（生我）',
    nature: '中性', relation: '继母、长辈、师长',
    image: '学识、思考、偏门、孤独、清高',
  ),
  ShiShenRelation(
    name: '正印', description: '生日干、阴阳相反（生我）',
    nature: '吉神', relation: '母亲、长辈、贵人',
    image: '学业、文凭、仁慈、健康、稳定',
  ),
  ShiShenRelation(
    name: '七杀', description: '克日干、阴阳相同（克我）',
    nature: '凶神', relation: '严父、上司、小人',
    image: '压力、权威、果断、灾祸、威严',
  ),
  ShiShenRelation(
    name: '正官', description: '克日干、阴阳相反（克我）',
    nature: '吉神', relation: '丈夫（女命）、上级',
    image: '官职、名誉、纪律、管理、守法',
  ),
];

/// 五行旺衰表（按月令）
const wuXingWangShuaiTable = <WuXingWangShuaiInfo>[
  WuXingWangShuaiInfo(wuXing: '木', status: '旺', meaning: '当令者旺，如春木得时，生机勃勃'),
  WuXingWangShuaiInfo(wuXing: '火', status: '相', meaning: '我生者相，如木生火，次旺之势'),
  WuXingWangShuaiInfo(wuXing: '金', status: '囚', meaning: '克我者囚，如金克木反被囚'),
  WuXingWangShuaiInfo(wuXing: '水', status: '休', meaning: '生我者休，如水生木而退位'),
  WuXingWangShuaiInfo(wuXing: '土', status: '死', meaning: '我克者死，如木克土而最衰'),
];

/// 传统天干表（Map格式，兼容旧代码）
const tianGanTable = <Map<String, String>>[
  {'天干': '甲', '五行': '木', '阴阳': '阳', '类象': '参天大树'},
  {'天干': '乙', '五行': '木', '阴阳': '阴', '类象': '花草藤蔓'},
  {'天干': '丙', '五行': '火', '阴阳': '阳', '类象': '太阳之火'},
  {'天干': '丁', '五行': '火', '阴阳': '阴', '类象': '灯烛之火'},
  {'天干': '戊', '五行': '土', '阴阳': '阳', '类象': '高岗厚土'},
  {'天干': '己', '五行': '土', '阴阳': '阴', '类象': '田园沃土'},
  {'天干': '庚', '五行': '金', '阴阳': '阳', '类象': '刀剑斧钺'},
  {'天干': '辛', '五行': '金', '阴阳': '阴', '类象': '珠玉金银'},
  {'天干': '壬', '五行': '水', '阴阳': '阳', '类象': '江河大海'},
  {'天干': '癸', '五行': '水', '阴阳': '阴', '类象': '雨露甘霖'},
];

/// 传统地支表（Map格式，兼容旧代码）
const diZhiTable = <Map<String, String>>[
  {'地支': '子', '生肖': '鼠', '五行': '水', '月份': '11月', '类象': '墨池之水'},
  {'地支': '丑', '生肖': '牛', '五行': '土', '月份': '12月', '类象': '寒湿冻土'},
  {'地支': '寅', '生肖': '虎', '五行': '木', '月份': '1月', '类象': '深山巨木'},
  {'地支': '卯', '生肖': '兔', '五行': '木', '月份': '2月', '类象': '花木繁茂'},
  {'地支': '辰', '生肖': '龙', '五行': '土', '月份': '3月', '类象': '湿地沃土'},
  {'地支': '巳', '生肖': '蛇', '五行': '火', '月份': '4月', '类象': '炉冶之火'},
  {'地支': '午', '生肖': '马', '五行': '火', '月份': '5月', '类象': '当空烈日'},
  {'地支': '未', '生肖': '羊', '五行': '土', '月份': '6月', '类象': '园林之土'},
  {'地支': '申', '生肖': '猴', '五行': '金', '月份': '7月', '类象': '刀剑寒金'},
  {'地支': '酉', '生肖': '鸡', '五行': '金', '月份': '8月', '类象': '珠宝美玉'},
  {'地支': '戌', '生肖': '狗', '五行': '土', '月份': '9月', '类象': '燥土熔炉'},
  {'地支': '亥', '生肖': '猪', '五行': '水', '月份': '10月', '类象': '江海静水'},
];

/// 传统藏干表（Map格式，兼容旧代码）
const cangGanTable = <Map<String, String>>[
  {'地支': '子', '本气': '癸', '中气': '—', '余气': '—'},
  {'地支': '丑', '本气': '己', '中气': '癸', '余气': '辛'},
  {'地支': '寅', '本气': '甲', '中气': '丙', '余气': '戊'},
  {'地支': '卯', '本气': '乙', '中气': '—', '余气': '—'},
  {'地支': '辰', '本气': '戊', '中气': '乙', '余气': '癸'},
  {'地支': '巳', '本气': '丙', '中气': '庚', '余气': '戊'},
  {'地支': '午', '本气': '丁', '中气': '己', '余气': '—'},
  {'地支': '未', '本气': '己', '中气': '丁', '余气': '乙'},
  {'地支': '申', '本气': '庚', '中气': '壬', '余气': '戊'},
  {'地支': '酉', '本气': '辛', '中气': '—', '余气': '—'},
  {'地支': '戌', '本气': '戊', '中气': '辛', '余气': '丁'},
  {'地支': '亥', '本气': '壬', '中气': '甲', '余气': '—'},
];
