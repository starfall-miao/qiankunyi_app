// 落·乾坤 - 设置页面
// 包含主题、配色、亚克力、字体、排盘规则等全部配置

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/theme_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/logger.dart';
import 'settings_provider.dart';
import 'views/about_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _log = Logger.instance;

  @override
  void initState() {
    super.initState();
    _log.info('设置页面已加载');
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

            _buildSectionHeader(theme, '🔧 调试与日志'),
            const SizedBox(height: 8),
            _buildDebugSettings(theme),
            const SizedBox(height: 16),

            _buildSectionHeader(theme, '🤖 AI 解卦配置'),
            const SizedBox(height: 8),
            _buildAISettings(theme),
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
            fontWeight: FontWeight.w600,
          )),
    );
  }

  Widget _buildCard(Widget child) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: child,
      ),
    );
  }

  Widget _buildSettingRow({
    required IconData icon,
    required String title,
    String subtitle = '',
    Widget? trailing,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF8D6E63)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
              if (subtitle.isNotEmpty)
                Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
        if (trailing != null) trailing,
      ],
    );
  }

  Widget _buildSwitchRow(String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
              if (subtitle.isNotEmpty)
                Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
        Switch(value: value, onChanged: onChanged),
      ],
    );
  }

  // ──────────────── 主题与配色 ────────────────

  Widget _buildThemeModeCard(ThemeData theme, bool isDark) {
    final tp = context.watch<ThemeProvider>();
    final mode = tp.themeMode;

    return _buildCard(
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _modeChip(Icons.light_mode, '浅色', ThemeMode.light, mode, tp),
          _modeChip(Icons.dark_mode, '深色', ThemeMode.dark, mode, tp),
          _modeChip(Icons.auto_mode, '跟随系统', ThemeMode.system, mode, tp),
        ],
      ),
    );
  }

  Widget _modeChip(IconData icon, String label, ThemeMode target, ThemeMode current, ThemeProvider provider) {
    final isSelected = current == target;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF9F6F2);

    return GestureDetector(
      onTap: () {
        provider.setThemeMode(target);
        Logger.instance.info('主题模式: $label');
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).colorScheme.primary : bg,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : (isDark ? const Color(0xFF555555) : const Color(0xFFD0C8B8)),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 18,
                color: isSelected
                    ? Colors.white
                    : (isDark ? const Color(0xFFE0D5C8).withAlpha(180) : const Color(0xFF4A3728).withAlpha(180))),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    fontSize: 12,
                    color: isSelected
                        ? Colors.white
                        : (isDark ? const Color(0xFFE0D5C8) : const Color(0xFF4A3728)))),
          ],
        ),
      ),
    );
  }

  Widget _buildColorSchemeSelector(ThemeData theme, bool isDark) {
    final tp = context.read<ThemeProvider>();
    final current = tp.colorSchemeType;

    return _buildCard(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('配色方案', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ColorSchemeType.values.map((type) {
              final selected = type == current;
              final p = type.primary;
              return GestureDetector(
                onTap: () {
                  tp.setColorScheme(type);
                  Logger.instance.info('配色方案: ${type.label}');
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: selected ? p : (isDark ? const Color(0xFF2C2C2C) : Colors.white),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: selected ? p : (isDark ? const Color(0xFF444444) : const Color(0xFFE0D5C8))),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 12, height: 12,
                        decoration: BoxDecoration(
                          color: p,
                          shape: BoxShape.circle,
                          border: Border.all(color: selected ? Colors.white : Colors.transparent, width: 1),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(type.label,
                          style: TextStyle(
                              fontSize: 13,
                              color: selected ? Colors.white : (isDark ? const Color(0xFFE0D5C8) : const Color(0xFF4A3728)))),
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

  Widget _buildAcrylicToggle(ThemeData theme) {
    final tp = context.watch<ThemeProvider>();

    return _buildCard(
      _buildSettingRow(
        icon: Icons.blur_on,
        title: '亚克力效果',
        subtitle: '毛玻璃视觉效果（实验性）',
        trailing: Switch(
          value: tp.acrylicEffect,
          onChanged: (v) => tp.setAcrylicEffect(v),
        ),
      ),
    );
  }

  // ──────────────── 字体与显示 ────────────────

  Widget _buildFontSettings(ThemeData theme) {
    final sp = context.watch<SettingsProvider>();

    return _buildCard(
      Column(
        children: [
          _buildSettingRow(
            icon: Icons.text_fields,
            title: '字体',
            subtitle: '鸿蒙字体（HarmonyOS Sans SC）',
            trailing: const Icon(Icons.check_circle, size: 18, color: Colors.green),
          ),
          const Divider(height: 16),
          _buildSettingRow(
            icon: Icons.format_size,
            title: '字体大小',
            subtitle: '${sp.fontSize.toInt()}px',
            trailing: SizedBox(
              width: 140,
              child: Slider(
                value: sp.fontSize,
                min: 12,
                max: 24,
                divisions: 12,
                label: '${sp.fontSize.toInt()}px',
                onChanged: (v) => sp.fontSize = v,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────── 排盘规则 ────────────────

  Widget _buildRuleSettings(ThemeData theme) {
    final sp = context.watch<SettingsProvider>();

    return _buildCard(
      Column(
        children: [
          _buildSettingRow(
            icon: Icons.rule,
            title: '日破暗动规则',
            trailing: DropdownButton<RiPoAnDongRule>(
              value: sp.riPoRule,
              underline: const SizedBox(),
              items: RiPoAnDongRule.values.map((r) {
                return DropdownMenuItem(value: r, child: Text(r.label));
              }).toList(),
              onChanged: (v) {
                if (v != null) sp.riPoRule = v;
              },
            ),
          ),
          const Divider(height: 16),
          _buildSwitchRow('晚子时', '23:00-00:59 时柱判定', sp.wanZiShi, (v) {
            sp.wanZiShi = v;
          }),
          const Divider(height: 16),
          _buildSwitchRow('辰沐土爻', '辰/戌/丑/未月土爻旺相', sp.chenMuTuYao, (v) {
            sp.chenMuTuYao = v;
          }),
        ],
      ),
    );
  }

  // ──────────────── 显示要素 ────────────────

  Widget _buildDisplaySettings(ThemeData theme) {
    final sp = context.watch<SettingsProvider>();

    return _buildCard(
      Column(
        children: [
          _buildSwitchRow('天干', '', sp.display.showTianGan, (v) {
            sp.toggleDisplay('showTianGan');
          }),
          const Divider(height: 4),
          _buildSwitchRow('纳音', '', sp.display.showNaYin, (v) {
            sp.toggleDisplay('showNaYin');
          }),
          const Divider(height: 4),
          _buildSwitchRow('神煞', '', sp.display.showShenSha, (v) {
            sp.toggleDisplay('showShenSha');
          }),
          const Divider(height: 4),
          _buildSwitchRow('六神', '青龙/朱雀/勾陈/螣蛇/白虎/玄武', sp.display.showLiuShen, (v) {
            sp.toggleDisplay('showLiuShen');
          }),
          const Divider(height: 4),
          _buildSwitchRow('旺衰', '旺/相/休/囚/死', sp.display.showWangShuai, (v) {
            sp.toggleDisplay('showWangShuai');
          }),
          const Divider(height: 4),
          _buildSwitchRow('世应', '', sp.display.showShiYing, (v) {
            sp.toggleDisplay('showShiYing');
          }),
          const Divider(height: 4),
          _buildSwitchRow('刑冲合害', '', sp.display.showXingChong, (v) {
            sp.toggleDisplay('showXingChong');
          }),
        ],
      ),
    );
  }

  // ──────────────── 调试与日志 ────────────────

  Widget _buildDebugSettings(ThemeData theme) {
    final log = Logger.instance;

    return _buildCard(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSwitchRow('自动记录日志', '页面加载、排盘操作、异常等事件自动写入日志', log.enabled, (v) {
            setState(() => log.setEnabled(v));
          }),
          const Divider(height: 16),
          _buildSwitchRow('渲染检测', '排盘页顶部显示渲染状态条', context.read<ThemeProvider>().renderDebug, (v) {
            context.read<ThemeProvider>().setRenderDebug(v);
          }),
          const Divider(height: 16),
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: () => _showLogDialog(context),
              icon: const Icon(Icons.terminal),
              label: const Text('查看运行日志'),
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────── 日志查看弹窗 ────────────────

  void _showLogDialog(BuildContext context) {
    final log = Logger.instance;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('运行日志'),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20),
              onPressed: () {
                log.clear();
                Navigator.of(ctx).pop();
              },
              tooltip: '清空日志',
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: log.logs.length,
            itemBuilder: (_, i) {
              final e = log.logs[i];
              final color = e.level == LogLevel.error ? Colors.red :
                  e.level == LogLevel.warn ? Colors.orange : Colors.grey;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 1),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: color.withAlpha(30),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text(e.levelTag, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '[${e.time.hour.toString().padLeft(2,'0')}:${e.time.minute.toString().padLeft(2,'0')}:${e.time.second.toString().padLeft(2,'0')}] ${e.message}',
                        style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('关闭')),
        ],
      ),
    );
  }

  // ──────────────── AI 解卦配置 ────────────────

  Widget _buildAISettings(ThemeData theme) {
    return _buildCard(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 总开关
          Consumer<SettingsProvider>(
            builder: (ctx, sp, _) => SwitchListTile(
              title: const Text('启用 AI 解卦'),
              subtitle: const Text('开启后可在排盘页使用 AI 辅助分析'),
              value: sp.aiEnabled,
              onChanged: (v) => sp.aiEnabled = v,
              dense: true,
            ),
          ),
          const Divider(height: 1),
          // API 地址
          Consumer<SettingsProvider>(
            builder: (ctx, sp, _) => _buildSettingsRow(
              icon: Icons.link,
              title: 'API 地址',
              subtitle: sp.aiEndpoint,
              onTap: () => _editText(context, 'API 地址', sp.aiEndpoint, (v) => sp.aiEndpoint = v),
            ),
          ),
          const Divider(height: 1),
          // API Key
          Consumer<SettingsProvider>(
            builder: (ctx, sp, _) => _buildSettingsRow(
              icon: Icons.key,
              title: 'API Key',
              subtitle: sp.aiApiKey.isEmpty ? '未设置' : '${sp.aiApiKey.substring(0, 8)}...',
              onTap: () => _editText(context, 'API Key', sp.aiApiKey, (v) => sp.aiApiKey = v, obscure: true),
            ),
          ),
          const Divider(height: 1),
          // 模型选择
          Consumer<SettingsProvider>(
            builder: (ctx, sp, _) => _buildSettingsRow(
              icon: Icons.model_training,
              title: '模型',
              subtitle: sp.aiModel,
              onTap: () => _selectModel(context, sp),
            ),
          ),
        ],
      ),
    );
  }

  void _editText(BuildContext context, String label, String current, Function(String) onSave,
      {bool obscure = false}) {
    final ctrl = TextEditingController(text: current);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(label),
        content: TextField(
          controller: ctrl,
          obscureText: obscure,
          decoration: InputDecoration(hintText: '请输入$label'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          TextButton(onPressed: () { onSave(ctrl.text); Navigator.pop(ctx); }, child: const Text('保存')),
        ],
      ),
    );
  }

  void _selectModel(BuildContext context, SettingsProvider sp) {
    final models = ['qwen-turbo', 'qwen-plus', 'qwen-max', 'deepseek-v3', 'deepseek-r1'];
    showDialog(
      context: context,
      builder: (ctx) {
        final theme2 = Theme.of(ctx);
        return AlertDialog(
          title: const Text('选择 AI 模型'),
          content: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: models.map((m) {
              final sel = sp.aiModel == m;
              return ChoiceChip(
                label: Text(m, style: TextStyle(fontSize: 13, color: sel ? theme2.colorScheme.primary : null)),
                selected: sel,
                onSelected: (_) { sp.aiModel = m; Navigator.pop(ctx); },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildSettingsRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final t = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Icon(icon, size: 20, color: t.colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 14, color: t.colorScheme.onSurface)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: TextStyle(fontSize: 12, color: t.colorScheme.onSurface.withAlpha(150))),
                ],
              ),
            ),
            const Icon(Icons.edit_outlined, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  // ──────────────── 关于 ────────────────

  Widget _buildAboutButton(ThemeData theme) {
    return _buildCard(
      InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AboutPage())),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: _buildSettingRow(
            icon: Icons.info_outline,
            title: '关于落·乾坤',
            subtitle: '版本 1.0.0',
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
          ),
        ),
      ),
    );
  }
}
