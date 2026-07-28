/// 卦例管理页面
/// 展示已保存的卦例列表，支持搜索、删除和详情查看
library;

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/logger.dart';
import '../providers/case_provider.dart';
import '../models/case_models.dart';
import '../../paipan/models/paipan_result.dart';
import '../../paipan/models/gua_model.dart';
import '../../paipan/models/yao_model.dart';
import '../../paipan/views/gua_widget.dart';

class CasePage extends StatefulWidget {
  const CasePage({super.key});

  @override
  State<CasePage> createState() => _CasePageState();
}

class _CasePageState extends State<CasePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CaseProvider>().loadCases();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('卦例库'),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download_outlined),
            tooltip: '导出卦例',
            onPressed: () => _exportCases(context),
          ),
          IconButton(
            icon: const Icon(Icons.file_upload_outlined),
            tooltip: '导入卦例',
            onPressed: () => _importCases(context),
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearch(context),
          ),
        ],
      ),
      body: Consumer<CaseProvider>(
        builder: (ctx, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          final cases = provider.cases;
          if (cases.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bookmark_border, size: 64, color: theme.colorScheme.onSurfaceVariant),
                  const SizedBox(height: 16),
                  Text('暂无卦例', style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                  const SizedBox(height: 8),
                  Text('排盘后可将结果保存为卦例', style: theme.textTheme.bodySmall),
                ],
              ),
            );
          }
          return Column(
            children: [
              _buildStatsCard(provider.allCases, theme),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                  itemCount: cases.length,
                  separatorBuilder: (_, __) => const Divider(height: 4),
                  itemBuilder: (ctx, i) => _buildCaseCard(ctx, cases[i], theme),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCaseCard(BuildContext context, CaseModel c, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    final t = isDark ? const Color(0xFFE0D5C8) : const Color(0xFF4A3728);
    final ago = _timeAgo(c.createdAt);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showCaseDetail(context, c),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withAlpha(25),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: theme.colorScheme.primary.withAlpha(60)),
                    ),
                    child: Text(_displayGuaName(c.guaName),
                        style: TextStyle(fontWeight: FontWeight.bold,
                            fontSize: 13, color: theme.colorScheme.primary)),
                  ),
                  const SizedBox(width: 8),
                  Text(c.guaGong,
                      style: TextStyle(fontSize: 11, color: t.withAlpha(180))),
                  const Spacer(),
                  Icon(Icons.access_time, size: 12, color: t.withAlpha(120)),
                  const SizedBox(width: 4),
                  Text(ago,
                      style: TextStyle(fontSize: 11, color: t.withAlpha(120))),
                ],
              ),
              const SizedBox(height: 10),
              Text(c.title,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: t)),
              if (c.notes != null && c.notes!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(c.notes!, maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: t.withAlpha(160))),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  _chip(theme, methodToCN(c.method)),
                  if (c.tags.isNotEmpty)
                    ...c.tags.map((tag) => _chip(theme, tag)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip(ThemeData theme, String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(label,
            style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurfaceVariant)),
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return '刚刚';
    if (diff.inMinutes < 60) return '${diff.inMinutes}分钟前';
    if (diff.inHours < 24) return '${diff.inHours}小时前';
    if (diff.inDays < 7) return '${diff.inDays}天前';
    return '${dt.month}/${dt.day}';
  }

  void _showSearch(BuildContext context) {
    final provider = context.read<CaseProvider>();
    showDialog(
      context: context,
      builder: (ctx) {
        final ctrl = TextEditingController(text: provider.searchQuery);
        return AlertDialog(
          title: const Text('搜索卦例'),
          content: TextField(
            controller: ctrl,
            autofocus: true,
            decoration: const InputDecoration(hintText: '标题/卦名/备注/标签', prefixIcon: Icon(Icons.search)),
            onChanged: (v) => provider.setSearchQuery(v),
          ),
          actions: [
            TextButton(onPressed: () {
              ctrl.clear();
              provider.setSearchQuery('');
              Navigator.pop(ctx);
            }, child: const Text('清除')),
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('关闭')),
          ],
        );
      },
    );
  }

  /// 导出卦例（全部 → JSON → 剪贴板）
  void _exportCases(BuildContext context) {
    final provider = context.read<CaseProvider>();
    final all = provider.allCases;
    if (all.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('暂无卦例可导出')),
      );
      return;
    }
    final jsonStr = const JsonEncoder.withIndent('  ').convert(all.map((c) => c.toMap()).toList());
    Clipboard.setData(ClipboardData(text: jsonStr));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('已导出 ${all.length} 条卦例到剪贴板'), duration: const Duration(seconds: 2)),
    );
    Logger.instance.info('卦例导出', '共 $all.length 条');
  }

  /// 导入卦例（从剪贴板 JSON 合并）
  void _importCases(BuildContext context) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('导入卦例'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('请粘贴卦例 JSON（已复制到剪贴板可直接粘贴）',
                  style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withAlpha(180))),
              const SizedBox(height: 8),
              TextField(
                controller: ctrl,
                maxLines: 6,
                decoration: const InputDecoration(
                  hintText: '在此粘贴 JSON…',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          FilledButton(onPressed: () async {
            final text = ctrl.text.trim();
            if (text.isEmpty) return;
            try {
              final parsed = jsonDecode(text);
              final list = (parsed as List).map((e) =>
                  CaseModel.fromMap(e as Map<String, dynamic>)).toList();
              final provider = context.read<CaseProvider>();
              for (final c in list) {
                // 避免重复（按 id 去重）
                final exists = provider.allCases.any((e) => e.id == c.id);
                if (!exists) {
                  provider.addCase(c);
                }
              }
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('成功导入 ${list.length} 条卦例')),
              );
              Logger.instance.info('卦例导入', '导入 ${list.length} 条');
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('导入失败: $e'), backgroundColor: Colors.red.shade300),
              );
            }
          }, child: const Text('导入')),
        ],
      ),
    );
  }

  void _showCaseDetail(BuildContext context, CaseModel c) {
    PaipanResult? result;
    try {
      result = PaipanResult.fromJson(jsonDecode(c.paipanData) as Map<String, dynamic>);
    } catch (_) {}

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final t = isDark ? const Color(0xFFE0D5C8) : const Color(0xFF4A3728);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF1A1A2E) : const Color(0xFFF5F0EB),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.4,
        expand: false,
        builder: (_, scrollCtrl) => SingleChildScrollView(
          controller: scrollCtrl,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(children: [
                Expanded(
                  child: Text(c.title,
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: t)),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20),
                  onPressed: () {
                    context.read<CaseProvider>().deleteCase(c.id!);
                    Navigator.pop(ctx);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 20),
                  onPressed: () {
                    Navigator.pop(ctx);
                    _showEditDialog(context, c);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ]),
              const SizedBox(height: 4),
              Row(children: [
                _infoTag(_displayGuaName(c.guaName), Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                _infoTag(c.guaGong, t.withAlpha(180)),
                const Spacer(),
                Text('${methodToCN(c.method)} · ${c.createdAt.month}/${c.createdAt.day}',
                    style: TextStyle(fontSize: 12, color: t.withAlpha(120))),
              ]),
              if (c.notes != null && c.notes!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF2C2C2C) : Colors.white.withAlpha(200),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(c.notes!,
                      style: TextStyle(fontSize: 13, color: t)),
                ),
              ] else ...[
                const SizedBox(height: 8),
                Text('暂无备注', style: TextStyle(fontSize: 12, color: t.withAlpha(100))),
              ],
              // 月令/日令/空亡
              if (result != null && (result.monthGanZhi != null || result.dayGanZhi != null)) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withAlpha(12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Theme.of(context).colorScheme.primary.withAlpha(30)),
                  ),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      if (result.monthGanZhi != null)
                        _detailInfoTag('月', result.monthGanZhi!, t),
                      if (result.dayGanZhi != null)
                        _detailInfoTag('日', result.dayGanZhi!, t),
                      if (result.kongWang != null && result.kongWang!.isNotEmpty)
                        _detailInfoTag('空', '旬空: ${result.kongWang!.join(" ")}', t),
                      _detailInfoTag('派',
                          result.school == LiuyaoSchool.jingFangJianBan ? '京房简版' : '京房正宗', t),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),
              // 排盘结果
              if (result != null) ...[
                GuaWidget(gua: result.benGua),
                if (result.bianGua != null) ...[
                  const SizedBox(height: 12),
                  Text('变卦', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: t)),
                  const SizedBox(height: 6),
                  GuaWidget(gua: result.bianGua!, showFooter: false),
                ],
                if (result.huGua != null) ...[
                  const SizedBox(height: 12),
                  Text('互卦', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: t)),
                  const SizedBox(height: 6),
                  GuaWidget(gua: result.huGua!, showFooter: false),
                ],
                if (result.benGua.yaos.length >= 6) ...[
                  const SizedBox(height: 16),
                  _buildTiYongDetail(result, t, isDark),
                ],
              ],
              // ── 人工断语 ──
              const SizedBox(height: 16),
              _DuanYuEditor(caseModel: c),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Text(text, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w500)),
    );
  }

  /// 兼容旧数据：GuaName 枚举名 → 中文卦名
  static const _enumNameToGuaCN = <String, String>{
    'qian': '乾为天', 'kun': '坤为地', 'zhun': '水雷屯',
    'meng': '山水蒙', 'xu': '水天需', 'song': '天水讼',
    'shi': '地水师', 'bi': '水地比', 'xiaoXu': '风天小畜',
    'lv': '天泽履', 'tai': '地天泰', 'pi': '天地否',
    'tongRen': '天火同人', 'daYou': '火天大有', 'qian2': '地山谦',
    'yu': '雷地豫', 'sui': '泽雷随', 'gu': '山风蛊',
    'lin': '地泽临', 'guan': '风地观', 'shiHe': '火雷噬嗑',
    'bi2': '山火贲', 'bo': '山地剥', 'fu': '地雷复',
    'wuWang': '天雷无妄', 'daXu': '山天大畜', 'yi': '山雷颐',
    'daGuo': '泽风大过', 'kan': '坎为水', 'li': '离为火',
    'xian': '泽山咸', 'heng': '雷风恒', 'dun': '天山遁',
    'daZhuang': '雷天大壮', 'jin': '火地晋', 'mingYi': '地火明夷',
    'jiaRen': '风火家人', 'kui': '火泽睽', 'jian': '水山蹇',
    'jie': '雷水解', 'sun': '山泽损', 'yi2': '风雷益',
    'guai': '泽天夬', 'gou': '天风姤', 'cui': '泽地萃',
    'sheng': '地风升', 'kun2': '泽水困', 'jing': '水风井',
    'ge': '泽火革', 'ding': '火风鼎', 'zhen': '震为雷',
    'gen': '艮为山', 'jian2': '风山渐', 'guiMei': '雷泽归妹',
    'feng': '雷火丰', 'lv2': '火山旅', 'xun': '巽为风',
    'dui': '兑为泽', 'huan': '风水涣', 'jie2': '水泽节',
    'zhongFu': '风泽中孚', 'xiaoGuo': '雷山小过', 'jiJi': '水火既济',
    'weiJi': '火水未济',
  };

  /// 显示卦名（兼容新旧数据）
  String _displayGuaName(String name) {
    // 新格式已经是中文
    if (name.contains(RegExp(r'[\u4e00-\u9fff]'))) return name;
    // 旧格式是枚举名 → 映射中文
    return _enumNameToGuaCN[name] ?? name;
  }

  /// 详情页小标签（月令/日令/空亡）
  Widget _detailInfoTag(String icon, String text, Color t) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: t.withAlpha(15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: t.withAlpha(25)),
      ),
      child: Text('$icon $text',
          style: TextStyle(fontSize: 11, color: t.withAlpha(200))),
    );
  }

  Widget _buildTiYongDetail(PaipanResult result, Color t, bool isDark) {
    // 简版体用生克
    final tiYao = result.benGua.yaos[result.benGua.shiYaoIndex];
    final tiWx = result.benGua.wuXing;
    final yongWx = _diZhiWuXing(tiYao.diZhi);
    final relation = _shengKeRelation(tiWx, yongWx);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2C) : Colors.white.withAlpha(200),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isDark ? const Color(0xFF444444) : const Color(0xFFE0D5C8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('体用生克', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: t)),
          const SizedBox(height: 8),
          Text(relation, style: TextStyle(fontSize: 13, color: t)),
        ],
      ),
    );
  }

  WuXing _diZhiWuXing(DiZhi? dz) {
    switch (dz) {
      case DiZhi.zi: return WuXing.shui;
      case DiZhi.chou: return WuXing.tu;
      case DiZhi.yin: return WuXing.mu;
      case DiZhi.mao: return WuXing.mu;
      case DiZhi.chen: return WuXing.tu;
      case DiZhi.si: return WuXing.huo;
      case DiZhi.wu: return WuXing.huo;
      case DiZhi.wei: return WuXing.tu;
      case DiZhi.shen: return WuXing.jin;
      case DiZhi.you: return WuXing.jin;
      case DiZhi.xu: return WuXing.tu;
      case DiZhi.hai: return WuXing.shui;
      default: return WuXing.tu;
    }
  }

  final _wxCN = <WuXing, String>{WuXing.jin: '金', WuXing.mu: '木', WuXing.shui: '水', WuXing.huo: '火', WuXing.tu: '土'};

  String _shengKeRelation(WuXing a, WuXing b) {
    if (a == b) return '体用同五行（$_wxCN[a]），比和，吉。';
    // 生克关系简化：生我者吉，我生者泄，克我者凶，我克者耗
    final sheng = <WuXing, WuXing>{
      WuXing.mu: WuXing.huo, WuXing.huo: WuXing.tu,
      WuXing.tu: WuXing.jin, WuXing.jin: WuXing.shui, WuXing.shui: WuXing.mu,
    };
    final ke = <WuXing, WuXing>{
      WuXing.mu: WuXing.tu, WuXing.tu: WuXing.shui,
      WuXing.shui: WuXing.huo, WuXing.huo: WuXing.jin, WuXing.jin: WuXing.mu,
    };
    if (sheng[a] == b) return '体${_wxCN[a]}生用${_wxCN[b]}，泄气，事有耗散。';
    if (sheng[b] == a) return '用${_wxCN[b]}生体${_wxCN[a]}，吉，有进益之喜。';
    if (ke[a] == b) return '体${_wxCN[a]}克用${_wxCN[b]}，虽胜有劳，事费力。';
    if (ke[b] == a) return '用${_wxCN[b]}克体${_wxCN[a]}，凶，事多阻逆。';
    return '体生用，泄气；用生体，吉。';
  }

  /// 编辑卦例对话框
  void _showEditDialog(BuildContext context, CaseModel c) {
    final titleCtl = TextEditingController(text: c.title);
    final notesCtl = TextEditingController(text: c.notes ?? '');
    final tagCtl = TextEditingController();
    final provider = context.read<CaseProvider>();
    List<String> tags = List.from(c.tags);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setSheetState) {
          return Padding(
            padding: EdgeInsets.fromLTRB(
              20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Text('编辑卦例', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(ctx).colorScheme.primary)),
                  const Spacer(),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                ]),
                const SizedBox(height: 12),
                TextField(
                  controller: titleCtl,
                  decoration: const InputDecoration(labelText: '标题', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: notesCtl,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: '备注', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: tagCtl,
                        decoration: const InputDecoration(labelText: '添加标签', border: OutlineInputBorder()),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: () {
                        final t = tagCtl.text.trim();
                        if (t.isNotEmpty && !tags.contains(t)) {
                          setSheetState(() => tags.add(t));
                          tagCtl.clear();
                        }
                      },
                    ),
                  ],
                ),
                if (tags.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6, runSpacing: 4,
                    children: tags.map((t) => Chip(
                      label: Text(t, style: const TextStyle(fontSize: 12)),
                      deleteIcon: const Icon(Icons.close, size: 16),
                      onDeleted: () => setSheetState(() => tags.remove(t)),
                    )).toList(),
                  ),
                ],
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      final updated = c.copyWith(
                        title: titleCtl.text.trim().isEmpty ? c.title : titleCtl.text.trim(),
                        notes: notesCtl.text.trim().isEmpty ? null : notesCtl.text.trim(),
                        tags: tags,
                      );
                      provider.updateCase(updated);
                      Logger.instance.info('卦例已更新', '${c.title} → ${updated.title}');
                      Navigator.pop(ctx);
                    },
                    child: const Text('保存'),
                  ),
                ),
              ],
            ),
          );
        });
      },
    );
  }

  /// 构建统计摘要卡片
  Widget _buildStatsCard(List<CaseModel> allCases, ThemeData theme) {
    final total = allCases.length;
    if (total == 0) return const SizedBox.shrink();

    // 按方法分组统计
    final methodCounts = <String, int>{};
    final guaCounts = <String, int>{};
    for (final c in allCases) {
      final m = methodToCN(c.method);
      methodCounts[m] = (methodCounts[m] ?? 0) + 1;
      final gn = _displayGuaName(c.guaName);
      guaCounts[gn] = (guaCounts[gn] ?? 0) + 1;
    }
    // 最常出现的卦（top 3）
    final topGua = guaCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top3 = topGua.take(3).toList();

    return Card(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(Icons.analytics_outlined, size: 18, color: theme.colorScheme.primary),
              const SizedBox(width: 6),
              Text('统计概要', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: theme.colorScheme.primary)),
            ]),
            const SizedBox(height: 10),
            Row(
              children: [
                _statItem(theme, '共 $total 例', Icons.bookmark, null),
                const SizedBox(width: 16),
                ...methodCounts.entries.map((e) => Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: _statItem(theme, '${e.value}例', null, e.key),
                )),
              ],
            ),
            if (top3.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('常见卦：', style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant)),
              const SizedBox(height: 4),
              Wrap(
                spacing: 8,
                children: top3.map((e) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondaryContainer.withAlpha(80),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text('${e.key} ×${e.value}', style: TextStyle(fontSize: 11, color: theme.colorScheme.onSecondaryContainer)),
                )).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _statItem(ThemeData theme, String text, IconData? icon, String? label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) Icon(icon, size: 14, color: theme.colorScheme.primary),
        if (label != null) Text(label, style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant)),
        const SizedBox(width: 2),
        Text(text, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface)),
      ],
    );
  }
}

