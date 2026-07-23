/// 卦例管理页面
/// 展示已保存的卦例列表，支持搜索、删除和详情查看
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/case_provider.dart';
import '../models/case_models.dart';

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
      context.read<CaseProvider>().loadDemoData();
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
                  Text('排盘后可将结果保存为卦例', style: theme.textTheme.bodySmall,),
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
    return Card(
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
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(c.guaName, style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onPrimaryContainer)),
                  ),
                  const SizedBox(width: 8),
                  Text(c.guaGong, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                  const Spacer(),
                  Text(c.method, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                ],
              ),
              const SizedBox(height: 8),
              Text(c.title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
              if (c.notes != null && c.notes!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(c.notes!, style: theme.textTheme.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.access_time, size: 14, color: theme.colorScheme.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Text(
                    '${c.createdAt.month}/${c.createdAt.day} ${c.createdAt.hour}:${c.createdAt.minute.toString().padLeft(2, '0')}',
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                  const Spacer(),
                  if (c.tags.isNotEmpty)
                    ...c.tags.map((t) => Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(t, style: const TextStyle(fontSize: 10)),
                      ),
                    )),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 卦例详情
  void _showCaseDetail(BuildContext context, CaseModel c) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.85,
          minChildSize: 0.4,
          expand: false,
          builder: (_, scrollCtrl) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: ListView(
                controller: scrollCtrl,
                children: [
                  Text(c.title, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(children: [
                    _chip(c.guaName, theme.colorScheme.primaryContainer, theme.colorScheme.onPrimaryContainer),
                    const SizedBox(width: 8),
                    _chip(c.guaGong, Colors.grey.shade200, Colors.grey.shade800),
                    const SizedBox(width: 8),
                    _chip(c.method, Colors.blue.shade50, Colors.blue.shade800),
                  ]),
                  const SizedBox(height: 16),
                  if (c.notes != null && c.notes!.isNotEmpty) ...[
                    Text('备注', style: theme.textTheme.labelLarge),
                    const SizedBox(height: 4),
                    Text(c.notes!, style: theme.textTheme.bodyMedium),
                    const SizedBox(height: 12),
                  ],
                  Text('创建时间', style: theme.textTheme.labelLarge),
                  Text('${c.createdAt.year}-${c.createdAt.month.toString().padLeft(2,'0')}-${c.createdAt.day.toString().padLeft(2,'0')} ${c.createdAt.hour}:${c.createdAt.minute.toString().padLeft(2,'0')}'),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('删除卦例'),
                    style: FilledButton.styleFrom(backgroundColor: Colors.red.shade100, foregroundColor: Colors.red.shade800),
                    onPressed: () {
                      if (c.id != null) {
                        context.read<CaseProvider>().deleteCase(c.id!);
                        Navigator.of(ctx).pop();
                      }
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _chip(String label, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Text(label, style: TextStyle(fontSize: 12, color: fg)),
    );
  }

  /// 搜索
  void _showSearch(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('搜索卦例'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: '输入卦名、标题或备注...',
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: (v) => context.read<CaseProvider>().setSearchQuery(v),
        ),
        actions: [
          TextButton(
            onPressed: () {
              context.read<CaseProvider>().setSearchQuery('');
              Navigator.of(ctx).pop();
            },
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}
