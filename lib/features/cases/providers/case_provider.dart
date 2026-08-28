import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:drift/drift.dart' show Value;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/database/app_database.dart';
import '../../../core/utils/logger.dart';
import '../models/case_models.dart';

/// 卦例管理 Provider — 基于 Drift(SQLite) 持久化，并支持旧版 SharedPreferences 数据迁移
class CaseProvider extends ChangeNotifier {
  List<CaseModel> _cases = [];
  bool _isLoading = false;
  String _searchQuery = '';
  AppDatabase? _db;

  List<CaseModel> get cases {
    if (_searchQuery.isEmpty) return List.unmodifiable(_cases);
    return _cases.where((c) =>
      c.title.contains(_searchQuery) ||
      c.guaName.contains(_searchQuery) ||
      (c.notes?.contains(_searchQuery) ?? false) ||
      (c.askEvent?.contains(_searchQuery) ?? false) ||
      c.tags.any((t) => t.contains(_searchQuery))
    ).toList();
  }

  List<CaseModel> get allCases => List.unmodifiable(_cases);
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  int get count => _cases.length;

  /// 旧版 SharedPreferences 存储 key（迁移用）
  static const _legacyKey = 'qiankunyi_cases';
  static const _migratedKey = 'qiankunyi_cases_migrated_v2';

  void setSearchQuery(String q) {
    _searchQuery = q;
    notifyListeners();
  }

  /// 初始化数据库连接（可注入 AppDatabase 便于测试）
  void attachDatabase(AppDatabase db) => _db = db;

  /// 从 SQLite 加载；首次启动若检测到旧 SharedPreferences 数据则迁移
  Future<void> loadCases() async {
    _isLoading = true;
    notifyListeners();
    try {
      _db ??= AppDatabase();
      final prefs = await SharedPreferences.getInstance();

      // 1) 尝试从 SQLite 读取
      final rows = await _db!.select(_db!.caseTable).get();
      if (rows.isNotEmpty) {
        _cases = rows.map((r) => _fromRow(r)).toList();
      } else {
        // 2) 迁移旧数据（仅一次）
        final legacy = prefs.getString(_legacyKey);
        if (legacy != null && legacy.isNotEmpty) {
          final list = jsonDecode(legacy) as List;
          final migrated =
              list.map((e) => CaseModel.fromMap(e as Map<String, dynamic>)).toList();
          for (final c in migrated) {
            await _insertRow(c);
          }
          _cases = migrated;
          await prefs.remove(_legacyKey);
          await prefs.setBool(_migratedKey, true);
          Logger.instance.info('CaseProvider', '已从旧版迁移 ${migrated.length} 条卦例到 SQLite');
        }
      }
    } catch (e, st) {
      debugPrint('加载卦例失败: $e\n$st');
      Logger.instance.error('CaseProvider', '加载失败: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _insertRow(CaseModel c) async {
    await _db!.into(_db!.caseTable).insert(CaseCompanionType.insert(
      id: Value(c.id ?? DateTime.now().millisecondsSinceEpoch),
      title: c.title,
      guaName: c.guaName,
      guaGong: c.guaGong,
      method: c.method,
      paipanData: c.paipanData,
      notes: Value(c.notes),
      duanYu: Value(c.duanYu),
      askObject: Value(c.askObject),
      askEvent: Value(c.askEvent),
      tags: jsonEncode(c.tags),
      aiMessages: jsonEncode(c.aiMessages.map((m) => m.toJson()).toList()),
      caseType: c.caseType.name,
      createdAt: c.createdAt,
      updatedAt: c.updatedAt,
    ));
  }

  /// Drift 行 → CaseModel
  CaseModel _fromRow(CaseRow row) {
    List<String> parseTags(String s) {
      try {
        return (jsonDecode(s) as List).cast<String>();
      } catch (_) {
        return [];
      }
    }

    List<AiMessage> parseMessages(String s) {
      try {
        return (jsonDecode(s) as List)
            .map((e) => AiMessage.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (_) {
        return [];
      }
    }

    return CaseModel(
      id: row.id,
      title: row.title,
      guaName: row.guaName,
      guaGong: row.guaGong,
      method: row.method,
      paipanData: row.paipanData,
      notes: row.notes,
      duanYu: row.duanYu,
      askObject: row.askObject,
      askEvent: row.askEvent,
      tags: parseTags(row.tags),
      aiMessages: parseMessages(row.aiMessages),
      caseType: CaseType.values.firstWhere(
          (e) => e.name == row.caseType, orElse: () => CaseType.liuyao),
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  /// 添加卦例
  Future<void> addCase(CaseModel caseModel) async {
    _cases.insert(0, caseModel);
    try {
      _db ??= AppDatabase();
      await _insertRow(caseModel);
    } catch (e) {
      debugPrint('添加卦例失败: $e');
    }
    notifyListeners();
  }

  /// 删除卦例
  Future<void> deleteCase(int id) async {
    _cases.removeWhere((c) => c.id == id);
    try {
      _db ??= AppDatabase();
      await (_db!.delete(_db!.caseTable)..where((t) => t.id.equals(id))).go();
    } catch (e) {
      debugPrint('删除卦例失败: $e');
    }
    notifyListeners();
  }

  /// 更新卦例（保留最新 AI 对话历史，防止旧快照覆盖）
  Future<void> updateCase(CaseModel updated) async {
    final index = _cases.indexWhere((c) => c.id == updated.id);
    if (index >= 0) {
      final latest = _cases[index];
      final merged = latest.copyWith(
        title: updated.title,
        guaName: updated.guaName,
        guaGong: updated.guaGong,
        method: updated.method,
        paipanData: updated.paipanData,
        notes: updated.notes,
        duanYu: updated.duanYu,
        askObject: updated.askObject,
        askEvent: updated.askEvent,
        tags: updated.tags,
        caseType: updated.caseType,
        aiMessages: updated.aiMessages.isNotEmpty
            ? updated.aiMessages
            : latest.aiMessages,
        updatedAt: DateTime.now(),
      );
      _cases[index] = merged;
      try {
        _db ??= AppDatabase();
        await (_db!.update(_db!.caseTable)
              ..where((t) => t.id.equals(merged.id!)))
            .write(CaseCompanionType(
          title: Value(merged.title),
          guaName: Value(merged.guaName),
          guaGong: Value(merged.guaGong),
          method: Value(merged.method),
          paipanData: Value(merged.paipanData),
          notes: Value(merged.notes),
          duanYu: Value(merged.duanYu),
          askObject: Value(merged.askObject),
          askEvent: Value(merged.askEvent),
          tags: Value(jsonEncode(merged.tags)),
          aiMessages: Value(
              jsonEncode(merged.aiMessages.map((m) => m.toJson()).toList())),
          caseType: Value(merged.caseType.name),
          updatedAt: Value(merged.updatedAt),
        ));
      } catch (e) {
        debugPrint('更新卦例失败: $e');
      }
      notifyListeners();
    } else {
      Logger.instance.error('CaseProvider', 'updateCase 未找到卦例 id: ${updated.id}');
    }
  }

  /// 更新卦例的 AI 对话历史
  Future<void> updateAiMessages(int id, List<AiMessage> aiMessages) async {
    final index = _cases.indexWhere((c) => c.id == id);
    if (index >= 0) {
      _cases[index] = _cases[index].copyWith(
        aiMessages: aiMessages,
        updatedAt: DateTime.now(),
      );
      await updateCase(_cases[index]);
      notifyListeners();
    } else {
      Logger.instance.error('CaseProvider', 'updateAiMessages 未找到卦例 id: $id');
    }
  }
}
