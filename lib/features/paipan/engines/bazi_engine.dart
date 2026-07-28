/// 八字排盘引擎 — 基于 tyme4dart
library;

import 'package:tyme/tyme.dart' as tyme;

import '../models/bazi_models.dart';

/// 天干中文字符列表（按顺序索引 0-9）
const _tianGanCN = ['甲', '乙', '丙', '丁', '戊', '己', '庚', '辛', '壬', '癸'];

/// 地支中文字符列表（按顺序索引 0-11）
const _diZhiCN = ['子', '丑', '寅', '卯', '辰', '巳', '午', '未', '申', '酉', '戌', '亥'];

/// 天干五行映射
const _tianGanWuXing = {
  '甲': '木', '乙': '木', '丙': '火', '丁': '火',
  '戊': '土', '己': '土', '庚': '金', '辛': '金',
  '壬': '水', '癸': '水',
};

/// 天干阴阳（true=阳，false=阴）
const _tianGanYinYang = {'甲': true, '乙': false, '丙': true, '丁': false, '戊': true, '己': false, '庚': true, '辛': false, '壬': true, '癸': false};

/// 藏干对应表（每宫地支藏天干）
/// - 本气：地支主气
/// - 中气：地支中气
/// - 余气：地支余气
const _cangGanMap = {
  '子': {'本气': '癸', '中气': '无', '余气': '无'},
  '丑': {'本气': '己', '中气': '癸', '余气': '辛'},
  '寅': {'本气': '甲', '中气': '丙', '余气': '戊'},
  '卯': {'本气': '乙', '中气': '无', '余气': '无'},
  '辰': {'本气': '戊', '中气': '乙', '余气': '癸'},
  '巳': {'本气': '丙', '中气': '庚', '余气': '戊'},
  '午': {'本气': '丁', '中气': '己', '余气': '无'},
  '未': {'本气': '己', '中气': '丁', '余气': '乙'},
  '申': {'本气': '庚', '中气': '壬', '余气': '戊'},
  '酉': {'本气': '辛', '中气': '无', '余气': '无'},
  '戌': {'本气': '戊', '中气': '辛', '余气': '丁'},
  '亥': {'本气': '壬', '中气': '甲', '余气': '无'},
};

/// 五行相生顺序（用于旺衰推算）
const _wuXingOrder = ['木', '火', '土', '金', '水'];

/// 月令五行映射（地支 → 五行）
const _monthZhiWuXing = {
  '寅': '木', '卯': '木',
  '巳': '火', '午': '火',
  '申': '金', '酉': '金',
  '亥': '水', '子': '水',
  '辰': '土', '戌': '土', '丑': '土', '未': '土',
};

/// 计算大运（顺排/逆排）
List<DaYun> _calcDaYun(String yearGan, String monthGan, String monthZhi, bool isMale) {
  // 阳年/阴年判定（年干阴阳）
  final yangGan = ['甲', '丙', '戊', '庚', '壬'];
  final isYangYear = yangGan.contains(yearGan);

  // 顺排：阳男阴女，逆排：阴男阳女
  final shunNi = isYangYear ^ !isMale;

  // 简化大运
  final result = <DaYun>[];
  final baseGanIdx = _tianGanCN.indexOf(monthGan);
  final baseZhiIdx = _diZhiCN.indexOf(monthZhi);

  for (var i = 0; i < 8; i++) {
    final ganIdx = shunNi ? (baseGanIdx + i) % 10 : (baseGanIdx - i + 10) % 10;
    final zhiIdx = shunNi ? (baseZhiIdx + i) % 12 : (baseZhiIdx - i + 12) % 12;
    final gan = _tianGanCN[ganIdx];
    final zhi = _diZhiCN[zhiIdx];
    final startAge = (i + 1) * 10;
    result.add(DaYun(
      startAge: startAge,
      ganZhi: '$gan$zhi',
      tianGan: gan,
      diZhi: zhi,
    ));
  }
  return result;
}

/// 计算五行旺衰（根据月令）
/// - 当令者旺，我生者相，生我者休，克我者囚，我克者死
Map<String, String> _calcWuXingWangShuai(String monthZhi) {
  final seasonWx = _monthZhiWuXing[monthZhi] ?? '土';
  final seasonIdx = _wuXingOrder.indexOf(seasonWx);
  if (seasonIdx < 0) return {};

  const statusLabels = ['旺', '相', '休', '囚', '死'];
  final result = <String, String>{};

  for (var i = 0; i < 5; i++) {
    final wx = _wuXingOrder[i];
    if (i == seasonIdx) {
      // 当令者旺
      result[wx] = statusLabels[0];
    } else if ((i - seasonIdx + 5) % 5 == 1) {
      // 我生者相
      result[wx] = statusLabels[1];
    } else if ((i - seasonIdx + 5) % 5 == 4) {
      // 生我者休
      result[wx] = statusLabels[2];
    } else if ((i - seasonIdx + 5) % 5 == 3) {
      // 克我者囚
      result[wx] = statusLabels[3];
    } else {
      // 我克者死
      result[wx] = statusLabels[4];
    }
  }
  return result;
}

