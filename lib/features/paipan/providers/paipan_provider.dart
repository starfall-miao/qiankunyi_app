import 'package:flutter/foundation.dart';
import '../models/paipan_result.dart';

/// 排盘状态管理
class PaipanProvider extends ChangeNotifier {
  PaipanResult? _currentResult;

  PaipanResult? get currentResult => _currentResult;

  /// 执行排盘
  void setResult(PaipanResult result) {
    _currentResult = result;
    notifyListeners();
  }

  /// 清除当前结果
  void clearResult() {
    _currentResult = null;
    notifyListeners();
  }
}
