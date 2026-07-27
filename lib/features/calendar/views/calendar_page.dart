/// 万年历页面
/// 月视图 + 详情卡片
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/theme_provider.dart';
import '../models/calendar_models.dart';
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
              title: const Text('万年历'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.today),
                  tooltip: '回到今天',
                  onPressed: () => cal.goToToday(),
                ),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(44),
                child: _buildMonthNav(context, cal, p, t),
              ),
            ),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  // 星期表头
                  _buildWeekdayHeader(p, t, isDark),
                  // 月视图网格
                  _buildMonthGrid(cal, monthData, p, t),
                  // 选中日期详情
                  if (cal.selectedDay != null)
                    _buildDayDetail(cal.selectedDay!, p, t, isDark),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// 月份导航条
  Widget _buildMonthNav(
      BuildContext context, CalendarProvider cal, Color p, Color t) {
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
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: p.withAlpha(15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: p.withAlpha(40)),
              ),
              child: Text(
                '${cal.year}年 ${cal.month}月',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: t,
                ),
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
  Widget _buildWeekdayHeader(Color p, Color t, bool isDark) {
    const weekdays = ['一', '二', '三', '四', '五', '六', '日'];
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF5F0EB),
        border: Border(
          bottom: BorderSide(color: p.withAlpha(60)),
          top: BorderSide(color: p.withAlpha(40)),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 10),
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
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isWeekend ? Colors.red.withAlpha(200) : t.withAlpha(200),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// 月视图网格
  Widget _buildMonthGrid(CalendarProvider cal, MonthData monthData, Color p,
      Color t) {
    final days = monthData.days;
    final firstW = monthData.firstWeekday;

    // 构建6行7列的网格（共42格）
    final cells = <Widget>[];

    // 填充当月第一天前的空白天数
    for (int i = 0; i < firstW; i++) {
      cells.add(const _EmptyCell());
    }

    // 日期格子（当月）
    for (final day in days) {
      final isSelected = cal.selectedDay?.gregorianDate == day.gregorianDate;
      cells.add(_DayCell(
        day: day,
        isSelected: isSelected,
        primary: p,
        textColor: t,
        onTap: () => cal.selectDay(day),
      ));
    }

    // 补全末尾空白格子至42格
    while (cells.length < 42) {
      cells.add(const _EmptyCell());
    }

    return GridView.count(
      crossAxisCount: 7,
      childAspectRatio: 1.0,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(4),
      mainAxisSpacing: 2,
      crossAxisSpacing: 2,
      children: cells,
    );
  }

  /// 选中日期的详情面板
  Widget _buildDayDetail(CalendarDayInfo day, Color p,
      Color t, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF333333) : const Color(0xFFFDF8F3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: p.withAlpha(50)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题行：公历 + 星期 + 生肖
          Row(
            children: [
              Text(
                '${day.gregorianDate.year}年${day.gregorianDate.month}月${day.gregorianDate.day}日',
                style: TextStyle(fontSize: 15, color: t.withAlpha(200)),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: p.withAlpha(20),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '星期${CalendarDayInfo.weekdayNames[day.weekday]}',
                  style: TextStyle(fontSize: 12, color: p, fontWeight: FontWeight.w500),
                ),
              ),
              const Spacer(),
              Text(
                '第${day.dayOfYear}天',
                style: TextStyle(fontSize: 12, color: t.withAlpha(120)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // 农历核心信息
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // 农历日期（大号）
              Text(
                day.lunarDate.toString(),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: t,
                ),
              ),
              const SizedBox(width: 12),
              // 生肖
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: p.withAlpha(25),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${day.yearSB.zodiac}年',
                  style: TextStyle(fontSize: 14, color: p, fontWeight: FontWeight.w600),
                ),
              ),
              // 节气标签
              if (day.solarTerm != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.withAlpha(30),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    day.solarTerm!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.orange.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          // 干支信息三列
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: p.withAlpha(10),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                _miniInfoCell('年', day.yearSB.fullName, day.yearSB.zodiac, p, t),
                Container(width: 1, height: 30, color: p.withAlpha(30)),
                _miniInfoCell('月', day.monthSB.fullName, null, p, t),
                Container(width: 1, height: 30, color: p.withAlpha(30)),
                _miniInfoCell('日', day.daySB.fullName, null, p, t),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniInfoCell(
      String label, String value, String? zodiac, Color p, Color t) {
    return Expanded(
      child: Column(
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 11, color: p, fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text(value,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: t)),
          if (zodiac != null)
            Text(zodiac,
                style: TextStyle(fontSize: 12, color: t.withAlpha(160))),
        ],
      ),
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
                        decoration: const InputDecoration(
                          labelText: '年',
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: List.generate(
                          201,
                          (i) => DropdownMenuItem(
                            value: 1900 + i,
                            child: Text(
                              '${1900 + i}',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ),
                        onChanged: (v) => y = v ?? y,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        initialValue: m,
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

/// 空白格子
class _EmptyCell extends StatelessWidget {
  const _EmptyCell();

  @override
  Widget build(BuildContext context) {
    return const SizedBox();
  }
}

/// 日期格子组件
class _DayCell extends StatelessWidget {
  final CalendarDayInfo day;
  final bool isSelected;
  final Color primary;
  final Color textColor;
  final VoidCallback onTap;

  const _DayCell({
    required this.day,
    required this.isSelected,
    required this.primary,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isWeekend = day.weekday >= 5;
    final isToday = day.isToday;

    // 选中/今天的日期文字用白色，确保深色背景可见
    final useWhiteText = isSelected || isToday;

    Color dateColor = textColor;
    if (useWhiteText) {
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
          color: isSelected
              ? primary
              : (isToday ? primary.withAlpha(200) : null),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? primary
                : (isToday ? primary.withAlpha(120) : Colors.transparent),
            width: isSelected ? 2 : (isToday ? 1.5 : 0),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${day.gregorianDate.day}',
              style: TextStyle(
                fontSize: 16,
                fontWeight:
                    isToday || isSelected ? FontWeight.bold : FontWeight.w500,
                color: dateColor,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              day.lunarDate.dayChinese,
              style: TextStyle(
                fontSize: 9,
                color: isSelected || isToday
                    ? Colors.white.withAlpha(230)
                    : textColor.withAlpha(130),
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            if (day.solarTerm != null) ...[
              const SizedBox(height: 1),
              Text(
                day.solarTerm!,
                style: TextStyle(
                  fontSize: 7,
                  color: isSelected || isToday
                      ? Colors.white.withAlpha(220)
                      : Colors.orange.withAlpha(200),
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
