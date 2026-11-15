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
import 'package:qiankunyi_app/features/paipan/engines/xiaoliuren_engine.dart';
import 'package:qiankunyi_app/features/settings/settings_provider.dart';
import 'package:qiankunyi_app/features/users/providers/user_provider.dart';

String _enc(Map<String, dynamic> m) =>
    m.entries.map((e) => '"${e.key}":${_json(e.value)}').join(',');
String _json(dynamic v) {
  if (v == null) return 'null';
  if (v is num || v is bool) return '$v';
  if (v is String) return '"$v"';
  if (v is List) return '[${v.map(_json).join(',')}]';
  if (v is Map) return '{${_enc(v.cast<String, dynamic>())}}';
  return '"$v"';
}

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
      paipanData: '{"xiaoLiuRen":${_enc(xlr.toJson())}}',
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
      paipanData: '{"daLiuRen":${_enc(dlr.toJson())}}',
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

    // 打开小六壬详情
    await tester.tap(find.textContaining('小六壬').first);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: '小六壬详情不应抛异常');
    // 关闭详情（点击关闭按钮）
    final closeBtn = find.byIcon(Icons.close);
    if (closeBtn.evaluate().isNotEmpty) {
      await tester.tap(closeBtn.first);
      await tester.pumpAndSettle();
    }

    // 打开大六壬详情
    await tester.tap(find.textContaining('大六壬').first);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: '大六壬详情不应抛异常');
  });
}
