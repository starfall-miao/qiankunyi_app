import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/database/app_database.dart';
import '../../../core/utils/logger.dart';
import '../models/case_models.dart';

/// 卦例管理 Provider — 基于 Drift(SQLite) 持久化（raw SQL），
/// 并支持旧版 SharedPreferences 数据自动迁移。
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
      final rows =
          await _db!.customSelect('SELECT * FROM case_table ORDER BY createdAt DESC').get();
      if (rows.isNotEmpty) {
        _cases = rows.map((r) => _fromRow(r.data)).toList();
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
    await _db!.customStatement(
      'INSERT INTO case_table (id, title, guaName, guaGong, method, paipanData, '
      'notes, duanYu, askObject, askEvent, tags, aiMessages, caseType, createdAt, updatedAt) '
      'VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)',
      [
        c.id ?? DateTime.now().millisecondsSinceEpoch,
        c.title,
        c.guaName,
        c.guaGong,
        c.method,
        c.paipanData,
        c.notes,
        c.duanYu,
        c.askObject,
        c.askEvent,
        jsonEncode(c.tags),
        jsonEncode(c.aiMessages.map((m) => m.toJson()).toList()),
        c.caseType.name,
        c.createdAt.toIso8601String(),
        c.updatedAt.toIso8601String(),
      ],
    );
  }

  /// SQLite 行数据 → CaseModel
  CaseModel _fromRow(Map<String, Object?> d) {
    List<String> parseTags(Object? s) {
      try {
        return (jsonDecode(s as String) as List).cast<String>();
      } catch (_) {
        return [];
      }
    }

    List<AiMessage> parseMessages(Object? s) {
      try {
        return (jsonDecode(s as String) as List)
            .map((e) => AiMessage.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (_) {
        return [];
      }
    }

    DateTime? parseDate(Object? s) {
      if (s == null) return null;
      try {
        return DateTime.parse(s.toString());
      } catch (_) {
        return null;
      }
    }

    return CaseModel(
      id: d['id'] as int?,
      title: d['title']?.toString() ?? '',
      guaName: d['guaName']?.toString() ?? '',
      guaGong: d['guaGong']?.toString() ?? '',
      method: d['method']?.toString() ?? '',
      paipanData: d['paipanData']?.toString() ?? '',
      notes: d['notes']?.toString(),
      duanYu: d['duanYu']?.toString(),
      askObject: d['askObject']?.toString(),
      askEvent: d['askEvent']?.toString(),
      tags: parseTags(d['tags']),
      aiMessages: parseMessages(d['aiMessages']),
      caseType: CaseType.values.firstWhere(
          (e) => e.name == d['caseType']?.toString(),
          orElse: () => CaseType.liuyao),
      createdAt: parseDate(d['createdAt']) ?? DateTime.now(),
      updatedAt: parseDate(d['updatedAt']) ?? DateTime.now(),
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
      await _db!.customStatement('DELETE FROM case_table WHERE id = ?', [id]);
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
        await _db!.customStatement(
          'UPDATE case_table SET title=?, guaName=?, guaGong=?, method=?, '
          'paipanData=?, notes=?, duanYu=?, askObject=?, askEvent=?, tags=?, '
          'aiMessages=?, caseType=?, updatedAt=? WHERE id=?',
          [
            merged.title,
            merged.guaName,
            merged.guaGong,
            merged.method,
            merged.paipanData,
            merged.notes,
            merged.duanYu,
            merged.askObject,
            merged.askEvent,
            jsonEncode(merged.tags),
            jsonEncode(merged.aiMessages.map((m) => m.toJson()).toList()),
            merged.caseType.name,
            merged.updatedAt.toIso8601String(),
            merged.id,
          ],
        );
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
