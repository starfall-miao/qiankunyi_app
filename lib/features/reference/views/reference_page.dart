/// 参考资料页面
/// 展示六十四卦（八宫分组）、纳音、星宿等参考信息
library;

import 'package:flutter/material.dart';
import '../data/reference_data.dart';
import '../data/xiangyi_data.dart';
import '../data/qinxing_data.dart';
import '../data/shensha_dictionary.dart';

class ReferencePage extends StatelessWidget {
  const ReferencePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 6,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('参考资料'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: '六十四卦'),
              Tab(text: '纳音'),
              Tab(text: '二十八星宿'),
              Tab(text: '象意字典'),
              Tab(text: '禽星关系'),
              Tab(text: '神煞象义'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _GuaCiTab(),
            _NaYinTab(),
            _XingXiuTab(),
            _XiangYiTab(),
            _QinXingTab(),
            _ShenShaTab(),
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

// ──────────── 象意字典 Tab ────────────

/// 八卦万物类象字典
class _XiangYiTab extends StatefulWidget {
  const _XiangYiTab();
  @override
  State<_XiangYiTab> createState() => _XiangYiTabState();
}

class _XiangYiTabState extends State<_XiangYiTab> {
  String _selectedGua = '乾';
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final guaNames = baguaXiangYi.keys.toList();
    final categories = baguaXiangYi[_selectedGua]!.keys.toList();

    return Column(
      children: [
        // 八卦选择器
        SizedBox(
          height: 48,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            children: guaNames.map((name) {
              final sel = name == _selectedGua;
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: FilterChip(
                  label: Text(name, style: TextStyle(fontSize: 15, fontWeight: sel ? FontWeight.bold : FontWeight.normal)),
                  selected: sel,
                  onSelected: (_) => setState(() { _selectedGua = name; _selectedCategory = null; }),
                ),
              );
            }).toList(),
          ),
        ),
        const Divider(height: 1),
        // 分类选择器
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            children: categories.map((cat) {
              final sel = cat == _selectedCategory;
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: ChoiceChip(
                  label: Text(cat, style: TextStyle(fontSize: 13, fontWeight: sel ? FontWeight.bold : FontWeight.normal)),
                  selected: sel,
                  onSelected: (_) => setState(() => _selectedCategory = sel ? null : cat),
                ),
              );
            }).toList(),
          ),
        ),
        // 内容
        Expanded(
          child: _selectedCategory == null
              ? _buildAllCategories(theme, guaNames)
              : _buildCategoryDetail(theme, _selectedCategory!),
        ),
      ],
    );
  }

  Widget _buildAllCategories(ThemeData theme, List<String> guaNames) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: guaNames.map((guaName) {
        final data = baguaXiangYi[guaName]!;
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(guaName, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
                const Divider(),
                ...data.entries.map((e) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text('${e.key}: ', style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurfaceVariant)),
                      ...e.value.map((v) => Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: Chip(label: Text(v, style: const TextStyle(fontSize: 12)), materialTapTargetSize: MaterialTapTargetSize.shrinkWrap, visualDensity: VisualDensity.compact),
                      )),
                    ],
                  ),
                )),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCategoryDetail(ThemeData theme, String category) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: baguaXiangYi.entries.map((e) {
        final items = e.value[category];
        if (items == null || items.isEmpty) return const SizedBox.shrink();
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Text(e.key, style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onPrimaryContainer)),
            ),
            title: Text(category),
            subtitle: Text(items.join('、')),
          ),
        );
      }).toList(),
    );
  }
}

// ──────────── 禽星关系 Tab ────────────

