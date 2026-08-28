// 落·乾坤 - 应用入口

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'features/paipan/views/paipan_page.dart';

import 'features/cases/views/case_page.dart';
import 'features/reference/views/reference_page.dart';
import 'features/settings/settings_page.dart';
import 'features/settings/settings_provider.dart';
import 'features/calendar/views/calendar_page.dart';
import 'features/onboarding/views/onboarding_page.dart';
import 'shared/widgets/spotlight_overlay.dart';

/// 落·乾坤 应用入口 Widget
class QianKunYiApp extends StatelessWidget {
  const QianKunYiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, SettingsProvider>(
      builder: (context, tp, sp, _) {
        return MaterialApp(
          title: '落·乾坤',
          debugShowCheckedModeBanner: false,
          // 三端滚动适配：桌面端支持鼠标/触控板拖拽，显示滚动条
          scrollBehavior: const AppScrollBehavior(),
          theme: AppTheme.lightTheme(tp.colorSchemeType,
              useAcrylic: tp.acrylicEffect, acrylicOpacity: tp.acrylicOpacity),
          darkTheme: AppTheme.darkTheme(tp.colorSchemeType,
              useAcrylic: tp.acrylicEffect, acrylicOpacity: tp.acrylicOpacity),
          themeMode: tp.themeMode,
          builder: (ctx, child) => _FontScaled(child: child!),
          home: sp.loaded && !sp.onboardingDone
              ? OnboardingPage(onDone: () => sp.onboardingDone = true)
              : const MainShell(),
        );
      },
    );
  }
}

/// 字体缩放 — 读取 SettingsProvider 并应用 textScaleFactor
class _FontScaled extends StatelessWidget {
  final Widget child;
  const _FontScaled({required this.child});

  @override
  Widget build(BuildContext context) {
    final sp = context.watch<SettingsProvider>();
    final scale = sp.loaded ? sp.fontSize / 16.0 : 1.0;
    // ignore: deprecated_member_use
    return MediaQuery(
      // ignore: deprecated_member_use
      data: MediaQuery.of(context).copyWith(textScaleFactor: scale),
      child: child,
    );
  }
}

/// 主框架（响应式布局：移动端底部导航栏 / 桌面端左侧导航栏）
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  // 聚光灯引导：5 个导航项的目标 key + 步骤文案
  final _navKeys = List.generate(5, (_) => GlobalKey());
  bool _spotlightVisible = false;
  bool _spotlightInitialized = false;

  List<SpotlightStep> get _spotlightSteps => [
        SpotlightStep(targetKey: _navKeys[0], title: '排盘', desc: '六爻/梅花/八字/小六壬/大六壬，五大术数排盘入口。'),
        SpotlightStep(targetKey: _navKeys[1], title: '卦例', desc: '保存与管理你的卦例，支持 AI 解卦与占问记录。'),
        SpotlightStep(targetKey: _navKeys[2], title: '日历', desc: '万年历与宜忌，日常查询好帮手。'),
        SpotlightStep(targetKey: _navKeys[3], title: '参考', desc: '六十四卦、纳音、星宿、象意字典等海量易学资料。'),
        SpotlightStep(targetKey: _navKeys[4], title: '百宝箱', desc: '教程、用户画像、AI 配置、数据管理等设置入口。'),
      ];

  final _pages = const [
    PaipanPage(),
    CasePage(),
    CalendarPage(),
    ReferencePage(),
    SettingsPage(),
  ];

  // 导航栏配置（Lucide 简约有活力图标）
  static const _icons = [
    LucideIcons.compass, LucideIcons.bookmark, LucideIcons.calendar,
    LucideIcons.book, LucideIcons.settings,
  ];
  static const _labels = ['排盘', '卦例', '日历', '参考', '百宝箱'];

  List<NavigationDestination> get _destinations => [
        for (var i = 0; i < 5; i++)
          NavigationDestination(
            icon: KeyedSubtree(key: _navKeys[i], child: Icon(_icons[i])),
            label: _labels[i],
          ),
      ];

  List<NavigationRailDestination> get _railDestinations => [
        for (var i = 0; i < 5; i++)
          NavigationRailDestination(
            icon: KeyedSubtree(key: _navKeys[i], child: Icon(_icons[i])),
            label: Text(_labels[i]),
          ),
      ];

  @override
  void initState() {
    super.initState();
    // 首次进入主界面后触发聚光灯实操引导（一次性）
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final sp = context.read<SettingsProvider>();
      if (sp.onboardingDone && !_spotlightInitialized && !_spotlightVisible) {
        _spotlightInitialized = true;
        _spotlightVisible = true;
      }
    });
  }

  void _finishSpotlight() {
    setState(() => _spotlightVisible = false);
  }

  @override
  Widget build(BuildContext context) {
    final tp = context.watch<ThemeProvider>();
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width > 900;

    return Focus(
      autofocus: true,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent) {
          final key = event.logicalKey;
          if (key == LogicalKeyboardKey.digit1) { setState(() => _currentIndex = 0); return KeyEventResult.handled; }
          if (key == LogicalKeyboardKey.digit2) { setState(() => _currentIndex = 1); return KeyEventResult.handled; }
          if (key == LogicalKeyboardKey.digit3) { setState(() => _currentIndex = 2); return KeyEventResult.handled; }
          if (key == LogicalKeyboardKey.digit4) { setState(() => _currentIndex = 3); return KeyEventResult.handled; }
          if (key == LogicalKeyboardKey.digit5) { setState(() => _currentIndex = 4); return KeyEventResult.handled; }
        }
        return KeyEventResult.ignored;
      },
      child: Stack(
        children: [
          Scaffold(
        body: Row(
        children: [
          // 桌面端：左侧导航栏（NavigationRail）
          if (isDesktop && !tp.immersiveMode)
            NavigationRail(
              selectedIndex: _currentIndex,
              onDestinationSelected: (i) => setState(() => _currentIndex = i),
              labelType: NavigationRailLabelType.all,
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        'assets/images/app_icon.png',
                        width: 32,
                        height: 32,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text('落·乾坤', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: tp.colorSchemeType.primary)),
                  ],
                ),
              ),
              destinations: _railDestinations,
            ),
          // 内容区
          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              children: _pages,
            ),
          ),
        ],
      ),
      bottomNavigationBar: (!isDesktop && !tp.immersiveMode)
          ? NavigationBar(
              selectedIndex: _currentIndex,
              onDestinationSelected: (i) => setState(() => _currentIndex = i),
              destinations: _destinations,
            )
          : null,
        ),
      // 聚光灯引导
      if (_spotlightVisible)
        SpotlightOverlay(
          steps: _spotlightSteps,
          onFinish: _finishSpotlight,
          onSkip: _finishSpotlight,
        ),
        ],
      ),
    );
  }
}

/// 全局滚动行为（三端适配）：
/// - 桌面端允许鼠标 / 触控板 / 手写笔拖拽滚动（默认 Material 不支持鼠标拖拽）
/// - 桌面端滚动条常显（thumbVisibility），移动端保持自动
class AppScrollBehavior extends MaterialScrollBehavior {
  const AppScrollBehavior();

  /// 桌面端允许鼠标 / 触控板 / 手写笔拖拽滚动（默认 Material 不支持鼠标拖拽）
  @override
  Set<PointerDeviceKind> get dragDevices => const {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.stylus,
        PointerDeviceKind.trackpad,
      };
}
