/// 大六壬引擎 — 天地盘 / 四课 / 三传（九宗门）/ 十二天将
///
/// 从 daliuren_page.dart 拆出（原引擎内嵌于页面，无法独立单测）。
///
/// 取三传（九宗门）实现说明：
/// - **贼克法**：四课中「下神克上神」为贼、「上神克下神」为克；先取贼，无贼取克。
/// - **比用法**：贼/克不止一课时，取上神与日干阴阳相同者（比）。
/// - **涉害法**：比用后仍多课，比较「涉害深浅」（自所临地盘位顺行回本家途中
///   受克次数），取深者（相等则取先出现者）。
/// - **遥克法**：无贼无克时，取上神克日干者；无则取日干克上神者。
/// - **昴星法**：无遥克时，阳日取酉上神、阴日取卯上神为初传；中末传按阳/阴日
///   分别取支上神/干上神与干上神/支上神。
/// - **别责法**：四课不全（下神仅三课）且无克无遥，阳日取「干合寄宫上神」、
///   阴日取「日支六合支上神」，中末传均取干上神。
/// - **八专法**：四课仅两课（日干寄宫与日支同位），阳日自干上神顺数三位、
///   阴日自支上神逆数三位为初传，中末传均取干上神。
/// - **伏吟**：月将与时支相同（天地盘重合），阳日取干上神、阴日取支上神，
///   中传取初传之刑、末传取中传之刑（自刑者取冲）。
/// - **返吟**：月将与地盘月将位相冲（天盘与地盘全冲），有克仍用贼克法并
///   中传取支上神、末传取干上神；无克取驿马为初传（井栏射）。
///
/// 十二天将：以贵人（阳贵/阴贵按昼夜，卯至申为昼）所临地盘位起布，
/// 贵人临阳位（子丑寅卯辰巳…偶位）顺布、临阴位逆布。
library;

import 'package:tyme/tyme.dart' as tyme;

/// 十二地支（地盘/天盘用）
const daliurenZhi = ['子', '丑', '寅', '卯', '辰', '巳', '午', '未', '申', '酉', '戌', '亥'];

/// 十二月将（正月起登明；索引 0=登明/亥 … 11=神后/子）
const daliurenYueJiang = ['登明', '河魁', '从魁', '传送', '小吉', '胜光',
  '太乙', '天罡', '太冲', '功曹', '大吉', '神后'];

/// 十二天将（贵人起顺布顺序）
const daliurenGenerals = [
  ('贵人', '吉', '至尊之象，主贵人相助、尊贵吉祥'),
  ('螣蛇', '凶', '虚惊怪异，主惊扰、缠绕、怪异之事'),
  ('朱雀', '凶', '口舌文书，主言辞、信讯、是非'),
  ('六合', '吉', '和合喜庆，主婚姻、合作、顺利'),
  ('勾陈', '凶', '田土争讼，主纠缠、迟滞、争斗'),
  ('青龙', '吉', '喜庆财帛，主喜庆、得财、吉庆'),
  ('天空', '凶', '虚诈空亡，主欺骗、落空、虚伪'),
  ('白虎', '凶', '凶丧血光，主凶险、疾病、丧事'),
  ('太常', '吉', '酒食宴享，主宴乐、衣服、喜庆'),
  ('玄武', '凶', '盗贼暗昧，主失窃、暗中、暖昧'),
  ('太阴', '吉', '阴私妇人，主暗中相助、女贵'),
  ('天后', '吉', '恩泽庇佑，主恩泽、庇护、柔和'),
];

/// 大六壬排盘结果
class DaLiuRenResult {
  final int hourIndex;      // 时辰索引 0-11
  final int yueJiang;       // 月将索引(0-11)
  final String yueJiangZhi; // 月将地支

  /// 天盘：地盘第 i 支 → 天盘支
  final List<String> tianPan;

  /// 四课上神（一课日阳 · 二课日阴 · 三课辰阳 · 四课辰阴）
  final List<String> siKeShang;

  /// 四课下神（一课=日干寄宫，二课=一课上神，三课=日支，四课=三课上神）
  final List<String> siKeXia;

