// 关于页面 — 落·乾坤
// 介绍原作者及项目信息，鸣谢素材来源

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/theme_provider.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final tp = context.watch<ThemeProvider>();
    final primary = tp.colorSchemeType.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('关于'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 20),
          // ── Logo + 应用名 ──
          Center(
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    'assets/images/app_icon.png',
                    width: 96,
                    height: 96,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '落·乾坤',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDark ? const Color(0xFFE8E0D8) : const Color(0xFF2C2C2C),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '乾坤易 离线多端版',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? const Color(0xFF888888) : const Color(0xFF888888),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: primary.withAlpha(20),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'v1.0.0',
                    style: TextStyle(fontSize: 12, color: primary),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // ── 致谢 ──
          _sectionCard(
            theme, isDark,
            Icons.volunteer_activism, '致谢',
            [
              '本应用灵感来源于 Gitee 开源项目「乾坤易」六爻排盘工具。',
              '乾坤易由 @ihsang 开发维护，其 Web 版 (hexagram.qiankunyi.com.cn) 提供了出色的排盘体验。',
              '落·乾坤 在此基础上以 Flutter 重构，实现离线多端运行。',
            ],
          ),

          const SizedBox(height: 12),

          // ── 图标素材 ──
          _sectionCard(
            theme, isDark,
            Icons.brush, '图标素材',
            [
              '应用图标由 Pixiv 画师 CyanAutumn 创作。',
              'CyanAutumn 的作品风格独特，为落·乾坤增添了艺术气息。',
              'Pixiv: https://www.pixiv.net/users/CyanAutumn',
            ],
            links: ['Pixiv: pixiv.net/users/CyanAutumn'],
          ),

          const SizedBox(height: 12),

          // ── 技术栈 ──
          _sectionCard(
            theme, isDark,
            Icons.code, '技术栈',
            [
              'Flutter (Dart) — 跨平台 UI 框架',
              'HarmonyOS Sans — 鸿蒙字体',
              'Provider — 状态管理',
              'Drift (SQLite) — 本地持久化',
              'SharedPreferences — 设置存储',
            ],
          ),

          const SizedBox(height: 12),

          // ── 开源许可 ──
          _sectionCard(
            theme, isDark,
            Icons.description_outlined, '开源许可',
            [
              '本应用仅供学习交流使用，请尊重原作者版权。',
              '乾坤易 原始项目版权归原作者 @ihsang 所有。',
              '落·乾坤 修改版遵循 MIT 协议开源。',
            ],
          ),

          const SizedBox(height: 32),

          Center(
            child: Text(
              '© ${DateTime.now().year} 落·乾坤 Contributors\nMade with ❤️ for the I Ching community',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? const Color(0xFF666666) : const Color(0xFFAAAAAA),
              ),
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _sectionCard(
    ThemeData theme, bool isDark,
    IconData icon, String title,
    List<String> lines, {
    List<String>? links,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF5F0EB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF444444) : const Color(0xFFE0D5C8),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, size: 20, color: isDark ? const Color(0xFFE0D5C8) : const Color(0xFF4A3728)),
            const SizedBox(width: 8),
            Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,
                color: isDark ? const Color(0xFFE0D5C8) : const Color(0xFF4A3728))),
          ]),
          const SizedBox(height: 12),
          ...lines.map((line) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(line, style: TextStyle(fontSize: 14,
                color: isDark ? const Color(0xFFCCCCCC) : const Color(0xFF666666), height: 1.5)),
          )),
          if (links != null) ...[
            const SizedBox(height: 4),
            ...links.map((link) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(link, style: TextStyle(fontSize: 13,
                  color: theme.colorScheme.primary, fontFamily: 'monospace')),
            )),
          ],
        ],
      ),
    );
  }
}