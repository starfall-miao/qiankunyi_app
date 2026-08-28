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
        // ── 流程式引导（约 15 步，画面随引导切换 Tab）──
        SpotlightStep(title: '欢迎使用落·乾坤', tabIndex: 0,
            desc: '易学助手：六爻、梅花、八字、小六壬、大六壬五大排盘，AI 解卦，海量资料。'
                '跟着引导走一遍核心流程吧！'),
        SpotlightStep(targetKey: _navKeys[0], title: '1. 排盘 Tab', tabIndex: 0,
            desc: '这是"排盘"入口。点击下方 Tab 切换术数：\n'
                '· 六爻：铜钱摇卦（如"这单生意能成吗"）\n'
                '· 梅花：数字/时间起卦\n'
                '· 八字：输入出生信息排四柱'),
        SpotlightStep(title: '2. 选择起卦方式', tabIndex: 0,
            desc: '排盘页顶部可选起卦方式：\n'
                '· 手工摇卦 / 机器摇卦 / 时间起卦 / 数字起卦\n'
                '例子：选"数字起卦"，输入 3 个数字（如 3、5、7）点排盘。'),
        SpotlightStep(title: '3. 查看卦象', tabIndex: 0,
            desc: '排盘结果展示本卦/变卦/互卦、世应、六亲、空亡、藏爻等。\n'
                '点按卦象可看详解，点"保存卦例"存入卦例库。'),
        SpotlightStep(targetKey: _navKeys[1], title: '4. 卦例 Tab', tabIndex: 1,
            desc: '这是"卦例"入口，保存的卦例都在这里。\n'
                '点击卦例可查看详情、编辑占问对象/事件、AI 解卦、导出/导入。'),
        SpotlightStep(title: '5. AI 解卦', tabIndex: 1,
            desc: '在卦例详情点"开始 AI 解卦"，AI 会结合卦象、占问对象与用户画像分析。\n'
                '例子：对刚摇的卦问"近期财运如何"，AI 会给出解读与建议。'),
        SpotlightStep(title: '6. 保存对话图片', tabIndex: 1,
            desc: 'AI 解卦结果可"保存为图片"（勾选对话，含卦例基本内容），方便分享。'),
        SpotlightStep(targetKey: _navKeys[2], title: '7. 日历 Tab', tabIndex: 2,
            desc: '这是"日历"入口：万年历、宜忌、农历节气，日常查询很方便。'),
        SpotlightStep(targetKey: _navKeys[3], title: '8. 参考 Tab', tabIndex: 3,
            desc: '这是"参考"入口：六十四卦、纳音、星宿、象意字典、神煞等海量资料。\n'
                '搜索框可快速找卦，如输入"泰"。'),
        SpotlightStep(targetKey: _navKeys[4], title: '9. 百宝箱 Tab', tabIndex: 4,
            desc: '这是"百宝箱"（设置）入口：\n'
                '· 用户画像：多用户，八字画像供 AI 参考\n'
                '· 易学教程：周易/六爻/梅花/八字/速查卡\n'
                '· AI 配置、数据管理等'),
        SpotlightStep(title: '10. 用户画像', tabIndex: 4,
            desc: '在百宝箱最上方"用户画像"：创建用户、填写八字自动生成画像，'
                'AI 解卦时会参考画像（可关闭）。'),
        SpotlightStep(title: '11. AI 提供商', tabIndex: 4,
            desc: '在"AI 解卦配置"选提供商（智谱/商汤/OpenAI 等），'
                '可添加自定义、从上游获取模型、自定义提示词。'),
        SpotlightStep(title: '12. 数据管理', tabIndex: 4,
            desc: '"数据管理"可查看卦例统计、清空卦例、恢复默认设置，'
                '数据本地保存，隐私安全。'),
        SpotlightStep(title: '13. 保存图片', tabIndex: 0,
            desc: '所有排盘结果都支持"保存图片"（PNG），生成美观的排盘图分享。'),
        SpotlightStep(title: '完成！祝你易学顺利', tabIndex: 0,
            desc: '已了解核心流程：排盘 → 卦例 → AI 解卦 → 日历 → 参考 → 百宝箱。\n'
                '更多功能可在"百宝箱 → 使用引导"随时重看。'),
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