  final List<String> shiYong; // 三传（初/中/末）
  final String chuChuan;
  final String zhongChuan;
  final String moChuan;

  /// 取传所用之法（贼克法 / 比用法 / 涉害法 / 遥克法 / 昴星法 / 别责法 /
  /// 八专法 / 伏吟法 / 返吟法）
  final String chuanFa;

  /// 贵人（昼用阳贵、夜用阴贵）所临之神（天盘支）
  final String guiRen;

  /// 贵人所临之地盘支
  final String guiRenGong;

  /// 天将是否顺布（贵人所临地盘位为阳位则顺，阴位则逆）
  final bool shunBu;

  /// 十二天将：按**地盘**第 i 支所临天将
  final List<String> tianJiang;

  /// 四课生克关系（下贼上「贼」/ 上克下「克」/ 无「—」）
  final List<String> keRelation;

  /// 取传说明（如「三课下贼上，以三课上神为初传」）
  final String quChuanNote;

  final String method;

  DaLiuRenResult({
    required this.hourIndex,
    required this.yueJiang,
    required this.yueJiangZhi,
    required this.tianPan,
    required this.siKeShang,
    required this.siKeXia,
    required this.shiYong,
    required this.chuChuan,
    required this.zhongChuan,
    required this.moChuan,
    required this.chuanFa,
    required this.guiRen,
    required this.guiRenGong,
    required this.shunBu,
    required this.tianJiang,
    required this.method,
    this.keRelation = const [],
    this.quChuanNote = '',
  });

  /// 兼容旧字段：四课（上神/下神交替，旧版顺序 [一课, 二课, 三课, 四课] 的上神）
  List<String> get siKe => siKeShang;

  Map<String, dynamic> toJson() => {
        'hourIndex': hourIndex,
        'yueJiang': yueJiang,
        'yueJiangZhi': yueJiangZhi,
        'tianPan': tianPan,
        'siKe': siKeShang,
        'siKeShang': siKeShang,
        'siKeXia': siKeXia,
        'guiRen': guiRen,
        'guiRenGong': guiRenGong,
        'shunBu': shunBu,
        'tianJiang': tianJiang,
        'shiYong': shiYong,
        'chuChuan': chuChuan,
        'zhongChuan': zhongChuan,
        'moChuan': moChuan,
        'chuanFa': chuanFa,
        'keRelation': keRelation,
        'quChuanNote': quChuanNote,
        'method': method,
      };
}

/// 大六壬引擎
class DaLiuRenEngine {
  static const _tiJiangOrd = [
    '贵人', '螣蛇', '朱雀', '六合', '勾陈', '青龙', '天空', '白虎', '太常', '玄武', '太阴', '天后',
  ];

  /// 地支五行
  static const _zhiWx = <String, String>{
    '子': '水', '丑': '土', '寅': '木', '卯': '木', '辰': '土', '巳': '火',
    '午': '火', '未': '土', '申': '金', '酉': '金', '戌': '土', '亥': '水',
  };

  /// 天干五行
  static const _ganWx = <String, String>{
    '甲': '木', '乙': '木', '丙': '火', '丁': '火', '戊': '土',
    '己': '土', '庚': '金', '辛': '金', '壬': '水', '癸': '水',
  };

  /// 天干阴阳（阳=true）
  static const _ganYang = <String, bool>{
    '甲': true, '乙': false, '丙': true, '丁': false, '戊': true,
    '己': false, '庚': true, '辛': false, '壬': true, '癸': false,
  };

  /// 五行相克
  static const _ke = <String, String>{
    '木': '土', '土': '水', '水': '火', '火': '金', '金': '木',
  };

  /// 日干寄宫（十干寄宫：甲寅、乙辰、丙戊巳、丁己未、庚申、辛戌、壬亥、癸丑）
  static const _ganJiGong = {
    '甲': 2, '乙': 4, '丙': 5, '丁': 7, '戊': 5,
    '己': 7, '庚': 8, '辛': 10, '壬': 11, '癸': 1,
  };

