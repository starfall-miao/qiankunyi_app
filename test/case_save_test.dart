import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:qiankunyi_app/core/database/app_database.dart';
import 'package:qiankunyi_app/features/cases/models/case_models.dart';
import 'package:qiankunyi_app/features/cases/providers/case_provider.dart';
import 'package:qiankunyi_app/features/paipan/engines/daliuren_engine.dart';
import 'package:qiankunyi_app/features/paipan/engines/xiaoliuren_engine.dart';

String jsonEncodeMap(Map<String, dynamic> m) =>
    m.entries.map((e) => '"${e.key}":${_json(e.value)}').join(',');

String _json(dynamic v) {
  if (v == null) return 'null';
  if (v is num || v is bool) return '$v';
  if (v is String) return '"$v"';
  if (v is List) return '[${v.map(_json).join(',')}]';
  if (v is Map) return '{${jsonEncodeMap(v.cast<String, dynamic>())}}';
  return '"$v"';
}

void main() {
  test('小六壬/大六壬 卦例可写入数据库', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    final provider = CaseProvider()..attachDatabase(db);

    final xlr = XiaoLiuRenEngine.byDateTime(DateTime(2024, 6, 15), 3);
    final xcm = CaseModel(
      id: 1,
      title: '小六壬 · ${xlr.resultPalm.name}',
      guaName: xlr.resultPalm.name,
      guaGong: xlr.resultPalm.element,
      method: '小六壬（${xlr.method}）',
      paipanData: '{"xiaoLiuRen":${jsonEncodeMap(xlr.toJson())}}',
      caseType: CaseType.xiaoliuren,
    );
    await provider.addCase(xcm);

    final dlr = DaLiuRenEngine.byHour(3, 1,
        dayGan: '甲', dayZhi: '子', monthZhiIdx: 2,
        yearGanZhi: '甲辰', monthGanZhi: '丙寅');
    final dcm = CaseModel(
      id: 2,
      title: '大六壬 · ${dlr.chuChuan}传',
      guaName: '大六壬',
      guaGong: dlr.chuChuan,
      method: '大六壬（${dlr.method}）',
      paipanData: '{"daLiuRen":${jsonEncodeMap(dlr.toJson())}}',
      caseType: CaseType.daliuren,
    );
    await provider.addCase(dcm);

    expect(provider.allCases.length, 2);
    // 重新加载（模拟重启）
    await provider.loadCases();
    expect(provider.allCases.length, 2);
    expect(provider.allCases.map((c) => c.caseType).toSet(),
        {CaseType.xiaoliuren, CaseType.daliuren});
  });
}
