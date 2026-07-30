/// 乾坤易内置万年历风格日期选择器对话框
/// 复用 [CalendarProvider] 的数据逻辑（基于 tyme4dart）显示日历网格。
/// 点击日期后 `Navigator.pop` 返回 [DateTime]。
library;

import 'package:flutter/material.dart';
import '../models/calendar_models.dart';
import '../providers/calendar_provider.dart';

/// 国风万年历日期选择器对话框
///
/// 使用方式：
/// ```dart
/// final d = await showDialog<DateTime>(
///   context: context,
///   builder: (_) => const CalendarPickerDialog(),
/// );
/// if (d != null) setState(() => _birth = d);
/// ```
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
    final gold = const Color(0xFFD4A843);

    return Dialog(
      backgroundColor: bg,
      surfaceTintColor: bg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: gold.withAlpha(60), width: 0.5),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: StatefulBuilder(
        builder: (context, setDialogState) {
          final yearGanZhi =
              _cal.days.isNotEmpty ? _cal.days.first.yearGanZhi : '';

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── 顶部：当年干支年号 ──
              _buildTopHeader(yearGanZhi, gold, t, isDark),
              // ── 月份导航（前后翻月） ──
              _buildMonthNav(setDialogState, p, t, isDark),
              // ── 星期表头 ──
              _buildWeekdayHeader(p, t, isDark),
              // ── 日期网格 ──
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 4),
                child: _buildMonthGrid(p, t, isDark),
              ),
              // ── 底部操作 ──
              _buildActions(setDialogState, p, t, gold),
            ],
          );
        },
      ),
    );
  }

  /// 顶部干支年号
  Widget _buildTopHeader(String yearGanZhi, Color gold, Color t, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 4),
      child: Row(
        children: [
          // 公历年月
          Text(
            '${_cal.year}年 ${_cal.month}月',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: t,
            ),
          ),
          const SizedBox(width: 12),
          // 干支年号标签
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: gold.withAlpha(25),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: gold.withAlpha(100)),
            ),
            child: Text(
              yearGanZhi,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: gold,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 月份导航条
  Widget _buildMonthNav(
    void Function(void Function()) setDialogState,
    Color p,
    Color t,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              _cal.goToPrevMonth();
              setDialogState(() {});
            },
            tooltip: '上月',
            color: t,
          ),
          GestureDetector(
            onTap: () => _showYearMonthPicker(setDialogState),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: p.withAlpha(50)),
              ),
              child: Text(
                '${_cal.year}年 ${_cal.month}月',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: t,
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              _cal.goToNextMonth();
              setDialogState(() {});
            },
            tooltip: '下月',
            color: t,
          ),
        ],
      ),
    );
  }

  /// 星期表头
  Widget _buildWeekdayHeader(Color p, Color t, bool isDark) {
    const weekdays = ['一', '二', '三', '四', '五', '六', '日'];
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: p.withAlpha(50)),
        ),
      ),
      child: Row(
        children: weekdays.asMap().entries.map((e) {
          final isWeekend = e.key >= 5;
          return Expanded(
            child: Center(
              child: Text(
                e.value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isWeekend
                      ? Colors.red.withAlpha(200)
                      : t.withAlpha(180),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// 月视图网格（复用 CalendarProvider 数据）
  Widget _buildMonthGrid(Color p, Color t, bool isDark) {
    final days = _cal.days;
    final firstW = _cal.firstWeekday;

    final cells = <Widget>[];
    for (int i = 0; i < firstW; i++) {
      cells.add(const SizedBox());
    }
    for (final day in days) {
      cells.add(_PickerDayCell(
        day: day,
        primary: p,
        textColor: t,
        onTap: () => Navigator.pop(context, day.gregorianDate),
      ));
    }
    while (cells.length < 42) {
      cells.add(const SizedBox());
    }

    return GridView.count(
      crossAxisCount: 7,
      childAspectRatio: 0.95,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(2),
      mainAxisSpacing: 2,
      crossAxisSpacing: 2,
      children: cells,
    );
  }

  /// 底部操作栏
  Widget _buildActions(
    void Function(void Function()) setDialogState,
    Color p,
    Color t,
    Color gold,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 今日按钮
          TextButton.icon(
            icon: Icon(Icons.today, size: 16, color: p),
            label: Text('今日', style: TextStyle(color: p)),
            onPressed: () {
              _cal.goToToday();
              setDialogState(() {});
            },
          ),
          // 取消
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('取消', style: TextStyle(color: t.withAlpha(180))),
          ),
        ],
      ),
    );
  }

  /// 年-月快速选择器弹窗
  void _showYearMonthPicker(void Function(void Function()) setDialogState) {
    int y = _cal.year;
    int m = _cal.month;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('选择年月'),
        content: SizedBox(
          width: 280,
          child: Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<int>(
                  value: y,
                  decoration: const InputDecoration(
                    labelText: '年',
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: List.generate(
                    201,
                    (i) => DropdownMenuItem(
                      value: 1900 + i,
                      child: Text('${1900 + i}'),
                    ),
                  ),
                  onChanged: (v) => y = v ?? y,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<int>(
                  value: m,
                  decoration: const InputDecoration(
                    labelText: '月',
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: List.generate(
                    12,
                    (i) => DropdownMenuItem(
                      value: i + 1,
                      child: Text('${i + 1}月'),
                    ),
                  ),
                  onChanged: (v) => m = v ?? m,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _cal.goToYearMonth(y, m);
              setDialogState(() {});
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// 日期格子组件 — 复用 `_DayCell` 的国风视觉风格
// ============================================================================

class _PickerDayCell extends StatelessWidget {
  final CalendarDayInfo day;
  final Color primary;
  final Color textColor;
  final VoidCallback onTap;

  const _PickerDayCell({
    required this.day,
    required this.primary,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isWeekend = day.weekday >= 5;
    final isToday = day.isToday;

    Color dateColor = textColor;
    if (isToday) {
      dateColor = Colors.white;
    } else if (isWeekend) {
      dateColor = Colors.red.withAlpha(220);
    } else if (day.lunarDate.day == 1) {
      dateColor = primary;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: isToday ? primary.withAlpha(200) : null,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isToday ? primary.withAlpha(120) : Colors.transparent,
            width: isToday ? 1.5 : 0,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ── 公历日 ──
            Text(
              '${day.gregorianDate.day}',
              style: TextStyle(
                fontSize: 15,
                fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                color: dateColor,
              ),
            ),
            const SizedBox(height: 1),
            // ── 农历日 ──
            Text(
              day.lunarDate.dayChinese,
              style: TextStyle(
                fontSize: 9,
                color: isToday
                    ? Colors.white.withAlpha(230)
                    : textColor.withAlpha(130),
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            // ── 日干支小字 ──
            Text(
              day.dayGanZhi,
              style: TextStyle(
                fontSize: 8,
                color: isToday
                    ? Colors.white.withAlpha(200)
                    : textColor.withAlpha(100),
              ),
            ),
            // ── 节气小标（如有） ──
            if (day.solarTerm != null)
              Text(
                day.solarTerm!,
                style: TextStyle(
                  fontSize: 7,
                  color: isToday
                      ? Colors.white.withAlpha(220)
                      : Colors.orange.withAlpha(200),
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
              ),
          ],
        ),
      ),
    );
  }
}