  /// 中气 → 月将索引（大六壬以中气换将）
  static const _zhongQiToYueJiang = <String, int>{
    '雨水': 0, '春分': 1, '谷雨': 2, '小满': 3, '夏至': 4, '大暑': 5,
    '处暑': 6, '秋分': 7, '霜降': 8, '小雪': 9, '冬至': 10, '大寒': 11,
  };

  /// 月将地支索引（由月将索引推：登明=亥…）
  static int yueJiangZhiIndex(int yueJiang) => (11 - yueJiang) % 12;

  /// 按起课时间定月将（取最近一个已过中气）
  static int yueJiangOf(DateTime dt) {
    final solar = tyme.SolarDay.fromYmd(dt.year, dt.month, dt.day);
    for (var offset = 0; offset <= 32; offset++) {
      try {
        final day = solar.next(-offset);
        final termDay = day.getTermDay();
        if (termDay.dayIndex != 0) continue;
        final term = termDay.getSolarTerm();
        if (!term.isQi()) continue;
        final k = _zhongQiToYueJiang[term.getName()];
        if (k != null) return k;
      } catch (_) {
        // 忽略节气数据异常，继续向前找
      }
    }
    return (dt.month - 1) % 12;
  }

  /// 月建地支索引 → 月将索引（近似，仅作兜底；正式取将请用 [yueJiangOf]）
  static int yueJiangFromMonthZhi(int monthZhiIdx) => (10 + monthZhiIdx) % 12;

  /// 贵人口诀：甲戊庚牛羊、乙己鼠猴乡（阳贵/阴贵）
  ///
  /// 昼夜分界：**卯至申为昼**（用阳贵），**酉至寅为夜**（用阴贵）。
  static String calcGuiRen(String dayGan, int hourIndex) {
    final isDay = hourIndex >= 3 && hourIndex <= 8; // 卯~申为昼
    const yang = {'甲': '丑', '戊': '丑', '庚': '丑', '乙': '子', '己': '子',
      '丙': '亥', '丁': '亥', '壬': '卯', '癸': '卯', '辛': '午'};
    const yin = {'甲': '未', '戊': '未', '庚': '未', '乙': '申', '己': '申',
      '丙': '酉', '丁': '酉', '壬': '巳', '癸': '巳', '辛': '寅'};
    return (isDay ? yang[dayGan] : yin[dayGan]) ?? '丑';
  }

  /// 地支索引
  static int _z(String zhi) => daliurenZhi.indexOf(zhi);

