/// 参考资料页面
/// 展示六十四卦（八宫分组）、纳音、星宿等参考信息
library;

import 'package:flutter/material.dart';
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

/// ──────────────── 六十四卦（八宫分组） ────────────────

class _GuaCiTab extends StatefulWidget {
  const _GuaCiTab();

  @override
  State<_GuaCiTab> createState() => _GuaCiTabState();
}

class _GuaCiTabState extends State<_GuaCiTab>
    with SingleTickerProviderStateMixin {
  final _gongNames = ['乾宫', '兑宫', '离宫', '震宫', '巽宫', '坎宫', '艮宫', '坤宫'];
  String _selectedGong = '乾宫';

  Color _gongColor(String gong) {
    switch (gong) {
      case '乾宫': return const Color(0xFF6C3FAA);
      case '兑宫': return const Color(0xFFD4A843);
      case '离宫': return Colors.redAccent;
      case '震宫': return Colors.green;
      case '巽宫': return Colors.teal;
      case '坎宫': return Colors.blue;
      case '艮宫': return Colors.brown;
      case '坤宫': return Colors.orange;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gongData = baguaGong[_selectedGong] ?? [];

    return Column(
      children: [
        // 八宫选择器
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: _gongNames.map((gong) {
              final selected = gong == _selectedGong;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: FilterChip(
                  label: Text(gong),
                  selected: selected,
                  selectedColor: _gongColor(gong).withAlpha(60),
                  checkmarkColor: _gongColor(gong),
                  onSelected: (_) => setState(() => _selectedGong = gong),
                ),
              );
            }).toList(),
          ),
        ),
        // 当前宫八卦列表
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
            itemCount: gongData.length,
            separatorBuilder: (_, __) => const Divider(height: 4),
            itemBuilder: (ctx, i) => _buildGuaCard(context, theme, gongData[i], i),
          ),
        ),
      ],
    );
  }

  Widget _buildGuaCard(BuildContext context, ThemeData theme, GuaCi gc, int index) {
    return Card(
      child: ExpansionTile(
        initiallyExpanded: index == 0,
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('${index + 1}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: theme.colorScheme.onPrimaryContainer)),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(gc.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                if (gc.jiXiong.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                      color: _jiXiongColor(gc.jiXiong).withAlpha(30),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(gc.jiXiong, style: TextStyle(fontSize: 11, color: _jiXiongColor(gc.jiXiong))),
                  ),
              ],
            ),
            const Spacer(),
            if (gc.wuXing.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _wxColor(gc.wuXing).withAlpha(30),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(gc.wuXing, style: TextStyle(fontSize: 12, color: _wxColor(gc.wuXing))),
              ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _infoRow(theme, '卦辞', gc.ci),
                if (gc.xiang.isNotEmpty) _infoRow(theme, '象辞', gc.xiang),
                if (gc.yiXiang.isNotEmpty) _infoRow(theme, '意象', gc.yiXiang),
                if (gc.fangWei.isNotEmpty || gc.shuZi.isNotEmpty || gc.ziRan.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        if (gc.fangWei.isNotEmpty) _chip(theme, '方位', gc.fangWei),
                        if (gc.shuZi.isNotEmpty) _chip(theme, '数字', gc.shuZi),
                        if (gc.ziRan.isNotEmpty) _chip(theme, '自然', gc.ziRan),
                        if (gc.renWu.isNotEmpty) _chip(theme, '人物', gc.renWu),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(ThemeData theme, String label, String content) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: RichText(
        text: TextSpan(
          style: theme.textTheme.bodyMedium,
          children: [
            TextSpan(
              text: '【$label】',
              style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w600),
            ),
            TextSpan(text: content),
          ],
        ),
      ),
    );
  }

  Widget _chip(ThemeData theme, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text('$label：$value', style: theme.textTheme.labelSmall),
    );
  }

  Color _jiXiongColor(String jx) {
    if (jx.contains('吉')) return Colors.green;
    if (jx.contains('凶')) return Colors.red;
    return Colors.orange;
  }

  Color _wxColor(String wx) {
    switch (wx) {
      case '金': return const Color(0xFFD4A843);
      case '木': return Colors.green;
      case '水': return Colors.blue;
      case '火': return Colors.redAccent;
      case '土': return Colors.brown;
      default: return Colors.grey;
    }
  }
}

/// ──────────────── 纳音标签页 ────────────────

class _NaYinTab extends StatelessWidget {
  const _NaYinTab();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final grouped = <String, List<NaYin>>{};
    for (final e in naYinTable) {
      grouped.putIfAbsent(e.wuXing, () => []).add(e);
    }
    final wxOrder = ['金', '木', '水', '火', '土'];

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        // 简介
        Card(
          color: theme.colorScheme.primaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: theme.colorScheme.onPrimaryContainer),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '纳音五行是中国传统命理学术语，将六十甲子分为三十组，每组配以五行属性，用于命理分析和择吉。',
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onPrimaryContainer),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        // 按五行分组的纳音列表
        for (final wx in wxOrder)
          if (grouped.containsKey(wx)) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: _wxColor2(wx),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text('$wx 行', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                  const SizedBox(width: 8),
                  Text('${grouped[wx]!.length}组', style: theme.textTheme.bodySmall),
                ],
              ),
            ),
            ...grouped[wx]!.map((e) => Card(
              child: ListTile(
                dense: true,
                leading: Container(
                  width: 80,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    color: _wxColor2(wx).withAlpha(30),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Text(e.naYin, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: _wxColor2(wx))),
                ),
                title: Text(e.naYin, style: TextStyle(fontWeight: FontWeight.w600, color: _wxColor2(wx))),
                subtitle: Text('五行属${e.wuXing}'),
                trailing: const Icon(Icons.chevron_right, size: 18),
              ),
            )),
          ],
      ],
    );
  }

  Color _wxColor2(String wx) {
    switch (wx) {
      case '金': return const Color(0xFFB8860B);
      case '木': return Colors.green.shade700;
      case '水': return Colors.blue.shade700;
      case '火': return Colors.redAccent.shade200;
      case '土': return Colors.brown.shade600;
      default: return Colors.grey;
    }
  }
}

/// ──────────────── 星宿标签页 ────────────────

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
        Card(
          color: theme.colorScheme.primaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(Icons.stars, color: theme.colorScheme.onPrimaryContainer),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '二十八星宿是中国古代天文学划分星空的区域，分东、南、西、北四象，每象七宿。',
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onPrimaryContainer),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
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
                  child: Text('$dir方七宿', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ]),
            ),
            ...grouped[dir]!.map((x) => Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Text(x.name, style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onPrimaryContainer)),
                ),
                title: Text(x.name),
                subtitle: Text('五行：${x.element}  ●  ${x.animal}'),
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