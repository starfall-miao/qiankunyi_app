import 'dart:convert';
import '../../paipan/models/paipan_result.dart';
import '../../paipan/models/gua_model.dart';
import '../../paipan/models/bazi_models.dart';

/// 起卦方式中文映射
const methodCN = <String, String>{
  'manual': '机器摇卦',
  '手工摇卦': '手工摇卦',
  'time': '时间起卦',
  'number': '数字起卦',
  '数字起卦': '数字起卦',
  '机器摇卦': '机器摇卦',
  '时间起卦': '时间起卦',
};

/// 卦名中文映射
const guaNameCN = <GuaName, String>{
  GuaName.qian: '乾为天', GuaName.kun: '坤为地', GuaName.zhun: '水雷屯',
  GuaName.meng: '山水蒙', GuaName.xu: '水天需', GuaName.song: '天水讼',
  GuaName.shi: '地水师', GuaName.bi: '水地比', GuaName.xiaoXu: '风天小畜',
  GuaName.lv: '天泽履', GuaName.tai: '地天泰', GuaName.pi: '天地否',
  GuaName.tongRen: '天火同人', GuaName.daYou: '火天大有', GuaName.qian2: '地山谦',
  GuaName.yu: '雷地豫', GuaName.sui: '泽雷随', GuaName.gu: '山风蛊',
  GuaName.lin: '地泽临', GuaName.guan: '风地观', GuaName.shiHe: '火雷噬嗑',
  GuaName.bi2: '山火贲', GuaName.bo: '山地剥', GuaName.fu: '地雷复',
  GuaName.wuWang: '天雷无妄', GuaName.daXu: '山天大畜', GuaName.yi: '山雷颐',
  GuaName.daGuo: '泽风大过', GuaName.kan: '坎为水', GuaName.li: '离为火',
  GuaName.xian: '泽山咸', GuaName.heng: '雷风恒', GuaName.dun: '天山遁',
  GuaName.daZhuang: '雷天大壮', GuaName.jin: '火地晋', GuaName.mingYi: '地火明夷',
  GuaName.jiaRen: '风火家人', GuaName.kui: '火泽睽', GuaName.jian: '水山蹇',
  GuaName.jie: '雷水解', GuaName.sun: '山泽损', GuaName.yi2: '风雷益',
  GuaName.guai: '泽天夬', GuaName.gou: '天风姤', GuaName.cui: '泽地萃',
  GuaName.sheng: '地风升', GuaName.kun2: '泽水困', GuaName.jing: '水风井',
  GuaName.ge: '泽火革', GuaName.ding: '火风鼎', GuaName.zhen: '震为雷',
  GuaName.gen: '艮为山', GuaName.jian2: '风山渐', GuaName.guiMei: '雷泽归妹',
  GuaName.feng: '雷火丰', GuaName.lv2: '火山旅', GuaName.xun: '巽为风',
  GuaName.dui: '兑为泽', GuaName.huan: '风水涣', GuaName.jie2: '水泽节',
  GuaName.zhongFu: '风泽中孚', GuaName.xiaoGuo: '雷山小过', GuaName.jiJi: '水火既济',
  GuaName.weiJi: '火水未济',
};

/// 卦宫中文映射
const guaGongCN = <GuaGong, String>{
  GuaGong.qian: '乾', GuaGong.dui: '兑', GuaGong.li: '离',
  GuaGong.zhen: '震', GuaGong.xun: '巽', GuaGong.kan: '坎',
  GuaGong.gen: '艮', GuaGong.kun: '坤',
};

/// 八卦中文名映射
const trigramCN = <int, String>{
  0: '乾', 1: '兑', 2: '离', 3: '震',
  4: '巽', 5: '坎', 6: '艮', 7: '坤',
};

/// 获取中文起卦方式
String methodToCN(String method) => methodCN[method] ?? method;

/// 获取中文卦名
String guaNameToCN(GuaName name) => guaNameCN[name] ?? name.name;

/// AI 对话消息
class AiMessage {
  final String role;     // 'user' | 'assistant' | 'system'
  final String content;  // 消息内容
  final DateTime timestamp;
  /// 是否按纯文本展示（不做 Markdown 渲染）。
  /// 用于"仅推理内容"兜底消息：DeepSeek 推理模型的思考过程包含大量
  /// `#`/`*`/`|` 等 Markdown 语法符号，按 Markdown 渲染会被吃掉部分内容
  /// 导致"显示不全"；纯文本展示可完整保留原文。
  final bool isPlainText;
  /// 思考过程（推理内容）。用户要求"结果出来后思考应该折叠而不是完全删掉"：
  /// 流式完成后把思考过程存入消息，UI 用可展开的折叠区展示完整内容；
  /// 旧数据为 null，不影响渲染。
  final String? thinking;

