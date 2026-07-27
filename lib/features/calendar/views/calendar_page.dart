/// 万年历页面
/// 月视图 + 详情卡片
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/theme_provider.dart';
import '../models/calendar_models.dart';
import '../engines/calendar_engine.dart';
import '../providers/calendar_provider.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  @override
  Widget build(BuildContext context) {
    final tp = context.watch<ThemeProvider>();
    final isDark = tp.themeMode == ThemeMode.dark ||
        (tp.themeMode == ThemeMode.system &&
            MediaQuery.platformBrightnessOf(context) == Brightness.dark);
    final p = Theme.of(context).colorScheme.primary;
    final t = isDark ? const Color(0xFFE0D5C8) : const Color(0xFF4A3728);
    final b = isDark ? const Color(0xFF3E3E3E) : const Color(0xFFD4C5B5);
    final c = isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF5F0EB);

    return ChangeNotifierProvider(
      create: (_) => CalendarProvider(),
      child: Consumer<CalendarProvider>(
        builder: (ctx, cal, _) {
          if (cal.isLoading || cal.monthData == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final monthData = cal.monthData!;

          return Scaffold(
            appBar: AppBar(
              title: Text('万年历'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.today),
                  tooltip: '回到今天',
                  onPressed: () => cal.goToToday(),
                ),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(44),
                child: _buildMonthNav(context, cal, p, t, b, c, isDark),
              ),
            ),
            body: Column(
              children: [
                // 星期表头
                _buildWeekdayHeader(p, t, b, c, isDark),
                // 月视图网格
                Expanded(
                  child: _buildMonthGrid(
                      context, cal, monthData, p, t, b, c, isDark),
                ),
                // 选中日期详情
                if (cal.selectedDay != null)
                  _buildDayDetail(context, cal.selectedDay!, p, t, c, isDark),
              ],
            ),
          );
        },
      ),
    );
  }

  /// 月份导航条
  Widget _buildMonthNav(BuildContext context, CalendarProvider cal, Color p,
      Color t, Color b, Color c, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => cal.goToPrevMonth(),
            tooltip: '上月',
          ),
          GestureDetector(
            onTap: () => _showYearMonthPicker(context, cal),
            child: Text(
              '${cal.year}年 ${cal.month}月',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: t,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () => cal.goToNextMonth(),
            tooltip: '下月',
          ),
        ],
      ),
    );
  }

  /// 星期表头
  Widget _buildWeekdayHeader(Color p, Color t, Color b, Color c, bool isDark) {
    const weekdays = ['一', '二', '三', '四', '五', '六', '日'];
    return Container(
      decoration: BoxDecoration(
        color: c,
        border: Border(bottom: BorderSide(color: b.withAlpha(80))),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: weekdays.asMap().entries.map((e) {
          final i = e.key;
          final name = e.value;
          final isWeekend = i >= 5;
          return Expanded(
            child: Center(
              child: Text(
                name,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isWeekend ? Colors.red.withAlpha(180) : t.withAlpha(180),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// 月视图网格
  Widget _buildMonthGrid(
      BuildContext context,
      CalendarProvider cal,
      MonthData monthData,
      Color p,
      Color t,
      Color b,
      Color c,
      bool isDark) {
    final days = monthData.days;
    final firstW = monthData.firstWeekday;

    // 构建6行7列的网格
    final cells = <Widget>[];

    // 填充当月第一天前的空白天数
    for (int i = 0; i < firstW; i++) {
      cells.add(const SizedBox());
    }

    // 日期格子
    for (final day in days) {
      final isSelected = cal.selectedDay?.gregorianDate == day.gregorianDate;
      cells.add(_DayCell(
        day: day,
        isSelected: isSelected,
        primary: p,
        textColor: t,
        cardBg: c,
        border: b,
        isDark: isDark,
        onTap: () => cal.selectDay(day),
      ));
    }

    return GridView.count(
      crossAxisCount: 7,
      childAspectRatio: 0.85,
      physics: const NeverScrollableScrollPhysics(),
      children: cells,
    );
  }

  /// 选中日期的详情面板
  Widget _buildDayDetail(BuildContext context, CalendarDayInfo day, Color p,
      Color t, Color c, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c,
        border: Border(top: BorderSide(color: p.withAlpha(60))),
      ),
      child: Row(
        children: [
          // 农历日期
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${day.gregorianDate.year}年${day.gregorianDate.month}月${day.gregorianDate.day}日',
                  style: TextStyle(fontSize: 14, color: t.withAlpha(200)),
                ),
                const SizedBox(height: 4),
                Text(
                  day.lunarDate.toString(),
                  style: TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold, color: t),
                ),
                if (day.solarTerm != null) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: p.withAlpha(30),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${day.solarTerm}',
                      style: TextStyle(fontSize: 12, color: p),
                    ),
                  ),
                ],
              ],
            ),
          ),
          // 干支信息
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _infoRow('年', day.yearSB.fullName, day.yearSB.zodiac, p, t),
                const SizedBox(height: 2),
                _infoRow('月', day.monthSB.fullName, null, p, t),
                const SizedBox(height: 2),
                _infoRow('日', day.daySB.fullName, null, p, t),
                const SizedBox(height: 4),
                Text(
                  '星期${CalendarDayInfo.weekdayNames[day.weekday]}  '
                  '第${day.dayOfYear}天',
                  style: TextStyle(fontSize: 12, color: t.withAlpha(150)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(
      String label, String value, String? zodiac, Color p, Color t) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
          decoration: BoxDecoration(
            color: p.withAlpha(25),
            borderRadius: BorderRadius.circular(3),
          ),
          child: Text(label,
              style: TextStyle(fontSize: 11, color: p, fontWeight: FontWeight.w600)),
        ),
        const SizedBox(width: 8),
        Text(value,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: t)),
        if (zodiac != null) ...[
          const SizedBox(width: 4),
          Text('($zodiac年)',
              style: TextStyle(fontSize: 12, color: t.withAlpha(160))),
        ],
      ],
    );
  }

  /// 年份月份选择器
  void _showYearMonthPicker(BuildContext context, CalendarProvider cal) {
    int y = cal.year;
    int m = cal.month;

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('选择年月'),
          content: SizedBox(
            width: 280,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        initialValue: y,
                        decoration: const InputDecoration(labelText: '年'),
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
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        initialValue: m,
                        decoration: const InputDecoration(labelText: '月'),
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
                cal.goToYearMonth(y, m);
              },
              child: const Text('确定'),
            ),
          ],
        );
      },
    );
  }
}

