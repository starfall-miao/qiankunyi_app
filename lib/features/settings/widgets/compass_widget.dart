/// 二十四山罗盘小工具 — CustomPainter 绘制，支持点击弹出方位信息
library;
import 'dart:math' as math;
import 'package:flutter/material.dart';

/// 二十四山方位数据
const List<Map<String, String>> kTwentyFourMountains = [
  {'name': '壬', 'wx': '水', 'gua': '坎', 'angle': '345'},
  {'name': '子', 'wx': '水', 'gua': '坎', 'angle': '0', 'sx': '鼠', 'dir': '正北'},
  {'name': '癸', 'wx': '水', 'gua': '坎', 'angle': '15'},
  {'name': '丑', 'wx': '土', 'gua': '艮', 'angle': '30', 'sx': '牛'},
  {'name': '艮', 'wx': '土', 'gua': '艮', 'angle': '45', 'dir': '东北'},
  {'name': '寅', 'wx': '木', 'gua': '艮', 'angle': '60', 'sx': '虎'},
  {'name': '甲', 'wx': '木', 'gua': '震', 'angle': '75'},
  {'name': '卯', 'wx': '木', 'gua': '震', 'angle': '90', 'sx': '兔', 'dir': '正东'},
  {'name': '乙', 'wx': '木', 'gua': '震', 'angle': '105'},
  {'name': '辰', 'wx': '土', 'gua': '巽', 'angle': '120', 'sx': '龙'},
  {'name': '巽', 'wx': '木', 'gua': '巽', 'angle': '135', 'dir': '东南'},
  {'name': '巳', 'wx': '火', 'gua': '巽', 'angle': '150', 'sx': '蛇'},
  {'name': '丙', 'wx': '火', 'gua': '离', 'angle': '165'},
  {'name': '午', 'wx': '火', 'gua': '离', 'angle': '180', 'sx': '马', 'dir': '正南'},
  {'name': '丁', 'wx': '火', 'gua': '离', 'angle': '195'},
  {'name': '未', 'wx': '土', 'gua': '坤', 'angle': '210', 'sx': '羊'},
  {'name': '坤', 'wx': '土', 'gua': '坤', 'angle': '225', 'dir': '西南'},
  {'name': '申', 'wx': '金', 'gua': '坤', 'angle': '240', 'sx': '猴'},
  {'name': '庚', 'wx': '金', 'gua': '兑', 'angle': '255'},
  {'name': '酉', 'wx': '金', 'gua': '兑', 'angle': '270', 'sx': '鸡', 'dir': '正西'},
  {'name': '辛', 'wx': '金', 'gua': '兑', 'angle': '285'},
  {'name': '戌', 'wx': '土', 'gua': '乾', 'angle': '300', 'sx': '狗'},
  {'name': '乾', 'wx': '金', 'gua': '乾', 'angle': '315', 'dir': '西北'},
  {'name': '亥', 'wx': '水', 'gua': '乾', 'angle': '330', 'sx': '猪'},
];

class CompassWidget extends StatefulWidget {
  const CompassWidget({super.key});

  @override
  State<CompassWidget> createState() => _CompassWidgetState();
}

class _CompassWidgetState extends State<CompassWidget> {
  int? _selectedIndex;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final t = isDark ? const Color(0xFFE0D5C8) : const Color(0xFF4A3728);
    final gold = const Color(0xFFD4A574);

