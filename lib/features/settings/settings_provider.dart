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

/// AI 提供商预设
class AiProviderPreset {
  final String name;
  final String endpoint;
  final String apiKey;
  final String model;
  /// 是否为"免费无需配置"预设（内置密钥，无需用户编辑地址/密钥/模型）
  final bool free;

  const AiProviderPreset({
    required this.name,
    required this.endpoint,
    required this.apiKey,
    required this.model,
    this.free = false,
  });
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
  /// 预设提供商列表
  /// 智谱 GLM-4.7-flash 为优选免费模型（官方接口），置于首位
  static const List<AiProviderPreset> aiPresets = [
    AiProviderPreset(
      name: '智谱 GLM-4.7-flash（免费）',
      endpoint: 'https://open.bigmodel.cn/api/paas/v4',
      apiKey: '',
      model: 'glm-4.7-flash',
      free: true,
    ),
    AiProviderPreset(
      name: 'opencode (deepseek-v4-flash)',
      endpoint: 'https://opencode.ai/zen/v1',
      apiKey: '',
      model: 'deepseek-v4-flash-free',
      free: true,
    ),
    AiProviderPreset(
      name: '阿里云通义千问',
      endpoint: 'https://dashscope.aliyuncs.com/compatible-mode/v1',
      apiKey: '',
      model: 'qwen-turbo',
      free: false,
    ),
  ];

  String _aiEndpoint = aiPresets[0].endpoint;
  String _aiApiKey = aiPresets[0].apiKey;
  String _aiModel = aiPresets[0].model;
  String _aiCustomModel = '';
  bool _aiEnabled = false;
  int _aiPresetIndex = 0; // 当前选中的预设索引，-1 表示自定义

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
  int get aiPresetIndex => _aiPresetIndex;

  /// 当前使用的提供商名称
  String get aiProviderName {
    if (_aiPresetIndex >= 0 && _aiPresetIndex < aiPresets.length) {
      return aiPresets[_aiPresetIndex].name;
    }
    return '自定义';
  }

  /// 当前选中的是否为"免费无需配置"预设（智谱 GLM / opencode，内置密钥，
  /// 地址/密钥/模型编辑锁定）
  bool get isFreeProvider =>
      _aiPresetIndex >= 0 &&
      _aiPresetIndex < aiPresets.length &&
      aiPresets[_aiPresetIndex].free;

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
    _aiEndpoint = _prefs!.getString('ai_endpoint') ?? aiPresets[0].endpoint;
    _aiApiKey = _prefs!.getString('ai_apiKey') ?? aiPresets[0].apiKey;
    _aiModel = _prefs!.getString('ai_model') ?? aiPresets[0].model;
    _aiCustomModel = _prefs!.getString('ai_custom_model') ?? '';
    _aiPresetIndex = _prefs!.getInt('ai_preset_index') ?? 0;
    // 迁移：旧版首选的 opencode（endpoint 含 opencode.ai）→ 新首选智谱 GLM。
    // 仅当用户确实停留在旧默认（之前未自定义）时才切换，只执行一次。
    if (!(_prefs!.getBool('ai_migrated_glm') ?? false)) {
      final oldEndpoint = _prefs!.getString('ai_endpoint') ?? '';
      if (oldEndpoint.contains('opencode.ai')) {
        _aiPresetIndex = 0;
        _aiEndpoint = aiPresets[0].endpoint;
        _aiApiKey = aiPresets[0].apiKey;
        _aiModel = aiPresets[0].model;
        _aiCustomModel = '';
        _prefs!.setInt('ai_preset_index', 0);
        _prefs!.setString('ai_endpoint', _aiEndpoint);
        _prefs!.setString('ai_apiKey', _aiApiKey);
        _prefs!.setString('ai_model', _aiModel);
        _prefs!.setString('ai_custom_model', '');
      }
      _prefs!.setBool('ai_migrated_glm', true);
    }
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
  /// 切换预设提供商
  void selectAiPreset(int index) {
    if (index < 0 || index >= aiPresets.length) return;
    _aiPresetIndex = index;
    _aiEndpoint = aiPresets[index].endpoint;
    _aiApiKey = aiPresets[index].apiKey;
    _aiModel = aiPresets[index].model;
    _aiCustomModel = '';
    _prefs?.setInt('ai_preset_index', index);
    _prefs?.setString('ai_endpoint', _aiEndpoint);
    _prefs?.setString('ai_apiKey', _aiApiKey);
    _prefs?.setString('ai_model', _aiModel);
    _prefs?.setString('ai_custom_model', '');
    notifyListeners();
    Logger.instance.info('AI提供商预设', aiPresets[index].name);
  }
  set aiEndpoint(String v) {
    _aiEndpoint = v;
    _aiPresetIndex = -1;
    _prefs?.setString('ai_endpoint', v);
    _prefs?.setInt('ai_preset_index', -1);
    notifyListeners();
    Logger.instance.info('AI服务地址已更新');
  }
  set aiApiKey(String v) {
    _aiApiKey = v;
    _prefs?.setString('ai_apiKey', v);
    notifyListeners();
    Logger.instance.info('AI API Key 已更新');
  }
  set aiModel(String v) {
    _aiModel = v;
    _prefs?.setString('ai_model', v);
    notifyListeners();
    Logger.instance.info('AI模型已更新', v);
  }
  set aiCustomModel(String v) {
    _aiCustomModel = v;
    _prefs?.setString('ai_custom_model', v);
    notifyListeners();
    Logger.instance.info('AI自定义模型已更新', v);
  }
  set aiEnabled(bool v) {
    _aiEnabled = v;
    _prefs?.setBool('ai_enabled', v);
    notifyListeners();
    Logger.instance.info('AI 解卦: ${v ? "开启" : "关闭"}');
  }
}