/// 断语编辑器
class _DuanYuEditor extends StatefulWidget {
  final CaseModel caseModel;
  const _DuanYuEditor({required this.caseModel});

  @override
  State<_DuanYuEditor> createState() => _DuanYuEditorState();
}

class _DuanYuEditorState extends State<_DuanYuEditor> {
  late TextEditingController _ctrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.caseModel.duanYu ?? '');
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = theme.colorScheme.primary;
    final isDark = theme.brightness == Brightness.dark;
    final t = isDark ? const Color(0xFFE0D5C8) : const Color(0xFF4A3728);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(Icons.edit_note, size: 18, color: p),
              const SizedBox(width: 6),
              Text('✍️ 人工断语', style: TextStyle(fontSize: 14,
                  fontWeight: FontWeight.bold, color: t)),
              const Spacer(),
              if (_saving)
                const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
              if (!_saving)
                TextButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.save, size: 16),
                  label: const Text('保存', style: TextStyle(fontSize: 13)),
                ),
            ]),
            const SizedBox(height: 8),
            TextField(
              controller: _ctrl,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: '输入你的分析判断…',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _save() async {
    setState(() => _saving = true);
    final updated = widget.caseModel.copyWith(duanYu: _ctrl.text);
    await context.read<CaseProvider>().updateCase(updated);
    setState(() => _saving = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('断语已保存'), duration: Duration(seconds: 2)),
      );
    }
  }
}
