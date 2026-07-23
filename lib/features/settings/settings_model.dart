/// 乾坤易 - 设置状态管理
library;

import 'package:flutter/material.dart';

/// 排盘显示要素开关
class DisplaySettings {
  bool showTianGan;    // 显示天干
  bool showNaYin;      // 显示纳音
  bool showShenSha;    // 显示神煞
  bool showLiuShen;    // 显示六神（青龙朱雀等）
  bool showWangShuai;  // 显示旺衰（数字量化）
  bool showShiYing;    // 显示世应
  bool showXingChong;  // 显示刑冲合害
  bool showFanGua;     // 显示返卦

  DisplaySettings({
    this.showTianGan = true,
    this.showNaYin = true,
    this.showShenSha = true,
    this.showLiuShen = true,
    this.showWangShuai = false,
    this.showShiYing = true,
    this.showXingChong = true,
    this.showFanGua = false,
  });
}

/// 字体主题选项
enum FontTheme {
  classic('经典', 'Noto Serif SC'),
  modern('现代', 'Noto Sans SC'),
  song('宋体', 'SimSun'),
  kai('楷体', 'KaiTi');

  final String label;
  final String fontFamily;
  const FontTheme(this.label, this.fontFamily);
}

/// 日破暗动规则
enum RiPoAnDongRule {
  wangShuai('旺衰'),
  youQing('有情'),
  jieDong('皆动');

  final String label;
  const RiPoAnDongRule(this.label);
}

/// 应用设置模型
class AppSettings {
  // 主题
  ThemeMode themeMode;
  FontTheme fontTheme;
  double fontSize;

  // 排盘规则
  RiPoAnDongRule riPoAnDongRule;
  bool wanZiShiSwitch;      // 晚子时切换为次日
  bool chenMuTuYao;         // 日令辰墓土爻

  // 显示要素
  DisplaySettings display;

  AppSettings({
    this.themeMode = ThemeMode.system,
    this.fontTheme = FontTheme.classic,
    this.fontSize = 16.0,
    this.riPoAnDongRule = RiPoAnDongRule.youQing,
    this.wanZiShiSwitch = false,
    this.chenMuTuYao = false,
    DisplaySettings? display,
  }) : display = display ?? DisplaySettings();
}