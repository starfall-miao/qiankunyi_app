/// 落·乾坤 - 二十四山罗盘小工具
///
/// 使用 CustomPainter 绘制传统风水罗盘，支持点击交互。
/// 国风配色：#F5F0EB / #4A3728 / #D4A574

import 'dart:math' as math;
import 'package:flutter/material.dart';

// ═══════════════════════════════════════════════════════════════
//  数据
// ═══════════════════════════════════════════════════════════════

/// 二十四山方位信息
class MountainInfo {
  final String name;
  final String wuXing;
  final String gua;
  final double startAngle; // 起始角度（度），0° = 正北
  final String shengXiao;
  final String directionLabel;

  const MountainInfo({
    required this.name,
    required this.wuXing,
    required this.gua,
    required this.startAngle,
    this.shengXiao = '',
    this.directionLabel = '',
  });
}

/// 二十四山完整列表（从 子/北 开始，顺时针 15° 一格）
const kTwentyFourMountains = <MountainInfo>[
  MountainInfo(name: '子', wuXing: '水', gua: '坎', startAngle: 0,   shengXiao: '鼠', directionLabel: '正北'),
  MountainInfo(name: '癸', wuXing: '水', gua: '坎', startAngle: 15,  shengXiao: '',   directionLabel: '北偏东'),
  MountainInfo(name: '丑', wuXing: '土', gua: '艮', startAngle: 30,  shengXiao: '牛', directionLabel: '东北偏北'),
  MountainInfo(name: '艮', wuXing: '土', gua: '艮', startAngle: 45,  shengXiao: '',   directionLabel: '东北'),
  MountainInfo(name: '寅', wuXing: '木', gua: '艮', startAngle: 60,  shengXiao: '虎', directionLabel: '东北偏东'),
  MountainInfo(name: '甲', wuXing: '木', gua: '震', startAngle: 75,  shengXiao: '',   directionLabel: '东偏北'),
  MountainInfo(name: '卯', wuXing: '木', gua: '震', startAngle: 90,  shengXiao: '兔', directionLabel: '正东'),
  MountainInfo(name: '乙', wuXing: '木', gua: '震', startAngle: 105, shengXiao: '',   directionLabel: '东偏南'),
  MountainInfo(name: '辰', wuXing: '土', gua: '巽', startAngle: 120, shengXiao: '龙', directionLabel: '东南偏东'),
  MountainInfo(name: '巽', wuXing: '木', gua: '巽', startAngle: 135, shengXiao: '',   directionLabel: '东南'),
  MountainInfo(name: '巳', wuXing: '火', gua: '巽', startAngle: 150, shengXiao: '蛇', directionLabel: '东南偏南'),
  MountainInfo(name: '丙', wuXing: '火', gua: '离', startAngle: 165, shengXiao: '',   directionLabel: '南偏东'),
  MountainInfo(name: '午', wuXing: '火', gua: '离', startAngle: 180, shengXiao: '马', directionLabel: '正南'),
  MountainInfo(name: '丁', wuXing: '火', gua: '离', startAngle: 195, shengXiao: '',   directionLabel: '南偏西'),
  MountainInfo(name: '未', wuXing: '土', gua: '坤', startAngle: 210, shengXiao: '羊', directionLabel: '西南偏南'),
  MountainInfo(name: '坤', wuXing: '土', gua: '坤', startAngle: 225, shengXiao: '',   directionLabel: '西南'),
  MountainInfo(name: '申', wuXing: '金', gua: '坤', startAngle: 240, shengXiao: '猴', directionLabel: '西南偏西'),
  MountainInfo(name: '庚', wuXing: '金', gua: '兑', startAngle: 255, shengXiao: '',   directionLabel: '西偏南'),
  MountainInfo(name: '酉', wuXing: '金', gua: '兑', startAngle: 270, shengXiao: '鸡', directionLabel: '正西'),
  MountainInfo(name: '辛', wuXing: '金', gua: '兑', startAngle: 285, shengXiao: '',   directionLabel: '西偏北'),
  MountainInfo(name: '戌', wuXing: '土', gua: '乾', startAngle: 300, shengXiao: '狗', directionLabel: '西北偏西'),
  MountainInfo(name: '乾', wuXing: '金', gua: '乾', startAngle: 315, shengXiao: '',   directionLabel: '西北'),
  MountainInfo(name: '亥', wuXing: '水', gua: '乾', startAngle: 330, shengXiao: '猪', directionLabel: '西北偏北'),
  MountainInfo(name: '壬', wuXing: '水', gua: '坎', startAngle: 345, shengXiao: '',   directionLabel: '北偏西'),
];

