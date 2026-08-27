/// 参考资料页面
/// 展示六十四卦（八宫分组）、纳音、星宿、象意、禽星、神煞、动变等参考信息
library;

import 'package:flutter/material.dart';
import '../data/reference_data.dart';
import '../data/xiangyi_data.dart';
import '../data/qinxing_data.dart';
import '../data/shensha_dictionary.dart';
import '../data/dongbian_dictionary.dart';
import '../data/yaoci_data.dart';
import '../data/meihua_data.dart';
import '../data/liuyao_reference_data.dart';
import '../data/bazi_reference_data.dart';
import '../../paipan/models/gua_model.dart';
import '../../cases/models/case_models.dart';

// ─── 六爻阴阳模式 ───
// 正确推导：每卦6条爻的阴阳由上下卦的三爻模式决定。
// 八卦模式（从初爻到三爻，1=阳 0=阴）：
const _trigramPatterns = [
  [1, 1, 1], // 0 乾
  [1, 1, 0], // 1 兑
  [1, 0, 1], // 2 离
  [1, 0, 0], // 3 震
  [0, 1, 1], // 4 巽
  [0, 1, 0], // 5 坎
  [0, 0, 1], // 6 艮
  [0, 0, 0], // 7 坤
];

// 正确六十四卦表 [下卦索引][上卦索引] → GuaName
const _guaNameTable = <int, List<GuaName>>{
  0: [GuaName.qian, GuaName.guai, GuaName.daYou, GuaName.daZhuang, GuaName.xiaoXu, GuaName.xu, GuaName.daXu, GuaName.tai],
  1: [GuaName.lv, GuaName.dui, GuaName.kui, GuaName.guiMei, GuaName.zhongFu, GuaName.jie2, GuaName.sun, GuaName.lin],
  2: [GuaName.tongRen, GuaName.ge, GuaName.li, GuaName.feng, GuaName.jiaRen, GuaName.jiJi, GuaName.bi2, GuaName.mingYi],
  3: [GuaName.wuWang, GuaName.sui, GuaName.shiHe, GuaName.zhen, GuaName.yi2, GuaName.zhun, GuaName.yi, GuaName.fu],
  4: [GuaName.gou, GuaName.daGuo, GuaName.ding, GuaName.heng, GuaName.xun, GuaName.jing, GuaName.gu, GuaName.sheng],
  5: [GuaName.song, GuaName.kun2, GuaName.weiJi, GuaName.jie, GuaName.huan, GuaName.kan, GuaName.meng, GuaName.shi],
  6: [GuaName.dun, GuaName.xian, GuaName.lv2, GuaName.xiaoGuo, GuaName.jian2, GuaName.jian, GuaName.gen, GuaName.qian2],
  7: [GuaName.pi, GuaName.cui, GuaName.jin, GuaName.yu, GuaName.guan, GuaName.bi, GuaName.bo, GuaName.kun],
};

/// 卦名 → 6条爻的阴阳序列（true=阳/九，false=阴/六）
final Map<GuaName, List<bool>> _guaYaoPatterns = () {
  final map = <GuaName, List<bool>>{};
  for (int lo = 0; lo < 8; lo++) {
    final lowerPat = _trigramPatterns[lo];
    for (int up = 0; up < 8; up++) {
      final upperPat = _trigramPatterns[up];
      final name = _guaNameTable[lo]![up];
      // 六爻：初爻(下卦初)→三爻(下卦上) + 四爻(上卦初)→上爻(上卦上)
      final lines = [
        lowerPat[0] == 1, lowerPat[1] == 1, lowerPat[2] == 1,
        upperPat[0] == 1, upperPat[1] == 1, upperPat[2] == 1,
      ];
      map[name] = lines;
    }
  }
  return map;
}();

class ReferencePage extends StatelessWidget {
  const ReferencePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DefaultTabController(
      length: 10,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('参考资料'),
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelColor: theme.colorScheme.primary,
            unselectedLabelColor: null,
            indicatorColor: theme.colorScheme.primary,
            tabs: const [
              Tab(text: '六十四卦'),
              Tab(text: '纳音'),
              Tab(text: '二十八星宿'),
              Tab(text: '象意字典'),
              Tab(text: '禽星关系'),
              Tab(text: '神煞象义'),
              Tab(text: '动变含义'),
              Tab(text: '梅花易数'),
              Tab(text: '六爻纳甲'),
              Tab(text: '八字'),
            ],
          ),
        ),
        body: LayoutBuilder(
          builder: (ctx, constraints) {
            final content = const TabBarView(
              children: [
                _GuaCiTab(),
                _NaYinTab(),
                _XingXiuTab(),
                _XiangYiTab(),
                _QinXingTab(),
                _ShenShaTab(),
                _DongBianTab(),
                _MeiHuaTab(),
                _LiuYaoRefTab(),
                _BaziRefTab(),
              ],
            );
            if (constraints.maxWidth > 1100) {
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1000),
                  child: content,
                ),
              );
            }
            return content;
          },
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

