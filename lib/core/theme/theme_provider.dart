// 落·乾坤 - 主题状态管理
// 支持暗/亮/跟随系统 + 多配色方案 + 亚克力效果（可调透明度）

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_theme.dart';
import '../utils/logger.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _modeKey = 'theme_mode';
  static const String _colorKey = 'color_scheme';
  static const String _acrylicKey = 'use_acrylic';
  static const String _opacityKey = 'acrylic_opacity';

  ThemeMode _themeMode = ThemeMode.system;
  ColorSchemeType _colorScheme = ColorSchemeType.xuanZi;
  bool _useAcrylic = true;
  double _acrylicOpacity = 0.75;
  bool _renderDebug = false;
  bool _immersiveMode = false;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  ColorSchemeType get colorSchemeType => _colorScheme;
  bool get acrylicEffect => _useAcrylic;
  double get acrylicOpacity => _acrylicOpacity;
  bool get renderDebug => _renderDebug;
  bool get immersiveMode => _immersiveMode;

  ThemeProvider() {
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _themeMode = _parseMode(prefs.getString(_modeKey) ?? 'system');
    _colorScheme = _parseColor(prefs.getString(_colorKey) ?? 'xuanZi');
    _useAcrylic = prefs.getBool(_acrylicKey) ?? true;
    _acrylicOpacity = prefs.getDouble(_opacityKey) ?? 0.75;
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_modeKey, _serializeMode(mode));
    final label = mode == ThemeMode.light ? '浅色' : mode == ThemeMode.dark ? '深色' : '跟随系统';
    Logger.instance.info('主题模式: $label');
  }

  Future<void> setColorScheme(ColorSchemeType type) async {
    _colorScheme = type;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_colorKey, type.name);
    Logger.instance.info('配色方案: ${type.label}');
  }

  Future<void> setAcrylicEffect(bool value) async {
    _useAcrylic = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_acrylicKey, value);
    Logger.instance.info('亚克力效果: ${value ? "开启" : "关闭"}');
  }

  Future<void> toggleAcrylic() async {
    await setAcrylicEffect(!_useAcrylic);
  }

  Future<void> setAcrylicOpacity(double value) async {
    _acrylicOpacity = value.clamp(0.0, 1.0);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_opacityKey, _acrylicOpacity);
    Logger.instance.info('亚克力透明度: ${(value * 100).toInt()}%');
  }

  Future<void> toggleTheme() async {
    final next = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await setThemeMode(next);
  }

  Future<void> setRenderDebug(bool value) async {
    _renderDebug = value;
    notifyListeners();
    Logger.instance.info('渲染检测: ${value ? "开启" : "关闭"}');
  }

  static ThemeMode _parseMode(String value) {
    switch (value) {
      case 'light': return ThemeMode.light;
      case 'dark': return ThemeMode.dark;
      default: return ThemeMode.system;
    }
  }

  static String _serializeMode(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light: return 'light';
      case ThemeMode.dark: return 'dark';
      case ThemeMode.system: return 'system';
    }
  }

  static ColorSchemeType _parseColor(String value) {
    return ColorSchemeType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ColorSchemeType.xuanZi,
    );
  }

  void setImmersiveMode(bool value) {
    _immersiveMode = value;
    notifyListeners();
  }
}
