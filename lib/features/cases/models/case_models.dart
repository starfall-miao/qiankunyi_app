import 'dart:convert';
import '../../paipan/models/paipan_result.dart';
import '../../paipan/models/gua_model.dart';

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

/// 卦例数据模型
class CaseModel {
  final int? id;
  final String title;
  final String guaName;        // 卦名（中文）
  final String guaGong;        // 卦宫
  final String method;         // 起卦方式（中文）
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

  /// 从排盘结果创建卦例（中文名存储）
  factory CaseModel.fromPaipanResult({
    required PaipanResult result,
    required String title,
    String? notes,
    List<String>? tags,
  }) {
    final now = DateTime.now();
    return CaseModel(
      id: now.millisecondsSinceEpoch ~/ 1000,
      title: title,
      guaName: guaNameToCN(result.benGua.name),
      guaGong: guaGongCN[result.benGua.gong] ?? '',
      method: methodToCN(result.method),
      paipanData: jsonEncode(result.toJson()),
      notes: notes,
      tags: tags ?? [],
      createdAt: now,
      updatedAt: now,
    );
  }
}