/// 后天八卦数据（位置角度从 坎/北 0° 开始，45° 间隔）
const kPostHeavenTrigrams = <Map<String, dynamic>>[
  {'name': '坎', 'wuXing': '水', 'angle': 0.0, 'direction': '北'},
  {'name': '艮', 'wuXing': '土', 'angle': 45.0, 'direction': '东北'},
  {'name': '震', 'wuXing': '木', 'angle': 90.0, 'direction': '东'},
  {'name': '巽', 'wuXing': '木', 'angle': 135.0, 'direction': '东南'},
  {'name': '离', 'wuXing': '火', 'angle': 180.0, 'direction': '南'},
  {'name': '坤', 'wuXing': '土', 'angle': 225.0, 'direction': '西南'},
  {'name': '兑', 'wuXing': '金', 'angle': 270.0, 'direction': '西'},
  {'name': '乾', 'wuXing': '金', 'angle': 315.0, 'direction': '西北'},
];

/// 十二地支数据（30° 间隔）
const kTwelveBranches = <Map<String, dynamic>>[
  {'name': '子', 'shengXiao': '鼠', 'angle': 0.0},
  {'name': '丑', 'shengXiao': '牛', 'angle': 30.0},
  {'name': '寅', 'shengXiao': '虎', 'angle': 60.0},
  {'name': '卯', 'shengXiao': '兔', 'angle': 90.0},
  {'name': '辰', 'shengXiao': '龙', 'angle': 120.0},
  {'name': '巳', 'shengXiao': '蛇', 'angle': 150.0},
  {'name': '午', 'shengXiao': '马', 'angle': 180.0},
  {'name': '未', 'shengXiao': '羊', 'angle': 210.0},
  {'name': '申', 'shengXiao': '猴', 'angle': 240.0},
  {'name': '酉', 'shengXiao': '鸡', 'angle': 270.0},
  {'name': '戌', 'shengXiao': '狗', 'angle': 300.0},
  {'name': '亥', 'shengXiao': '猪', 'angle': 330.0},
];

// ═══════════════════════════════════════════════════════════════
//  Widget
// ═══════════════════════════════════════════════════════════════

/// 二十四山罗盘 Widget
///
/// 绘制三个同心圆环（外→内：24山 → 后天八卦 → 十二地支）。
/// 点击方位弹出详细信息对话框。
class CompassWidget extends StatefulWidget {
  const CompassWidget({super.key});

  @override
  State<CompassWidget> createState() => _CompassWidgetState();
}

