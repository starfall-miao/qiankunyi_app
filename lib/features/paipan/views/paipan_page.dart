/// 排盘主页 — 国风紧凑版
/// 参考 hexagram.qiankunyi.com.cn 布局
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
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      // ── 自定义 AppBar ──
      appBar: AppBar(
        backgroundColor: isDark
            ? const Color(0xFF1A1A2E)
            : const Color(0xFF3E2723),
        foregroundColor: const Color(0xFFF5F0EB),
        elevation: 0,
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFF8D6E63).withAlpha(60),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.change_circle_outlined, size: 20, color: Color(0xFFD4A574)),
              ),
              const SizedBox(width: 8),
              const Text(
                '乾坤易',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFD4A574),
                ),
              ),
              const Text(
                '六爻',
                style: TextStyle(fontSize: 12, color: Color(0xFFA1887F)),
              ),
            ],
          ),
        ),
        actions: [
          // 主题切换
          IconButton(
            icon: Icon(
              context.watch<ThemeProvider>().themeMode == ThemeMode.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
              color: const Color(0xFFD4A574),
            ),
            tooltip: '切换主题',
            onPressed: () => context.read<ThemeProvider>().toggleTheme(),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Consumer<PaipanProvider>(
        builder: (ctx, provider, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── 时间选择器（仿参考网站） ──
                _buildTimeSelector(theme, isDark),
                const SizedBox(height: 10),

                // ── 排盘方式 Tab ──
                _buildTabRow(theme, isDark),
                const SizedBox(height: 10),

                // ── 输入表单 ──
                _tabIndex == 0
                    ? _buildLiuYaoForm(theme, provider, isDark)
                    : _buildMeiHuaForm(theme, provider, isDark),

                // ── 结果区域 ──
                if (provider.currentResult != null) ...[
                  const SizedBox(height: 12),
                  _buildResultHeader(theme, provider, isDark),
                  const SizedBox(height: 8),
                  _buildResultBody(theme, provider.currentResult!, isDark),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  // ──────────────── 时间选择器 ────────────────

  Widget _buildTimeSelector(ThemeData theme, bool isDark) {
    final textColor = isDark ? const Color(0xFFE0D5C8) : const Color(0xFF4A3728);
    final bgColor = isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF5F0EB);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? const Color(0xFF444444) : const Color(0xFFE0D5C8),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.access_time, size: 16, color: textColor.withAlpha(150)),
          const SizedBox(width: 6),
          Text(
            '${_selectedTime.year}-${_selectedTime.month.toString().padLeft(2, '0')}-${_selectedTime.day.toString().padLeft(2, '0')}  ${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
            style: TextStyle(fontSize: 13, color: textColor),
          ),
          const Spacer(),
          InkWell(
            onTap: _pickDateTime,
            borderRadius: BorderRadius.circular(6),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF8D6E63).withAlpha(30),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text('选择时间',
                  style: TextStyle(fontSize: 12, color: textColor.withAlpha(180))),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDateTime() async {
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

  // ──────────────── 五行导航 ────────────────

  Widget _buildWuXingNav(ThemeData theme, bool isDark) {
    const items = [
      ('木', Color(0xFF2E7D32)),
      ('火', Color(0xFFD32F2F)),
      ('土', Color(0xFF8D6E63)),
      ('金', Color(0xFFF9A825)),
      ('水', Color(0xFF1565C0)),
    ];
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: items.map((e) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 3),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
            color: e.$2.withAlpha(isDark ? 40 : 25),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: e.$2.withAlpha(isDark ? 80 : 50)),
          ),
          child: Text(
            e.$1,
            style: TextStyle(fontSize: 12, color: e.$2, fontWeight: FontWeight.w500),
          ),
        );
      }).toList(),
    );
  }

  // ──────────────── 排盘方式 Tab ────────────────

  Widget _buildTabRow(ThemeData theme, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF5F0EB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? const Color(0xFF444444) : const Color(0xFFE0D5C8),
        ),
      ),
      padding: const EdgeInsets.all(3),
      child: Row(
        children: [
          _tabBtn('六爻纳甲', 0, isDark),
          const SizedBox(width: 3),
          _tabBtn('梅花易数', 1, isDark),
        ],
      ),
    );
  }

  Widget _tabBtn(String label, int idx, bool isDark) {
    final sel = _tabIndex == idx;
    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: sel
              ? (isDark ? const Color(0xFF3E2723) : const Color(0xFF8D6E63))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: InkWell(
          onTap: () => setState(() => _tabIndex = idx),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: sel ? FontWeight.bold : FontWeight.normal,
                color: sel
                    ? const Color(0xFFF5F0EB)
                    : (isDark ? const Color(0xFFE0D5C8) : const Color(0xFF4A3728)),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ──────────────── 六爻表单 ────────────────

  Widget _buildLiuYaoForm(ThemeData theme, PaipanProvider provider, bool isDark) {
    return Column(
      children: [
        _card(
          theme,
          isDark,
          Icons.calculate,
          '数字起卦',
          '输入上卦、下卦、动爻数',
          [
            _field('上卦数', '1~99', _upperCtrl),
            _field('下卦数', '1~99', _lowerCtrl),
            _field('动爻数', '1~6', _movingCtrl),
            const SizedBox(height: 10),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF8D6E63),
                foregroundColor: const Color(0xFFF5F0EB),
                minimumSize: const Size(double.infinity, 40),
              ),
              icon: const Icon(Icons.auto_fix_high, size: 18),
              label: const Text('起卦'),
              onPressed: () => _liuYaoByNumbers(provider),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _card(theme, isDark, Icons.casino, '随机摇卦', '模拟传统摇卦，随机生成六爻', [
          const SizedBox(height: 6),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: isDark ? const Color(0xFFE0D5C8) : const Color(0xFF4A3728),
              side: BorderSide(
                color: isDark ? const Color(0xFF444444) : const Color(0xFFE0D5C8),
              ),
              minimumSize: const Size(double.infinity, 40),
            ),
            icon: const Icon(Icons.casino, size: 18),
            label: const Text('摇一卦'),
            onPressed: () => provider.setResult(LiuYaoEngine.manual()),
          ),
        ]),
        const SizedBox(height: 8),
        _card(theme, isDark, Icons.schedule, '时间起卦', '以所选时间起卦', [
          const SizedBox(height: 6),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: isDark ? const Color(0xFFE0D5C8) : const Color(0xFF4A3728),
              side: BorderSide(
                color: isDark ? const Color(0xFF444444) : const Color(0xFFE0D5C8),
              ),
              minimumSize: const Size(double.infinity, 40),
            ),
            icon: const Icon(Icons.access_time, size: 18),
            label: const Text('用当前时间起卦'),
            onPressed: () => provider.setResult(LiuYaoEngine.byTime(_selectedTime)),
          ),
        ]),
      ],
    );
  }

  void _liuYaoByNumbers(PaipanProvider provider) {
    final a = int.tryParse(_upperCtrl.text);
    final b = int.tryParse(_lowerCtrl.text);
    final c = int.tryParse(_movingCtrl.text);
    if (a == null || b == null || c == null) {
      _snack('请输入有效的数字');
      return;
    }
    if (c < 1 || c > 6) {
      _snack('动爻数必须在1~6之间');
      return;
    }
    provider.setResult(LiuYaoEngine.byNumbers(a, b, c));
  }

  // ──────────────── 梅花表单 ────────────────

  Widget _buildMeiHuaForm(ThemeData theme, PaipanProvider provider, bool isDark) {
    return Column(
      children: [
        _card(theme, isDark, Icons.auto_awesome, '数字起卦', '输入三个数字定上下卦和动爻', [
          _field('数字一（上卦）', '任意正整数', _numACtrl),
          _field('数字二（下卦）', '任意正整数', _numBCtrl),
          _field('数字三（动爻）', '任意正整数', _numCCtrl),
          const SizedBox(height: 10),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF8D6E63),
              foregroundColor: const Color(0xFFF5F0EB),
              minimumSize: const Size(double.infinity, 40),
            ),
            icon: const Icon(Icons.auto_awesome, size: 18),
            label: const Text('起卦'),
            onPressed: () => _meiHuaByNumbers(provider),
          ),
        ]),
        const SizedBox(height: 8),
        _card(theme, isDark, Icons.schedule, '时间起卦', '以所选时间起梅花卦', [
          const SizedBox(height: 6),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: isDark ? const Color(0xFFE0D5C8) : const Color(0xFF4A3728),
              side: BorderSide(
                color: isDark ? const Color(0xFF444444) : const Color(0xFFE0D5C8),
              ),
              minimumSize: const Size(double.infinity, 40),
            ),
            icon: const Icon(Icons.access_time, size: 18),
            label: const Text('用所选时间起卦'),
            onPressed: () {
              try {
                provider.setResult(MeihuaEngine.fromDateTime(_selectedTime));
              } catch (e) {
                _snack('起卦失败：$e');
              }
            },
          ),
        ]),
      ],
    );
  }

  void _meiHuaByNumbers(PaipanProvider provider) {
    final a = int.tryParse(_numACtrl.text);
    final b = int.tryParse(_numBCtrl.text);
    final c = int.tryParse(_numCCtrl.text);
    if (a == null || b == null) {
      _snack('请输入有效的正整数');
      return;
    }
    try {
      provider.setResult(MeihuaEngine.fromNumbers(a, b, c));
    } catch (e) {
      _snack('起卦失败：$e');
    }
  }

  // ──────────────── 结果展示 ────────────────

  Widget _buildResultHeader(ThemeData theme, PaipanProvider provider, bool isDark) {
    final r = provider.currentResult!;
    final textColor = isDark ? const Color(0xFFE0D5C8) : const Color(0xFF4A3728);
    return Row(
      children: [
        Text('排盘结果',
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: textColor)),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xFF8D6E63).withAlpha(30),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: const Color(0xFF8D6E63).withAlpha(60)),
          ),
          child: Text(r.method,
              style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF8D6E63),
                  fontWeight: FontWeight.w500)),
        ),
        const Spacer(),
        InkWell(
          onTap: () => provider.clearResult(),
          borderRadius: BorderRadius.circular(6),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.close, size: 16, color: textColor.withAlpha(150)),
                const SizedBox(width: 2),
                Text('清除',
                    style: TextStyle(
                        fontSize: 12, color: textColor.withAlpha(150))),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultBody(ThemeData theme, PaipanResult result, bool isDark) {
    if (result.method.contains('梅花')) {
      return MeihuaResultWidget(result: result);
    }
    final textColor = isDark ? const Color(0xFFE0D5C8) : const Color(0xFF4A3728);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── 五行导航 ──
        _buildWuXingNav(theme, isDark),
        const SizedBox(height: 10),

        // ── 本卦 ──
        GuaWidget(gua: result.benGua),

        // ── 变卦 ──
        if (result.bianGua != null) ...[
          const SizedBox(height: 8),
          _guaSectionLabel('▸ 变卦', textColor),
          const SizedBox(height: 4),
          GuaWidget(gua: result.bianGua!, showFooter: false),
        ],

        // ── 互卦 ──
        if (result.huGua != null) ...[
          const SizedBox(height: 8),
          _guaSectionLabel('▸ 互卦', textColor),
          const SizedBox(height: 4),
          GuaWidget(gua: result.huGua!, showFooter: false),
        ],

        // ── 神煞 ──
        if (result.shenSha.isNotEmpty) ...[
          const SizedBox(height: 8),
          _infoChip(theme, isDark, '神煞', result.shenSha.join('、')),
        ],

        // ── 纳音 ──
        if (result.naYin != null) ...[
          const SizedBox(height: 4),
          _infoChip(theme, isDark, '纳音', result.naYin!),
        ],
      ],
    );
  }

  Widget _guaSectionLabel(String text, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(text,
          style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: textColor.withAlpha(180))),
    );
  }

  Widget _infoChip(ThemeData theme, bool isDark, String label, String value) {
    final textColor = isDark ? const Color(0xFFE0D5C8) : const Color(0xFF4A3728);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF5F0EB),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? const Color(0xFF444444) : const Color(0xFFE0D5C8),
        ),
      ),
      child: Row(
        children: [
          Text('$label：',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: textColor)),
          Expanded(
              child: Text(value,
                  style: TextStyle(fontSize: 12, color: textColor.withAlpha(180)))),
        ],
      ),
    );
  }

  // ──────────────── 通用组件 ────────────────

  Widget _card(ThemeData theme, bool isDark, IconData icon, String title,
      String subtitle, List<Widget> children) {
    final bgColor = isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF5F0EB);
    final textColor = isDark ? const Color(0xFFE0D5C8) : const Color(0xFF4A3728);

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF444444) : const Color(0xFFE0D5C8),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(icon, size: 18, color: textColor.withAlpha(180)),
              const SizedBox(width: 6),
              Text(title,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: textColor)),
            ]),
            if (subtitle.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(subtitle,
                  style: TextStyle(
                      fontSize: 12, color: textColor.withAlpha(120))),
            ],
            const SizedBox(height: 10),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _field(String label, String hint, TextEditingController ctrl) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextField(
        controller: ctrl,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
      ),
    );
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}