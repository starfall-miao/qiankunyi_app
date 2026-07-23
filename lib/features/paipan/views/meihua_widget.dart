/// 梅花易数卦象展示组件
/// 本卦、变卦、互卦三卦并排展示及体用生克
library;

import 'package:flutter/material.dart';
import '../models/paipan_result.dart';
import '../../paipan/views/gua_widget.dart';
import '../../paipan/engines/meihua_engine.dart';

/// 梅花易数排盘展示
class MeihuaResultWidget extends StatelessWidget {
  final PaipanResult result;

  const MeihuaResultWidget({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWide = MediaQuery.of(context).size.width > 600;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 起卦信息
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Icon(Icons.auto_awesome, color: theme.colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  '起卦方式：${result.method}',
                  style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.primary),
                ),
                const Spacer(),
                Text(
                  '${result.paipanTime.month}/${result.paipanTime.day} ${result.paipanTime.hour}:${result.paipanTime.minute.toString().padLeft(2,'0')}',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),

          // 三卦展示
          if (isWide)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _guaColumn(context, '本卦', result.benGua)),
                if (result.bianGua != null) ...[
                  const SizedBox(width: 8),
                  Expanded(child: _guaColumn(context, '变卦', result.bianGua!)),
                ],
                if (result.huGua != null) ...[
                  const SizedBox(width: 8),
                  Expanded(child: _guaColumn(context, '互卦', result.huGua!)),
                ],
              ],
            )
          else
            Column(
              children: [
                _guaColumn(context, '本卦', result.benGua),
                if (result.bianGua != null) _guaColumn(context, '变卦', result.bianGua!),
                if (result.huGua != null) _guaColumn(context, '互卦', result.huGua!),
              ],
            ),

          // 体用生克
          const SizedBox(height: 16),
          _buildTiYongCard(context),
        ],
      ),
    );
  }

  Widget _guaColumn(BuildContext context, String label, dynamic gua) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, top: 8),
          child: Text(label, style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold)),
        ),
        GuaWidget(gua: gua),
      ],
    );
  }

  Widget _buildTiYongCard(BuildContext context) {
    final tiYong = MeihuaEngine.getTiYong(result);
    final theme = Theme.of(context);

    // 判断吉凶类型
    Color bgColor;
    IconData icon;
    if (tiYong.contains('比和')) {
      bgColor = Colors.green.shade50;
      icon = Icons.check_circle_outline;
    } else if (tiYong.contains('用生体') || tiYong.contains('进益')) {
      bgColor = Colors.green.shade50;
      icon = Icons.trending_up;
    } else if (tiYong.contains('用克体') || tiYong.contains('凶险')) {
      bgColor = Colors.red.shade50;
      icon = Icons.warning_amber_outlined;
    } else if (tiYong.contains('体克用')) {
      bgColor = Colors.orange.shade50;
      icon = Icons.auto_fix_high;
    } else {
      bgColor = Colors.grey.shade50;
      icon = Icons.info_outline;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: bgColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: theme.colorScheme.primary, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                tiYong,
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
