<<<<<<< HEAD
/// 万年历状态管理
library;

import 'package:flutter/material.dart';
import '../models/calendar_models.dart';
import '../engines/calendar_engine.dart';

class CalendarProvider extends ChangeNotifier {
  DateTime _currentDate = DateTime.now();
  MonthData? _monthData;
  CalendarDayInfo? _selectedDay;
  bool _isLoading = false;

  DateTime get currentDate => _currentDate;
  MonthData? get monthData => _monthData;
  CalendarDayInfo? get selectedDay => _selectedDay;
  bool get isLoading => _isLoading;

  int get year => _currentDate.year;
  int get month => _currentDate.month;

  CalendarProvider() {
    _initToday();
  }

  void _initToday() {
    final now = DateTime.now();
    _monthData = CalendarEngine.buildMonthData(now.year, now.month);
    _currentDate = DateTime(now.year, now.month, 1);
    _selectedDay = _monthData!.days.firstWhere(
      (d) => d.isToday,
      orElse: () => _monthData!.days.first,
    );
    notifyListeners();
  }

  void loadMonth(int year, int month) {
    _isLoading = true;
    notifyListeners();

    try {
      _monthData = CalendarEngine.buildMonthData(year, month);
      _currentDate = DateTime(year, month, 1);
      // 切换月份后选中当前月第一天
      _selectedDay = _monthData!.days.first;
    } catch (e) {
      debugPrint('万年历加载失败: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void goToPrevMonth() {
    final m = _currentDate.month - 1;
    if (m < 1) {
      loadMonth(_currentDate.year - 1, 12);
    } else {
      loadMonth(_currentDate.year, m);
    }
  }

  void goToNextMonth() {
    final m = _currentDate.month + 1;
    if (m > 12) {
      loadMonth(_currentDate.year + 1, 1);
    } else {
      loadMonth(_currentDate.year, m);
    }
=======
/// 万年历状态管理 — 基于 tyme4dart
library;

import 'package:flutter/material.dart';
import 'package:tyme/tyme.dart' as tyme;
import '../models/calendar_models.dart';

class CalendarProvider extends ChangeNotifier {
  int _year;
  int _month;
  List<CalendarDayInfo> _days = [];
  CalendarDayInfo? _selectedDay;

  int get year => _year;
  int get month => _month;
  List<CalendarDayInfo> get days => _days;
  CalendarDayInfo? get selectedDay => _selectedDay;

  /// 获取第一天的星期偏移(0=周一, 6=周日)
  int get firstWeekday {
    if (_days.isEmpty) return 0;
    // weekday: 0=周一, 6=周日
    return _days.first.weekday;
  }

  CalendarProvider() {
    final now = DateTime.now();
    _year = now.year;
    _month = now.month;
    _buildMonth();
    _selectToday();
  }

  void _selectToday() {
    final now = DateTime.now();
    for (final d in _days) {
      if (d.isToday) {
        _selectedDay = d;
        return;
      }
    }
    _selectedDay = _days.first;
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
        if (termDay.getDay() == 0) {
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
    _buildMonth();
    if (_selectedDay != null) {
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
      _year--;
      _month = 12;
    } else {
      _month--;
    }
    _rebuild();
  }

  void goToNextMonth() {
    if (_month == 12) {
      _year++;
      _month = 1;
    } else {
      _month++;
    }
    _rebuild();
>>>>>>> 3ef53e2 (feat(calendar): integrate tyme4dart with rich huangli info and responsive layout)
  }

  void goToToday() {
    final now = DateTime.now();
<<<<<<< HEAD
    _monthData = CalendarEngine.buildMonthData(now.year, now.month);
    _currentDate = DateTime(now.year, now.month, 1);
    _selectedDay = _monthData!.days.firstWhere(
      (d) => d.isToday,
      orElse: () => _monthData!.days.first,
    );
    _isLoading = false;
=======
    _year = now.year;
    _month = now.month;
    _buildMonth();
    _selectToday();
>>>>>>> 3ef53e2 (feat(calendar): integrate tyme4dart with rich huangli info and responsive layout)
    notifyListeners();
  }

  void selectDay(CalendarDayInfo day) {
    _selectedDay = day;
    notifyListeners();
  }

  void goToYearMonth(int year, int month) {
<<<<<<< HEAD
    loadMonth(year, month);
=======
    _year = year;
    _month = month;
    _rebuild();
>>>>>>> 3ef53e2 (feat(calendar): integrate tyme4dart with rich huangli info and responsive layout)
  }
}