class _GuaCiTabState extends State<_GuaCiTab> {
  final _gongNames = ['乾宫', '兑宫', '离宫', '震宫', '巽宫', '坎宫', '艮宫', '坤宫'];
  String _selectedGong = '乾宫';
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  /// 获取当前宫卦列表；搜索时全范围（8 宫全部 64 卦）过滤
  List<GuaCi> get _filteredGua {
    if (_searchQuery.isEmpty) return baguaGong[_selectedGong] ?? [];
    final result = <GuaCi>[];
    for (final gong in baguaGong.values) {
      for (final g in gong) {
        final cn = guaNameCN[g.name] ?? g.name.name;
        if (cn.contains(_searchQuery) || g.name.name.contains(_searchQuery)) {
          result.add(g);
        }
      }
    }
    return result;
  }

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
    final filtered = _filteredGua;

    return Column(
      children: [
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
                  label: Text(gong, style: TextStyle(
                    fontSize: 13,
                    fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                    color: selected ? _gongColor(gong) : null,
                  )),
                  selected: selected,
                  selectedColor: _gongColor(gong).withAlpha(40),
                  backgroundColor: theme.colorScheme.surface,
                  checkmarkColor: _gongColor(gong),
                  side: BorderSide(color: selected ? _gongColor(gong) : theme.colorScheme.outlineVariant, width: selected ? 1.5 : 1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  onSelected: (_) => setState(() => _selectedGong = gong),
                ),
              );
            }).toList(),
          ),
        ),
        // 搜索框
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: TextField(
            controller: _searchCtrl,
            decoration: InputDecoration(
              hintText: '搜索卦名…',
              prefixIcon: const Icon(Icons.search, size: 18),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 16),
                      onPressed: () {
                        _searchCtrl.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              isDense: true,
            ),
            onChanged: (v) => setState(() => _searchQuery = v),
          ),
        ),
        Expanded(
          child: filtered.isEmpty
              ? Center(child: Text('未找到匹配的卦', style: TextStyle(color: theme.colorScheme.onSurfaceVariant)))
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const Divider(height: 4),
                  itemBuilder: (ctx, i) => _buildGuaCard(context, theme, filtered[i], i),
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
              width: 36, height: 36,
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
                // ── 爻辞 ──
                if (yaoCiMap.containsKey(gc.name))
                  ..._buildYaoCiSection(theme, gc.name),
                if (gc.fangWei.isNotEmpty || gc.shuZi.isNotEmpty || gc.ziRan.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Wrap(
                      spacing: 8, runSpacing: 4,
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
            TextSpan(text: '【$label】', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w600)),
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

  /// 构建爻辞展示区域
  List<Widget> _buildYaoCiSection(ThemeData theme, GuaName name) {
    final yaos = yaoCiMap[name];
    if (yaos == null || yaos.isEmpty) return [];
    final patterns = _guaYaoPatterns[name] ?? [true, true, true, true, true, true];
    return [
      const SizedBox(height: 8),
      const Divider(height: 1),
      const SizedBox(height: 6),
      Text('📜 爻辞', style: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 13,
        color: theme.colorScheme.primary,
      )),
      const SizedBox(height: 4),
      for (int i = 0; i < yaos.length; i++) ...[
        _buildYaoLine(theme, yaos[i], i, patterns[i]),
        if (i < yaos.length - 1) const SizedBox(height: 2),
      ],
    ];
  }

  Widget _buildYaoLine(ThemeData theme, YaoCi yao, int index, bool yang) {
    final pos = yaoPositionName(index, yang);
    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: theme.colorScheme.outlineVariant.withAlpha(80)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            padding: const EdgeInsets.symmetric(vertical: 2),
            decoration: BoxDecoration(
              color: yang ? theme.colorScheme.primary.withAlpha(25) : theme.colorScheme.secondary.withAlpha(25),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(pos, textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.bold,
                color: yang ? theme.colorScheme.primary : theme.colorScheme.secondary,
              )),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(yao.text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                if (yao.explanation.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(yao.explanation,
                      style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withAlpha(160))),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
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
        Card(
          color: theme.colorScheme.primaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: theme.colorScheme.onPrimaryContainer),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text('纳音释义',
                        style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onPrimaryContainer)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '纳音五行将六十甲子分为三十组，每组以其意象配属五行。'
                  '点击每条可查看详细释义，了解该纳音的命理象征含义。',
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onPrimaryContainer.withAlpha(200)),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        for (final wx in wxOrder)
          if (grouped.containsKey(wx)) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(color: _wxColor2(wx), borderRadius: BorderRadius.circular(12)),
                    child: Text('$wx 行', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                  const SizedBox(width: 8),
                  Text('${grouped[wx]!.length}组', style: theme.textTheme.bodySmall),
                ],
              ),
            ),
            ...grouped[wx]!.map((e) => Card(
              child: ExpansionTile(
                dense: true,
                tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
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
                children: [
                  Text(e.description.isNotEmpty ? e.description : '暂无详细解释',
                      style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurface.withAlpha(180))),
                ],
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
                  child: Text('二十八星宿是中国古代天文学划分星空的区域，分东、南、西、北四象，每象七宿。',
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onPrimaryContainer)),
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
                  decoration: BoxDecoration(color: _dirColor(dir), borderRadius: BorderRadius.circular(12)),
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

/// ──────────────── 象意字典 Tab ────────────────

class _XiangYiTab extends StatefulWidget {
  const _XiangYiTab();
  @override
  State<_XiangYiTab> createState() => _XiangYiTabState();
}

class _XiangYiTabState extends State<_XiangYiTab> {
  final String _selectedGua = '乾';
  String? _selectedCategory;

  static const _guaSymbols = {'乾': '☰', '兑': '☱', '离': '☲', '震': '☳',
                               '巽': '☴', '坎': '☵', '艮': '☶', '坤': '☷'};

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = theme.colorScheme.primary;
    final t = theme.colorScheme.onSurface;
    final guaNames = baguaXiangYi.keys.toList();
    final categories = baguaXiangYi[_selectedGua]!.keys.toList();

    return Column(
      children: [
        // ── 分类快捷筛选（轻量标签） ──
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            children: [
              // "全部" 标签
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => setState(() => _selectedCategory = null),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: _selectedCategory == null ? p.withAlpha(20) : t.withAlpha(10),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _selectedCategory == null ? p.withAlpha(100) : t.withAlpha(30)),
                    ),
                    child: Text('全部', style: TextStyle(
                      fontSize: 13,
                      fontWeight: _selectedCategory == null ? FontWeight.bold : FontWeight.normal,
                      color: _selectedCategory == null ? p : t.withAlpha(140),
                    )),
                  ),
                ),
              ),
              ...categories.map((cat) {
                final sel = cat == _selectedCategory;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () => setState(() => _selectedCategory = sel ? null : cat),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: sel ? p.withAlpha(20) : t.withAlpha(10),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: sel ? p.withAlpha(100) : t.withAlpha(30)),
                      ),
                      child: Text(cat, style: TextStyle(
                        fontSize: 13,
                        fontWeight: sel ? FontWeight.bold : FontWeight.normal,
                        color: sel ? p : t.withAlpha(140),
                      )),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),

        // ── 内容区域 ──
        Expanded(
          child: _selectedCategory == null
              ? _buildAllCategories(theme, guaNames)
              : _buildCategoryDetail(theme, _selectedCategory!),
        ),
      ],
    );
  }

  Widget _buildAllCategories(ThemeData theme, List<String> guaNames) {
    final p = theme.colorScheme.primary;
    final t = theme.colorScheme.onSurface;
    return ListView(
      padding: const EdgeInsets.all(12),
      children: guaNames.map((guaName) {
        final data = baguaXiangYi[guaName]!;
        final sym = _guaSymbols[guaName] ?? '';
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: t.withAlpha(15)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: p.withAlpha(20),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text('$sym $guaName',
                        style: TextStyle(fontWeight: FontWeight.bold,
                            fontSize: 16, color: p)),
                  ),
                ]),
                const SizedBox(height: 8),
                ...data.entries.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(e.key, style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: p.withAlpha(200),
                      )),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: e.value.map((v) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: t.withAlpha(8),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: t.withAlpha(20)),
                          ),
                          child: Text(v, style: TextStyle(fontSize: 12, color: t.withAlpha(200))),
                        )).toList(),
                      ),
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
    final p = theme.colorScheme.primary;
    final t = theme.colorScheme.onSurface;
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Card(
          color: p.withAlpha(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(children: [
              Icon(Icons.filter_alt_outlined, size: 18, color: p),
              const SizedBox(width: 8),
              Text('分类：', style: TextStyle(fontSize: 13, color: t.withAlpha(160))),
              Text(category, style: TextStyle(fontSize: 14,
                  fontWeight: FontWeight.bold, color: p)),
            ]),
          ),
        ),
        const SizedBox(height: 8),
        ...baguaXiangYi.entries.map((e) {
          final items = e.value[category];
          if (items == null || items.isEmpty) return const SizedBox.shrink();
          final sym = _guaSymbols[e.key] ?? '';
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(color: t.withAlpha(15)),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: p.withAlpha(20),
                child: Text(sym, style: TextStyle(fontWeight: FontWeight.bold,
                    fontSize: 16, color: p)),
              ),
              title: Text('${e.key} · $category',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: t.withAlpha(220))),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(items.join('、'),
                    style: TextStyle(fontSize: 12, color: t.withAlpha(160))),
              ),
            ),
          );
        }),
      ],
    );
  }
}

