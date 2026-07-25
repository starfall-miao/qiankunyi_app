// 排盘主页 — 国风紧凑版（主题感知）
// 参考 hexagram.qiankunyi.com.cn 布局

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/theme_provider.dart';
import '../providers/paipan_provider.dart';
import '../engines/liuyao_engine.dart';
import '../engines/meihua_engine.dart';
import '../models/paipan_result.dart';
import 'gua_widget.dart';
import 'meihua_widget.dart';

/// 排盘主页
class PaipanPage extends StatefulWidget {
  const PaipanPage({super.key});

  @override
  State<PaipanPage> createState() => _PaipanPageState();
}

class _PaipanPageState extends State<PaipanPage> {
  int _tabIndex = 0;
  final _upperCtrl = TextEditingController();
  final _lowerCtrl = TextEditingController();
  final _movingCtrl = TextEditingController();
  final _numACtrl = TextEditingController();
  final _numBCtrl = TextEditingController();
  final _numCCtrl = TextEditingController();
  DateTime _selectedTime = DateTime.now();

  @override
  void dispose() {
    _upperCtrl.dispose();
    _lowerCtrl.dispose();
    _movingCtrl.dispose();
    _numACtrl.dispose();
    _numBCtrl.dispose();
    _numCCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tp = context.watch<ThemeProvider>();
    final isDark = theme.brightness == Brightness.dark;
    final primary = tp.colorSchemeType.primary;
    final useAcrylic = tp.acrylicEffect;
    final int a = (tp.acrylicOpacity * 255).round().clamp(0, 255);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: useAcrylic
            ? (isDark ? const Color(0xFF252542).withAlpha(a) : Colors.white.withAlpha(a))
            : (isDark ? const Color(0xFF1A1A2E) : primary),
        foregroundColor: useAcrylic
            ? (isDark ? const Color(0xFFE8E0D8) : const Color(0xFF2C2C2C))
            : const Color(0xFFF5F0EB),
        elevation: 0,
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withAlpha(30) : Colors.black.withAlpha(20),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(Icons.change_circle_outlined, size: 20,
                    color: isDark ? secondaryColor(tp) : const Color(0xFFD4A574)),
              ),
              const SizedBox(width: 8),
              Text(
                '落·乾坤',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? secondaryColor(tp) : const Color(0xFFD4A574),
                ),
              ),
              Text(
                _tabIndex == 0 ? ' 六爻' : ' 梅花',
                style: TextStyle(fontSize: 12,
                    color: isDark ? Colors.white54 : const Color(0xFFA1887F)),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              tp.themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode,
              color: isDark ? secondaryColor(tp) : const Color(0xFFD4A574),
            ),
            tooltip: '切换主题',
            onPressed: () => tp.toggleTheme(),
          ),
        ],
      ),
      body: _buildBody(context, theme, tp, isDark, primary, useAcrylic, a),
    );
  }

  Color secondaryColor(ThemeProvider tp) {
    // 金色辅助色（国风传统配色）
    return const Color(0xFFD4A574);
  }

  Widget _buildBody(BuildContext context, ThemeData theme, ThemeProvider tp,
      bool isDark, Color primary, bool useAcrylic, int a) {
    final provider = context.watch<PaipanProvider>();
    final textColor = isDark ? const Color(0xFFE0D5C8) : const Color(0xFF4A3728);
    final bgColor = isDark ? const Color(0xFF1A1A2E) : const Color(0xFFF5F0EB);
    final cardBg = useAcrylic
        ? (isDark ? const Color(0xFF252542).withAlpha(a) : Colors.white.withAlpha(a))
        : (isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF5F0EB));
    final borderColor = isDark ? const Color(0xFF444444) : const Color(0xFFE0D5C8);

    return Container(
      color: bgColor,
      child: Column(
        children: [
          // ── 时间选择器 ──
          _buildTimePicker(context, theme, isDark, primary, textColor, cardBg, borderColor),

          // ── Tab 切换 ──
          _buildTabBar(context, isDark, primary, borderColor),

          // ── 输入区域 ──
          Expanded(
            child: _tabIndex == 0
                ? _buildLiuyaoInput(context, theme, tp, isDark, primary, textColor, cardBg, borderColor, useAcrylic, a)
                : _buildMeihuaInput(context, theme, isDark, primary, textColor, cardBg, borderColor),
          ),

          // ── 排盘按钮 ──
          _buildSubmitButton(context, isDark, primary, provider),
        ],
      ),
    );
  }

  // ── 时间选择器 ──

  Widget _buildTimePicker(BuildContext context, ThemeData theme, bool isDark,
      Color primary, Color textColor, Color cardBg, Color borderColor) {
    return Container(
      margin: const EdgeInsets.fromLTRB(8, 6, 8, 0),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Icon(Icons.access_time, size: 14, color: primary),
          const SizedBox(width: 6),
          Text(
            '${_selectedTime.year}年${_selectedTime.month}月${_selectedTime.day}日 '
            '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
            style: TextStyle(fontSize: 12, color: textColor),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => _pickDateTime(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: primary.withAlpha(25),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text('修改', style: TextStyle(fontSize: 11, color: primary)),
            ),
          ),
        ],
      ),
    );
  }

  // ── Tab 切换栏 ──

  Widget _buildTabBar(BuildContext context, bool isDark, Color primary, Color borderColor) {
    return Container(
      margin: const EdgeInsets.fromLTRB(8, 4, 8, 0),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF5F0EB),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          _tabItem('六爻（铜钱）', 0),
          _tabItem('梅花易数', 1),
        ],
      ),
    );
  }

  Widget _tabItem(String label, int index) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = context.watch<ThemeProvider>().colorSchemeType.primary;
    final selected = _tabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tabIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: selected ? primary.withAlpha(25) : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              color: selected ? primary : (isDark ? const Color(0xFF888888) : const Color(0xFF888888)),
            ),
          ),
        ),
      ),
    );
  }

  // ── 六爻输入区 ──

  Widget _buildLiuyaoInput(BuildContext context, ThemeData theme, ThemeProvider tp,
      bool isDark, Color primary, Color textColor, Color cardBg, Color borderColor,
      bool useAcrylic, int a) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          // 手动起卦区
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.handyman_outlined, size: 14, color: primary),
                    const SizedBox(width: 4),
                    Text('手动起卦（三数）', style: TextStyle(fontSize: 12, color: textColor, fontWeight: FontWeight.w500)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _numField('上卦', _upperCtrl, '0-8'),
                    const SizedBox(width: 6),
                    _numField('下卦', _lowerCtrl, '0-8'),
                    const SizedBox(width: 6),
                    _numField('动爻', _movingCtrl, '0-6'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),

          // 随机起卦区
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.shuffle, size: 14, color: primary),
                    const SizedBox(width: 4),
                    Text('随机起卦', style: TextStyle(fontSize: 12, color: textColor, fontWeight: FontWeight.w500)),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _smallBtn('上卦', primary, () {}),
                    const SizedBox(width: 4),
                    _smallBtn('下卦', primary, () {}),
                    const SizedBox(width: 4),
                    _smallBtn('动爻', primary, () {}),
                    const SizedBox(width: 8),
                    _smallBtn('全随机', primary, () {}),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),

          // 五行导航
          _buildWuxingNav(isDark, primary, cardBg, borderColor),

          const SizedBox(height: 6),

          // 排盘结果
          if (provider.result != null)
            _buildResult(context, theme, tp, isDark, primary, textColor, cardBg, borderColor, useAcrylic, a, provider.result!)
          else
            _buildEmptyHint(primary, textColor),
        ],
      ),
    );
  }

  Widget _numField(String label, TextEditingController ctrl, String hint) {
    return Expanded(
      child: TextField(
        controller: ctrl,
        keyboardType: TextInputType.number,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
        ),
      ),
    );
  }

  Widget _smallBtn(String label, Color primary, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: primary.withAlpha(20),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(label, style: TextStyle(fontSize: 11, color: primary)),
      ),
    );
  }

  // ── 五行导航 ──

  Widget _buildWuxingNav(bool isDark, Color primary, Color cardBg, Color borderColor) {
    final wuxing = [
      ('木', const Color(0xFF2E7D32)),
      ('火', const Color(0xFFD32F2F)),
      ('土', const Color(0xFF8D6E63)),
      ('金', const Color(0xFFF9A825)),
      ('水', const Color(0xFF1565C0)),
    ];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: wuxing.map((w) => Column(
          children: [
            Container(
              width: 24, height: 24,
              decoration: BoxDecoration(
                color: w.$2.withAlpha(30),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(child: Text(w.$1, style: TextStyle(fontSize: 10, color: w.$2, fontWeight: FontWeight.bold))),
            ),
            const SizedBox(height: 2),
            Text(w.$1, style: TextStyle(fontSize: 10, color: isDark ? const Color(0xFF999999) : const Color(0xFF888888))),
          ],
        )).toList(),
      ),
    );
  }

  // ── 排盘结果 ──

  Widget _buildResult(BuildContext context, ThemeData theme, ThemeProvider tp,
      bool isDark, Color primary, Color textColor, Color cardBg, Color borderColor,
      bool useAcrylic, int a, PaipanResult result) {
    return Column(
      children: [
        if (result.liuyao != null)
          GuaWidget(
            gua: result.liuyao!,
            theme: theme,
            isDark: isDark,
            primary: primary,
            useAcrylic: useAcrylic,
            acrylicAlpha: a,
          ),
        if (result.meihua != null)
          MeihuaResultWidget(
            result: result,
            theme: theme,
            isDark: isDark,
            primary: primary,
            useAcrylic: useAcrylic,
            acrylicAlpha: a,
          ),
        const SizedBox(height: 8),
        // 清空按钮
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => context.read<PaipanProvider>().clear(),
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('清空排盘'),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildEmptyHint(Color primary, Color textColor) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Icon(Icons.auto_awesome, size: 48, color: primary.withAlpha(60)),
            const SizedBox(height: 12),
            Text('输入卦数或点击随机起卦', style: TextStyle(fontSize: 14, color: textColor.withAlpha(120))),
          ],
        ),
      ),
    );
  }

  // ── 梅花易数输入 ──

  Widget _buildMeihuaInput(BuildContext context, ThemeData theme, bool isDark,
      Color primary, Color textColor, Color cardBg, Color borderColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.numbers, size: 14, color: primary),
                    const SizedBox(width: 4),
                    Text('三数起卦', style: TextStyle(fontSize: 12, color: textColor, fontWeight: FontWeight.w500)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _numField('数 A', _numACtrl, '0-9'),
                    const SizedBox(width: 6),
                    _numField('数 B', _numBCtrl, '0-9'),
                    const SizedBox(width: 6),
                    _numField('数 C', _numCCtrl, '0-9'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.date_range, size: 14, color: primary),
                    const SizedBox(width: 4),
                    Text('日期起卦', style: TextStyle(fontSize: 12, color: textColor, fontWeight: FontWeight.w500)),
                  ],
                ),
                const SizedBox(height: 6),
                Text('使用当前选中时间年月日数字起卦', style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFF999999) : const Color(0xFF888888))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── 排盘按钮 ──

  Widget _buildSubmitButton(BuildContext context, bool isDark, Color primary, PaipanProvider provider) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: SizedBox(
          width: double.infinity,
          height: 44,
          child: ElevatedButton.icon(
            onPressed: () => _onSubmit(context, provider),
            icon: const Icon(Icons.auto_awesome, size: 18),
            label: const Text('开始排盘', style: TextStyle(fontSize: 16)),
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
      ),
    );
  }

  void _onSubmit(BuildContext context, PaipanProvider provider) {
    if (_tabIndex == 0) {
      final upper = int.tryParse(_upperCtrl.text) ?? 0;
      final lower = int.tryParse(_lowerCtrl.text) ?? 0;
      final moving = int.tryParse(_movingCtrl.text) ?? 0;
      if (upper > 0 && lower > 0) {
        final result = LiuyaoEngine.calculate(upper, lower, moving, time: _selectedTime);
        provider.setResult(result);
      }
    } else {
      final a = int.tryParse(_numACtrl.text) ?? 0;
      final b = int.tryParse(_numBCtrl.text) ?? 0;
      final c = int.tryParse(_numCCtrl.text) ?? 0;
      if (a > 0 || b > 0 || c > 0) {
        final result = MeihuaEngine.calculate(a, b, c, time: _selectedTime);
        provider.setResult(result);
      }
    }
  }

  // ── 时间选择 ──

  Future<void> _pickDateTime(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedTime,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (date == null) return;
    if (!context.mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedTime),
    );
    if (time == null) return;
    setState(() {
      _selectedTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }
}
