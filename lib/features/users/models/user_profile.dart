// 落·乾坤 - 用户画像模型（多用户本地保存）
/// 用户画像：多用户独立记录，本地保存，可设密码
class UserProfile {
  final String id;
  String nickname;
  /// 密码（本地简单散列，非明文）
  String? passwordHash;
  /// 是否提交八字（可选择不提交）
  bool hasBazi;
  DateTime? birth;       // 出生日期（含时刻）
  bool isMale;
  int? hourIndex;        // 出生时辰索引 0-11
  /// 八字画像摘要（由排盘引擎生成，如"日主甲木，喜水木"）
  String baziSummary;
  /// 用户补充的画像备注（兴趣/性格/近况等，由用户维护）
  List<String> notes;
  /// 是否在 AI 解卦时参考画像
  bool aiReferenceEnabled;
  DateTime? createdAt;

  UserProfile({
    required this.id,
    required this.nickname,
    this.passwordHash,
    this.hasBazi = false,
    this.birth,
    this.isMale = true,
    this.hourIndex,
    this.baziSummary = '',
    this.notes = const [],
    this.aiReferenceEnabled = false,
    this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'nickname': nickname,
        'passwordHash': passwordHash,
        'hasBazi': hasBazi,
        'birth': birth?.toIso8601String(),
        'isMale': isMale,
        'hourIndex': hourIndex,
        'baziSummary': baziSummary,
        'notes': notes,
        'aiReferenceEnabled': aiReferenceEnabled,
        'createdAt': createdAt?.toIso8601String(),
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        id: json['id'] as String,
        nickname: json['nickname'] as String? ?? '未命名',
        passwordHash: json['passwordHash'] as String?,
        hasBazi: json['hasBazi'] as bool? ?? false,
        birth: json['birth'] != null ? DateTime.parse(json['birth'] as String) : null,
        isMale: json['isMale'] as bool? ?? true,
        hourIndex: json['hourIndex'] as int?,
        baziSummary: json['baziSummary'] as String? ?? '',
        notes: (json['notes'] as List?)?.map((e) => e.toString()).toList() ?? const [],
        aiReferenceEnabled: json['aiReferenceEnabled'] as bool? ?? false,
        createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : null,
      );

  UserProfile copyWith({
    String? nickname,
    String? passwordHash,
    bool? hasBazi,
    DateTime? birth,
    bool? isMale,
    int? hourIndex,
    String? baziSummary,
    List<String>? notes,
    bool? aiReferenceEnabled,
  }) {
    return UserProfile(
      id: id,
      nickname: nickname ?? this.nickname,
      passwordHash: passwordHash ?? this.passwordHash,
      hasBazi: hasBazi ?? this.hasBazi,
      birth: birth ?? this.birth,
      isMale: isMale ?? this.isMale,
      hourIndex: hourIndex ?? this.hourIndex,
      baziSummary: baziSummary ?? this.baziSummary,
      notes: notes ?? this.notes,
      aiReferenceEnabled: aiReferenceEnabled ?? this.aiReferenceEnabled,
      createdAt: createdAt,
    );
  }
}