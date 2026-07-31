/// 乾坤易内置万年历风格日期选择器
/// 复用 [CalendarProvider] 显示日历网格，点击日期返回 [DateTime]。
library;

import 'package:flutter/material.dart';
import '../../../core/utils/logger.dart';
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
    Logger.instance.info('日期选择器', '打开，当前 ${_cal.year}年${_cal.month}月');
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
      child: ConstrainedBox(
        // 固定最小宽度样式（maxWidth 320，小屏可用宽度不足时自动收缩不溢出）+ 限制最大高度，
        // 避免小屏/横屏/桌面小窗口下内容溢出屏幕导致"点了没反应"
        constraints: BoxConstraints(
          maxWidth: 320,
          maxHeight: MediaQuery.sizeOf(context).height * 0.88,
        ),
        child: SafeArea(
          child: StatefulBuilder(
            builder: (ctx, setDialogState) {
              final yearGanZhi =
                  _cal.days.isNotEmpty ? _cal.days.first.yearGanZhi : '';
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── 顶部：干支年号 ──
                  _buildHeader(yearGanZhi, p, t, isDark),
                  // ── 月份导航（箭头 + 点击年月可快速选择）──
                  _buildNav(setDialogState, ctx, p, t),
                  // ── 星期表头 ──
                  _buildWeekdayHeader(p, t),
                  // ── 日期网格：Flexible + 滚动视图，高度不足时可滚动而非溢出 ──
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(8, 0, 8, 4),
                      child: _buildGrid(setDialogState, ctx, p, t),
                    ),
                  ),
                  // ── 底部按钮 ──
                  _buildActions(ctx, setDialogState, p, t),
                  // ── 错误提示 ──
                  if (_cal.hasError)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                      child: Text(
                        '⚠ 数据异常，部分日期可能不可用',
                        style: TextStyle(fontSize: 11, color: Colors.deepOrange.shade400),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
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

  Widget _buildNav(void Function(void Function()) upd, BuildContext ctx, Color p, Color t) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              _cal.goToPrevMonth();
              upd(() {});
            },
            color: t,
            tooltip: '上月',
          ),
          // 点击年月文字可快速选择年月（与万年历页一致的 Dropdown 方案）
          InkWell(
            onTap: () => _showYearMonthPicker(ctx, upd),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _cal.hasError ? '加载失败' : '${_cal.year}年${_cal.month}月',
                    style: TextStyle(
                        fontSize: 14,
                        color: t.withAlpha(160),
                        fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(width: 2),
                  Icon(Icons.arrow_drop_down, size: 18, color: p.withAlpha(180)),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              _cal.goToNextMonth();
              upd(() {});
            },
            color: t,
            tooltip: '下月',
          ),
        ],
      ),
    );
  }

  /// 快速选择年月 — 与万年历页 calendar_page.dart 的年月选择器一致：
  /// 年/月两个 Dropdown，确定后 [_cal.goToYearMonth] 跳转并刷新网格。
  void _showYearMonthPicker(BuildContext ctx, void Function(void Function()) upd) {
    int y = _cal.year;
    int m = _cal.month;
    final isDark = Theme.of(ctx).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF1A1A2E) : const Color(0xFFF5F0EB);

    showDialog(
      context: ctx,
      builder: (context) => AlertDialog(
        backgroundColor: bg,
        surfaceTintColor: bg,
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
                  // 1901-2100，与 CalendarProvider.kMinYear/kMaxYear 一致
                  items: List.generate(200, (i) => DropdownMenuItem(
                    value: 1901 + i,
                    child: Text('${1901 + i}'),
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
              Logger.instance.info('日期选择器', '快速选择 → $y年$m月');
              _cal.goToYearMonth(y, m);
              upd(() {});
            },
            child: const Text('确定'),
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
    if (_cal.days.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: Text('暂无日期数据', style: TextStyle(fontSize: 14))),
      );
    }

    // 填充空白以对齐星期（0=周一，前面补 weekday 个空格子）
    final first = _cal.days.first.weekday;
    final List<Widget> cells = [];
    for (int i = 0; i < first; i++) {
      cells.add(const SizedBox());
    }
    for (final day in _cal.days) {
      cells.add(_DayCell(
        day: day,
        primary: p,
        textColor: t,
        onTap: () {
          Logger.instance.info('日期选择器', '选中 ${day.gregorianDate}');
          Navigator.pop(ctx, day.gregorianDate);
        },
      ));
    }
    // 固定每格高度 mainAxisExtent，避免 childAspectRatio 在小屏下把格子压得过矮
    // 导致单元格内容溢出；FittedBox 兜底缩放保证不出现黄黑条纹。
    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisExtent: 46,
      ),
      children: cells,
    );
  }

  Widget _buildActions(BuildContext ctx, void Function(void Function()) upd, Color p, Color t) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: () {
              Logger.instance.info('日期选择器', '回到今天');
              _cal.goToToday();
              upd(() {});
            },
            child: Text('今天', style: TextStyle(color: p)),
          ),
          TextButton(
            onPressed: () {
              Logger.instance.info('日期选择器', '取消选择');
              Navigator.pop(ctx);
            },
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
        // FittedBox 保证内容在小格内等比缩放，不产生 RenderFlex overflow
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
      ),
    );
  }
}
