// 落·乾坤 - 主题配置
// 支持多种传统配色方案

import 'package:flutter/material.dart';

/// 配色方案枚举
enum ColorSchemeType {
  xuanZi('玄紫', Color(0xFF6C3FAA), Color(0xFF3F1C6B)),      // 默认：紫
  cangQing('藏青', Color(0xFF1A5276), Color(0xFF0E2F44)),     // 藏蓝
  chiHong('赤红', Color(0xFFB03A2E), Color(0xFF7B241C)),      // 朱红
  moLu('墨绿', Color(0xFF1E8449), Color(0xFF0E4D2A)),         // 墨绿
  qiuHuang('秋黄', Color(0xFFB7950B), Color(0xFF7D6608)),     // 金色
  yanZhi('胭脂', Color(0xFFC0392B), Color(0xFF78281F)),       // 胭脂红
  qingLan('青蓝', Color(0xFF2E86C1), Color(0xFF1B4F72)),      // 青蓝
  songYan('松烟', Color(0xFF4A4A4A), Color(0xFF2C2C2C)),      // 松烟灰

  final String label;
  final Color primary;
  final Color primaryDark;
  const ColorSchemeType(this.label, this.primary, this.primaryDark);
}

/// 主题配置
class AppTheme {
  AppTheme._();

  /// 获取对应配色方案的亮色主题
  static ThemeData lightTheme(ColorSchemeType type, {bool useAcrylic = false}) {
    final primary = type.primary;
    final secondary = _secondaryColor(type);

    final colorScheme = ColorScheme.light(
      primary: primary,
      secondary: secondary,
      surface: Colors.white,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: const Color(0xFF2C2C2C),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamily: 'HarmonyOS_Sans_SC',
      scaffoldBackgroundColor: const Color(0xFFF5F0EB),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: useAcrylic ? Colors.transparent : Colors.white,
        foregroundColor: const Color(0xFF2C2C2C),
        titleTextStyle: const TextStyle(
          color: Color(0xFF2C2C2C),
          fontSize: 18,
          fontWeight: FontWeight.w600,
          fontFamily: 'HarmonyOS_Sans_SC',
        ),
      ),
      cardTheme: CardThemeData(
        elevation: useAcrylic ? 0 : 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: useAcrylic ? Colors.white.withAlpha(200) : Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      dividerTheme: const DividerThemeData(
        space: 1,
        thickness: 1,
        color: Color(0xFFE0D8CC),
      ),
      navigationBarTheme: NavigationBarThemeData(
        indicatorColor: primary.withAlpha(30),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(
              fontFamily: 'HarmonyOS_Sans_SC',
              fontWeight: FontWeight.w600,
              color: primary,
            );
          }
          return TextStyle(fontFamily: 'HarmonyOS_Sans_SC');
        }),
      ),
    );
  }

  /// 获取对应配色方案的暗色主题
  static ThemeData darkTheme(ColorSchemeType type, {bool useAcrylic = false}) {
    final primary = type.primary;
    final secondary = _secondaryColor(type);

    final colorScheme = ColorScheme.dark(
      primary: primary,
      secondary: secondary,
      surface: const Color(0xFF2C2C2C),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: const Color(0xFFE8E0D8),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamily: 'HarmonyOS_Sans_SC',
      scaffoldBackgroundColor: const Color(0xFF1A1A2E),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: useAcrylic ? Colors.transparent : const Color(0xFF1A1A2E),
        foregroundColor: const Color(0xFFE8E0D8),
        titleTextStyle: const TextStyle(
          color: Color(0xFFE8E0D8),
          fontSize: 18,
          fontWeight: FontWeight.w600,
          fontFamily: 'HarmonyOS_Sans_SC',
        ),
      ),
      cardTheme: CardThemeData(
        elevation: useAcrylic ? 0 : 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: useAcrylic ? const Color(0xFF2C2C2C).withAlpha(200) : const Color(0xFF2C2C2C),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      dividerTheme: const DividerThemeData(
        space: 1,
        thickness: 1,
        color: Color(0xFF3A3A3A),
      ),
      navigationBarTheme: NavigationBarThemeData(
        indicatorColor: primary.withAlpha(40),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(
              fontFamily: 'HarmonyOS_Sans_SC',
              fontWeight: FontWeight.w600,
              color: primary,
            );
          }
          return TextStyle(fontFamily: 'HarmonyOS_Sans_SC');
        }),
      ),
    );
  }

  /// 辅助色
  static Color _secondaryColor(ColorSchemeType type) {
    switch (type) {
      case ColorSchemeType.xuanZi: return const Color(0xFFD4A843);
      case ColorSchemeType.cangQing: return const Color(0xFF85C1E9);
      case ColorSchemeType.chiHong: return const Color(0xFFE6B0AA);
      case ColorSchemeType.moLu: return const Color(0xFF82E0AA);
      case ColorSchemeType.qiuHuang: return const Color(0xFFF9E79F);
      case ColorSchemeType.yanZhi: return const Color(0xFFF5B7B1);
      case ColorSchemeType.qingLan: return const Color(0xFFAED6F1);
      case ColorSchemeType.songYan: return const Color(0xFFABB2B9);
    }
  }
}

/// 色值辅助扩展
extension ColorSchemeTypeExt on ColorSchemeType {
  /// 色块预览颜色
  Color get previewColor => primary;
}