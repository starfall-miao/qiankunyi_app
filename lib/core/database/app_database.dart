import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../utils/constants.dart';

part 'app_database.g.dart';

/// 卦例表
class CaseTable extends Table {
  IntColumn get id => integer()();
  TextColumn get title => text()();
  TextColumn get guaName => text()();
  TextColumn get guaGong => text()();
  TextColumn get method => text()();
  TextColumn get paipanData => text()();
  TextColumn get notes => text().nullable()();
  TextColumn get duanYu => text().nullable()();
  TextColumn get askObject => text().nullable()();
  TextColumn get askEvent => text().nullable()();
  TextColumn get tags => text()();          // JSON 数组
  TextColumn get aiMessages => text()();    // JSON 数组
  TextColumn get caseType => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// 乾坤易数据库（Drift）
@DriftDatabase(tables: [CaseTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 1;

  /// 列名兼容：drift 生成的列名为下划线风格（gua_name / created_at …），
  /// 而历史版本（drift 2.23 时代）建的表是驼峰列（guaName / createdAt …）。
  /// 打开数据库时把旧驼峰列统一重命名为下划线，避免"新建库写不进去、
  /// 旧库碰巧能写"的分裂状态。
  static const _legacyColumnRenames = <String, String>{
    'guaName': 'gua_name',
    'guaGong': 'gua_gong',
    'paipanData': 'paipan_data',
    'duanYu': 'duan_yu',
    'askObject': 'ask_object',
    'askEvent': 'ask_event',
    'aiMessages': 'ai_messages',
    'caseType': 'case_type',
    'createdAt': 'created_at',
    'updatedAt': 'updated_at',
  };

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        beforeOpen: (details) async {
          try {
            final info =
                await customSelect('PRAGMA table_info(case_table)').get();
            final cols = info
                .map((r) => r.data['name']?.toString() ?? '')
                .where((e) => e.isNotEmpty)
                .toSet();
            if (cols.isEmpty) return; // 表尚未创建（首次打开由 onCreate 负责）
            for (final e in _legacyColumnRenames.entries) {
              if (cols.contains(e.key) && !cols.contains(e.value)) {
                await customStatement(
                    'ALTER TABLE case_table RENAME COLUMN "${e.key}" TO "${e.value}"');
              }
            }
          } catch (_) {
            // 迁移失败不阻塞启动（后续读写会走兼容读取）
          }
        },
      );

  static QueryExecutor _openConnection() {
    return LazyDatabase(() async {
      final dir = await getApplicationDocumentsDirectory();
      await Directory(dir.path).create(recursive: true);
      final file = File(p.join(dir.path, AppConstants.databaseName));
      return NativeDatabase(file);
    });
  }
}
