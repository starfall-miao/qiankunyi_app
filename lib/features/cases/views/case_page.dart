/// 卦例管理页面
/// 展示已保存的卦例列表，支持搜索、删除和详情查看
library;

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/logger.dart';
import '../../../core/services/ai_service.dart';
import '../providers/case_provider.dart';
import '../models/case_models.dart';
import '../../paipan/models/paipan_result.dart';
import '../../paipan/models/bazi_models.dart';
import '../../reference/data/bazi_reference_data.dart';
import '../../paipan/models/gua_model.dart';
import '../../paipan/models/yao_model.dart';
import '../../paipan/views/gua_widget.dart';
import '../../settings/settings_provider.dart';

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
    BaziResult? baziResult;
    try {
      result = PaipanResult.fromJson(jsonDecode(c.paipanData) as Map<String, dynamic>);
    } catch (_) {
      try {
        baziResult = BaziResult.fromJson(jsonDecode(c.paipanData) as Map<String, dynamic>);
      } catch (_) {}
    }

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
          initialChildSize: 0.6,
          maxChildSize: 1.0,
          minChildSize: 0.35,
          expand: false,
          shouldCloseOnMinExtent: true,
          builder: (_, scrollCtrl) => SingleChildScrollView(
          controller: scrollCtrl,
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
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
              ] else if (baziResult != null) ...[
                _buildBaziDetail(baziResult, t, isDark, context),
              ],
              // ── 人工断语 ──
              const SizedBox(height: 16),
              _ManualDuanYuEditor(caseModel: c),
              const SizedBox(height: 16),
              // ── AI 解卦 / 追问 ──
              _AiChatSection(caseModel: c),
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

  /// 八字详情展示
  Widget _buildBaziDetail(BaziResult r, Color t, bool isDark, BuildContext ctx) {
    final p = Theme.of(ctx).colorScheme.primary;
    final b = isDark ? const Color(0xFF444444) : const Color(0xFFE0D5C8);
    const wxColors = <String, Color>{
      '木': Color(0xFF4CAF50), '火': Color(0xFFE53935),
      '土': Color(0xFF8D6E63), '金': Color(0xFFFFB300),
      '水': Color(0xFF2196F3),
    };
    const wsColors = <String, Color>{
      '旺': Color(0xFFE53935), '相': Color(0xFFFF9800),
      '休': Color(0xFF9E9E9E), '囚': Color(0xFF6D4C41),
      '死': Color(0xFF424242),
    };

    Widget sectionHeader(String title) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 6, top: 2),
        child: Text(title,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: p)),
      );
    }

    Widget tag(String text, Color accent) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: accent.withAlpha(15),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: accent.withAlpha(40)),
        ),
        child: Text(text,
            style: TextStyle(fontSize: 12, color: t.withAlpha(220))),
      );
    }

    Widget cangGanRow(String label, Map<String, String> cangGan) {
      final items = cangGan.entries
          .where((e) => e.value != '无' && e.value.isNotEmpty)
          .toList();
      return Row(
        children: [
          SizedBox(
            width: 48,
            child: Text(label,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: p)),
          ),
          if (items.isEmpty)
            Expanded(
              child: Text('无',
                  style: TextStyle(fontSize: 12, color: t.withAlpha(120))),
            )
          else
            Expanded(
              child: Row(
                children: items.map((e) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Text('${e.key}:${e.value}',
                        style: TextStyle(fontSize: 12, color: t)),
                  );
                }).toList(),
              ),
            ),
        ],
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2C) : Colors.white.withAlpha(200),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: b),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 标题 ──
          Row(children: [
            Text('八字排盘', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: t)),
            const Spacer(),
            Text(r.isMale ? '乾造' : '坤造',
                style: TextStyle(fontSize: 13,
                    color: p,
                    fontWeight: FontWeight.w500)),
          ]),
          const SizedBox(height: 8),

          // ── 四柱（支持点击天干/地支查看参考资料） ──
          _baziPillarRow('年柱', r.yearZhu, t, ctx),
          const SizedBox(height: 4),
          _baziPillarRow('月柱', r.monthZhu, t, ctx),
          const SizedBox(height: 4),
          _baziPillarRow('日柱', r.dayZhu, t, ctx, isRiZhu: true),
          const SizedBox(height: 4),
          _baziPillarRow('时柱', r.hourZhu, t, ctx),

          // ── 月令/日辰/空亡 ──
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF9F6F2),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: b.withAlpha(50)),
            ),
            child: Row(
              children: [
                _infoTag('月令 ${r.monthZhu.diZhi}', p),
                const SizedBox(width: 6),
                _infoTag('日辰 ${r.dayZhu.diZhi}', Theme.of(ctx).colorScheme.secondary),
                const SizedBox(width: 6),
                _infoTag('旬空 ${_kongWang(r.dayZhu.ganZhi)}', Colors.deepOrange),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ── 五行旺衰 ──
          if (r.wuXingWangShuai.isNotEmpty) ...[
            sectionHeader('五行旺衰'),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: r.wuXingWangShuai.entries.map((e) {
                final wc = wxColors[e.key] ?? t;
                final sc = wsColors[e.value] ?? t;
                return Container(
                  width: 56,
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  decoration: BoxDecoration(
                    color: wc.withAlpha(15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: wc.withAlpha(40)),
                  ),
                  child: Column(
                    children: [
                      Text(e.key,
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold, color: wc)),
                      const SizedBox(height: 2),
                      Text(e.value,
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: sc)),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
          ],

          // ── 五行统计 ──
          if (r.wuXingCounts.isNotEmpty) ...[
            sectionHeader('五行统计'),
            Wrap(spacing: 6, runSpacing: 6,
              children: r.wuXingCounts.entries.map((e) {
                final wc = wxColors[e.key] ?? t;
                return tag('${e.key} ${e.value}', wc);
              }).toList(),
            ),
            const SizedBox(height: 12),
          ],

          // ── 藏干 ──
          sectionHeader('藏干'),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF9F6F2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: b.withAlpha(60)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                cangGanRow('年柱', r.yearZhu.cangGan),
                const Divider(height: 12),
                cangGanRow('月柱', r.monthZhu.cangGan),
                const Divider(height: 12),
                cangGanRow('日柱', r.dayZhu.cangGan),
                const Divider(height: 12),
                cangGanRow('时柱', r.hourZhu.cangGan),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ── 十神 ──
          if (r.shiShenMap.isNotEmpty) ...[
            sectionHeader('十神关系（以日干为基准）'),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF9F6F2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: b.withAlpha(60)),
              ),
              child: Wrap(
                spacing: 6, runSpacing: 6,
                children: r.shiShenMap.entries
                    .where((e) => e.key != '日主')
                    .map((e) {
                  final label = e.key.contains(':')
                      ? '${e.key.split(':')[0]}:${e.key.split(':')[1]}'
                      : e.key;
                  return tag('$label → ${e.value}', p);
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),
          ],

          // ── 大运 ──
          if (r.daYun.isNotEmpty) ...[
            sectionHeader('大运'),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: r.daYun.map((dy) {
                  return Container(
                    width: 68,
                    margin: const EdgeInsets.only(right: 6),
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF9F6F2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: b.withAlpha(60)),
                    ),
                    child: Column(
                      children: [
                        Text('${dy.startAge}岁',
                            style: TextStyle(
                                fontSize: 11, color: t.withAlpha(150))),
                        const SizedBox(height: 2),
                        Text(dy.ganZhi,
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: t)),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),
          ],

          // ── 流年 ──
          if (r.liuNian != null) ...[
            sectionHeader('当年流年'),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF9F6F2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: b.withAlpha(60)),
              ),
              child: Row(children: [
                const Icon(Icons.calendar_month_outlined, size: 18, color: Colors.deepOrange),
                const SizedBox(width: 8),
                Text('流年：', style: TextStyle(fontSize: 13, color: t)),
                Text(r.liuNian!,
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold, color: p)),
              ]),
            ),
          ],
        ],
      ),
    );
  }

  /// 八字单柱行（含点击参考）
  Widget _baziPillarRow(String label, SiZhu p, Color t, BuildContext ctx, {bool isRiZhu = false}) {
    final ganInfo = _findTianGanInfo(p.tianGan);
    final zhiInfo = _findDiZhiInfo(p.diZhi);
    return Row(children: [
      SizedBox(width: 40, child: Text(label,
          style: TextStyle(fontSize: 13,
              fontWeight: isRiZhu ? FontWeight.w800 : FontWeight.w600,
              color: isRiZhu ? Theme.of(ctx).colorScheme.primary : t))),
      const SizedBox(width: 8),
      // 天干（可点击）
      if (p.tianGan.isNotEmpty)
        GestureDetector(
          onTap: () => _showGanZhiRef(ctx, '天干', p.tianGan, ganInfo),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: isRiZhu ? Theme.of(ctx).colorScheme.primary.withAlpha(20) : t.withAlpha(15),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: isRiZhu ? Theme.of(ctx).colorScheme.primary.withAlpha(60) : t.withAlpha(25)),
            ),
            child: Text(p.tianGan,
                style: TextStyle(fontSize: 14, fontWeight: isRiZhu ? FontWeight.bold : FontWeight.normal, color: t)),
          ),
        ),
      if (p.diZhi.isNotEmpty) ...[
        const SizedBox(width: 4),
        // 地支（可点击）
        GestureDetector(
          onTap: () => _showGanZhiRef(ctx, '地支', p.diZhi, zhiInfo),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: t.withAlpha(15),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: t.withAlpha(25)),
            ),
            child: Text(p.diZhi,
                style: TextStyle(fontSize: 14, color: t)),
          ),
        ),
        const SizedBox(width: 4),
        Text(p.ganZhi,
            style: TextStyle(fontSize: 12, color: t.withAlpha(120))),
      ],
    ]);
  }

  /// 查找天干参考信息
  TianGanInfo? _findTianGanInfo(String tg) {
    try {
      return tianGanList.firstWhere((g) => g.name == tg);
    } catch (_) {
      return null;
    }
  }

  /// 查找地支参考信息
  DiZhiInfo? _findDiZhiInfo(String dz) {
    try {
      return diZhiList.firstWhere((z) => z.name == dz);
    } catch (_) {
      return null;
    }
  }

  /// 计算旬空（空亡）based on 日柱干支
  /// 甲子旬戌亥空，甲戌旬申酉空，甲申旬午未空，
  /// 甲午旬辰巳空，甲辰旬寅卯空，甲寅旬子丑空
  String _kongWang(String ganZhi) {
    const xunKong = {
      '甲子': '戌亥', '乙丑': '戌亥', '丙寅': '戌亥', '丁卯': '戌亥', '戊辰': '戌亥', '己巳': '戌亥',
      '庚午': '戌亥', '辛未': '戌亥', '壬申': '戌亥', '癸酉': '戌亥',
      '甲戌': '申酉', '乙亥': '申酉', '丙子': '申酉', '丁丑': '申酉', '戊寅': '申酉', '己卯': '申酉',
      '庚辰': '申酉', '辛巳': '申酉', '壬午': '申酉', '癸未': '申酉',
      '甲申': '午未', '乙酉': '午未', '丙戌': '午未', '丁亥': '午未', '戊子': '午未', '己丑': '午未',
      '庚寅': '午未', '辛卯': '午未', '壬辰': '午未', '癸巳': '午未',
      '甲午': '辰巳', '乙未': '辰巳', '丙申': '辰巳', '丁酉': '辰巳', '戊戌': '辰巳', '己亥': '辰巳',
      '庚子': '辰巳', '辛丑': '辰巳', '壬寅': '辰巳', '癸卯': '辰巳',
      '甲辰': '寅卯', '乙巳': '寅卯', '丙午': '寅卯', '丁未': '寅卯', '戊申': '寅卯', '己酉': '寅卯',
      '庚戌': '寅卯', '辛亥': '寅卯', '壬子': '寅卯', '癸丑': '寅卯',
      '甲寅': '子丑', '乙卯': '子丑', '丙辰': '子丑', '丁巳': '子丑', '戊午': '子丑', '己未': '子丑',
      '庚申': '子丑', '辛酉': '子丑', '壬戌': '子丑', '癸亥': '子丑',
    };
    return xunKong[ganZhi] ?? '无';
  }

  /// 显示天干/地支参考弹窗
  void _showGanZhiRef(BuildContext ctx, String type, String name, dynamic info) {
    if (info == null) {
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(content: Text('暂无「$name」的参考资料'), duration: const Duration(seconds: 2)),
      );
      return;
    }
    final t = Theme.of(ctx);
    showDialog(
      context: ctx,
      builder: (dialogCtx) => AlertDialog(
        title: Row(children: [
          Text('$type · $name',
              style: TextStyle(fontWeight: FontWeight.bold, color: t.colorScheme.onSurface)),
          if (info is TianGanInfo) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: t.colorScheme.primary.withAlpha(20),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(info.wuXing,
                  style: TextStyle(fontSize: 12, color: t.colorScheme.primary)),
            ),
          ],
        ]),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (info is TianGanInfo) ...[
                _refRow('五行', info.wuXing, t),
                _refRow('阴阳', info.yinYang, t),
                _refRow('方位', info.direction, t),
                _refRow('类象', info.image, t),
                _refRow('对应身体', info.body, t),
              ] else if (info is DiZhiInfo) ...[
                _refRow('五行', info.wuXing, t),
                _refRow('阴阳', info.yinYang, t),
                _refRow('生肖', info.shengXiao, t),
                _refRow('月份', info.month, t),
                _refRow('时辰', info.hourRange, t),
                _refRow('方位', info.direction, t),
                _refRow('类象', info.image, t),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('关闭')),
        ],
      ),
    );
  }

  /// 参考信息行
  Widget _refRow(String label, String value, ThemeData t) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 60, child: Text('$label：',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: t.colorScheme.onSurface.withAlpha(180)))),
          Expanded(child: Text(value,
              style: TextStyle(fontSize: 13, color: t.colorScheme.onSurface))),
        ],
      ),
    );
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

