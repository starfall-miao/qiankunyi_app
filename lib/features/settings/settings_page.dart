// 落·乾坤 - 设置页面
// 包含主题、配色、亚克力、字体、排盘规则等全部配置

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../core/theme/theme_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/logger.dart';
import 'settings_provider.dart';
import 'views/about_page.dart';
import 'views/compass_page.dart';
import '../onboarding/views/onboarding_page.dart';
import '../users/views/user_profile_page.dart';
import '../users/providers/user_provider.dart';
import 'views/tutorial_page.dart';
import 'views/data_management_page.dart';

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
      appBar: AppBar(title: const Text('百宝箱')),
      body: Container(
        color: bgColor,
        child: LayoutBuilder(
          builder: (ctx, constraints) {
            final width = constraints.maxWidth;
            final list = ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              children: [
                // 👤 用户画像（置顶）
                _buildSectionHeader(theme, '用户画像', icon: LucideIcons.users),
                const SizedBox(height: 8),
                Consumer<UserProvider>(
                  builder: (ctx, up, _) => _buildCard(
                    Column(children: [
                      _buildSettingsRow(
                        icon: Icons.face,
                        title: '当前用户',
                        subtitle: up.current != null
                            ? '${up.current!.nickname} · 共 ${up.users.length} 个用户'
                            : '未创建用户，点此创建',
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const UserProfilePage()),
                        ),
                      ),
                      if (up.current != null) ...[
                        const Divider(height: 12),
                        _buildSettingsRow(
                          icon: Icons.badge_outlined,
                          title: 'AI 参考画像',
                          subtitle: up.current!.aiReferenceEnabled
                              ? '${up.current!.baziSummary.isNotEmpty ? "已提交八字 · " : ""}解卦时参考'
                              : '未开启（解卦时不参考画像）',
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const UserProfilePage()),
                          ),
                        ),
                      ],
                    ]),
                  ),
                ),
                const SizedBox(height: 16),

                // 📖 易学入门教程（百宝箱主打功能）
                _buildSectionHeader(theme, '易学入门教程', icon: LucideIcons.book),
                const SizedBox(height: 8),
                _buildCard(
                  Column(children: [
                    _buildSettingsRow(
                      icon: Icons.auto_stories,
                      title: '周易 · 六爻 · 梅花 · 八字教程',
                      subtitle: '术数原理 · 手动排盘 · 五行六亲纳甲速查卡',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const TutorialPage()),
                      ),
                    ),
                  ]),
                ),
                const SizedBox(height: 16),

                _buildSectionHeader(theme, '主题与配色', icon: LucideIcons.palette),
                const SizedBox(height: 8),
                _buildThemeModeCard(theme, isDark),
                const SizedBox(height: 8),
                _buildColorSchemeSelector(theme, isDark),
                const SizedBox(height: 8),
                _buildAcrylicToggle(theme),
                const SizedBox(height: 16),

                _buildSectionHeader(theme, '字体与显示', icon: LucideIcons.type),
                const SizedBox(height: 8),
                _buildFontSettings(theme),
                const SizedBox(height: 16),

                _buildSectionHeader(theme, '排盘规则', icon: LucideIcons.sliders),
                const SizedBox(height: 8),
                _buildRuleSettings(theme),
                const SizedBox(height: 16),

                _buildSectionHeader(theme, '显示要素', icon: LucideIcons.eye),
                const SizedBox(height: 8),
                _buildDisplaySettings(theme),
                const SizedBox(height: 16),

                _buildSectionHeader(theme, '调试与日志', icon: LucideIcons.terminal),
                const SizedBox(height: 8),
                _buildDebugSettings(theme),
                const SizedBox(height: 8),
                // 数据管理入口
                _buildCard(
                  Column(children: [
                    _buildSettingsRow(
                      icon: LucideIcons.database,
                      title: '数据管理',
                      subtitle: '卦例统计/清空 · 设置恢复默认',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const DataManagementPage()),
                      ),
                    ),
                  ]),
                ),
                const SizedBox(height: 16),

                _buildSectionHeader(theme, '小工具', icon: LucideIcons.wrench),
                const SizedBox(height: 8),
                _buildCompassEntry(theme),
                const SizedBox(height: 16),

                _buildSectionHeader(theme, 'AI 解卦配置', icon: LucideIcons.sparkles),
                const SizedBox(height: 8),
                _buildAISettings(theme),
                const SizedBox(height: 16),

                _buildSectionHeader(theme, '信息', icon: LucideIcons.info),
                const SizedBox(height: 8),
                _buildAboutButton(theme),
                const SizedBox(height: 8),
                // 使用引导（重新查看）
                _buildSettingsRow(
                  icon: Icons.menu_book,
                  title: '使用引导',
                  subtitle: '重新查看首次启动引导',
                  onTap: () {
                    final nav = Navigator.of(context);
                    nav.push(
                      MaterialPageRoute(
                        builder: (_) => OnboardingPage(
                          onDone: () => nav.pop(),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 32),
              ],
            );
            // 桌面宽屏：限宽居中，避免设置项拉得过宽
            if (width > 1100) {
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: list,
                ),
              );
            }
            return list;
          },
        ),
      ),
    );
  }

  // ──────────────── 辅助组件 ────────────────

  Widget _buildSectionHeader(ThemeData theme, String title, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 4),
      child: Row(children: [
        if (icon != null) ...[
          Icon(icon, size: 16, color: theme.colorScheme.primary),
          const SizedBox(width: 6),
        ],
        Text(title,
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            )),
      ]),
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
    final tp = context.watch<ThemeProvider>();
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
            subtitle: '（开发中，引擎暂未读取此设置）',
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
          _buildSwitchRow('晚子时', '23:00-00:59 时柱归次日子时', sp.wanZiShi, (v) {
            sp.wanZiShi = v;
          }),
          const Divider(height: 16),
          _buildSwitchRow('辰沐土爻', '辰/戌/丑/未月土爻旺相（开发中）', sp.chenMuTuYao, (v) {
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
          _buildSwitchRow('天干', '四柱天干显示', sp.display.showTianGan, (v) {
            sp.toggleDisplay('showTianGan');
          }),
          const Divider(height: 4),
          _buildSwitchRow('纳音', '六十甲子纳音', sp.display.showNaYin, (v) {
            sp.toggleDisplay('showNaYin');
          }),
          const Divider(height: 4),
          _buildSwitchRow('神煞', '吉凶神煞', sp.display.showShenSha, (v) {
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
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 复制全部日志（用户反馈"日志不能复制很不科学"）：
                // 一键把全部日志拼成文本复制到剪贴板，便于粘贴给开发者排查
                IconButton(
                  icon: const Icon(Icons.copy, size: 20),
                  onPressed: () {
                    final buf = StringBuffer();
                    for (final e in log.logs) {
                      buf.writeln(
                          '[${e.time.hour.toString().padLeft(2, '0')}:${e.time.minute.toString().padLeft(2, '0')}:${e.time.second.toString().padLeft(2, '0')}] ${e.levelTag} ${e.message}${e.detail != null && e.detail!.isNotEmpty ? ' | ${e.detail}' : ''}');
                    }
                    Clipboard.setData(ClipboardData(text: buf.toString()));
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      const SnackBar(content: Text('日志已复制到剪贴板'),
                          duration: Duration(seconds: 1)),
                    );
                  },
                  tooltip: '复制全部日志',
                ),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // SelectableText：日志可长按选择/复制（用户反馈
                          // "日志不能复制很不科学"）
                          SelectableText(
                            '[${e.time.hour.toString().padLeft(2,'0')}:${e.time.minute.toString().padLeft(2,'0')}:${e.time.second.toString().padLeft(2,'0')}] ${e.message}',
                            style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                          ),
                          if (e.detail != null && e.detail!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 2, left: 4),
                              child: SelectableText(
                                e.detail!,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontFamily: 'monospace',
                                  color: e.level == LogLevel.error
                                      ? Colors.red.shade300
                                      : Colors.grey.shade600,
                                ),
                              ),
                            ),
                        ],
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

  // ──────────────── 🧭 小工具 ────────────────

  Widget _buildCompassEntry(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    final t = isDark ? const Color(0xFFE0D5C8) : const Color(0xFF4A3728);
    return _buildCard(
      ListTile(
        leading: Icon(Icons.explore, color: theme.colorScheme.primary),
        title: Text('罗盘', style: TextStyle(fontSize: 15, color: t)),
        subtitle: Text('二十四山罗盘 · 点击方位查看详情',
            style: TextStyle(fontSize: 12, color: t.withAlpha(150))),
        trailing: Icon(Icons.chevron_right, color: t.withAlpha(120)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: EdgeInsets.zero,
        onTap: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const CompassPage()));
        },
      ),
    );
  }

  // ──────────────── AI 解卦配置 ────────────────

  Widget _buildAISettings(ThemeData theme) {
    // 提供商选择弹窗（内置 + 自定义，可增删）
    void selectProviderDialog(BuildContext ctx, SettingsProvider sp) {
      showDialog(
        context: ctx,
        builder: (dialogCtx) {
          final t = Theme.of(dialogCtx);
          final providers = sp.aiProviders;
          return AlertDialog(
            title: const Text('选择 AI 提供商'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView(
                shrinkWrap: true,
                children: [
                  ...providers.asMap().entries.map((entry) {
                    final i = entry.key;
                    final preset = entry.value;
                    final isSelected = sp.aiPresetIndex == i;
                    final isBuiltin = i < SettingsProvider.aiPresets.length;
                    return ListTile(
                      leading: Icon(
                        isSelected
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                        color: isSelected ? t.colorScheme.primary : null,
                      ),
                      title: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(preset.name),
                          if (preset.free) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                              decoration: BoxDecoration(
                                color: Colors.green.withAlpha(30),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text('免费',
                                  style: TextStyle(fontSize: 10, color: Colors.green.shade700)),
                            ),
                          ],
                        ],
                      ),
                      subtitle: Text(preset.endpoint, style: const TextStyle(fontSize: 12)),
                      dense: true,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit_outlined, size: 18, color: t.colorScheme.onSurface.withAlpha(150)),
                            onPressed: () {
                              _providerEditDialog(context, sp, i);
                            },
                          ),
                          if (!isBuiltin)
                            IconButton(
                              icon: Icon(Icons.delete_outline, size: 18, color: Colors.red.shade300),
                              onPressed: () {
                                sp.removeCustomProvider(i);
                                Navigator.pop(dialogCtx);
                              },
                            ),
                        ],
                      ),
                      onTap: () {
                        sp.selectAiPreset(i);
                        Navigator.pop(dialogCtx);
                      },
                    );
                  }),
                  const Divider(),
                  // 常见供应商快速添加（默认折叠）
                  ExpansionTile(
                    dense: true,
                    tilePadding: const EdgeInsets.symmetric(horizontal: 16),
                    childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    title: Text('快速添加常见提供商',
                        style: TextStyle(fontSize: 13, color: t.colorScheme.onSurface.withAlpha(180))),
                    subtitle: Text('点击展开一键添加', style: TextStyle(fontSize: 11, color: t.colorScheme.onSurface.withAlpha(120))),
                    leading: const Icon(Icons.library_add_outlined, size: 18),
                    children: [
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          _commonProviderChip('智谱 GLM', 'https://open.bigmodel.cn/api/paas/v4', 'glm-4.7-flash', ['glm-4.7-flash', 'glm-4.7', 'glm-5'], sp, dialogCtx),
                          _commonProviderChip('OpenAI', 'https://api.openai.com/v1', 'gpt-4o', ['gpt-4o', 'gpt-4o-mini', 'gpt-4', 'gpt-3.5-turbo'], sp, dialogCtx),
                          _commonProviderChip('DeepSeek', 'https://api.deepseek.com/v1', 'deepseek-chat', ['deepseek-chat', 'deepseek-reasoner'], sp, dialogCtx),
                          _commonProviderChip('通义千问', 'https://dashscope.aliyuncs.com/compatible-mode/v1', 'qwen-turbo', ['qwen-turbo', 'qwen-plus', 'qwen-max'], sp, dialogCtx),
                          _commonProviderChip('月之暗面 Kimi', 'https://api.moonshot.cn/v1', 'moonshot-v1-8k', ['moonshot-v1-8k', 'moonshot-v1-32k', 'moonshot-v1-128k'], sp, dialogCtx),
                          _commonProviderChip('豆包/火山方舟', 'https://ark.cn-beijing.volces.com/api/v3', 'doubao-pro-32k', ['doubao-pro-32k', 'doubao-lite-32k'], sp, dialogCtx),
                          _commonProviderChip('硅基流动', 'https://api.siliconflow.cn/v1', 'Qwen/Qwen2.5-7B-Instruct', ['Qwen/Qwen2.5-7B-Instruct', 'deepseek-ai/DeepSeek-V3'], sp, dialogCtx),
                          _commonProviderChip('Anthropic Claude', 'https://api.anthropic.com/v1', 'claude-3-5-sonnet', ['claude-3-5-sonnet', 'claude-3-haiku'], sp, dialogCtx),
                          _commonProviderChip('opencode zen', 'https://opencode.ai/zen/v1', 'mimo-v2.5-free', ['mimo-v2.5-free', 'north-mini-code-free', 'nemotron-3-ultra-free', 'big-pickle'], sp, dialogCtx),
                          _commonProviderChip('商汤日日新', 'https://token.sensenova.cn/v1', 'glm-5.2', ['glm-5.2', 'glm-5.1', 'glm-4.7-flash'], sp, dialogCtx),
                        ],
                      ),
                    ],
                  ),
                  const Divider(),
                  // 添加自定义提供商
                  TextButton.icon(
                    onPressed: () {
                      Navigator.pop(dialogCtx);
                      _addProviderDialog(context, sp);
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('添加自定义提供商'),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(dialogCtx),
                  child: const Text('关闭')),
            ],
          );
        },
      );
    }

    return _buildCard(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 总开关
          Consumer<SettingsProvider>(
            builder: (ctx, sp, _) => _buildSettingRow(
              icon: Icons.auto_awesome,
              title: '启用 AI 解卦',
              subtitle: '开启后可在卦例详情页使用 AI 辅助分析',
              trailing: Switch(
                value: sp.aiEnabled,
                onChanged: (v) => sp.aiEnabled = v,
              ),
            ),
          ),
          const Divider(height: 1),
          // 429 限流自动重试
          Consumer<SettingsProvider>(
            builder: (ctx, sp, _) => _buildSettingRow(
              icon: Icons.refresh,
              title: '429 限流自动重试',
              subtitle: '遇到限流(429)自动重试，最多20次',
              trailing: Switch(
                value: sp.aiRetryOn429,
                onChanged: (v) => sp.aiRetryOn429 = v,
              ),
            ),
          ),
          const Divider(height: 1),
          // 提供商选择
          Consumer<SettingsProvider>(
            builder: (ctx, sp, _) => _buildSettingsRow(
              icon: Icons.cloud,
              title: '提供商',
              subtitle: sp.aiProviderName,
              onTap: () => selectProviderDialog(context, sp),
            ),
          ),
          const Divider(height: 1),
          // API 地址（所有提供商均可编辑）
          Consumer<SettingsProvider>(
            builder: (ctx, sp, _) => _buildSettingsRow(
              icon: Icons.link,
              title: 'API 地址',
              subtitle: sp.aiEndpoint.isEmpty ? '未设置' : sp.aiEndpoint,
              onTap: () => _editText(context, 'API 地址', sp.aiEndpoint, (v) => sp.aiEndpoint = v),
            ),
          ),
          const Divider(height: 1),
          // API 密钥
          Consumer<SettingsProvider>(
            builder: (ctx, sp, _) => _buildSettingsRow(
              icon: Icons.key,
              title: 'API 密钥',
              subtitle: sp.isFreeProvider
                  ? '内置免费（源码加密，无需填写）'
                  : (sp.aiApiKey.isEmpty ? '未设置' : '••••••${sp.aiApiKey.substring(sp.aiApiKey.length > 6 ? sp.aiApiKey.length - 4 : 0)}'),
              onTap: sp.isFreeProvider
                  ? () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('内置免费提供商密钥已内置并加密，无需填写'), duration: Duration(seconds: 2)))
                  : () => _editText(context, 'API 密钥', sp.aiApiKey,
                      (v) => sp.aiApiKey = v,
                      obscure: true),
            ),
          ),
          const Divider(height: 1),
          // 模型
          Consumer<SettingsProvider>(
            builder: (ctx, sp, _) => _buildSettingsRow(
              icon: Icons.model_training,
              title: '模型',
              subtitle: sp.effectiveAiModel.isEmpty ? '未设置' : sp.effectiveAiModel,
              onTap: () => _selectModelDialog(context, sp),
            ),
          ),
          const Divider(height: 1),
          // 提示词模板
          Consumer<SettingsProvider>(
            builder: (ctx, sp, _) => _buildSettingsRow(
              icon: Icons.auto_awesome,
              title: '提示词模板',
              subtitle: sp.aiSystemPrompt.isEmpty ? '默认（已调优）' : '自定义',
              onTap: () => _editPromptTemplate(context, sp),
            ),
          ),
          // 提示词内容预览（点击直接编辑，方便查看/修改）
          Consumer<SettingsProvider>(
            builder: (ctx, sp, _) {
              final prompt = sp.aiSystemPrompt;
              // 默认也显示：未自定义时展示默认模板说明
              final displayText = prompt.isEmpty
                  ? '（未自定义）默认使用内置模板：让 AI 扮演六爻/梅花/八字解卦专家，'
                      '结合卦象/命盘、占问对象与事件、用户画像进行针对性分析并给出建议。\n'
                      '点击下方"编辑提示词模板"可自定义。'
                  : (prompt.length > 120 ? '${prompt.substring(0, 120)}…' : prompt);
              return InkWell(
                onTap: () => _editPromptTemplate(context, sp),
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withAlpha(60)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('提示词预览（点击编辑）',
                          style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.primary)),
                      const SizedBox(height: 4),
                      Text(
                        displayText,
                        style: TextStyle(fontSize: 11, height: 1.4, color: Theme.of(context).colorScheme.onSurface.withAlpha(180)),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// 常见供应商快速添加 Chip
  Widget _commonProviderChip(String name, String endpoint, String model, List<String> models, SettingsProvider sp, BuildContext dialogCtx) {
    return ActionChip(
      label: Text(name, style: const TextStyle(fontSize: 11)),
      onPressed: () {
        final exists = sp.aiProviders.any((p) => p.endpoint == endpoint);
        if (!exists) {
          sp.addCustomProvider(AiProviderPreset(
            name: name,
            endpoint: endpoint,
            apiKey: '',
            model: model,
            models: models,
          ));
          Navigator.pop(dialogCtx);
        } else {
          Navigator.pop(dialogCtx);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$name 已存在'), duration: const Duration(seconds: 1)),
          );
        }
      },
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  /// 添加自定义提供商弹窗
  void _addProviderDialog(BuildContext context, SettingsProvider sp) {
    final nameCtrl = TextEditingController();
    final endpointCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('添加自定义提供商'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: '名称', hintText: '如：我的提供商')),
              const SizedBox(height: 8),
              TextField(controller: endpointCtrl, decoration: const InputDecoration(labelText: 'API 地址', hintText: 'https://api.example.com/v1')),
              const SizedBox(height: 8),
              Text('添加后可继续编辑 API 密钥、模型列表等', style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withAlpha(150))),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          FilledButton(
            onPressed: () {
              if (nameCtrl.text.trim().isEmpty || endpointCtrl.text.trim().isEmpty) return;
              sp.addCustomProvider(AiProviderPreset(
                name: nameCtrl.text.trim(),
                endpoint: endpointCtrl.text.trim().trimRight(),
                apiKey: '',
                model: 'gpt-4',
                models: ['gpt-4'],
              ));
              Navigator.pop(ctx);
              // 自动打开编辑弹窗
              _providerEditDialog(context, sp, sp.aiProviders.length - 1);
            },
            child: const Text('添加'),
          ),
        ],
      ),
    );
  }

  /// 编辑提供商（名称、密钥、模型列表 chips 可增删）
  void _providerEditDialog(BuildContext context, SettingsProvider sp, int index) {
    final providers = sp.aiProviders;
    if (index < 0 || index >= providers.length) return;
    showDialog(
      context: context,
      builder: (ctx) => _ProviderEditDialog(sp: sp, index: index, preset: providers[index]),
    );
  }

  /// 编辑 AI 提示词模板（多行文本）
  void _editPromptTemplate(BuildContext context, SettingsProvider sp) {
    final ctrl = TextEditingController(text: sp.aiSystemPrompt);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('提示词模板'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('自定义 AI 系统提示词，留空使用内置默认模板（已调优）。',
                  style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withAlpha(180))),
              const SizedBox(height: 8),
              TextField(
                controller: ctrl,
                maxLines: 8,
                decoration: const InputDecoration(
                  hintText: '输入自定义提示词…',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () {
            // 恢复默认
            sp.aiSystemPrompt = '';
            Navigator.pop(ctx);
          }, child: const Text('恢复默认')),
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          FilledButton(onPressed: () {
            sp.aiSystemPrompt = ctrl.text.trim();
            Navigator.pop(ctx);
          }, child: const Text('保存')),
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

  /// 模型选择弹窗（使用当前提供商的推荐模型列表 + 自定义）
  void _selectModelDialog(BuildContext context, SettingsProvider sp) {
    final currentProvider = sp.currentProvider;
    final models = currentProvider != null
        ? List<String>.from(currentProvider.models)
        : <String>[];
    if (models.isEmpty) {
      models.addAll(['glm-4.7-flash', 'mimo-v2.5-free', 'north-mini-code-free', 'nemotron-3-ultra-free']);
    }
    final customCtrl = TextEditingController(text: sp.aiCustomModel);
    showDialog(
      context: context,
      builder: (ctx) {
        final theme2 = Theme.of(ctx);
        return AlertDialog(
          title: const Text('选择 AI 模型'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 当前提供商的推荐模型
                Text('推荐模型', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: models.map((m) {
                    final sel = sp.effectiveAiModel == m;
                    return ChoiceChip(
                      label: Text(m, style: TextStyle(fontSize: 13, color: sel ? theme2.colorScheme.primary : null)),
                      selected: sel,
                      onSelected: (_) { sp.aiCustomModel = ''; sp.aiModel = m; Navigator.pop(ctx); },
                    );
                  }).toList(),
                ),
                const Divider(height: 20),
                const Text('或自定义模型名', style: TextStyle(fontSize: 12)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: customCtrl,
                        decoration: const InputDecoration(
                          hintText: '输入自定义模型名',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        if (customCtrl.text.trim().isNotEmpty) {
                          sp.aiCustomModel = customCtrl.text.trim();
                          Navigator.pop(ctx);
                        }
                      },
                      child: const Text('确认'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  Widget _buildSettingsRow({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    final t = Theme.of(context);
    final enabled = onTap != null;
    return InkWell(
      onTap: onTap,
      child: Opacity(
        opacity: enabled ? 1.0 : 0.5,
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
              if (enabled)
                const Icon(Icons.edit_outlined, size: 16, color: Colors.grey),
            ],
          ),
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

/// 提供商编辑对话框（StatefulWidget：模型列表 chips 可增删）
class _ProviderEditDialog extends StatefulWidget {
  final SettingsProvider sp;
  final int index;
  final AiProviderPreset preset;
  const _ProviderEditDialog({
    required this.sp,
    required this.index,
    required this.preset,
  });

  @override
  State<_ProviderEditDialog> createState() => _ProviderEditDialogState();
}

class _ProviderEditDialogState extends State<_ProviderEditDialog> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _endpointCtrl;
  late final TextEditingController _keyCtrl;
  late final TextEditingController _addModelCtrl;
  late List<String> _models;

  @override
  void initState() {
    super.initState();
    final p = widget.preset;
    _nameCtrl = TextEditingController(text: p.name);
    _endpointCtrl = TextEditingController(text: p.endpoint);
    // 内置免费提供商：密钥不显示明文
    _keyCtrl = TextEditingController(text: p.free ? '' : p.apiKey);
    _addModelCtrl = TextEditingController();
    _models = List<String>.from(p.models);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _endpointCtrl.dispose();
    _keyCtrl.dispose();
    _addModelCtrl.dispose();
    super.dispose();
  }

  void _addModel() {
    final m = _addModelCtrl.text.trim();
    if (m.isEmpty) return;
    setState(() {
      if (!_models.contains(m)) _models.add(m);
      _addModelCtrl.clear();
    });
  }

  /// 从上游获取模型列表（GET {endpoint}/models）
  Future<void> _fetchModels() async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('正在从上游获取模型列表…'), duration: const Duration(seconds: 3)),
    );
    try {
      final endpoint = _endpointCtrl.text.trim().replaceAll(RegExp(r'/+$'), '');
      final key = widget.preset.free ? widget.preset.apiKey : _keyCtrl.text.trim();
      final url = '$endpoint/models';
      final res = await http.get(
        Uri.parse(url),
        headers: {
          if (key.isNotEmpty) 'Authorization': 'Bearer $key',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 20));
      if (res.statusCode != 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('获取失败 HTTP ${res.statusCode}: ${res.body.length > 100 ? res.body.substring(0, 100) : res.body}')),
          );
        }
        return;
      }
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final list = data['data'] as List? ?? [];
      final ids = list
          .map((e) => e is Map ? (e['id']?.toString() ?? '') : e.toString())
          .where((s) => s.isNotEmpty)
          .toList();
      if (ids.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('接口未返回模型列表（可能需登录/付费）')),
          );
        }
        return;
      }
      setState(() {
        _models = ids;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('已获取 ${ids.length} 个模型')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('获取失败: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.preset;
    final t = Theme.of(context).colorScheme.onSurface;
    return AlertDialog(
      title: Text('编辑 ${p.name}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: '名称', isDense: true)),
            const SizedBox(height: 6),
            TextField(controller: _endpointCtrl, decoration: const InputDecoration(labelText: 'API 地址', isDense: true)),
            const SizedBox(height: 6),
            TextField(
              controller: _keyCtrl,
              decoration: InputDecoration(
                labelText: 'API 密钥',
                hintText: p.free ? '内置免费（已加密）' : 'sk-...',
                isDense: true,
              ),
              obscureText: true,
            ),
            const SizedBox(height: 10),
            Text('模型列表', style: TextStyle(fontSize: 12, color: t.withAlpha(180))),
            const SizedBox(height: 6),
            // 模型 chips（可删除）
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: _models.map((m) {
                return InputChip(
                  label: Text(m, style: const TextStyle(fontSize: 12)),
                  visualDensity: VisualDensity.compact,
                  onDeleted: () => setState(() => _models.remove(m)),
                );
              }).toList(),
            ),
            const SizedBox(height: 6),
            // 添加模型
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _addModelCtrl,
                    decoration: const InputDecoration(
                      labelText: '添加模型',
                      hintText: '输入模型名后点 + 或回车',
                      isDense: true,
                    ),
                    onSubmitted: (_) => _addModel(),
                  ),
                ),
                const SizedBox(width: 6),
                IconButton(
                  onPressed: _addModel,
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
            ),
            const SizedBox(height: 2),
            // 从上游获取模型
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: _fetchModels,
                icon: const Icon(Icons.cloud_download_outlined, size: 15),
                label: const Text('从上游获取模型列表', style: TextStyle(fontSize: 12)),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ),
            if (!p.builtin) ...[
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: () {
                  widget.sp.removeCustomProvider(widget.index);
                  Navigator.pop(context);
                },
                icon: Icon(Icons.delete_outline, size: 16, color: Colors.red.shade300),
                label: Text('删除此提供商', style: TextStyle(color: Colors.red.shade300, fontSize: 13)),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
        FilledButton(
          onPressed: () {
            if (_nameCtrl.text.trim().isEmpty) return;
            final key = _keyCtrl.text.trim();
            final updated = AiProviderPreset(
              name: _nameCtrl.text.trim(),
              endpoint: _endpointCtrl.text.trim(),
              apiKey: widget.preset.free ? widget.preset.apiKey : key,
              model: _models.isNotEmpty ? _models.first : widget.preset.model,
              models: _models.isNotEmpty ? _models : widget.preset.models,
            );
            if (widget.preset.builtin) {
              // 内置提供商：允许增删模型（保存到覆盖列表），非免费可更新 key
              widget.sp.setProviderModels(widget.preset.name, _models);
              if (!widget.preset.free && key.isNotEmpty) {
                widget.sp.aiApiKey = key;
              }
              if (_models.isNotEmpty && widget.sp.aiModel.isEmpty) {
                widget.sp.aiCustomModel = _models.first;
              }
            } else {
              widget.sp.updateCustomProvider(widget.index, updated);
            }
            Navigator.pop(context);
            Logger.instance.info('AI提供商已更新', _nameCtrl.text.trim());
          },
          child: const Text('保存'),
        ),
      ],
    );
  }
}