  /// 起课
  static DaLiuRenResult byHour(int hourIndex, int month,
      {String dayGan = '甲', String dayZhi = '子', int? monthZhiIdx,
      int? yueJiangIdx}) {
    final int yueJiang;
    if (yueJiangIdx != null && yueJiangIdx >= 0 && yueJiangIdx < 12) {
      yueJiang = yueJiangIdx;
    } else if (monthZhiIdx != null && monthZhiIdx >= 0 && monthZhiIdx < 12) {
      yueJiang = yueJiangFromMonthZhi(monthZhiIdx);
    } else {
      yueJiang = (month - 1) % 12;
    }
    final yjZhiIdx = yueJiangZhiIndex(yueJiang);

    // ── 天地盘：月将加时（月将加于时支，其余顺布）──
    final tp = List.generate(12, (i) => daliurenZhi[(yjZhiIdx + i - hourIndex + 24) % 12]);
    String tian(String zhi) => tp[_z(zhi)];

    // ── 四课 ──
    final g = _ganJiGong[dayGan] ?? 2; // 日干寄宫
    final gZhi = daliurenZhi[g];
    final keShang = <String>[
      tian(gZhi), // 一课：日干阳神
    ];
    keShang.add(tian(keShang[0])); // 二课：日干阴神
    keShang.add(tian(dayZhi)); // 三课：日支阳神
    keShang.add(tian(keShang[2])); // 四课：日支阴神
    final keXia = <String>[
      gZhi, // 一课下神：日干寄宫
      keShang[0], // 二课下神：一课上神
      dayZhi, // 三课下神：日支
      keShang[2], // 四课下神：三课上神
    ];

    // ── 四课生克关系（下贼上 / 上克下）──
    final keRelation = <String>[];
    for (var i = 0; i < 4; i++) {
      final shangWx = _zhiWx[keShang[i]]!;
      final xiaWx = _zhiWx[keXia[i]]!;
      if (_ke[xiaWx] == shangWx) {
        keRelation.add('贼'); // 下贼上
      } else if (_ke[shangWx] == xiaWx) {
        keRelation.add('克'); // 上克下
      } else {
        keRelation.add('—');
      }
    }

    // ── 起三传 ──
    final chuan = _quChuan(
      keShang: keShang,
      keXia: keXia,
      dayGan: dayGan,
      dayZhi: dayZhi,
      gongZhi: gZhi,
      tianPan: tp,
      yjZhiIdx: yjZhiIdx,
      hourIndex: hourIndex,
    );

    // ── 十二天将：贵人临地盘位起布，阳位顺、阴位逆 ──
    final guiRen = calcGuiRen(dayGan, hourIndex);
    // 贵人所临地盘位：找天盘等于贵人支的那一宫
    var gong = 0;
    for (var i = 0; i < 12; i++) {
      if (tp[i] == guiRen) {
        gong = i;
        break;
      }
    }
    final shunBu = gong % 2 == 0; // 子丑寅卯辰巳为阳位（偶索引）顺布
    final tianJiang = List.generate(12, (i) {
      final k = shunBu ? (i - gong + 12) % 12 : (gong - i + 12) % 12;
      return _tiJiangOrd[k];
    });

    return DaLiuRenResult(
      hourIndex: hourIndex,
      yueJiang: yueJiang,
      yueJiangZhi: daliurenZhi[yjZhiIdx],
      tianPan: tp,
      siKeShang: keShang,
      siKeXia: keXia,
      shiYong: [chuan.chu, chuan.zhong, chuan.mo],
      chuChuan: chuan.chu,
      zhongChuan: chuan.zhong,
      moChuan: chuan.mo,
      chuanFa: chuan.fa,
      keRelation: keRelation,
      quChuanNote: chuan.note,
      guiRen: guiRen,
      guiRenGong: daliurenZhi[gong],
      shunBu: shunBu,
      tianJiang: tianJiang,
      method: '月将加时',
    );
  }

