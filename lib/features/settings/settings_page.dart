/// 设置页面
/// 包含主题、字体、排盘规则、显示要素等配置
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/theme_provider.dart';
import 'settings_model.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // 本地设置缓存
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
    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          // ── 外观设置 ──
          _section(theme, '外观', Icons.palette, [
            _themeModeTile(theme),
            _fontThemeTile(theme),
            _fontSizeTile(theme),
          ]),
          const SizedBox(height: 8),
          // ── 排盘规则 ──
          _section(theme, '排盘规则', Icons.rule, [
            _riPoRuleTile(theme),
            _switchTile(theme, '晚子时切换为次日', _wanZiShi, (v) => setState(() => _wanZiShi = v)),
            _switchTile(theme, '日令辰墓土爻', _chenMuTuYao, (v) => setState(() => _chenMuTuYao = v)),
          ]),
          const SizedBox(height: 8),
          // ── 显示要素 ──
          _section(theme, '显示要素', Icons.visibility, [
            _switchTile(theme, '天干', _display.showTianGan, (v) => setState(() => _display.showTianGan = v)),
            _switchTile(theme, '纳音', _display.showNaYin, (v) => setState(() => _display.showNaYin = v)),
            _switchTile(theme, '神煞', _display.showShenSha, (v) => setState(() => _display.showShenSha = v)),
            _switchTile(theme, '六神（青龙朱雀等）', _display.showLiuShen, (v) => setState(() => _display.showLiuShen = v)),
            _switchTile(theme, '旺衰（数字量化）', _display.showWangShuai, (v) => setState(() => _display.showWangShuai = v)),
            _switchTile(theme, '世应', _display.showShiYing, (v) => setState(() => _display.showShiYing = v)),
            _switchTile(theme, '刑冲合害', _display.showXingChong, (v) => setState(() => _display.showXingChong = v)),
            _switchTile(theme, '返卦', _display.showFanGua, (v) => setState(() => _display.showFanGua = v)),
          ]),
        ],
      ),
    );
  }

  // ── 主题模式 ──

  Widget _themeModeTile(ThemeData theme) {
    final tp = context.watch<ThemeProvider>();
    String label;
    switch (tp.themeMode) {
      case ThemeMode.light: label = '亮色'; break;
      case ThemeMode.dark: label = '暗色'; break;
      default: label = '跟随系统';
    }
    return ListTile(
      leading: const Icon(Icons.brightness_6),
      title: const Text('主题模式'),
      trailing: SegmentedButton<ThemeMode>(
        segments: const [
          ButtonSegment(value: ThemeMode.light, label: Text('亮')),
          ButtonSegment(value: ThemeMode.dark, label: Text('暗')),
          ButtonSegment(value: ThemeMode.system, label: Text('系统')),
        ],
        selected: {tp.themeMode},
        onSelectionChanged: (s) => tp.setThemeMode(s.first),
      ),
    );
  }

  // ── 字体主题 ──

  Widget _fontThemeTile(ThemeData theme) {
    return ListTile(
      leading: const Icon(Icons.font_download),
      title: const Text('字体主题'),
      subtitle: Text(_fontTheme.label),
      trailing: DropdownButton<FontTheme>(
        value: _fontTheme,
        underline: const SizedBox(),
        items: FontTheme.values.map((f) => DropdownMenuItem(
          value: f,
          child: Text(f.label, style: TextStyle(fontFamily: f.fontFamily)),
        )).toList(),
        onChanged: (v) {
          if (v != null) setState(() => _fontTheme = v);
        },
      ),
    );
  }

  // ── 字号 ──

  Widget _fontSizeTile(ThemeData theme) {
    return ListTile(
      leading: const Icon(Icons.text_fields),
      title: const Text('字号'),
      subtitle: Text('${_fontSize.toInt()}px'),
      trailing: SizedBox(
        width: 200,
        child: Slider(
          value: _fontSize,
          min: 12,
          max: 24,
          divisions: 12,
          label: '${_fontSize.toInt()}px',
          onChanged: (v) => setState(() => _fontSize = v),
        ),
      ),
    );
  }

  // ── 日破暗动规则 ──

  Widget _riPoRuleTile(ThemeData theme) {
    return ListTile(
      leading: const Icon(Icons.rule),
      title: const Text('日破暗动规则'),
      trailing: DropdownButton<RiPoAnDongRule>(
        value: _riPoRule,
        underline: const SizedBox(),
        items: RiPoAnDongRule.values.map((r) => DropdownMenuItem(
          value: r,
          child: Text(r.label),
        )).toList(),
        onChanged: (v) {
          if (v != null) setState(() => _riPoRule = v);
        },
      ),
    );
  }

  // ── 开关 ──

  Widget _switchTile(ThemeData theme, String title, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      title: Text(title, style: theme.textTheme.bodyMedium),
      value: value,
      onChanged: onChanged,
    );
  }

  // ── 分组 ──

  Widget _section(ThemeData theme, String title, IconData icon, List<Widget> children) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(children: [
              Icon(icon, size: 18, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
            ]),
          ),
          ...children,
        ],
      ),
    );
  }
}