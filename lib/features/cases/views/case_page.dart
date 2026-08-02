/// 卦例管理页面
/// 展示已保存的卦例列表，支持搜索、删除和详情查看
library;

import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/logger.dart';
import '../../../core/services/ai_service.dart';
import '../../../shared/widgets/gua_screenshot_template.dart';
import '../../../shared/widgets/save_image_dialog.dart';
import '../../paipan/models/bazi_models.dart';
import '../../paipan/models/gua_model.dart';
import '../../paipan/models/paipan_result.dart';
import '../../paipan/models/yao_model.dart';
import '../../paipan/views/gua_widget.dart';
import '../../reference/data/bazi_reference_data.dart';
import '../../reference/data/reference_data.dart';
import '../../settings/settings_provider.dart';
import '../models/case_models.dart';
import '../providers/case_provider.dart';

class CasePage extends StatefulWidget {
  const CasePage({super.key});

  @override
  State<CasePage> createState() => _CasePageState();
}

class _CasePageState extends State<CasePage> {
  // 大运横向滚动控制器（供 Scrollbar 显示/拖拽滚动条，与排盘页 bazi_page.dart 一致）
  final _daYunScrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CaseProvider>().loadCases();
    });
  }

  @override
  void dispose() {
    _daYunScrollCtrl.dispose();
    super.dispose();
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

    // 全屏/还原：控制 DraggableScrollableSheet 的高度（桌面端无触摸上滑手势，提供显式按钮）
    final sheetCtrl = DraggableScrollableController();
    var isFullscreen = false;
    // 桌面宽屏放宽 Material 默认 640 宽度限制，避免详情窗口过窄
    final screenW = MediaQuery.sizeOf(context).width;
    final sheetConstraints =
        BoxConstraints(maxWidth: screenW > 900 ? 720 : double.infinity);
    // 保存图片：屏幕外截图模板的 RepaintBoundary key（详情弹窗每次打开独立创建）
    final caseShotKey = GlobalKey();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      constraints: sheetConstraints,
      backgroundColor: isDark ? const Color(0xFF1A1A2E) : const Color(0xFFF5F0EB),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (_, setSheetState) => DraggableScrollableSheet(
          controller: sheetCtrl,
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
                // 全屏 / 还原（桌面端也可一键展开全屏，手机端可配合上滑手势）
                IconButton(
                  icon: Icon(
                      isFullscreen ? Icons.close_fullscreen : Icons.open_in_full,
                      size: 20),
                  tooltip: isFullscreen ? '还原半屏' : '全屏查看',
                  onPressed: () {
                    final target = isFullscreen ? 0.6 : 1.0;
                    setSheetState(() => isFullscreen = !isFullscreen);
                    try {
                      sheetCtrl.animateTo(
                        target,
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOut,
                      );
                    } catch (_) {
                      // controller 尚未 attach 时忽略（打开后极短时间内点击）
                    }
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
              const SizedBox(height: 8),
              // ── 操作按钮：复制结果 / 保存图片 ──
              Row(children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed: () => _copyCaseResult(ctx, c),
                    icon: const Icon(Icons.copy_outlined, size: 16),
                    label: const Text('复制结果'),
                    style: TextButton.styleFrom(
                        foregroundColor: t.withAlpha(200)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextButton.icon(
                    onPressed: () => _saveCaseImage(
                      caseShotKey,
                      ctx,
                      guaName: _displayGuaName(c.guaName),
                    ),
                    icon: const Icon(Icons.image_outlined, size: 16),
                    label: const Text('保存图片'),
                    style: TextButton.styleFrom(
                        foregroundColor: t.withAlpha(200)),
                  ),
                ),
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
              _AiChatSection(caseModel: c, parentScrollController: scrollCtrl),
              const SizedBox(height: 24),
              // ── 截图专用模板（屏幕外，不显示；与排盘页保持一致的紧凑国风模板）──
              ScreenshotSource(
                boundaryKey: caseShotKey,
                child: baziResult != null
                    ? BaziScreenshotTemplate(
                        birthText:
                            '${baziResult.birth.year}年${baziResult.birth.month}月'
                            '${baziResult.birth.day}日 '
                            '${baziResult.birth.hour}时 · '
                            '${baziResult.isMale ? '男' : '女'}',
                        result: baziResult,
                      )
                    : (result != null &&
                            (c.caseType == CaseType.meihua ||
                                result.method == 'meihua'))
                        ? MeihuaScreenshotTemplate(
                            timeText: formatCnTime(result.paipanTime),
                            infoTags: ['方式 ${result.method}'],
                            benGua: result.benGua,
                            bianGua: result.bianGua,
                            huGua: result.huGua,
                            explanationTitle:
                                guaNameCN[result.benGua.name],
                            explanationCi:
                                getGuaCi(result.benGua.name)?.ci,
                            explanationXiang:
                                getGuaCi(result.benGua.name)?.xiang,
                            explanationJiXiong:
                                getGuaCi(result.benGua.name)?.jiXiong,
                          )
                        : (result != null)
                            ? LiuyaoScreenshotTemplate(
                                timeText: formatCnTime(result.paipanTime),
                                infoTags: [
                                  if (result.monthGanZhi != null)
                                    '月 ${result.monthGanZhi}',
                                  if (result.dayGanZhi != null)
                                    '日 ${result.dayGanZhi}',
                                  if (result.kongWang != null)
                                    '空 旬空:${result.kongWang!.join(" ")}',
                                  '派 ${result.school == LiuyaoSchool.jingFangJianBan ? "京房简版" : "京房正宗"}',
                                ],
                                benGua: result.benGua,
                                bianGua: result.bianGua,
                                huGua: result.huGua,
                                explanationTitle:
                                    guaNameCN[result.benGua.name],
                                explanationCi:
                                    getGuaCi(result.benGua.name)?.ci,
                                explanationXiang:
                                    getGuaCi(result.benGua.name)?.xiang,
                                explanationJiXiong:
                                    getGuaCi(result.benGua.name)?.jiXiong,
                              )
                            : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
        ),
      ),
    ).whenComplete(sheetCtrl.dispose);
  }

  /// 复制排盘结果文本到剪贴板（六爻/梅花/八字）
  void _copyCaseResult(BuildContext ctx, CaseModel c) {
    PaipanResult? result;
    BaziResult? baziResult;
    try {
      result = PaipanResult.fromJson(
          jsonDecode(c.paipanData) as Map<String, dynamic>);
    } catch (_) {
      try {
        baziResult = BaziResult.fromJson(
            jsonDecode(c.paipanData) as Map<String, dynamic>);
      } catch (_) {}
    }

    final sb = StringBuffer();
    if (baziResult != null) {
      final r = baziResult;
      sb.writeln('【落·乾坤】八字排盘结果');
      sb.writeln('━━━━━━━━━━━━━━');
      sb.writeln('出生：${r.birth.year}/${r.birth.month}/${r.birth.day} '
          '${r.birth.hour}:${r.birth.minute.toString().padLeft(2, '0')}');
      sb.writeln('性别：${r.isMale ? "男" : "女"}');
      sb.writeln('━━━━━━━━━━━━━━');
      sb.writeln('年柱：${r.yearZhu.ganZhi}  ${r.yearZhu.wuXing}');
      sb.writeln('月柱：${r.monthZhu.ganZhi}  ${r.monthZhu.wuXing}');
      sb.writeln('日柱：${r.dayZhu.ganZhi}  ${r.dayZhu.wuXing}');
      sb.writeln('时柱：${r.hourZhu.ganZhi}  ${r.hourZhu.wuXing}');
      sb.writeln('━━━━━━━━━━━━━━');
      if (r.wuXingWangShuai.isNotEmpty) {
        sb.writeln('五行旺衰：');
        sb.writeln(r.wuXingWangShuai.entries
            .map((e) => '${e.key}: ${e.value}')
            .join(' · '));
      }
      if (r.daYun.isNotEmpty) {
        sb.writeln('━━━━━━━━━━━━━━');
        sb.writeln('大运：${r.daYun.map((d) => '${d.ganZhi}(${d.startAge}岁起)').join('，')}');
      }
      if (r.liuNian != null) {
        sb.writeln('流年：${r.liuNian}');
      }
    } else if (result != null) {
      final wxCN = <WuXing, String>{
        WuXing.jin: '金', WuXing.mu: '木', WuXing.shui: '水',
        WuXing.huo: '火', WuXing.tu: '土',
      };
      final bn = guaNameCN[result.benGua.name] ?? result.benGua.name.name;
      final bg = guaGongCN[result.benGua.gong] ?? '';
      final bw = wxCN[result.benGua.wuXing] ?? '';
      final timeStr =
          '${result.paipanTime.year}/${result.paipanTime.month}/${result.paipanTime.day} '
          '${result.paipanTime.hour}:${result.paipanTime.minute.toString().padLeft(2, '0')}';
      final yaosStr = result.benGua.yaos
          .map((y) => '${y.positionName}爻 '
              '${y.yinYang == YaoYinYang.yang ? '———' : '— —'}'
              '${y.isMoving ? ' ⚡动' : ''}')
          .toList()
          .reversed
          .join('\n');
      sb.writeln('【落·乾坤】排盘结果');
      sb.writeln('━━━━━━━━━━━━━━');
      sb.writeln('卦名：$bn');
      sb.writeln('宫位：$bg宫 · 五行 $bw');
      sb.writeln('方式：${methodToCN(c.method)}');
      sb.writeln('时间：$timeStr');
      sb.writeln('━━━━━━━━━━━━━━');
      sb.writeln(yaosStr);
      if (result.bianGua != null) {
        final bn2 = guaNameCN[result.bianGua!.name] ?? result.bianGua!.name.name;
        sb.writeln('━━━━━━━━━━━━━━');
        sb.writeln('▸ 变卦：$bn2');
      }
      if (result.huGua != null) {
        final bn3 = guaNameCN[result.huGua!.name] ?? result.huGua!.name.name;
        sb.writeln('▸ 互卦：$bn3');
      }
    }
    sb.writeln('━━━━━━━━━━━━━━');
    sb.writeln('—— 来自「落·乾坤」');

    Clipboard.setData(ClipboardData(text: sb.toString()));
    Logger.instance.info('卦例详情', '复制排盘结果: ${c.title}');
    if (ctx.mounted) {
      ScaffoldMessenger.of(ctx).showSnackBar(
        const SnackBar(content: Text('排盘结果已复制到剪贴板'),
            duration: Duration(seconds: 2)),
      );
    }
  }

  /// 截取卦例详情模板并保存图片（浮窗预览 → 文件名编辑 → 选择目录 → 写入）
  Future<void> _saveCaseImage(GlobalKey key, BuildContext ctx,
      {required String guaName}) async {
    try {
      final boundary = key.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) {
        if (ctx.mounted) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            const SnackBar(content: Text('截图失败：未找到排盘结果')),
          );
        }
        return;
      }
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;
      final pngBytes = byteData.buffer.asUint8List();
      if (!ctx.mounted) return;
      final savedPath = await saveImageWithDialog(
        context: ctx,
        pngBytes: pngBytes,
        defaultFileName: buildImageFileName(guaName),
      );
      if (savedPath == null) return;
      if (ctx.mounted) {
        ScaffoldMessenger.of(ctx).showSnackBar(
          SnackBar(content: Text('截图已保存: $savedPath')),
        );
      }
    } catch (e) {
      if (ctx.mounted) {
        ScaffoldMessenger.of(ctx).showSnackBar(
          SnackBar(content: Text('保存图片失败: $e')),
        );
      }
    }
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
            // 与排盘页 bazi_page.dart 大运一致：ScrollConfiguration 允许鼠标/触控板拖拽横向滚动，
            // Scrollbar 提供可见滚动条（可拖拽拇指），避免外层纵向滚动吞掉横向手势导致"看起来不能滑动"。
            ScrollConfiguration(
              behavior: ScrollConfiguration.of(ctx).copyWith(
                dragDevices: {
                  ui.PointerDeviceKind.touch,
                  ui.PointerDeviceKind.mouse,
                  ui.PointerDeviceKind.stylus,
                  ui.PointerDeviceKind.trackpad,
                },
              ),
              child: Scrollbar(
                controller: _daYunScrollCtrl,
                thumbVisibility: true,
                interactive: true,
                radius: const Radius.circular(8),
                child: SingleChildScrollView(
                  controller: _daYunScrollCtrl,
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
  /// 父级详情弹窗的滚动控制器：AI 新消息后自动滚动到底部（让用户直接看到回复）
  final ScrollController? parentScrollController;

  const _AiChatSection({
    required this.caseModel,
    this.parentScrollController,
  });

  @override
  State<_AiChatSection> createState() => _AiChatSectionState();
}

class _AiChatSectionState extends State<_AiChatSection> {
  final TextEditingController _questionCtrl = TextEditingController();
  /// 首个 chunk 到达前为 true：头部显示转圈（AC4：转圈只在首个 chunk 前显示）
  bool _loading = false;
  /// 流式请求进行中：首个 chunk 到达后 _loading=false（转圈关闭），但 _streaming
  /// 保持 true 直到流结束/取消/删除，用于禁用'开始 AI 解卦'按钮与追问输入，
  /// 避免流式中触发并发请求（与 _loading 分离，转圈与打字机不再全程并存）
  bool _streaming = false;
  List<AiMessage> _localMessages = [];
  /// 当前流式订阅（AI 解卦/追问流式输出期间非 null）
  StreamSubscription<AiStreamPiece>? _streamSub;
  /// 正在流式更新的 assistant 消息（对象引用定位，避免删除其它消息后索引偏移）
  AiMessage? _streamingMsg;
  /// 本次流式是否已执行首次自动滚动：首个增量到达时滚到底一次（让用户看到
  /// 回复开始）；之后仅当用户接近底部时跟随滚动，不打断上滑回看排盘/历史。
  bool _autoScrolled = false;
  /// AI 解卦卡片自身的 GlobalKey：用于把详情弹窗滚动到 AI 区顶部（让用户看到
  /// 回复与上方上下文，而不是钉死在最底部只剩输入框）。
  final GlobalKey _cardKey = GlobalKey();
  /// 推理过程累积（DeepSeek 推理模型思考阶段只有 reasoning_content 增量）。
  /// 推理阶段 UI 显示'正在思考…'+ 思考过程小字（打字机效果），让用户感知
  /// 流式输出；最终消息只保留正式答案（content），思考过程不拼入。
  String _thinking = '';

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
    // 停止流式订阅，避免对已 dispose 的 State 继续 setState（cancel 后不再派发事件）
    _streamSub?.cancel();
    _streamSub = null;
    _questionCtrl.dispose();
    super.dispose();
  }

  Future<void> _requestJieGua() async {
    final sp = context.read<SettingsProvider>();
    if (!sp.aiEnabled) {
      _showToast('请先在设置中启用 AI 解卦');
      return;
    }
    final isBazi = widget.caseModel.caseType == CaseType.bazi;
    // 精简中文系统提示：明确输出格式要求（>>>解卦<<< 标记 + 逐行换行），
    // 并强制"思考极短、正式输出详细"——实测（2026-08-02）deepseek-v4-flash-free
    // 若不禁制思考会输出超长 reasoning（甚至 20K+ 字符），把 max_tokens
    // 配额耗尽导致 content 为空或流式永不完成；必须明确限定思考篇幅。
    final systemPrompt = isBazi
        ? '你是八字命理专家，根据排盘信息直接分析命盘。'
            '思考控制在50字以内（只列关键要点），不要复述排盘数据；'
            '正式结果要详细清晰有条理，用 >>>解卦<<< 开头、>>>解卦结束<<< 结尾包裹；'
            '不同要点逐行输出，禁止挤在一行。'
        : '你是六爻/梅花解卦专家。思考控制在50字以内（只列关键要点），'
            '不要复述排盘数据；正式结果要详细清晰有条理，'
            '用 >>>解卦<<< 开头、>>>解卦结束<<< 结尾包裹；'
            '各爻逐行输出（初爻：…／二爻：…）；不同要点换行，禁止挤在一行。';
    final prompt = _buildPromptForType();
    final messages = <Map<String, String>>[
      {'role': 'system', 'content': systemPrompt},
      {'role': 'user', 'content': prompt},
    ];
    await _runStreamingAi(
      messages: messages,
      userContent: prompt,
      clearBefore: true,
      logTag: 'AI解卦',
      errPrefix: '解卦失败',
    );
  }

  String _buildPromptForType() {
    if (widget.caseModel.caseType == CaseType.bazi) {
      return _buildBaziPrompt();
    }
    // 六爻/梅花：把排盘 JSON 解析为中文描述再发给 AI
    // （不传英文键 JSON 原文，模型才能直接读懂排盘信息）
    String cnInfo;
    try {
      final r = PaipanResult.fromJson(
          jsonDecode(widget.caseModel.paipanData) as Map<String, dynamic>);
      cnInfo = _buildPaipanTextCN(r);
    } catch (_) {
      // 旧数据解析失败时降级为标题信息
      cnInfo = '卦名：${widget.caseModel.guaName}（${widget.caseModel.guaGong}宫）\n'
          '起卦方式：${widget.caseModel.method}';
    }
    return AiService().buildJieGuaPrompt(cnInfo);
  }

  /// 把排盘结果格式化为中文文本（复用"复制结果"的格式化逻辑），
  /// 供 AI 解卦提示词使用——避免把英文键的 JSON 原文发给模型。
  String _buildPaipanTextCN(PaipanResult result) {
    const wxCN = <WuXing, String>{
      WuXing.jin: '金', WuXing.mu: '木', WuXing.shui: '水',
      WuXing.huo: '火', WuXing.tu: '土',
    };
    const lqCN = <LiuQin, String>{
      LiuQin.parent: '父母', LiuQin.brother: '兄弟', LiuQin.officer: '官鬼',
      LiuQin.wife: '妻财', LiuQin.child: '子孙', LiuQin.none: '',
    };
    final bn = guaNameCN[result.benGua.name] ?? result.benGua.name.name;
    final bg = guaGongCN[result.benGua.gong] ?? '';
    final bw = wxCN[result.benGua.wuXing] ?? '';
    final timeStr = '${result.paipanTime.year}年${result.paipanTime.month}月'
        '${result.paipanTime.day}日 ${result.paipanTime.hour}:'
        '${result.paipanTime.minute.toString().padLeft(2, '0')}';
    final sb = StringBuffer();
    sb.writeln('本卦：$bn（$bg宫，五行$bw）');
    sb.writeln('起卦方式：${methodToCN(result.method)}');
    sb.writeln('起卦时间：$timeStr');
    sb.writeln('六爻排盘（自下而上）：');
    for (final y in result.benGua.yaos.reversed) {
      final line = y.yinYang == YaoYinYang.yang ? '———' : '— —';
      final parts = <String>['${y.positionName}爻 $line'];
      if (y.isMoving) parts.add('动');
      if (y.liuQin != LiuQin.none) parts.add(lqCN[y.liuQin] ?? '');
      if (y.liuShen != null) parts.add(liuShenCN[y.liuShen] ?? '');
      if (y.wangShuai != null) parts.add(y.wangShuai!.label);
      if (y.isShi) parts.add('世');
      if (y.isYing) parts.add('应');
      if (y.isKongWang) parts.add('旬空');
      sb.writeln('  ${parts.join(' ')}');
    }
    if (result.bianGua != null) {
      final bn2 = guaNameCN[result.bianGua!.name] ?? result.bianGua!.name.name;
      sb.writeln('变卦：$bn2');
    }
    if (result.huGua != null) {
      final bn3 = guaNameCN[result.huGua!.name] ?? result.huGua!.name.name;
      sb.writeln('互卦：$bn3');
    }
    if (result.monthGanZhi != null) sb.writeln('月令（月建）：${result.monthGanZhi}');
    if (result.dayGanZhi != null) sb.writeln('日辰：${result.dayGanZhi}');
    if (result.kongWang != null && result.kongWang!.isNotEmpty) {
      sb.writeln('旬空：${result.kongWang!.join('、')}');
    }
    if (result.shenSha.isNotEmpty) {
      sb.writeln('神煞：${result.shenSha.join('、')}');
    }
    return sb.toString();
  }

  /// 构建八字提示词：从 paipanData 解析完整四柱/五行/十神/大运。
  /// 不再用 guaName（实为年柱）/ guaGong（实为日柱）占位。
  String _buildBaziPrompt() {
    try {
      final r = BaziResult.fromJson(
        jsonDecode(widget.caseModel.paipanData) as Map<String, dynamic>,
      );
      final sb = StringBuffer('【八字排盘信息】\n');
      sb.writeln('出生时间：${r.birth.toLocal()}');
      sb.writeln('性别：${r.isMale ? '男' : '女'}');
      sb.writeln('四柱：');
      sb.writeln('  年柱 ${r.yearZhu.ganZhi}（${r.yearZhu.wuXing}）');
      sb.writeln('  月柱 ${r.monthZhu.ganZhi}（${r.monthZhu.wuXing}）');
      sb.writeln('  日柱 ${r.dayZhu.ganZhi}（${r.dayZhu.wuXing}，日元）');
      sb.writeln('  时柱 ${r.hourZhu.ganZhi}（${r.hourZhu.wuXing}）');
      if (r.wuXingCounts.isNotEmpty) {
        sb.write('五行统计：');
        for (final e in r.wuXingCounts.entries) {
          sb.write('${e.key} ${e.value}  ');
        }
        sb.writeln();
      }
      if (r.wuXingWangShuai.isNotEmpty) {
        sb.write('五行旺衰：');
        for (final e in r.wuXingWangShuai.entries) {
          sb.write('${e.key}${e.value}  ');
        }
        sb.writeln();
      }
      if (r.shiShenMap.isNotEmpty) {
        sb.write('十神：');
        final labels = r.shiShenMap.entries
            .where((e) => e.key != '日主')
            .map((e) => e.key.contains(':')
                ? '${e.key.split(':')[1]}(${e.value})'
                : '${e.key}(${e.value})');
        for (final s in labels) {
          sb.write('$s  ');
        }
        sb.writeln();
      }
      if (r.daYun.isNotEmpty) {
        sb.write('大运：');
        for (final d in r.daYun) {
          sb.write('${d.startAge}岁${d.ganZhi}  ');
        }
        sb.writeln();
      }
      if (r.liuNian != null && r.liuNian!.isNotEmpty) {
        sb.writeln('流年：${r.liuNian}');
      }
      sb.writeln('\n请分析此八字命盘，包括五行喜忌、十神、大运走势等。');
      sb.writeln('【输出格式】思考控制在50字以内（只列关键要点），不要复述排盘数据；');
      sb.writeln('正式结果要详细清晰有条理，用 >>>解卦<<< 开头、>>>解卦结束<<< 结尾包裹；');
      sb.writeln('不同要点逐行输出，禁止挤在一行。');
      return sb.toString();
    } catch (e) {
      // 旧数据解析失败时降级为简要信息（不再把年柱/日柱当卦名占位）
      return '【八字排盘信息】\n'
          '四柱：年柱${widget.caseModel.guaName} / 日柱${widget.caseModel.guaGong}\n'
          '排盘数据：${widget.caseModel.paipanData}\n\n'
          '请分析此八字命盘，包括五行喜忌、十神、大运走势等。\n'
          '【输出格式】思考控制在50字以内（只列关键要点），不要复述排盘数据；'
          '正式结果要详细清晰有条理，用 >>>解卦<<< 开头、>>>解卦结束<<< 结尾包裹；'
          '不同要点逐行输出，禁止挤在一行。';
    }
  }

  Future<void> _askFollowUp() async {
    final text = _questionCtrl.text.trim();
    if (text.isEmpty) return;
    final sp = context.read<SettingsProvider>();
    if (!sp.aiEnabled) {
      _showToast('请先在设置中启用 AI 解卦');
      return;
    }
    final isBazi = widget.caseModel.caseType == CaseType.bazi;
    // 追问沿用解卦的输出格式要求（>>>解卦<<< 标记 + 逐行换行 + 思考极短），
    // 便于软件按同一逻辑提取正文。思考限定 ≤50 字：实测不限制时
    // 推理模型输出超长思考导致 content 为空/流式永不完成。
    final systemPrompt = isBazi
        ? '你是八字命理专家，下面是对同一命盘的连续讨论。'
            '思考控制在50字以内（只列关键要点），不要复述排盘数据；'
            '回答详细清晰有条理，同样用 >>>解卦<<< 开头、>>>解卦结束<<< 结尾包裹正式内容；'
            '不同要点逐行输出，禁止挤在一行。'
        : '你是六爻/梅花解卦专家，下面是对同一卦象的连续讨论。'
            '思考控制在50字以内（只列关键要点），不要复述排盘数据；'
            '回答详细清晰有条理，同样用 >>>解卦<<< 开头、>>>解卦结束<<< 结尾包裹正式内容；'
            '各爻逐行输出；不同要点换行，禁止挤在一行。';
    // 构建上下文：系统提示 + 历史消息 + 当前问题（错误消息不进入 AI 上下文）。
    // 上下文容量保护：按约 131k tokens（≈85k 中文字符）上限，超出时丢弃
    // 最旧消息（保留最近的对话，保证追问多轮后不超模型窗口；正常追问
    // 远达不到该上限，纯防御）。
    final messages = <Map<String, String>>[
      {'role': 'system', 'content': systemPrompt},
      ..._buildHistoryContext(systemPrompt, _messages),
      {'role': 'user', 'content': text},
    ];
    _questionCtrl.clear();
    await _runStreamingAi(
      messages: messages,
      userContent: text,
      clearBefore: false,
      logTag: 'AI追问',
      errPrefix: '追问失败',
    );
  }

  /// 构建追问上下文历史消息，带 131k tokens 容量保护。
  /// 中文约 0.65 字/token，131072 tokens ≈ 85000 字符；从最近的对话开始
  /// 累积，超出上限就丢弃更早的消息（保留最近上下文，追问多轮不超窗口）。
  List<Map<String, String>> _buildHistoryContext(
      String systemPrompt, List<AiMessage> history) {
    // 131k tokens 上下文极限（用户指定，qwenpaw 同值）；≈85k 中文字符
    const int maxContextChars = 85000;
    final keep = <AiMessage>[];
    var used = systemPrompt.length;
    // 从最新往最旧累积：最新消息最相关，优先保留
    for (final m in history.reversed) {
      final cost = m.content.length;
      if (used + cost > maxContextChars) break;
      used += cost;
      keep.add(m);
    }
    return keep.reversed
        .map((m) => {'role': m.role, 'content': m.content})
        .toList();
  }

  /// 流式 AI 请求统一流程（解卦 / 追问共用）：
  /// 1. '你' 消息立即入列并持久化（用户问题完整保留）
  /// 2. 创建空 assistant 占位（UI 显示'正在生成…'），订阅 chatStream 增量更新内容
  /// 3. 流完成：持久化最终完整文本；流异常或无内容：自动回退非流式 chat()
  Future<void> _runStreamingAi({
    required List<Map<String, String>> messages,
    required String userContent,
    required bool clearBefore,
    required String logTag,
    required String errPrefix,
  }) async {
    // 防御：已有流式请求进行中时忽略并发触发（按钮/追问区已隐藏，双保险）
    if (_streaming || _streamSub != null) return;
    final sp = context.read<SettingsProvider>();
    setState(() {
      _loading = true;
      _streaming = true;
      _autoScrolled = false;
      _thinking = '';
    });
    try {
      // 关键步骤日志：开始请求（model、消息数；不打印 apiKey，避免明文泄漏）
      Logger.instance.info('$logTag开始',
          'model: ${sp.effectiveAiModel} | messages: ${messages.length}');
      // 重新解卦语义：若当前对话中已无 AI 回复（旧回复已被删除），先清空旧消息，
      // 再写入新的一对 '你'/'AI'，避免再次解卦时旧卡片与新卡片堆叠重复。
      if (clearBefore && !_hasAssistantReply && _localMessages.isNotEmpty) {
        setState(() => _localMessages = []);
      }
      // 用户问题立即入列并持久化
      await _addAiMessage('user', userContent);
      // 创建 assistant 占位消息（内容为空、UI 显示'正在生成…'）。
      // 占位不立即持久化（避免流式中途刷新残留空/半成品消息），
      // 只在流式完成后用最终完整文本持久化一次。
      final placeholder = _createAssistantPlaceholder();
      if (placeholder == null) return; // 弹窗已关闭
      _streamingMsg = placeholder;

      final stream = AiService()
          .chatStream(
            endpoint: sp.aiEndpoint,
            apiKey: sp.aiApiKey,
            model: sp.effectiveAiModel,
            messages: messages,
          )
          // 流式超时保护：推理模型思考阶段可能长时间无增量（DeepSeek 思考
          // 较久才输出），超时窗口放宽到 180 秒；两个增量事件间隔超过 180 秒
          // （网关挂起/无数据）时才在流上抛错 → 触发 onError → 自动回退
          // 非流式 chat()，避免用户看到无限转圈只能反复重开弹窗。
          .timeout(
            const Duration(seconds: 180),
            onTimeout: (sink) => sink.addError(
              AiStreamException('流式超时（180 秒无数据）'),
            ),
          );
      var receivedAny = false;
      // 推理过程累积（DeepSeek 推理模型思考阶段只有 reasoning_content 增量）。
      // 仅用于兜底展示与"流式有活性"判定，不拼入最终消息。
      var thinking = '';
      // 增量统计：用于诊断"没有流式输出"类反馈——块数 > 1 说明增量确实实时
      // 分块到达（UI 展示问题）；块数 = 1 说明一次性返回（网关缓冲或解析问题）。
      var chunkCount = 0;
      var reasoningCount = 0;
      _streamSub = stream.listen(
        (piece) {
          if (!mounted || _streamingMsg == null) return;
          final msg = _streamingMsg!;
          receivedAny = true;
          if (_loading) {
            // 发现 A：首个 chunk 到达后关闭转圈（AC4：转圈只在首个 chunk 前
            // 显示；之后的进度由消息卡片的打字机效果呈现）。注意推理阶段
            // 的 reasoning 增量也属于首个 chunk，同样要关闭转圈。
            setState(() => _loading = false);
          }
          if (piece.isReasoning) {
            reasoningCount++;
            // 推理过程增量：只累积，不拼入消息，避免"思考过程+答案"拼接
            // 污染展示（用户最终看到的消息只含正式答案）。同时把思考过程
            // 同步到 UI 小字（打字机），让用户看到"正在思考"的流式输出，
            // 而不是几十秒毫无动静。
            thinking += piece.text;
            // 思考失控保护（实测 2026-08-02）：deepseek-v4-flash-free
            // 思考可无限长（20K+ 字符仍不进入 content 阶段），导致流式
            // 永不完成、UI 卡死。推理累积超 1.5 万字符仍无正式答案 →
            // 主动取消流并用思考全文兜底，避免用户无限等待。
            if (thinking.length > 15000 && msg.content.trim().isEmpty) {
              Logger.instance.warn('$logTag思考过长',
                  '推理 ${thinking.length} 字仍无正式答案，主动止损并展示思考内容');
              _streamSub?.cancel();
              _streamSub = null;
              _streamingMsg = null;
              _finishStreamingWithThinking(msg, thinking, logTag);
              return;
            }
            setState(() => _thinking = thinking);
            return;
          }
          chunkCount++;
          _appendStreamPiece(piece.text);
        },
        onError: (Object e) {
          if (!mounted) return;
          _streamSub = null;
          final msg = _streamingMsg;
          _streamingMsg = null;
          if (msg == null) {
            // 占位已被用户删除：不再回退，直接复位全部请求态
            setState(() {
              _loading = false;
              _streaming = false;
            });
            return;
          }
          Logger.instance.error('$logTag流式失败', '流错误: $e');
          _fallbackToNonStreaming(
            msg: msg,
            messages: messages,
            logTag: logTag,
            errPrefix: errPrefix,
          );
        },
        onDone: () {
          if (!mounted) return;
          _streamSub = null;
          final msg = _streamingMsg;
          _streamingMsg = null;
          if (msg == null) {
            // 占位已被删除/取消：不再回退，直接复位全部请求态
            // （发现 B：该早退路径同样必须复位，否则 _loading 永不复位卡死）
            setState(() {
              _loading = false;
              _streaming = false;
            });
            return;
          }
          if (receivedAny && msg.content.trim().isNotEmpty) {
            // 流式成功：完整答案已随 content 增量拼好，提取标记内正文后
            // 持久化最终文本（模型未按格式输出时提取结果=原文，不重复 setState）。
            // 思考过程随消息保存（thinking 字段），UI 折叠展示而非删掉。
            final clean = _extractAiResult(msg.content);
            if (clean != msg.content || thinking.trim().isNotEmpty) {
              _replaceAssistantContent(msg, clean, thinking: thinking);
            }
            Logger.instance.info('$logTag流式完成',
                'content长度: ${clean.length} | content增量: $chunkCount | 推理增量: $reasoningCount');
            _persistAiMessages(logTag);
            setState(() {
              _loading = false;
              _streaming = false;
              _thinking = '';
            });
            // 完成后若用户仍在底部附近（未上滑回看），滚到 AI 区顶部展示结果
            _scrollToAiSectionIfNear();
          } else if (receivedAny && thinking.trim().isNotEmpty) {
            _finishStreamingWithThinking(msg, thinking, logTag);
          } else {
            // 流正常结束但未产出内容 → 回退非流式 chat()（网关不支持流式等场景）
            Logger.instance.error('$logTag流式无内容', '回退非流式 chat()');
            _fallbackToNonStreaming(
              msg: msg,
              messages: messages,
              logTag: logTag,
              errPrefix: errPrefix,
            );
          }
        },
      );
    } catch (e) {
      // 订阅创建阶段的异常（构建请求/网络连接失败等）
      Logger.instance.error('$logTag失败', '网络错误: $e');
      _handleStreamFailure(_streamingMsg, '$errPrefix: 网络错误: $e');
      _streamingMsg = null;
      _showToast('$errPrefix: 网络错误: $e');
      if (mounted) {
        setState(() {
          _loading = false;
          _streaming = false;
        });
      }
    }
  }

  /// 流式结束但只有推理内容（content 为空）时的统一兜底：
  /// 用思考全文替换占位消息（纯文本渲染，避免 Markdown 吃掉符号）。
  /// 三种场景复用：
  /// 1. onDone 正常结束但 content 始终为空（网关只回推理）
  /// 2. 思考失控主动止损（_thinking > 1.5 万字符无正式答案）
  /// 3. （预留）其它异常路径
  /// 注意：兜底直接用思考全文，不再 _extractAiResult 提取——思考过程里若
  /// 出现" >>>解卦<<< "字样（模型模拟输出格式但未写完），提取会只留下
  /// 标记后的残句（用户反馈"只有'开头、'的输出"）。
  void _finishStreamingWithThinking(
      AiMessage msg, String thinking, String logTag) {
    Logger.instance.info('$logTag流式完成(仅推理内容)',
        '长度: ${thinking.trim().length}');
    _replaceAssistantContent(msg, thinking.trim(), plainText: true);
    _persistAiMessages(logTag);
    if (!mounted) return;
    setState(() {
      _loading = false;
      _streaming = false;
      _thinking = '';
    });
    _scrollToAiSectionIfNear();
  }

  /// 弹窗查看完整实时思考过程（流式推理阶段点击"思考过程"区域触发）。
  /// 流式期间思考可能长达数万字，卡片里只显示前 400 字符，这里全量可看。
  void _showThinkingDialog() {
    final content = _thinking.trim();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('思考过程（实时）'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: SelectableText(
              content.isEmpty ? '（暂无内容，思考生成中…）' : content,
              style: const TextStyle(fontSize: 13, height: 1.6),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  /// 创建空的 assistant 占位消息（不持久化，流完成后再写最终文本）
  AiMessage? _createAssistantPlaceholder() {
    if (!mounted) return null;
    final msg = AiMessage(role: 'assistant', content: '');
    setState(() {
      _localMessages = [..._localMessages, msg];
    });
    // 不在此处滚动：AI 解卦开始时保持用户当前阅读位置（排盘内容不被推走），
    // 首个回复增量到达后再滚动（见 _appendStreamPiece），避免"内容瞬间消失"。
    return msg;
  }

  /// 把流式增量文本追加到正在生成的 assistant 消息（打字机效果）。
  /// 通过对象引用定位消息，删除其它消息导致的索引偏移不影响追加。
  void _appendStreamPiece(String piece) {
    if (!mounted) return;
    final msg = _streamingMsg;
    if (msg == null) return;
    final idx = _localMessages.indexOf(msg);
    if (idx < 0) return; // 占位已被删除
    final updated = AiMessage(role: 'assistant', content: msg.content + piece);
    setState(() {
      _localMessages = [..._localMessages];
      _localMessages[idx] = updated;
    });
    _streamingMsg = updated;
    if (!_autoScrolled) {
      // 首个答案增量到达：滚到 AI 区顶部，让用户看到回复开始（打字机效果）。
      // 不再滚到最底部输入框——之前滚到底导致"内容全空只剩输入框"体感。
      _autoScrolled = true;
      _scrollToAiSection();
    }
    // 后续增量：不自动滚动（流式期间持续滚动会与用户手势对抗，
    // 表现为"一点都滑不动"；用户可自由上滑回看排盘/历史）。
  }

  /// 从 AI 原始输出中提取正式解卦结果。
  /// 用户要求：模型用标识符标记真正输出，方便软件快速获取真正结果
  /// （AI 输出冗余 → 只需展示/保存标记内的正文）。
  /// 优先提取 >>>解卦<<< ... >>>解卦结束<<< 之间的正文；
  /// 模型未按格式输出时回退为原文（不丢弃任何内容）。
  String _extractAiResult(String raw) {
    var text = raw.trim();
    const start = '>>>解卦<<<';
    const end = '>>>解卦结束<<<';
    final si = text.indexOf(start);
    if (si >= 0) {
      final ei = text.indexOf(end, si + start.length);
      if (ei > si) {
        return text.substring(si + start.length, ei).trim();
      }
      // 只有开头标记没有结尾标记：取开头标记之后的内容
      return text.substring(si + start.length).trim();
    }
    return text;
  }

  /// Markdown 渲染前转义输出标记：把 ">>>" / "<<<" 替换为全角，
  /// 避免 " >>>解卦<<< " 被解析成 blockquote（引用块）语法破坏卡片布局。
  String _sanitizeMarkdown(String s) => s
      .replaceAll('>>>', '＞＞＞')
      .replaceAll('<<<', '＜＜＜');

  /// 用完整内容替换占位 assistant 消息（回退非流式成功后）
  /// [thinking] 为思考过程：随消息持久化，UI 折叠展示（用户要求思考
  /// "折叠而不是完全删掉"）；null 表示无思考（非流式回退等场景）。
  void _replaceAssistantContent(AiMessage msg, String content,
      {bool plainText = false, String? thinking}) {
    if (!mounted) return;
    final idx = _localMessages.indexOf(msg);
    if (idx < 0) return;
    setState(() {
      _localMessages = [..._localMessages];
      _localMessages[idx] = AiMessage(
        role: 'assistant',
        content: content,
        isPlainText: plainText,
        thinking: thinking,
      );
    });
    _scrollToAiSection();
  }

  /// 流式失败处理：移除空占位 assistant 消息，追加错误气泡（不持久化 error）
  void _handleStreamFailure(AiMessage? msg, String display) {
    if (!mounted) return;
    if (msg != null) {
      final idx = _localMessages.indexOf(msg);
      if (idx >= 0) {
        setState(() {
          _localMessages = [..._localMessages]..removeAt(idx);
        });
      }
    }
    _addErrorMessage(display);
  }

  /// 流式失败/无内容时回退到原非流式 chat()，一次性返回完整内容，
  /// 避免网关不支持流式时用户干等或看到空白卡片。
  Future<void> _fallbackToNonStreaming({
    required AiMessage msg,
    required List<Map<String, String>> messages,
    required String logTag,
    required String errPrefix,
  }) async {
    final sp = context.read<SettingsProvider>();
    try {
      final result = await AiService().chat(
        endpoint: sp.aiEndpoint,
        apiKey: sp.aiApiKey,
        model: sp.effectiveAiModel,
        messages: messages,
      );
      if (result.success) {
        Logger.instance.info('$logTag回退成功', 'content长度: ${result.content.length}');
        _replaceAssistantContent(msg, _extractAiResult(result.content));
        await _persistAiMessages(logTag);
      } else {
        Logger.instance.error('$logTag回退失败',
            'statusCode: ${result.statusCode ?? 'N/A'} 错误摘要: ${result.errorMessage}');
        _handleStreamFailure(msg, '$errPrefix: ${result.errorMessage}');
        _showToast('$errPrefix: ${result.errorMessage}');
      }
    } catch (e) {
      Logger.instance.error('$logTag回退失败', '网络错误: $e');
      _handleStreamFailure(msg, '$errPrefix: 网络错误: $e');
      _showToast('$errPrefix: 网络错误: $e');
    } finally {
      // 成功/失败/异常都复位全部请求态；弹窗已关闭时避免对已 dispose 的 State 调 setState
      if (mounted) {
        setState(() {
          _loading = false;
          _streaming = false;
        });
      }
    }
  }

  /// 持久化当前消息列表（过滤 error；流式期间不调用，只存最终完整文本）
  Future<void> _persistAiMessages(String logTag) async {
    // 弹窗已关闭（widget 已 dispose）时不再访问 context / 持久化
    if (!mounted) return;
    // CI fix (US-003)：context 读取紧跟 mounted 守卫（任何其他语句之前）并缓存
    // provider 复用，lint 完全识别该 guard，消除 use_build_context_synchronously
    // （原实现 context.read 位于 try 块内且隔着分支，flow analysis 不认可守卫覆盖）。
    // context.read 无副作用，id 为空的早退路径多读一次 provider 不影响行为。
    final provider = context.read<CaseProvider>();
    final id = widget.caseModel.id;
    if (id == null) {
      Logger.instance.error('AI解卦', '卦例 id 为空，AI 消息仅显示不持久化');
      return;
    }
    try {
      await provider.updateAiMessages(
        id,
        _localMessages.where((m) => m.role != 'error').toList(),
      );
      Logger.instance.info('$logTag持久化完成', '当前消息数: ${_localMessages.length}');
    } catch (e) {
      Logger.instance.error('AI解卦', 'AI 消息持久化失败: $e');
    }
  }

  Future<void> _addAiMessage(String role, String content) async {
    // 弹窗已关闭（widget 已 dispose）时不再改动本地消息状态
    if (!mounted) return;
    final msg = AiMessage(role: role, content: content);
    setState(() {
      _localMessages = [..._localMessages, msg];
    });
    // 不在此处滚动：消息入列不打断用户当前阅读位置（回复出现时再滚动）
    // 持久化时过滤 error 消息（错误气泡仅显示在界面上，不写入卦例）。
    // 使用 CaseProvider.updateAiMessages 基于 provider 最新状态合并，串行 await 避免竞态。
    final id = widget.caseModel.id;
    if (id == null) {
      Logger.instance.error('AI解卦', '卦例 id 为空，AI 消息仅显示不持久化');
      return;
    }
    final provider = context.read<CaseProvider>();
    await provider.updateAiMessages(
      id,
      _localMessages.where((m) => m.role != 'error').toList(),
    );
  }

  /// 错误消息仅显示在 AI 对话区（红色错误气泡），不持久化到卦例
  void _addErrorMessage(String content) {
    if (!mounted) return;
    setState(() {
      _localMessages = [..._localMessages, AiMessage(role: 'error', content: content)];
    });
    _scrollToAiSection();
  }

  Future<void> _deleteAiMessage(int index) async {
    // 防御：弹窗已关闭或 index 越界（如列表在重建前被并发修改）时直接忽略
    if (!mounted || index < 0 || index >= _localMessages.length) return;
    // 若删除的是正在流式生成的 assistant 消息：先取消订阅，避免后续 chunk
    // 继续 setState 更新已删除的消息（残留脏状态）；onDone/onError 不再触发。
    final target = _localMessages[index];
    if (identical(target, _streamingMsg)) {
      _streamingMsg = null;
      await _streamSub?.cancel();
      _streamSub = null;
      // 发现 B（高危）：取消订阅后 onDone/onError 不再触发，必须在这里同步复位
      // 请求态，否则转圈与按钮/追问区锁定永久卡死；
      // await 之后弹窗可能已关闭，需 mounted 守卫避免 setState-after-dispose。
      if (mounted) {
        setState(() {
          _loading = false;
          _streaming = false;
        });
      }
    }
    setState(() {
      _localMessages = [..._localMessages]..removeAt(index);
    });
    // async gap（await cancel）之后使用 State.context 前需 State.mounted 守卫
    // （use_build_context_synchronously 要求 State.context 用 mounted 而非 context.mounted）
    if (!mounted) return;
    final id = widget.caseModel.id;
    if (id == null) {
      Logger.instance.error('AI解卦', '卦例 id 为空，删除仅影响界面显示');
      return;
    }
    try {
      final provider = context.read<CaseProvider>();
      await provider.updateAiMessages(
        id,
        // 过滤 error 消息；流式中的半成品 assistant 不持久化（完成后才写最终文本）
        _localMessages
            .where((m) => m.role != 'error' && !identical(m, _streamingMsg))
            .toList(),
      );
    } catch (e) {
      // 持久化失败不影响界面删除（setState 已先行执行），记录日志避免未处理异常
      Logger.instance.error('AI解卦', '删除消息持久化失败: $e');
    }
  }

  /// 用户消息的卡片展示文本：折叠连续空白（避免多空格/换行挤爆布局），
  /// **完整保留原文**——用户反馈"提示词显示不全"，不再截断前 60 字符；
  /// prompt 全文同时用于追问上下文与持久化数据。
  String _displayUserContent(String content) {
    final collapsed = content.replaceAll(RegExp(r'\s+'), ' ').trim();
    return collapsed;
  }

  /// 把详情弹窗滚动到 AI 解卦卡片顶部（留 12px 顶部空隙），让用户看到 AI
  /// 回复与上方上下文。**不滚到最底部**——底部是输入框，钉死在底部会让用户
  /// 产生"内容全空只剩输入框"的体感。
  void _scrollToAiSection() {
    final sc = widget.parentScrollController;
    if (sc == null || !sc.hasClients) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !sc.hasClients) return;
      final ctx = _cardKey.currentContext;
      if (ctx == null) return;
      final box = ctx.findRenderObject();
      if (box is! RenderBox) return;
      // AI 卡片顶部相对屏幕的 y；视口顶部相对屏幕的 y 之差即卡片距视口顶部距离
      // （ScrollContext.storageContext 为非空 BuildContext，无需 null 判断）
      final cardTop = box.localToGlobal(Offset.zero).dy;
      final viewportCtx = sc.position.context.storageContext;
      double viewportTop = 0;
      final vbox = viewportCtx.findRenderObject();
      if (vbox is RenderBox) {
        viewportTop = vbox.localToGlobal(Offset.zero).dy;
      }
      final target = (sc.position.pixels + (cardTop - viewportTop) - 12)
          .clamp(0.0, sc.position.maxScrollExtent)
          .toDouble();
      sc.animateTo(
        target,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  /// 仅当用户接近底部（未上滑回看排盘/历史）时才滚动到 AI 区：
  /// 完成/兜底提示时避免打断用户主动回看的阅读位置。
  void _scrollToAiSectionIfNear() {
    final sc = widget.parentScrollController;
    if (sc == null || !sc.hasClients) return;
    if (sc.position.maxScrollExtent - sc.position.pixels <
        sc.position.viewportDimension * 0.5) {
      _scrollToAiSection();
    }
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
      key: _cardKey,
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
            // 发现 A：流式进行中（_streaming）也隐藏按钮——首个 chunk 后
            // _loading 已复位，若无 _streaming 判断按钮会误现并可能并发触发
            if (!_hasAssistantReply && !_loading && !_streaming) ...[
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
                final isError = m.role == 'error';
                final errColor = isDark
                    ? const Color(0xFFE08A8A)
                    : const Color(0xFFC0392B);
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isError
                        ? (isDark ? const Color(0xFF3A2020) : const Color(0xFFFBEAEA))
                        : isUser
                            ? (isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF0EDE8))
                            : (isDark ? const Color(0xFF252535) : const Color(0xFFFAF6F0)),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isError
                          ? errColor.withAlpha(80)
                          : isUser
                              ? t.withAlpha(20)
                              : p.withAlpha(30),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Icon(
                          isError
                              ? Icons.error_outline
                              : (isUser ? Icons.person : Icons.auto_awesome),
                          size: 14,
                          color: isError ? errColor : (isUser ? t : p),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isError ? '错误' : (isUser ? '你' : 'AI'),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isError ? errColor : (isUser ? t : p),
                          ),
                        ),
                        const Spacer(),
                        // 叉叉：删除这条消息（删除 AI 回复后 _hasAssistantReply 重算，
                        // '开始 AI 解卦'按钮会重新出现；删除追问回复后可重新追问）。
                        // 用 IconButton 提供可靠命中区域（原 GestureDetector+14px Icon
                        // 目标太小，点击易落空），带 tooltip 便于识别用途。
                        IconButton(
                          onPressed: () => _deleteAiMessage(i),
                          tooltip: '删除这条消息',
                          icon: Icon(Icons.close, size: 16,
                              color: t.withAlpha(120)),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                              minWidth: 30, minHeight: 30),
                          visualDensity: VisualDensity.compact,
                          splashRadius: 14,
                        ),
                      ]),
                      const SizedBox(height: 4),
                      if (isError)
                        Text(m.content,
                            style: TextStyle(fontSize: 13, color: errColor))
                      else if (isUser)
                        // '你'卡片展示完整 prompt（仅折叠空白，不截断）：
                        // 用户反馈"提示词显示不全"，完整展示用户提交的内容
                        Text(
                          _displayUserContent(m.content),
                          style: TextStyle(fontSize: 13, color: t),
                        )
                      else if (m.content.trim().isEmpty && identical(m, _streamingMsg))
                        // 流式生成中：内容为空（通常是 DeepSeek 推理模型几十秒
                        // 的思考阶段，只有 reasoning 增量）→ 显示'正在思考…'，
                        // 并把思考过程实时显示为灰色小字（打字机效果），让用户
                        // 明确感知流式输出在进行，而不是毫无动静/以为没流式。
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('正在思考…',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontStyle: FontStyle.italic,
                                    color: p.withAlpha(160))),
                            if (_thinking.trim().isNotEmpty) ...[
                              const SizedBox(height: 4),
                              // 截断显示思考过程（前 400 字符 + …）：推理阶段
                              // 增量高频 setState，思考可能长达数万字，全量渲染
                              // 每帧布局会卡顿；截断既保留"流式进行中"的感知，
                              // 又避免性能问题（完成后的最终消息只含正式答案）。
                              // 整块可点击：弹窗查看完整实时思考（用户反馈
                              // "思考内容输出不完整"——这里给全量入口）。
                              GestureDetector(
                                onTap: _showThinkingDialog,
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: t.withAlpha(8),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '思考过程（点击查看完整，${_thinking.length}字）',
                                        style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: p.withAlpha(170)),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        _thinking.length > 400
                                            ? '${_thinking.substring(0, 400)}…'
                                            : _thinking.trim(),
                                        maxLines: 4,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            fontSize: 11,
                                            fontStyle: FontStyle.italic,
                                            color: t.withAlpha(110)),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ],
                        )
                      else if (m.content.trim().isEmpty)
                        // 旧数据可能残留空 content 的 assistant 消息：显示友好占位，
                        // 不再出现"无内容的 AI 卡片"
                        Text('（空回复）',
                            style: TextStyle(
                                fontSize: 13,
                                fontStyle: FontStyle.italic,
                                color: t.withAlpha(120)))
                      else if (m.isPlainText)
                        // 纯文本消息（"仅推理内容"兜底）：完整展示原文。
                        // 思考过程含大量 Markdown 语法符号，按 Markdown 渲染
                        // 会被吃掉部分内容导致"显示不全"。
                        Text(
                          m.content,
                          style: TextStyle(fontSize: 13, height: 1.5, color: t),
                        )
                      else
                        // 渲染前转义 >>> / <<<：流式期间的原始文本含
                        // " >>>解卦<<< " 标记，而 Markdown 把 ">>>" 解析为
                        // blockquote（引用块）语法，会破坏卡片布局导致
                        // 追问输入框错位到左上角；转义为全角后只当普通文本。
                        Markdown(
                          data: _sanitizeMarkdown(m.content),
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
                      // 思考过程折叠区（AI 消息）：完成后的思考不删除，
                      // 默认收起，点击展开查看完整内容（用户反馈"思考内容
                      // 输出不完整"——流式期间只显示截断小字，这里补全量）。
                      if (!isUser && !isError && m.thinking != null &&
                          m.thinking!.trim().isNotEmpty) ...[
                        const SizedBox(height: 6),
                        _ThinkingCollapseBox(thinking: m.thinking!),
                      ],
                    ],
                  ),
                );
              }),
            ],

            // ── 有 AI 回复时显示追问输入 ──
            // 发现 A：流式进行中（_streaming）隐藏追问区，防止并发请求——
            // 首个 chunk 后 _loading=false 但 _streaming=true，仍需保持隐藏
            if (_hasAssistantReply && !_loading && !_streaming) ...[
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

/// 思考过程折叠区：默认收起，点击展开查看完整思考内容。
/// 用户反馈"思考内容输出不完整""结果出来后应该折叠而不是完全删掉"——
/// 流式期间只显示截断小字，完成后的完整思考在这里可展开查看。
class _ThinkingCollapseBox extends StatefulWidget {
  final String thinking;
  const _ThinkingCollapseBox({required this.thinking});

  @override
  State<_ThinkingCollapseBox> createState() => _ThinkingCollapseBoxState();
}

class _ThinkingCollapseBoxState extends State<_ThinkingCollapseBox> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final t = isDark ? const Color(0xFFE0D5C8) : const Color(0xFF4A3728);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E28) : const Color(0xFFF3EDE4),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: t.withAlpha(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(4),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(children: [
                Icon(
                  _expanded ? Icons.unfold_less : Icons.unfold_more,
                  size: 14,
                  color: t.withAlpha(140),
                ),
                const SizedBox(width: 4),
                Text(
                  _expanded ? '思考过程（点击收起）' : '思考过程（点击展开）',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: t.withAlpha(160)),
                ),
                const Spacer(),
                Text(
                  '${widget.thinking.length}字',
                  style: TextStyle(
                      fontSize: 11, color: t.withAlpha(100)),
                ),
              ]),
            ),
          ),
          if (_expanded) ...[
            const SizedBox(height: 4),
            // 完整思考过程：SelectableText 可长按复制（用户反馈"日志不能复制"；
            // 思考内容含大量符号，纯文本展示避免 Markdown 吃掉内容）。
            SelectableText(
              widget.thinking.trim(),
              style: TextStyle(
                  fontSize: 12, height: 1.5, color: t.withAlpha(150)),
            ),
          ],
        ],
      ),
    );
  }
}
