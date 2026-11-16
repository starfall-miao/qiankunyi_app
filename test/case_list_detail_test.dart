/// 卦例列表 + 详情 渲染测试（小六壬/大六壬/六爻）
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:drift/native.dart';

import 'package:qiankunyi_app/core/database/app_database.dart';
import 'package:qiankunyi_app/core/theme/theme_provider.dart';
import 'package:qiankunyi_app/features/cases/models/case_models.dart';
import 'package:qiankunyi_app/features/cases/providers/case_provider.dart';
import 'package:qiankunyi_app/features/cases/views/case_page.dart';
import 'package:qiankunyi_app/features/paipan/engines/daliuren_engine.dart';
import 'dart:convert';
import 'package:qiankunyi_app/features/paipan/engines/xiaoliuren_engine.dart';
import 'package:qiankunyi_app/features/settings/settings_provider.dart';
import 'package:qiankunyi_app/features/users/providers/user_provider.dart';

void main() {
  testWidgets('小六壬/大六壬卦例：列表可见、详情可打开不抛异常', (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(900, 2200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final db = AppDatabase.forTesting(NativeDatabase.memory());
    final cases = CaseProvider()..attachDatabase(db);

    final xlr = XiaoLiuRenEngine.byDateTime(DateTime(2024, 6, 15), 3);
    await cases.addCase(CaseModel(
      id: 11,
      title: '小六壬 · ${xlr.resultPalm.name}',
      guaName: xlr.resultPalm.name,
      guaGong: xlr.resultPalm.element,
      method: '小六壬（${xlr.method}）',
      paipanData: jsonEncode({'xiaoLiuRen': xlr.toJson()}),
      caseType: CaseType.xiaoliuren,
    ));
    final dlr = DaLiuRenEngine.byHour(3, 1,
        dayGan: '甲', dayZhi: '子', monthZhiIdx: 2,
        yearGanZhi: '甲辰', monthGanZhi: '丙寅');
    await cases.addCase(CaseModel(
      id: 12,
      title: '大六壬 · ${dlr.chuChuan}传',
      guaName: '大六壬',
      guaGong: dlr.chuChuan,
      method: '大六壬（${dlr.method}）',
      paipanData: jsonEncode({'daLiuRen': dlr.toJson()}),
      caseType: CaseType.daliuren,
    ));

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider.value(value: cases),
          ChangeNotifierProvider(create: (_) => SettingsProvider()..init()),
          ChangeNotifierProvider(create: (_) => UserProvider()..init()),
        ],
        child: const MaterialApp(home: CasePage()),
      ),
    );
    await tester.pumpAndSettle();

    // 列表应展示两条
    expect(find.textContaining('小六壬'), findsWidgets);
    expect(find.textContaining('大六壬'), findsWidgets);

    // 打开小六壬详情（点标题，命中卡片 InkWell）
    await tester.tap(find.textContaining('小六壬 ·').first);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: '小六壬详情不应抛异常');
    // 详情应展示结构化摘要，而不是兜底「排盘数据较早」文案
    expect(find.textContaining('小六壬排盘'), findsWidgets,
        reason: '应显示小六壬排盘摘要');
    expect(find.textContaining('排盘数据较早'), findsNothing,
        reason: '不应走兜底文案');
    // 关闭详情（点右上角关闭按钮）
    final closeBtn = find.byIcon(Icons.close);
    expect(closeBtn, findsWidgets, reason: '详情应有关闭按钮');
    await tester.tap(closeBtn.first);
    await tester.pumpAndSettle();
    expect(find.textContaining('小六壬排盘'), findsNothing,
        reason: '关闭后详情应消失');

    // 打开大六壬详情（点标题，命中卡片 InkWell）
    await tester.tap(find.textContaining('大六壬 ·').first);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: '大六壬详情不应抛异常');
    expect(find.textContaining('大六壬排盘'), findsWidgets,
        reason: '应显示大六壬排盘摘要');
    expect(find.textContaining('排盘数据较早'), findsNothing);
  });
}
