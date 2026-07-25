// 落·乾坤 - 设置状态管理

import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

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
  classic('经典', 'HarmonyOS_Sans_SC'),
  modern('现代', 'HarmonyOS_Sans_SC'),
  song('宋体', 'HarmonyOS_Sans_SC'),
  kai('楷体', 'HarmonyOS_Sans_SC');

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

/// 配色方案设置
enum ColorThemeOption {
  xuanZi('玄紫', ColorSchemeType.xuanZi),
  cangQing('藏青', ColorSchemeType.cangQing),
  chiHong('赤红', ColorSchemeType.chiHong),
  moLu('墨绿', ColorSchemeType.moLu),
  qiuHuang('秋黄', ColorSchemeType.qiuHuang),
  yanZhi('胭脂', ColorSchemeType.yanZhi),
  qingLan('青蓝', ColorSchemeType.qingLan),
  songYan('松烟', ColorSchemeType.songYan);

  final String label;
  final ColorSchemeType scheme;
  const ColorThemeOption(this.label, this.scheme);

  Color get primaryColor => scheme.primary;
}