/// 人工断语编辑器
class _ManualDuanYuEditor extends StatefulWidget {
  final CaseModel caseModel;
  const _ManualDuanYuEditor({required this.caseModel});

  @override
  State<_ManualDuanYuEditor> createState() => _ManualDuanYuEditorState();
}

class _ManualDuanYuEditorState extends State<_ManualDuanYuEditor> {
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

/// AI 解卦 / 追问 对话组件
class _AiChatSection extends StatefulWidget {
  final CaseModel caseModel;
  const _AiChatSection({required this.caseModel});

  @override
  State<_AiChatSection> createState() => _AiChatSectionState();
}

class _AiChatSectionState extends State<_AiChatSection> {
  final TextEditingController _questionCtrl = TextEditingController();
  bool _loading = false;
  List<AiMessage> _localMessages = [];

  List<AiMessage> get _messages => _localMessages;

  bool get _hasAssistantReply =>
      _localMessages.any((m) => m.role == 'assistant');

  @override
  void initState() {
    super.initState();
    _localMessages = List.from(widget.caseModel.aiMessages);
  }

  @override
  void didUpdateWidget(covariant _AiChatSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 如果父级传入的 caseModel 变了，同步
    if (widget.caseModel.id != oldWidget.caseModel.id) {
      _localMessages = List.from(widget.caseModel.aiMessages);
    }
  }

