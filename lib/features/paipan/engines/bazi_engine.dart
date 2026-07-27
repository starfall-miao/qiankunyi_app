/// 八字排盘引擎 — 基于 tyme4dart
library;

import 'package:tyme/tyme.dart';

import '../models/bazi_models.dart';

/// 天干地支中文映射
const _tianGanCN = ['甲','乙','丙','丁','戊','己','庚','辛','壬','癸'];
const _diZhiCN = ['子','丑','寅','卯','辰','巳','午','未','申','酉','戌','亥'];
const _diZhiWuXing = {
  '子':'水','丑':'土','寅':'木','卯':'木','辰':'土','巳':'火',
  '午':'火','未':'土','申':'金','酉':'金','戌':'土','亥':'水',
};
const _tianGanWuXing = {
  '甲':'木','乙':'木','丙':'火','丁':'火','戊':'土','己':'土',
  '庚':'金','辛':'金','壬':'水','癸':'水',
};

/// 日干对应十神映射
const _shiShenMap = {
  // 日干为木
  '甲': {'甲':'比肩','乙':'劫财','丙':'食神','丁':'伤官','戊':'偏财','己':'正财','庚':'七杀','辛':'正官','壬':'偏印','癸':'正印'},
  '乙': {'甲':'劫财','乙':'比肩','丙':'食神','丁':'伤官','戊':'正财','己':'偏财','庚':'正官','辛':'七杀','壬':'正印','癸':'偏印'},
  // 日干为火
  '丙': {'甲':'偏印','乙':'正印','丙':'比肩','丁':'劫财','戊':'食神','己':'伤官','庚':'偏财','辛':'正财','壬':'七杀','癸':'正官'},
  '丁': {'甲':'正印','乙':'偏印','丙':'比肩','丁':'劫财','戊':'伤官','己':'食神','庚':'正财','辛':'偏财','壬':'正官','癸':'七杀'},
  // 日干为土
  '戊': {'甲':'七杀','乙':'正官','丙':'偏印','丁':'正印','戊':'比肩','己':'劫财','庚':'食神','辛':'伤官','壬':'偏财','癸':'正财'},
  '己': {'甲':'正官','乙':'七杀','丙':'正印','丁':'偏印','戊':'比肩','己':'劫财','庚':'伤官','辛':'食神','壬':'正财','癸':'偏财'},
  // 日干为金
  '庚': {'甲':'偏财','乙':'正财','丙':'七杀','丁':'正官','戊':'偏印','己':'正印','庚':'比肩','辛':'劫财','壬':'食神','癸':'伤官'},
  '辛': {'甲':'正财','乙':'偏财','丙':'正官','丁':'七杀','戊':'正印','己':'偏印','庚':'比肩','辛':'劫财','壬':'伤官','癸':'食神'},
  // 日干为水
  '壬': {'甲':'食神','乙':'伤官','丙':'偏财','丁':'正财','戊':'七杀','己':'正官','庚':'偏印','辛':'正印','壬':'比肩','癸':'劫财'},
  '癸': {'甲':'伤官','乙':'食神','丙':'正财','丁':'偏财','戊':'正官','己':'七杀','庚':'正印','辛':'偏印','壬':'比肩','癸':'劫财'},
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
List<DaYun> _calcDaYun(String dayGan, String monthZhi, bool isMale) {
  // 阳年/阴年判定（年干阴阳）
  final yangGan = ['甲','丙','戊','庚','壬'];
  final isYangYear = yangGan.contains(dayGan[0]); // 以日干代表年柱天干简化
  final monthZhiIdx = _diZhiCN.indexOf(monthZhi);

  // 顺排：阳男阴女，逆排：阴男阳女
  final shunNi = isYangYear ^ isMale; // true=顺排

  // 简化大运：以月柱推算（实际以节气，这里简化）
  final result = <DaYun>[];
  final baseGanIdx = _tianGanCN.indexOf(dayGan[0]);

  for (var i = 0; i < 8; i++) {
    final idx = shunNi ? (baseGanIdx + i) % 10 : (baseGanIdx - i + 10) % 10;
    final zhiOffset = shunNi ? (monthZhiIdx + i) % 12 : (monthZhiIdx - i + 12) % 12;
    final gan = _tianGanCN[idx];
    final zhi = _diZhiCN[zhiOffset];
    final startAge = shunNi ? (i * 10) : (i * 10);
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
    final solar = Solar.fromDate(birth);
    final lunar = solar.toLunar();

    // 四柱干支
    final yearGZ = lunar.getYearInGanZhi();
    final monthGZ = lunar.getMonthInGanZhi();
    final dayGZ = lunar.getDayInGanZhi();
    // 时辰
    final lunarDay = lunar;
    final hours = lunarDay.getHours();
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
    final daYun = _calcDaYun(dayGan, monthGZ, isMale);

    // 流年（当年）
    final now = DateTime.now();
    final nowLunar = Solar.fromDate(now).toLunar();
    final liuNian = nowLunar.getYearInGanZhi();

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
    // 用户选择的时辰索引（0=子时，1=丑时...）
    final selectedHour = hours.firstWhere(
      (h) => (h as dynamic).getIndex() == hourIndex,
      orElse: () => hours[0],
    );
    final sc = (selectedHour as dynamic).getSixtyCycle() as String;
    return sc;
  }
}
