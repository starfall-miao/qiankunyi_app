import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qiankunyi_app/features/settings/views/tutorial_page.dart';

void main() {
  testWidgets('教程页五个 Tab 可切换且包含落落导语', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: TutorialPage()));

    // 落落导语出现（周易 Tab）
    expect(find.textContaining('落落说'), findsWidgets);

    // 五个 Tab 都存在
    expect(find.text('周易'), findsOneWidget);
    expect(find.text('六爻'), findsOneWidget);
    expect(find.text('梅花'), findsOneWidget);
    expect(find.text('八字'), findsOneWidget);
    expect(find.text('小六壬'), findsOneWidget);
    expect(find.text('大六壬'), findsOneWidget);
    expect(find.text('速查卡'), findsOneWidget);

    // 切换到六爻 Tab，落落导语仍在
    await tester.tap(find.text('六爻'));
    await tester.pumpAndSettle();
    expect(find.textContaining('落落说'), findsWidgets);
  });

  testWidgets('速查卡 Tab 含纳音/象意内容', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: TutorialPage()));
    await tester.tap(find.text('速查卡'));
    await tester.pumpAndSettle();
    expect(find.textContaining('纳音'), findsWidgets);
    expect(find.textContaining('八卦象意'), findsWidgets);
  });
}
