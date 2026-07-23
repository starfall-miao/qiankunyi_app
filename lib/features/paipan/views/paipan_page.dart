import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app.dart';
import '../../../core/utils/constants.dart';

/// 排盘主页 - 应用首页
class PaipanPage extends StatelessWidget {
  const PaipanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        actions: [
          IconButton(
            icon: Icon(
              context.watch<ThemeModeProvider>().themeMode == ThemeMode.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            tooltip: '切换主题',
            onPressed: () {
              context.read<ThemeModeProvider>().toggleTheme();
            },
          ),
        ],
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.auto_fix_high,
              size: 64,
              color: Color(0xFF6C3FAA),
            ),
            SizedBox(height: 24),
            Text(
              '乾坤易',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '玄学排盘与案例管理工具',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 32),
            _FeatureGrid(),
          ],
        ),
      ),
    );
  }
}

class _FeatureGrid extends StatelessWidget {
  const _FeatureGrid();

  @override
  Widget build(BuildContext context) {
    final features = [
      _FeatureItem(icon: Icons.science, label: '排盘', subtitle: '八字/紫微/六爻'),
      _FeatureItem(icon: Icons.book, label: '查阅', subtitle: '命理知识参考'),
      _FeatureItem(icon: Icons.folder, label: '案例', subtitle: '案例管理'),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: features
            .map(
              (f) => Column(
                children: [
                  Icon(f.icon, size: 40, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(height: 8),
                  Text(f.label, style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text(f.subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            )
            .toList(),
      ),
    );
  }
}

class _FeatureItem {
  final IconData icon;
  final String label;
  final String subtitle;

  const _FeatureItem({
    required this.icon,
    required this.label,
    required this.subtitle,
  });
}
