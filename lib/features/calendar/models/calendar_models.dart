/// 万年历数据模型
library;

/// 农历日期（轻量版，用于网格展示）
class LunarDate {
  final int year;
  final int month;   // 1-12
  final int day;     // 1-29/30
  final bool isLeap;

  const LunarDate({
    required this.year,
    required this.month,
    required this.day,
    this.isLeap = false,
  });

  String get monthChinese {
    const months = ['正','二','三','四','五','六','七','八','九','十','冬','腊'];
    final idx = month - 1;
    if (idx < 0 || idx >= months.length) return '?月';
    return '${isLeap ? "闰" : ""}${months[idx]}月';
  }

  String get dayChinese {
    const days = [
      '初一','初二','初三','初四','初五','初六','初七','初八','初九','初十',
      '十一','十二','十三','十四','十五','十六','十七','十八','十九','二十',
      '廿一','廿二','廿三','廿四','廿五','廿六','廿七','廿八','廿九','三十',
    ];
    if (day < 1 || day > 30) return '?日';
    return days[day - 1];
  }

  @override
  String toString() => '$year年$monthChinese$dayChinese';
}

/// 网格日期信息
class CalendarDayInfo {
  final DateTime gregorianDate;
  final LunarDate lunarDate;
  final String yearGanZhi;
  final String monthGanZhi;
  final String dayGanZhi;
  final String zodiac;
  final String? solarTerm;
  final int dayOfYear;
  final int weekday; // 0=周一, 6=周日
  final bool isToday;

  const CalendarDayInfo({
    required this.gregorianDate,
    required this.lunarDate,
    required this.yearGanZhi,
    required this.monthGanZhi,
    required this.dayGanZhi,
    required this.zodiac,
    this.solarTerm,
    required this.dayOfYear,
    required this.weekday,
    required this.isToday,
  });

  String get weekdayName => '周${_weekdayNames[weekday]}';
  static const _weekdayNames = ['一','二','三','四','五','六','日'];
}
