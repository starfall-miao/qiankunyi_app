/// 万年历核心算法
///   - 公历↔农历转换
///   - 干支推算
///   - 二十四节气计算
library;

import '../models/calendar_models.dart';
import '../data/lunar_data.dart';

class CalendarEngine {
  /// 基准：1900年正月初一对应的公历日期
  static const int baseYear = 1900;
  static const int baseLunarYear = 1900;

  /// 公历日期 → 农历日期
  static LunarDate? gregorianToLunar(DateTime date) {
    final gy = date.year;
    final gm = date.month;
    final gd = date.day;

    // 计算从基准日期(1900-01-31)到目标日期的偏移天数
    final baseDate = DateTime(baseYear, 1, 31);
    final targetDate = DateTime(gy, gm, gd);
    int offset = targetDate.difference(baseDate).inDays;

    if (offset < 0) return null; // 不支持1900年之前的日期

    // 遍历农历年，找到目标日期所在的农历年
    int lYear = baseLunarYear;
    int lYearDays;

    while (lYear < 2100) {
      lYearDays = getLunarYearDays(lYear);
      if (offset < lYearDays) break;
      offset -= lYearDays;
      lYear++;
    }

    if (lYear > 2100) return null;

    // 在当前农历年中，逐月查找
    final leapMonth = getLeapMonth(lYear);
    bool isLeap = false;
    int lMonth = 1;

    for (int m = 1; m <= 12; m++) {
      final monthDays = getLunarMonthDays(lYear, m);
      if (offset < monthDays) {
        lMonth = m;
        break;
      }
      offset -= monthDays;

      // 如果有闰月且当前月是闰月
      if (leapMonth > 0 && m == leapMonth) {
        final lDays = getLeapMonthDays(lYear);
        if (offset < lDays) {
          lMonth = m;
          isLeap = true;
          break;
        }
        offset -= lDays;
      }
    }

    final lDay = offset + 1;

    return LunarDate(
      year: lYear,
      month: lMonth,
      day: lDay,
      isLeap: isLeap,
    );
  }

  /// 农历 → 公历日期
  static DateTime? lunarToGregorian(int lYear, int lMonth, int lDay,
      {bool isLeap = false}) {
    if (lYear < baseLunarYear || lYear > 2100) return null;

    // 计算农历正月初一对应的公历日期偏移
    final baseDate = DateTime(baseYear, 1, 31);
    int offset = 0;

    // 累加之前农历年的天数
    for (int y = baseLunarYear; y < lYear; y++) {
      offset += getLunarYearDays(y);
    }

    // 累加当年农历月的天数
    final leapMonth = getLeapMonth(lYear);
    for (int m = 1; m < lMonth; m++) {
      offset += getLunarMonthDays(lYear, m);
      if (leapMonth > 0 && m == leapMonth) {
        offset += getLeapMonthDays(lYear);
      }
    }

    offset += lDay - 1;

    return baseDate.add(Duration(days: offset));
  }

  /// 计算年干支（从立春开始换年）
  static StemBranch getYearStemBranch(int year, {int month = 1, int day = 1}) {
    int y = year;
    if (month < 2 || (month == 2 && day < 4)) {
      y = year - 1;
    }
    final stem = (y - 4) % 10;
    final branch = (y - 4) % 12;
    return StemBranch(
      stem < 0 ? stem + 10 : stem,
      branch < 0 ? branch + 12 : branch,
    );
  }

  /// 计算月干支
  static StemBranch getMonthStemBranch(int year, int month) {
    final yearSB = getYearStemBranch(year, month: month, day: 15);
    final yearStem = yearSB.heavenlyStem;

    final monthIndex = ((month + 9) % 12);
    final stemOffset = (yearStem % 5) * 2;
    final stem = (stemOffset + monthIndex) % 10;
    final branch = (month + 1) % 12;

    return StemBranch(stem, branch);
  }

  /// 计算日干支（基准：2000-01-01 = 甲子日(0,0)）
  static StemBranch getDayStemBranch(DateTime date) {
    final base = DateTime(2000, 1, 1);
    final diff = date.difference(base).inDays;
    final stem = ((diff % 10) + 10) % 10;
    final branch = ((diff % 12) + 12) % 12;
    return StemBranch(stem, branch);
  }

  /// 获取二十四节气（简化近似算法）
  static List<SolarTerm> getSolarTerms(int year) {
    final terms = <SolarTerm>[];

    for (int i = 0; i < 24; i++) {
      final m = i ~/ 2;
      final isFirst = i % 2 == 0;

      double baseDay;
      if (isFirst) {
        baseDay = _solarTermBase1[m];
      } else {
        baseDay = _solarTermBase2[m];
      }

      final yearOffset = (year - 1900) * 0.2422;
      final leapOffset = ((year - 1900) / 4).floor() -
          ((year - 1900) / 100).floor() +
          ((year - 1900) / 400).floor();

      int day = (baseDay + yearOffset - leapOffset + 0.5).floor();
      if (day > 31) day = 31;
      if (day < 1) day = 1;

      try {
        final date = DateTime(year, m + 1, day);
        terms.add(SolarTerm(name: SolarTerm.names[i], date: date));
      } catch (_) {}
    }

    return terms;
  }

  static const _solarTermBase1 = [
    5.59, 3.87, 5.63, 4.81, 5.52, 5.43,
    6.98, 7.50, 7.38, 8.14, 7.37, 6.59,
  ];
  static const _solarTermBase2 = [
    20.15, 18.73, 20.46, 20.32, 21.11, 21.43,
    22.90, 23.18, 23.09, 23.44, 22.58, 21.76,
  ];

  /// 查找某天的节气名
  static String? findSolarTerm(DateTime date, List<SolarTerm> terms) {
    for (final t in terms) {
      if (t.date.year == date.year &&
          t.date.month == date.month &&
          t.date.day == date.day) {
        return t.name;
      }
    }
    return null;
  }

  /// 构建某月的完整日历数据
  static MonthData buildMonthData(int year, int month, {DateTime? today}) {
    today ??= DateTime.now();
    final firstDay = DateTime(year, month, 1);
    final lastDay = DateTime(year, month + 1, 0);
    final totalDays = lastDay.day;
    final firstWeekday = (firstDay.weekday + 6) % 7;

    final firstDayOfYear = DateTime(year, 1, 1);
    final days = <CalendarDayInfo>[];
    final solarTerms = getSolarTerms(year);

    for (int d = 1; d <= totalDays; d++) {
      final date = DateTime(year, month, d);
      final lunar = gregorianToLunar(date);
      final yearSB = getYearStemBranch(year, month: month, day: d);
      final monthSB = getMonthStemBranch(year, month);
      final daySB = getDayStemBranch(date);
      final dayOfYear = date.difference(firstDayOfYear).inDays + 1;
      final wd = (date.weekday + 6) % 7;
      final isT = date.year == today.year &&
          date.month == today.month &&
          date.day == today.day;

      days.add(CalendarDayInfo(
        gregorianDate: date,
        lunarDate: lunar ??
            LunarDate(year: year, month: month, day: d, isLeap: false),
        yearSB: yearSB,
        monthSB: monthSB,
        daySB: daySB,
        solarTerm: findSolarTerm(date, solarTerms),
        dayOfYear: dayOfYear,
        weekday: wd,
        isToday: isT,
        isCurrentMonth: true,
      ));
    }

    return MonthData(
      year: year,
      month: month,
      days: days,
      firstWeekday: firstWeekday,
      totalDays: totalDays,
    );
  }
}
