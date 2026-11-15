/// 数据库列名迁移测试
///
/// 回归：drift 2.35 生成的列名为下划线风格（gua_name/created_at），而历史库
/// 由旧版 drift 建为驼峰列（guaName/createdAt）。若不做迁移，裸 SQL 会出现
/// 「新建库写不进去 / 旧库碰巧能写」。此处模拟旧库验证 beforeOpen 的重命名。
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:drift/native.dart';

import 'package:qiankunyi_app/core/database/app_database.dart';
import 'package:qiankunyi_app/features/cases/models/case_models.dart';
import 'package:qiankunyi_app/features/cases/providers/case_provider.dart';

const _legacyDdl = '''
CREATE TABLE case_table (
  id INTEGER NOT NULL PRIMARY KEY,
  title TEXT NOT NULL,
  guaName TEXT NOT NULL,
  guaGong TEXT NOT NULL,
  method TEXT NOT NULL,
  paipanData TEXT NOT NULL,
  notes TEXT,
  duanYu TEXT,
  askObject TEXT,
  askEvent TEXT,
  tags TEXT NOT NULL,
  aiMessages TEXT NOT NULL,
  caseType TEXT NOT NULL,
  createdAt TEXT NOT NULL,
  updatedAt TEXT NOT NULL
)
''';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('旧版驼峰列数据库：打开后自动重命名并可正常读取/写入', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory(setup: (raw) {
      raw.execute(_legacyDdl);
      raw.execute(
          "INSERT INTO case_table VALUES (1,'旧卦例','大安','木','小六壬','{}',"
          "NULL,NULL,NULL,NULL,'[]','[]','xiaoliuren',"
          "'2024-01-01T00:00:00.000','2024-01-01T00:00:00.000')");
      // 标记为已建版本，避免 drift 走 onCreate
      raw.execute('PRAGMA user_version = 1');
    }));

    final provider = CaseProvider()..attachDatabase(db);
    await provider.loadCases();

    expect(provider.allCases.length, 1, reason: '旧库应能读出 1 条');
    expect(provider.allCases.first.title, '旧卦例');
    expect(provider.allCases.first.caseType, CaseType.xiaoliuren,
        reason: 'caseType 列迁移后应可读');

    // 迁移后新写入应成功（下划线列）
    await provider.addCase(CaseModel(
      id: 2,
      title: '新卦例',
      guaName: '大六壬',
      guaGong: '午',
      method: '大六壬（月将加时）',
      paipanData: '{}',
      caseType: CaseType.daliuren,
    ));
    expect(provider.allCases.length, 2);

    // 重新加载仍为 2 条
    await provider.loadCases();
    expect(provider.allCases.length, 2);
  });
}
