// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CaseTableTable extends CaseTable
    with TableInfo<$CaseTableTable, CaseTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CaseTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _guaNameMeta =
      const VerificationMeta('guaName');
  @override
  late final GeneratedColumn<String> guaName = GeneratedColumn<String>(
      'gua_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _guaGongMeta =
      const VerificationMeta('guaGong');
  @override
  late final GeneratedColumn<String> guaGong = GeneratedColumn<String>(
      'gua_gong', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _methodMeta = const VerificationMeta('method');
  @override
  late final GeneratedColumn<String> method = GeneratedColumn<String>(
      'method', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _paipanDataMeta =
      const VerificationMeta('paipanData');
  @override
  late final GeneratedColumn<String> paipanData = GeneratedColumn<String>(
      'paipan_data', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _duanYuMeta = const VerificationMeta('duanYu');
  @override
  late final GeneratedColumn<String> duanYu = GeneratedColumn<String>(
      'duan_yu', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _askObjectMeta =
      const VerificationMeta('askObject');
  @override
  late final GeneratedColumn<String> askObject = GeneratedColumn<String>(
      'ask_object', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _askEventMeta =
      const VerificationMeta('askEvent');
  @override
  late final GeneratedColumn<String> askEvent = GeneratedColumn<String>(
      'ask_event', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _tagsMeta = const VerificationMeta('tags');
  @override
  late final GeneratedColumn<String> tags = GeneratedColumn<String>(
      'tags', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _aiMessagesMeta =
      const VerificationMeta('aiMessages');
  @override
  late final GeneratedColumn<String> aiMessages = GeneratedColumn<String>(
      'ai_messages', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _caseTypeMeta =
      const VerificationMeta('caseType');
  @override
  late final GeneratedColumn<String> caseType = GeneratedColumn<String>(
      'case_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        title,
        guaName,
        guaGong,
        method,
        paipanData,
        notes,
        duanYu,
        askObject,
        askEvent,
        tags,
        aiMessages,
        caseType,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'case_table';
  @override
  VerificationContext validateIntegrity(Insertable<CaseTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('gua_name')) {
      context.handle(_guaNameMeta,
          guaName.isAcceptableOrUnknown(data['gua_name']!, _guaNameMeta));
    } else if (isInserting) {
      context.missing(_guaNameMeta);
    }
    if (data.containsKey('gua_gong')) {
      context.handle(_guaGongMeta,
          guaGong.isAcceptableOrUnknown(data['gua_gong']!, _guaGongMeta));
    } else if (isInserting) {
      context.missing(_guaGongMeta);
    }
    if (data.containsKey('method')) {
      context.handle(_methodMeta,
          method.isAcceptableOrUnknown(data['method']!, _methodMeta));
    } else if (isInserting) {
      context.missing(_methodMeta);
    }
    if (data.containsKey('paipan_data')) {
      context.handle(
          _paipanDataMeta,
          paipanData.isAcceptableOrUnknown(
              data['paipan_data']!, _paipanDataMeta));
    } else if (isInserting) {
      context.missing(_paipanDataMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('duan_yu')) {
      context.handle(_duanYuMeta,
          duanYu.isAcceptableOrUnknown(data['duan_yu']!, _duanYuMeta));
    }
    if (data.containsKey('ask_object')) {
      context.handle(_askObjectMeta,
          askObject.isAcceptableOrUnknown(data['ask_object']!, _askObjectMeta));
    }
    if (data.containsKey('ask_event')) {
      context.handle(_askEventMeta,
          askEvent.isAcceptableOrUnknown(data['ask_event']!, _askEventMeta));
    }
    if (data.containsKey('tags')) {
      context.handle(
          _tagsMeta, tags.isAcceptableOrUnknown(data['tags']!, _tagsMeta));
    } else if (isInserting) {
      context.missing(_tagsMeta);
    }
    if (data.containsKey('ai_messages')) {
      context.handle(
          _aiMessagesMeta,
          aiMessages.isAcceptableOrUnknown(
              data['ai_messages']!, _aiMessagesMeta));
    } else if (isInserting) {
      context.missing(_aiMessagesMeta);
    }
    if (data.containsKey('case_type')) {
      context.handle(_caseTypeMeta,
          caseType.isAcceptableOrUnknown(data['case_type']!, _caseTypeMeta));
    } else if (isInserting) {
      context.missing(_caseTypeMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CaseTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CaseTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      guaName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}gua_name'])!,
      guaGong: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}gua_gong'])!,
      method: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}method'])!,
      paipanData: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}paipan_data'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      duanYu: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}duan_yu']),
      askObject: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}ask_object']),
      askEvent: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}ask_event']),
      tags: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tags'])!,
      aiMessages: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}ai_messages'])!,
      caseType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}case_type'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $CaseTableTable createAlias(String alias) {
    return $CaseTableTable(attachedDatabase, alias);
  }
}

class CaseTableData extends DataClass implements Insertable<CaseTableData> {
  final int id;
  final String title;
  final String guaName;
  final String guaGong;
  final String method;
  final String paipanData;
  final String? notes;
  final String? duanYu;
  final String? askObject;
  final String? askEvent;
  final String tags;
  final String aiMessages;
  final String caseType;
  final DateTime createdAt;
  final DateTime updatedAt;
  const CaseTableData(
      {required this.id,
      required this.title,
      required this.guaName,
      required this.guaGong,
      required this.method,
      required this.paipanData,
      this.notes,
      this.duanYu,
      this.askObject,
      this.askEvent,
      required this.tags,
      required this.aiMessages,
      required this.caseType,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    map['gua_name'] = Variable<String>(guaName);
    map['gua_gong'] = Variable<String>(guaGong);
    map['method'] = Variable<String>(method);
    map['paipan_data'] = Variable<String>(paipanData);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || duanYu != null) {
      map['duan_yu'] = Variable<String>(duanYu);
    }
    if (!nullToAbsent || askObject != null) {
      map['ask_object'] = Variable<String>(askObject);
    }
    if (!nullToAbsent || askEvent != null) {
      map['ask_event'] = Variable<String>(askEvent);
    }
    map['tags'] = Variable<String>(tags);
    map['ai_messages'] = Variable<String>(aiMessages);
    map['case_type'] = Variable<String>(caseType);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CaseTableCompanion toCompanion(bool nullToAbsent) {
    return CaseTableCompanion(
      id: Value(id),
      title: Value(title),
      guaName: Value(guaName),
      guaGong: Value(guaGong),
      method: Value(method),
      paipanData: Value(paipanData),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      duanYu:
          duanYu == null && nullToAbsent ? const Value.absent() : Value(duanYu),
      askObject: askObject == null && nullToAbsent
          ? const Value.absent()
          : Value(askObject),
      askEvent: askEvent == null && nullToAbsent
          ? const Value.absent()
          : Value(askEvent),
      tags: Value(tags),
      aiMessages: Value(aiMessages),
      caseType: Value(caseType),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory CaseTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CaseTableData(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      guaName: serializer.fromJson<String>(json['guaName']),
      guaGong: serializer.fromJson<String>(json['guaGong']),
      method: serializer.fromJson<String>(json['method']),
      paipanData: serializer.fromJson<String>(json['paipanData']),
      notes: serializer.fromJson<String?>(json['notes']),
      duanYu: serializer.fromJson<String?>(json['duanYu']),
      askObject: serializer.fromJson<String?>(json['askObject']),
      askEvent: serializer.fromJson<String?>(json['askEvent']),
      tags: serializer.fromJson<String>(json['tags']),
      aiMessages: serializer.fromJson<String>(json['aiMessages']),
      caseType: serializer.fromJson<String>(json['caseType']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'guaName': serializer.toJson<String>(guaName),
      'guaGong': serializer.toJson<String>(guaGong),
      'method': serializer.toJson<String>(method),
      'paipanData': serializer.toJson<String>(paipanData),
      'notes': serializer.toJson<String?>(notes),
      'duanYu': serializer.toJson<String?>(duanYu),
      'askObject': serializer.toJson<String?>(askObject),
      'askEvent': serializer.toJson<String?>(askEvent),
      'tags': serializer.toJson<String>(tags),
      'aiMessages': serializer.toJson<String>(aiMessages),
      'caseType': serializer.toJson<String>(caseType),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  CaseTableData copyWith(
          {int? id,
          String? title,
          String? guaName,
          String? guaGong,
          String? method,
          String? paipanData,
          Value<String?> notes = const Value.absent(),
          Value<String?> duanYu = const Value.absent(),
          Value<String?> askObject = const Value.absent(),
          Value<String?> askEvent = const Value.absent(),
          String? tags,
          String? aiMessages,
          String? caseType,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      CaseTableData(
        id: id ?? this.id,
        title: title ?? this.title,
        guaName: guaName ?? this.guaName,
        guaGong: guaGong ?? this.guaGong,
        method: method ?? this.method,
        paipanData: paipanData ?? this.paipanData,
        notes: notes.present ? notes.value : this.notes,
        duanYu: duanYu.present ? duanYu.value : this.duanYu,
        askObject: askObject.present ? askObject.value : this.askObject,
        askEvent: askEvent.present ? askEvent.value : this.askEvent,
        tags: tags ?? this.tags,
        aiMessages: aiMessages ?? this.aiMessages,
        caseType: caseType ?? this.caseType,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  CaseTableData copyWithCompanion(CaseTableCompanion data) {
    return CaseTableData(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      guaName: data.guaName.present ? data.guaName.value : this.guaName,
      guaGong: data.guaGong.present ? data.guaGong.value : this.guaGong,
      method: data.method.present ? data.method.value : this.method,
      paipanData:
          data.paipanData.present ? data.paipanData.value : this.paipanData,
      notes: data.notes.present ? data.notes.value : this.notes,
      duanYu: data.duanYu.present ? data.duanYu.value : this.duanYu,
      askObject: data.askObject.present ? data.askObject.value : this.askObject,
      askEvent: data.askEvent.present ? data.askEvent.value : this.askEvent,
      tags: data.tags.present ? data.tags.value : this.tags,
      aiMessages:
          data.aiMessages.present ? data.aiMessages.value : this.aiMessages,
      caseType: data.caseType.present ? data.caseType.value : this.caseType,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CaseTableData(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('guaName: $guaName, ')
          ..write('guaGong: $guaGong, ')
          ..write('method: $method, ')
          ..write('paipanData: $paipanData, ')
          ..write('notes: $notes, ')
          ..write('duanYu: $duanYu, ')
          ..write('askObject: $askObject, ')
          ..write('askEvent: $askEvent, ')
          ..write('tags: $tags, ')
          ..write('aiMessages: $aiMessages, ')
          ..write('caseType: $caseType, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      title,
      guaName,
      guaGong,
      method,
      paipanData,
      notes,
      duanYu,
      askObject,
      askEvent,
      tags,
      aiMessages,
      caseType,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CaseTableData &&
          other.id == this.id &&
          other.title == this.title &&
          other.guaName == this.guaName &&
          other.guaGong == this.guaGong &&
          other.method == this.method &&
          other.paipanData == this.paipanData &&
          other.notes == this.notes &&
          other.duanYu == this.duanYu &&
          other.askObject == this.askObject &&
          other.askEvent == this.askEvent &&
          other.tags == this.tags &&
          other.aiMessages == this.aiMessages &&
          other.caseType == this.caseType &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class CaseTableCompanion extends UpdateCompanion<CaseTableData> {
  final Value<int> id;
  final Value<String> title;
  final Value<String> guaName;
  final Value<String> guaGong;
  final Value<String> method;
  final Value<String> paipanData;
  final Value<String?> notes;
  final Value<String?> duanYu;
  final Value<String?> askObject;
  final Value<String?> askEvent;
  final Value<String> tags;
  final Value<String> aiMessages;
  final Value<String> caseType;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const CaseTableCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.guaName = const Value.absent(),
    this.guaGong = const Value.absent(),
    this.method = const Value.absent(),
    this.paipanData = const Value.absent(),
    this.notes = const Value.absent(),
    this.duanYu = const Value.absent(),
    this.askObject = const Value.absent(),
    this.askEvent = const Value.absent(),
    this.tags = const Value.absent(),
    this.aiMessages = const Value.absent(),
    this.caseType = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  CaseTableCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    required String guaName,
    required String guaGong,
    required String method,
    required String paipanData,
    this.notes = const Value.absent(),
    this.duanYu = const Value.absent(),
    this.askObject = const Value.absent(),
    this.askEvent = const Value.absent(),
    required String tags,
    required String aiMessages,
    required String caseType,
    required DateTime createdAt,
    required DateTime updatedAt,
  })  : title = Value(title),
        guaName = Value(guaName),
        guaGong = Value(guaGong),
        method = Value(method),
        paipanData = Value(paipanData),
        tags = Value(tags),
        aiMessages = Value(aiMessages),
        caseType = Value(caseType),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<CaseTableData> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? guaName,
    Expression<String>? guaGong,
    Expression<String>? method,
    Expression<String>? paipanData,
    Expression<String>? notes,
    Expression<String>? duanYu,
    Expression<String>? askObject,
    Expression<String>? askEvent,
    Expression<String>? tags,
    Expression<String>? aiMessages,
    Expression<String>? caseType,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (guaName != null) 'gua_name': guaName,
      if (guaGong != null) 'gua_gong': guaGong,
      if (method != null) 'method': method,
      if (paipanData != null) 'paipan_data': paipanData,
      if (notes != null) 'notes': notes,
      if (duanYu != null) 'duan_yu': duanYu,
      if (askObject != null) 'ask_object': askObject,
      if (askEvent != null) 'ask_event': askEvent,
      if (tags != null) 'tags': tags,
      if (aiMessages != null) 'ai_messages': aiMessages,
      if (caseType != null) 'case_type': caseType,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  CaseTableCompanion copyWith(
      {Value<int>? id,
      Value<String>? title,
      Value<String>? guaName,
      Value<String>? guaGong,
      Value<String>? method,
      Value<String>? paipanData,
      Value<String?>? notes,
      Value<String?>? duanYu,
      Value<String?>? askObject,
      Value<String?>? askEvent,
      Value<String>? tags,
      Value<String>? aiMessages,
      Value<String>? caseType,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt}) {
    return CaseTableCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      guaName: guaName ?? this.guaName,
      guaGong: guaGong ?? this.guaGong,
      method: method ?? this.method,
      paipanData: paipanData ?? this.paipanData,
      notes: notes ?? this.notes,
      duanYu: duanYu ?? this.duanYu,
      askObject: askObject ?? this.askObject,
      askEvent: askEvent ?? this.askEvent,
      tags: tags ?? this.tags,
      aiMessages: aiMessages ?? this.aiMessages,
      caseType: caseType ?? this.caseType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (guaName.present) {
      map['gua_name'] = Variable<String>(guaName.value);
    }
    if (guaGong.present) {
      map['gua_gong'] = Variable<String>(guaGong.value);
    }
    if (method.present) {
      map['method'] = Variable<String>(method.value);
    }
    if (paipanData.present) {
      map['paipan_data'] = Variable<String>(paipanData.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (duanYu.present) {
      map['duan_yu'] = Variable<String>(duanYu.value);
    }
    if (askObject.present) {
      map['ask_object'] = Variable<String>(askObject.value);
    }
    if (askEvent.present) {
      map['ask_event'] = Variable<String>(askEvent.value);
    }
    if (tags.present) {
      map['tags'] = Variable<String>(tags.value);
    }
    if (aiMessages.present) {
      map['ai_messages'] = Variable<String>(aiMessages.value);
    }
    if (caseType.present) {
      map['case_type'] = Variable<String>(caseType.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CaseTableCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('guaName: $guaName, ')
          ..write('guaGong: $guaGong, ')
          ..write('method: $method, ')
          ..write('paipanData: $paipanData, ')
          ..write('notes: $notes, ')
          ..write('duanYu: $duanYu, ')
          ..write('askObject: $askObject, ')
          ..write('askEvent: $askEvent, ')
          ..write('tags: $tags, ')
          ..write('aiMessages: $aiMessages, ')
          ..write('caseType: $caseType, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CaseTableTable caseTable = $CaseTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [caseTable];
}

typedef $$CaseTableTableCreateCompanionBuilder = CaseTableCompanion Function({
  Value<int> id,
  required String title,
  required String guaName,
  required String guaGong,
  required String method,
  required String paipanData,
  Value<String?> notes,
  Value<String?> duanYu,
  Value<String?> askObject,
  Value<String?> askEvent,
  required String tags,
  required String aiMessages,
  required String caseType,
  required DateTime createdAt,
  required DateTime updatedAt,
});
typedef $$CaseTableTableUpdateCompanionBuilder = CaseTableCompanion Function({
  Value<int> id,
  Value<String> title,
  Value<String> guaName,
  Value<String> guaGong,
  Value<String> method,
  Value<String> paipanData,
  Value<String?> notes,
  Value<String?> duanYu,
  Value<String?> askObject,
  Value<String?> askEvent,
  Value<String> tags,
  Value<String> aiMessages,
  Value<String> caseType,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});

class $$CaseTableTableFilterComposer
    extends Composer<_$AppDatabase, $CaseTableTable> {
  $$CaseTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get guaName => $composableBuilder(
      column: $table.guaName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get guaGong => $composableBuilder(
      column: $table.guaGong, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get method => $composableBuilder(
      column: $table.method, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get paipanData => $composableBuilder(
      column: $table.paipanData, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get duanYu => $composableBuilder(
      column: $table.duanYu, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get askObject => $composableBuilder(
      column: $table.askObject, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get askEvent => $composableBuilder(
      column: $table.askEvent, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tags => $composableBuilder(
      column: $table.tags, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get aiMessages => $composableBuilder(
      column: $table.aiMessages, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get caseType => $composableBuilder(
      column: $table.caseType, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$CaseTableTableOrderingComposer
    extends Composer<_$AppDatabase, $CaseTableTable> {
  $$CaseTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get guaName => $composableBuilder(
      column: $table.guaName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get guaGong => $composableBuilder(
      column: $table.guaGong, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get method => $composableBuilder(
      column: $table.method, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get paipanData => $composableBuilder(
      column: $table.paipanData, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get duanYu => $composableBuilder(
      column: $table.duanYu, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get askObject => $composableBuilder(
      column: $table.askObject, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get askEvent => $composableBuilder(
      column: $table.askEvent, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tags => $composableBuilder(
      column: $table.tags, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get aiMessages => $composableBuilder(
      column: $table.aiMessages, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get caseType => $composableBuilder(
      column: $table.caseType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$CaseTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $CaseTableTable> {
  $$CaseTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get guaName =>
      $composableBuilder(column: $table.guaName, builder: (column) => column);

  GeneratedColumn<String> get guaGong =>
      $composableBuilder(column: $table.guaGong, builder: (column) => column);

  GeneratedColumn<String> get method =>
      $composableBuilder(column: $table.method, builder: (column) => column);

  GeneratedColumn<String> get paipanData => $composableBuilder(
      column: $table.paipanData, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get duanYu =>
      $composableBuilder(column: $table.duanYu, builder: (column) => column);

  GeneratedColumn<String> get askObject =>
      $composableBuilder(column: $table.askObject, builder: (column) => column);

  GeneratedColumn<String> get askEvent =>
      $composableBuilder(column: $table.askEvent, builder: (column) => column);

  GeneratedColumn<String> get tags =>
      $composableBuilder(column: $table.tags, builder: (column) => column);

  GeneratedColumn<String> get aiMessages => $composableBuilder(
      column: $table.aiMessages, builder: (column) => column);

  GeneratedColumn<String> get caseType =>
      $composableBuilder(column: $table.caseType, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$CaseTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CaseTableTable,
    CaseTableData,
    $$CaseTableTableFilterComposer,
    $$CaseTableTableOrderingComposer,
    $$CaseTableTableAnnotationComposer,
    $$CaseTableTableCreateCompanionBuilder,
    $$CaseTableTableUpdateCompanionBuilder,
    (
      CaseTableData,
      BaseReferences<_$AppDatabase, $CaseTableTable, CaseTableData>
    ),
    CaseTableData,
    PrefetchHooks Function()> {
  $$CaseTableTableTableManager(_$AppDatabase db, $CaseTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CaseTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CaseTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CaseTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> guaName = const Value.absent(),
            Value<String> guaGong = const Value.absent(),
            Value<String> method = const Value.absent(),
            Value<String> paipanData = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<String?> duanYu = const Value.absent(),
            Value<String?> askObject = const Value.absent(),
            Value<String?> askEvent = const Value.absent(),
            Value<String> tags = const Value.absent(),
            Value<String> aiMessages = const Value.absent(),
            Value<String> caseType = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              CaseTableCompanion(
            id: id,
            title: title,
            guaName: guaName,
            guaGong: guaGong,
            method: method,
            paipanData: paipanData,
            notes: notes,
            duanYu: duanYu,
            askObject: askObject,
            askEvent: askEvent,
            tags: tags,
            aiMessages: aiMessages,
            caseType: caseType,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String title,
            required String guaName,
            required String guaGong,
            required String method,
            required String paipanData,
            Value<String?> notes = const Value.absent(),
            Value<String?> duanYu = const Value.absent(),
            Value<String?> askObject = const Value.absent(),
            Value<String?> askEvent = const Value.absent(),
            required String tags,
            required String aiMessages,
            required String caseType,
            required DateTime createdAt,
            required DateTime updatedAt,
          }) =>
              CaseTableCompanion.insert(
            id: id,
            title: title,
            guaName: guaName,
            guaGong: guaGong,
            method: method,
            paipanData: paipanData,
            notes: notes,
            duanYu: duanYu,
            askObject: askObject,
            askEvent: askEvent,
            tags: tags,
            aiMessages: aiMessages,
            caseType: caseType,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$CaseTableTable, CaseTableData>(table),
                    BaseReferences<_$AppDatabase, $CaseTableTable,
                        CaseTableData>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CaseTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CaseTableTable,
    CaseTableData,
    $$CaseTableTableFilterComposer,
    $$CaseTableTableOrderingComposer,
    $$CaseTableTableAnnotationComposer,
    $$CaseTableTableCreateCompanionBuilder,
    $$CaseTableTableUpdateCompanionBuilder,
    (
      CaseTableData,
      BaseReferences<_$AppDatabase, $CaseTableTable, CaseTableData>
    ),
    CaseTableData,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CaseTableTableTableManager get caseTable =>
      $$CaseTableTableTableManager(_db, _db.caseTable);
}
