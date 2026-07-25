// 落·乾坤 - 主题状态管理
// 支持暗/亮/跟随系统 + 多配色方案 + 亚克力效果

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_theme.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _modeKey = 'theme_mode';
  static const String _colorKey = 'color_scheme';
  static const String _acrylicKey = 'use_acrylic';

  ThemeMode _themeMode = ThemeMode.system;
  ColorSchemeType _colorScheme = ColorSchemeType.xuanZi;
  bool _useAcrylic = false;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  ColorSchemeType get colorSchemeType => _colorScheme;
  bool get acrylicEffect => _useAcrylic;

  ThemeProvider() {
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _themeMode = _parseMode(prefs.getString(_modeKey) ?? 'system');
    _colorScheme = _parseColor(prefs.getString(_colorKey) ?? 'xuanZi');
    _useAcrylic = prefs.getBool(_acrylicKey) ?? false;
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_modeKey, _serializeMode(mode));
  }

  Future<void> setColorScheme(ColorSchemeType type) async {
    _colorScheme = type;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_colorKey, type.name);
  }

  Future<void> toggleAcrylic() async {
    _useAcrylic = !_useAcrylic;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_acrylicKey, _useAcrylic);
  }

  Future<void> toggleTheme() async {
    final next = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await setThemeMode(next);
  }

  static ThemeMode _parseMode(String value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  static String _serializeMode(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      default:
        return 'system';
    }
  }

  static ColorSchemeType _parseColor(String value) {
    return ColorSchemeType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ColorSchemeType.xuanZi,
    );
  }
}
