/// 万年历数据模型
library;

/// 农历日期
class LunarDate {
  final int year;       // 农历年
  final int month;      // 农历月（1-12）
  final int day;        // 农历日（1-29/30）
  final bool isLeap;    // 是否闰月

  const LunarDate({
    required this.year,
    required this.month,
    required this.day,
    this.isLeap = false,
  });

  String get monthChinese {
    final idx = isLeap ? month - 1 : month - 1;
    if (idx < 0 || idx >= _lunarMonths.length) return '?月';
    return '${isLeap ? "闰" : ""}${_lunarMonths[idx]}月';
  }

  String get dayChinese {
    if (day < 1 || day > 30) return '?日';
    return _lunarDays[day - 1];
  }

  @override
  String toString() => '$year年$monthChinese$dayChinese';

  static const _lunarMonths = [
    '正', '二', '三', '四', '五', '六',
    '七', '八', '九', '十', '冬', '腊',
  ];

  static const _lunarDays = [
    '初一', '初二', '初三', '初四', '初五', '初六', '初七', '初八', '初九', '初十',
    '十一', '十二', '十三', '十四', '十五', '十六', '十七', '十八', '十九', '二十',
    '廿一', '廿二', '廿三', '廿四', '廿五', '廿六', '廿七', '廿八', '廿九', '三十',
  ];
}

/// 天干地支
class StemBranch {
  final int heavenlyStem;  // 0-9
  final int earthlyBranch; // 0-11

  const StemBranch(this.heavenlyStem, this.earthlyBranch);

  String get stemName => _heavenlyStems[heavenlyStem];
  String get branchName => _earthlyBranches[earthlyBranch];
  String get fullName => '$stemName$branchName';
  String get zodiac => _zodiac[earthlyBranch];

  static const _heavenlyStems = [
    '甲', '乙', '丙', '丁', '戊', '己', '庚', '辛', '壬', '癸',
  ];
  static const _earthlyBranches = [
    '子', '丑', '寅', '卯', '辰', '巳',
    '午', '未', '申', '酉', '戌', '亥',
  ];
  static const _zodiac = [
    '鼠', '牛', '虎', '兔', '龙', '蛇',
    '马', '羊', '猴', '鸡', '狗', '猪',
  ];
}

/// 单日完整信息
class CalendarDayInfo {
  final DateTime gregorianDate;
  final LunarDate lunarDate;
  final StemBranch yearSB;
  final StemBranch monthSB;
  final StemBranch daySB;
  final String? solarTerm;
  final int dayOfYear;
  final int weekday; // 0=周一, 6=周日
  final bool isToday;
  final bool isCurrentMonth;

  const CalendarDayInfo({
    required this.gregorianDate,
    required this.lunarDate,
    required this.yearSB,
    required this.monthSB,
    required this.daySB,
    this.solarTerm,
    required this.dayOfYear,
    required this.weekday,
    required this.isToday,
    required this.isCurrentMonth,
  });

  String get weekdayName => '周${_weekdayNames[weekday]}';
  static const _weekdayNames = ['一', '二', '三', '四', '五', '六', '日'];
}

/// 月视图数据
class MonthData {
  final int year;
  final int month; // 1-12
  final List<CalendarDayInfo> days;
  final int firstWeekday; // 当月第一天是周几 (0=周一, 6=周日)
  final int totalDays;

  const MonthData({
    required this.year,
    required this.month,
    required this.days,
    required this.firstWeekday,
    required this.totalDays,
  });
}