class _CompassWidgetState extends State<CompassWidget> {
  int? _selectedIndex;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final available = constraints.maxWidth;
        final size = available < 280 ? available : 280.0;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 罗盘
            GestureDetector(
              onTapDown: (details) => _handleTap(details, size),
              child: CustomPaint(
                size: Size(size, size),
                painter: CompassPainter(selectedIndex: _selectedIndex),
              ),
            ),
            const SizedBox(height: 8),
            // 提示文字
            Text(
              _selectedIndex != null
                  ? '已选: ${kTwentyFourMountains[_selectedIndex!].name} 山  ·  点击其他方位查看'
                  : '点击查看方位信息',
              style: TextStyle(
                fontSize: 12,
                color: const Color(0xFF4A3728).withAlpha(150),
              ),
            ),
          ],
        );
      },
    );
  }

  /// 处理点击，计算点击角度对应的方位索引
  void _handleTap(TapDownDetails details, double size) {
    final center = size / 2;
    final dx = details.localPosition.dx - center;
    final dy = details.localPosition.dy - center;
    final dist = math.sqrt(dx * dx + dy * dy);

    // 只在罗盘有效半径内响应
    final outerRadius = size / 2 - 4;
    if (dist > outerRadius || dist < size * 0.08) return;

    // 计算角度：atan2 返回 -π~π，0 = East
    // 转换为罗盘角度：0° = North，顺时针
    double angleDeg = (math.atan2(dx, -dy) * 180 / math.pi);
    if (angleDeg < 0) angleDeg += 360;

    // 找到对应的方位
    final idx = _hitTestAngle(angleDeg);
    if (idx == null) return;

    setState(() => _selectedIndex = idx);
    _showMountainInfo(context, idx);
  }

  /// 根据角度命中测试，返回二十四山索引
  int? _hitTestAngle(double angleDeg) {
    // 每个山占 15°，从 子(0°) 开始
    for (int i = 0; i < kTwentyFourMountains.length; i++) {
      final start = kTwentyFourMountains[i].startAngle;
      final end = start + 15.0;
      if (angleDeg >= start && angleDeg < end) return i;
    }
    // 环绕处理：345°-360° 对应最后一个山（壬，索引 23）
    if (angleDeg >= 345 && angleDeg < 360) return 23;
    return null;
  }

  /// 弹出方位详细信息对话框
  void _showMountainInfo(BuildContext context, int index) {
    final info = kTwentyFourMountains[index];
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) {
        final t = Theme.of(ctx);
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF5F0EB),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFFD4A574), width: 1.5),
          ),
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${info.name}山',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF4A3728),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFD4A574).withAlpha(40),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  info.directionLabel,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF8D6E63),
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _infoRow('五行', info.wuXing, _wuXingColor(info.wuXing)),
              const SizedBox(height: 10),
              _infoRow('卦象', info.gua, const Color(0xFF4A3728)),
              const SizedBox(height: 10),
              _infoRow('方位', '${info.startAngle.toInt()}° — ${(info.startAngle + 15).toInt()}°', const Color(0xFF8D6E63)),
              if (info.shengXiao.isNotEmpty) ...[
                const SizedBox(height: 10),
                _infoRow('生肖', info.shengXiao, const Color(0xFFD4A574)),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text(
                '关闭',
                style: TextStyle(color: Color(0xFF8D6E63)),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _infoRow(String label, String value, Color valueColor) {
    return Row(
      children: [
        SizedBox(
          width: 48,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF8D6E63),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: valueColor.withAlpha(20),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: valueColor.withAlpha(40)),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: valueColor,
            ),
          ),
        ),
      ],
    );
  }

  Color _wuXingColor(String wx) {
    switch (wx) {
      case '金': return const Color(0xFFD4A574);
      case '木': return const Color(0xFF5B8C5A);
      case '水': return const Color(0xFF4A7BA7);
      case '火': return const Color(0xFFC0392B);
      case '土': return const Color(0xFF8D6E63);
      default: return const Color(0xFF4A3728);
    }
  }
}

// ═══════════════════════════════════════════════════════════════
//  Painter
// ═══════════════════════════════════════════════════════════════

class CompassPainter extends CustomPainter {
  final int? selectedIndex;

  CompassPainter({this.selectedIndex});

  // 国风配色
  static const Color kBgBeige = Color(0xFFF5F0EB);
  static const Color kDarkBrown = Color(0xFF4A3728);
  static const Color kGold = Color(0xFFD4A574);
  static const Color kBrownLight = Color(0xFF8D6E63);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerR = size.width / 2 - 4;
    if (outerR <= 0) return;

