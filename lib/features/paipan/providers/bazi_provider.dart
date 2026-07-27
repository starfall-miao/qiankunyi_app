/// 八字排盘状态管理
library;

import 'package:flutter/foundation.dart';
import '../models/bazi_models.dart';
import '../engines/bazi_engine.dart';

/// 八字 Provider
class BaziProvider extends ChangeNotifier {
  BaziResult? _result;
  DateTime? _birth;
  bool _isMale = true;
  bool _isCalculating = false;

  BaziResult? get result => _result;
  bool get isCalculating => _isCalculating;
  bool get hasResult => _result != null;

  /// 排盘
  Future<void> calc({
    required DateTime birth,
    required bool isMale,
    required int hourIndex,
  }) async {
    _isCalculating = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 100)); // UI 响应
      _birth = birth;
      _isMale = isMale;
      _result = BaiZiEngine.calc(birth: birth, isMale: isMale, hourIndex: hourIndex);
    } catch (e) {
      debugPrint('八字排盘失败: $e');
    }

    _isCalculating = false;
    notifyListeners();
  }

  /// 清空
  void clear() {
    _result = null;
    _birth = null;
    notifyListeners();
  }
}
