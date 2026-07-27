/// 万年历页面
///   - 响应式布局：窄屏竖排 / 宽屏并排
///   - 基于 tyme4dart 的丰富黄历信息
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tyme/tyme.dart' as tyme;

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
            ),
            body: LayoutBuilder(
              builder: (ctx, constraints) {
                final isWide = constraints.maxWidth >= 600;
                return Column(
                  children: [
                    _buildMonthNav(ctx, cal, p, t, isDark),
                    _buildWeekdayHeader(p, t, isDark),
                    Expanded(
                      child: isWide
                          ? _buildWideLayout(ctx, cal, p, t, isDark)
                          : _buildNarrowLayout(ctx, cal, p, t, isDark),
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }

  /// 窄屏：网格在上，详情在下
  Widget _buildNarrowLayout(
      BuildContext ctx, CalendarProvider cal, Color p, Color t, bool isDark) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildMonthGrid(cal, p, t, isDark),
          if (cal.selectedDay != null)
            _DayDetailPanel(day: cal.selectedDay!, p: p, t: t, isDark: isDark),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  /// 宽屏：网格在左，详情在右，详情可滚动
  Widget _buildWideLayout(
      BuildContext ctx, CalendarProvider cal, Color p, Color t, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: SingleChildScrollView(
            child: _buildMonthGrid(cal, p, t, isDark),
          ),
        ),
        const VerticalDivider(width: 1),
        Expanded(
          flex: 4,
          child: cal.selectedDay != null
              ? SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: _DayDetailPanel(
                    day: cal.selectedDay!,
                    p: p,
                    t: t,
                    isDark: isDark,
                  ),
                )
              : Center(child: Text('选择日期', style: TextStyle(color: t.withAlpha(120)))),
        ),
      ],
    );
  }

  /// 月份导航条
  Widget _buildMonthNav(
      BuildContext ctx, CalendarProvider cal, Color p, Color t, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: p.withAlpha(40))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => cal.goToPrevMonth(),
            tooltip: '上月',
          ),
          GestureDetector(
            onTap: () => _showYearMonthPicker(ctx, cal),
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
                  color: isWeekend
                      ? Colors.red.withAlpha(200)
                      : t.withAlpha(200),
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
      CalendarProvider cal, Color p, Color t, bool isDark) {
    final days = cal.days;
    final firstW = cal.firstWeekday;

    final cells = <Widget>[];
    for (int i = 0; i < firstW; i++) {
      cells.add(const SizedBox());
    }
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
    while (cells.length < 42) {
      cells.add(const SizedBox());
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

  /// 年月选择器
  void _showYearMonthPicker(BuildContext ctx, CalendarProvider cal) {
    int y = cal.year;
    int m = cal.month;

    showDialog(
      context: ctx,
      builder: (context) => AlertDialog(
        title: const Text('选择年月'),
        content: SizedBox(
          width: 280,
          child: Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<int>(
                  initialValue: y,
                  decoration: const InputDecoration(
                    labelText: '年',
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: List.generate(201, (i) => DropdownMenuItem(
                    value: 1900 + i,
                    child: Text('${1900 + i}'),
                  )),
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
                  items:
                      List.generate(12, (i) => DropdownMenuItem(
                    value: i + 1,
                    child: Text('${i + 1}月'),
                  )),
                  onChanged: (v) => m = v ?? m,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              cal.goToYearMonth(y, m);
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// 日期格子组件
// ============================================================================

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
                color: useWhiteText
                    ? Colors.white.withAlpha(230)
                    : textColor.withAlpha(130),
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            if (day.solarTerm != null)
              Text(
                day.solarTerm!,
                style: TextStyle(
                  fontSize: 7,
                  color: useWhiteText
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

// ============================================================================
// 日期详情面板 - 增强黄历信息
// ============================================================================

class _DayDetailPanel extends StatelessWidget {
  final CalendarDayInfo day;
  final Color p;
  final Color t;
  final bool isDark;

  const _DayDetailPanel({
    required this.day,
    required this.p,
    required this.t,
    required this.isDark,
  });

  /// 详情卡片容器
  Widget _card(String title, Widget child) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF333333) : const Color(0xFFFDF8F3),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: p.withAlpha(40)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
            child: Text(title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: p,
                )),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
            child: child,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 获取 Tyme 丰富数据
    final solarDay = tyme.SolarDay.fromYmd(
      day.gregorianDate.year,
      day.gregorianDate.month,
      day.gregorianDate.day,
    );
    final lunarDay = solarDay.getLunarDay();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // === 日期头 ===
        _buildHeader(solarDay, lunarDay),
        const SizedBox(height: 8),
        // === 干支 ===
        _card('干支', _buildGanZhi()),
        // === 宜/忌 ===
        _buildYiJi(lunarDay),
        // === 黄历条目 ===
        _buildHuangLi(lunarDay),
        // === 吉时 ===
        _buildJiShi(lunarDay),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildHeader(tyme.SolarDay solarDay, tyme.LunarDay lunarDay) {
    final weekName = CalendarDayInfo._weekdayNames[day.weekday];
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF333333) : const Color(0xFFFDF8F3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: p.withAlpha(50)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          // 日期大号
          Column(
            children: [
              Text(
                '${day.gregorianDate.day}',
                style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold, color: t),
              ),
              Text(
                '${day.gregorianDate.month}月',
                style: TextStyle(fontSize: 13, color: t.withAlpha(150)),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 农历 + 星期
                Text(
                  '${day.lunarDate.monthChinese}${day.lunarDate.dayChinese} 周$weekName',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: t),
                ),
                const SizedBox(height: 4),
                // 干支 + 生肖
                Text(
                  '${day.yearGanZhi}年 ${day.monthGanZhi}月 ${day.dayGanZhi}日  ·  ${day.zodiac}年',
                  style: TextStyle(fontSize: 14, color: t.withAlpha(200)),
                ),
                const SizedBox(height: 6),
                // 节气 + 第几天
                Row(
                  children: [
                    if (day.solarTerm != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.orange.withAlpha(30),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(day.solarTerm!,
                            style: TextStyle(
                                fontSize: 12,
                                color: Colors.orange.shade700,
                                fontWeight: FontWeight.w600)),
                      ),
                    const SizedBox(width: 8),
                    Text('第${day.dayOfYear}天',
                        style: TextStyle(fontSize: 12, color: t.withAlpha(130))),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGanZhi() {
    return Row(
      children: [
        _pillar('年柱', day.yearGanZhi, day.zodiac),
        const SizedBox(width: 8),
        _pillar('月柱', day.monthGanZhi, null),
        const SizedBox(width: 8),
        _pillar('日柱', day.dayGanZhi, null),
      ],
    );
  }

  Widget _pillar(String label, String value, String? sub) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: p.withAlpha(12),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          children: [
            Text(label,
                style: TextStyle(fontSize: 11, color: p, fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text(value,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: t)),
            if (sub != null)
              Text(sub,
                  style: TextStyle(fontSize: 12, color: t.withAlpha(150))),
          ],
        ),
      ),
    );
  }

  Widget _buildYiJi(tyme.LunarDay lunarDay) {
    final recommends = lunarDay.getRecommends();
    final avoids = lunarDay.getAvoids();
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF333333) : const Color(0xFFFDF8F3),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: p.withAlpha(40)),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 宜
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red.withAlpha(30),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text('宜',
                    style: TextStyle(
                        color: Colors.red,
                        fontSize: 13,
                        fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Wrap(
                  spacing: 4,
                  runSpacing: 2,
                  children: [
                    if (recommends.isEmpty)
                      Text('诸事不宜',
                          style: TextStyle(fontSize: 13, color: t.withAlpha(150)))
                    else
                      ...recommends.take(12).map((r) => _tag(r.getName(), Colors.red.shade700)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // 忌
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey.withAlpha(40),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text('忌',
                    style: TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                        fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Wrap(
                  spacing: 4,
                  runSpacing: 2,
                  children: avoids.take(12).map((r) => _tag(r.getName(), Colors.grey.shade600)).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(text,
          style: TextStyle(fontSize: 12, color: color)),
    );
  }

  Widget _buildHuangLi(tyme.LunarDay lunarDay) {
    final duty = lunarDay.getDuty().getName(); // 建除十二值神
    final sixStar = lunarDay.getSixStar().getName(); // 六曜
    final star28 = lunarDay.getTwentyEightStar().getName(); // 二十八宿
    final fetusDay = lunarDay.getFetusDay(); // 胎神

    // 冲煞：日冲
    final dayBranch = lunarDay.getSixtyCycle().getEarthBranch();
    final oppositeBranchIndex = (dayBranch.getIndex() + 6) % 12;
    final oppositeZodiac = tyme.Zodiac(oppositeBranchIndex).getName();

    // 彭祖百忌
    final pengZu = lunarDay.getSixtyCycle().getPengZu().getName();

    // 神煞
    final gods = lunarDay.getGods();

    return _card('黄历', Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _infoRow('值神', duty, p, t),
        _infoRow('六曜', sixStar, p, t),
        _infoRow('二十八宿', star28, p, t),
        _infoRow('冲煞', '冲${oppositeZodiac}(${tyme.EarthBranch(oppositeBranchIndex).getName()})', p, t),
        if (fetusDay != null) _infoRow('胎神', fetusDay.getName(), p, t),
        _infoRow('彭祖百忌', pengZu, p, t),
        if (gods.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('吉神宜趋',
                    style: TextStyle(fontSize: 12, color: p, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Wrap(
                  spacing: 4,
                  runSpacing: 2,
                  children: gods
                      .where((g) => g.getLuck().getIndex() == 0)
                      .take(8)
                      .map((g) => _tag(g.getName(), Colors.green.shade700))
                      .toList(),
                ),
                if (gods.any((g) => g.getLuck().getIndex() != 0)) ...[
                  const SizedBox(height: 4),
                  Text('凶煞宜忌',
                      style: TextStyle(fontSize: 12, color: Colors.red.shade700, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Wrap(
                    spacing: 4,
                    runSpacing: 2,
                    children: gods
                        .where((g) => g.getLuck().getIndex() != 0)
                        .take(8)
                        .map((g) => _tag(g.getName(), Colors.red.shade700))
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
      ],
    ));
  }

  Widget _infoRow(String label, String value, Color p, Color t) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 64,
            child: Text(label,
                style: TextStyle(
                    fontSize: 12, color: p, fontWeight: FontWeight.w500)),
          ),
          Expanded(
            child: Text(value,
                style: TextStyle(fontSize: 13, color: t)),
          ),
        ],
      ),
    );
  }

  Widget _buildJiShi(tyme.LunarDay lunarDay) {
    final hours = lunarDay.getHours();
    return _card('吉时', Column(
      children: [
        // 两列网格：每列6行
        ...List.generate(6, (row) {
          final left = hours[row * 2];
          final right = hours[row * 2 + 1];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              children: [
                Expanded(child: _hourCell(left)),
                const SizedBox(width: 8),
                Expanded(child: _hourCell(right)),
              ],
            ),
          );
        }),
      ],
    ));
  }

  Widget _hourCell(tyme.LunarHour hour) {
    final sc = hour.getSixtyCycle();
    final recommends = hour.getRecommends();
    final avoids = hour.getAvoids();

    final isGood = recommends.isNotEmpty;
    final isBad = avoids.isNotEmpty && !isGood;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: isGood
            ? Colors.green.withAlpha(15)
            : (isBad ? Colors.red.withAlpha(10) : Colors.grey.withAlpha(10)),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isGood
              ? Colors.green.withAlpha(40)
              : (isBad ? Colors.red.withAlpha(30) : Colors.grey.withAlpha(20)),
        ),
      ),
      child: Row(
        children: [
          Text(sc.getName(),
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isGood ? Colors.green.shade700 : (isBad ? Colors.red.shade700 : t.withAlpha(150)))),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              isGood ? '吉·宜' : (isBad ? '凶·忌' : '平'),
              style: TextStyle(fontSize: 11, color: isGood ? Colors.green.shade600 : (isBad ? Colors.red.shade600 : t.withAlpha(120))),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