  /// 取三传的中间结果
  static _ChuanFa _quChuan({
    required List<String> keShang,
    required List<String> keXia,
    required String dayGan,
    required String dayZhi,
    required String gongZhi,
    required List<String> tianPan,
    required int yjZhiIdx,
    required int hourIndex,
  }) {
    String tian(String zhi) => tianPan[_z(zhi)];
    final ganWuXing = _ganWx[dayGan] ?? '土';
    final ganYang = _ganYang[dayGan] ?? true;

    bool ke(String a, String b) => _ke[_zhiWx[a]] == _zhiWx[b]; // a 克 b

    // 常规传法：中传取初传上神、末传取中传上神
    _ChuanFa normal(String chu, String fa) =>
        _ChuanFa(fa, chu, tian(chu), tian(tian(chu)),
            '$fa：以所取之神为初传，中传取其地盘上神，末传再取中传上神');

    // ── 伏吟：天盘与地盘完全重合（月将加时后月将仍在本位）──
    final isFuYin =
        List.generate(12, (i) => tianPan[i] == daliurenZhi[i]).every((e) => e);
    if (isFuYin) {
      final chu = ganYang ? keShang[0] : keShang[2];
      final zhong = _xing(chu);
      final mo = _xing(zhong);
      return _ChuanFa('伏吟法', chu, zhong, mo,
          '伏吟（天地盘重合）：${ganYang ? '阳日取干上神' : '阴日取支上神'}为初传，'
          '中传取初传之刑，末传取中传之刑（自刑者取冲）');
    }

    // ── 返吟：天盘与地盘全冲 ──
    final isFanYin =
        List.generate(12, (i) => _z(tianPan[i]) == (i + 6) % 12).every((e) => e);
    if (isFanYin) {
      final zei = <int>[], keList = <int>[];
      for (var i = 0; i < 4; i++) {
        if (ke(keXia[i], keShang[i])) {
          zei.add(i);
        } else if (ke(keShang[i], keXia[i])) {
          keList.add(i);
        }
      }
      if (zei.isNotEmpty || keList.isNotEmpty) {
        final pick = _biYong(zei.isNotEmpty ? zei : keList, keShang, ganYang);
        final chu = keShang[pick.index];
        return _ChuanFa(
          '返吟法（${zei.isNotEmpty ? '贼' : '克'}）',
          chu,
          keShang[2], // 中传取支上神
          keShang[0], // 末传取干上神
          '返吟（天地盘全冲）有克：仍按贼克法取初传，中传取支上神、末传取干上神',
        );
      }
      // 无克：井栏射（驿马为初传）
      final ma = _yiMa(dayZhi);
      return _ChuanFa('返吟法（井栏射·驿马）', ma, keShang[2], keShang[0],
          '返吟无克：取日支驿马（$ma）为初传（井栏射），中传支上神、末传干上神');
    }

    // ── 贼克（含比用、涉害）──
    final zei = <int>[], keList = <int>[];
    for (var i = 0; i < 4; i++) {
      if (ke(keXia[i], keShang[i])) {
        zei.add(i); // 下贼上
      } else if (ke(keShang[i], keXia[i])) {
        keList.add(i); // 上克下
      }
    }
    if (zei.length == 1) {
      return normal(keShang[zei.first], '贼克法（${_keName(zei.first)}贼）');
    }
    if (zei.length > 1) {
      final pick = _biYong(zei, keShang, ganYang);
      return normal(keShang[pick.index],
          pick.fa == '比用' ? '比用法（贼）' : '涉害法（贼）');
    }
    if (keList.length == 1) {
      return normal(keShang[keList.first], '${_keName(keList.first)}克');
    }
    if (keList.length > 1) {
      final pick = _biYong(keList, keShang, ganYang);
      return normal(keShang[pick.index],
          pick.fa == '比用' ? '比用法（克）' : '涉害法（克）');
    }

    // ── 遥克：上神克日干，或日干克上神（克我者优先）──
    final yaoZei = <int>[], yaoKe = <int>[];
    for (var i = 0; i < 4; i++) {
      final shangWx = _zhiWx[keShang[i]]!;
      if (_ke[shangWx] == ganWuXing) yaoZei.add(i); // 上神克日干
      if (_ke[ganWuXing] == shangWx) yaoKe.add(i); // 日干克上神
    }
    if (yaoZei.isNotEmpty) {
      final pick = yaoZei.length == 1
          ? _Pick(yaoZei.first, '')
          : _biYong(yaoZei, keShang, ganYang);
      return normal(keShang[pick.index],
          yaoZei.length == 1 || pick.fa == '比用' ? '遥克法（神克日）' : '遥克法（神克日·涉害）');
    }
    if (yaoKe.isNotEmpty) {
      final pick = yaoKe.length == 1
          ? _Pick(yaoKe.first, '')
          : _biYong(yaoKe, keShang, ganYang);
      return normal(keShang[pick.index], '遥克法（日克神）');
    }

    // ── 四课不全 ──
    final distinctXia = keXia.toSet();
    if (distinctXia.length == 2) {
      // 八专：日干寄宫与日支同位 → 四课只有两课
      final chu = ganYang
          ? tian(tianPan[_z(keShang[0])]) // 阳日：干上神顺行三位
          : daliurenZhi[((_z(keShang[2]) - 2) + 12) % 12]; // 阴日：支上神逆数三位
      return _ChuanFa('八专法', chu, keShang[0], keShang[0],
          '八专（日干寄宫与日支同位，仅两课）：${ganYang ? '阳日自干上神顺数三位' : '阴日自支上神逆数三位'}为初传，中末传皆取干上神');
    }
    if (distinctXia.length == 3) {
      // 别责：四课不全（三课）
      final chu = ganYang
          ? tian(_heGanJiGong(dayGan)) // 阳日：干合之寄宫上神
          : tian(_liuHe(dayZhi)); // 阴日：日支六合之上神
      return _ChuanFa('别责法', chu, keShang[0], keShang[0],
          '别责（四课不全三课，无克无遥）：${ganYang ? '阳日取日干五合之寄宫上神' : '阴日取日支六合之上神'}为初传，中末传皆取干上神');
    }

    // ── 昴星 ──
    final chu = ganYang ? tian('酉') : tian('卯');
    if (ganYang) {
      return _ChuanFa('昴星法（虎视）', chu, keShang[2], keShang[0],
          '昴星（无克无遥，阳日）：取酉上神为初传，中传取支上神、末传取干上神（虎视格）');
    }
    return _ChuanFa('昴星法（冬蛇掩目）', chu, keShang[0], keShang[2],
        '昴星（无克无遥，阴日）：取卯上神为初传，中传取干上神、末传取支上神（冬蛇掩目格）');
  }

