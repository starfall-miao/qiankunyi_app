import 'dart:convert';

/// 卦例数据模型
class CaseModel {
  final int? id;
  final String title;
  final String guaName;        // 卦名
  final String guaGong;        // 卦宫
  final String method;         // 起卦方式
  final String paipanData;     // 排盘JSON数据
  final String? notes;         // 用户备注
  final List<String> tags;     // 标签
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
    this.tags = const [],
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
    List<String>? tags,
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
      tags: tags ?? this.tags,
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
    'tags': jsonEncode(tags),
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
    tags: (map['tags'] != null) ? (jsonDecode(map['tags'] as String) as List).cast<String>() : [],
    createdAt: DateTime.parse(map['createdAt'] as String),
    updatedAt: DateTime.parse(map['updatedAt'] as String),
  );
}
