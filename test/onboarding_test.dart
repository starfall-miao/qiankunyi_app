/// 首次启动引导页测试：单页（一屏读完）+ 只有一个「开始使用」按钮
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:qiankunyi_app/features/onboarding/views/onboarding_page.dart';

void main() {
  testWidgets('引导页为单页：无分页指示器与「下一步」', (tester) async {
    var done = false;
    await tester.pumpWidget(
      MaterialApp(home: OnboardingPage(onDone: () => done = true)),
    );
    await tester.pumpAndSettle();

    // 只有一页内容：应出现欢迎标题与核心说明
    expect(find.textContaining('欢迎来到'), findsWidgets);
    expect(find.textContaining('百宝箱'), findsWidgets);

    // 不应再有多页翻页控件
    expect(find.byType(PageView), findsNothing);
    expect(find.text('下一步'), findsNothing);
    expect(find.text('上一步'), findsNothing);

    // 唯一的入口按钮
    expect(find.widgetWithText(FilledButton, '开始使用'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, '开始使用'));
    await tester.pump();
    expect(done, isTrue);
  });
}
