import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:qiankunyi_app/app.dart';
import 'package:qiankunyi_app/core/theme/theme_provider.dart';
import 'package:qiankunyi_app/features/paipan/providers/paipan_provider.dart';
import 'package:qiankunyi_app/features/cases/providers/case_provider.dart';
import 'package:qiankunyi_app/features/settings/settings_provider.dart';
import 'package:qiankunyi_app/features/paipan/providers/bazi_provider.dart';
import 'package:qiankunyi_app/features/users/providers/user_provider.dart';

void main() {
  testWidgets('App launches with main navigation',
      (WidgetTester tester) async {
    // Mock SharedPreferences for SettingsProvider init
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
        child: const QianKunYiApp(),
      ),
    );

    // NavigationBar destinations should be visible
    // 注意：'排盘' 可能出现2处（底部导航 + 排盘页按钮），用 findsWidgets 断言至少存在
    expect(find.text('排盘'), findsWidgets);
    expect(find.text('卦例'), findsWidgets);
    expect(find.text('日历'), findsWidgets);
    expect(find.text('参考'), findsWidgets);
    expect(find.text('设置'), findsWidgets);
    // 底部导航栏存在
    expect(find.byType(NavigationBar), findsOneWidget);
  });
}