  AiMessage({
    required this.role,
    required this.content,
    DateTime? timestamp,
    this.isPlainText = false,
    this.thinking,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'role': role,
    'content': content,
    'timestamp': timestamp.toIso8601String(),
    'isPlainText': isPlainText,
    if (thinking != null) 'thinking': thinking,
  };

  factory AiMessage.fromJson(Map<String, dynamic> json) => AiMessage(
    role: json['role'] as String,
    content: json['content'] as String,
    timestamp: DateTime.parse(json['timestamp'] as String),
    isPlainText: json['isPlainText'] as bool? ?? false,
    thinking: json['thinking'] as String?,
  );
}

/// 卦例类型
enum CaseType { liuyao, meihua, bazi }

/// 卦例数据模型
class CaseModel {
  final int? id;
  final String title;
  final String guaName;        // 卦名（中文）
  final String guaGong;        // 卦宫
  final String method;         // 起卦方式
  final String paipanData;     // 排盘JSON数据
  final String? notes;         // 用户备注
  final String? duanYu;        // 人工断语
  final List<String> tags;     // 标签
  final List<AiMessage> aiMessages; // AI 对话历史
  final CaseType caseType;     // 卦例类型
  final DateTime createdAt;    // 创建时间
  final DateTime updatedAt;    // 更新时间

  CaseModel({
    this.id,
    required this.title,
    required this.guaName,
    required this.guaGong,
    required this.method,
    required this.paipanData,
    this.notes,
    this.duanYu,
    this.tags = const [],
    this.aiMessages = const [],
    this.caseType = CaseType.liuyao,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  CaseModel copyWith({
    int? id,
    String? title,
    String? guaName,
    String? guaGong,
    String? method,
    String? paipanData,
    String? notes,
    String? duanYu,
    List<String>? tags,
    List<AiMessage>? aiMessages,
    CaseType? caseType,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CaseModel(
      id: id ?? this.id,
      title: title ?? this.title,
      guaName: guaName ?? this.guaName,
      guaGong: guaGong ?? this.guaGong,
      method: method ?? this.method,
      paipanData: paipanData ?? this.paipanData,
      notes: notes ?? this.notes,
      duanYu: duanYu ?? this.duanYu,
      tags: tags ?? this.tags,
      aiMessages: aiMessages ?? this.aiMessages,
      caseType: caseType ?? this.caseType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'guaName': guaName,
    'guaGong': guaGong,
    'method': method,
    'paipanData': paipanData,
    'notes': notes,
    'duanYu': duanYu,
    'tags': jsonEncode(tags),
    'aiMessages': jsonEncode(aiMessages.map((m) => m.toJson()).toList()),
    'caseType': caseType.name,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory CaseModel.fromMap(Map<String, dynamic> map) => CaseModel(
    id: map['id'] as int?,
    title: map['title'] as String,
    guaName: map['guaName'] as String,
    guaGong: map['guaGong'] as String,
    method: map['method'] as String,
    paipanData: map['paipanData'] as String,
    notes: map['notes'] as String?,
    duanYu: map['duanYu'] as String?,
    tags: (map['tags'] != null) ? (jsonDecode(map['tags'] as String) as List).cast<String>() : [],
    aiMessages: (map['aiMessages'] != null)
        ? (jsonDecode(map['aiMessages'] as String) as List).map((e) => AiMessage.fromJson(e as Map<String, dynamic>)).toList()
        : [],
    caseType: map['caseType'] != null ? CaseType.values.firstWhere((e) => e.name == map['caseType'], orElse: () => CaseType.liuyao) : CaseType.liuyao,
    createdAt: DateTime.parse(map['createdAt'] as String),
    updatedAt: DateTime.parse(map['updatedAt'] as String),
  );

  /// 从排盘结果创建卦例
  factory CaseModel.fromPaipanResult({
    required PaipanResult result,
    required String title,
    String? notes,
    String? duanYu,
    List<String>? tags,
    CaseType? caseType,  // 传 'meihua' 覆盖默认值（引擎method无法区分）
  }) {
    final now = DateTime.now();
    final methodMap = <String, String>{'manual': '机器摇卦', 'time': '时间起卦', 'number': '数字起卦'};
    return CaseModel(
      id: now.millisecondsSinceEpoch,
      title: title,
      guaName: guaNameToCN(result.benGua.name),
      guaGong: guaGongCN[result.benGua.gong] ?? '',
      method: methodMap[result.method] ?? result.method,
      paipanData: jsonEncode(result.toJson()),
      notes: notes,
      duanYu: duanYu,
      tags: tags ?? [],
      caseType: caseType ?? CaseType.liuyao,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// 从八字结果创建卦例
  factory CaseModel.fromBaziResult({
    required BaziResult result,
    required String title,
    String? notes,
    String? duanYu,
    List<String>? tags,
  }) {
    final now = DateTime.now();
    return CaseModel(
      id: now.millisecondsSinceEpoch,
      title: title,
      guaName: '${result.yearZhu.ganZhi}年',
      guaGong: result.dayZhu.ganZhi,
      method: '八字排盘',
      paipanData: jsonEncode(result.toJson()),
      notes: notes,
      duanYu: duanYu,
      tags: tags ?? ['八字'],
      caseType: CaseType.bazi,
      createdAt: now,
      updatedAt: now,
    );
  }
}
