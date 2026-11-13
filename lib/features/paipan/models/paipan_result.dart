import 'gua_model.dart';

/// 六爻流派
enum LiuyaoSchool {
  jingFangJianBan,   // 京房简版（默认）
  jingFangZhengZong, // 京房正宗
}

/// 伏神（藏爻）信息
///
/// 传统取法：本卦缺少某一六亲时，取**本宫首卦（八纯卦）**中该六亲的一爻为
/// 伏神，伏于本卦**同一爻位**之下；本卦该爻位的爻称「飞神」。
/// 伏神所临爻位与飞神（六亲/干支）是断卦常用信息，故结构化保存。
class FuShenInfo {
  /// 六亲（父母/兄弟/官鬼/妻财/子孙）
  final String liuQin;

  /// 伏神干支（如 "甲寅"）
  final String ganZhi;

  /// 所伏爻位（0=初爻 … 5=上爻；-1 表示旧数据未记录）
  final int yaoIndex;

  /// 飞神六亲（本卦同位爻的六亲）
  final String feiShenLiuQin;

  /// 飞神干支
  final String feiShenGanZhi;

  const FuShenInfo({
    required this.liuQin,
    required this.ganZhi,
    this.yaoIndex = -1,
    this.feiShenLiuQin = '',
    this.feiShenGanZhi = '',
  });

  static const _posCN = ['初', '二', '三', '四', '五', '上'];

  /// 所伏爻位中文（如 "二爻"；未知时为空）
  String get yaoPositionCN =>
      (yaoIndex >= 0 && yaoIndex < 6) ? '${_posCN[yaoIndex]}爻' : '';

  /// 简述：如 "妻财 甲寅"
  String get label => '$liuQin $ganZhi'.trim();

  /// 完整描述：如 "妻财 甲寅（伏于二爻 兄弟 壬午 下）"
  String get describe {
    if (yaoIndex < 0) return label;
    final fei = '$feiShenLiuQin $feiShenGanZhi'.trim();
    return fei.isEmpty
        ? '$label（伏于$yaoPositionCN）'
        : '$label（伏于$yaoPositionCN $fei 下）';
  }

  Map<String, dynamic> toJson() => {
        'liuQin': liuQin,
        'ganZhi': ganZhi,
        'yaoIndex': yaoIndex,
        'feiShenLiuQin': feiShenLiuQin,
        'feiShenGanZhi': feiShenGanZhi,
      };

  factory FuShenInfo.fromJson(Map<String, dynamic> j) => FuShenInfo(
        liuQin: j['liuQin'] as String? ?? '',
        ganZhi: j['ganZhi'] as String? ?? '',
        yaoIndex: (j['yaoIndex'] as int?) ?? -1,
        feiShenLiuQin: j['feiShenLiuQin'] as String? ?? '',
        feiShenGanZhi: j['feiShenGanZhi'] as String? ?? '',
      );

  /// 旧版数据兼容：早期只存 "官鬼 巳火" 这类字符串（六亲 + 地支五行）
  factory FuShenInfo.legacy(String s) {
    final parts = s.trim().split(RegExp(r'\s+'));
    final lq = parts.isNotEmpty ? parts.first : '';
    final rest = parts.length > 1 ? parts.sublist(1).join(' ') : '';
    return FuShenInfo(liuQin: lq, ganZhi: rest, yaoIndex: -1);
  }
}

/// 排盘结果
class PaipanResult {
  final GuaModel benGua;       // 本卦
  final GuaModel? bianGua;     // 变卦
  final GuaModel? huGua;       // 互卦
  final DateTime paipanTime;   // 排盘时间
  final String method;         // 起卦方式
  final LiuyaoSchool school;   // 流派
  final String? monthZhi;      // 月建（月的地支名）
  final String? monthGanZhi;   // 月柱（干支）
  final String? dayGanZhi;     // 日辰（日干支）
  final List<String> shenSha;  // 神煞列表
  final List<String>? kongWang; // 旬空（空亡的地支名列表）
  final String? naYin;         // 纳音
  /// 伏神（藏爻）结构化信息：本卦缺失的六亲，自本宫首卦借入
  final List<FuShenInfo> fuShen;

  PaipanResult({
    required this.benGua,
    this.bianGua,
    this.huGua,
    required this.paipanTime,
    required this.method,
    this.school = LiuyaoSchool.jingFangJianBan,
    this.monthZhi,
    this.monthGanZhi,
    this.dayGanZhi,
    this.shenSha = const [],
    this.kongWang,
    this.naYin,
    this.fuShen = const [],
  });

  /// 兼容旧接口：伏神简述列表（如 "妻财 甲寅"）
  List<String> get hiddenFuShen => fuShen.map((f) => f.label).toList();

  Map<String, dynamic> toJson() => {
    'benGua': benGua.toJson(),
    'bianGua': bianGua?.toJson(),
    'huGua': huGua?.toJson(),
    'paipanTime': paipanTime.toIso8601String(),
    'method': method,
    'school': school.name,
    'monthZhi': monthZhi,
    'monthGanZhi': monthGanZhi,
    'dayGanZhi': dayGanZhi,
    'shenSha': shenSha,
    'kongWang': kongWang,
    'naYin': naYin,
    // 结构化伏神 + 兼容旧读取方的字符串列表
    'fuShen': fuShen.map((f) => f.toJson()).toList(),
    'hiddenFuShen': hiddenFuShen,
  };

  factory PaipanResult.fromJson(Map<String, dynamic> j) => PaipanResult(
    benGua: GuaModel.fromJson(j['benGua'] as Map<String, dynamic>),
    bianGua: j['bianGua'] != null ? GuaModel.fromJson(j['bianGua'] as Map<String, dynamic>) : null,
    huGua: j['huGua'] != null ? GuaModel.fromJson(j['huGua'] as Map<String, dynamic>) : null,
    paipanTime: DateTime.parse(j['paipanTime'] as String),
    method: j['method'] as String,
    school: LiuyaoSchool.values.firstWhere((e) => e.name == (j['school'] ?? 'jingFangJianBan')),
    monthZhi: j['monthZhi'] as String?,
    monthGanZhi: j['monthGanZhi'] as String?,
    dayGanZhi: j['dayGanZhi'] as String?,
    shenSha: (j['shenSha'] as List?)?.cast<String>() ?? [],
    kongWang: (j['kongWang'] as List?)?.cast<String>() ?? [],
    naYin: j['naYin'] as String?,
    fuShen: () {
      // 新格式：结构化列表
      final raw = j['fuShen'];
      if (raw is List) {
        return raw
            .whereType<Map>()
            .map((e) => FuShenInfo.fromJson(e.cast<String, dynamic>()))
            .toList();
      }
      // 旧格式：字符串列表（"官鬼 巳火"），仅保留六亲与干支，爻位未知
      final legacy = j['hiddenFuShen'];
      if (legacy is List) {
        return legacy.map((e) => FuShenInfo.legacy(e.toString())).toList();
      }
      return const <FuShenInfo>[];
    }(),
  );
}
