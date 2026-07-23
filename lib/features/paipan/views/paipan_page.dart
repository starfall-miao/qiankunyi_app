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
    return Scaffold(
      appBar: AppBar(
        title: const Text('排盘'),
        actions: [
          IconButton(
            icon: Icon(
              context.watch<ThemeProvider>().themeMode == ThemeMode.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            tooltip: '切换主题',
            onPressed: () => context.read<ThemeProvider>().toggleTheme(),
          ),
        ],
      ),
      body: Consumer<PaipanProvider>(
        builder: (ctx, provider, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── 排盘方式Tab ──
                Row(
                  children: [
                    _tabBtn('六爻纳甲', 0),
                    const SizedBox(width: 8),
                    _tabBtn('梅花易数', 1),
                  ],
                ),
                const SizedBox(height: 8),
                // ── 输入表单 ──
                _tabIndex == 0 ? _buildLiuYaoForm(theme, provider) : _buildMeiHuaForm(theme, provider),
                // ── 结果区域 ──
                if (provider.currentResult != null) ...[
                  const Divider(height: 24),
                  _buildResultHeader(theme, provider),
                  const SizedBox(height: 8),
                  _buildResultBody(theme, provider.currentResult!),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _tabBtn(String label, int idx) {
    final sel = _tabIndex == idx;
    return Expanded(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: sel ? null : Colors.transparent,
          elevation: sel ? 1 : 0,
        ),
        onPressed: () => setState(() => _tabIndex = idx),
        child: Text(label, style: TextStyle(fontWeight: sel ? FontWeight.bold : FontWeight.normal)),
      ),
    );
  }

  // ──────────────── 六爻表单 ────────────────

  Widget _buildLiuYaoForm(ThemeData theme, PaipanProvider provider) {
    return Column(
      children: [
        _card(theme, Icons.calculate, '数字起卦', [
          _field('上卦数', '1~99', _upperCtrl),
          _field('下卦数', '1~99', _lowerCtrl),
          _field('动爻数', '1~6', _movingCtrl),
          const SizedBox(height: 8),
          FilledButton.icon(
            icon: const Icon(Icons.auto_fix_high),
            label: const Text('起卦'),
            onPressed: () => _liuYaoByNumbers(provider),
          ),
        ]),
        const SizedBox(height: 8),
        _card(theme, Icons.casino, '随机摇卦', [
          Text('模拟传统摇卦，随机生成六爻', style: theme.textTheme.bodySmall),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            icon: const Icon(Icons.casino),
            label: const Text('摇一卦'),
            onPressed: () => provider.setResult(LiuYaoEngine.manual()),
          ),
        ]),
        const SizedBox(height: 8),
        _card(theme, Icons.schedule, '时间起卦', [
          Text('以当前年月日时起卦', style: theme.textTheme.bodySmall),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            icon: const Icon(Icons.access_time),
            label: const Text('用当前时间起卦'),
            onPressed: () => provider.setResult(LiuYaoEngine.byTime(DateTime.now())),
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

  Widget _buildMeiHuaForm(ThemeData theme, PaipanProvider provider) {
    return Column(
      children: [
        _card(theme, Icons.auto_awesome, '数字起卦', [
          Text('输入三个数字定上下卦和动爻', style: theme.textTheme.bodySmall),
          _field('数字一（上卦）', '任意正整数', _numACtrl),
          _field('数字二（下卦）', '任意正整数', _numBCtrl),
          _field('数字三（动爻）', '任意正整数', _numCCtrl),
          const SizedBox(height: 8),
          FilledButton.icon(
            icon: const Icon(Icons.auto_awesome),
            label: const Text('起卦'),
            onPressed: () => _meiHuaByNumbers(provider),
          ),
        ]),
        const SizedBox(height: 8),
        _card(theme, Icons.schedule, '时间起卦', [
          Text('以当前年月日时起梅花卦', style: theme.textTheme.bodySmall),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            icon: const Icon(Icons.access_time),
            label: const Text('用当前时间起卦'),
            onPressed: () {
              try {
                provider.setResult(MeihuaEngine.fromDateTime(DateTime.now()));
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

  Widget _buildResultHeader(ThemeData theme, PaipanProvider provider) {
    final r = provider.currentResult!;
    return Row(
      children: [
        Text('排盘结果', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(r.method, style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onPrimaryContainer)),
        ),
        const Spacer(),
        TextButton.icon(
          icon: const Icon(Icons.close, size: 18),
          label: const Text('清除'),
          onPressed: () => provider.clearResult(),
        ),
      ],
    );
  }

  Widget _buildResultBody(ThemeData theme, PaipanResult result) {
    if (result.method.contains('梅花')) {
      return MeihuaResultWidget(result: result);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GuaWidget(gua: result.benGua),
        if (result.bianGua != null) ...[
          const SizedBox(height: 8),
          Text('▸ 变卦', style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.primary)),
          GuaWidget(gua: result.bianGua!, showFooter: false),
        ],
        if (result.huGua != null) ...[
          const SizedBox(height: 8),
          Text('▸ 互卦', style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.primary)),
          GuaWidget(gua: result.huGua!, showFooter: false),
        ],
        if (result.shenSha.isNotEmpty) ...[
          const SizedBox(height: 8),
          _infoChip(theme, '神煞', result.shenSha.join('、')),
        ],
        if (result.naYin != null) ...[
          const SizedBox(height: 4),
          _infoChip(theme, '纳音', result.naYin!),
        ],
      ],
    );
  }

  Widget _infoChip(ThemeData theme, String label, String value) {
    return Row(
      children: [
        Text('$label：', style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
        Expanded(child: Text(value, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant))),
      ],
    );
  }

  // ──────────────── 通用组件 ────────────────

  Widget _card(ThemeData theme, IconData icon, String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(icon, size: 20, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
            ]),
            const SizedBox(height: 12),
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
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
      ),
    );
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}