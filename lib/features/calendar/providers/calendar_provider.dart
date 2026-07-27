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
  }

  void goToToday() {
    final now = DateTime.now();
    _monthData = CalendarEngine.buildMonthData(now.year, now.month);
    _currentDate = DateTime(now.year, now.month, 1);
    _selectedDay = _monthData!.days.firstWhere(
      (d) => d.isToday,
      orElse: () => _monthData!.days.first,
    );
    _isLoading = false;
    notifyListeners();
  }

  void selectDay(CalendarDayInfo day) {
    _selectedDay = day;
    notifyListeners();
  }

  void goToYearMonth(int year, int month) {
    loadMonth(year, month);
  }
}
