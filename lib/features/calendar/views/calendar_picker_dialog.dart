/// 乾坤易内置万年历风格日期选择器
/// 复用 [CalendarProvider] 显示日历网格，点击日期返回 [DateTime]。
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/calendar_models.dart';
import '../providers/calendar_provider.dart';

class CalendarPickerDialog extends StatefulWidget {
  const CalendarPickerDialog({super.key});

  @override
  State<CalendarPickerDialog> createState() => _CalendarPickerDialogState();
}

class _CalendarPickerDialogState extends State<CalendarPickerDialog> {
  late CalendarProvider _cal;

  @override
  void initState() {
    super.initState();
    _cal = CalendarProvider();
  }

  @override
  void dispose() {
    _cal.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final p = Theme.of(context).colorScheme.primary;
    final t = isDark ? const Color(0xFFE0D5C8) : const Color(0xFF4A3728);
    final bg = isDark ? const Color(0xFF1A1A2E) : const Color(0xFFF5F0EB);

    return Dialog(
      backgroundColor: bg,
      surfaceTintColor: bg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: StatefulBuilder(
        builder: (ctx, setDialogState) {
          final yearGanZhi =
              _cal.days.isNotEmpty ? _cal.days.first.yearGanZhi : '';
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── 顶部：干支年号 ──
              _buildHeader(yearGanZhi, p, t, isDark),
              // ── 月份导航 ──
              _buildNav(setDialogState, p, t),
              // ── 星期表头 ──
              _buildWeekdayHeader(p, t),
              // ── 日期网格 ──
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 4),
                child: _buildGrid(setDialogState, ctx, p, t),
              ),
              // ── 底部按钮 ──
              _buildActions(ctx, p, t),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(String yearGanZhi, Color p, Color t, bool dark) {
    final gold = const Color(0xFFD4A574);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Row(
        children: [
          Text('${_cal.year}年 ${_cal.month}月',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: t)),
          const SizedBox(width: 12),
          if (yearGanZhi.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: gold.withAlpha(25),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: gold.withAlpha(80)),
              ),
              child: Text(yearGanZhi,
                  style: TextStyle(fontSize: 13, color: gold, fontWeight: FontWeight.w600)),
            ),
        ],
      ),
    );
  }

  Widget _buildNav(void Function(void Function()) upd, Color p, Color t) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () { _cal.goToPrevMonth(); upd(() {}); },
            color: t,
          ),
          Text('${_cal.year}年${_cal.month}月',
              style: TextStyle(fontSize: 16, color: t.withAlpha(180))),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () { _cal.goToNextMonth(); upd(() {}); },
            color: t,
          ),
        ],
      ),
    );
  }

  Widget _buildWeekdayHeader(Color p, Color t) {
    const labels = ['一', '二', '三', '四', '五', '六', '日'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: labels.map((l) => Expanded(
          child: Center(
            child: Text(l,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                    color: l == '六' || l == '日' ? Colors.red.withAlpha(180) : t.withAlpha(150))),
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildGrid(void Function(void Function()) upd, BuildContext ctx, Color p, Color t) {
    // 填充空白以对齐星期
    final first = _cal.days.isNotEmpty ? _cal.days.first.weekday : 0;
    final List<Widget> cells = [];
    for (int i = 0; i < first; i++) {
      cells.add(const Expanded(child: SizedBox()));
    }
    for (final day in _cal.days) {
      cells.add(_DayCell(
        day: day,
        primary: p,
        textColor: t,
        onTap: () => Navigator.pop(ctx, day.gregorianDate),
      ));
    }
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 7,
      childAspectRatio: 0.95,
      children: cells,
    );
  }

  Widget _buildActions(BuildContext ctx, Color p, Color t) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: () { _cal.goToToday(); setState(() {}); },
            child: Text('今天', style: TextStyle(color: p)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('取消', style: TextStyle(color: t.withAlpha(180))),
          ),
        ],
      ),
    );
  }
}

/// 日期格
class _DayCell extends StatelessWidget {
  final CalendarDayInfo day;
  final Color primary, textColor;
  final VoidCallback onTap;

  const _DayCell({
    required this.day,
    required this.primary,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isWeekend = day.weekday >= 5;
    final isToday = day.isToday;
    final Color dateColor = isToday ? Colors.white
        : isWeekend ? Colors.red.withAlpha(200)
        : textColor;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(1.5),
        decoration: BoxDecoration(
          color: isToday ? primary.withAlpha(200) : null,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('${day.gregorianDate.day}',
                style: TextStyle(fontSize: 14, fontWeight: isToday ? FontWeight.bold : FontWeight.w500, color: dateColor)),
            Text(day.lunarDate.dayChinese,
                style: TextStyle(fontSize: 8, color: isToday ? Colors.white.withAlpha(200) : textColor.withAlpha(120))),
            Text(day.dayGanZhi,
                style: TextStyle(fontSize: 7, color: isToday ? Colors.white.withAlpha(180) : textColor.withAlpha(80))),
            if (day.solarTerm != null)
              Text(day.solarTerm!,
                  style: TextStyle(fontSize: 6, color: isToday ? Colors.white.withAlpha(200) : Colors.orange.withAlpha(180),
                      fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
