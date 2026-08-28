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

  static QueryExecutor _openConnection() {
    return LazyDatabase(() async {
      final dir = await getApplicationDocumentsDirectory();
      await Directory(dir.path).create(recursive: true);
      final file = File(p.join(dir.path, AppConstants.databaseName));
      return NativeDatabase(file);
    });
  }
}
