/// 罗盘全屏页面 — 二十四山罗盘小工具
/// 用户点击设置页「小工具 → 罗盘」后跳转到此页
library;

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
        child: Column(
          children: [
            const Spacer(flex: 1),
            // 罗盘控件
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const CompassWidget(),
            ),
            const SizedBox(height: 16),
            // 说明文字
            Text(
              '点击方位查看详细信息',
              style: TextStyle(
                fontSize: 13,
                color: t.withAlpha(150),
              ),
            ),
            const Spacer(flex: 1),
          ],
        ),
      ),
    );
  }
}
