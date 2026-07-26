import 'package:flutter/foundation.dart';
import '../models/paipan_result.dart';

/// 排盘状态管理 — 六爻与梅花独立存储
class PaipanProvider extends ChangeNotifier {
  PaipanResult? _liuyaoResult;
  PaipanResult? _meihuaResult;

  PaipanResult? get liuyaoResult => _liuyaoResult;
  PaipanResult? get meihuaResult => _meihuaResult;

  /// 六爻起卦
  void setLiuyaoResult(PaipanResult result) {
    _liuyaoResult = result;
    notifyListeners();
  }

  /// 梅花起卦
  void setMeihuaResult(PaipanResult result) {
    _meihuaResult = result;
    notifyListeners();
  }

  /// 清除全部
  void clearAll() {
    _liuyaoResult = null;
    _meihuaResult = null;
    notifyListeners();
  }

  /// 仅清除六爻
  void clearLiuyao() {
    _liuyaoResult = null;
    notifyListeners();
  }

  /// 仅清除梅花
  void clearMeihua() {
    _meihuaResult = null;
    notifyListeners();
  }
}