/// ──────────────── 禽星关系 Tab ────────────────

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
              color: color.withAlpha(38),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Text('$group方 ${group == '东' ? '青龙' : group == '南' ? '朱雀' : group == '西' ? '白虎' : '玄武'}七宿',
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
                if (star.chong != null) _relChip(theme, '冲', star.chong!, Colors.red.shade100, Colors.red.shade800),
                if (star.he != null) _relChip(theme, '合', star.he!, Colors.green.shade100, Colors.green.shade800),
                if (star.ai.isNotEmpty) _relChip(theme, '爱', star.ai.join('、'), Colors.blue.shade100, Colors.blue.shade800),
                if (star.wei.isNotEmpty) _relChip(theme, '畏', star.wei.join('、'), Colors.orange.shade100, Colors.orange.shade800),
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

/// ──────────────── 神煞象义 Tab ────────────────

class _ShenShaTab extends StatefulWidget {
  const _ShenShaTab();
  @override
  State<_ShenShaTab> createState() => _ShenShaTabState();
}

class _ShenShaTabState extends State<_ShenShaTab> {
  String _filterType = '全部';

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
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            children: types.map((t) => Padding(
              padding: const EdgeInsets.only(right: 6),
              child: ChoiceChip(
                label: Text(t, style: TextStyle(
                  fontSize: 14,
                  fontWeight: _filterType == t ? FontWeight.bold : FontWeight.normal,
                  color: _filterType == t ? theme.colorScheme.primary : null,
                )),
                selected: _filterType == t,
                selectedColor: theme.colorScheme.primary.withAlpha(30),
                backgroundColor: theme.colorScheme.surface,
                side: BorderSide(color: _filterType == t ? theme.colorScheme.primary : theme.colorScheme.outlineVariant, width: _filterType == t ? 1.5 : 1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
}

/// ──────────────── 六爻纳甲 Tab ────────────────

class _LiuYaoRefTab extends StatelessWidget {
  const _LiuYaoRefTab();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = theme.colorScheme.primary;
    final t = theme.colorScheme.onSurface.withAlpha(200);

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        // 快速入门课程
        _liuyaoCourse,
        _sectionHeader(p, '六神详解'),
        ...liuShenList.map((s) => Card(
          margin: const EdgeInsets.only(bottom: 6),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 4, height: 36,
                  decoration: BoxDecoration(
                    color: Color(int.parse(s.colorHex.replaceFirst('#', '0xFF'))),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Text(s.name, style: TextStyle(fontWeight: FontWeight.bold,
                            fontSize: 15, color: Color(int.parse(s.colorHex.replaceFirst('#', '0xFF'))))),
                        const SizedBox(width: 8),
                        Text('${s.wuXing} · ${s.season}',
                            style: TextStyle(fontSize: 11, color: t.withAlpha(120))),
                      ]),
                      const SizedBox(height: 2),
                      Text(s.meaning, style: TextStyle(fontSize: 12, color: t.withAlpha(180))),
                    ],
                  ),
                ),
              ],
            ),
          ),
        )),
        const SizedBox(height: 12),

        _sectionHeader(p, '六亲含义'),
        ...liuQinMeanings.map((m) => Card(
          margin: const EdgeInsets.only(bottom: 6),
          child: ListTile(
            dense: true,
            leading: CircleAvatar(
              radius: 14,
              backgroundColor: p.withAlpha(20),
              child: Text(m['亲']!, style: TextStyle(fontSize: 12,
                  fontWeight: FontWeight.bold, color: p)),
            ),
            title: Text(m['含义']!, style: TextStyle(fontSize: 13, color: t.withAlpha(220))),
          ),
        )),
        const SizedBox(height: 12),

        _sectionHeader(p, '旬空表'),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Table(
              columnWidths: const {0: FlexColumnWidth(1), 1: FlexColumnWidth(1)},
              children: [
                TableRow(
                  decoration: BoxDecoration(color: p.withAlpha(20)),
                  children: ['甲子旬', '空亡地支'].map((h) =>
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                      child: Text(h, textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.bold,
                              fontSize: 13, color: p)),
                    ),
                  ).toList(),
                ),
                ...xunKongTable.map((e) => TableRow(
                  children: [
                    Padding(padding: const EdgeInsets.all(6),
                        child: Text(e.jiaZi, textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 13, color: t))),
                    Padding(padding: const EdgeInsets.all(6),
                        child: Text(e.kongWang, textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 13, color: t))),
                  ],
                )),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        _sectionHeader(p, '五行旺衰表（月建）'),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Table(
              columnWidths: const {
                0: FlexColumnWidth(2), 1: FlexColumnWidth(1),
                2: FlexColumnWidth(1), 3: FlexColumnWidth(1),
                4: FlexColumnWidth(1), 5: FlexColumnWidth(1),
              },
              children: [
                TableRow(
                  decoration: BoxDecoration(color: p.withAlpha(20)),
                  children: ['月建', '旺', '相', '休', '囚', '死'].map((h) =>
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                      child: Text(h, textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.bold,
                              fontSize: 12, color: p)),
                    ),
                  ).toList(),
                ),
                ...wangShuaiTable.map((row) => TableRow(
                  children: ['月建', '旺', '相', '休', '囚', '死'].map((k) =>
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 2),
                      child: Text(row[k] ?? '', textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12, color: t)),
                    ),
                  ).toList(),
                )),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        _sectionHeader(p, '纳甲表'),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Table(
              columnWidths: const {
                0: FlexColumnWidth(1), 1: FlexColumnWidth(1), 2: FlexColumnWidth(1),
              },
              children: [
                TableRow(
                  decoration: BoxDecoration(color: p.withAlpha(20)),
                  children: ['八卦', '内卦纳甲', '外卦纳甲'].map((h) =>
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                      child: Text(h, textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.bold,
                              fontSize: 13, color: p)),
                    ),
                  ).toList(),
                ),
                ...naJiaTable.map((e) => TableRow(
                  children: [
                    Padding(padding: const EdgeInsets.all(5),
                        child: Text(e.gua, textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 13, color: t))),
                    Padding(padding: const EdgeInsets.all(5),
                        child: Text(e.innerGan, textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 13, color: t))),
                    Padding(padding: const EdgeInsets.all(5),
                        child: Text(e.outerGan, textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 13, color: t))),
                  ],
                )),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _sectionHeader(Color primary, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, top: 4),
      child: Text(title, style: TextStyle(fontSize: 15,
          fontWeight: FontWeight.bold, color: primary)),
    );
  }
}
class _MeiHuaTab extends StatelessWidget {
  const _MeiHuaTab();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = theme.colorScheme.primary;
    final t = theme.colorScheme.onSurface.withAlpha(200);

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        // 快速入门课程
        _meihuaCourse,
        // ── 标题 ──
        Card(
          color: p.withAlpha(15),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              Text('🌸', style: TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('梅花易数', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: p)),
                    const SizedBox(height: 4),
                    Text('宋代邵雍（康节）所创，以数起卦、以象断事',
                        style: TextStyle(fontSize: 12, color: t.withAlpha(180))),
                  ],
                ),
              ),
            ]),
          ),
        ),
        const SizedBox(height: 12),

        // ── 起卦方法 ──
        _sectionHeader(p, '起卦方法'),
        ...qiGuaMethods.map((m) => Card(
          margin: const EdgeInsets.only(bottom: 6),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('• ', style: TextStyle(color: p, fontWeight: FontWeight.bold)),
                Expanded(child: Text(m, style: TextStyle(fontSize: 13, color: t.withAlpha(220)))),
              ],
            ),
          ),
        )),
        const SizedBox(height: 12),

        // ── 体用生克 ──
        _sectionHeader(p, '体用生克'),
        ...tiYongRules.map((r) => Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(r.icon, color: r.color, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(r.name, style: TextStyle(fontWeight: FontWeight.bold,
                          fontSize: 14, color: r.color)),
                      const SizedBox(height: 2),
                      Text(r.description, style: TextStyle(fontSize: 12, color: t.withAlpha(180))),
                      const SizedBox(height: 2),
                      Text('→ ${r.verdict}', style: TextStyle(fontSize: 12,
                          color: r.color.withAlpha(200), fontStyle: FontStyle.italic)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        )),
        const SizedBox(height: 12),

        // ── 八卦五行表 ──
        _sectionHeader(p, '八卦五行属性'),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Table(
              columnWidths: const {0: FlexColumnWidth(1), 1: FlexColumnWidth(1),
                2: FlexColumnWidth(1), 3: FlexColumnWidth(1), 4: FlexColumnWidth(1)},
              children: [
                TableRow(
                  decoration: BoxDecoration(color: p.withAlpha(20)),
                  children: ['卦名', '符号', '五行', '数', '阴阳'].map((h) =>
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                      child: Text(h, textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.bold,
                              fontSize: 13, color: p)),
                    ),
                  ).toList(),
                ),
                ...trigramInfos.map((tr) => TableRow(
                  children: [
                    _cell(tr.name, t),
                    _cell(tr.symbol, t),
                    _cell(tr.wuXing, t),
                    _cell('${tr.number}', t),
                    _cell(tr.yinYang, t),
                  ],
                )),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // ── 五行生克 ──
        _sectionHeader(p, '五行生克'),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('相生：', style: TextStyle(fontWeight: FontWeight.bold,
                    fontSize: 13, color: const Color(0xFF2E7D32))),
                const SizedBox(height: 4),
                Text(wuXingShengKe[0], style: TextStyle(fontSize: 13, color: t.withAlpha(220))),
                const SizedBox(height: 12),
                Text('相克：', style: TextStyle(fontWeight: FontWeight.bold,
                    fontSize: 13, color: const Color(0xFFD32F2F))),
                const SizedBox(height: 4),
                Text(wuXingShengKe[1], style: TextStyle(fontSize: 13, color: t.withAlpha(220))),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // ── 卦气旺衰 ──
        _sectionHeader(p, '卦气旺衰（时令旺相休囚死）'),
        ...guaQiWangShuai.map((s) => Card(
          margin: const EdgeInsets.only(bottom: 6),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Text(s, style: TextStyle(fontSize: 12, color: t.withAlpha(220))),
          ),
        )),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _sectionHeader(Color primary, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, top: 4),
      child: Text(title, style: TextStyle(fontSize: 15,
          fontWeight: FontWeight.bold, color: primary)),
    );
  }

  Widget _cell(String text, Color t) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      child: Text(text, textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: t.withAlpha(220))),
    );
  }
}

