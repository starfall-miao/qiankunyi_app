// 落·乾坤 - 聚光灯引导组件
// 以聚光灯效果逐步高亮界面控件，引导用户完成核心流程
import 'dart:ui';

import 'package:flutter/material.dart';

/// 引导步骤：高亮一个目标控件并显示说明
class SpotlightStep {
  final GlobalKey targetKey; // 目标控件 key
  final String title;        // 步骤标题
  final String desc;         // 说明文字
  const SpotlightStep({
    required this.targetKey,
    required this.title,
    required this.desc,
  });
}

/// 聚光灯引导遮罩
class SpotlightOverlay extends StatefulWidget {
  final List<SpotlightStep> steps;
  final VoidCallback onFinish;
  final VoidCallback onSkip;
  const SpotlightOverlay({
    super.key,
    required this.steps,
    required this.onFinish,
    required this.onSkip,
  });

  @override
  State<SpotlightOverlay> createState() => _SpotlightOverlayState();
}

class _SpotlightOverlayState extends State<SpotlightOverlay> {
  int _index = 0;

  /// 当前步骤目标控件在全局坐标中的矩形
  Rect? get _targetRect {
    final ctx = widget.steps[_index].targetKey.currentContext;
    if (ctx == null) return null;
    final box = ctx.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize || !box.attached) return null;
    final offset = box.localToGlobal(Offset.zero);
    return offset & box.size;
  }

  @override
  Widget build(BuildContext context) {
    final step = widget.steps[_index];
    final rect = _targetRect;
    final size = MediaQuery.of(context).size;
    final scheme = Theme.of(context).colorScheme;

    return Stack(
      children: [
        // 遮罩 + 聚光灯挖空
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: _SpotlightPainter(
                hole: rect,
                baseColor: Colors.black.withOpacity(0.62),
                borderColor: scheme.primary,
              ),
            ),
          ),
        ),
        // 说明气泡（目标下方）
        if (rect != null)
          Positioned(
            left: 12,
            right: 12,
            bottom: MediaQuery.of(context).padding.bottom + 120,
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(step.title,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text(step.desc,
                        style: TextStyle(
                            fontSize: 13,
                            height: 1.6,
                            color: scheme.onSurface.withAlpha(180))),
                    const SizedBox(height: 10),
                    Row(children: [
                      Text('${_index + 1}/${widget.steps.length}',
                          style: TextStyle(
                              fontSize: 12, color: scheme.onSurface.withAlpha(120))),
                      const Spacer(),
                      TextButton(
                          onPressed: widget.onSkip, child: const Text('跳过')),
                      const SizedBox(width: 4),
                      FilledButton(
                        onPressed: _index < widget.steps.length - 1
                            ? () => setState(() => _index++)
                            : widget.onFinish,
                        child: Text(_index < widget.steps.length - 1 ? '下一步' : '完成'),
                      ),
                    ]),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// 聚光灯绘制器：暗色背景 + 目标区域挖空 + 描边
class _SpotlightPainter extends CustomPainter {
  final Rect? hole;
  final Color baseColor;
  final Color borderColor;
  _SpotlightPainter({
    required this.hole,
    required this.baseColor,
    required this.borderColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 全屏暗色
    final paint = Paint()..color = baseColor;
    canvas.drawRect(Offset.zero & size, paint);

    // 目标区域挖空（用 BlurMaskFilter 让边缘柔化，形成聚光灯效果）
    if (hole != null) {
      final rrect = RRect.fromRectAndRadius(
        hole!.inflate(8),
        const Radius.circular(12),
      );
      final clear = Paint()
        ..color = Colors.black
        ..blendMode = BlendMode.clear
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawRRect(rrect, clear);
      // 描边
      final border = Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          hole!.inflate(8),
          const Radius.circular(12),
        ),
        border,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SpotlightPainter old) =>
      old.hole != hole || old.baseColor != baseColor;
}