  @override
  void dispose() {
    _questionCtrl.dispose();
    super.dispose();
  }

  Future<void> _requestJieGua() async {
    final sp = context.read<SettingsProvider>();
    if (!sp.aiEnabled) {
      _showToast('请先在设置中启用 AI 解卦');
      return;
    }
    setState(() => _loading = true);
    try {
      final isBazi = widget.caseModel.caseType == CaseType.bazi;
      final systemPrompt = isBazi
          ? '你是一位精通八字命理的资深命理专家。请根据排盘信息进行详细分析。'
          : '你是一位精通《周易》的资深术数专家。';
      final prompt = _buildPromptForType();
      final messages = <Map<String, String>>[
        {'role': 'system', 'content': systemPrompt},
        {'role': 'user', 'content': prompt},
      ];
      final result = await AiService().chat(
        endpoint: sp.aiEndpoint,
        apiKey: sp.aiApiKey,
        model: sp.effectiveAiModel,
        messages: messages,
      );
      if (result.success) {
        _addAiMessage('user', prompt.truncated(200));
        _addAiMessage('assistant', result.content);
      } else {
        _showToast('解卦失败: ${result.errorMessage}');
      }
    } catch (e) {
      _showToast('网络错误: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  String _buildPromptForType() {
    if (widget.caseModel.caseType == CaseType.bazi) {
      return '【八字排盘信息】\n年柱：${widget.caseModel.guaName}\n'
          '日柱：${widget.caseModel.guaGong}\n'
          '排盘数据：${widget.caseModel.paipanData}\n\n'
          '请分析此八字命盘，包括五行喜忌、十神、大运走势等。';
    }
    return AiService().buildJieGuaPrompt(
      '卦名：${widget.caseModel.guaName}（${widget.caseModel.guaGong}宫）\n'
      '起卦方式：${widget.caseModel.method}\n'
      '排盘数据：${widget.caseModel.paipanData}',
    );
  }

  Future<void> _askFollowUp() async {
    final text = _questionCtrl.text.trim();
    if (text.isEmpty) return;
    final sp = context.read<SettingsProvider>();
    if (!sp.aiEnabled) {
      _showToast('请先在设置中启用 AI 解卦');
      return;
    }
    setState(() => _loading = true);
    _questionCtrl.clear();
    try {
      // 构建上下文：系统提示 + 之前的对话 + 当前问题
      final messages = <Map<String, String>>[
        {'role': 'system', 'content': '你是一位精通《周易》的资深术数专家。下面是对同一卦象的连续讨论。'},
        ..._messages.map((m) => {'role': m.role, 'content': m.content}),
        {'role': 'user', 'content': text},
      ];
      final result = await AiService().chat(
        endpoint: sp.aiEndpoint,
        apiKey: sp.aiApiKey,
        model: sp.effectiveAiModel,
        messages: messages,
      );
      if (result.success) {
        _addAiMessage('user', text);
        _addAiMessage('assistant', result.content);
      } else {
        _showToast('追问失败: ${result.errorMessage}');
      }
    } catch (e) {
      _showToast('网络错误: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  void _addAiMessage(String role, String content) {
    final msg = AiMessage(role: role, content: content);
    setState(() {
      _localMessages = [..._localMessages, msg];
    });
    // 持久化到 provider
    final updated = widget.caseModel.copyWith(
      aiMessages: _localMessages,
    );
    context.read<CaseProvider>().updateCase(updated);
  }

  void _deleteAiMessage(int index) {
    setState(() {
      _localMessages = [..._localMessages]..removeAt(index);
    });
    final updated = widget.caseModel.copyWith(
      aiMessages: _localMessages,
    );
    context.read<CaseProvider>().updateCase(updated);
  }

  void _showToast(String msg) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
      );
    }
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
            // 标题
            Row(children: [
              Icon(Icons.auto_awesome, size: 18, color: p),
              const SizedBox(width: 6),
              Text('🤖 AI 解卦', style: TextStyle(fontSize: 14,
                  fontWeight: FontWeight.bold, color: t)),
              if (_loading) ...[
                const Spacer(),
                const SizedBox(width: 18, height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2)),
              ],
            ]),
            const SizedBox(height: 8),

            // ── 首次 AI 解卦按钮 ──
            if (!_hasAssistantReply && !_loading) ...[
              Center(
                child: TextButton.icon(
                  onPressed: _requestJieGua,
                  icon: const Icon(Icons.auto_awesome, size: 18),
                  label: const Text('开始 AI 解卦', style: TextStyle(fontSize: 14)),
                  style: TextButton.styleFrom(
                    foregroundColor: p,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                    side: BorderSide(color: p.withAlpha(80)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],

            // AI 对话历史
            if (_messages.isNotEmpty) ...[
              ..._messages.asMap().entries.map((entry) {
                final i = entry.key;
                final m = entry.value;
                final isUser = m.role == 'user';
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isUser
                        ? (isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF0EDE8))
                        : (isDark ? const Color(0xFF252535) : const Color(0xFFFAF6F0)),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isUser ? t.withAlpha(20) : p.withAlpha(30),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Icon(
                          isUser ? Icons.person : Icons.auto_awesome,
                          size: 14,
                          color: isUser ? t : p,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isUser ? '你' : 'AI',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isUser ? t : p,
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => _deleteAiMessage(i),
                          child: Icon(Icons.close, size: 14,
                              color: t.withAlpha(100)),
                        ),
                      ]),
                      const SizedBox(height: 4),
                      if (isUser)
                        Text(m.content, style: TextStyle(
                            fontSize: 13, color: t))
                      else
                        Markdown(
                          data: m.content,
                          styleSheet: MarkdownStyleSheet(
                            p: TextStyle(fontSize: 13, color: t),
                            h1: TextStyle(fontSize: 16, color: t,
                                fontWeight: FontWeight.bold),
                            h2: TextStyle(fontSize: 15, color: t,
                                fontWeight: FontWeight.bold),
                            h3: TextStyle(fontSize: 14, color: t,
                                fontWeight: FontWeight.bold),
                            strong: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                    ],
                  ),
                );
              }),
            ],

            // ── 有 AI 回复时显示追问输入 ──
            if (_hasAssistantReply && !_loading) ...[
              const SizedBox(height: 8),
              Row(children: [
                Expanded(
                  child: TextField(
                    controller: _questionCtrl,
                    decoration: InputDecoration(
                      hintText: '输入追问…',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      isDense: true,
                    ),
                    maxLines: 2,
                    minLines: 1,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _askFollowUp(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _askFollowUp,
                  icon: Icon(Icons.send, color: p),
                ),
              ]),
            ],
          ],
        ),
      ),
    );
  }
}

extension _StringExtension on String {
  String truncated(int maxLen) =>
      length <= maxLen ? this : '${substring(0, maxLen)}…';
}