/// ──────────────── 动变含义 Tab ────────────────

class _DongBianTab extends StatefulWidget {
  const _DongBianTab();
  @override
  State<_DongBianTab> createState() => _DongBianTabState();
}

class _DongBianTabState extends State<_DongBianTab> {
  String _filterCat = '全部';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cats = ['全部', '基础', '动变关系', '动变趋势', '特殊'];
    var list = dongBianDictionary;
    if (_filterCat != '全部') {
      list = list.where((d) => d.category == _filterCat).toList();
    }

    return Column(
      children: [
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            children: cats.map((c) => Padding(
              padding: const EdgeInsets.only(right: 6),
              child: ChoiceChip(
                label: Text(c, style: TextStyle(
                  fontSize: 14,
                  fontWeight: _filterCat == c ? FontWeight.bold : FontWeight.normal,
                  color: _filterCat == c ? theme.colorScheme.primary : null,
                )),
                selected: _filterCat == c,
                selectedColor: theme.colorScheme.primary.withAlpha(30),
                backgroundColor: theme.colorScheme.surface,
                side: BorderSide(color: _filterCat == c ? theme.colorScheme.primary : theme.colorScheme.outlineVariant, width: _filterCat == c ? 1.5 : 1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                onSelected: (_) => setState(() => _filterCat = c),
              ),
            )).toList(),
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(12),
            children: list.map((d) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ExpansionTile(
                leading: CircleAvatar(
                  radius: 16,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Text(d.category[0], style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: theme.colorScheme.onPrimaryContainer)),
                ),
                title: Text(d.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(d.description, style: theme.textTheme.bodySmall),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: d.details.map((detail) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('• ', style: TextStyle(color: theme.colorScheme.primary)),
                            Expanded(child: Text(detail, style: theme.textTheme.bodySmall)),
                          ],
                        ),
                      )).toList(),
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
}

/// ──────────────── 六爻纳甲 Tab ────────────────
/// ──────────────── 八字参考 Tab ────────────────

class _BaziRefTab extends StatelessWidget {
  const _BaziRefTab();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = theme.colorScheme.primary;
    final t = theme.colorScheme.onSurface.withAlpha(200);

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        // 快速入门课程
        _baziCourse,
        _sectionHeader(p, '八字基础'),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Text('八字命理，又称四柱预测，是以人出生的年、月、日、时四柱（每柱天干地支，共八个字）推算命运。'
                '日柱天干代表"日元"，是命局的核心。五行旺衰、十神生克、格局组合构成论命基础。',
                style: TextStyle(fontSize: 13, color: t.withAlpha(180))),
          ),
        ),
        const SizedBox(height: 12),

