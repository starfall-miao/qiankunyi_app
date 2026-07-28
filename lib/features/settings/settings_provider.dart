// 落·乾坤 - 设置持久化与状态管理
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/utils/logger.dart';

/// 排盘显示要素开关
class DisplaySettings {
  bool showTianGan;
  bool showNaYin;
  bool showShenSha;
  bool showLiuShen;
  bool showWangShuai;
  bool showShiYing;
  bool showXingChong;
  bool showFanGua;

  DisplaySettings({
    this.showTianGan = true,
    this.showNaYin = true,
    this.showShenSha = true,
    this.showLiuShen = true,
    this.showWangShuai = false,
    this.showShiYing = true,
    this.showXingChong = true,
    this.showFanGua = false,
  });

  Map<String, dynamic> toMap() => {
    'showTianGan': showTianGan,
    'showNaYin': showNaYin,
    'showShenSha': showShenSha,
    'showLiuShen': showLiuShen,
    'showWangShuai': showWangShuai,
    'showShiYing': showShiYing,
    'showXingChong': showXingChong,
    'showFanGua': showFanGua,
  };

  factory DisplaySettings.fromMap(Map<String, dynamic> m) => DisplaySettings(
    showTianGan: m['showTianGan'] as bool? ?? true,
    showNaYin: m['showNaYin'] as bool? ?? true,
    showShenSha: m['showShenSha'] as bool? ?? true,
    showLiuShen: m['showLiuShen'] as bool? ?? true,
    showWangShuai: m['showWangShuai'] as bool? ?? false,
    showShiYing: m['showShiYing'] as bool? ?? true,
    showXingChong: m['showXingChong'] as bool? ?? true,
    showFanGua: m['showFanGua'] as bool? ?? false,
  );
}

/// 日破暗动规则
enum RiPoAnDongRule {
  wangShuai('旺衰'),
  youQing('有情'),
  jieDong('皆动');

  final String label;
  const RiPoAnDongRule(this.label);
}

/// 全局设置 Provider — 持久化存储
class SettingsProvider extends ChangeNotifier {
  double _fontSize = 16;
  RiPoAnDongRule _riPoRule = RiPoAnDongRule.youQing;
  bool _wanZiShi = false;
  bool _chenMuTuYao = false;
  DisplaySettings _display = DisplaySettings();
  bool _loaded = false;
  SharedPreferences? _prefs;

  // ===== AI 解卦配置 =====
  String _aiEndpoint = 'https://opencode.ai/zen/v1';
  String _aiApiKey = 'sk-ztLkRc1oZQ1KMEUoUVFyO0dcYF3tk4qea7saKXFPvKyhAwcVfa4NNKlNzPujPD2j';
  String _aiModel = 'deepseek-v4-flash-free';
  String _aiCustomModel = '';
  bool _aiEnabled = false;

  // Getters
  double get fontSize => _fontSize;
  RiPoAnDongRule get riPoRule => _riPoRule;
  bool get wanZiShi => _wanZiShi;
  bool get chenMuTuYao => _chenMuTuYao;
  DisplaySettings get display => _display;
  bool get loaded => _loaded;
  // AI Getters
  String get aiEndpoint => _aiEndpoint;
  String get aiApiKey => _aiApiKey;
  String get aiModel => _aiModel;
  bool get aiEnabled => _aiEnabled;
  String get aiCustomModel => _aiCustomModel;

  /// 实际使用的模型名：自定义优先
  String get effectiveAiModel => _aiCustomModel.isNotEmpty ? _aiCustomModel : _aiModel;

  /// 初始化 — 从 SharedPreferences 加载
  Future<void> init() async {
    if (_loaded) return;
    _prefs = await SharedPreferences.getInstance();
    _fontSize = _prefs!.getDouble('paipan_fontSize') ?? 16;
    _riPoRule = RiPoAnDongRule.values[_prefs!.getInt('paipan_riPoRule') ?? 1];
    _wanZiShi = _prefs!.getBool('paipan_wanZiShi') ?? false;
    _chenMuTuYao = _prefs!.getBool('paipan_chenMuTuYao') ?? false;
    _aiEndpoint = _prefs!.getString('ai_endpoint') ?? 'https://opencode.ai/zen/v1';
    _aiApiKey = _prefs!.getString('ai_apiKey') ?? 'sk-ztLkRc1oZQ1KMEUoUVFyO0dcYF3tk4qea7saKXFPvKyhAwcVfa4NNKlNzPujPD2j';
    _aiModel = _prefs!.getString('ai_model') ?? 'deepseek-v4-flash-free';
    _aiCustomModel = _prefs!.getString('ai_custom_model') ?? '';
    _aiEnabled = _prefs!.getBool('ai_enabled') ?? false;
    final ds = _prefs!.getString('paipan_display');
    if (ds != null) {
      _display = DisplaySettings.fromMap(
          Map.fromEntries(ds.split('&').map((e) {
            final p = e.split('=');
            return MapEntry<String, dynamic>(p[0], p[1] == 'true');
          })));
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> _save() async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.setDouble('paipan_fontSize', _fontSize);
    await _prefs!.setInt('paipan_riPoRule', _riPoRule.index);
    await _prefs!.setBool('paipan_wanZiShi', _wanZiShi);
    await _prefs!.setBool('paipan_chenMuTuYao', _chenMuTuYao);
    await _prefs!.setString('paipan_display',
        _display.toMap().entries.map((e) => '${e.key}=${e.value}').join('&'));
  }

  // Setters with persistence
  set fontSize(double v) {
    _fontSize = v;
    _save();
    notifyListeners();
    Logger.instance.info('字体大小: ${v.toInt()}px');
  }
  set riPoRule(RiPoAnDongRule v) {
    _riPoRule = v;
    _save();
    notifyListeners();
    Logger.instance.info('日破暗动规则: ${v.label}');
  }
  set wanZiShi(bool v) {
    _wanZiShi = v;
    _save();
    notifyListeners();
    Logger.instance.info('晚子时: ${v ? "开启" : "关闭"}');
  }
  set chenMuTuYao(bool v) {
    _chenMuTuYao = v;
    _save();
    notifyListeners();
    Logger.instance.info('辰沐土爻: ${v ? "开启" : "关闭"}');
  }
  set display(DisplaySettings v) {
    _display = v;
    _save();
    notifyListeners();
    Logger.instance.info('显示要素已更新');
  }

  void toggleDisplay(String key) {
    final m = _display.toMap()..update(key, (v) => !(v as bool));
    _display = DisplaySettings.fromMap(m);
    _save();
    notifyListeners();
    Logger.instance.info('切换显示要素: $key = ${_display.toMap()[key]}');
  }

  // ===== AI 解卦设置 =====
  set aiEndpoint(String v) {
    _aiEndpoint = v;
    _prefs?.setString('ai_endpoint', v);
    notifyListeners();
  }
  set aiApiKey(String v) {
    _aiApiKey = v;
    _prefs?.setString('ai_apiKey', v);
    notifyListeners();
  }
  set aiModel(String v) {
    _aiModel = v;
    _prefs?.setString('ai_model', v);
    notifyListeners();
  }
  set aiCustomModel(String v) {
    _aiCustomModel = v;
    _prefs?.setString('ai_custom_model', v);
    notifyListeners();
  }
  set aiEnabled(bool v) {
    _aiEnabled = v;
    _prefs?.setBool('ai_enabled', v);
    notifyListeners();
    Logger.instance.info('AI 解卦: ${v ? "开启" : "关闭"}');
  }
}
