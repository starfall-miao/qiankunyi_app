// 落·乾坤 - 用户画像状态管理（多用户、本地保存、密码保护）
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/utils/logger.dart';
import '../../paipan/providers/bazi_provider.dart';
import '../models/user_profile.dart';

/// 用户画像 Provider：多用户独立记录，本地保存，可设密码
class UserProvider extends ChangeNotifier {
  List<UserProfile> _users = [];
  UserProfile? _current;
  bool _initialized = false;
  SharedPreferences? _prefs;
  /// 当前会话是否已通过密码验证（防止切换后未验证直接使用）
  bool _unlocked = false;

  List<UserProfile> get users => _users;
  UserProfile? get current => _current;
  bool get initialized => _initialized;
  bool get unlocked => _unlocked;

  /// 当前用户画像摘要（供 AI 解卦注入）
  String get aiPicContext {
    final u = _current;
    if (u == null || !u.aiReferenceEnabled) return '';
    final buf = <String>[
      '画像用户：${u.nickname}',
      if (u.hasBazi && u.baziSummary.isNotEmpty) '八字画像：${u.baziSummary}',
      if (u.notes.isNotEmpty) '画像备注：${u.notes}',
    ];
    return buf.join('\n');
  }

  Future<void> init() async {
    if (_initialized) return;
    _prefs = await SharedPreferences.getInstance();
    final raw = _prefs!.getString('user_profiles');
    if (raw != null && raw.isNotEmpty) {
      try {
        final list = jsonDecode(raw) as List;
        _users = list
            .map((e) => UserProfile.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (e) {
        Logger.instance.warn('用户画像', '解析失败: $e');
      }
    }
    final curId = _prefs!.getString('current_user_id');
    if (curId != null) {
      for (final u in _users) {
        if (u.id == curId) {
          _current = u;
          break;
        }
      }
    }
    _initialized = true;
    notifyListeners();
  }

  void _persist() {
    _prefs?.setString(
        'user_profiles', jsonEncode(_users.map((u) => u.toJson()).toList()));
    _prefs?.setString('current_user_id', _current?.id ?? '');
  }

  // ── 用户管理 ──

  /// 添加用户；[password] 非空则设置密码
  UserProfile addUser(String nickname, {String? password}) {
    final u = UserProfile(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      nickname: nickname,
      passwordHash: password != null && password.isNotEmpty
          ? _hash(password)
          : null,
      aiReferenceEnabled: true,
      createdAt: DateTime.now(),
    );
    _users.add(u);
    _current = u;
    _unlocked = true;
    _persist();
    notifyListeners();
    Logger.instance.info('用户画像', '新增用户: $nickname');
    return u;
  }

  /// 密码验证；无密码用户直接通过
  bool unlock(String? password) {
    final u = _current;
    if (u == null) return false;
    if (u.passwordHash == null) {
      _unlocked = true;
      return true;
    }
    if (_hash(password ?? '') == u.passwordHash) {
      _unlocked = true;
      return true;
    }
    return false;
  }

  /// 锁定当前用户（App 重启/切后台时由调用方触发）
  void lock() => _unlocked = false;

  /// 切换用户：若有密码需先 unlock
  bool selectUser(String id) {
    for (final u in _users) {
      if (u.id == id) {
        _current = u;
        _unlocked = u.passwordHash == null;
        _persist();
        notifyListeners();
        return true;
      }
    }
    return false;
  }

  /// 修改密码；[oldPassword] 校验旧密码
  bool changePassword(String oldPassword, String newPassword) {
    final u = _current;
    if (u == null) return false;
    if (u.passwordHash != null && _hash(oldPassword) != u.passwordHash) {
      return false;
    }
    u.passwordHash = newPassword.isEmpty ? null : _hash(newPassword);
    _persist();
    notifyListeners();
    return true;
  }

  /// 更新用户（资料/画像）
  void updateUser(UserProfile updated) {
    final i = _users.indexWhere((u) => u.id == updated.id);
    if (i < 0) return;
    _users[i] = updated;
    if (_current?.id == updated.id) _current = updated;
    _persist();
    notifyListeners();
  }

  /// 删除用户
  void removeUser(String id) {
    _users.removeWhere((u) => u.id == id);
    if (_current?.id == id) {
      _current = _users.isNotEmpty ? _users.first : null;
      _unlocked = true;
    }
    _persist();
    notifyListeners();
  }

  /// 根据出生信息计算八字画像摘要并更新到当前用户
  Future<void> updateBaziFromBirth({
    required DateTime birth,
    required bool isMale,
    required int hourIndex,
    bool submit = true,
  }) async {
    final u = _current;
    if (u == null) return;
    if (!submit) {
      // 不提交八字：清空画像数据
      updateUser(u.copyWith(
        hasBazi: false,
        birth: null,
        baziSummary: '',
        hourIndex: null,
        isMale: true,
      ));
      return;
    }
    String summary = '';
    try {
      // 调用八字引擎计算四柱，生成画像摘要
      final bp = BaziProvider();
      await bp.calc(birth: birth, isMale: isMale, hourIndex: hourIndex);
      final r = bp.result;
      if (r == null) throw StateError('排盘结果为空');
      final dayGan = r.dayZhu.tianGan;
      // 日主五行
      const ganWx = {
        '甲': '木', '乙': '木', '丙': '火', '丁': '火', '戊': '土',
        '己': '土', '庚': '金', '辛': '金', '壬': '水', '癸': '水',
      };
      final wx = ganWx[dayGan] ?? '土';
      // 五行统计（天干地支散字）
      final counts = {for (final k in ['木', '火', '土', '金', '水']) k: 0};
      final zhuGZ = [
        r.yearZhu.ganZhi, r.monthZhu.ganZhi, r.dayZhu.ganZhi, r.hourZhu.ganZhi
      ];
      for (final gz in zhuGZ) {
        for (final ch in gz.split('')) {
          final w = ganWx[ch];
          if (w != null) counts[w] = counts[w]! + 1;
        }
      }
      final countsStr = counts.entries
          .where((e) => e.value > 0)
          .map((e) => '${e.key}${e.value}')
          .join('、');
      summary = '日主${dayGan}（属$wx）；五行分布：${countsStr.isEmpty ? "均衡" : countsStr}；'
          '四柱${r.yearZhu.ganZhi} ${r.monthZhu.ganZhi} ${r.dayZhu.ganZhi} ${r.hourZhu.ganZhi}';
    } catch (e) {
      Logger.instance.warn('用户画像', '八字计算失败: $e');
      summary = '八字数据计算失败（已选择提交）';
    }
    updateUser(u.copyWith(
      hasBazi: true,
      birth: birth,
      isMale: isMale,
      hourIndex: hourIndex,
      baziSummary: summary,
    ));
  }

  /// 本地简单散列（非加密用途，仅防明文/误看）
  String _hash(String s) {
    var h = 0x811c9dc5;
    for (final code in s.codeUnits) {
      h ^= code;
      h = (h * 0x01000193) & 0xFFFFFFFF;
    }
    return h.toRadixString(16);
  }
}