/// 日期格子组件
class _DayCell extends StatelessWidget {
  final CalendarDayInfo day;
  final bool isSelected;
  final Color primary;
  final Color textColor;
  final Color cardBg;
  final Color border;
  final bool isDark;
  final VoidCallback onTap;

  const _DayCell({
    required this.day,
    required this.isSelected,
    required this.primary,
    required this.textColor,
    required this.cardBg,
    required this.border,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isWeekend = day.weekday >= 5;
    final isToday = day.isToday;
    Color dateColor = textColor;

    if (isWeekend) dateColor = Colors.red.withAlpha(200);
    if (day.lunarDate.day == 1) dateColor = primary;
    if (isToday) dateColor = primary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: isSelected
              ? primary.withAlpha(30)
              : (isToday ? primary.withAlpha(15) : null),
          borderRadius: BorderRadius.circular(6),
          border: isToday
              ? Border.all(color: primary.withAlpha(120), width: 1.5)
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${day.gregorianDate.day}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                color: dateColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              day.lunarDate.dayChinese,
              style: TextStyle(
                fontSize: 10,
                color: isSelected
                    ? primary
                    : textColor.withAlpha(isToday ? 180 : 120),
              ),
              overflow: TextOverflow.ellipsis,
            ),
            if (day.solarTerm != null)
              Text(
                day.solarTerm!,
                style: TextStyle(
                  fontSize: 8,
                  color: primary.withAlpha(180),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
