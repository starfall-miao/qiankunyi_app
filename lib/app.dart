import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'features/paipan/views/paipan_page.dart';
import 'features/cases/views/case_page.dart';
import 'features/reference/views/reference_page.dart';
import 'features/settings/settings_page.dart';

/// 乾坤易应用入口 Widget
class QianKunYiApp extends StatelessWidget {
  const QianKunYiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return MaterialApp(
          title: '乾坤易',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          home: const MainShell(),
        );
      },
    );
  }
}

/// 主框架（底部导航栏）
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final _pages = const <Widget>[
    PaipanPage(),
    CasePage(),
    ReferencePage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.auto_awesome), label: '排盘'),
          NavigationDestination(icon: Icon(Icons.bookmark_outline), label: '卦例'),
          NavigationDestination(icon: Icon(Icons.menu_book_outlined), label: '参考'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), label: '设置'),
        ],
      ),
    );
  }
}
