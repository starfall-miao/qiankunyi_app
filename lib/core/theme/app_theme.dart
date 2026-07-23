import 'package:flutter/material.dart';

/// 乾坤易 - 主题配置
class AppTheme {
  AppTheme._();

  // ─── 颜色常量 ───

  /// 主色调 - 玄色（深紫色调，体现玄学氛围）
  static const Color primaryColor = Color(0xFF6C3FAA);
  static const Color primaryLight = Color(0xFF9C6FD4);
  static const Color primaryDark = Color(0xFF3F1C6B);

  /// 辅助色 - 金色（体现传统、经典）
  static const Color accentColor = Color(0xFFD4A843);
  static const Color accentLight = Color(0xFFFFD97A);
  static const Color accentDark = Color(0xFFA07A2E);

  /// 背景色
  static const Color lightBg = Color(0xFFF8F5F0);
  static const Color darkBg = Color(0xFF1A1A2E);

  /// 卡片色
  static const Color lightCard = Colors.white;
  static const Color darkCard = Color(0xFF252542);

  // ─── 亮色主题 ───

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.light(
      primary: primaryColor,
      secondary: accentColor,
      surface: lightCard,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: const Color(0xFF1A1A2E),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: lightBg,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: lightCard,
        foregroundColor: const Color(0xFF1A1A2E),
        titleTextStyle: const TextStyle(
          color: Color(0xFF1A1A2E),
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: lightCard,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
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
    );
  }

  // ─── 暗色主题 ───

  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.dark(
      primary: primaryLight,
      secondary: accentColor,
      surface: darkCard,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: const Color(0xFFF0EAE0),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: darkBg,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: darkCard,
        foregroundColor: const Color(0xFFF0EAE0),
        titleTextStyle: const TextStyle(
          color: Color(0xFFF0EAE0),
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: darkCard,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryLight,
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
    );
  }
}
