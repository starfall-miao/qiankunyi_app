// 落·乾坤 - 应用入口

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'features/paipan/views/paipan_page.dart';

import 'features/cases/views/case_page.dart';
import 'features/reference/views/reference_page.dart';
import 'features/settings/settings_page.dart';
import 'features/settings/settings_provider.dart';
import 'features/calendar/views/calendar_page.dart';

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
          theme: AppTheme.lightTheme(tp.colorSchemeType,
              useAcrylic: tp.acrylicEffect, acrylicOpacity: tp.acrylicOpacity),
          darkTheme: AppTheme.darkTheme(tp.colorSchemeType,
              useAcrylic: tp.acrylicEffect, acrylicOpacity: tp.acrylicOpacity),
          themeMode: tp.themeMode,
          builder: (ctx, child) => _FontScaled(child: child!),
          home: const MainShell(),
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

  final _pages = const [
    PaipanPage(),
    CasePage(),
    CalendarPage(),
    ReferencePage(),
    SettingsPage(),
  ];

  // 导航栏配置
  static const _navDestinations = [
    NavigationDestination(icon: Icon(Icons.change_circle_outlined), label: '排盘'),
    NavigationDestination(icon: Icon(Icons.bookmark_border), label: '卦例'),
    NavigationDestination(icon: Icon(Icons.calendar_month_outlined), label: '日历'),
    NavigationDestination(icon: Icon(Icons.menu_book_outlined), label: '参考'),
    NavigationDestination(icon: Icon(Icons.settings_outlined), label: '设置'),
  ];

  static const _navRailDestinations = [
    NavigationRailDestination(
      icon: Icon(Icons.change_circle_outlined),
      label: Text('排盘'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.bookmark_border),
      label: Text('卦例'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.calendar_month_outlined),
      label: Text('日历'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.menu_book_outlined),
      label: Text('参考'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.settings_outlined),
      label: Text('设置'),
    ),
  ];

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
      child: Scaffold(
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
              destinations: _navRailDestinations,
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
              destinations: _navDestinations,
            )
          : null,
      ),
    );
  }
}
