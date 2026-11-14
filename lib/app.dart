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
        // 引导设计原则：每步只讲一件事、可直接照做；共 10 步一屏一步
        SpotlightStep(
            title: '欢迎使用落·乾坤',
            tabIndex: 0,
            desc: '这是离线易学工具：六爻 / 梅花 / 八字 / 小六壬 / 大六壬排盘，'
                '外加万年历、二十四山罗盘与六十四卦资料。\n'
                '下面用 10 步走一遍核心流程，随时可点「跳过」。'),
        SpotlightStep(
            targetKey: _navKeys[0],
            title: '① 排盘：一切从这里开始',
            tabIndex: 0,
            desc: '点这个 Tab 进入排盘。顶部可切换五种术数：\n'
                '· 六爻：铜钱摇卦，问具体事（如"这笔款能收回吗"）\n'
                '· 梅花：数字 / 时间起卦，看体用生克\n'
                '· 八字：输入出生时间排四柱\n'
                '· 小六壬 / 大六壬：掌诀与三式起课'),
        SpotlightStep(
            title: '② 选起卦方式',
            tabIndex: 0,
            desc: '六爻有四种：手工摇卦（自选六爻）、机器摇卦（三枚铜钱概率）、'
                '时间起卦（梅花通行法）、数字起卦（两数定卦 + 动爻）。\n'
                '想动爻多通常选机器摇卦；想指定卦象选手工或数字。'),
        SpotlightStep(
            title: '③ 看懂排盘结果',
            tabIndex: 0,
            desc: '结果区依次是：月建日辰旬空神煞 → 本卦 / 变卦 / 互卦 → '
                '每爻的六亲、六神、旺衰、月破、化进退化、纳音与神煞。\n'
                '点任意一爻可看该项的白话详解。'),
        SpotlightStep(
            targetKey: _navKeys[1],
            title: '④ 卦例：保存与回看',
            tabIndex: 1,
            desc: '排盘后可「保存卦例」，这里集中管理：搜索、编辑标题与占问事件、'
                '导出 JSON / 导入合并。'),
        SpotlightStep(
            title: '⑤ AI 解卦与追问',
            tabIndex: 1,
            desc: '打开卦例详情点「开始 AI 解卦」，AI 会结合卦象、占问对象与你的人'
                '物画像分析；结果可连续追问，也能保存成图片分享。\n'
                'AI 提供商与提示词在「百宝箱 → AI 解卦配置」。'),
        SpotlightStep(
            targetKey: _navKeys[2],
            title: '⑥ 日历：万年历与宜忌',
            tabIndex: 2,
            desc: '公历 / 农历 / 干支 / 节气 / 宜忌 / 值神 / 六曜 / 二十八宿，'
                '点任意日期看当日详情。'),
        SpotlightStep(
            targetKey: _navKeys[3],
            title: '⑦ 参考：易学资料库',
            tabIndex: 3,
            desc: '六十四卦爻辞、京房八宫、神煞、纳音、二十八宿、象意、禽星、'
                '动变等分类资料，顶部搜索框可直接查卦名。'),
        SpotlightStep(
            targetKey: _navKeys[4],
            title: '⑧ 百宝箱：设置与画像',
            tabIndex: 4,
            desc: '用户画像（多用户、八字画像供 AI 参考）、易学教程、AI 配置、'
                '测算显示项、字体与主题、数据管理与本引导的重新播放。'),
        SpotlightStep(
            title: '完成！随时可再看引导',
            tabIndex: 0,
            desc: '核心流程：排盘 → 卦例 → AI 解卦 → 日历 → 参考 → 百宝箱。\n'
                '想重看本引导：百宝箱 → 使用引导 → 播放实操引导。祝易学顺利！'),
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
      if ((sp.onboardingDone && !_spotlightInitialized) ||
          sp.showSpotlightGuide) {
        _spotlightInitialized = true;
        if (sp.showSpotlightGuide) sp.consumeSpotlightGuide();
        setState(() => _spotlightVisible = true);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 响应设置页"实操引导"请求
    final sp = context.watch<SettingsProvider>();
    if (sp.showSpotlightGuide && mounted) {
      _spotlightInitialized = true;
      sp.consumeSpotlightGuide();
      setState(() => _spotlightVisible = true);
    }
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
          fallbackNavKeys: _navKeys,
          onStepChanged: (i) {
            // 画面随引导步骤切换对应 Tab
            final tab = i >= 0 && i < _spotlightSteps.length
                ? _spotlightSteps[i].tabIndex
                : null;
            if (tab != null && tab != _currentIndex) {
              setState(() => _currentIndex = tab);
            }
          },
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
