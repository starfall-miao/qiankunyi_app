// 落·乾坤 - 设置持久化与状态管理
import 'dart:convert';

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

  DisplaySettings({
    this.showTianGan = true,
    this.showNaYin = true,
    this.showShenSha = true,
    this.showLiuShen = true,
    this.showWangShuai = false,
    this.showShiYing = true,
    this.showXingChong = true,
  });

  Map<String, dynamic> toMap() => {
    'showTianGan': showTianGan,
    'showNaYin': showNaYin,
    'showShenSha': showShenSha,
    'showLiuShen': showLiuShen,
    'showWangShuai': showWangShuai,
    'showShiYing': showShiYing,
    'showXingChong': showXingChong,
  };

  factory DisplaySettings.fromMap(Map<String, dynamic> m) => DisplaySettings(
    showTianGan: m['showTianGan'] as bool? ?? true,
    showNaYin: m['showNaYin'] as bool? ?? true,
    showShenSha: m['showShenSha'] as bool? ?? true,
    showLiuShen: m['showLiuShen'] as bool? ?? true,
    showWangShuai: m['showWangShuai'] as bool? ?? false,
    showShiYing: m['showShiYing'] as bool? ?? true,
    showXingChong: m['showXingChong'] as bool? ?? true,
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

/// AI 提供商（内置预设与用户自定义共用同一模型）
class AiProviderPreset {
  final String name;
  final String endpoint;
  final String apiKey;
  final String model;
  /// 该提供商推荐/可选的模型列表（模型选择弹窗展示）
  final List<String> models;
  /// 是否为"免费无需配置"预设（内置密钥已清空，仅标记免费）
  final bool free;
  /// 是否内置预设（内置不可删除）
  final bool builtin;

  const AiProviderPreset({
    required this.name,
    required this.endpoint,
    required this.apiKey,
    required this.model,
    this.models = const [],
    this.free = false,
    this.builtin = false,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'endpoint': endpoint,
    'apiKey': apiKey,
    'model': model,
    'models': models,
  };

  factory AiProviderPreset.fromJson(Map<String, dynamic> j) => AiProviderPreset(
    name: j['name'] as String? ?? '',
    endpoint: j['endpoint'] as String? ?? '',
    apiKey: j['apiKey'] as String? ?? '',
    model: j['model'] as String? ?? '',
    models: (j['models'] as List?)?.cast<String>() ?? [],
  );
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
  /// 内置提供商预设（密钥均清空，用户需自行填入；可自由增删模型，内置不可删除）
  static const List<AiProviderPreset> aiPresets = [
    AiProviderPreset(
      name: '智谱 GLM（免费）',
      endpoint: 'https://open.bigmodel.cn/api/paas/v4',
      apiKey: 'ef579420dcdd49ae968b5358debf106a.qJjYax55VQNmF9cb',
      model: 'glm-4.7-flash',
      models: ['glm-4.7-flash', 'glm-4.7', 'glm-5'],
      free: true,
      builtin: true,
    ),
    AiProviderPreset(
      name: 'opencode zen（免费）',
      endpoint: 'https://opencode.ai/zen/v1',
      apiKey: '',
      model: 'mimo-v2.5-free',
      models: ['mimo-v2.5-free', 'north-mini-code-free', 'nemotron-3-ultra-free', 'big-pickle'],
      free: true,
      builtin: true,
    ),
  ];

  String _aiEndpoint = aiPresets[0].endpoint;
  String _aiApiKey = aiPresets[0].apiKey;
  String _aiModel = aiPresets[0].model;
  String _aiCustomModel = '';
  /// 自定义 AI 系统提示词（留空使用内置模板）
  String _aiSystemPrompt = '';
  bool _aiEnabled = false;
  int _aiPresetIndex = 0; // 当前选中的提供商在 aiProviders 中的索引，-1 表示自定义

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
  String get aiSystemPrompt => _aiSystemPrompt;
  int get aiPresetIndex => _aiPresetIndex;

  /// 自定义提供商列表（持久化，用户可增删）
  final List<AiProviderPreset> _customProviders = [];
  List<AiProviderPreset> get customProviders =>
      List.unmodifiable(_customProviders);

  /// 全部可选提供商 = 内置预设 + 自定义
  List<AiProviderPreset> get aiProviders => [...aiPresets, ..._customProviders];

  /// 当前使用的提供商名称
  String get aiProviderName {
    final p = currentProvider;
    return p != null ? p.name : '自定义';
  }

  /// 当前选中的提供商（无则 null → 自定义直接改字段）
  AiProviderPreset? get currentProvider {
    final list = aiProviders;
    if (_aiPresetIndex >= 0 && _aiPresetIndex < list.length) {
      return list[_aiPresetIndex];
    }
    return null;
  }

  /// 是否选中免费标记提供商（仅用于 UI 展示"免费"标签，不再锁编辑）
  bool get isFreeProvider => currentProvider?.free ?? false;

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
    // 加载自定义提供商
    final rawProviders = _prefs!.getString('ai_custom_providers');
    if (rawProviders != null && rawProviders.isNotEmpty) {
      try {
        final list = (jsonDecode(rawProviders) as List)
            .map((e) => AiProviderPreset.fromJson(e as Map<String, dynamic>))
            .toList();
        _customProviders
          ..clear()
          ..addAll(list);
      } catch (_) {
        // 损坏的 JSON 忽略，不阻塞启动
      }
    }
    _aiEndpoint = _prefs!.getString('ai_endpoint') ?? aiProviders.first.endpoint;
    _aiApiKey = _prefs!.getString('ai_apiKey') ?? aiProviders.first.apiKey;
    _aiModel = _prefs!.getString('ai_model') ?? aiProviders.first.model;
    _aiCustomModel = _prefs!.getString('ai_custom_model') ?? '';
    _aiSystemPrompt = _prefs!.getString('ai_system_prompt') ?? '';
    _aiPresetIndex = _prefs!.getInt('ai_preset_index') ?? 0;
    // 迁移：旧的 opencode 预设名 → 新 zen（deepseek-v4-flash-free 已失效）
    if (_aiModel == 'deepseek-v4-flash-free') {
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
  /// 切换提供商（内置 + 自定义统一索引）
  void selectAiPreset(int index) {
    final list = aiProviders;
    if (index < 0 || index >= list.length) return;
    _aiPresetIndex = index;
    _aiEndpoint = list[index].endpoint;
    _aiApiKey = list[index].apiKey;
    _aiModel = list[index].model;
    _aiCustomModel = '';
    _prefs?.setInt('ai_preset_index', index);
    _prefs?.setString('ai_endpoint', _aiEndpoint);
    _prefs?.setString('ai_apiKey', _aiApiKey);
    _prefs?.setString('ai_model', _aiModel);
    _prefs?.setString('ai_custom_model', '');
    notifyListeners();
    Logger.instance.info('AI提供商', list[index].name);
  }

  /// 添加自定义提供商（可含模型列表）
  void addCustomProvider(AiProviderPreset provider) {
    _customProviders.add(provider);
    _persistCustomProviders();
    selectAiPreset(aiPresets.length + _customProviders.length - 1);
    Logger.instance.info('AI提供商已添加', provider.name);
  }

  /// 更新自定义提供商（下标为 aiProviders 中的索引）
  void updateCustomProvider(int index, AiProviderPreset updated) {
    final customIndex = index - aiPresets.length;
    if (customIndex < 0 || customIndex >= _customProviders.length) return;
    _customProviders[customIndex] = updated;
    _persistCustomProviders();
    // 若是当前选中的提供商，同步当前字段
    if (_aiPresetIndex == index) {
      _aiEndpoint = updated.endpoint;
      _aiApiKey = updated.apiKey;
      _aiModel = updated.model;
    }
    notifyListeners();
    Logger.instance.info('AI提供商已更新', updated.name);
  }

  /// 删除自定义提供商（内置不可删）
  void removeCustomProvider(int index) {
    final customIndex = index - aiPresets.length;
    if (customIndex < 0 || customIndex >= _customProviders.length) return;
    _customProviders.removeAt(customIndex);
    _persistCustomProviders();
    if (_aiPresetIndex == index) {
      // 删除的是当前项 → 切回内置第一个
      selectAiPreset(0);
    } else if (_aiPresetIndex > index) {
      _aiPresetIndex--;
      _prefs?.setInt('ai_preset_index', _aiPresetIndex);
    }
    notifyListeners();
    Logger.instance.info('AI提供商已删除');
  }

  void _persistCustomProviders() {
    try {
      _prefs?.setString('ai_custom_providers',
          jsonEncode(_customProviders.map((p) => p.toJson()).toList()));
    } catch (_) {}
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
  set aiSystemPrompt(String v) {
    _aiSystemPrompt = v;
    _prefs?.setString('ai_system_prompt', v);
    notifyListeners();
  }
  set aiEnabled(bool v) {
    _aiEnabled = v;
    _prefs?.setBool('ai_enabled', v);
    notifyListeners();
    Logger.instance.info('AI 解卦: ${v ? "开启" : "关闭"}');
  }
}
