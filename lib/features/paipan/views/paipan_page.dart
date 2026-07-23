import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/theme_provider.dart';
import '../providers/paipan_provider.dart';
import '../engines/liuyao_engine.dart';
import '../engines/meihua_engine.dart';
import '../models/paipan_result.dart';
import 'gua_widget.dart';
import 'meihua_widget.dart';

/// 排盘主页 - 支持六爻纳甲 & 梅花易数
class PaipanPage extends StatefulWidget {
  const PaipanPage({super.key});

  @override
  State<PaipanPage> createState() => _PaipanPageState();
}

class _PaipanPageState extends State<PaipanPage> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  final _upperCtrl = TextEditingController();
  final _lowerCtrl = TextEditingController();
  final _movingCtrl = TextEditingController();
  final _numACtrl = TextEditingController();
  final _numBCtrl = TextEditingController();
  final _numCCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
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
        bottom: TabBar(
          controller: _tabCtrl,
          tabs: const [
            Tab(icon: Icon(Icons.science), text: '六爻纳甲'),
            Tab(icon: Icon(Icons.auto_awesome), text: '梅花易数'),
          ],
        ),
      ),
      body: Consumer<PaipanProvider>(
        builder: (ctx, provider, _) {
          return Column(
            children: [
              // 输入表单
              Expanded(
                flex: provider.currentResult == null ? 1 : 0,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: TabBarView(
                    controller: _tabCtrl,
                    children: [
                      _buildLiuYaoForm(theme, provider),
                      _buildMeiHuaForm(theme, provider),
                    ],
                  ),
                ),
              ),
              // 排盘结果
              if (provider.currentResult != null)
                Expanded(
                  flex: 2,
                  child: _buildResultPanel(theme, provider.currentResult!),
                ),
            ],
          );
        },
      ),
    );
  }

  // ──────────────── 六爻输入表单 ────────────────

  Widget _buildLiuYaoForm(ThemeData theme, PaipanProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('数字起卦', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                _buildNumField('上卦数', '输入1-99', _upperCtrl),
                const SizedBox(height: 8),
                _buildNumField('下卦数', '输入1-99', _lowerCtrl),
                const SizedBox(height: 8),
                _buildNumField('动爻数', '输入1-6', _movingCtrl),
                const SizedBox(height: 16),
                FilledButton.icon(
                  icon: const Icon(Icons.auto_fix_high),
                  label: const Text('起卦'),
                  onPressed: () => _liuYaoByNumbers(provider),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(children: [
                  Icon(Icons.shuffle, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text('随机摇卦', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                ]),
                const SizedBox(height: 12),
                Text('模拟传统摇卦，随机生成六爻', style: theme.textTheme.bodySmall),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  icon: const Icon(Icons.casino),
                  label: const Text('摇一卦'),
                  onPressed: () {
                    final result = LiuYaoEngine.manual();
                    provider.setResult(result);
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(children: [
                  Icon(Icons.schedule, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text('时间起卦', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                ]),
                const SizedBox(height: 12),
                Text('以当前年月日时起卦', style: theme.textTheme.bodySmall),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  icon: const Icon(Icons.access_time),
                  label: const Text('用当前时间起卦'),
                  onPressed: () {
                    final result = LiuYaoEngine.byTime(DateTime.now());
                    provider.setResult(result);
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _liuYaoByNumbers(PaipanProvider provider) {
    final a = int.tryParse(_upperCtrl.text);
    final b = int.tryParse(_lowerCtrl.text);
    final c = int.tryParse(_movingCtrl.text);
    if (a == null || b == null || c == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入有效的数字')),
      );
      return;
    }
    if (c < 1 || c > 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('动爻数必须在1-6之间')),
      );
      return;
    }
    final result = LiuYaoEngine.byNumbers(a, b, c);
    provider.setResult(result);
  }

  // ──────────────── 梅花输入表单 ────────────────

  Widget _buildMeiHuaForm(ThemeData theme, PaipanProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('数字起卦（梅花易数）', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Text('输入任意三个数字，取上卦、下卦、动爻', style: theme.textTheme.bodySmall),
                const SizedBox(height: 12),
                _buildNumField('数字一（上卦）', '任意正整数', _numACtrl),
                const SizedBox(height: 8),
                _buildNumField('数字二（下卦）', '任意正整数', _numBCtrl),
                const SizedBox(height: 8),
                _buildNumField('数字三（动爻）', '任意正整数', _numCCtrl),
                const SizedBox(height: 16),
                FilledButton.icon(
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text('起卦'),
                  onPressed: () => _meiHuaByNumbers(provider),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('时间起卦', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Text('以当前年月日时起梅花卦', style: theme.textTheme.bodySmall),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  icon: const Icon(Icons.access_time),
                  label: const Text('用当前时间起卦'),
                  onPressed: () => _meiHuaByTime(provider),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _meiHuaByNumbers(PaipanProvider provider) {
    final a = int.tryParse(_numACtrl.text);
    final b = int.tryParse(_numBCtrl.text);
    final c = int.tryParse(_numCCtrl.text);
    if (a == null || b == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入有效的正整数')),
      );
      return;
    }
    try {
      final result = MeiHuaEngine.fromNumbers(a, b, c);
      provider.setResult(result);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('起卦失败：$e')),
      );
    }
  }

  void _meiHuaByTime(PaipanProvider provider) {
    try {
      final now = DateTime.now();
      final result = MeiHuaEngine.fromDateTime(now);
      provider.setResult(result);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('起卦失败：$e')),
      );
    }
  }

  // ──────────────── 结果展示 ────────────────

  Widget _buildResultPanel(ThemeData theme, PaipanResult result) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        border: Border(top: BorderSide(color: theme.dividerTheme.color ?? Colors.grey.shade300, width: 1)),
      ),
      child: Column(
        children: [
          // 结果标题栏
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text('排盘结果', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                const Spacer(),
                Text(result.method, style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.primary)),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => context.read<PaipanProvider>().clearResult(),
                  tooltip: '关闭',
                ),
              ],
            ),
          ),
          // 卦象展示
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: result.method.contains('梅花')
                  ? MeihuaResultWidget(result: result)
                  : Column(
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
                          Text('神煞：${result.shenSha.join("、")}',
                            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                        ],
                        if (result.naYin != null) ...[
                          const SizedBox(height: 4),
                          Text('纳音：${result.naYin}',
                            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                        ],
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────── 通用组件 ────────────────

  Widget _buildNumField(String label, String hint, TextEditingController ctrl) {
    return TextField(
      controller: ctrl,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
    );
  }
}