/// 罗盘全屏页面 — 二十四山罗盘小工具
/// 用户点击设置页「小工具 → 罗盘」后跳转到此页
library;

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../widgets/compass_widget.dart';

/// 罗盘全屏页面
class CompassPage extends StatelessWidget {
  const CompassPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final t = isDark ? const Color(0xFFE0D5C8) : const Color(0xFF4A3728);
    final bg = isDark ? const Color(0xFF1A1A2E) : const Color(0xFFF5F0EB);

    return Scaffold(
      appBar: AppBar(
        title: Text('罗盘 · 二十四山',
            style: TextStyle(color: t)),
        backgroundColor: bg,
        iconTheme: IconThemeData(color: t),
        elevation: 0,
      ),
      backgroundColor: bg,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (ctx, constraints) {
            // 底部说明文字预留区：16(SizedBox) + 约20(文字) + 16(底部边距)
            const double hintBlock = 52.0;
            // 罗盘基于 min(可用宽-32 边距, 可用高-说明区) 自适应，上限 480，下限 100，
            // 桌面宽屏可放大至 480，手机竖屏/横屏取较小者居中显示且不溢出。
            final double size = math.max(
              math.min(
                math.min(constraints.maxWidth - 32, constraints.maxHeight - hintBlock),
                480.0,
              ),
              100.0,
            );
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: size,
                    height: size,
                    child: const CompassWidget(),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '手机平放时盘面随方位自动旋转；也可点击方位查看详细信息',
                    style: TextStyle(
                      fontSize: 13,
                      color: t.withAlpha(150),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