/// 二十八宿禽星关系面板
class _QinXingTab extends StatelessWidget {
  const _QinXingTab();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final groups = ['东', '南', '西', '北'];
    final groupColors = <String, Color>{
      '东': Colors.green, '南': Colors.red, '西': Colors.orange, '北': Colors.blue,
    };

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        // 图例
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('禽星关系说明', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                _legendRow(theme, '冲', '对立相冲', Colors.red.shade100, Colors.red.shade800),
                _legendRow(theme, '合', '和谐相合', Colors.green.shade100, Colors.green.shade800),
                _legendRow(theme, '爱', '亲爱相生', Colors.blue.shade100, Colors.blue.shade800),
                _legendRow(theme, '畏', '畏惧相克', Colors.orange.shade100, Colors.orange.shade800),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        // 四组展示
        ...groups.map((g) => _buildGroup(theme, g, groupColors[g]!)),
      ],
    );
  }

  Widget _legendRow(ThemeData theme, String label, String desc, Color bg, Color fg) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
            child: Text(label, style: TextStyle(fontSize: 12, color: fg, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 8),
          Text(desc, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }

  Widget _buildGroup(ThemeData theme, String group, Color color) {
    final stars = qinXingList.where((x) => x.group == group).toList();
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Text('${group}方 ${group == '东' ? '青龙' : group == '南' ? '朱雀' : group == '西' ? '白虎' : '玄武'}七宿',
                  style: TextStyle(fontWeight: FontWeight.bold, color: color)),
              ],
            ),
          ),
          ...stars.map((x) => _buildStarCard(theme, x)),
        ],
      ),
    );
  }

  Widget _buildStarCard(ThemeData theme, QinXingInfo star) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        leading: CircleAvatar(
          radius: 18,
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Text(star.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: theme.colorScheme.onPrimaryContainer)),
        ),
        title: Text('${star.name}宿 · ${star.animal}'),
        subtitle: Text('五行${star.element}'),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (star.chong != null)
                  _relChip(theme, '冲', star.chong!, Colors.red.shade100, Colors.red.shade800),
                if (star.he != null)
                  _relChip(theme, '合', star.he!, Colors.green.shade100, Colors.green.shade800),
                if (star.ai.isNotEmpty)
                  _relChip(theme, '爱', star.ai.join('、'), Colors.blue.shade100, Colors.blue.shade800),
                if (star.wei.isNotEmpty)
                  _relChip(theme, '畏', star.wei.join('、'), Colors.orange.shade100, Colors.orange.shade800),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _relChip(ThemeData theme, String label, String value, Color bg, Color fg) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
            child: Text(label, style: TextStyle(fontSize: 12, color: fg, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 8),
          Text(value, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}

// ──────────── 神煞象义 Tab ────────────

/// 神煞象义词典
class _ShenShaTab extends StatefulWidget {
  const _ShenShaTab();
  @override
  State<_ShenShaTab> createState() => _ShenShaTabState();
}

class _ShenShaTabState extends State<_ShenShaTab> {
  String _filterType = '全部';
  String? _selectedName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final types = ['全部', '吉', '凶', '平'];
    var list = shenShaDictionary;
    if (_filterType != '全部') {
      list = list.where((s) => s.type == _filterType).toList();
    }

    return Column(
      children: [
        // 类型过滤
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            children: types.map((t) => Padding(
              padding: const EdgeInsets.only(right: 6),
              child: ChoiceChip(
                label: Text(t, style: TextStyle(fontSize: 14, fontWeight: _filterType == t ? FontWeight.bold : FontWeight.normal)),
                selected: _filterType == t,
                onSelected: (_) => setState(() => _filterType = t),
              ),
            )).toList(),
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(12),
            children: list.map((s) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ExpansionTile(
                leading: CircleAvatar(
                  radius: 16,
                  backgroundColor: s.type == '吉' ? Colors.green.shade100 : s.type == '凶' ? Colors.red.shade100 : Colors.amber.shade100,
                  child: Text(s.type, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold,
                    color: s.type == '吉' ? Colors.green.shade800 : s.type == '凶' ? Colors.red.shade800 : Colors.amber.shade800)),
                ),
                title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(s.description, style: theme.textTheme.bodySmall),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('分类：${s.category}', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                        if (s.dayZhi != null) Text('条件：${s.dayZhi}', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                        if (s.useCase != null) Text('适用：${s.useCase}', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                        const SizedBox(height: 8),
                        ...s.details.map((d) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('• ', style: TextStyle(color: theme.colorScheme.primary)),
                              Expanded(child: Text(d, style: theme.textTheme.bodySmall)),
                            ],
                          ),
                        )),
                      ],
                    ),
                  ),
                ],
              ),
            )).toList(),
          ),
        ),
      ],
    );
  }