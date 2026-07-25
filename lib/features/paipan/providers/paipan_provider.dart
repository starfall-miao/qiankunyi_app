import 'package:flutter/foundation.dart';
import '../models/paipan_result.dart';

/// 排盘状态管理
class PaipanProvider extends ChangeNotifier {
  PaipanResult? _currentResult;
  String _lastMethod = ''; // 'liuyao' | 'meihua'

  PaipanResult? get currentResult => _currentResult;
  String get lastMethod => _lastMethod;

  /// 执行排盘
  void setResult(PaipanResult result, {String method = ''}) {
    _currentResult = result;
    _lastMethod = method;
    notifyListeners();
  }

  /// 清除当前结果
  void clearResult() {
    _currentResult = null;
    _lastMethod = '';
    notifyListeners();
  }
}
