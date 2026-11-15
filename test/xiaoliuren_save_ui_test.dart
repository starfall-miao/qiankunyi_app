/// 小六壬/大六壬 保存卦例 UI 链路测试（回归：保存按钮无效）
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:qiankunyi_app/core/theme/theme_provider.dart';
import 'package:qiankunyi_app/features/cases/providers/case_provider.dart';
import 'package:qiankunyi_app/features/paipan/views/xiaoliuren_page.dart';

void main() {
  testWidgets('小六壬：排盘后保存卦例应写入 CaseProvider', (tester) async {
    SharedPreferences.setMockInitialValues({});
    // 用高一些的视口，避免按钮被挤出屏幕（测试环境默认 800x600）
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final cases = CaseProvider();
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider.value(value: cases),
        ],
        child: const MaterialApp(home: XiaoLiuRenPage()),
      ),
    );
    await tester.pumpAndSettle();

    // 排盘
    await tester.tap(find.widgetWithText(ElevatedButton, '排盘'));
    await tester.pumpAndSettle(const Duration(seconds: 1));

    // 保存卦例 → 弹窗
    await tester.tap(find.text('保存卦例').first);
    await tester.pumpAndSettle();
    expect(find.text('保存卦例'), findsWidgets);

    // 点「保存」
    await tester.tap(find.widgetWithText(FilledButton, '保存'));
    await tester.pumpAndSettle();
    // 测试环境没有 ScaffoldMessenger 的注册表，保存后的 SnackBar 断言异常忽略
    final err = tester.takeException();
    if (err != null) {
      expect(err.toString(), contains('ScaffoldMessenger'));
    }

    expect(cases.allCases.length, 1, reason: '保存后应有一条卦例');
    expect(cases.allCases.first.caseType.name, 'xiaoliuren');
  });
}
