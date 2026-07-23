/// 参考资料页面
/// 展示神煞、纳音、卦辞、星宿等参考信息
import 'package:flutter/material.dart';
import '../../paipan/models/gua_model.dart';
import '../data/reference_data.dart';

class ReferencePage extends StatelessWidget {
  const ReferencePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('参考资料'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: '六十四卦'),
              Tab(text: '纳音'),
              Tab(text: '二十八星宿'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _GuaCiTab(),
            _NaYinTab(),
            _XingXiuTab(),
          ],
        ),
      ),
    );
  }
}

/// 卦辞标签页
class _GuaCiTab extends StatelessWidget {
  const _GuaCiTab();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: guaCiList.length,
      separatorBuilder: (_, __) => const Divider(height: 4),
      itemBuilder: (ctx, i) {
        final gc = guaCiList[i];
        return Card(
          child: ExpansionTile(
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(gc.title, style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onPrimaryContainer)),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(gc.ci, style: theme.textTheme.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis)),
              ],
            ),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('【卦辞】${gc.ci}', style: theme.textTheme.bodyMedium),
                    const SizedBox(height: 8),
                    Text('【象辞】${gc.xiang}', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// 纳音标签页
class _NaYinTab extends StatelessWidget {
  const _NaYinTab();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final entries = naYinTable.entries.toList();

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: entries.length,
      itemBuilder: (ctx, i) {
        final e = entries[i];
        return Card(
          child: ListTile(
            leading: Container(
              width: 80,
              padding: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Text(e.key, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: theme.colorScheme.onPrimaryContainer)),
            ),
            title: Text(e.value),
            trailing: const Icon(Icons.chevron_right),
          ),
        );
      },
    );
  }
}

/// 星宿标签页
class _XingXiuTab extends StatelessWidget {
  const _XingXiuTab();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // 按方向分组
    final grouped = <String, List<XingXiu>>{};
    for (final x in erShiBaXingXiu) {
      grouped.putIfAbsent(x.direction, () => []).add(x);
    }
    final dirOrder = ['东', '北', '西', '南'];

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        for (final dir in dirOrder)
          if (grouped.containsKey(dir)) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: _dirColor(dir),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('${dir}方七宿', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ]),
            ),
            ...grouped[dir]!.map((x) => Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Text(x.name, style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onPrimaryContainer)),
                ),
                title: Text(x.animal),
                subtitle: Text('五行：${x.element}'),
                trailing: Text(x.direction, style: TextStyle(color: _dirColor(x.direction))),
              ),
            )),
          ],
      ],
    );
  }

  Color _dirColor(String dir) {
    switch (dir) {
      case '东': return Colors.green;
      case '南': return Colors.red;
      case '西': return Colors.orange;
      case '北': return Colors.blue;
      default: return Colors.grey;
    }
  }
}
