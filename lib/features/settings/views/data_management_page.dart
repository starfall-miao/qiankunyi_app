// 落·乾坤 - 数据管理页（卦例管理 / 设置恢复）
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../cases/providers/case_provider.dart';
import '../settings_provider.dart';

/// 数据管理：卦例统计/清理、设置恢复初始
class DataManagementPage extends StatefulWidget {
  const DataManagementPage({super.key});
  @override
  State<DataManagementPage> createState() => _DataManagementPageState();
}

class _DataManagementPageState extends State<DataManagementPage> {
  @override
  Widget build(BuildContext context) {
    final cp = context.watch<CaseProvider>();
    final sp = context.watch<SettingsProvider>();
    final scheme = Theme.of(context).colorScheme;
    final cases = cp.allCases;

    // 按天统计
    final byDay = <String, int>{};
    for (final c in cases) {
      final k = '${c.createdAt.year}-${c.createdAt.month.toString().padLeft(2, '0')}-${c.createdAt.day.toString().padLeft(2, '0')}';
      byDay[k] = (byDay[k] ?? 0) + 1;
    }
    final days = byDay.keys.toList()..sort((a, b) => b.compareTo(a));

    return Scaffold(
      appBar: AppBar(title: const Text('数据管理')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _card(scheme, [
            _titleRow(scheme, '📊 卦例数据', '共 ${cases.length} 条 · ${days.length} 天'),
            const SizedBox(height: 8),
            // 按天统计
            ...days.take(14).map((d) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(children: [
                Text(d, style: TextStyle(fontSize: 12, color: scheme.onSurface.withAlpha(170))),
                const Spacer(),
                Text('${byDay[d]} 条', style: TextStyle(fontSize: 12, color: scheme.primary)),
              ]),
            )),
          ]),
          const SizedBox(height: 12),
          _card(scheme, [
            _titleRow(scheme, '🗑️ 清空卦例', '删除全部卦例数据（本地）'),
            const SizedBox(height: 8),
            FilledButton.tonalIcon(
              onPressed: cases.isEmpty ? null : () => _confirmClearAll(cp),
              icon: const Icon(Icons.delete_forever, size: 18),
              label: const Text('清空全部卦例'),
              style: FilledButton.styleFrom(backgroundColor: scheme.errorContainer),
            ),
          ]),
          const SizedBox(height: 12),
          _card(scheme, [
            _titleRow(scheme, '⚙️ 设置管理', '恢复默认设置（不影响卦例与用户画像）'),
            const SizedBox(height: 8),
            FilledButton.tonalIcon(
              onPressed: () => _confirmResetSettings(sp),
              icon: const Icon(Icons.restart_alt, size: 18),
              label: const Text('恢复默认设置'),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _card(ColorScheme scheme, List<Widget> children) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children)),
    );
  }

  Widget _titleRow(ColorScheme scheme, String title, String sub) {
    return Row(children: [
      Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: scheme.onSurface)),
      const Spacer(),
      Text(sub, style: TextStyle(fontSize: 11, color: scheme.onSurface.withAlpha(130))),
    ]);
  }

  Future<void> _confirmClearAll(CaseProvider cp) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('清空全部卦例？'),
        content: Text('将删除全部 ${cp.allCases.length} 条卦例，此操作不可恢复。'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade300),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('清空'),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      for (final c in List.of(cp.allCases)) {
        await cp.deleteCase(c.id!);
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('已清空全部卦例')));
      }
    }
  }

  Future<void> _confirmResetSettings(SettingsProvider sp) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('恢复默认设置？'),
        content: const Text('将重置主题、字体、排盘规则、AI 配置等为默认值。不影响卦例数据和用户画像。'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('恢复'),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      await sp.resetToDefault();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('已恢复默认设置')));
      }
    }
  }
}