/// 计算十神（以日干为基准）
/// - 同我：比肩（同阴阳）、劫财（异阴阳）
/// - 我生：食神（同阴阳）、伤官（异阴阳）
/// - 生我：偏印（同阴阳）、正印（异阴阳）
/// - 我克：偏财（同阴阳）、正财（异阴阳）
/// - 克我：七杀（同阴阳）、正官（异阴阳）
String _calcShiShen(String dayGan, String targetGan) {
  final dIdx = _tianGanCN.indexOf(dayGan);
  final tIdx = _tianGanCN.indexOf(targetGan);
  if (dIdx < 0 || tIdx < 0) return '未知';

  final dWx = _tianGanWuXing[dayGan] ?? '';
  final tWx = _tianGanWuXing[targetGan] ?? '';
  final dYang = _tianGanYinYang[dayGan] ?? true;
  final tYang = _tianGanYinYang[targetGan] ?? true;

  final dWxIdx = _wuXingOrder.indexOf(dWx);
  final tWxIdx = _wuXingOrder.indexOf(tWx);
  if (dWxIdx < 0 || tWxIdx < 0) return '未知';

  final sameYy = dYang == tYang;

  if (dWx == tWx) {
    // 同我
    return sameYy ? '比肩' : '劫财';
  }

  final diff = (tWxIdx - dWxIdx + 5) % 5;

  if (diff == 1) {
    // 我生之五行（日干生目标）
    return sameYy ? '食神' : '伤官';
  }
  if (diff == 4) {
    // 生我之五行（目标生日干）
    return sameYy ? '偏印' : '正印';
  }
  if (diff == 2) {
    // 我克之五行（日干克目标）
    return sameYy ? '偏财' : '正财';
  }
  // diff == 3: 克我之五行（目标克日干）
  return sameYy ? '七杀' : '正官';
}

/// 统计八字中五行数量
Map<String, int> _countWuXing(String yearGan, String yearZhi, String monthGan,
    String monthZhi, String dayGan, String dayZhi, String hourGan, String hourZhi) {
  final result = <String, int>{'木': 0, '火': 0, '土': 0, '金': 0, '水': 0};

  void addGan(String gan) {
    final wx = _tianGanWuXing[gan];
    if (wx != null) result[wx] = (result[wx] ?? 0) + 1;
  }

  void addZhi(String zhi) {
    // 地支中藏干取本气五行
    final cang = _cangGanMap[zhi] ?? {};
    final benQi = cang['本气'] ?? '';
    if (benQi.isNotEmpty && benQi != '无') {
      final wx = _tianGanWuXing[benQi];
      if (wx != null) result[wx] = (result[wx] ?? 0) + 1;
    }
  }

  addGan(yearGan);
  addZhi(yearZhi);
  addGan(monthGan);
  addZhi(monthZhi);
  addGan(dayGan);
  addZhi(dayZhi);
  addGan(hourGan);
  addZhi(hourZhi);

  return result;
}