        // ── 十天干（含类象） ──
        _sectionHeader(p, '十天干（含类象）'),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Table(
              columnWidths: const {
                0: FlexColumnWidth(1),
                1: FlexColumnWidth(1),
                2: FlexColumnWidth(1),
                3: FlexColumnWidth(2),
              },
              children: [
                TableRow(
                  decoration: BoxDecoration(color: p.withAlpha(20)),
                  children: ['天干', '五行', '阴阳', '类象']
                      .map((h) => _cell(h, p))
                      .toList(),
                ),
                ...tianGanList.map((info) => TableRow(
                      children: [
                        _cell(info.name, t),
                        _cell(info.wuXing, t),
                        _cell(info.yinYang, t),
                        _cell(info.image, t),
                      ],
                    )),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // ── 十二地支（含类象） ──
        _sectionHeader(p, '十二地支（含类象）'),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Table(
              columnWidths: const {
                0: FlexColumnWidth(1),
                1: FlexColumnWidth(1),
                2: FlexColumnWidth(1),
                3: FlexColumnWidth(1),
                4: FlexColumnWidth(1.5),
              },
              children: [
                TableRow(
                  decoration: BoxDecoration(color: p.withAlpha(20)),
                  children: ['地支', '生肖', '五行', '月份', '类象']
                      .map((h) => _cell(h, p))
                      .toList(),
                ),
                ...diZhiList.map((info) => TableRow(
                      children: [
                        _cell(info.name, t),
                        _cell(info.shengXiao, t),
                        _cell(info.wuXing, t),
                        _cell(info.month, t),
                        _cell(info.image, t),
                      ],
                    )),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // ── 十神详解 ──
        _sectionHeader(p, '十神详解（以日干为基准）'),
        ...shiShenList.map((ss) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(ss.name,
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: p)),
                    const SizedBox(height: 4),
                    Text(ss.description,
                        style: TextStyle(fontSize: 12, color: t)),
                    const SizedBox(height: 2),
                    Row(children: [
                      _tag('性质: ${ss.nature}', p, t),
                      const SizedBox(width: 6),
                      _tag('六亲: ${ss.relation}', p, t),
                    ]),
                    const SizedBox(height: 2),
                    Text('类象: ${ss.image}',
                        style: TextStyle(
                            fontSize: 12, color: t.withAlpha(200))),
                  ],
                ),
              ),
            )),
        const SizedBox(height: 12),

        // ── 藏干表 ──
        _sectionHeader(p, '藏干表（地支藏天干）'),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Table(
              columnWidths: const {
                0: FlexColumnWidth(1),
                1: FlexColumnWidth(1.2),
                2: FlexColumnWidth(1.2),
                3: FlexColumnWidth(1.2),
              },
              children: [
                TableRow(
                  decoration: BoxDecoration(color: p.withAlpha(20)),
                  children: ['地支', '本气', '中气', '余气']
                      .map((h) => _cell(h, p))
                      .toList(),
                ),
                ...cangGanList.map((entry) => TableRow(
                      children: [
                        _cell(entry.diZhi, t),
                        _cell(entry.benQi, t),
                        _cell(entry.zhongQi, t),
                        _cell(entry.yuQi, t),
                      ],
                    )),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // ── 五行旺衰 ──
        _sectionHeader(p, '五行旺衰（按月令）'),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Table(
                  columnWidths: const {
                    0: FlexColumnWidth(1),
                    1: FlexColumnWidth(1),
                    2: FlexColumnWidth(3),
                  },
                  children: [
                    TableRow(
                      decoration: BoxDecoration(color: p.withAlpha(20)),
                      children: ['五行', '状态', '含义']
                          .map((h) => _cell(h, p))
                          .toList(),
                    ),
                    ...wuXingWangShuaiTable.map((w) => TableRow(
                          children: [
                            _cell(w.wuXing, t),
                            _cell(w.status, t),
                            _cell(w.meaning, t),
                          ],
                        )),
                  ],
                ),
                const SizedBox(height: 6),
                Text('旺相休囚死：当令者旺，我生者相，生我者休，克我者囚，我克者死',
                    style: TextStyle(
                        fontSize: 11,
                        color: t.withAlpha(160),
                        fontStyle: FontStyle.italic)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _sectionHeader(Color primary, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, top: 4),
      child: Text(title,
          style: TextStyle(
              fontSize: 15, fontWeight: FontWeight.bold, color: primary)),
    );
  }

  Widget _cell(String text, Color t) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      child: Text(text,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: t.withAlpha(220))),
    );
  }

  Widget _tag(String text, Color p, Color t) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: p.withAlpha(15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: p.withAlpha(30)),
      ),
      child: Text(text,
          style: TextStyle(fontSize: 11, color: t.withAlpha(200))),
    );
  }
}

