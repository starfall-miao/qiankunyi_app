import 'package:flutter/material.dart';
import '../models/reference_models.dart';

/// 查阅 - 知识库状态管理
class ReferenceProvider extends ChangeNotifier {
  final List<ReferenceEntry> _entries = [];
  List<ReferenceEntry> get entries => List.unmodifiable(_entries);

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  void search(String query) {
    _searchQuery = query;
    notifyListeners();
  }
}
