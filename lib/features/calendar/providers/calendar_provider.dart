/// 万年历状态管理 — 基于 tyme4dart
library;

import 'package:flutter/material.dart';
import 'package:tyme/tyme.dart' as tyme;
import '../../../core/utils/logger.dart';
import '../models/calendar_models.dart';

class CalendarProvider extends ChangeNotifier {
  static const int kMinYear = 1901;
  static const int kMaxYear = 2100;

  late int _year;
  late int _month;
  List<CalendarDayInfo> _days = [];
  CalendarDayInfo? _selectedDay;
  bool _hasError = false;
  String _lastErrorMessage = '';

  int get year => _year;
  int get month => _month;
  List<CalendarDayInfo> get days => _days;
  CalendarDayInfo? get selectedDay => _selectedDay;
  bool get hasError => _hasError;
  String get lastErrorMessage => _lastErrorMessage;
  bool get atMinYear => _year <= kMinYear;
  bool get atMaxYear => _year >= kMaxYear;

  /// 获取第一天的星期偏移(0=周一, 6=周日)
  int get firstWeekday {
    if (_days.isEmpty) return 0;
    // weekday: 0=周一, 6=周日
    return _days.first.weekday;
  }

  CalendarProvider() {
    final now = DateTime.now();
    _year = now.year.clamp(kMinYear, kMaxYear);
    _month = now.month;
    _safeBuildMonth();
  }

  void _selectToday() {
    for (final d in _days) {
      if (d.isToday) {
        _selectedDay = d;
        return;
      }
    }
    if (_days.isNotEmpty) _selectedDay = _days.first;
  }

  /// 安全的月份构建（带异常保护）
  void _safeBuildMonth() {
    try {
      _buildMonth();
      _hasError = false;
      _lastErrorMessage = '';
    } catch (e, stack) {
      _hasError = true;
      _lastErrorMessage = e.toString();
      Logger.instance.error('万年历构建失败', '$_year年$_month月: $e\n$stack');
      _days = [];
      _selectedDay = null;
    }
    _selectToday();
  }

  void _buildMonth() {
    final monthObj = tyme.SolarMonth.fromYm(_year, _month);
    final dayCount = monthObj.getDayCount();
    final today = DateTime.now();

    _days = List.generate(dayCount, (i) {
      final d = i + 1;
      final solar = tyme.SolarDay.fromYmd(_year, _month, d);
      final lunar = solar.getLunarDay();
      final scd = solar.getSixtyCycleDay();

      // 公历
      final date = DateTime(_year, _month, d);

      // 农历
      final lYear = lunar.getYear();
      final lMonth = lunar.getMonth();
      final lDay = lunar.getDay();
      final lIsLeap = lunar.getLunarMonth().isLeap();

      // 干支
      final yearGanZhi = scd.getYear().getName();
      final monthGanZhi = scd.getMonth().getName();
      final dayGanZhi = scd.getSixtyCycle().getName();

      // 生肖
      final zodiac = scd.getYear().getEarthBranch().getZodiac().getName();

      // 星期: Tyme Week index 0=周日, 迁移到 0=周一, 6=周日
      final tymeWeek = solar.getWeek().getIndex();
      final wd = (tymeWeek + 6) % 7;

      // 节气
      String? termName;
      try {
        final termDay = solar.getTermDay();
        if (termDay.dayIndex == 0) {
          termName = termDay.getSolarTerm().getName();
        }
      } catch (_) {}

      // 年积日
      final doy = date.difference(DateTime(_year, 1, 1)).inDays + 1;

      // 是否今天
      final isT = date.year == today.year &&
          date.month == today.month &&
          date.day == today.day;

      return CalendarDayInfo(
        gregorianDate: date,
        lunarDate: LunarDate(year: lYear, month: lMonth, day: lDay, isLeap: lIsLeap),
        yearGanZhi: yearGanZhi,
        monthGanZhi: monthGanZhi,
        dayGanZhi: dayGanZhi,
        zodiac: zodiac,
        solarTerm: termName,
        dayOfYear: doy,
        weekday: wd,
        isToday: isT,
      );
    });
  }

  void _rebuild() {
    _safeBuildMonth();
    if (_selectedDay != null && _days.isNotEmpty) {
      // 尽量保持选中同一天
      final oldDay = _selectedDay!.gregorianDate.day;
      for (final d in _days) {
        if (d.gregorianDate.day == oldDay) {
          _selectedDay = d;
          notifyListeners();
          return;
        }
      }
      _selectedDay = _days.first;
    }
    notifyListeners();
  }

  void goToPrevMonth() {
    if (_month == 1) {
      if (_year <= kMinYear) {
        Logger.instance.warn('万年历', '已达最小年份 ${kMinYear}年');
        return;
      }
      _year--;
      _month = 12;
    } else {
      _month--;
    }
    Logger.instance.info('万年历导航', '上个月 → $_year年$_month月');
    _rebuild();
  }

  void goToNextMonth() {
    if (_month == 12) {
      if (_year >= kMaxYear) {
        Logger.instance.warn('万年历', '已达最大年份 ${kMaxYear}年');
        return;
      }
      _year++;
      _month = 1;
    } else {
      _month++;
    }
    Logger.instance.info('万年历导航', '下个月 → $_year年$_month月');
    _rebuild();
  }

  void goToToday() {
    final now = DateTime.now();
    _year = now.year.clamp(kMinYear, kMaxYear);
    _month = now.month;
    Logger.instance.info('万年历', '回到今天 → $_year年$_month月');
    _safeBuildMonth();
    notifyListeners();
  }

  void selectDay(CalendarDayInfo day) {
    _selectedDay = day;
    notifyListeners();
  }

  void goToYearMonth(int year, int month) {
    _year = year;
    _month = month;
    _rebuild();
  }
}