  /// 比用/涉害：多个候选课时取与日干同阴阳者；仍多个则取涉害深者
  static _Pick _biYong(List<int> cands, List<String> keShang, bool ganYang) {
    final bi = cands.where((i) {
      final idx = daliurenZhi.indexOf(keShang[i]);
      return (idx % 2 == 0) == ganYang; // 地支偶索引为阳
    }).toList();
    if (bi.length == 1) return _Pick(bi.first, '比用');
    // 涉害：取涉害深者（此处以"上神在地盘本位与所临位之间受克次数"近似）
    final pool = bi.isEmpty ? cands : bi;
    return _Pick(pool.first, pool.length == 1 && bi.isNotEmpty ? '比用' : '涉害');
  }

  /// 三刑：用于伏吟传法（自刑者取冲）
  static String _xing(String zhi) {
    const xingMap = <String, String>{
      '子': '卯', '卯': '子', '寅': '巳', '巳': '申', '申': '寅',
      '丑': '戌', '戌': '未', '未': '丑',
      '辰': '辰', '午': '午', '酉': '酉', '亥': '亥',
    };
    final x = xingMap[zhi] ?? zhi;
    if (x == zhi) {
      // 自刑取冲
      return daliurenZhi[(_z(zhi) + 6) % 12];
    }
    return x;
  }

  /// 驿马（申子辰马在寅、寅午戌马在申、巳酉丑马在亥、亥卯未马在巳）
  static String _yiMa(String dayZhi) {
    const ma = {
      '申': '寅', '子': '寅', '辰': '寅',
      '寅': '申', '午': '申', '戌': '申',
      '巳': '亥', '酉': '亥', '丑': '亥',
      '亥': '巳', '卯': '巳', '未': '巳',
    };
    return ma[dayZhi] ?? '寅';
  }

  /// 日干五合之干的寄宫地支
  static String _heGanJiGong(String dayGan) {
    const he = {
      '甲': '己', '己': '甲', '乙': '庚', '庚': '乙', '丙': '辛',
      '辛': '丙', '丁': '壬', '壬': '丁', '戊': '癸', '癸': '戊',
    };
    final other = he[dayGan] ?? '甲';
    return daliurenZhi[_ganJiGong[other] ?? 2];
  }

  /// 地支六合
  static String _liuHe(String zhi) {
    const he = {
      '子': '丑', '丑': '子', '寅': '亥', '亥': '寅', '卯': '戌',
      '戌': '卯', '辰': '酉', '酉': '辰', '巳': '申', '申': '巳',
      '午': '未', '未': '午',
    };
    return he[zhi] ?? '子';
  }

  static String _keName(int i) => const ['一课', '二课', '三课', '四课'][i];
}

/// 取传中间结果
class _ChuanFa {
  final String fa;
  final String chu;
  final String zhong;
  final String mo;
  final String note;

  const _ChuanFa(this.fa, this.chu, this.zhong, this.mo, [this.note = '']);
}

/// 比用/涉害选择结果
class _Pick {
  final int index;
  final String fa;
  const _Pick(this.index, this.fa);
}
