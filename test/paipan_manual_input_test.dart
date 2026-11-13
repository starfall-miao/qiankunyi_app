/// 手工摇卦输入 → 排盘结果 的 UI 链路测试
///
/// 回归重点：面板自上而下显示「初爻…上爻」，且把「初爻」存在
/// `_manualYaos[5]`；提交时必须按 5-i 取出，否则整卦上下颠倒
/// （画「天风姤」会排出「天泽履」）。
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:qiankunyi_app/core/theme/theme_provider.dart';
import 'package:qiankunyi_app/features/cases/providers/case_provider.dart';
import 'package:qiankunyi_app/features/paipan/providers/bazi_provider.dart';
import 'package:qiankunyi_app/features/paipan/providers/paipan_provider.dart';
import 'package:qiankunyi_app/features/paipan/views/paipan_page.dart';
import 'package:qiankunyi_app/features/settings/settings_provider.dart';
import 'package:qiankunyi_app/features/users/providers/user_provider.dart';

Future<void> _pumpPaipanPage(WidgetTester tester) async {
  SharedPreferences.setMockInitialValues({});
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => PaipanProvider()),
        ChangeNotifierProvider(create: (_) => CaseProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()..init()),
        ChangeNotifierProvider(create: (_) => BaziProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()..init()),
      ],
      child: const MaterialApp(home: PaipanPage()),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('手工摇卦：画天风姤（初爻阴、余阳）应排出天风姤', (tester) async {
    await _pumpPaipanPage(tester);

    // 面板自下而上：第 0 行是「初爻」…第 5 行是「上爻」
    // 默认全为「少阴」，把二爻到上爻改为「少阳」，初爻保留「少阴」
    final shaoYangChips = find.text('少阳');
    expect(shaoYangChips, findsNWidgets(6), reason: '每行一个少阳选项');

    for (var row = 1; row <= 5; row++) {
      await tester.tap(shaoYangChips.at(row));
      await tester.pump();
    }

    // 点击排盘按钮（底部导航无此按钮，此处用 ElevatedButton 精确定位）
    await tester.tap(find.widgetWithText(ElevatedButton, '排盘'));
    await tester.pumpAndSettle(const Duration(seconds: 1));

    // 结果卡片应显示「天风姤」，而不是上下颠倒的「天泽履」
    expect(find.text('天风姤'), findsWidgets,
        reason: '初爻阴、二至五爻阳、上爻阳 = 天风姤（上乾下巽）');
    expect(find.text('天泽履'), findsNothing,
        reason: '若爻序颠倒会误排成天泽履');
  });

  testWidgets('手工摇卦：全阳排出乾为天', (tester) async {
    await _pumpPaipanPage(tester);

    final shaoYangChips = find.text('少阳');
    for (var row = 0; row < 6; row++) {
      await tester.tap(shaoYangChips.at(row));
      await tester.pump();
    }
    await tester.tap(find.widgetWithText(ElevatedButton, '排盘'));
    await tester.pumpAndSettle(const Duration(seconds: 1));

    expect(find.text('乾为天'), findsWidgets);
  });
}
