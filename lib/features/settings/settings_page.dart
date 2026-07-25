// 落·乾坤 - 设置页面
// 包含主题、配色、亚克力、字体、排盘规则等全部配置

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/theme_provider.dart';
import '../../core/theme/app_theme.dart';
import 'settings_model.dart';
import 'views/about_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late FontTheme _fontTheme;
  late double _fontSize;
  late RiPoAnDongRule _riPoRule;
  late bool _wanZiShi;
  late bool _chenMuTuYao;
  late DisplaySettings _display;

  @override
  void initState() {
    super.initState();
    _fontTheme = FontTheme.classic;
    _fontSize = 16;
    _riPoRule = RiPoAnDongRule.youQing;
    _wanZiShi = false;
    _chenMuTuYao = false;
    _display = DisplaySettings();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1A1A2E) : const Color(0xFFF5F0EB);

    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: Container(
        color: bgColor,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            _buildSectionHeader(theme, '🎨 主题与配色'),
            const SizedBox(height: 8),
            _buildThemeModeCard(theme, isDark),
            const SizedBox(height: 8),
            _buildColorSchemeSelector(theme, isDark),
            const SizedBox(height: 8),
            _buildAcrylicToggle(theme),
            const SizedBox(height: 16),

            _buildSectionHeader(theme, '🔤 字体与显示'),
            const SizedBox(height: 8),
            _buildFontSettings(theme),
            const SizedBox(height: 16),

            _buildSectionHeader(theme, '⚙️ 排盘规则'),
            const SizedBox(height: 8),
            _buildRuleSettings(theme),
            const SizedBox(height: 16),

            _buildSectionHeader(theme, '👁️ 显示要素'),
            const SizedBox(height: 8),
            _buildDisplaySettings(theme),
            const SizedBox(height: 16),

            _buildSectionHeader(theme, '📖 信息'),
            const SizedBox(height: 8),
            _buildAboutButton(theme),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ──────────────── 辅助组件 ────────────────

  Widget _buildSectionHeader(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 4),
      child: Text(title,
          style: theme.textTheme.titleSmall?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          )),
    );
  }

  Widget _buildCard(Widget child, {EdgeInsetsGeometry? padding}) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16),
        child: child,
      ),
    );
  }

  // ──────────────── 主题模式 ────────────────

  Widget _buildThemeModeCard(ThemeData theme, bool isDark) {
    final provider = context.watch<ThemeProvider>();
    final mode = provider.themeMode;

    return _buildCard(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('显示模式', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Row(
            children: [
              _modeChip(Icons.light_mode, '浅色', ThemeMode.light, mode, provider),
              const SizedBox(width: 8),
              _modeChip(Icons.dark_mode, '深色', ThemeMode.dark, mode, provider),
              const SizedBox(width: 8),
              _modeChip(Icons.settings_brightness, '跟随系统', ThemeMode.system, mode, provider),
            ],
          ),
        ],
      ),
    );
  }

  Widget _modeChip(IconData icon, String label, ThemeMode target, ThemeMode current, ThemeProvider provider) {
    final selected = current == target;
    return Expanded(
      child: InkWell(
        onTap: () => provider.setThemeMode(target),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? Theme.of(context).colorScheme.primaryContainer : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected ? Theme.of(context).colorScheme.primary : Colors.grey.shade300,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, size: 20, color: selected ? Theme.of(context).colorScheme.primary : null),
              const SizedBox(height: 4),
              Text(label, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  // ──────────────── 配色方案 ────────────────

  Widget _buildColorSchemeSelector(ThemeData theme, bool isDark) {
    final provider = context.watch<ThemeProvider>();
    final current = provider.colorSchemeType;

    return _buildCard(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('配色主题', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: ColorSchemeType.values.map((type) {
              final selected = current == type;
              return GestureDetector(
                onTap: () => provider.setColorScheme(type),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: type.primary.withAlpha(30),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selected ? type.primary : Colors.grey.shade300,
                      width: selected ? 2.5 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: type.primary,
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: selected
                              ? [BoxShadow(color: type.primary.withAlpha(100), blurRadius: 8)]
                              : null,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(type.label,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                            color: selected ? type.primary : null,
                          )),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ──────────────── 亚克力效果 ────────────────

  Widget _buildAcrylicToggle(ThemeData theme) {
    final provider = context.watch<ThemeProvider>();

    return _buildCard(
      Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.blur_on, color: theme.colorScheme.primary, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('亚克力效果', style: TextStyle(fontWeight: FontWeight.w600)),
                    const Text('毛玻璃背景模糊效果', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
              Switch(
                value: provider.acrylicEffect,
                onChanged: (_) => provider.toggleAcrylic(),
                activeThumbColor: theme.colorScheme.primary,
              ),
            ],
          ),
          if (provider.acrylicEffect) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const SizedBox(width: 50),
                const Text('透明', style: TextStyle(fontSize: 11, color: Colors.grey)),
                Expanded(
                  child: Slider(
                    value: provider.acrylicOpacity,
                    min: 0.1,
                    max: 1.0,
                    divisions: 9,
                    label: '${(provider.acrylicOpacity * 100).round()}%',
                    onChanged: (v) => provider.setAcrylicOpacity(v),
                  ),
                ),
                const Text('不透明', style: TextStyle(fontSize: 11, color: Colors.grey)),
                const SizedBox(width: 4),
                Text('${(provider.acrylicOpacity * 100).round()}%',
                    style: TextStyle(fontSize: 12, color: theme.colorScheme.primary, fontWeight: FontWeight.w600)),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ──────────────── 字体设置 ────────────────

  Widget _buildFontSettings(ThemeData theme) {
    return _buildCard(
      Column(
        children: [
          _buildSettingRow(
            icon: Icons.text_fields,
            title: '字体',
            subtitle: '鸿蒙字体（HarmonyOS Sans）',
            trailing: Text(FontTheme.values[_fontTheme.index].label),
          ),
          const Divider(height: 16),
          _buildSettingRow(
            icon: Icons.format_size,
            title: '字体大小',
            subtitle: '${_fontSize.toInt()}px',
            trailing: SizedBox(
              width: 140,
              child: Slider(
                value: _fontSize,
                min: 12,
                max: 24,
                divisions: 12,
                label: '${_fontSize.toInt()}px',
                onChanged: (v) => setState(() => _fontSize = v),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────── 排盘规则 ────────────────

  Widget _buildRuleSettings(ThemeData theme) {
    return _buildCard(
      Column(
        children: [
          _buildSettingRow(
            icon: Icons.rule,
            title: '日破暗动规则',
            trailing: DropdownButton<RiPoAnDongRule>(
              value: _riPoRule,
              underline: const SizedBox(),
              items: RiPoAnDongRule.values.map((r) {
                return DropdownMenuItem(value: r, child: Text(r.label));
              }).toList(),
              onChanged: (v) {
                if (v != null) setState(() => _riPoRule = v);
              },
            ),
          ),
          const Divider(height: 16),
          _buildSwitchRow('晚子时', '23:00-00:59 时柱判定', _wanZiShi, (v) {
            setState(() => _wanZiShi = v);
          }),
          const Divider(height: 16),
          _buildSwitchRow('辰沐土爻', '辰/戌/丑/未月土爻旺相', _chenMuTuYao, (v) {
            setState(() => _chenMuTuYao = v);
          }),
        ],
      ),
    );
  }

  // ──────────────── 显示要素 ────────────────

  Widget _buildDisplaySettings(ThemeData theme) {
    return _buildCard(
      Column(
        children: [
          _buildSwitchRow('天干', '', _display.showTianGan, (v) {
            setState(() => _display.showTianGan = v);
          }),
          const Divider(height: 4),
          _buildSwitchRow('纳音', '', _display.showNaYin, (v) {
            setState(() => _display.showNaYin = v);
          }),
          const Divider(height: 4),
          _buildSwitchRow('神煞', '', _display.showShenSha, (v) {
            setState(() => _display.showShenSha = v);
          }),
          const Divider(height: 4),
          _buildSwitchRow('六神', '青龙/朱雀/勾陈/螣蛇/白虎/玄武', _display.showLiuShen, (v) {
            setState(() => _display.showLiuShen = v);
          }),
          const Divider(height: 4),
          _buildSwitchRow('旺衰', '旺/相/休/囚/死', _display.showWangShuai, (v) {
            setState(() => _display.showWangShuai = v);
          }),
          const Divider(height: 4),
          _buildSwitchRow('世应', '', _display.showShiYing, (v) {
            setState(() => _display.showShiYing = v);
          }),
          const Divider(height: 4),
          _buildSwitchRow('刑冲合害', '', _display.showXingChong, (v) {
            setState(() => _display.showXingChong = v);
          }),
        ],
      ),
    );
  }

  // ──────────────── 关于 ────────────────

  Widget _buildAboutButton(ThemeData theme) {
    return _buildCard(
      InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutPage())),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.info_outline, color: theme.colorScheme.primary, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('关于 落·乾坤', style: TextStyle(fontWeight: FontWeight.w600)),
                    const Text('版本 1.0.0 · 原作者及项目介绍',
                        style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }

  // ──────────────── 通用组件 ────────────────

  Widget _buildSettingRow({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
                if (subtitle != null)
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget _buildSwitchRow(String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
                if (subtitle.isNotEmpty)
                  Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Theme.of(context).colorScheme.primary,
          ),
        ],
      ),
    );
  }
}