/// 快速入门课程卡片（六爻/梅花/八字入门）
class _CourseCard extends StatelessWidget {
  final String title;
  final String emoji;
  final List<({String t, String d})> sections;
  const _CourseCard({
    required this.title,
    required this.emoji,
    required this.sections,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: scheme.primary.withAlpha(40)),
      ),
      child: ExpansionTile(
        leading: Text(emoji, style: const TextStyle(fontSize: 22)),
        title: Text(title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        subtitle: const Text('快速入门 · 点击展开', style: TextStyle(fontSize: 11)),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: sections.map((s) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.t,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: scheme.primary,
                        )),
                    const SizedBox(height: 3),
                    Text(s.d,
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.6,
                          color: Theme.of(context).colorScheme.onSurface.withAlpha(180),
                        )),
                  ],
                ),
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

/// 六爻快速入门内容
const _liuyaoCourse = _CourseCard(
  title: '六爻占卜 · 快速入门',
  emoji: '🪙',
  sections: [
    (t: '1. 什么是六爻？', d: '六爻用三枚铜钱（或硬币）摇动六次，每次记一爻，自下而上组成一卦。'
        '三次铜钱出现不同组合决定爻的阴阳：三正为老阳（动爻○）、两正一背为少阳（—）、'
        '一正两背为少阴（--）、三背为老阴（动爻×）。'),
    (t: '2. 起卦之后看什么？', d: '排盘会给出本卦、变卦、互卦。有动爻的卦会变成变卦，代表事情的发展变化；'
        '互卦代表事情的过程。卦中有"世爻"和"应爻"，世爻代表自己，应爻代表对方。'),
    (t: '3. 六亲与用神', d: '六亲是卦中五行生克关系：父母、兄弟、子孙、妻财、官鬼。'
        '解卦关键是找"用神"——占财看妻财，占官看官鬼，占父母看父母，占子孙看子孙，占竞争看兄弟。'),
    (t: '4. 旺衰生克断吉凶', d: '先看用神旺衰（得月令、日辰生扶则旺），再看动爻对用神的生克：'
        '用神旺相且受生 → 吉；用神休囚受克 → 凶。再看六神（青龙/朱雀/勾陈/腾蛇/白虎/玄武）辅助判断吉凶方向。'),
  ],
);