    _drawBackground(canvas, center, outerR);
    _drawRingBorders(canvas, center, outerR);
    _drawOuterRing(canvas, center, outerR);   // 24 山
    _drawMiddleRing(canvas, center, outerR);  // 后天八卦
    _drawInnerRing(canvas, center, outerR);   // 十二地支
    _drawCenterLabel(canvas, center, outerR);
    _drawNorthIndicator(canvas, center, outerR);
  }

  // ── 背景 ──

  void _drawBackground(Canvas canvas, Offset center, double outerR) {
    final paint = Paint()
      ..color = kBgBeige
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, outerR, paint);

    // 外圈描边
    final border = Paint()
      ..color = kDarkBrown
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, outerR, border);
  }

  // ── 三个圆环的分界线 ──

  void _drawRingBorders(Canvas canvas, Offset center, double outerR) {
    final radii = _ringRadii(outerR);
    final paint = Paint()
      ..color = kDarkBrown.withAlpha(120)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (final r in [radii['outerInner']!, radii['midInner']!]) {
      canvas.drawCircle(center, r, paint);
    }

    // 中心小圆
    canvas.drawCircle(center, radii['center']!, paint);
  }

  // ── 外环：二十四山 ──

  void _drawOuterRing(Canvas canvas, Offset center, double outerR) {
    final radii = _ringRadii(outerR);
    final outerMid = (outerR + radii['outerInner']!) / 2;
    final segAngle = 15.0; // 每山 15°

    for (int i = 0; i < kTwentyFourMountains.length; i++) {
      final mtn = kTwentyFourMountains[i];
      // 每山中心角度
      final midAngle = mtn.startAngle + segAngle / 2;
      final isSelected = selectedIndex == i;

      // 高亮扇形
      if (isSelected) {
        _drawHighlightSector(canvas, center, outerR, radii['outerInner']!,
            mtn.startAngle, mtn.startAngle + segAngle);
      }

      // 分割线
      final lineAngle = _compassToCanvas(mtn.startAngle);
      final linePaint = Paint()
        ..color = kDarkBrown.withAlpha(80)
        ..strokeWidth = 0.5;
      canvas.drawLine(
        center + Offset(radii['outerInner']! * cos(lineAngle), radii['outerInner']! * sin(lineAngle)),
        center + Offset(outerR * cos(lineAngle), outerR * sin(lineAngle)),
        linePaint,
      );

      // 文字
      _drawRadialText(canvas, center, outerMid, midAngle, mtn.name,
          isSelected ? kGold : kDarkBrown, 13, isSelected);
    }
  }

  // ── 中环：后天八卦 ──

  void _drawMiddleRing(Canvas canvas, Offset center, double outerR) {
    final radii = _ringRadii(outerR);
    final midR = (radii['outerInner']! + radii['midInner']!) / 2;

    for (int i = 0; i < kPostHeavenTrigrams.length; i++) {
      final g = kPostHeavenTrigrams[i];
      final angle = (g['angle'] as double) + 22.5; // 偏移使八卦位于两组24山之间

      // 分割线
      final lineAngle = _compassToCanvas(angle);
      final linePaint = Paint()
        ..color = kDarkBrown.withAlpha(60)
        ..strokeWidth = 0.5;
      canvas.drawLine(
        center + Offset(radii['midInner']! * cos(lineAngle), radii['midInner']! * sin(lineAngle)),
        center + Offset(radii['outerInner']! * cos(lineAngle), radii['outerInner']! * sin(lineAngle)),
        linePaint,
      );

      // 文字（八卦文字稍微偏移 22.5° 使其与24山交错显示）
      final labelAngle = (g['angle'] as double) + 22.5;
      _drawRadialText(canvas, center, midR, labelAngle, g['name'] as String,
          kDarkBrown, 14, false);
    }
  }

  // ── 内环：十二地支 ──

  void _drawInnerRing(Canvas canvas, Offset center, double outerR) {
    final radii = _ringRadii(outerR);
    final innerR = (radii['midInner']! + radii['center']!) / 2;

    for (int i = 0; i < kTwelveBranches.length; i++) {
      final b = kTwelveBranches[i];
      final angle = (b['angle'] as double) + 7.5; // 偏移对齐 24 山

      // 分割线
      final lineAngle = _compassToCanvas(b['angle'] as double);
      final linePaint = Paint()
        ..color = kDarkBrown.withAlpha(50)
        ..strokeWidth = 0.5;
      canvas.drawLine(
        center + Offset(radii['center']! * cos(lineAngle), radii['center']! * sin(lineAngle)),
        center + Offset(radii['midInner']! * cos(lineAngle), radii['midInner']! * sin(lineAngle)),
        linePaint,
      );

      // 文字
      _drawRadialText(canvas, center, innerR, angle, b['name'] as String,
          const Color(0xFF6D4C2A), 12, false);
    }
  }

  // ── 中心 ──

  void _drawCenterLabel(Canvas canvas, Offset center, double outerR) {
    final radii = _ringRadii(outerR);
    final r = radii['center']!;

    // 阴阳鱼或八卦符号可用小圆示意，此处简化为 "乾坤" 文字
    final textPainter = TextPainter(
      text: TextSpan(
        text: '易',
        style: TextStyle(
          color: kGold,
          fontSize: r * 0.9,
          fontWeight: FontWeight.bold,
          fontFamily: 'serif',
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout();
    textPainter.paint(
      canvas,
      center - Offset(textPainter.width / 2, textPainter.height / 2),
    );
  }

  // ── 北向指示 ──

  void _drawNorthIndicator(Canvas canvas, Offset center, double outerR) {
    // 在正北（子山）外侧画一个小三角指示
    final tipR = outerR + 6;
    final baseR = outerR - 2;
    final tip = center + Offset(0, -tipR);
    final baseLeft = center + Offset(-5, -baseR);
    final baseRight = center + Offset(5, -baseR);

    final paint = Paint()
      ..color = const Color(0xFFC0392B) // 红色指示
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(baseLeft.dx, baseLeft.dy)
      ..lineTo(baseRight.dx, baseRight.dy)
      ..close();
    canvas.drawPath(path, paint);

    // 外圈缺口让三角可见（用一个背景色覆盖下面一小段）
  }

  // ── 辅助 ──

  /// 获取三个环的半径
  Map<String, double> _ringRadii(double outerR) {
    // 外环：outerR ~ outerR * 0.68
    // 中环：outerR * 0.68 ~ outerR * 0.45
    // 内环：outerR * 0.45 ~ outerR * 0.18
    // 中心：outerR * 0.18
    return {
      'outerInner': outerR * 0.68,
      'midInner': outerR * 0.45,
      'center': outerR * 0.18,
    };
  }

  /// 将罗盘角度（0°=北，顺时针）转为 canvas 弧度（0=东，逆时针）
  double _compassToCanvas(double angleDeg) {
    return (angleDeg * math.pi / 180) - math.pi / 2;
  }

  /// 绘制高亮扇形
  void _drawHighlightSector(Canvas canvas, Offset center, double outerR,
      double innerR, double startDeg, double endDeg) {
    final start = _compassToCanvas(startDeg);
    final end = _compassToCanvas(endDeg);
    final paint = Paint()
      ..color = kGold.withAlpha(35)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(
        center.dx + innerR * cos(start),
        center.dy + innerR * sin(start),
      )
      ..arcTo(
        Rect.fromCircle(center: center, radius: innerR),
        start,
        end - start,
        true,
      )
      ..lineTo(
        center.dx + outerR * cos(end),
        center.dy + outerR * sin(end),
      )
      ..arcTo(
        Rect.fromCircle(center: center, radius: outerR),
        end,
        start - end,
        false,
      )
      ..close();
    canvas.drawPath(path, paint);

    // 高亮描边
    final borderPaint = Paint()
      ..color = kGold
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawPath(path, borderPaint);
  }

  /// 沿径向绘制文字
  void _drawRadialText(Canvas canvas, Offset center, double radius,
      double angleDeg, String text, Color color, double fontSize, bool bold) {
    final canvasAngle = _compassToCanvas(angleDeg);
    final pos = Offset(
      center.dx + radius * cos(canvasAngle),
      center.dy + radius * sin(canvasAngle),
    );

    canvas.save();
    canvas.translate(pos.dx, pos.dy);

    // 判断文字是否需要翻转（下半圆翻转使文字始终可读）
    // 在 canvas 坐标中 -π/2 到 π/2 是右半部分（罗盘下半部分）
    final normalized = canvasAngle % (2 * math.pi);
    final flip = normalized > math.pi / 2 && normalized < 3 * math.pi / 2;

    if (flip) {
      canvas.rotate(canvasAngle + math.pi);
    } else {
      canvas.rotate(canvasAngle);
    }

    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: bold ? FontWeight.bold : FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout();

    tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
    canvas.restore();
  }

  @override
  bool shouldRepaint(CompassPainter oldDelegate) {
    return oldDelegate.selectedIndex != selectedIndex;
  }
}
