import 'dart:io';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../utils/constants.dart';

/// 乾坤易 - 数据库管理器
///
/// 使用 drift (原 moor) 作为数据库框架。
/// 数据表定义后续通过 drift 的 @DataClass / @Table 注解添加。
/// 运行 `flutter pub run build_runner build` 生成代码后，
/// 可改用继承 _$AppDatabase 的方式使用自动生成的 DAO。
class AppDatabase {
  NativeDatabase? _database;

  AppDatabase._();

  static final AppDatabase _instance = AppDatabase._();
  factory AppDatabase() => _instance;

  /// 获取数据库实例（懒加载）
  Future<NativeDatabase> get database async {
    if (_database != null) return _database!;
    _database = await _openConnection();
    return _database!;
  }

  Future<NativeDatabase> _openConnection() async {
    final dir = await getApplicationDocumentsDirectory();
    await Directory(dir.path).create(recursive: true);
    final file = File(p.join(dir.path, AppConstants.databaseName));
    return NativeDatabase(file);
  }

  /// 关闭数据库连接
  Future<void> close() async {
    await _database?.close();
    _database = null;
  }
}
