// 落·乾坤 - 主题配置
// 支持多种传统配色方案

import 'package:flutter/material.dart';

/// 配色方案枚举（不使用增强枚举字段，确保 CI 兼容）
enum ColorSchemeType {
  xuanZi,     // 玄紫（默认）
  cangQing,   // 藏青
  chiHong,    // 赤红
  moLu,       // 墨绿
  qiuHuang,   // 秋黄
  yanZhi,     // 胭脂
  qingLan,    // 青蓝
  songYan;    // 松烟灰

  String get label {
    return _ColorSchemeMeta.labels[this]!;
  }

  Color get primary {
    return _ColorSchemeMeta.primaryColors[this]!;
  }

  Color get primaryDark {
    return _ColorSchemeMeta.primaryDarkColors[this]!;
  }
}

/// 配色方案元数据（Map 映射，避免增强 enum 的 CI 兼容问题）
class _ColorSchemeMeta {
  static const labels = {
    ColorSchemeType.xuanZi: '玄紫',
    ColorSchemeType.cangQing: '藏青',
    ColorSchemeType.chiHong: '赤红',
    ColorSchemeType.moLu: '墨绿',
    ColorSchemeType.qiuHuang: '秋黄',
    ColorSchemeType.yanZhi: '胭脂',
    ColorSchemeType.qingLan: '青蓝',
    ColorSchemeType.songYan: '松烟',
  };

  static const primaryColors = {
    ColorSchemeType.xuanZi: Color(0xFF6C3FAA),
    ColorSchemeType.cangQing: Color(0xFF1A5276),
    ColorSchemeType.chiHong: Color(0xFFB03A2E),
    ColorSchemeType.moLu: Color(0xFF1E8449),
    ColorSchemeType.qiuHuang: Color(0xFFB7950B),
    ColorSchemeType.yanZhi: Color(0xFFC0392B),
    ColorSchemeType.qingLan: Color(0xFF2E86C1),
    ColorSchemeType.songYan: Color(0xFF4A4A4A),
  };

  static const primaryDarkColors = {
    ColorSchemeType.xuanZi: Color(0xFF3F1C6B),
    ColorSchemeType.cangQing: Color(0xFF0E2F44),
    ColorSchemeType.chiHong: Color(0xFF7B241C),
    ColorSchemeType.moLu: Color(0xFF0E4D2A),
    ColorSchemeType.qiuHuang: Color(0xFF7D6608),
    ColorSchemeType.yanZhi: Color(0xFF78281F),
    ColorSchemeType.qingLan: Color(0xFF1B4F72),
    ColorSchemeType.songYan: Color(0xFF2C2C2C),
  };
}

/// 获取辅助色
Color _secondaryColor(ColorSchemeType type) {
  switch (type) {
    case ColorSchemeType.xuanZi: return const Color(0xFFD4A843);
    case ColorSchemeType.cangQing: return const Color(0xFFD4A843);
    case ColorSchemeType.chiHong: return const Color(0xFFD4A843);
    case ColorSchemeType.moLu: return const Color(0xFFD4A843);
    case ColorSchemeType.qiuHuang: return const Color(0xFF8B6F47);
    case ColorSchemeType.yanZhi: return const Color(0xFFD4A843);
    case ColorSchemeType.qingLan: return const Color(0xFFD4A843);
    case ColorSchemeType.songYan: return const Color(0xFFD4A843);
  }
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
        elevation: 0,
        backgroundColor: useAcrylic ? Colors.white.withAlpha(230) : Colors.white,
        indicatorColor: primary.withAlpha(30),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(
              color: primary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              fontFamily: 'HarmonyOS_Sans_SC',
            );
          }
          return TextStyle(
            color: const Color(0xFF888888),
            fontSize: 12,
            fontFamily: 'HarmonyOS_Sans_SC',
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: primary, size: 24);
          }
          return const IconThemeData(color: Color(0xFF888888), size: 24);
        }),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: useAcrylic ? Colors.white.withAlpha(230) : Colors.white,
        selectedItemColor: primary,
        unselectedItemColor: const Color(0xFF888888),
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
      surface: const Color(0xFF1A1A2E),
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
        backgroundColor: useAcrylic ? Colors.transparent : const Color(0xFF252542),
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
        color: useAcrylic ? const Color(0xFF252542).withAlpha(200) : const Color(0xFF252542),
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
        color: Color(0xFF3A3A5C),
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        backgroundColor: useAcrylic
            ? const Color(0xFF252542).withAlpha(230)
            : const Color(0xFF252542),
        indicatorColor: primary.withAlpha(30),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(
              color: primary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              fontFamily: 'HarmonyOS_Sans_SC',
            );
          }
          return TextStyle(
            color: const Color(0xFF888888),
            fontSize: 12,
            fontFamily: 'HarmonyOS_Sans_SC',
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: primary, size: 24);
          }
          return const IconThemeData(color: Color(0xFF888888), size: 24);
        }),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: useAcrylic
            ? const Color(0xFF252542).withAlpha(230)
            : const Color(0xFF252542),
        selectedItemColor: primary,
        unselectedItemColor: const Color(0xFF888888),
      ),
    );
  }
}