/// 梅花易数快速入门内容
const _meihuaCourse = _CourseCard(
  title: '梅花易数 · 快速入门',
  emoji: '🌸',
  sections: [
    (t: '1. 什么是梅花易数？', d: '北宋邵雍所创，用"数"起"象"，以先天八卦数为依据，'
        '随时随地可起卦，是最灵便的占卜法。先天数：乾1兑2离3震4巽5坎6艮7坤8。'),
    (t: '2. 时间起卦', d: '用年月日时取数：年数+月数+日数之和除8取余数为上卦；'
        '再加时辰数除8取余数为下卦；总和除6取余数为动爻（余0取6）。'),
    (t: '3. 体用生克', d: '不动之卦为体卦（代表自己），动爻所在的卦为用卦（代表所问之事）。'
        '体克用吉，用生体吉；体生用为泄气，用克体凶。比和（同五行）为吉。'),
    (t: '4. 万物类象断事', d: '每个卦都有丰富类象：乾为天为君为父为金玉；坤为地为母为柔顺为田土；'
        '八卦类象结合体用生克，把抽象卦象落到具体人事上，再结合时间、方位综合判断。'),
  ],
);

/// 八字快速入门内容
const _baziCourse = _CourseCard(
  title: '八字命理 · 快速入门',
  emoji: '📜',
  sections: [
    (t: '1. 什么是八字？', d: '八字即出生年月日时的四柱干支，每柱一天干一地支，共八个字。'
        '日柱天干代表"日主"（自己），是整个命盘的核心。'),
    (t: '2. 十天干五行', d: '甲乙属木、丙丁属火、戊己属土、庚辛属金、壬癸属水。'
        '五行之间相生：木生火、火生土、土生金、金生水、水生木；相克：木克土、土克水、水克火、火克金、金克木。'),
    (t: '3. 十神关系', d: '以日主为基准，与其它天干的关系生出十神：'
        '生我者为印（正印/偏印），我生者为食伤（食神/伤官），'
        '克我者为官杀（正官/七杀），我克者为财（正财/偏财），同我者为比劫（比肩/劫财）。'),
    (t: '4. 大运与流年', d: '每十年一步大运，记录人生的阶段起伏；每年一柱流年，代表当年的运势。'
        '看大运流年与大运干支对日主的生克，结合五行喜忌判断吉凶。'
        '命理仅供参考，命运掌握在自己手中！'),
  ],
);
