/// 卦例管理页面
/// 展示已保存的卦例列表，支持搜索、删除和详情查看
library;

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: cases.length,
            separatorBuilder: (_, __) => const Divider(height: 4),
            itemBuilder: (ctx, i) => _buildCaseCard(ctx, cases[i], theme),
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
                    child: Text(c.guaName,
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
                  _chip(theme, c.method),
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
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ]),
              const SizedBox(height: 4),
              Row(children: [
                _infoTag(c.guaName, Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                _infoTag(c.guaGong, t.withAlpha(180)),
                const Spacer(),
                Text('${c.method} · ${c.createdAt.month}/${c.createdAt.day}',
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
}
