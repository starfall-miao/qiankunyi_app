import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/utils/logger.dart';
import '../models/case_models.dart';

/// 卦例管理 Provider — 支持 shared_preferences 持久化
class CaseProvider extends ChangeNotifier {
  List<CaseModel> _cases = [];
  bool _isLoading = false;
  String _searchQuery = '';

  List<CaseModel> get cases {
    if (_searchQuery.isEmpty) return List.unmodifiable(_cases);
    return _cases.where((c) =>
      c.title.contains(_searchQuery) ||
      c.guaName.contains(_searchQuery) ||
      (c.notes?.contains(_searchQuery) ?? false) ||
      c.tags.any((t) => t.contains(_searchQuery))
    ).toList();
  }

  List<CaseModel> get allCases => List.unmodifiable(_cases);
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  int get count => _cases.length;

  static const _storageKey = 'qiankunyi_cases';

  void setSearchQuery(String q) {
    _searchQuery = q;
    notifyListeners();
  }

  /// 初始化——从 shared_preferences 加载
  Future<void> loadCases() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw != null && raw.isNotEmpty) {
        final list = jsonDecode(raw) as List;
        _cases = list.map((e) => CaseModel.fromMap(e as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      debugPrint('加载卦例失败: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = jsonEncode(_cases.map((c) => c.toMap()).toList());
      await prefs.setString(_storageKey, raw);
    } catch (e) {
      debugPrint('保存卦例失败: $e');
    }
  }

  /// 添加卦例
  Future<void> addCase(CaseModel caseModel) async {
    _cases.insert(0, caseModel);
    await _persist();
    notifyListeners();
  }

  /// 删除卦例
  Future<void> deleteCase(int id) async {
    _cases.removeWhere((c) => c.id == id);
    await _persist();
    notifyListeners();
  }

  /// 更新卦例（找不到 id 时记录错误日志，不再静默失败）
  Future<void> updateCase(CaseModel updated) async {
    final index = _cases.indexWhere((c) => c.id == updated.id);
    if (index >= 0) {
      _cases[index] = updated;
      await _persist();
      notifyListeners();
    } else {
      Logger.instance.error('CaseProvider', 'updateCase 未找到卦例 id: ${updated.id}');
    }
  }

  /// 更新卦例的 AI 对话历史。
  /// 基于最新 [_cases] 中的对象合并（而非调用方传入的旧对象），
  /// 避免连续两次 updateCase 并发写 SharedPreferences 时互相覆盖丢失消息。
  Future<void> updateAiMessages(int id, List<AiMessage> aiMessages) async {
    final index = _cases.indexWhere((c) => c.id == id);
    if (index >= 0) {
      _cases[index] = _cases[index].copyWith(
        aiMessages: aiMessages,
        updatedAt: DateTime.now(),
      );
      await _persist();
      notifyListeners();
    } else {
      Logger.instance.error('CaseProvider', 'updateAiMessages 未找到卦例 id: $id');
    }
  }
}