/// 八字排盘引擎
class BaiZiEngine {
  /// 排盘计算
  /// - [birth] 公历出生日期
  /// - [isMale] true=男 false=女
  /// - [hourIndex] 时辰索引 0=子时 … 11=亥时
  static BaziResult calc({
    required DateTime birth,
    required bool isMale,
    required int hourIndex,
  }) {
    // 使用 tyme 获取公历日及六十甲子
    final solar = tyme.SolarDay.fromYmd(birth.year, birth.month, birth.day);
    final scd = solar.getSixtyCycleDay();

    // 四柱干支（通过 SixtyCycleDay 获取）
    final yearGZ = scd.getYear().getName();
    final monthGZ = scd.getMonth().getName();
    final dayGZ = scd.getSixtyCycle().getName();
    // 时柱：根据日干和时辰索引推算（五鼠遁）
    final hourGZ = _calcHourGanZhi(dayGZ, hourIndex);

    // 解析天干地支（干支字符串首字为天干，次字为地支）
    final yearGan = yearGZ[0];
    final yearZhi = yearGZ[1];
    final monthGan = monthGZ[0];
    final monthZhi = monthGZ[1];
    final dayGan = dayGZ[0];
    final dayZhi = dayGZ[1];
    final hourGan = hourGZ[0];
    final hourZhi = hourGZ[1];

    // 藏干
    final cangGanYear = Map<String, String>.from(_cangGanMap[yearZhi] ?? {});
    final cangGanMonth = Map<String, String>.from(_cangGanMap[monthZhi] ?? {});
    final cangGanDay = Map<String, String>.from(_cangGanMap[dayZhi] ?? {});
    final cangGanHour = Map<String, String>.from(_cangGanMap[hourZhi] ?? {});

    // 日干五行
    final dayWuXing = _tianGanWuXing[dayGan] ?? '';

    // 四柱
    final yearZhu = SiZhu(
      ganZhi: yearGZ,
      tianGan: yearGan,
      diZhi: yearZhi,
      tianGanCN: yearGan,
      diZhiCN: yearZhi,
      wuXing: _tianGanWuXing[yearGan] ?? '',
      cangGan: cangGanYear,
    );
    final monthZhu = SiZhu(
      ganZhi: monthGZ,
      tianGan: monthGan,
      diZhi: monthZhi,
      tianGanCN: monthGan,
      diZhiCN: monthZhi,
      wuXing: _tianGanWuXing[monthGan] ?? '',
      cangGan: cangGanMonth,
    );
    final dayZhu = SiZhu(
      ganZhi: dayGZ,
      tianGan: dayGan,
      diZhi: dayZhi,
      tianGanCN: dayGan,
      diZhiCN: dayZhi,
      wuXing: dayWuXing,
      cangGan: cangGanDay,
    );
    final hourZhu = SiZhu(
      ganZhi: hourGZ,
      tianGan: hourGan,
      diZhi: hourZhi,
      tianGanCN: hourGan,
      diZhiCN: hourZhi,
      wuXing: _tianGanWuXing[hourGan] ?? '',
      cangGan: cangGanHour,
    );

    // 大运
    final daYun = _calcDaYun(yearGan, monthGan, monthZhi, isMale);

    // 流年（当年）
    final now = DateTime.now();
    final nowSolar = tyme.SolarDay.fromYmd(now.year, now.month, now.day);
    final nowScd = nowSolar.getSixtyCycleDay();
    final liuNian = nowScd.getYear().getName();

    // 五行旺衰（根据月令）
    final wuXingWangShuai = _calcWuXingWangShuai(monthZhi);

    // 五行数量
    final wuXingCounts = _countWuXing(
      yearGan, yearZhi, monthGan, monthZhi,
      dayGan, dayZhi, hourGan, hourZhi,
    );

    // 十神（以日干为基准计算各天干）
    final shiShenMap = <String, String>{
      yearGan: _calcShiShen(dayGan, yearGan),
      monthGan: _calcShiShen(dayGan, monthGan),
      '日主': '日元',
      hourGan: _calcShiShen(dayGan, hourGan),
    };
    // 藏干十神
    for (final entry in cangGanYear.entries) {
      if (entry.value != '无') {
        shiShenMap['${entry.key}:${entry.value}'] = _calcShiShen(dayGan, entry.value);
      }
    }
    for (final entry in cangGanMonth.entries) {
      if (entry.value != '无') {
        shiShenMap['${entry.key}:${entry.value}'] = _calcShiShen(dayGan, entry.value);
      }
    }
    for (final entry in cangGanDay.entries) {
      if (entry.value != '无') {
        shiShenMap['${entry.key}:${entry.value}'] = _calcShiShen(dayGan, entry.value);
      }
    }
    for (final entry in cangGanHour.entries) {
      if (entry.value != '无') {
        shiShenMap['${entry.key}:${entry.value}'] = _calcShiShen(dayGan, entry.value);
      }
    }

    return BaziResult(
      birth: birth,
      isMale: isMale,
      yearZhu: yearZhu,
      monthZhu: monthZhu,
      dayZhu: dayZhu,
      hourZhu: hourZhu,
      daYun: daYun,
      liuNian: liuNian,
      wuXingCounts: wuXingCounts,
      wuXingWangShuai: wuXingWangShuai,
      shiShenMap: shiShenMap,
    );
  }

  /// 日上起时法（五鼠遁）计算时辰干支
  /// [dayGanZhi] 日干支，如 "甲子"
  /// [hourIndex] 时辰索引 0=子时 … 11=亥时
  static String _calcHourGanZhi(String dayGanZhi, int hourIndex) {
    final dayGan = dayGanZhi[0];
    final dayGanIdx = _tianGanCN.indexOf(dayGan);
    if (dayGanIdx < 0) return dayGanZhi;

    // 五鼠遁口诀：甲己还加甲，乙庚丙作初，丙辛从戊起，丁壬庚子居，戊癸何方发，壬子是真途
    // 子时起的天干根据日干确定
    final startHourGan = (dayGanIdx % 5) * 2;
    final hourGanIdx = (startHourGan + hourIndex) % 10;
    final hourGan = _tianGanCN[hourGanIdx];
    final hourZhi = _diZhiCN[hourIndex];

    return '$hourGan$hourZhi';
  }
}