    return LayoutBuilder(
      builder: (ctx, constraints) {
        final size = math.min(constraints.maxWidth, 320.0).toDouble();
        return GestureDetector(
          onTapDown: (details) {
            final center = size / 2;
            final dx = details.localPosition.dx - center;
            final dy = details.localPosition.dy - center;
            final dist = math.sqrt(dx * dx + dy * dy);
            if (dist > size * 0.15 && dist < size * 0.47) {
              // Convert to angle, 0° = top (north)
              double deg = math.atan2(dx, -dy) * 180 / math.pi;
              if (deg < 0) deg += 360;
              // Find closest mountain
              int best = 0;
              double bestDiff = 360;
              for (int i = 0; i < kTwentyFourMountains.length; i++) {
                final a = double.parse(kTwentyFourMountains[i]['angle']!);
                double diff = (deg - a).abs();
                if (diff > 180) diff = 360 - diff;
                if (diff < bestDiff) {
                  bestDiff = diff;
                  best = i;
                }
              }
              setState(() => _selectedIndex = best);
              _showInfo(ctx, best, isDark, t, gold);
            }
          },
          child: SizedBox(
            width: size,
            height: size,
            child: CustomPaint(
              painter: CompassPainter(
                selectedIndex: _selectedIndex,
                isDark: isDark,
                textColor: t,
                gold: gold,
              ),
            ),
          ),
        );
      },
    );
  }

  void _showInfo(BuildContext ctx, int index, bool dark, Color t, Color gold) {
    final m = kTwentyFourMountains[index];
    showDialog(
      context: ctx,
      builder: (ctx2) => AlertDialog(
        backgroundColor: dark ? const Color(0xFF1A1A2E) : const Color(0xFFF5F0EB),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: gold.withAlpha(25),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(m['name']!, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: gold)),
          ),
          const SizedBox(width: 8),
          Text('二十四山', style: TextStyle(fontSize: 14, color: t.withAlpha(150))),
        ]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoRow('五行', m['wx'] ?? '—', t),
            _infoRow('卦象', m['gua'] ?? '—', t),
            if ((m['sx'] ?? '').isNotEmpty) _infoRow('生肖', m['sx']!, t),
            if ((m['dir'] ?? '').isNotEmpty) _infoRow('方位', m['dir']!, t),
            _infoRow('角度', '${m['angle']}°', t),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx2), child: Text('关闭', style: TextStyle(color: t)))],
      ),
    );
  }

  Widget _infoRow(String label, String value, Color t) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(children: [
        SizedBox(width: 48, child: Text('$label：', style: TextStyle(fontSize: 13, color: t.withAlpha(150)))),
        Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: t)),
      ]),
    );
  }
}

class CompassPainter extends CustomPainter {
  final int? selectedIndex;
  final bool isDark;
  final Color textColor, gold;

  CompassPainter({required this.selectedIndex, required this.isDark, required this.textColor, required this.gold});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final bgPaint = Paint()
      ..color = isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF9F6F2)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, bgPaint);

    // Outer ring border
    final borderPaint = Paint()
      ..color = gold.withAlpha(80)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, radius - 2, borderPaint);
    canvas.drawCircle(center, radius * 0.48, borderPaint);

    // Draw 24 mountains (tick marks + labels)
    for (int i = 0; i < kTwentyFourMountains.length; i++) {
      final m = kTwentyFourMountains[i];
      final angle = double.parse(m['angle']!) * math.pi / 180;
      final isSelected = i == selectedIndex;

      // Tick
      final innerR = radius * 0.48;
      final outerR = radius - 6;
      final tickPaint = Paint()
        ..color = isSelected ? gold : textColor.withAlpha(120)
        ..strokeWidth = isSelected ? 2.5 : 1.0;
      canvas.drawLine(
        Offset(center.dx + innerR * math.sin(angle), center.dy - innerR * math.cos(angle)),
        Offset(center.dx + outerR * math.sin(angle), center.dy - outerR * math.cos(angle)),
        tickPaint,
      );

      // Label
      final textR = radius * 0.73;
      final tp = TextPainter(
        text: TextSpan(
          text: m['name']!,
          style: TextStyle(
            color: isSelected ? gold : textColor,
            fontSize: isSelected ? 13 : 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      )..layout();
      tp.paint(
        canvas,
        Offset(
          center.dx + textR * math.sin(angle) - tp.width / 2,
          center.dy - textR * math.cos(angle) - tp.height / 2,
        ),
      );
    }

    // Inner ring - 八卦
    const baguaNames = ['离', '坤', '兑', '乾', '坎', '艮', '震', '巽'];
    const baguaAngles = [0.0, 45, 90, 135, 180, 225, 270, 315]; // clockwise from top
    for (int i = 0; i < 8; i++) {
      final angle = baguaAngles[i] * math.pi / 180;
      final textR = radius * 0.30;
      final tp = TextPainter(
        text: TextSpan(
          text: baguaNames[i],
          style: TextStyle(
            color: gold,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      )..layout();
      tp.paint(
        canvas,
        Offset(
          center.dx + textR * math.sin(angle) - tp.width / 2,
          center.dy - textR * math.cos(angle) - tp.height / 2,
        ),
      );
    }

    // Center - 太极
    final taiPaint = Paint()..color = gold.withAlpha(100);
    canvas.drawCircle(center, radius * 0.12, taiPaint);
    final tp = TextPainter(
      text: const TextSpan(
        text: '太极',
        style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout();
    tp.paint(canvas, Offset(center.dx - tp.width / 2, center.dy - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant CompassPainter oldDelegate) {
    return oldDelegate.selectedIndex != selectedIndex || oldDelegate.isDark != isDark;
  }
}
