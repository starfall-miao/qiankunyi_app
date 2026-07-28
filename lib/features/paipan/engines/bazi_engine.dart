/// 八字排盘引擎 — 基于 tyme4dart
library;

import 'package:tyme/tyme.dart' as tyme;

import '../models/bazi_models.dart';

/// 天干地支中文映射
const _tianGanCN = ['甲','乙','丙','丁','戊','己','庚','辛','壬','癸'];
const _diZhiCN = ['子','丑','寅','卯','辰','巳','午','未','申','酉','戌','亥'];
const _tianGanWuXing = {
  '甲':'木','乙':'木','丙':'火','丁':'火','戊':'土','己':'土',
  '庚':'金','辛':'金','壬':'水','癸':'水',
};


/// 藏干对应表（每宫地支藏天干）
const _cangGanMap = {
  '子': {'本气':'癸','中气':'无','余气':'无'},
  '丑': {'本气':'己','中气':'癸','余气':'辛'},
  '寅': {'本气':'甲','中气':'丙','余气':'戊'},
  '卯': {'本气':'乙','中气':'无','余气':'无'},
  '辰': {'本气':'戊','中气':'乙','余气':'癸'},
  '巳': {'本气':'丙','中气':'庚','余气':'戊'},
  '午': {'本气':'丁','中气':'己','余气':'无'},
  '未': {'本气':'己','中气':'丁','余气':'乙'},
  '申': {'本气':'庚','中气':'壬','余气':'戊'},
  '酉': {'本气':'辛','中气':'无','余气':'无'},
  '戌': {'本气':'戊','中气':'辛','余气':'丁'},
  '亥': {'本气':'壬','中气':'甲','余气':'无'},
};

/// 计算大运（顺排/逆排）
List<DaYun> _calcDaYun(String yearGan, String monthGan, String monthZhi, bool isMale) {
  // 阳年/阴年判定（年干阴阳）
  final yangGan = ['甲','丙','戊','庚','壬'];
  final isYangYear = yangGan.contains(yearGan);

  // 顺排：阳男阴女，逆排：阴男阳女
  final shunNi = isYangYear ^ !isMale; // 阳男阴女顺排

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

/// 起卦
class BaiZiEngine {
  static BaziResult calc({
    required DateTime birth,
    required bool isMale,
    required int hourIndex,
  }) {
    // 使用 tyme 获取干支
    final solar = tyme.SolarDay.fromYmd(birth.year, birth.month, birth.day);
    final lunar = solar.getLunarDay();
    final scd = solar.getSixtyCycleDay();

    // 四柱干支（通过 SixtyCycleDay 获取）
    final yearGZ = scd.getYear().getName();
    final monthGZ = scd.getMonth().getName();
    final dayGZ = scd.getSixtyCycle().getName();
    // 时辰
    final hours = lunar.getHours();
    final hourGZ = _getHourGanZhi(dayGZ, hours, hourIndex);

    // 解析天干地支
    final yearGan = yearGZ[0], yearZhi = yearGZ[1];
    final monthGan = monthGZ[0], monthZhi = monthGZ[1];
    final dayGan = dayGZ[0], dayZhi = dayGZ[1];
    final hourGan = hourGZ[0], hourZhi = hourGZ[1];

    // 藏干
    final cangGanYear = Map<String, String>.from(_cangGanMap[yearZhi] ?? {});
    final cangGanMonth = Map<String, String>.from(_cangGanMap[monthZhi] ?? {});
    final cangGanDay = Map<String, String>.from(_cangGanMap[dayZhi] ?? {});
    final cangGanHour = Map<String, String>.from(_cangGanMap[hourZhi] ?? {});

    // 日干五行
    final dayWuXing = _tianGanWuXing[dayGan] ?? '';

    // 四柱
    final yearZhu = SiZhu(
      ganZhi: yearGZ, tianGan: yearGan, diZhi: yearZhi,
      tianGanCN: yearGan, diZhiCN: yearZhi,
      wuXing: _tianGanWuXing[yearGan] ?? '',
      cangGan: cangGanYear,
    );
    final monthZhu = SiZhu(
      ganZhi: monthGZ, tianGan: monthGan, diZhi: monthZhi,
      tianGanCN: monthGan, diZhiCN: monthZhi,
      wuXing: _tianGanWuXing[monthGan] ?? '',
      cangGan: cangGanMonth,
    );
    final dayZhu = SiZhu(
      ganZhi: dayGZ, tianGan: dayGan, diZhi: dayZhi,
      tianGanCN: dayGan, diZhiCN: dayZhi,
      wuXing: dayWuXing,
      cangGan: cangGanDay,
    );
    final hourZhu = SiZhu(
      ganZhi: hourGZ, tianGan: hourGan, diZhi: hourZhi,
      tianGanCN: hourGan, diZhiCN: hourZhi,
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

    return BaziResult(
      birth: birth,
      isMale: isMale,
      yearZhu: yearZhu,
      monthZhu: monthZhu,
      dayZhu: dayZhu,
      hourZhu: hourZhu,
      daYun: daYun,
      liuNian: liuNian,
    );
  }

  /// 获取时辰干支
  static String _getHourGanZhi(String dayGanZhi, List hours, int hourIndex) {
    if (hours.isEmpty) return dayGanZhi;
    final idx = hourIndex.clamp(0, hours.length - 1);
    final selected = hours[idx];
    try {
      final sc = (selected as dynamic).getSixtyCycle();
      return sc is String ? sc : dayGanZhi;
    } catch (_) {
      return dayGanZhi;
    }
  }
}
