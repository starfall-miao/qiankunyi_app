/// 梅花易数卦象展示组件 — 国风紧凑版
/// 本卦、变卦、互卦三卦并排展示及体用生克
import 'package:flutter/material.dart';
import '../models/paipan_result.dart';
import '../models/gua_model.dart';
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
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 起卦信息
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Icon(Icons.auto_awesome,
                  color: isDark ? const Color(0xFFE0D5C8) : const Color(0xFF4A3728),
                  size: 18),
              const SizedBox(width: 6),
              Text(
                result.method,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? const Color(0xFFE0D5C8) : const Color(0xFF4A3728),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Text(
                '${result.paipanTime.month}/${result.paipanTime.day} ${result.paipanTime.hour}:${result.paipanTime.minute.toString().padLeft(2, '0')}',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? const Color(0xFF888888) : const Color(0xFF888888),
                ),
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
              if (result.bianGua != null)
                _guaColumn(context, '变卦', result.bianGua!),
              if (result.huGua != null)
                _guaColumn(context, '互卦', result.huGua!),
            ],
          ),

        // 体用生克
        const SizedBox(height: 12),
        _buildTiYongCard(context),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _guaColumn(BuildContext context, String label, GuaModel gua) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, top: 6),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isDark ? const Color(0xFFE0D5C8) : const Color(0xFF4A3728),
            ),
          ),
        ),
        const SizedBox(height: 4),
        GuaWidget(gua: gua),
      ],
    );
  }

  Widget _buildTiYongCard(BuildContext context) {
    final tiYong = MeihuaEngine.getTiYong(result);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Color bgColor;
    Color borderColor;
    Color textColor;
    IconData icon;

    if (tiYong.contains('比和')) {
      bgColor = isDark ? const Color(0xFF1B3A1B) : const Color(0xFFE8F5E9);
      borderColor = const Color(0xFF2E7D32);
      textColor = const Color(0xFF2E7D32);
      icon = Icons.check_circle_outline;
    } else if (tiYong.contains('用生体') || tiYong.contains('进益')) {
      bgColor = isDark ? const Color(0xFF1B3A1B) : const Color(0xFFE8F5E9);
      borderColor = const Color(0xFF2E7D32);
      textColor = const Color(0xFF2E7D32);
      icon = Icons.trending_up;
    } else if (tiYong.contains('用克体') || tiYong.contains('凶险')) {
      bgColor = isDark ? const Color(0xFF3A1B1B) : const Color(0xFFFFEBEE);
      borderColor = const Color(0xFFD32F2F);
      textColor = const Color(0xFFD32F2F);
      icon = Icons.warning_amber_outlined;
    } else if (tiYong.contains('体克用')) {
      bgColor = isDark ? const Color(0xFF3A2E1B) : const Color(0xFFFFF3E0);
      borderColor = const Color(0xFFEF6C00);
      textColor = const Color(0xFFEF6C00);
      icon = Icons.auto_fix_high;
    } else {
      bgColor = isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF5F5F5);
      borderColor = isDark ? const Color(0xFF444444) : const Color(0xFFE0E0E0);
      textColor = isDark ? const Color(0xFFE0D5C8) : const Color(0xFF4A3728);
      icon = Icons.info_outline;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor.withAlpha(80)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: textColor, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              tiYong,
              style: TextStyle(fontSize: 13, color: textColor),
            ),
          ),
        ],
      ),
    );
  }
}