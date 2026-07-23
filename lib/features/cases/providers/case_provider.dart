import 'package:flutter/foundation.dart';
import '../models/case_models.dart';

/// 卦例管理 Provider
class CaseProvider extends ChangeNotifier {
  List<CaseModel> _cases = [];
  bool _isLoading = false;
  String _searchQuery = '';

  List<CaseModel> get cases {
    if (_searchQuery.isEmpty) return List.unmodifiable(_cases);
    return _cases.where((c) =>
      c.title.contains(_searchQuery) ||
      c.guaName.contains(_searchQuery) ||
      (c.notes?.contains(_searchQuery) ?? false)
    ).toList();
  }

  List<CaseModel> get allCases => List.unmodifiable(_cases);
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  int get count => _cases.length;

  void setSearchQuery(String q) {
    _searchQuery = q;
    notifyListeners();
  }

  /// 添加卦例
  void addCase(CaseModel caseModel) {
    _cases.insert(0, caseModel);
    notifyListeners();
  }

  /// 删除卦例
  void deleteCase(int id) {
    _cases.removeWhere((c) => c.id == id);
    notifyListeners();
  }

  /// 更新卦例
  void updateCase(CaseModel updated) {
    final index = _cases.indexWhere((c) => c.id == updated.id);
    if (index >= 0) {
      _cases[index] = updated;
      notifyListeners();
    }
  }

  /// 加载示例数据（后续接入SQLite后替换）
  void loadDemoData() {
    if (_cases.isNotEmpty) return;
    _isLoading = true;
    notifyListeners();

    // 演示数据
    _cases = [
      CaseModel(
        id: 1, title: '今日占卜-事业', guaName: '乾为天',
        guaGong: '乾宫', method: '手动摇卦',
        paipanData: '{}', notes: '问事业前景',
        tags: ['事业'], createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      CaseModel(
        id: 2, title: '感情卦例', guaName: '火风鼎',
        guaGong: '离宫', method: '时间起卦',
        paipanData: '{}', notes: '问感情发展',
        tags: ['感情'], createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];

    _isLoading = false;
    notifyListeners();
  }
}
