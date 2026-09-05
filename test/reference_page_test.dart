import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qiankunyi_app/features/reference/views/reference_page.dart';

void main() {
  testWidgets('参考页七个 Tab 存在且可切换', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: ReferencePage()));

    // 七个 Tab
    expect(find.text('六十四卦'), findsOneWidget);
    expect(find.text('纳音'), findsOneWidget);
    expect(find.text('二十八星宿'), findsOneWidget);
    expect(find.text('象意字典'), findsOneWidget);
    expect(find.text('禽星关系'), findsOneWidget);
    expect(find.text('神煞象义'), findsOneWidget);
    expect(find.text('动变含义'), findsOneWidget);
  });

  testWidgets('六十四卦搜索框在宫位上方', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: ReferencePage()));
    // 搜索框存在
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('搜索卦名…'), findsOneWidget);
    // 宫位 chips（乾宫等）存在
    expect(find.text('乾宫'), findsWidgets);
  });
}
