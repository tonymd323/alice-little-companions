// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class Households extends Table with TableInfo<Households, Household> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Households(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  static const VerificationMeta _singletonMeta = const VerificationMeta(
    'singleton',
  );
  late final GeneratedColumn<int> singleton = GeneratedColumn<int>(
    'singleton',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 1 UNIQUE CHECK (singleton = 1)',
    defaultValue: const CustomExpression('1'),
  );
  static const VerificationMeta _lineageIdMeta = const VerificationMeta(
    'lineageId',
  );
  late final GeneratedColumn<String> lineageId = GeneratedColumn<String>(
    'lineage_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _timezoneMeta = const VerificationMeta(
    'timezone',
  );
  late final GeneratedColumn<String> timezone = GeneratedColumn<String>(
    'timezone',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _rulesVersionMeta = const VerificationMeta(
    'rulesVersion',
  );
  late final GeneratedColumn<String> rulesVersion = GeneratedColumn<String>(
    'rules_version',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _catalogVersionMeta = const VerificationMeta(
    'catalogVersion',
  );
  late final GeneratedColumn<String> catalogVersion = GeneratedColumn<String>(
    'catalog_version',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _domainRevisionMeta = const VerificationMeta(
    'domainRevision',
  );
  late final GeneratedColumn<int> domainRevision = GeneratedColumn<int>(
    'domain_revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const CustomExpression('0'),
  );
  static const VerificationMeta _latestLocalDayMeta = const VerificationMeta(
    'latestLocalDay',
  );
  late final GeneratedColumn<String> latestLocalDay = GeneratedColumn<String>(
    'latest_local_day',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    singleton,
    lineageId,
    timezone,
    rulesVersion,
    catalogVersion,
    domainRevision,
    latestLocalDay,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'households';
  @override
  VerificationContext validateIntegrity(
    Insertable<Household> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('singleton')) {
      context.handle(
        _singletonMeta,
        singleton.isAcceptableOrUnknown(data['singleton']!, _singletonMeta),
      );
    }
    if (data.containsKey('lineage_id')) {
      context.handle(
        _lineageIdMeta,
        lineageId.isAcceptableOrUnknown(data['lineage_id']!, _lineageIdMeta),
      );
    } else if (isInserting) {
      context.missing(_lineageIdMeta);
    }
    if (data.containsKey('timezone')) {
      context.handle(
        _timezoneMeta,
        timezone.isAcceptableOrUnknown(data['timezone']!, _timezoneMeta),
      );
    } else if (isInserting) {
      context.missing(_timezoneMeta);
    }
    if (data.containsKey('rules_version')) {
      context.handle(
        _rulesVersionMeta,
        rulesVersion.isAcceptableOrUnknown(
          data['rules_version']!,
          _rulesVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_rulesVersionMeta);
    }
    if (data.containsKey('catalog_version')) {
      context.handle(
        _catalogVersionMeta,
        catalogVersion.isAcceptableOrUnknown(
          data['catalog_version']!,
          _catalogVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_catalogVersionMeta);
    }
    if (data.containsKey('domain_revision')) {
      context.handle(
        _domainRevisionMeta,
        domainRevision.isAcceptableOrUnknown(
          data['domain_revision']!,
          _domainRevisionMeta,
        ),
      );
    }
    if (data.containsKey('latest_local_day')) {
      context.handle(
        _latestLocalDayMeta,
        latestLocalDay.isAcceptableOrUnknown(
          data['latest_local_day']!,
          _latestLocalDayMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Household map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Household(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      singleton: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}singleton'],
      )!,
      lineageId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lineage_id'],
      )!,
      timezone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}timezone'],
      )!,
      rulesVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rules_version'],
      )!,
      catalogVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}catalog_version'],
      )!,
      domainRevision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}domain_revision'],
      )!,
      latestLocalDay: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}latest_local_day'],
      ),
    );
  }

  @override
  Households createAlias(String alias) {
    return Households(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class Household extends DataClass implements Insertable<Household> {
  final String id;
  final int singleton;
  final String lineageId;
  final String timezone;
  final String rulesVersion;
  final String catalogVersion;
  final int domainRevision;
  final String? latestLocalDay;
  const Household({
    required this.id,
    required this.singleton,
    required this.lineageId,
    required this.timezone,
    required this.rulesVersion,
    required this.catalogVersion,
    required this.domainRevision,
    this.latestLocalDay,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['singleton'] = Variable<int>(singleton);
    map['lineage_id'] = Variable<String>(lineageId);
    map['timezone'] = Variable<String>(timezone);
    map['rules_version'] = Variable<String>(rulesVersion);
    map['catalog_version'] = Variable<String>(catalogVersion);
    map['domain_revision'] = Variable<int>(domainRevision);
    if (!nullToAbsent || latestLocalDay != null) {
      map['latest_local_day'] = Variable<String>(latestLocalDay);
    }
    return map;
  }

  HouseholdsCompanion toCompanion(bool nullToAbsent) {
    return HouseholdsCompanion(
      id: Value(id),
      singleton: Value(singleton),
      lineageId: Value(lineageId),
      timezone: Value(timezone),
      rulesVersion: Value(rulesVersion),
      catalogVersion: Value(catalogVersion),
      domainRevision: Value(domainRevision),
      latestLocalDay: latestLocalDay == null && nullToAbsent
          ? const Value.absent()
          : Value(latestLocalDay),
    );
  }

  factory Household.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Household(
      id: serializer.fromJson<String>(json['id']),
      singleton: serializer.fromJson<int>(json['singleton']),
      lineageId: serializer.fromJson<String>(json['lineage_id']),
      timezone: serializer.fromJson<String>(json['timezone']),
      rulesVersion: serializer.fromJson<String>(json['rules_version']),
      catalogVersion: serializer.fromJson<String>(json['catalog_version']),
      domainRevision: serializer.fromJson<int>(json['domain_revision']),
      latestLocalDay: serializer.fromJson<String?>(json['latest_local_day']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'singleton': serializer.toJson<int>(singleton),
      'lineage_id': serializer.toJson<String>(lineageId),
      'timezone': serializer.toJson<String>(timezone),
      'rules_version': serializer.toJson<String>(rulesVersion),
      'catalog_version': serializer.toJson<String>(catalogVersion),
      'domain_revision': serializer.toJson<int>(domainRevision),
      'latest_local_day': serializer.toJson<String?>(latestLocalDay),
    };
  }

  Household copyWith({
    String? id,
    int? singleton,
    String? lineageId,
    String? timezone,
    String? rulesVersion,
    String? catalogVersion,
    int? domainRevision,
    Value<String?> latestLocalDay = const Value.absent(),
  }) => Household(
    id: id ?? this.id,
    singleton: singleton ?? this.singleton,
    lineageId: lineageId ?? this.lineageId,
    timezone: timezone ?? this.timezone,
    rulesVersion: rulesVersion ?? this.rulesVersion,
    catalogVersion: catalogVersion ?? this.catalogVersion,
    domainRevision: domainRevision ?? this.domainRevision,
    latestLocalDay: latestLocalDay.present
        ? latestLocalDay.value
        : this.latestLocalDay,
  );
  Household copyWithCompanion(HouseholdsCompanion data) {
    return Household(
      id: data.id.present ? data.id.value : this.id,
      singleton: data.singleton.present ? data.singleton.value : this.singleton,
      lineageId: data.lineageId.present ? data.lineageId.value : this.lineageId,
      timezone: data.timezone.present ? data.timezone.value : this.timezone,
      rulesVersion: data.rulesVersion.present
          ? data.rulesVersion.value
          : this.rulesVersion,
      catalogVersion: data.catalogVersion.present
          ? data.catalogVersion.value
          : this.catalogVersion,
      domainRevision: data.domainRevision.present
          ? data.domainRevision.value
          : this.domainRevision,
      latestLocalDay: data.latestLocalDay.present
          ? data.latestLocalDay.value
          : this.latestLocalDay,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Household(')
          ..write('id: $id, ')
          ..write('singleton: $singleton, ')
          ..write('lineageId: $lineageId, ')
          ..write('timezone: $timezone, ')
          ..write('rulesVersion: $rulesVersion, ')
          ..write('catalogVersion: $catalogVersion, ')
          ..write('domainRevision: $domainRevision, ')
          ..write('latestLocalDay: $latestLocalDay')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    singleton,
    lineageId,
    timezone,
    rulesVersion,
    catalogVersion,
    domainRevision,
    latestLocalDay,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Household &&
          other.id == this.id &&
          other.singleton == this.singleton &&
          other.lineageId == this.lineageId &&
          other.timezone == this.timezone &&
          other.rulesVersion == this.rulesVersion &&
          other.catalogVersion == this.catalogVersion &&
          other.domainRevision == this.domainRevision &&
          other.latestLocalDay == this.latestLocalDay);
}

class HouseholdsCompanion extends UpdateCompanion<Household> {
  final Value<String> id;
  final Value<int> singleton;
  final Value<String> lineageId;
  final Value<String> timezone;
  final Value<String> rulesVersion;
  final Value<String> catalogVersion;
  final Value<int> domainRevision;
  final Value<String?> latestLocalDay;
  final Value<int> rowid;
  const HouseholdsCompanion({
    this.id = const Value.absent(),
    this.singleton = const Value.absent(),
    this.lineageId = const Value.absent(),
    this.timezone = const Value.absent(),
    this.rulesVersion = const Value.absent(),
    this.catalogVersion = const Value.absent(),
    this.domainRevision = const Value.absent(),
    this.latestLocalDay = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HouseholdsCompanion.insert({
    required String id,
    this.singleton = const Value.absent(),
    required String lineageId,
    required String timezone,
    required String rulesVersion,
    required String catalogVersion,
    this.domainRevision = const Value.absent(),
    this.latestLocalDay = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       lineageId = Value(lineageId),
       timezone = Value(timezone),
       rulesVersion = Value(rulesVersion),
       catalogVersion = Value(catalogVersion);
  static Insertable<Household> custom({
    Expression<String>? id,
    Expression<int>? singleton,
    Expression<String>? lineageId,
    Expression<String>? timezone,
    Expression<String>? rulesVersion,
    Expression<String>? catalogVersion,
    Expression<int>? domainRevision,
    Expression<String>? latestLocalDay,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (singleton != null) 'singleton': singleton,
      if (lineageId != null) 'lineage_id': lineageId,
      if (timezone != null) 'timezone': timezone,
      if (rulesVersion != null) 'rules_version': rulesVersion,
      if (catalogVersion != null) 'catalog_version': catalogVersion,
      if (domainRevision != null) 'domain_revision': domainRevision,
      if (latestLocalDay != null) 'latest_local_day': latestLocalDay,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HouseholdsCompanion copyWith({
    Value<String>? id,
    Value<int>? singleton,
    Value<String>? lineageId,
    Value<String>? timezone,
    Value<String>? rulesVersion,
    Value<String>? catalogVersion,
    Value<int>? domainRevision,
    Value<String?>? latestLocalDay,
    Value<int>? rowid,
  }) {
    return HouseholdsCompanion(
      id: id ?? this.id,
      singleton: singleton ?? this.singleton,
      lineageId: lineageId ?? this.lineageId,
      timezone: timezone ?? this.timezone,
      rulesVersion: rulesVersion ?? this.rulesVersion,
      catalogVersion: catalogVersion ?? this.catalogVersion,
      domainRevision: domainRevision ?? this.domainRevision,
      latestLocalDay: latestLocalDay ?? this.latestLocalDay,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (singleton.present) {
      map['singleton'] = Variable<int>(singleton.value);
    }
    if (lineageId.present) {
      map['lineage_id'] = Variable<String>(lineageId.value);
    }
    if (timezone.present) {
      map['timezone'] = Variable<String>(timezone.value);
    }
    if (rulesVersion.present) {
      map['rules_version'] = Variable<String>(rulesVersion.value);
    }
    if (catalogVersion.present) {
      map['catalog_version'] = Variable<String>(catalogVersion.value);
    }
    if (domainRevision.present) {
      map['domain_revision'] = Variable<int>(domainRevision.value);
    }
    if (latestLocalDay.present) {
      map['latest_local_day'] = Variable<String>(latestLocalDay.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HouseholdsCompanion(')
          ..write('id: $id, ')
          ..write('singleton: $singleton, ')
          ..write('lineageId: $lineageId, ')
          ..write('timezone: $timezone, ')
          ..write('rulesVersion: $rulesVersion, ')
          ..write('catalogVersion: $catalogVersion, ')
          ..write('domainRevision: $domainRevision, ')
          ..write('latestLocalDay: $latestLocalDay, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class ChildProfiles extends Table with TableInfo<ChildProfiles, ChildProfile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  ChildProfiles(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  static const VerificationMeta _familyIdMeta = const VerificationMeta(
    'familyId',
  );
  late final GeneratedColumn<String> familyId = GeneratedColumn<String>(
    'family_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL UNIQUE REFERENCES households(id)',
  );
  static const VerificationMeta _nicknameMeta = const VerificationMeta(
    'nickname',
  );
  late final GeneratedColumn<String> nickname = GeneratedColumn<String>(
    'nickname',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _activePetIdMeta = const VerificationMeta(
    'activePetId',
  );
  late final GeneratedColumn<String> activePetId = GeneratedColumn<String>(
    'active_pet_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints:
        'NOT NULL CHECK (active_pet_id IN (\'fox\', \'rabbit\', \'cat\'))',
  );
  @override
  List<GeneratedColumn> get $columns => [id, familyId, nickname, activePetId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'child_profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<ChildProfile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('family_id')) {
      context.handle(
        _familyIdMeta,
        familyId.isAcceptableOrUnknown(data['family_id']!, _familyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_familyIdMeta);
    }
    if (data.containsKey('nickname')) {
      context.handle(
        _nicknameMeta,
        nickname.isAcceptableOrUnknown(data['nickname']!, _nicknameMeta),
      );
    } else if (isInserting) {
      context.missing(_nicknameMeta);
    }
    if (data.containsKey('active_pet_id')) {
      context.handle(
        _activePetIdMeta,
        activePetId.isAcceptableOrUnknown(
          data['active_pet_id']!,
          _activePetIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_activePetIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ChildProfile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChildProfile(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      familyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}family_id'],
      )!,
      nickname: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nickname'],
      )!,
      activePetId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}active_pet_id'],
      )!,
    );
  }

  @override
  ChildProfiles createAlias(String alias) {
    return ChildProfiles(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class ChildProfile extends DataClass implements Insertable<ChildProfile> {
  final String id;
  final String familyId;
  final String nickname;
  final String activePetId;
  const ChildProfile({
    required this.id,
    required this.familyId,
    required this.nickname,
    required this.activePetId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['family_id'] = Variable<String>(familyId);
    map['nickname'] = Variable<String>(nickname);
    map['active_pet_id'] = Variable<String>(activePetId);
    return map;
  }

  ChildProfilesCompanion toCompanion(bool nullToAbsent) {
    return ChildProfilesCompanion(
      id: Value(id),
      familyId: Value(familyId),
      nickname: Value(nickname),
      activePetId: Value(activePetId),
    );
  }

  factory ChildProfile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChildProfile(
      id: serializer.fromJson<String>(json['id']),
      familyId: serializer.fromJson<String>(json['family_id']),
      nickname: serializer.fromJson<String>(json['nickname']),
      activePetId: serializer.fromJson<String>(json['active_pet_id']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'family_id': serializer.toJson<String>(familyId),
      'nickname': serializer.toJson<String>(nickname),
      'active_pet_id': serializer.toJson<String>(activePetId),
    };
  }

  ChildProfile copyWith({
    String? id,
    String? familyId,
    String? nickname,
    String? activePetId,
  }) => ChildProfile(
    id: id ?? this.id,
    familyId: familyId ?? this.familyId,
    nickname: nickname ?? this.nickname,
    activePetId: activePetId ?? this.activePetId,
  );
  ChildProfile copyWithCompanion(ChildProfilesCompanion data) {
    return ChildProfile(
      id: data.id.present ? data.id.value : this.id,
      familyId: data.familyId.present ? data.familyId.value : this.familyId,
      nickname: data.nickname.present ? data.nickname.value : this.nickname,
      activePetId: data.activePetId.present
          ? data.activePetId.value
          : this.activePetId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChildProfile(')
          ..write('id: $id, ')
          ..write('familyId: $familyId, ')
          ..write('nickname: $nickname, ')
          ..write('activePetId: $activePetId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, familyId, nickname, activePetId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChildProfile &&
          other.id == this.id &&
          other.familyId == this.familyId &&
          other.nickname == this.nickname &&
          other.activePetId == this.activePetId);
}

class ChildProfilesCompanion extends UpdateCompanion<ChildProfile> {
  final Value<String> id;
  final Value<String> familyId;
  final Value<String> nickname;
  final Value<String> activePetId;
  final Value<int> rowid;
  const ChildProfilesCompanion({
    this.id = const Value.absent(),
    this.familyId = const Value.absent(),
    this.nickname = const Value.absent(),
    this.activePetId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ChildProfilesCompanion.insert({
    required String id,
    required String familyId,
    required String nickname,
    required String activePetId,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       familyId = Value(familyId),
       nickname = Value(nickname),
       activePetId = Value(activePetId);
  static Insertable<ChildProfile> custom({
    Expression<String>? id,
    Expression<String>? familyId,
    Expression<String>? nickname,
    Expression<String>? activePetId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (familyId != null) 'family_id': familyId,
      if (nickname != null) 'nickname': nickname,
      if (activePetId != null) 'active_pet_id': activePetId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ChildProfilesCompanion copyWith({
    Value<String>? id,
    Value<String>? familyId,
    Value<String>? nickname,
    Value<String>? activePetId,
    Value<int>? rowid,
  }) {
    return ChildProfilesCompanion(
      id: id ?? this.id,
      familyId: familyId ?? this.familyId,
      nickname: nickname ?? this.nickname,
      activePetId: activePetId ?? this.activePetId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (familyId.present) {
      map['family_id'] = Variable<String>(familyId.value);
    }
    if (nickname.present) {
      map['nickname'] = Variable<String>(nickname.value);
    }
    if (activePetId.present) {
      map['active_pet_id'] = Variable<String>(activePetId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChildProfilesCompanion(')
          ..write('id: $id, ')
          ..write('familyId: $familyId, ')
          ..write('nickname: $nickname, ')
          ..write('activePetId: $activePetId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class Accounts extends Table with TableInfo<Accounts, Account> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Accounts(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  static const VerificationMeta _childIdMeta = const VerificationMeta(
    'childId',
  );
  late final GeneratedColumn<String> childId = GeneratedColumn<String>(
    'child_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL UNIQUE REFERENCES child_profiles(id)',
  );
  static const VerificationMeta _balanceMeta = const VerificationMeta(
    'balance',
  );
  late final GeneratedColumn<int> balance = GeneratedColumn<int>(
    'balance',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0 CHECK (balance >= 0)',
    defaultValue: const CustomExpression('0'),
  );
  @override
  List<GeneratedColumn> get $columns => [id, childId, balance];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'accounts';
  @override
  VerificationContext validateIntegrity(
    Insertable<Account> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('child_id')) {
      context.handle(
        _childIdMeta,
        childId.isAcceptableOrUnknown(data['child_id']!, _childIdMeta),
      );
    } else if (isInserting) {
      context.missing(_childIdMeta);
    }
    if (data.containsKey('balance')) {
      context.handle(
        _balanceMeta,
        balance.isAcceptableOrUnknown(data['balance']!, _balanceMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Account map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Account(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      childId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}child_id'],
      )!,
      balance: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}balance'],
      )!,
    );
  }

  @override
  Accounts createAlias(String alias) {
    return Accounts(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class Account extends DataClass implements Insertable<Account> {
  final String id;
  final String childId;
  final int balance;
  const Account({
    required this.id,
    required this.childId,
    required this.balance,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['child_id'] = Variable<String>(childId);
    map['balance'] = Variable<int>(balance);
    return map;
  }

  AccountsCompanion toCompanion(bool nullToAbsent) {
    return AccountsCompanion(
      id: Value(id),
      childId: Value(childId),
      balance: Value(balance),
    );
  }

  factory Account.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Account(
      id: serializer.fromJson<String>(json['id']),
      childId: serializer.fromJson<String>(json['child_id']),
      balance: serializer.fromJson<int>(json['balance']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'child_id': serializer.toJson<String>(childId),
      'balance': serializer.toJson<int>(balance),
    };
  }

  Account copyWith({String? id, String? childId, int? balance}) => Account(
    id: id ?? this.id,
    childId: childId ?? this.childId,
    balance: balance ?? this.balance,
  );
  Account copyWithCompanion(AccountsCompanion data) {
    return Account(
      id: data.id.present ? data.id.value : this.id,
      childId: data.childId.present ? data.childId.value : this.childId,
      balance: data.balance.present ? data.balance.value : this.balance,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Account(')
          ..write('id: $id, ')
          ..write('childId: $childId, ')
          ..write('balance: $balance')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, childId, balance);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Account &&
          other.id == this.id &&
          other.childId == this.childId &&
          other.balance == this.balance);
}

class AccountsCompanion extends UpdateCompanion<Account> {
  final Value<String> id;
  final Value<String> childId;
  final Value<int> balance;
  final Value<int> rowid;
  const AccountsCompanion({
    this.id = const Value.absent(),
    this.childId = const Value.absent(),
    this.balance = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AccountsCompanion.insert({
    required String id,
    required String childId,
    this.balance = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       childId = Value(childId);
  static Insertable<Account> custom({
    Expression<String>? id,
    Expression<String>? childId,
    Expression<int>? balance,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (childId != null) 'child_id': childId,
      if (balance != null) 'balance': balance,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AccountsCompanion copyWith({
    Value<String>? id,
    Value<String>? childId,
    Value<int>? balance,
    Value<int>? rowid,
  }) {
    return AccountsCompanion(
      id: id ?? this.id,
      childId: childId ?? this.childId,
      balance: balance ?? this.balance,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (childId.present) {
      map['child_id'] = Variable<String>(childId.value);
    }
    if (balance.present) {
      map['balance'] = Variable<int>(balance.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AccountsCompanion(')
          ..write('id: $id, ')
          ..write('childId: $childId, ')
          ..write('balance: $balance, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class TaskTemplates extends Table with TableInfo<TaskTemplates, TaskTemplate> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  TaskTemplates(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  static const VerificationMeta _familyIdMeta = const VerificationMeta(
    'familyId',
  );
  late final GeneratedColumn<String> familyId = GeneratedColumn<String>(
    'family_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES households(id)',
  );
  static const VerificationMeta _modeMeta = const VerificationMeta('mode');
  late final GeneratedColumn<String> mode = GeneratedColumn<String>(
    'mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints:
        'NOT NULL CHECK (mode IN (\'once\', \'recurring\', \'staged\'))',
  );
  static const VerificationMeta _currentVersionMeta = const VerificationMeta(
    'currentVersion',
  );
  late final GeneratedColumn<int> currentVersion = GeneratedColumn<int>(
    'current_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 1 CHECK (current_version >= 1)',
    defaultValue: const CustomExpression('1'),
  );
  static const VerificationMeta _pausedMeta = const VerificationMeta('paused');
  late final GeneratedColumn<int> paused = GeneratedColumn<int>(
    'paused',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0 CHECK (paused IN (0, 1))',
    defaultValue: const CustomExpression('0'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    familyId,
    mode,
    currentVersion,
    paused,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'task_templates';
  @override
  VerificationContext validateIntegrity(
    Insertable<TaskTemplate> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('family_id')) {
      context.handle(
        _familyIdMeta,
        familyId.isAcceptableOrUnknown(data['family_id']!, _familyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_familyIdMeta);
    }
    if (data.containsKey('mode')) {
      context.handle(
        _modeMeta,
        mode.isAcceptableOrUnknown(data['mode']!, _modeMeta),
      );
    } else if (isInserting) {
      context.missing(_modeMeta);
    }
    if (data.containsKey('current_version')) {
      context.handle(
        _currentVersionMeta,
        currentVersion.isAcceptableOrUnknown(
          data['current_version']!,
          _currentVersionMeta,
        ),
      );
    }
    if (data.containsKey('paused')) {
      context.handle(
        _pausedMeta,
        paused.isAcceptableOrUnknown(data['paused']!, _pausedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TaskTemplate map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TaskTemplate(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      familyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}family_id'],
      )!,
      mode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mode'],
      )!,
      currentVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}current_version'],
      )!,
      paused: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}paused'],
      )!,
    );
  }

  @override
  TaskTemplates createAlias(String alias) {
    return TaskTemplates(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class TaskTemplate extends DataClass implements Insertable<TaskTemplate> {
  final String id;
  final String familyId;
  final String mode;
  final int currentVersion;
  final int paused;
  const TaskTemplate({
    required this.id,
    required this.familyId,
    required this.mode,
    required this.currentVersion,
    required this.paused,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['family_id'] = Variable<String>(familyId);
    map['mode'] = Variable<String>(mode);
    map['current_version'] = Variable<int>(currentVersion);
    map['paused'] = Variable<int>(paused);
    return map;
  }

  TaskTemplatesCompanion toCompanion(bool nullToAbsent) {
    return TaskTemplatesCompanion(
      id: Value(id),
      familyId: Value(familyId),
      mode: Value(mode),
      currentVersion: Value(currentVersion),
      paused: Value(paused),
    );
  }

  factory TaskTemplate.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TaskTemplate(
      id: serializer.fromJson<String>(json['id']),
      familyId: serializer.fromJson<String>(json['family_id']),
      mode: serializer.fromJson<String>(json['mode']),
      currentVersion: serializer.fromJson<int>(json['current_version']),
      paused: serializer.fromJson<int>(json['paused']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'family_id': serializer.toJson<String>(familyId),
      'mode': serializer.toJson<String>(mode),
      'current_version': serializer.toJson<int>(currentVersion),
      'paused': serializer.toJson<int>(paused),
    };
  }

  TaskTemplate copyWith({
    String? id,
    String? familyId,
    String? mode,
    int? currentVersion,
    int? paused,
  }) => TaskTemplate(
    id: id ?? this.id,
    familyId: familyId ?? this.familyId,
    mode: mode ?? this.mode,
    currentVersion: currentVersion ?? this.currentVersion,
    paused: paused ?? this.paused,
  );
  TaskTemplate copyWithCompanion(TaskTemplatesCompanion data) {
    return TaskTemplate(
      id: data.id.present ? data.id.value : this.id,
      familyId: data.familyId.present ? data.familyId.value : this.familyId,
      mode: data.mode.present ? data.mode.value : this.mode,
      currentVersion: data.currentVersion.present
          ? data.currentVersion.value
          : this.currentVersion,
      paused: data.paused.present ? data.paused.value : this.paused,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TaskTemplate(')
          ..write('id: $id, ')
          ..write('familyId: $familyId, ')
          ..write('mode: $mode, ')
          ..write('currentVersion: $currentVersion, ')
          ..write('paused: $paused')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, familyId, mode, currentVersion, paused);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TaskTemplate &&
          other.id == this.id &&
          other.familyId == this.familyId &&
          other.mode == this.mode &&
          other.currentVersion == this.currentVersion &&
          other.paused == this.paused);
}

class TaskTemplatesCompanion extends UpdateCompanion<TaskTemplate> {
  final Value<String> id;
  final Value<String> familyId;
  final Value<String> mode;
  final Value<int> currentVersion;
  final Value<int> paused;
  final Value<int> rowid;
  const TaskTemplatesCompanion({
    this.id = const Value.absent(),
    this.familyId = const Value.absent(),
    this.mode = const Value.absent(),
    this.currentVersion = const Value.absent(),
    this.paused = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TaskTemplatesCompanion.insert({
    required String id,
    required String familyId,
    required String mode,
    this.currentVersion = const Value.absent(),
    this.paused = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       familyId = Value(familyId),
       mode = Value(mode);
  static Insertable<TaskTemplate> custom({
    Expression<String>? id,
    Expression<String>? familyId,
    Expression<String>? mode,
    Expression<int>? currentVersion,
    Expression<int>? paused,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (familyId != null) 'family_id': familyId,
      if (mode != null) 'mode': mode,
      if (currentVersion != null) 'current_version': currentVersion,
      if (paused != null) 'paused': paused,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TaskTemplatesCompanion copyWith({
    Value<String>? id,
    Value<String>? familyId,
    Value<String>? mode,
    Value<int>? currentVersion,
    Value<int>? paused,
    Value<int>? rowid,
  }) {
    return TaskTemplatesCompanion(
      id: id ?? this.id,
      familyId: familyId ?? this.familyId,
      mode: mode ?? this.mode,
      currentVersion: currentVersion ?? this.currentVersion,
      paused: paused ?? this.paused,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (familyId.present) {
      map['family_id'] = Variable<String>(familyId.value);
    }
    if (mode.present) {
      map['mode'] = Variable<String>(mode.value);
    }
    if (currentVersion.present) {
      map['current_version'] = Variable<int>(currentVersion.value);
    }
    if (paused.present) {
      map['paused'] = Variable<int>(paused.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TaskTemplatesCompanion(')
          ..write('id: $id, ')
          ..write('familyId: $familyId, ')
          ..write('mode: $mode, ')
          ..write('currentVersion: $currentVersion, ')
          ..write('paused: $paused, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class TaskVersions extends Table with TableInfo<TaskVersions, TaskVersion> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  TaskVersions(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  static const VerificationMeta _templateIdMeta = const VerificationMeta(
    'templateId',
  );
  late final GeneratedColumn<String> templateId = GeneratedColumn<String>(
    'template_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES task_templates(id)',
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _criteriaMeta = const VerificationMeta(
    'criteria',
  );
  late final GeneratedColumn<String> criteria = GeneratedColumn<String>(
    'criteria',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _taskTypeMeta = const VerificationMeta(
    'taskType',
  );
  late final GeneratedColumn<String> taskType = GeneratedColumn<String>(
    'task_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _rewardMeta = const VerificationMeta('reward');
  late final GeneratedColumn<int> reward = GeneratedColumn<int>(
    'reward',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (reward BETWEEN 2 AND 5)',
  );
  static const VerificationMeta _rulesVersionMeta = const VerificationMeta(
    'rulesVersion',
  );
  late final GeneratedColumn<String> rulesVersion = GeneratedColumn<String>(
    'rules_version',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _scheduleJsonMeta = const VerificationMeta(
    'scheduleJson',
  );
  late final GeneratedColumn<String> scheduleJson = GeneratedColumn<String>(
    'schedule_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    templateId,
    version,
    title,
    content,
    criteria,
    taskType,
    reward,
    rulesVersion,
    scheduleJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'task_versions';
  @override
  VerificationContext validateIntegrity(
    Insertable<TaskVersion> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('template_id')) {
      context.handle(
        _templateIdMeta,
        templateId.isAcceptableOrUnknown(data['template_id']!, _templateIdMeta),
      );
    } else if (isInserting) {
      context.missing(_templateIdMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    } else if (isInserting) {
      context.missing(_versionMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('criteria')) {
      context.handle(
        _criteriaMeta,
        criteria.isAcceptableOrUnknown(data['criteria']!, _criteriaMeta),
      );
    } else if (isInserting) {
      context.missing(_criteriaMeta);
    }
    if (data.containsKey('task_type')) {
      context.handle(
        _taskTypeMeta,
        taskType.isAcceptableOrUnknown(data['task_type']!, _taskTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_taskTypeMeta);
    }
    if (data.containsKey('reward')) {
      context.handle(
        _rewardMeta,
        reward.isAcceptableOrUnknown(data['reward']!, _rewardMeta),
      );
    } else if (isInserting) {
      context.missing(_rewardMeta);
    }
    if (data.containsKey('rules_version')) {
      context.handle(
        _rulesVersionMeta,
        rulesVersion.isAcceptableOrUnknown(
          data['rules_version']!,
          _rulesVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_rulesVersionMeta);
    }
    if (data.containsKey('schedule_json')) {
      context.handle(
        _scheduleJsonMeta,
        scheduleJson.isAcceptableOrUnknown(
          data['schedule_json']!,
          _scheduleJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_scheduleJsonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {templateId, version},
  ];
  @override
  TaskVersion map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TaskVersion(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      templateId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}template_id'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      criteria: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}criteria'],
      )!,
      taskType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}task_type'],
      )!,
      reward: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reward'],
      )!,
      rulesVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rules_version'],
      )!,
      scheduleJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}schedule_json'],
      )!,
    );
  }

  @override
  TaskVersions createAlias(String alias) {
    return TaskVersions(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints => const ['UNIQUE(template_id, version)'];
  @override
  bool get dontWriteConstraints => true;
}

class TaskVersion extends DataClass implements Insertable<TaskVersion> {
  final String id;
  final String templateId;
  final int version;
  final String title;
  final String content;
  final String criteria;
  final String taskType;
  final int reward;
  final String rulesVersion;
  final String scheduleJson;
  const TaskVersion({
    required this.id,
    required this.templateId,
    required this.version,
    required this.title,
    required this.content,
    required this.criteria,
    required this.taskType,
    required this.reward,
    required this.rulesVersion,
    required this.scheduleJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['template_id'] = Variable<String>(templateId);
    map['version'] = Variable<int>(version);
    map['title'] = Variable<String>(title);
    map['content'] = Variable<String>(content);
    map['criteria'] = Variable<String>(criteria);
    map['task_type'] = Variable<String>(taskType);
    map['reward'] = Variable<int>(reward);
    map['rules_version'] = Variable<String>(rulesVersion);
    map['schedule_json'] = Variable<String>(scheduleJson);
    return map;
  }

  TaskVersionsCompanion toCompanion(bool nullToAbsent) {
    return TaskVersionsCompanion(
      id: Value(id),
      templateId: Value(templateId),
      version: Value(version),
      title: Value(title),
      content: Value(content),
      criteria: Value(criteria),
      taskType: Value(taskType),
      reward: Value(reward),
      rulesVersion: Value(rulesVersion),
      scheduleJson: Value(scheduleJson),
    );
  }

  factory TaskVersion.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TaskVersion(
      id: serializer.fromJson<String>(json['id']),
      templateId: serializer.fromJson<String>(json['template_id']),
      version: serializer.fromJson<int>(json['version']),
      title: serializer.fromJson<String>(json['title']),
      content: serializer.fromJson<String>(json['content']),
      criteria: serializer.fromJson<String>(json['criteria']),
      taskType: serializer.fromJson<String>(json['task_type']),
      reward: serializer.fromJson<int>(json['reward']),
      rulesVersion: serializer.fromJson<String>(json['rules_version']),
      scheduleJson: serializer.fromJson<String>(json['schedule_json']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'template_id': serializer.toJson<String>(templateId),
      'version': serializer.toJson<int>(version),
      'title': serializer.toJson<String>(title),
      'content': serializer.toJson<String>(content),
      'criteria': serializer.toJson<String>(criteria),
      'task_type': serializer.toJson<String>(taskType),
      'reward': serializer.toJson<int>(reward),
      'rules_version': serializer.toJson<String>(rulesVersion),
      'schedule_json': serializer.toJson<String>(scheduleJson),
    };
  }

  TaskVersion copyWith({
    String? id,
    String? templateId,
    int? version,
    String? title,
    String? content,
    String? criteria,
    String? taskType,
    int? reward,
    String? rulesVersion,
    String? scheduleJson,
  }) => TaskVersion(
    id: id ?? this.id,
    templateId: templateId ?? this.templateId,
    version: version ?? this.version,
    title: title ?? this.title,
    content: content ?? this.content,
    criteria: criteria ?? this.criteria,
    taskType: taskType ?? this.taskType,
    reward: reward ?? this.reward,
    rulesVersion: rulesVersion ?? this.rulesVersion,
    scheduleJson: scheduleJson ?? this.scheduleJson,
  );
  TaskVersion copyWithCompanion(TaskVersionsCompanion data) {
    return TaskVersion(
      id: data.id.present ? data.id.value : this.id,
      templateId: data.templateId.present
          ? data.templateId.value
          : this.templateId,
      version: data.version.present ? data.version.value : this.version,
      title: data.title.present ? data.title.value : this.title,
      content: data.content.present ? data.content.value : this.content,
      criteria: data.criteria.present ? data.criteria.value : this.criteria,
      taskType: data.taskType.present ? data.taskType.value : this.taskType,
      reward: data.reward.present ? data.reward.value : this.reward,
      rulesVersion: data.rulesVersion.present
          ? data.rulesVersion.value
          : this.rulesVersion,
      scheduleJson: data.scheduleJson.present
          ? data.scheduleJson.value
          : this.scheduleJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TaskVersion(')
          ..write('id: $id, ')
          ..write('templateId: $templateId, ')
          ..write('version: $version, ')
          ..write('title: $title, ')
          ..write('content: $content, ')
          ..write('criteria: $criteria, ')
          ..write('taskType: $taskType, ')
          ..write('reward: $reward, ')
          ..write('rulesVersion: $rulesVersion, ')
          ..write('scheduleJson: $scheduleJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    templateId,
    version,
    title,
    content,
    criteria,
    taskType,
    reward,
    rulesVersion,
    scheduleJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TaskVersion &&
          other.id == this.id &&
          other.templateId == this.templateId &&
          other.version == this.version &&
          other.title == this.title &&
          other.content == this.content &&
          other.criteria == this.criteria &&
          other.taskType == this.taskType &&
          other.reward == this.reward &&
          other.rulesVersion == this.rulesVersion &&
          other.scheduleJson == this.scheduleJson);
}

class TaskVersionsCompanion extends UpdateCompanion<TaskVersion> {
  final Value<String> id;
  final Value<String> templateId;
  final Value<int> version;
  final Value<String> title;
  final Value<String> content;
  final Value<String> criteria;
  final Value<String> taskType;
  final Value<int> reward;
  final Value<String> rulesVersion;
  final Value<String> scheduleJson;
  final Value<int> rowid;
  const TaskVersionsCompanion({
    this.id = const Value.absent(),
    this.templateId = const Value.absent(),
    this.version = const Value.absent(),
    this.title = const Value.absent(),
    this.content = const Value.absent(),
    this.criteria = const Value.absent(),
    this.taskType = const Value.absent(),
    this.reward = const Value.absent(),
    this.rulesVersion = const Value.absent(),
    this.scheduleJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TaskVersionsCompanion.insert({
    required String id,
    required String templateId,
    required int version,
    required String title,
    required String content,
    required String criteria,
    required String taskType,
    required int reward,
    required String rulesVersion,
    required String scheduleJson,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       templateId = Value(templateId),
       version = Value(version),
       title = Value(title),
       content = Value(content),
       criteria = Value(criteria),
       taskType = Value(taskType),
       reward = Value(reward),
       rulesVersion = Value(rulesVersion),
       scheduleJson = Value(scheduleJson);
  static Insertable<TaskVersion> custom({
    Expression<String>? id,
    Expression<String>? templateId,
    Expression<int>? version,
    Expression<String>? title,
    Expression<String>? content,
    Expression<String>? criteria,
    Expression<String>? taskType,
    Expression<int>? reward,
    Expression<String>? rulesVersion,
    Expression<String>? scheduleJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (templateId != null) 'template_id': templateId,
      if (version != null) 'version': version,
      if (title != null) 'title': title,
      if (content != null) 'content': content,
      if (criteria != null) 'criteria': criteria,
      if (taskType != null) 'task_type': taskType,
      if (reward != null) 'reward': reward,
      if (rulesVersion != null) 'rules_version': rulesVersion,
      if (scheduleJson != null) 'schedule_json': scheduleJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TaskVersionsCompanion copyWith({
    Value<String>? id,
    Value<String>? templateId,
    Value<int>? version,
    Value<String>? title,
    Value<String>? content,
    Value<String>? criteria,
    Value<String>? taskType,
    Value<int>? reward,
    Value<String>? rulesVersion,
    Value<String>? scheduleJson,
    Value<int>? rowid,
  }) {
    return TaskVersionsCompanion(
      id: id ?? this.id,
      templateId: templateId ?? this.templateId,
      version: version ?? this.version,
      title: title ?? this.title,
      content: content ?? this.content,
      criteria: criteria ?? this.criteria,
      taskType: taskType ?? this.taskType,
      reward: reward ?? this.reward,
      rulesVersion: rulesVersion ?? this.rulesVersion,
      scheduleJson: scheduleJson ?? this.scheduleJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (templateId.present) {
      map['template_id'] = Variable<String>(templateId.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (criteria.present) {
      map['criteria'] = Variable<String>(criteria.value);
    }
    if (taskType.present) {
      map['task_type'] = Variable<String>(taskType.value);
    }
    if (reward.present) {
      map['reward'] = Variable<int>(reward.value);
    }
    if (rulesVersion.present) {
      map['rules_version'] = Variable<String>(rulesVersion.value);
    }
    if (scheduleJson.present) {
      map['schedule_json'] = Variable<String>(scheduleJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TaskVersionsCompanion(')
          ..write('id: $id, ')
          ..write('templateId: $templateId, ')
          ..write('version: $version, ')
          ..write('title: $title, ')
          ..write('content: $content, ')
          ..write('criteria: $criteria, ')
          ..write('taskType: $taskType, ')
          ..write('reward: $reward, ')
          ..write('rulesVersion: $rulesVersion, ')
          ..write('scheduleJson: $scheduleJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class ProjectStages extends Table with TableInfo<ProjectStages, ProjectStage> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  ProjectStages(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  static const VerificationMeta _versionIdMeta = const VerificationMeta(
    'versionId',
  );
  late final GeneratedColumn<String> versionId = GeneratedColumn<String>(
    'version_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES task_versions(id)',
  );
  static const VerificationMeta _sequenceMeta = const VerificationMeta(
    'sequence',
  );
  late final GeneratedColumn<int> sequence = GeneratedColumn<int>(
    'sequence',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (sequence >= 1)',
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _criteriaMeta = const VerificationMeta(
    'criteria',
  );
  late final GeneratedColumn<String> criteria = GeneratedColumn<String>(
    'criteria',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _taskTypeMeta = const VerificationMeta(
    'taskType',
  );
  late final GeneratedColumn<String> taskType = GeneratedColumn<String>(
    'task_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _rewardMeta = const VerificationMeta('reward');
  late final GeneratedColumn<int> reward = GeneratedColumn<int>(
    'reward',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (reward BETWEEN 2 AND 5)',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    versionId,
    sequence,
    title,
    criteria,
    taskType,
    reward,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'project_stages';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProjectStage> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('version_id')) {
      context.handle(
        _versionIdMeta,
        versionId.isAcceptableOrUnknown(data['version_id']!, _versionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_versionIdMeta);
    }
    if (data.containsKey('sequence')) {
      context.handle(
        _sequenceMeta,
        sequence.isAcceptableOrUnknown(data['sequence']!, _sequenceMeta),
      );
    } else if (isInserting) {
      context.missing(_sequenceMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('criteria')) {
      context.handle(
        _criteriaMeta,
        criteria.isAcceptableOrUnknown(data['criteria']!, _criteriaMeta),
      );
    } else if (isInserting) {
      context.missing(_criteriaMeta);
    }
    if (data.containsKey('task_type')) {
      context.handle(
        _taskTypeMeta,
        taskType.isAcceptableOrUnknown(data['task_type']!, _taskTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_taskTypeMeta);
    }
    if (data.containsKey('reward')) {
      context.handle(
        _rewardMeta,
        reward.isAcceptableOrUnknown(data['reward']!, _rewardMeta),
      );
    } else if (isInserting) {
      context.missing(_rewardMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {versionId, sequence},
  ];
  @override
  ProjectStage map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProjectStage(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      versionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}version_id'],
      )!,
      sequence: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sequence'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      criteria: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}criteria'],
      )!,
      taskType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}task_type'],
      )!,
      reward: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reward'],
      )!,
    );
  }

  @override
  ProjectStages createAlias(String alias) {
    return ProjectStages(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints => const ['UNIQUE(version_id, sequence)'];
  @override
  bool get dontWriteConstraints => true;
}

class ProjectStage extends DataClass implements Insertable<ProjectStage> {
  final String id;
  final String versionId;
  final int sequence;
  final String title;
  final String criteria;
  final String taskType;
  final int reward;
  const ProjectStage({
    required this.id,
    required this.versionId,
    required this.sequence,
    required this.title,
    required this.criteria,
    required this.taskType,
    required this.reward,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['version_id'] = Variable<String>(versionId);
    map['sequence'] = Variable<int>(sequence);
    map['title'] = Variable<String>(title);
    map['criteria'] = Variable<String>(criteria);
    map['task_type'] = Variable<String>(taskType);
    map['reward'] = Variable<int>(reward);
    return map;
  }

  ProjectStagesCompanion toCompanion(bool nullToAbsent) {
    return ProjectStagesCompanion(
      id: Value(id),
      versionId: Value(versionId),
      sequence: Value(sequence),
      title: Value(title),
      criteria: Value(criteria),
      taskType: Value(taskType),
      reward: Value(reward),
    );
  }

  factory ProjectStage.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProjectStage(
      id: serializer.fromJson<String>(json['id']),
      versionId: serializer.fromJson<String>(json['version_id']),
      sequence: serializer.fromJson<int>(json['sequence']),
      title: serializer.fromJson<String>(json['title']),
      criteria: serializer.fromJson<String>(json['criteria']),
      taskType: serializer.fromJson<String>(json['task_type']),
      reward: serializer.fromJson<int>(json['reward']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'version_id': serializer.toJson<String>(versionId),
      'sequence': serializer.toJson<int>(sequence),
      'title': serializer.toJson<String>(title),
      'criteria': serializer.toJson<String>(criteria),
      'task_type': serializer.toJson<String>(taskType),
      'reward': serializer.toJson<int>(reward),
    };
  }

  ProjectStage copyWith({
    String? id,
    String? versionId,
    int? sequence,
    String? title,
    String? criteria,
    String? taskType,
    int? reward,
  }) => ProjectStage(
    id: id ?? this.id,
    versionId: versionId ?? this.versionId,
    sequence: sequence ?? this.sequence,
    title: title ?? this.title,
    criteria: criteria ?? this.criteria,
    taskType: taskType ?? this.taskType,
    reward: reward ?? this.reward,
  );
  ProjectStage copyWithCompanion(ProjectStagesCompanion data) {
    return ProjectStage(
      id: data.id.present ? data.id.value : this.id,
      versionId: data.versionId.present ? data.versionId.value : this.versionId,
      sequence: data.sequence.present ? data.sequence.value : this.sequence,
      title: data.title.present ? data.title.value : this.title,
      criteria: data.criteria.present ? data.criteria.value : this.criteria,
      taskType: data.taskType.present ? data.taskType.value : this.taskType,
      reward: data.reward.present ? data.reward.value : this.reward,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProjectStage(')
          ..write('id: $id, ')
          ..write('versionId: $versionId, ')
          ..write('sequence: $sequence, ')
          ..write('title: $title, ')
          ..write('criteria: $criteria, ')
          ..write('taskType: $taskType, ')
          ..write('reward: $reward')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, versionId, sequence, title, criteria, taskType, reward);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProjectStage &&
          other.id == this.id &&
          other.versionId == this.versionId &&
          other.sequence == this.sequence &&
          other.title == this.title &&
          other.criteria == this.criteria &&
          other.taskType == this.taskType &&
          other.reward == this.reward);
}

class ProjectStagesCompanion extends UpdateCompanion<ProjectStage> {
  final Value<String> id;
  final Value<String> versionId;
  final Value<int> sequence;
  final Value<String> title;
  final Value<String> criteria;
  final Value<String> taskType;
  final Value<int> reward;
  final Value<int> rowid;
  const ProjectStagesCompanion({
    this.id = const Value.absent(),
    this.versionId = const Value.absent(),
    this.sequence = const Value.absent(),
    this.title = const Value.absent(),
    this.criteria = const Value.absent(),
    this.taskType = const Value.absent(),
    this.reward = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProjectStagesCompanion.insert({
    required String id,
    required String versionId,
    required int sequence,
    required String title,
    required String criteria,
    required String taskType,
    required int reward,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       versionId = Value(versionId),
       sequence = Value(sequence),
       title = Value(title),
       criteria = Value(criteria),
       taskType = Value(taskType),
       reward = Value(reward);
  static Insertable<ProjectStage> custom({
    Expression<String>? id,
    Expression<String>? versionId,
    Expression<int>? sequence,
    Expression<String>? title,
    Expression<String>? criteria,
    Expression<String>? taskType,
    Expression<int>? reward,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (versionId != null) 'version_id': versionId,
      if (sequence != null) 'sequence': sequence,
      if (title != null) 'title': title,
      if (criteria != null) 'criteria': criteria,
      if (taskType != null) 'task_type': taskType,
      if (reward != null) 'reward': reward,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProjectStagesCompanion copyWith({
    Value<String>? id,
    Value<String>? versionId,
    Value<int>? sequence,
    Value<String>? title,
    Value<String>? criteria,
    Value<String>? taskType,
    Value<int>? reward,
    Value<int>? rowid,
  }) {
    return ProjectStagesCompanion(
      id: id ?? this.id,
      versionId: versionId ?? this.versionId,
      sequence: sequence ?? this.sequence,
      title: title ?? this.title,
      criteria: criteria ?? this.criteria,
      taskType: taskType ?? this.taskType,
      reward: reward ?? this.reward,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (versionId.present) {
      map['version_id'] = Variable<String>(versionId.value);
    }
    if (sequence.present) {
      map['sequence'] = Variable<int>(sequence.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (criteria.present) {
      map['criteria'] = Variable<String>(criteria.value);
    }
    if (taskType.present) {
      map['task_type'] = Variable<String>(taskType.value);
    }
    if (reward.present) {
      map['reward'] = Variable<int>(reward.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProjectStagesCompanion(')
          ..write('id: $id, ')
          ..write('versionId: $versionId, ')
          ..write('sequence: $sequence, ')
          ..write('title: $title, ')
          ..write('criteria: $criteria, ')
          ..write('taskType: $taskType, ')
          ..write('reward: $reward, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class TaskInstances extends Table with TableInfo<TaskInstances, TaskInstance> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  TaskInstances(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  static const VerificationMeta _instanceKeyMeta = const VerificationMeta(
    'instanceKey',
  );
  late final GeneratedColumn<String> instanceKey = GeneratedColumn<String>(
    'instance_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL UNIQUE',
  );
  static const VerificationMeta _templateIdMeta = const VerificationMeta(
    'templateId',
  );
  late final GeneratedColumn<String> templateId = GeneratedColumn<String>(
    'template_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES task_templates(id)',
  );
  static const VerificationMeta _versionIdMeta = const VerificationMeta(
    'versionId',
  );
  late final GeneratedColumn<String> versionId = GeneratedColumn<String>(
    'version_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES task_versions(id)',
  );
  static const VerificationMeta _stageIdMeta = const VerificationMeta(
    'stageId',
  );
  late final GeneratedColumn<String> stageId = GeneratedColumn<String>(
    'stage_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'REFERENCES project_stages(id)',
  );
  static const VerificationMeta _priorInstanceIdMeta = const VerificationMeta(
    'priorInstanceId',
  );
  late final GeneratedColumn<String> priorInstanceId = GeneratedColumn<String>(
    'prior_instance_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'REFERENCES task_instances(id)',
  );
  static const VerificationMeta _plannedDayMeta = const VerificationMeta(
    'plannedDay',
  );
  late final GeneratedColumn<String> plannedDay = GeneratedColumn<String>(
    'planned_day',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _slotMeta = const VerificationMeta('slot');
  late final GeneratedColumn<int> slot = GeneratedColumn<int>(
    'slot',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 1',
    defaultValue: const CustomExpression('1'),
  );
  static const VerificationMeta _dueDayMeta = const VerificationMeta('dueDay');
  late final GeneratedColumn<String> dueDay = GeneratedColumn<String>(
    'due_day',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
    'state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (state IN (\'OPEN\', \'SUBMITTED\', \'RETURNED\', \'APPROVED\', \'EXPIRED\', \'CANCELLED\', \'CORRECTED\', \'WAITING\'))',
  );
  static const VerificationMeta _actualDateMeta = const VerificationMeta(
    'actualDate',
  );
  late final GeneratedColumn<String> actualDate = GeneratedColumn<String>(
    'actual_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _approvedAtMeta = const VerificationMeta(
    'approvedAt',
  );
  late final GeneratedColumn<int> approvedAt = GeneratedColumn<int>(
    'approved_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _resolutionNoteMeta = const VerificationMeta(
    'resolutionNote',
  );
  late final GeneratedColumn<String> resolutionNote = GeneratedColumn<String>(
    'resolution_note',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT \'\'',
    defaultValue: const CustomExpression('\'\''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    instanceKey,
    templateId,
    versionId,
    stageId,
    priorInstanceId,
    plannedDay,
    slot,
    dueDay,
    state,
    actualDate,
    approvedAt,
    resolutionNote,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'task_instances';
  @override
  VerificationContext validateIntegrity(
    Insertable<TaskInstance> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('instance_key')) {
      context.handle(
        _instanceKeyMeta,
        instanceKey.isAcceptableOrUnknown(
          data['instance_key']!,
          _instanceKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_instanceKeyMeta);
    }
    if (data.containsKey('template_id')) {
      context.handle(
        _templateIdMeta,
        templateId.isAcceptableOrUnknown(data['template_id']!, _templateIdMeta),
      );
    } else if (isInserting) {
      context.missing(_templateIdMeta);
    }
    if (data.containsKey('version_id')) {
      context.handle(
        _versionIdMeta,
        versionId.isAcceptableOrUnknown(data['version_id']!, _versionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_versionIdMeta);
    }
    if (data.containsKey('stage_id')) {
      context.handle(
        _stageIdMeta,
        stageId.isAcceptableOrUnknown(data['stage_id']!, _stageIdMeta),
      );
    }
    if (data.containsKey('prior_instance_id')) {
      context.handle(
        _priorInstanceIdMeta,
        priorInstanceId.isAcceptableOrUnknown(
          data['prior_instance_id']!,
          _priorInstanceIdMeta,
        ),
      );
    }
    if (data.containsKey('planned_day')) {
      context.handle(
        _plannedDayMeta,
        plannedDay.isAcceptableOrUnknown(data['planned_day']!, _plannedDayMeta),
      );
    } else if (isInserting) {
      context.missing(_plannedDayMeta);
    }
    if (data.containsKey('slot')) {
      context.handle(
        _slotMeta,
        slot.isAcceptableOrUnknown(data['slot']!, _slotMeta),
      );
    }
    if (data.containsKey('due_day')) {
      context.handle(
        _dueDayMeta,
        dueDay.isAcceptableOrUnknown(data['due_day']!, _dueDayMeta),
      );
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    } else if (isInserting) {
      context.missing(_stateMeta);
    }
    if (data.containsKey('actual_date')) {
      context.handle(
        _actualDateMeta,
        actualDate.isAcceptableOrUnknown(data['actual_date']!, _actualDateMeta),
      );
    }
    if (data.containsKey('approved_at')) {
      context.handle(
        _approvedAtMeta,
        approvedAt.isAcceptableOrUnknown(data['approved_at']!, _approvedAtMeta),
      );
    }
    if (data.containsKey('resolution_note')) {
      context.handle(
        _resolutionNoteMeta,
        resolutionNote.isAcceptableOrUnknown(
          data['resolution_note']!,
          _resolutionNoteMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TaskInstance map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TaskInstance(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      instanceKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}instance_key'],
      )!,
      templateId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}template_id'],
      )!,
      versionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}version_id'],
      )!,
      stageId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stage_id'],
      ),
      priorInstanceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}prior_instance_id'],
      ),
      plannedDay: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}planned_day'],
      )!,
      slot: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}slot'],
      )!,
      dueDay: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}due_day'],
      ),
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state'],
      )!,
      actualDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}actual_date'],
      ),
      approvedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}approved_at'],
      ),
      resolutionNote: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}resolution_note'],
      )!,
    );
  }

  @override
  TaskInstances createAlias(String alias) {
    return TaskInstances(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class TaskInstance extends DataClass implements Insertable<TaskInstance> {
  final String id;
  final String instanceKey;
  final String templateId;
  final String versionId;
  final String? stageId;
  final String? priorInstanceId;
  final String plannedDay;
  final int slot;
  final String? dueDay;
  final String state;
  final String? actualDate;
  final int? approvedAt;
  final String resolutionNote;
  const TaskInstance({
    required this.id,
    required this.instanceKey,
    required this.templateId,
    required this.versionId,
    this.stageId,
    this.priorInstanceId,
    required this.plannedDay,
    required this.slot,
    this.dueDay,
    required this.state,
    this.actualDate,
    this.approvedAt,
    required this.resolutionNote,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['instance_key'] = Variable<String>(instanceKey);
    map['template_id'] = Variable<String>(templateId);
    map['version_id'] = Variable<String>(versionId);
    if (!nullToAbsent || stageId != null) {
      map['stage_id'] = Variable<String>(stageId);
    }
    if (!nullToAbsent || priorInstanceId != null) {
      map['prior_instance_id'] = Variable<String>(priorInstanceId);
    }
    map['planned_day'] = Variable<String>(plannedDay);
    map['slot'] = Variable<int>(slot);
    if (!nullToAbsent || dueDay != null) {
      map['due_day'] = Variable<String>(dueDay);
    }
    map['state'] = Variable<String>(state);
    if (!nullToAbsent || actualDate != null) {
      map['actual_date'] = Variable<String>(actualDate);
    }
    if (!nullToAbsent || approvedAt != null) {
      map['approved_at'] = Variable<int>(approvedAt);
    }
    map['resolution_note'] = Variable<String>(resolutionNote);
    return map;
  }

  TaskInstancesCompanion toCompanion(bool nullToAbsent) {
    return TaskInstancesCompanion(
      id: Value(id),
      instanceKey: Value(instanceKey),
      templateId: Value(templateId),
      versionId: Value(versionId),
      stageId: stageId == null && nullToAbsent
          ? const Value.absent()
          : Value(stageId),
      priorInstanceId: priorInstanceId == null && nullToAbsent
          ? const Value.absent()
          : Value(priorInstanceId),
      plannedDay: Value(plannedDay),
      slot: Value(slot),
      dueDay: dueDay == null && nullToAbsent
          ? const Value.absent()
          : Value(dueDay),
      state: Value(state),
      actualDate: actualDate == null && nullToAbsent
          ? const Value.absent()
          : Value(actualDate),
      approvedAt: approvedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(approvedAt),
      resolutionNote: Value(resolutionNote),
    );
  }

  factory TaskInstance.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TaskInstance(
      id: serializer.fromJson<String>(json['id']),
      instanceKey: serializer.fromJson<String>(json['instance_key']),
      templateId: serializer.fromJson<String>(json['template_id']),
      versionId: serializer.fromJson<String>(json['version_id']),
      stageId: serializer.fromJson<String?>(json['stage_id']),
      priorInstanceId: serializer.fromJson<String?>(json['prior_instance_id']),
      plannedDay: serializer.fromJson<String>(json['planned_day']),
      slot: serializer.fromJson<int>(json['slot']),
      dueDay: serializer.fromJson<String?>(json['due_day']),
      state: serializer.fromJson<String>(json['state']),
      actualDate: serializer.fromJson<String?>(json['actual_date']),
      approvedAt: serializer.fromJson<int?>(json['approved_at']),
      resolutionNote: serializer.fromJson<String>(json['resolution_note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'instance_key': serializer.toJson<String>(instanceKey),
      'template_id': serializer.toJson<String>(templateId),
      'version_id': serializer.toJson<String>(versionId),
      'stage_id': serializer.toJson<String?>(stageId),
      'prior_instance_id': serializer.toJson<String?>(priorInstanceId),
      'planned_day': serializer.toJson<String>(plannedDay),
      'slot': serializer.toJson<int>(slot),
      'due_day': serializer.toJson<String?>(dueDay),
      'state': serializer.toJson<String>(state),
      'actual_date': serializer.toJson<String?>(actualDate),
      'approved_at': serializer.toJson<int?>(approvedAt),
      'resolution_note': serializer.toJson<String>(resolutionNote),
    };
  }

  TaskInstance copyWith({
    String? id,
    String? instanceKey,
    String? templateId,
    String? versionId,
    Value<String?> stageId = const Value.absent(),
    Value<String?> priorInstanceId = const Value.absent(),
    String? plannedDay,
    int? slot,
    Value<String?> dueDay = const Value.absent(),
    String? state,
    Value<String?> actualDate = const Value.absent(),
    Value<int?> approvedAt = const Value.absent(),
    String? resolutionNote,
  }) => TaskInstance(
    id: id ?? this.id,
    instanceKey: instanceKey ?? this.instanceKey,
    templateId: templateId ?? this.templateId,
    versionId: versionId ?? this.versionId,
    stageId: stageId.present ? stageId.value : this.stageId,
    priorInstanceId: priorInstanceId.present
        ? priorInstanceId.value
        : this.priorInstanceId,
    plannedDay: plannedDay ?? this.plannedDay,
    slot: slot ?? this.slot,
    dueDay: dueDay.present ? dueDay.value : this.dueDay,
    state: state ?? this.state,
    actualDate: actualDate.present ? actualDate.value : this.actualDate,
    approvedAt: approvedAt.present ? approvedAt.value : this.approvedAt,
    resolutionNote: resolutionNote ?? this.resolutionNote,
  );
  TaskInstance copyWithCompanion(TaskInstancesCompanion data) {
    return TaskInstance(
      id: data.id.present ? data.id.value : this.id,
      instanceKey: data.instanceKey.present
          ? data.instanceKey.value
          : this.instanceKey,
      templateId: data.templateId.present
          ? data.templateId.value
          : this.templateId,
      versionId: data.versionId.present ? data.versionId.value : this.versionId,
      stageId: data.stageId.present ? data.stageId.value : this.stageId,
      priorInstanceId: data.priorInstanceId.present
          ? data.priorInstanceId.value
          : this.priorInstanceId,
      plannedDay: data.plannedDay.present
          ? data.plannedDay.value
          : this.plannedDay,
      slot: data.slot.present ? data.slot.value : this.slot,
      dueDay: data.dueDay.present ? data.dueDay.value : this.dueDay,
      state: data.state.present ? data.state.value : this.state,
      actualDate: data.actualDate.present
          ? data.actualDate.value
          : this.actualDate,
      approvedAt: data.approvedAt.present
          ? data.approvedAt.value
          : this.approvedAt,
      resolutionNote: data.resolutionNote.present
          ? data.resolutionNote.value
          : this.resolutionNote,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TaskInstance(')
          ..write('id: $id, ')
          ..write('instanceKey: $instanceKey, ')
          ..write('templateId: $templateId, ')
          ..write('versionId: $versionId, ')
          ..write('stageId: $stageId, ')
          ..write('priorInstanceId: $priorInstanceId, ')
          ..write('plannedDay: $plannedDay, ')
          ..write('slot: $slot, ')
          ..write('dueDay: $dueDay, ')
          ..write('state: $state, ')
          ..write('actualDate: $actualDate, ')
          ..write('approvedAt: $approvedAt, ')
          ..write('resolutionNote: $resolutionNote')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    instanceKey,
    templateId,
    versionId,
    stageId,
    priorInstanceId,
    plannedDay,
    slot,
    dueDay,
    state,
    actualDate,
    approvedAt,
    resolutionNote,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TaskInstance &&
          other.id == this.id &&
          other.instanceKey == this.instanceKey &&
          other.templateId == this.templateId &&
          other.versionId == this.versionId &&
          other.stageId == this.stageId &&
          other.priorInstanceId == this.priorInstanceId &&
          other.plannedDay == this.plannedDay &&
          other.slot == this.slot &&
          other.dueDay == this.dueDay &&
          other.state == this.state &&
          other.actualDate == this.actualDate &&
          other.approvedAt == this.approvedAt &&
          other.resolutionNote == this.resolutionNote);
}

class TaskInstancesCompanion extends UpdateCompanion<TaskInstance> {
  final Value<String> id;
  final Value<String> instanceKey;
  final Value<String> templateId;
  final Value<String> versionId;
  final Value<String?> stageId;
  final Value<String?> priorInstanceId;
  final Value<String> plannedDay;
  final Value<int> slot;
  final Value<String?> dueDay;
  final Value<String> state;
  final Value<String?> actualDate;
  final Value<int?> approvedAt;
  final Value<String> resolutionNote;
  final Value<int> rowid;
  const TaskInstancesCompanion({
    this.id = const Value.absent(),
    this.instanceKey = const Value.absent(),
    this.templateId = const Value.absent(),
    this.versionId = const Value.absent(),
    this.stageId = const Value.absent(),
    this.priorInstanceId = const Value.absent(),
    this.plannedDay = const Value.absent(),
    this.slot = const Value.absent(),
    this.dueDay = const Value.absent(),
    this.state = const Value.absent(),
    this.actualDate = const Value.absent(),
    this.approvedAt = const Value.absent(),
    this.resolutionNote = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TaskInstancesCompanion.insert({
    required String id,
    required String instanceKey,
    required String templateId,
    required String versionId,
    this.stageId = const Value.absent(),
    this.priorInstanceId = const Value.absent(),
    required String plannedDay,
    this.slot = const Value.absent(),
    this.dueDay = const Value.absent(),
    required String state,
    this.actualDate = const Value.absent(),
    this.approvedAt = const Value.absent(),
    this.resolutionNote = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       instanceKey = Value(instanceKey),
       templateId = Value(templateId),
       versionId = Value(versionId),
       plannedDay = Value(plannedDay),
       state = Value(state);
  static Insertable<TaskInstance> custom({
    Expression<String>? id,
    Expression<String>? instanceKey,
    Expression<String>? templateId,
    Expression<String>? versionId,
    Expression<String>? stageId,
    Expression<String>? priorInstanceId,
    Expression<String>? plannedDay,
    Expression<int>? slot,
    Expression<String>? dueDay,
    Expression<String>? state,
    Expression<String>? actualDate,
    Expression<int>? approvedAt,
    Expression<String>? resolutionNote,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (instanceKey != null) 'instance_key': instanceKey,
      if (templateId != null) 'template_id': templateId,
      if (versionId != null) 'version_id': versionId,
      if (stageId != null) 'stage_id': stageId,
      if (priorInstanceId != null) 'prior_instance_id': priorInstanceId,
      if (plannedDay != null) 'planned_day': plannedDay,
      if (slot != null) 'slot': slot,
      if (dueDay != null) 'due_day': dueDay,
      if (state != null) 'state': state,
      if (actualDate != null) 'actual_date': actualDate,
      if (approvedAt != null) 'approved_at': approvedAt,
      if (resolutionNote != null) 'resolution_note': resolutionNote,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TaskInstancesCompanion copyWith({
    Value<String>? id,
    Value<String>? instanceKey,
    Value<String>? templateId,
    Value<String>? versionId,
    Value<String?>? stageId,
    Value<String?>? priorInstanceId,
    Value<String>? plannedDay,
    Value<int>? slot,
    Value<String?>? dueDay,
    Value<String>? state,
    Value<String?>? actualDate,
    Value<int?>? approvedAt,
    Value<String>? resolutionNote,
    Value<int>? rowid,
  }) {
    return TaskInstancesCompanion(
      id: id ?? this.id,
      instanceKey: instanceKey ?? this.instanceKey,
      templateId: templateId ?? this.templateId,
      versionId: versionId ?? this.versionId,
      stageId: stageId ?? this.stageId,
      priorInstanceId: priorInstanceId ?? this.priorInstanceId,
      plannedDay: plannedDay ?? this.plannedDay,
      slot: slot ?? this.slot,
      dueDay: dueDay ?? this.dueDay,
      state: state ?? this.state,
      actualDate: actualDate ?? this.actualDate,
      approvedAt: approvedAt ?? this.approvedAt,
      resolutionNote: resolutionNote ?? this.resolutionNote,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (instanceKey.present) {
      map['instance_key'] = Variable<String>(instanceKey.value);
    }
    if (templateId.present) {
      map['template_id'] = Variable<String>(templateId.value);
    }
    if (versionId.present) {
      map['version_id'] = Variable<String>(versionId.value);
    }
    if (stageId.present) {
      map['stage_id'] = Variable<String>(stageId.value);
    }
    if (priorInstanceId.present) {
      map['prior_instance_id'] = Variable<String>(priorInstanceId.value);
    }
    if (plannedDay.present) {
      map['planned_day'] = Variable<String>(plannedDay.value);
    }
    if (slot.present) {
      map['slot'] = Variable<int>(slot.value);
    }
    if (dueDay.present) {
      map['due_day'] = Variable<String>(dueDay.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (actualDate.present) {
      map['actual_date'] = Variable<String>(actualDate.value);
    }
    if (approvedAt.present) {
      map['approved_at'] = Variable<int>(approvedAt.value);
    }
    if (resolutionNote.present) {
      map['resolution_note'] = Variable<String>(resolutionNote.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TaskInstancesCompanion(')
          ..write('id: $id, ')
          ..write('instanceKey: $instanceKey, ')
          ..write('templateId: $templateId, ')
          ..write('versionId: $versionId, ')
          ..write('stageId: $stageId, ')
          ..write('priorInstanceId: $priorInstanceId, ')
          ..write('plannedDay: $plannedDay, ')
          ..write('slot: $slot, ')
          ..write('dueDay: $dueDay, ')
          ..write('state: $state, ')
          ..write('actualDate: $actualDate, ')
          ..write('approvedAt: $approvedAt, ')
          ..write('resolutionNote: $resolutionNote, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class Submissions extends Table with TableInfo<Submissions, Submission> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Submissions(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  static const VerificationMeta _instanceIdMeta = const VerificationMeta(
    'instanceId',
  );
  late final GeneratedColumn<String> instanceId = GeneratedColumn<String>(
    'instance_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES task_instances(id)',
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _actualDateMeta = const VerificationMeta(
    'actualDate',
  );
  late final GeneratedColumn<String> actualDate = GeneratedColumn<String>(
    'actual_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    instanceId,
    note,
    actualDate,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'submissions';
  @override
  VerificationContext validateIntegrity(
    Insertable<Submission> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('instance_id')) {
      context.handle(
        _instanceIdMeta,
        instanceId.isAcceptableOrUnknown(data['instance_id']!, _instanceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_instanceIdMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    } else if (isInserting) {
      context.missing(_noteMeta);
    }
    if (data.containsKey('actual_date')) {
      context.handle(
        _actualDateMeta,
        actualDate.isAcceptableOrUnknown(data['actual_date']!, _actualDateMeta),
      );
    } else if (isInserting) {
      context.missing(_actualDateMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Submission map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Submission(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      instanceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}instance_id'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      )!,
      actualDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}actual_date'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  Submissions createAlias(String alias) {
    return Submissions(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class Submission extends DataClass implements Insertable<Submission> {
  final String id;
  final String instanceId;
  final String note;
  final String actualDate;
  final int createdAt;
  const Submission({
    required this.id,
    required this.instanceId,
    required this.note,
    required this.actualDate,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['instance_id'] = Variable<String>(instanceId);
    map['note'] = Variable<String>(note);
    map['actual_date'] = Variable<String>(actualDate);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  SubmissionsCompanion toCompanion(bool nullToAbsent) {
    return SubmissionsCompanion(
      id: Value(id),
      instanceId: Value(instanceId),
      note: Value(note),
      actualDate: Value(actualDate),
      createdAt: Value(createdAt),
    );
  }

  factory Submission.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Submission(
      id: serializer.fromJson<String>(json['id']),
      instanceId: serializer.fromJson<String>(json['instance_id']),
      note: serializer.fromJson<String>(json['note']),
      actualDate: serializer.fromJson<String>(json['actual_date']),
      createdAt: serializer.fromJson<int>(json['created_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'instance_id': serializer.toJson<String>(instanceId),
      'note': serializer.toJson<String>(note),
      'actual_date': serializer.toJson<String>(actualDate),
      'created_at': serializer.toJson<int>(createdAt),
    };
  }

  Submission copyWith({
    String? id,
    String? instanceId,
    String? note,
    String? actualDate,
    int? createdAt,
  }) => Submission(
    id: id ?? this.id,
    instanceId: instanceId ?? this.instanceId,
    note: note ?? this.note,
    actualDate: actualDate ?? this.actualDate,
    createdAt: createdAt ?? this.createdAt,
  );
  Submission copyWithCompanion(SubmissionsCompanion data) {
    return Submission(
      id: data.id.present ? data.id.value : this.id,
      instanceId: data.instanceId.present
          ? data.instanceId.value
          : this.instanceId,
      note: data.note.present ? data.note.value : this.note,
      actualDate: data.actualDate.present
          ? data.actualDate.value
          : this.actualDate,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Submission(')
          ..write('id: $id, ')
          ..write('instanceId: $instanceId, ')
          ..write('note: $note, ')
          ..write('actualDate: $actualDate, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, instanceId, note, actualDate, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Submission &&
          other.id == this.id &&
          other.instanceId == this.instanceId &&
          other.note == this.note &&
          other.actualDate == this.actualDate &&
          other.createdAt == this.createdAt);
}

class SubmissionsCompanion extends UpdateCompanion<Submission> {
  final Value<String> id;
  final Value<String> instanceId;
  final Value<String> note;
  final Value<String> actualDate;
  final Value<int> createdAt;
  final Value<int> rowid;
  const SubmissionsCompanion({
    this.id = const Value.absent(),
    this.instanceId = const Value.absent(),
    this.note = const Value.absent(),
    this.actualDate = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SubmissionsCompanion.insert({
    required String id,
    required String instanceId,
    required String note,
    required String actualDate,
    required int createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       instanceId = Value(instanceId),
       note = Value(note),
       actualDate = Value(actualDate),
       createdAt = Value(createdAt);
  static Insertable<Submission> custom({
    Expression<String>? id,
    Expression<String>? instanceId,
    Expression<String>? note,
    Expression<String>? actualDate,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (instanceId != null) 'instance_id': instanceId,
      if (note != null) 'note': note,
      if (actualDate != null) 'actual_date': actualDate,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SubmissionsCompanion copyWith({
    Value<String>? id,
    Value<String>? instanceId,
    Value<String>? note,
    Value<String>? actualDate,
    Value<int>? createdAt,
    Value<int>? rowid,
  }) {
    return SubmissionsCompanion(
      id: id ?? this.id,
      instanceId: instanceId ?? this.instanceId,
      note: note ?? this.note,
      actualDate: actualDate ?? this.actualDate,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (instanceId.present) {
      map['instance_id'] = Variable<String>(instanceId.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (actualDate.present) {
      map['actual_date'] = Variable<String>(actualDate.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SubmissionsCompanion(')
          ..write('id: $id, ')
          ..write('instanceId: $instanceId, ')
          ..write('note: $note, ')
          ..write('actualDate: $actualDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class Completions extends Table with TableInfo<Completions, Completion> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Completions(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  static const VerificationMeta _instanceIdMeta = const VerificationMeta(
    'instanceId',
  );
  late final GeneratedColumn<String> instanceId = GeneratedColumn<String>(
    'instance_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL UNIQUE REFERENCES task_instances(id)',
  );
  static const VerificationMeta _actualDateMeta = const VerificationMeta(
    'actualDate',
  );
  late final GeneratedColumn<String> actualDate = GeneratedColumn<String>(
    'actual_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _feedbackMeta = const VerificationMeta(
    'feedback',
  );
  late final GeneratedColumn<String> feedback = GeneratedColumn<String>(
    'feedback',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _isValidMeta = const VerificationMeta(
    'isValid',
  );
  late final GeneratedColumn<int> isValid = GeneratedColumn<int>(
    'is_valid',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 1 CHECK (is_valid IN (0, 1))',
    defaultValue: const CustomExpression('1'),
  );
  static const VerificationMeta _approvalCommandIdMeta = const VerificationMeta(
    'approvalCommandId',
  );
  late final GeneratedColumn<String> approvalCommandId =
      GeneratedColumn<String>(
        'approval_command_id',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
        $customConstraints: 'NOT NULL UNIQUE',
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    instanceId,
    actualDate,
    feedback,
    isValid,
    approvalCommandId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'completions';
  @override
  VerificationContext validateIntegrity(
    Insertable<Completion> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('instance_id')) {
      context.handle(
        _instanceIdMeta,
        instanceId.isAcceptableOrUnknown(data['instance_id']!, _instanceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_instanceIdMeta);
    }
    if (data.containsKey('actual_date')) {
      context.handle(
        _actualDateMeta,
        actualDate.isAcceptableOrUnknown(data['actual_date']!, _actualDateMeta),
      );
    } else if (isInserting) {
      context.missing(_actualDateMeta);
    }
    if (data.containsKey('feedback')) {
      context.handle(
        _feedbackMeta,
        feedback.isAcceptableOrUnknown(data['feedback']!, _feedbackMeta),
      );
    } else if (isInserting) {
      context.missing(_feedbackMeta);
    }
    if (data.containsKey('is_valid')) {
      context.handle(
        _isValidMeta,
        isValid.isAcceptableOrUnknown(data['is_valid']!, _isValidMeta),
      );
    }
    if (data.containsKey('approval_command_id')) {
      context.handle(
        _approvalCommandIdMeta,
        approvalCommandId.isAcceptableOrUnknown(
          data['approval_command_id']!,
          _approvalCommandIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_approvalCommandIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Completion map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Completion(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      instanceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}instance_id'],
      )!,
      actualDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}actual_date'],
      )!,
      feedback: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}feedback'],
      )!,
      isValid: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}is_valid'],
      )!,
      approvalCommandId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}approval_command_id'],
      )!,
    );
  }

  @override
  Completions createAlias(String alias) {
    return Completions(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class Completion extends DataClass implements Insertable<Completion> {
  final String id;
  final String instanceId;
  final String actualDate;
  final String feedback;
  final int isValid;
  final String approvalCommandId;
  const Completion({
    required this.id,
    required this.instanceId,
    required this.actualDate,
    required this.feedback,
    required this.isValid,
    required this.approvalCommandId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['instance_id'] = Variable<String>(instanceId);
    map['actual_date'] = Variable<String>(actualDate);
    map['feedback'] = Variable<String>(feedback);
    map['is_valid'] = Variable<int>(isValid);
    map['approval_command_id'] = Variable<String>(approvalCommandId);
    return map;
  }

  CompletionsCompanion toCompanion(bool nullToAbsent) {
    return CompletionsCompanion(
      id: Value(id),
      instanceId: Value(instanceId),
      actualDate: Value(actualDate),
      feedback: Value(feedback),
      isValid: Value(isValid),
      approvalCommandId: Value(approvalCommandId),
    );
  }

  factory Completion.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Completion(
      id: serializer.fromJson<String>(json['id']),
      instanceId: serializer.fromJson<String>(json['instance_id']),
      actualDate: serializer.fromJson<String>(json['actual_date']),
      feedback: serializer.fromJson<String>(json['feedback']),
      isValid: serializer.fromJson<int>(json['is_valid']),
      approvalCommandId: serializer.fromJson<String>(
        json['approval_command_id'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'instance_id': serializer.toJson<String>(instanceId),
      'actual_date': serializer.toJson<String>(actualDate),
      'feedback': serializer.toJson<String>(feedback),
      'is_valid': serializer.toJson<int>(isValid),
      'approval_command_id': serializer.toJson<String>(approvalCommandId),
    };
  }

  Completion copyWith({
    String? id,
    String? instanceId,
    String? actualDate,
    String? feedback,
    int? isValid,
    String? approvalCommandId,
  }) => Completion(
    id: id ?? this.id,
    instanceId: instanceId ?? this.instanceId,
    actualDate: actualDate ?? this.actualDate,
    feedback: feedback ?? this.feedback,
    isValid: isValid ?? this.isValid,
    approvalCommandId: approvalCommandId ?? this.approvalCommandId,
  );
  Completion copyWithCompanion(CompletionsCompanion data) {
    return Completion(
      id: data.id.present ? data.id.value : this.id,
      instanceId: data.instanceId.present
          ? data.instanceId.value
          : this.instanceId,
      actualDate: data.actualDate.present
          ? data.actualDate.value
          : this.actualDate,
      feedback: data.feedback.present ? data.feedback.value : this.feedback,
      isValid: data.isValid.present ? data.isValid.value : this.isValid,
      approvalCommandId: data.approvalCommandId.present
          ? data.approvalCommandId.value
          : this.approvalCommandId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Completion(')
          ..write('id: $id, ')
          ..write('instanceId: $instanceId, ')
          ..write('actualDate: $actualDate, ')
          ..write('feedback: $feedback, ')
          ..write('isValid: $isValid, ')
          ..write('approvalCommandId: $approvalCommandId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    instanceId,
    actualDate,
    feedback,
    isValid,
    approvalCommandId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Completion &&
          other.id == this.id &&
          other.instanceId == this.instanceId &&
          other.actualDate == this.actualDate &&
          other.feedback == this.feedback &&
          other.isValid == this.isValid &&
          other.approvalCommandId == this.approvalCommandId);
}

class CompletionsCompanion extends UpdateCompanion<Completion> {
  final Value<String> id;
  final Value<String> instanceId;
  final Value<String> actualDate;
  final Value<String> feedback;
  final Value<int> isValid;
  final Value<String> approvalCommandId;
  final Value<int> rowid;
  const CompletionsCompanion({
    this.id = const Value.absent(),
    this.instanceId = const Value.absent(),
    this.actualDate = const Value.absent(),
    this.feedback = const Value.absent(),
    this.isValid = const Value.absent(),
    this.approvalCommandId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CompletionsCompanion.insert({
    required String id,
    required String instanceId,
    required String actualDate,
    required String feedback,
    this.isValid = const Value.absent(),
    required String approvalCommandId,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       instanceId = Value(instanceId),
       actualDate = Value(actualDate),
       feedback = Value(feedback),
       approvalCommandId = Value(approvalCommandId);
  static Insertable<Completion> custom({
    Expression<String>? id,
    Expression<String>? instanceId,
    Expression<String>? actualDate,
    Expression<String>? feedback,
    Expression<int>? isValid,
    Expression<String>? approvalCommandId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (instanceId != null) 'instance_id': instanceId,
      if (actualDate != null) 'actual_date': actualDate,
      if (feedback != null) 'feedback': feedback,
      if (isValid != null) 'is_valid': isValid,
      if (approvalCommandId != null) 'approval_command_id': approvalCommandId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CompletionsCompanion copyWith({
    Value<String>? id,
    Value<String>? instanceId,
    Value<String>? actualDate,
    Value<String>? feedback,
    Value<int>? isValid,
    Value<String>? approvalCommandId,
    Value<int>? rowid,
  }) {
    return CompletionsCompanion(
      id: id ?? this.id,
      instanceId: instanceId ?? this.instanceId,
      actualDate: actualDate ?? this.actualDate,
      feedback: feedback ?? this.feedback,
      isValid: isValid ?? this.isValid,
      approvalCommandId: approvalCommandId ?? this.approvalCommandId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (instanceId.present) {
      map['instance_id'] = Variable<String>(instanceId.value);
    }
    if (actualDate.present) {
      map['actual_date'] = Variable<String>(actualDate.value);
    }
    if (feedback.present) {
      map['feedback'] = Variable<String>(feedback.value);
    }
    if (isValid.present) {
      map['is_valid'] = Variable<int>(isValid.value);
    }
    if (approvalCommandId.present) {
      map['approval_command_id'] = Variable<String>(approvalCommandId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CompletionsCompanion(')
          ..write('id: $id, ')
          ..write('instanceId: $instanceId, ')
          ..write('actualDate: $actualDate, ')
          ..write('feedback: $feedback, ')
          ..write('isValid: $isValid, ')
          ..write('approvalCommandId: $approvalCommandId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class LedgerEntries extends Table with TableInfo<LedgerEntries, LedgerEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  LedgerEntries(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
    'account_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES accounts(id)',
  );
  static const VerificationMeta _deltaMeta = const VerificationMeta('delta');
  late final GeneratedColumn<int> delta = GeneratedColumn<int>(
    'delta',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _balanceAfterMeta = const VerificationMeta(
    'balanceAfter',
  );
  late final GeneratedColumn<int> balanceAfter = GeneratedColumn<int>(
    'balance_after',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (balance_after >= 0)',
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (kind IN (\'reward\', \'penalty\', \'penalty_reversal\', \'purchase\', \'refund\', \'correction\'))',
  );
  static const VerificationMeta _sourceKeyMeta = const VerificationMeta(
    'sourceKey',
  );
  late final GeneratedColumn<String> sourceKey = GeneratedColumn<String>(
    'source_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL UNIQUE',
  );
  static const VerificationMeta _reversalOfMeta = const VerificationMeta(
    'reversalOf',
  );
  late final GeneratedColumn<String> reversalOf = GeneratedColumn<String>(
    'reversal_of',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'UNIQUE REFERENCES ledger_entries(id)',
  );
  static const VerificationMeta _actualDateMeta = const VerificationMeta(
    'actualDate',
  );
  late final GeneratedColumn<String> actualDate = GeneratedColumn<String>(
    'actual_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _postedDayMeta = const VerificationMeta(
    'postedDay',
  );
  late final GeneratedColumn<String> postedDay = GeneratedColumn<String>(
    'posted_day',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _commandIdMeta = const VerificationMeta(
    'commandId',
  );
  late final GeneratedColumn<String> commandId = GeneratedColumn<String>(
    'command_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    accountId,
    delta,
    balanceAfter,
    kind,
    sourceKey,
    reversalOf,
    actualDate,
    postedDay,
    createdAt,
    commandId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ledger_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<LedgerEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('delta')) {
      context.handle(
        _deltaMeta,
        delta.isAcceptableOrUnknown(data['delta']!, _deltaMeta),
      );
    } else if (isInserting) {
      context.missing(_deltaMeta);
    }
    if (data.containsKey('balance_after')) {
      context.handle(
        _balanceAfterMeta,
        balanceAfter.isAcceptableOrUnknown(
          data['balance_after']!,
          _balanceAfterMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_balanceAfterMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('source_key')) {
      context.handle(
        _sourceKeyMeta,
        sourceKey.isAcceptableOrUnknown(data['source_key']!, _sourceKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceKeyMeta);
    }
    if (data.containsKey('reversal_of')) {
      context.handle(
        _reversalOfMeta,
        reversalOf.isAcceptableOrUnknown(data['reversal_of']!, _reversalOfMeta),
      );
    }
    if (data.containsKey('actual_date')) {
      context.handle(
        _actualDateMeta,
        actualDate.isAcceptableOrUnknown(data['actual_date']!, _actualDateMeta),
      );
    } else if (isInserting) {
      context.missing(_actualDateMeta);
    }
    if (data.containsKey('posted_day')) {
      context.handle(
        _postedDayMeta,
        postedDay.isAcceptableOrUnknown(data['posted_day']!, _postedDayMeta),
      );
    } else if (isInserting) {
      context.missing(_postedDayMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('command_id')) {
      context.handle(
        _commandIdMeta,
        commandId.isAcceptableOrUnknown(data['command_id']!, _commandIdMeta),
      );
    } else if (isInserting) {
      context.missing(_commandIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LedgerEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LedgerEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_id'],
      )!,
      delta: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}delta'],
      )!,
      balanceAfter: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}balance_after'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      sourceKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_key'],
      )!,
      reversalOf: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reversal_of'],
      ),
      actualDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}actual_date'],
      )!,
      postedDay: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}posted_day'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      commandId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}command_id'],
      )!,
    );
  }

  @override
  LedgerEntries createAlias(String alias) {
    return LedgerEntries(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class LedgerEntry extends DataClass implements Insertable<LedgerEntry> {
  final String id;
  final String accountId;
  final int delta;
  final int balanceAfter;
  final String kind;
  final String sourceKey;
  final String? reversalOf;
  final String actualDate;
  final String postedDay;
  final int createdAt;
  final String commandId;
  const LedgerEntry({
    required this.id,
    required this.accountId,
    required this.delta,
    required this.balanceAfter,
    required this.kind,
    required this.sourceKey,
    this.reversalOf,
    required this.actualDate,
    required this.postedDay,
    required this.createdAt,
    required this.commandId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['account_id'] = Variable<String>(accountId);
    map['delta'] = Variable<int>(delta);
    map['balance_after'] = Variable<int>(balanceAfter);
    map['kind'] = Variable<String>(kind);
    map['source_key'] = Variable<String>(sourceKey);
    if (!nullToAbsent || reversalOf != null) {
      map['reversal_of'] = Variable<String>(reversalOf);
    }
    map['actual_date'] = Variable<String>(actualDate);
    map['posted_day'] = Variable<String>(postedDay);
    map['created_at'] = Variable<int>(createdAt);
    map['command_id'] = Variable<String>(commandId);
    return map;
  }

  LedgerEntriesCompanion toCompanion(bool nullToAbsent) {
    return LedgerEntriesCompanion(
      id: Value(id),
      accountId: Value(accountId),
      delta: Value(delta),
      balanceAfter: Value(balanceAfter),
      kind: Value(kind),
      sourceKey: Value(sourceKey),
      reversalOf: reversalOf == null && nullToAbsent
          ? const Value.absent()
          : Value(reversalOf),
      actualDate: Value(actualDate),
      postedDay: Value(postedDay),
      createdAt: Value(createdAt),
      commandId: Value(commandId),
    );
  }

  factory LedgerEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LedgerEntry(
      id: serializer.fromJson<String>(json['id']),
      accountId: serializer.fromJson<String>(json['account_id']),
      delta: serializer.fromJson<int>(json['delta']),
      balanceAfter: serializer.fromJson<int>(json['balance_after']),
      kind: serializer.fromJson<String>(json['kind']),
      sourceKey: serializer.fromJson<String>(json['source_key']),
      reversalOf: serializer.fromJson<String?>(json['reversal_of']),
      actualDate: serializer.fromJson<String>(json['actual_date']),
      postedDay: serializer.fromJson<String>(json['posted_day']),
      createdAt: serializer.fromJson<int>(json['created_at']),
      commandId: serializer.fromJson<String>(json['command_id']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'account_id': serializer.toJson<String>(accountId),
      'delta': serializer.toJson<int>(delta),
      'balance_after': serializer.toJson<int>(balanceAfter),
      'kind': serializer.toJson<String>(kind),
      'source_key': serializer.toJson<String>(sourceKey),
      'reversal_of': serializer.toJson<String?>(reversalOf),
      'actual_date': serializer.toJson<String>(actualDate),
      'posted_day': serializer.toJson<String>(postedDay),
      'created_at': serializer.toJson<int>(createdAt),
      'command_id': serializer.toJson<String>(commandId),
    };
  }

  LedgerEntry copyWith({
    String? id,
    String? accountId,
    int? delta,
    int? balanceAfter,
    String? kind,
    String? sourceKey,
    Value<String?> reversalOf = const Value.absent(),
    String? actualDate,
    String? postedDay,
    int? createdAt,
    String? commandId,
  }) => LedgerEntry(
    id: id ?? this.id,
    accountId: accountId ?? this.accountId,
    delta: delta ?? this.delta,
    balanceAfter: balanceAfter ?? this.balanceAfter,
    kind: kind ?? this.kind,
    sourceKey: sourceKey ?? this.sourceKey,
    reversalOf: reversalOf.present ? reversalOf.value : this.reversalOf,
    actualDate: actualDate ?? this.actualDate,
    postedDay: postedDay ?? this.postedDay,
    createdAt: createdAt ?? this.createdAt,
    commandId: commandId ?? this.commandId,
  );
  LedgerEntry copyWithCompanion(LedgerEntriesCompanion data) {
    return LedgerEntry(
      id: data.id.present ? data.id.value : this.id,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      delta: data.delta.present ? data.delta.value : this.delta,
      balanceAfter: data.balanceAfter.present
          ? data.balanceAfter.value
          : this.balanceAfter,
      kind: data.kind.present ? data.kind.value : this.kind,
      sourceKey: data.sourceKey.present ? data.sourceKey.value : this.sourceKey,
      reversalOf: data.reversalOf.present
          ? data.reversalOf.value
          : this.reversalOf,
      actualDate: data.actualDate.present
          ? data.actualDate.value
          : this.actualDate,
      postedDay: data.postedDay.present ? data.postedDay.value : this.postedDay,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      commandId: data.commandId.present ? data.commandId.value : this.commandId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LedgerEntry(')
          ..write('id: $id, ')
          ..write('accountId: $accountId, ')
          ..write('delta: $delta, ')
          ..write('balanceAfter: $balanceAfter, ')
          ..write('kind: $kind, ')
          ..write('sourceKey: $sourceKey, ')
          ..write('reversalOf: $reversalOf, ')
          ..write('actualDate: $actualDate, ')
          ..write('postedDay: $postedDay, ')
          ..write('createdAt: $createdAt, ')
          ..write('commandId: $commandId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    accountId,
    delta,
    balanceAfter,
    kind,
    sourceKey,
    reversalOf,
    actualDate,
    postedDay,
    createdAt,
    commandId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LedgerEntry &&
          other.id == this.id &&
          other.accountId == this.accountId &&
          other.delta == this.delta &&
          other.balanceAfter == this.balanceAfter &&
          other.kind == this.kind &&
          other.sourceKey == this.sourceKey &&
          other.reversalOf == this.reversalOf &&
          other.actualDate == this.actualDate &&
          other.postedDay == this.postedDay &&
          other.createdAt == this.createdAt &&
          other.commandId == this.commandId);
}

class LedgerEntriesCompanion extends UpdateCompanion<LedgerEntry> {
  final Value<String> id;
  final Value<String> accountId;
  final Value<int> delta;
  final Value<int> balanceAfter;
  final Value<String> kind;
  final Value<String> sourceKey;
  final Value<String?> reversalOf;
  final Value<String> actualDate;
  final Value<String> postedDay;
  final Value<int> createdAt;
  final Value<String> commandId;
  final Value<int> rowid;
  const LedgerEntriesCompanion({
    this.id = const Value.absent(),
    this.accountId = const Value.absent(),
    this.delta = const Value.absent(),
    this.balanceAfter = const Value.absent(),
    this.kind = const Value.absent(),
    this.sourceKey = const Value.absent(),
    this.reversalOf = const Value.absent(),
    this.actualDate = const Value.absent(),
    this.postedDay = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.commandId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LedgerEntriesCompanion.insert({
    required String id,
    required String accountId,
    required int delta,
    required int balanceAfter,
    required String kind,
    required String sourceKey,
    this.reversalOf = const Value.absent(),
    required String actualDate,
    required String postedDay,
    required int createdAt,
    required String commandId,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       accountId = Value(accountId),
       delta = Value(delta),
       balanceAfter = Value(balanceAfter),
       kind = Value(kind),
       sourceKey = Value(sourceKey),
       actualDate = Value(actualDate),
       postedDay = Value(postedDay),
       createdAt = Value(createdAt),
       commandId = Value(commandId);
  static Insertable<LedgerEntry> custom({
    Expression<String>? id,
    Expression<String>? accountId,
    Expression<int>? delta,
    Expression<int>? balanceAfter,
    Expression<String>? kind,
    Expression<String>? sourceKey,
    Expression<String>? reversalOf,
    Expression<String>? actualDate,
    Expression<String>? postedDay,
    Expression<int>? createdAt,
    Expression<String>? commandId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (accountId != null) 'account_id': accountId,
      if (delta != null) 'delta': delta,
      if (balanceAfter != null) 'balance_after': balanceAfter,
      if (kind != null) 'kind': kind,
      if (sourceKey != null) 'source_key': sourceKey,
      if (reversalOf != null) 'reversal_of': reversalOf,
      if (actualDate != null) 'actual_date': actualDate,
      if (postedDay != null) 'posted_day': postedDay,
      if (createdAt != null) 'created_at': createdAt,
      if (commandId != null) 'command_id': commandId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LedgerEntriesCompanion copyWith({
    Value<String>? id,
    Value<String>? accountId,
    Value<int>? delta,
    Value<int>? balanceAfter,
    Value<String>? kind,
    Value<String>? sourceKey,
    Value<String?>? reversalOf,
    Value<String>? actualDate,
    Value<String>? postedDay,
    Value<int>? createdAt,
    Value<String>? commandId,
    Value<int>? rowid,
  }) {
    return LedgerEntriesCompanion(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      delta: delta ?? this.delta,
      balanceAfter: balanceAfter ?? this.balanceAfter,
      kind: kind ?? this.kind,
      sourceKey: sourceKey ?? this.sourceKey,
      reversalOf: reversalOf ?? this.reversalOf,
      actualDate: actualDate ?? this.actualDate,
      postedDay: postedDay ?? this.postedDay,
      createdAt: createdAt ?? this.createdAt,
      commandId: commandId ?? this.commandId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (delta.present) {
      map['delta'] = Variable<int>(delta.value);
    }
    if (balanceAfter.present) {
      map['balance_after'] = Variable<int>(balanceAfter.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (sourceKey.present) {
      map['source_key'] = Variable<String>(sourceKey.value);
    }
    if (reversalOf.present) {
      map['reversal_of'] = Variable<String>(reversalOf.value);
    }
    if (actualDate.present) {
      map['actual_date'] = Variable<String>(actualDate.value);
    }
    if (postedDay.present) {
      map['posted_day'] = Variable<String>(postedDay.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (commandId.present) {
      map['command_id'] = Variable<String>(commandId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LedgerEntriesCompanion(')
          ..write('id: $id, ')
          ..write('accountId: $accountId, ')
          ..write('delta: $delta, ')
          ..write('balanceAfter: $balanceAfter, ')
          ..write('kind: $kind, ')
          ..write('sourceKey: $sourceKey, ')
          ..write('reversalOf: $reversalOf, ')
          ..write('actualDate: $actualDate, ')
          ..write('postedDay: $postedDay, ')
          ..write('createdAt: $createdAt, ')
          ..write('commandId: $commandId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class ProcessedCommands extends Table
    with TableInfo<ProcessedCommands, ProcessedCommand> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  ProcessedCommands(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  static const VerificationMeta _payloadHashMeta = const VerificationMeta(
    'payloadHash',
  );
  late final GeneratedColumn<String> payloadHash = GeneratedColumn<String>(
    'payload_hash',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _resultJsonMeta = const VerificationMeta(
    'resultJson',
  );
  late final GeneratedColumn<String> resultJson = GeneratedColumn<String>(
    'result_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    payloadHash,
    resultJson,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'processed_commands';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProcessedCommand> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('payload_hash')) {
      context.handle(
        _payloadHashMeta,
        payloadHash.isAcceptableOrUnknown(
          data['payload_hash']!,
          _payloadHashMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadHashMeta);
    }
    if (data.containsKey('result_json')) {
      context.handle(
        _resultJsonMeta,
        resultJson.isAcceptableOrUnknown(data['result_json']!, _resultJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_resultJsonMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProcessedCommand map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProcessedCommand(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      payloadHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_hash'],
      )!,
      resultJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}result_json'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  ProcessedCommands createAlias(String alias) {
    return ProcessedCommands(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class ProcessedCommand extends DataClass
    implements Insertable<ProcessedCommand> {
  final String id;
  final String payloadHash;
  final String resultJson;
  final int createdAt;
  const ProcessedCommand({
    required this.id,
    required this.payloadHash,
    required this.resultJson,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['payload_hash'] = Variable<String>(payloadHash);
    map['result_json'] = Variable<String>(resultJson);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  ProcessedCommandsCompanion toCompanion(bool nullToAbsent) {
    return ProcessedCommandsCompanion(
      id: Value(id),
      payloadHash: Value(payloadHash),
      resultJson: Value(resultJson),
      createdAt: Value(createdAt),
    );
  }

  factory ProcessedCommand.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProcessedCommand(
      id: serializer.fromJson<String>(json['id']),
      payloadHash: serializer.fromJson<String>(json['payload_hash']),
      resultJson: serializer.fromJson<String>(json['result_json']),
      createdAt: serializer.fromJson<int>(json['created_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'payload_hash': serializer.toJson<String>(payloadHash),
      'result_json': serializer.toJson<String>(resultJson),
      'created_at': serializer.toJson<int>(createdAt),
    };
  }

  ProcessedCommand copyWith({
    String? id,
    String? payloadHash,
    String? resultJson,
    int? createdAt,
  }) => ProcessedCommand(
    id: id ?? this.id,
    payloadHash: payloadHash ?? this.payloadHash,
    resultJson: resultJson ?? this.resultJson,
    createdAt: createdAt ?? this.createdAt,
  );
  ProcessedCommand copyWithCompanion(ProcessedCommandsCompanion data) {
    return ProcessedCommand(
      id: data.id.present ? data.id.value : this.id,
      payloadHash: data.payloadHash.present
          ? data.payloadHash.value
          : this.payloadHash,
      resultJson: data.resultJson.present
          ? data.resultJson.value
          : this.resultJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProcessedCommand(')
          ..write('id: $id, ')
          ..write('payloadHash: $payloadHash, ')
          ..write('resultJson: $resultJson, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, payloadHash, resultJson, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProcessedCommand &&
          other.id == this.id &&
          other.payloadHash == this.payloadHash &&
          other.resultJson == this.resultJson &&
          other.createdAt == this.createdAt);
}

class ProcessedCommandsCompanion extends UpdateCompanion<ProcessedCommand> {
  final Value<String> id;
  final Value<String> payloadHash;
  final Value<String> resultJson;
  final Value<int> createdAt;
  final Value<int> rowid;
  const ProcessedCommandsCompanion({
    this.id = const Value.absent(),
    this.payloadHash = const Value.absent(),
    this.resultJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProcessedCommandsCompanion.insert({
    required String id,
    required String payloadHash,
    required String resultJson,
    required int createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       payloadHash = Value(payloadHash),
       resultJson = Value(resultJson),
       createdAt = Value(createdAt);
  static Insertable<ProcessedCommand> custom({
    Expression<String>? id,
    Expression<String>? payloadHash,
    Expression<String>? resultJson,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (payloadHash != null) 'payload_hash': payloadHash,
      if (resultJson != null) 'result_json': resultJson,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProcessedCommandsCompanion copyWith({
    Value<String>? id,
    Value<String>? payloadHash,
    Value<String>? resultJson,
    Value<int>? createdAt,
    Value<int>? rowid,
  }) {
    return ProcessedCommandsCompanion(
      id: id ?? this.id,
      payloadHash: payloadHash ?? this.payloadHash,
      resultJson: resultJson ?? this.resultJson,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (payloadHash.present) {
      map['payload_hash'] = Variable<String>(payloadHash.value);
    }
    if (resultJson.present) {
      map['result_json'] = Variable<String>(resultJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProcessedCommandsCompanion(')
          ..write('id: $id, ')
          ..write('payloadHash: $payloadHash, ')
          ..write('resultJson: $resultJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class PenaltyRules extends Table with TableInfo<PenaltyRules, PenaltyRule> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  PenaltyRules(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  static const VerificationMeta _behaviorMeta = const VerificationMeta(
    'behavior',
  );
  late final GeneratedColumn<String> behavior = GeneratedColumn<String>(
    'behavior',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _conditionTextMeta = const VerificationMeta(
    'conditionText',
  );
  late final GeneratedColumn<String> conditionText = GeneratedColumn<String>(
    'condition_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _pointsMeta = const VerificationMeta('points');
  late final GeneratedColumn<int> points = GeneratedColumn<int>(
    'points',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (points BETWEEN 1 AND 3)',
  );
  @override
  List<GeneratedColumn> get $columns => [id, behavior, conditionText, points];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'penalty_rules';
  @override
  VerificationContext validateIntegrity(
    Insertable<PenaltyRule> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('behavior')) {
      context.handle(
        _behaviorMeta,
        behavior.isAcceptableOrUnknown(data['behavior']!, _behaviorMeta),
      );
    } else if (isInserting) {
      context.missing(_behaviorMeta);
    }
    if (data.containsKey('condition_text')) {
      context.handle(
        _conditionTextMeta,
        conditionText.isAcceptableOrUnknown(
          data['condition_text']!,
          _conditionTextMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_conditionTextMeta);
    }
    if (data.containsKey('points')) {
      context.handle(
        _pointsMeta,
        points.isAcceptableOrUnknown(data['points']!, _pointsMeta),
      );
    } else if (isInserting) {
      context.missing(_pointsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PenaltyRule map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PenaltyRule(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      behavior: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}behavior'],
      )!,
      conditionText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}condition_text'],
      )!,
      points: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}points'],
      )!,
    );
  }

  @override
  PenaltyRules createAlias(String alias) {
    return PenaltyRules(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class PenaltyRule extends DataClass implements Insertable<PenaltyRule> {
  final String id;
  final String behavior;
  final String conditionText;
  final int points;
  const PenaltyRule({
    required this.id,
    required this.behavior,
    required this.conditionText,
    required this.points,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['behavior'] = Variable<String>(behavior);
    map['condition_text'] = Variable<String>(conditionText);
    map['points'] = Variable<int>(points);
    return map;
  }

  PenaltyRulesCompanion toCompanion(bool nullToAbsent) {
    return PenaltyRulesCompanion(
      id: Value(id),
      behavior: Value(behavior),
      conditionText: Value(conditionText),
      points: Value(points),
    );
  }

  factory PenaltyRule.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PenaltyRule(
      id: serializer.fromJson<String>(json['id']),
      behavior: serializer.fromJson<String>(json['behavior']),
      conditionText: serializer.fromJson<String>(json['condition_text']),
      points: serializer.fromJson<int>(json['points']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'behavior': serializer.toJson<String>(behavior),
      'condition_text': serializer.toJson<String>(conditionText),
      'points': serializer.toJson<int>(points),
    };
  }

  PenaltyRule copyWith({
    String? id,
    String? behavior,
    String? conditionText,
    int? points,
  }) => PenaltyRule(
    id: id ?? this.id,
    behavior: behavior ?? this.behavior,
    conditionText: conditionText ?? this.conditionText,
    points: points ?? this.points,
  );
  PenaltyRule copyWithCompanion(PenaltyRulesCompanion data) {
    return PenaltyRule(
      id: data.id.present ? data.id.value : this.id,
      behavior: data.behavior.present ? data.behavior.value : this.behavior,
      conditionText: data.conditionText.present
          ? data.conditionText.value
          : this.conditionText,
      points: data.points.present ? data.points.value : this.points,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PenaltyRule(')
          ..write('id: $id, ')
          ..write('behavior: $behavior, ')
          ..write('conditionText: $conditionText, ')
          ..write('points: $points')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, behavior, conditionText, points);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PenaltyRule &&
          other.id == this.id &&
          other.behavior == this.behavior &&
          other.conditionText == this.conditionText &&
          other.points == this.points);
}

class PenaltyRulesCompanion extends UpdateCompanion<PenaltyRule> {
  final Value<String> id;
  final Value<String> behavior;
  final Value<String> conditionText;
  final Value<int> points;
  final Value<int> rowid;
  const PenaltyRulesCompanion({
    this.id = const Value.absent(),
    this.behavior = const Value.absent(),
    this.conditionText = const Value.absent(),
    this.points = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PenaltyRulesCompanion.insert({
    required String id,
    required String behavior,
    required String conditionText,
    required int points,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       behavior = Value(behavior),
       conditionText = Value(conditionText),
       points = Value(points);
  static Insertable<PenaltyRule> custom({
    Expression<String>? id,
    Expression<String>? behavior,
    Expression<String>? conditionText,
    Expression<int>? points,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (behavior != null) 'behavior': behavior,
      if (conditionText != null) 'condition_text': conditionText,
      if (points != null) 'points': points,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PenaltyRulesCompanion copyWith({
    Value<String>? id,
    Value<String>? behavior,
    Value<String>? conditionText,
    Value<int>? points,
    Value<int>? rowid,
  }) {
    return PenaltyRulesCompanion(
      id: id ?? this.id,
      behavior: behavior ?? this.behavior,
      conditionText: conditionText ?? this.conditionText,
      points: points ?? this.points,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (behavior.present) {
      map['behavior'] = Variable<String>(behavior.value);
    }
    if (conditionText.present) {
      map['condition_text'] = Variable<String>(conditionText.value);
    }
    if (points.present) {
      map['points'] = Variable<int>(points.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PenaltyRulesCompanion(')
          ..write('id: $id, ')
          ..write('behavior: $behavior, ')
          ..write('conditionText: $conditionText, ')
          ..write('points: $points, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class PenaltyEvents extends Table with TableInfo<PenaltyEvents, PenaltyEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  PenaltyEvents(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  static const VerificationMeta _ruleIdMeta = const VerificationMeta('ruleId');
  late final GeneratedColumn<String> ruleId = GeneratedColumn<String>(
    'rule_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES penalty_rules(id)',
  );
  static const VerificationMeta _factMeta = const VerificationMeta('fact');
  late final GeneratedColumn<String> fact = GeneratedColumn<String>(
    'fact',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _actualDateMeta = const VerificationMeta(
    'actualDate',
  );
  late final GeneratedColumn<String> actualDate = GeneratedColumn<String>(
    'actual_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _postedDayMeta = const VerificationMeta(
    'postedDay',
  );
  late final GeneratedColumn<String> postedDay = GeneratedColumn<String>(
    'posted_day',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _plannedPointsMeta = const VerificationMeta(
    'plannedPoints',
  );
  late final GeneratedColumn<int> plannedPoints = GeneratedColumn<int>(
    'planned_points',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (planned_points BETWEEN 1 AND 3)',
  );
  static const VerificationMeta _deductedMeta = const VerificationMeta(
    'deducted',
  );
  late final GeneratedColumn<int> deducted = GeneratedColumn<int>(
    'deducted',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints:
        'NOT NULL CHECK (deducted BETWEEN 0 AND planned_points)',
  );
  static const VerificationMeta _ledgerIdMeta = const VerificationMeta(
    'ledgerId',
  );
  late final GeneratedColumn<String> ledgerId = GeneratedColumn<String>(
    'ledger_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL UNIQUE REFERENCES ledger_entries(id)',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ruleId,
    fact,
    actualDate,
    postedDay,
    plannedPoints,
    deducted,
    ledgerId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'penalty_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<PenaltyEvent> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('rule_id')) {
      context.handle(
        _ruleIdMeta,
        ruleId.isAcceptableOrUnknown(data['rule_id']!, _ruleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ruleIdMeta);
    }
    if (data.containsKey('fact')) {
      context.handle(
        _factMeta,
        fact.isAcceptableOrUnknown(data['fact']!, _factMeta),
      );
    } else if (isInserting) {
      context.missing(_factMeta);
    }
    if (data.containsKey('actual_date')) {
      context.handle(
        _actualDateMeta,
        actualDate.isAcceptableOrUnknown(data['actual_date']!, _actualDateMeta),
      );
    } else if (isInserting) {
      context.missing(_actualDateMeta);
    }
    if (data.containsKey('posted_day')) {
      context.handle(
        _postedDayMeta,
        postedDay.isAcceptableOrUnknown(data['posted_day']!, _postedDayMeta),
      );
    } else if (isInserting) {
      context.missing(_postedDayMeta);
    }
    if (data.containsKey('planned_points')) {
      context.handle(
        _plannedPointsMeta,
        plannedPoints.isAcceptableOrUnknown(
          data['planned_points']!,
          _plannedPointsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_plannedPointsMeta);
    }
    if (data.containsKey('deducted')) {
      context.handle(
        _deductedMeta,
        deducted.isAcceptableOrUnknown(data['deducted']!, _deductedMeta),
      );
    } else if (isInserting) {
      context.missing(_deductedMeta);
    }
    if (data.containsKey('ledger_id')) {
      context.handle(
        _ledgerIdMeta,
        ledgerId.isAcceptableOrUnknown(data['ledger_id']!, _ledgerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ledgerIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PenaltyEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PenaltyEvent(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      ruleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rule_id'],
      )!,
      fact: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fact'],
      )!,
      actualDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}actual_date'],
      )!,
      postedDay: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}posted_day'],
      )!,
      plannedPoints: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}planned_points'],
      )!,
      deducted: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deducted'],
      )!,
      ledgerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ledger_id'],
      )!,
    );
  }

  @override
  PenaltyEvents createAlias(String alias) {
    return PenaltyEvents(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class PenaltyEvent extends DataClass implements Insertable<PenaltyEvent> {
  final String id;
  final String ruleId;
  final String fact;
  final String actualDate;
  final String postedDay;
  final int plannedPoints;
  final int deducted;
  final String ledgerId;
  const PenaltyEvent({
    required this.id,
    required this.ruleId,
    required this.fact,
    required this.actualDate,
    required this.postedDay,
    required this.plannedPoints,
    required this.deducted,
    required this.ledgerId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['rule_id'] = Variable<String>(ruleId);
    map['fact'] = Variable<String>(fact);
    map['actual_date'] = Variable<String>(actualDate);
    map['posted_day'] = Variable<String>(postedDay);
    map['planned_points'] = Variable<int>(plannedPoints);
    map['deducted'] = Variable<int>(deducted);
    map['ledger_id'] = Variable<String>(ledgerId);
    return map;
  }

  PenaltyEventsCompanion toCompanion(bool nullToAbsent) {
    return PenaltyEventsCompanion(
      id: Value(id),
      ruleId: Value(ruleId),
      fact: Value(fact),
      actualDate: Value(actualDate),
      postedDay: Value(postedDay),
      plannedPoints: Value(plannedPoints),
      deducted: Value(deducted),
      ledgerId: Value(ledgerId),
    );
  }

  factory PenaltyEvent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PenaltyEvent(
      id: serializer.fromJson<String>(json['id']),
      ruleId: serializer.fromJson<String>(json['rule_id']),
      fact: serializer.fromJson<String>(json['fact']),
      actualDate: serializer.fromJson<String>(json['actual_date']),
      postedDay: serializer.fromJson<String>(json['posted_day']),
      plannedPoints: serializer.fromJson<int>(json['planned_points']),
      deducted: serializer.fromJson<int>(json['deducted']),
      ledgerId: serializer.fromJson<String>(json['ledger_id']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'rule_id': serializer.toJson<String>(ruleId),
      'fact': serializer.toJson<String>(fact),
      'actual_date': serializer.toJson<String>(actualDate),
      'posted_day': serializer.toJson<String>(postedDay),
      'planned_points': serializer.toJson<int>(plannedPoints),
      'deducted': serializer.toJson<int>(deducted),
      'ledger_id': serializer.toJson<String>(ledgerId),
    };
  }

  PenaltyEvent copyWith({
    String? id,
    String? ruleId,
    String? fact,
    String? actualDate,
    String? postedDay,
    int? plannedPoints,
    int? deducted,
    String? ledgerId,
  }) => PenaltyEvent(
    id: id ?? this.id,
    ruleId: ruleId ?? this.ruleId,
    fact: fact ?? this.fact,
    actualDate: actualDate ?? this.actualDate,
    postedDay: postedDay ?? this.postedDay,
    plannedPoints: plannedPoints ?? this.plannedPoints,
    deducted: deducted ?? this.deducted,
    ledgerId: ledgerId ?? this.ledgerId,
  );
  PenaltyEvent copyWithCompanion(PenaltyEventsCompanion data) {
    return PenaltyEvent(
      id: data.id.present ? data.id.value : this.id,
      ruleId: data.ruleId.present ? data.ruleId.value : this.ruleId,
      fact: data.fact.present ? data.fact.value : this.fact,
      actualDate: data.actualDate.present
          ? data.actualDate.value
          : this.actualDate,
      postedDay: data.postedDay.present ? data.postedDay.value : this.postedDay,
      plannedPoints: data.plannedPoints.present
          ? data.plannedPoints.value
          : this.plannedPoints,
      deducted: data.deducted.present ? data.deducted.value : this.deducted,
      ledgerId: data.ledgerId.present ? data.ledgerId.value : this.ledgerId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PenaltyEvent(')
          ..write('id: $id, ')
          ..write('ruleId: $ruleId, ')
          ..write('fact: $fact, ')
          ..write('actualDate: $actualDate, ')
          ..write('postedDay: $postedDay, ')
          ..write('plannedPoints: $plannedPoints, ')
          ..write('deducted: $deducted, ')
          ..write('ledgerId: $ledgerId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    ruleId,
    fact,
    actualDate,
    postedDay,
    plannedPoints,
    deducted,
    ledgerId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PenaltyEvent &&
          other.id == this.id &&
          other.ruleId == this.ruleId &&
          other.fact == this.fact &&
          other.actualDate == this.actualDate &&
          other.postedDay == this.postedDay &&
          other.plannedPoints == this.plannedPoints &&
          other.deducted == this.deducted &&
          other.ledgerId == this.ledgerId);
}

class PenaltyEventsCompanion extends UpdateCompanion<PenaltyEvent> {
  final Value<String> id;
  final Value<String> ruleId;
  final Value<String> fact;
  final Value<String> actualDate;
  final Value<String> postedDay;
  final Value<int> plannedPoints;
  final Value<int> deducted;
  final Value<String> ledgerId;
  final Value<int> rowid;
  const PenaltyEventsCompanion({
    this.id = const Value.absent(),
    this.ruleId = const Value.absent(),
    this.fact = const Value.absent(),
    this.actualDate = const Value.absent(),
    this.postedDay = const Value.absent(),
    this.plannedPoints = const Value.absent(),
    this.deducted = const Value.absent(),
    this.ledgerId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PenaltyEventsCompanion.insert({
    required String id,
    required String ruleId,
    required String fact,
    required String actualDate,
    required String postedDay,
    required int plannedPoints,
    required int deducted,
    required String ledgerId,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       ruleId = Value(ruleId),
       fact = Value(fact),
       actualDate = Value(actualDate),
       postedDay = Value(postedDay),
       plannedPoints = Value(plannedPoints),
       deducted = Value(deducted),
       ledgerId = Value(ledgerId);
  static Insertable<PenaltyEvent> custom({
    Expression<String>? id,
    Expression<String>? ruleId,
    Expression<String>? fact,
    Expression<String>? actualDate,
    Expression<String>? postedDay,
    Expression<int>? plannedPoints,
    Expression<int>? deducted,
    Expression<String>? ledgerId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ruleId != null) 'rule_id': ruleId,
      if (fact != null) 'fact': fact,
      if (actualDate != null) 'actual_date': actualDate,
      if (postedDay != null) 'posted_day': postedDay,
      if (plannedPoints != null) 'planned_points': plannedPoints,
      if (deducted != null) 'deducted': deducted,
      if (ledgerId != null) 'ledger_id': ledgerId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PenaltyEventsCompanion copyWith({
    Value<String>? id,
    Value<String>? ruleId,
    Value<String>? fact,
    Value<String>? actualDate,
    Value<String>? postedDay,
    Value<int>? plannedPoints,
    Value<int>? deducted,
    Value<String>? ledgerId,
    Value<int>? rowid,
  }) {
    return PenaltyEventsCompanion(
      id: id ?? this.id,
      ruleId: ruleId ?? this.ruleId,
      fact: fact ?? this.fact,
      actualDate: actualDate ?? this.actualDate,
      postedDay: postedDay ?? this.postedDay,
      plannedPoints: plannedPoints ?? this.plannedPoints,
      deducted: deducted ?? this.deducted,
      ledgerId: ledgerId ?? this.ledgerId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (ruleId.present) {
      map['rule_id'] = Variable<String>(ruleId.value);
    }
    if (fact.present) {
      map['fact'] = Variable<String>(fact.value);
    }
    if (actualDate.present) {
      map['actual_date'] = Variable<String>(actualDate.value);
    }
    if (postedDay.present) {
      map['posted_day'] = Variable<String>(postedDay.value);
    }
    if (plannedPoints.present) {
      map['planned_points'] = Variable<int>(plannedPoints.value);
    }
    if (deducted.present) {
      map['deducted'] = Variable<int>(deducted.value);
    }
    if (ledgerId.present) {
      map['ledger_id'] = Variable<String>(ledgerId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PenaltyEventsCompanion(')
          ..write('id: $id, ')
          ..write('ruleId: $ruleId, ')
          ..write('fact: $fact, ')
          ..write('actualDate: $actualDate, ')
          ..write('postedDay: $postedDay, ')
          ..write('plannedPoints: $plannedPoints, ')
          ..write('deducted: $deducted, ')
          ..write('ledgerId: $ledgerId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class PenaltyDayUsage extends Table
    with TableInfo<PenaltyDayUsage, PenaltyDayUsageData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  PenaltyDayUsage(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
    'account_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES accounts(id)',
  );
  static const VerificationMeta _postedDayMeta = const VerificationMeta(
    'postedDay',
  );
  late final GeneratedColumn<String> postedDay = GeneratedColumn<String>(
    'posted_day',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _usedMeta = const VerificationMeta('used');
  late final GeneratedColumn<int> used = GeneratedColumn<int>(
    'used',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (used BETWEEN 0 AND 3)',
  );
  @override
  List<GeneratedColumn> get $columns => [accountId, postedDay, used];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'penalty_day_usage';
  @override
  VerificationContext validateIntegrity(
    Insertable<PenaltyDayUsageData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('posted_day')) {
      context.handle(
        _postedDayMeta,
        postedDay.isAcceptableOrUnknown(data['posted_day']!, _postedDayMeta),
      );
    } else if (isInserting) {
      context.missing(_postedDayMeta);
    }
    if (data.containsKey('used')) {
      context.handle(
        _usedMeta,
        used.isAcceptableOrUnknown(data['used']!, _usedMeta),
      );
    } else if (isInserting) {
      context.missing(_usedMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {accountId, postedDay};
  @override
  PenaltyDayUsageData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PenaltyDayUsageData(
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_id'],
      )!,
      postedDay: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}posted_day'],
      )!,
      used: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}used'],
      )!,
    );
  }

  @override
  PenaltyDayUsage createAlias(String alias) {
    return PenaltyDayUsage(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints => const [
    'PRIMARY KEY(account_id, posted_day)',
  ];
  @override
  bool get dontWriteConstraints => true;
}

class PenaltyDayUsageData extends DataClass
    implements Insertable<PenaltyDayUsageData> {
  final String accountId;
  final String postedDay;
  final int used;
  const PenaltyDayUsageData({
    required this.accountId,
    required this.postedDay,
    required this.used,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['account_id'] = Variable<String>(accountId);
    map['posted_day'] = Variable<String>(postedDay);
    map['used'] = Variable<int>(used);
    return map;
  }

  PenaltyDayUsageCompanion toCompanion(bool nullToAbsent) {
    return PenaltyDayUsageCompanion(
      accountId: Value(accountId),
      postedDay: Value(postedDay),
      used: Value(used),
    );
  }

  factory PenaltyDayUsageData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PenaltyDayUsageData(
      accountId: serializer.fromJson<String>(json['account_id']),
      postedDay: serializer.fromJson<String>(json['posted_day']),
      used: serializer.fromJson<int>(json['used']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'account_id': serializer.toJson<String>(accountId),
      'posted_day': serializer.toJson<String>(postedDay),
      'used': serializer.toJson<int>(used),
    };
  }

  PenaltyDayUsageData copyWith({
    String? accountId,
    String? postedDay,
    int? used,
  }) => PenaltyDayUsageData(
    accountId: accountId ?? this.accountId,
    postedDay: postedDay ?? this.postedDay,
    used: used ?? this.used,
  );
  PenaltyDayUsageData copyWithCompanion(PenaltyDayUsageCompanion data) {
    return PenaltyDayUsageData(
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      postedDay: data.postedDay.present ? data.postedDay.value : this.postedDay,
      used: data.used.present ? data.used.value : this.used,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PenaltyDayUsageData(')
          ..write('accountId: $accountId, ')
          ..write('postedDay: $postedDay, ')
          ..write('used: $used')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(accountId, postedDay, used);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PenaltyDayUsageData &&
          other.accountId == this.accountId &&
          other.postedDay == this.postedDay &&
          other.used == this.used);
}

class PenaltyDayUsageCompanion extends UpdateCompanion<PenaltyDayUsageData> {
  final Value<String> accountId;
  final Value<String> postedDay;
  final Value<int> used;
  final Value<int> rowid;
  const PenaltyDayUsageCompanion({
    this.accountId = const Value.absent(),
    this.postedDay = const Value.absent(),
    this.used = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PenaltyDayUsageCompanion.insert({
    required String accountId,
    required String postedDay,
    required int used,
    this.rowid = const Value.absent(),
  }) : accountId = Value(accountId),
       postedDay = Value(postedDay),
       used = Value(used);
  static Insertable<PenaltyDayUsageData> custom({
    Expression<String>? accountId,
    Expression<String>? postedDay,
    Expression<int>? used,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (accountId != null) 'account_id': accountId,
      if (postedDay != null) 'posted_day': postedDay,
      if (used != null) 'used': used,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PenaltyDayUsageCompanion copyWith({
    Value<String>? accountId,
    Value<String>? postedDay,
    Value<int>? used,
    Value<int>? rowid,
  }) {
    return PenaltyDayUsageCompanion(
      accountId: accountId ?? this.accountId,
      postedDay: postedDay ?? this.postedDay,
      used: used ?? this.used,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (postedDay.present) {
      map['posted_day'] = Variable<String>(postedDay.value);
    }
    if (used.present) {
      map['used'] = Variable<int>(used.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PenaltyDayUsageCompanion(')
          ..write('accountId: $accountId, ')
          ..write('postedDay: $postedDay, ')
          ..write('used: $used, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class Purchases extends Table with TableInfo<Purchases, Purchase> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Purchases(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
    'item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _pricePaidMeta = const VerificationMeta(
    'pricePaid',
  );
  late final GeneratedColumn<int> pricePaid = GeneratedColumn<int>(
    'price_paid',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (price_paid > 0)',
  );
  static const VerificationMeta _ledgerIdMeta = const VerificationMeta(
    'ledgerId',
  );
  late final GeneratedColumn<String> ledgerId = GeneratedColumn<String>(
    'ledger_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL UNIQUE REFERENCES ledger_entries(id)',
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _refundedAtMeta = const VerificationMeta(
    'refundedAt',
  );
  late final GeneratedColumn<int> refundedAt = GeneratedColumn<int>(
    'refunded_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _commandIdMeta = const VerificationMeta(
    'commandId',
  );
  late final GeneratedColumn<String> commandId = GeneratedColumn<String>(
    'command_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL UNIQUE',
  );
  static const VerificationMeta _assetIdMeta = const VerificationMeta(
    'assetId',
  );
  late final GeneratedColumn<String> assetId = GeneratedColumn<String>(
    'asset_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    itemId,
    name,
    pricePaid,
    ledgerId,
    createdAt,
    refundedAt,
    commandId,
    assetId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'purchases';
  @override
  VerificationContext validateIntegrity(
    Insertable<Purchase> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('item_id')) {
      context.handle(
        _itemIdMeta,
        itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta),
      );
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('price_paid')) {
      context.handle(
        _pricePaidMeta,
        pricePaid.isAcceptableOrUnknown(data['price_paid']!, _pricePaidMeta),
      );
    } else if (isInserting) {
      context.missing(_pricePaidMeta);
    }
    if (data.containsKey('ledger_id')) {
      context.handle(
        _ledgerIdMeta,
        ledgerId.isAcceptableOrUnknown(data['ledger_id']!, _ledgerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ledgerIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('refunded_at')) {
      context.handle(
        _refundedAtMeta,
        refundedAt.isAcceptableOrUnknown(data['refunded_at']!, _refundedAtMeta),
      );
    }
    if (data.containsKey('command_id')) {
      context.handle(
        _commandIdMeta,
        commandId.isAcceptableOrUnknown(data['command_id']!, _commandIdMeta),
      );
    } else if (isInserting) {
      context.missing(_commandIdMeta);
    }
    if (data.containsKey('asset_id')) {
      context.handle(
        _assetIdMeta,
        assetId.isAcceptableOrUnknown(data['asset_id']!, _assetIdMeta),
      );
    } else if (isInserting) {
      context.missing(_assetIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Purchase map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Purchase(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      itemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      pricePaid: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}price_paid'],
      )!,
      ledgerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ledger_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      refundedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}refunded_at'],
      ),
      commandId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}command_id'],
      )!,
      assetId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}asset_id'],
      )!,
    );
  }

  @override
  Purchases createAlias(String alias) {
    return Purchases(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class Purchase extends DataClass implements Insertable<Purchase> {
  final String id;
  final String itemId;
  final String name;
  final int pricePaid;
  final String ledgerId;
  final int createdAt;
  final int? refundedAt;
  final String commandId;
  final String assetId;
  const Purchase({
    required this.id,
    required this.itemId,
    required this.name,
    required this.pricePaid,
    required this.ledgerId,
    required this.createdAt,
    this.refundedAt,
    required this.commandId,
    required this.assetId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['item_id'] = Variable<String>(itemId);
    map['name'] = Variable<String>(name);
    map['price_paid'] = Variable<int>(pricePaid);
    map['ledger_id'] = Variable<String>(ledgerId);
    map['created_at'] = Variable<int>(createdAt);
    if (!nullToAbsent || refundedAt != null) {
      map['refunded_at'] = Variable<int>(refundedAt);
    }
    map['command_id'] = Variable<String>(commandId);
    map['asset_id'] = Variable<String>(assetId);
    return map;
  }

  PurchasesCompanion toCompanion(bool nullToAbsent) {
    return PurchasesCompanion(
      id: Value(id),
      itemId: Value(itemId),
      name: Value(name),
      pricePaid: Value(pricePaid),
      ledgerId: Value(ledgerId),
      createdAt: Value(createdAt),
      refundedAt: refundedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(refundedAt),
      commandId: Value(commandId),
      assetId: Value(assetId),
    );
  }

  factory Purchase.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Purchase(
      id: serializer.fromJson<String>(json['id']),
      itemId: serializer.fromJson<String>(json['item_id']),
      name: serializer.fromJson<String>(json['name']),
      pricePaid: serializer.fromJson<int>(json['price_paid']),
      ledgerId: serializer.fromJson<String>(json['ledger_id']),
      createdAt: serializer.fromJson<int>(json['created_at']),
      refundedAt: serializer.fromJson<int?>(json['refunded_at']),
      commandId: serializer.fromJson<String>(json['command_id']),
      assetId: serializer.fromJson<String>(json['asset_id']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'item_id': serializer.toJson<String>(itemId),
      'name': serializer.toJson<String>(name),
      'price_paid': serializer.toJson<int>(pricePaid),
      'ledger_id': serializer.toJson<String>(ledgerId),
      'created_at': serializer.toJson<int>(createdAt),
      'refunded_at': serializer.toJson<int?>(refundedAt),
      'command_id': serializer.toJson<String>(commandId),
      'asset_id': serializer.toJson<String>(assetId),
    };
  }

  Purchase copyWith({
    String? id,
    String? itemId,
    String? name,
    int? pricePaid,
    String? ledgerId,
    int? createdAt,
    Value<int?> refundedAt = const Value.absent(),
    String? commandId,
    String? assetId,
  }) => Purchase(
    id: id ?? this.id,
    itemId: itemId ?? this.itemId,
    name: name ?? this.name,
    pricePaid: pricePaid ?? this.pricePaid,
    ledgerId: ledgerId ?? this.ledgerId,
    createdAt: createdAt ?? this.createdAt,
    refundedAt: refundedAt.present ? refundedAt.value : this.refundedAt,
    commandId: commandId ?? this.commandId,
    assetId: assetId ?? this.assetId,
  );
  Purchase copyWithCompanion(PurchasesCompanion data) {
    return Purchase(
      id: data.id.present ? data.id.value : this.id,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      name: data.name.present ? data.name.value : this.name,
      pricePaid: data.pricePaid.present ? data.pricePaid.value : this.pricePaid,
      ledgerId: data.ledgerId.present ? data.ledgerId.value : this.ledgerId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      refundedAt: data.refundedAt.present
          ? data.refundedAt.value
          : this.refundedAt,
      commandId: data.commandId.present ? data.commandId.value : this.commandId,
      assetId: data.assetId.present ? data.assetId.value : this.assetId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Purchase(')
          ..write('id: $id, ')
          ..write('itemId: $itemId, ')
          ..write('name: $name, ')
          ..write('pricePaid: $pricePaid, ')
          ..write('ledgerId: $ledgerId, ')
          ..write('createdAt: $createdAt, ')
          ..write('refundedAt: $refundedAt, ')
          ..write('commandId: $commandId, ')
          ..write('assetId: $assetId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    itemId,
    name,
    pricePaid,
    ledgerId,
    createdAt,
    refundedAt,
    commandId,
    assetId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Purchase &&
          other.id == this.id &&
          other.itemId == this.itemId &&
          other.name == this.name &&
          other.pricePaid == this.pricePaid &&
          other.ledgerId == this.ledgerId &&
          other.createdAt == this.createdAt &&
          other.refundedAt == this.refundedAt &&
          other.commandId == this.commandId &&
          other.assetId == this.assetId);
}

class PurchasesCompanion extends UpdateCompanion<Purchase> {
  final Value<String> id;
  final Value<String> itemId;
  final Value<String> name;
  final Value<int> pricePaid;
  final Value<String> ledgerId;
  final Value<int> createdAt;
  final Value<int?> refundedAt;
  final Value<String> commandId;
  final Value<String> assetId;
  final Value<int> rowid;
  const PurchasesCompanion({
    this.id = const Value.absent(),
    this.itemId = const Value.absent(),
    this.name = const Value.absent(),
    this.pricePaid = const Value.absent(),
    this.ledgerId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.refundedAt = const Value.absent(),
    this.commandId = const Value.absent(),
    this.assetId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PurchasesCompanion.insert({
    required String id,
    required String itemId,
    required String name,
    required int pricePaid,
    required String ledgerId,
    required int createdAt,
    this.refundedAt = const Value.absent(),
    required String commandId,
    required String assetId,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       itemId = Value(itemId),
       name = Value(name),
       pricePaid = Value(pricePaid),
       ledgerId = Value(ledgerId),
       createdAt = Value(createdAt),
       commandId = Value(commandId),
       assetId = Value(assetId);
  static Insertable<Purchase> custom({
    Expression<String>? id,
    Expression<String>? itemId,
    Expression<String>? name,
    Expression<int>? pricePaid,
    Expression<String>? ledgerId,
    Expression<int>? createdAt,
    Expression<int>? refundedAt,
    Expression<String>? commandId,
    Expression<String>? assetId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (itemId != null) 'item_id': itemId,
      if (name != null) 'name': name,
      if (pricePaid != null) 'price_paid': pricePaid,
      if (ledgerId != null) 'ledger_id': ledgerId,
      if (createdAt != null) 'created_at': createdAt,
      if (refundedAt != null) 'refunded_at': refundedAt,
      if (commandId != null) 'command_id': commandId,
      if (assetId != null) 'asset_id': assetId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PurchasesCompanion copyWith({
    Value<String>? id,
    Value<String>? itemId,
    Value<String>? name,
    Value<int>? pricePaid,
    Value<String>? ledgerId,
    Value<int>? createdAt,
    Value<int?>? refundedAt,
    Value<String>? commandId,
    Value<String>? assetId,
    Value<int>? rowid,
  }) {
    return PurchasesCompanion(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      name: name ?? this.name,
      pricePaid: pricePaid ?? this.pricePaid,
      ledgerId: ledgerId ?? this.ledgerId,
      createdAt: createdAt ?? this.createdAt,
      refundedAt: refundedAt ?? this.refundedAt,
      commandId: commandId ?? this.commandId,
      assetId: assetId ?? this.assetId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (pricePaid.present) {
      map['price_paid'] = Variable<int>(pricePaid.value);
    }
    if (ledgerId.present) {
      map['ledger_id'] = Variable<String>(ledgerId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (refundedAt.present) {
      map['refunded_at'] = Variable<int>(refundedAt.value);
    }
    if (commandId.present) {
      map['command_id'] = Variable<String>(commandId.value);
    }
    if (assetId.present) {
      map['asset_id'] = Variable<String>(assetId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PurchasesCompanion(')
          ..write('id: $id, ')
          ..write('itemId: $itemId, ')
          ..write('name: $name, ')
          ..write('pricePaid: $pricePaid, ')
          ..write('ledgerId: $ledgerId, ')
          ..write('createdAt: $createdAt, ')
          ..write('refundedAt: $refundedAt, ')
          ..write('commandId: $commandId, ')
          ..write('assetId: $assetId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class Spaces extends Table with TableInfo<Spaces, Space> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Spaces(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  static const VerificationMeta _sceneIdMeta = const VerificationMeta(
    'sceneId',
  );
  late final GeneratedColumn<String> sceneId = GeneratedColumn<String>(
    'scene_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL UNIQUE',
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _purchaseIdMeta = const VerificationMeta(
    'purchaseId',
  );
  late final GeneratedColumn<String> purchaseId = GeneratedColumn<String>(
    'purchase_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'REFERENCES purchases(id)',
  );
  static const VerificationMeta _layoutVersionMeta = const VerificationMeta(
    'layoutVersion',
  );
  late final GeneratedColumn<int> layoutVersion = GeneratedColumn<int>(
    'layout_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const CustomExpression('0'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sceneId,
    name,
    purchaseId,
    layoutVersion,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'spaces';
  @override
  VerificationContext validateIntegrity(
    Insertable<Space> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('scene_id')) {
      context.handle(
        _sceneIdMeta,
        sceneId.isAcceptableOrUnknown(data['scene_id']!, _sceneIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sceneIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('purchase_id')) {
      context.handle(
        _purchaseIdMeta,
        purchaseId.isAcceptableOrUnknown(data['purchase_id']!, _purchaseIdMeta),
      );
    }
    if (data.containsKey('layout_version')) {
      context.handle(
        _layoutVersionMeta,
        layoutVersion.isAcceptableOrUnknown(
          data['layout_version']!,
          _layoutVersionMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Space map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Space(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      sceneId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scene_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      purchaseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}purchase_id'],
      ),
      layoutVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}layout_version'],
      )!,
    );
  }

  @override
  Spaces createAlias(String alias) {
    return Spaces(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class Space extends DataClass implements Insertable<Space> {
  final String id;
  final String sceneId;
  final String name;
  final String? purchaseId;
  final int layoutVersion;
  const Space({
    required this.id,
    required this.sceneId,
    required this.name,
    this.purchaseId,
    required this.layoutVersion,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['scene_id'] = Variable<String>(sceneId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || purchaseId != null) {
      map['purchase_id'] = Variable<String>(purchaseId);
    }
    map['layout_version'] = Variable<int>(layoutVersion);
    return map;
  }

  SpacesCompanion toCompanion(bool nullToAbsent) {
    return SpacesCompanion(
      id: Value(id),
      sceneId: Value(sceneId),
      name: Value(name),
      purchaseId: purchaseId == null && nullToAbsent
          ? const Value.absent()
          : Value(purchaseId),
      layoutVersion: Value(layoutVersion),
    );
  }

  factory Space.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Space(
      id: serializer.fromJson<String>(json['id']),
      sceneId: serializer.fromJson<String>(json['scene_id']),
      name: serializer.fromJson<String>(json['name']),
      purchaseId: serializer.fromJson<String?>(json['purchase_id']),
      layoutVersion: serializer.fromJson<int>(json['layout_version']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'scene_id': serializer.toJson<String>(sceneId),
      'name': serializer.toJson<String>(name),
      'purchase_id': serializer.toJson<String?>(purchaseId),
      'layout_version': serializer.toJson<int>(layoutVersion),
    };
  }

  Space copyWith({
    String? id,
    String? sceneId,
    String? name,
    Value<String?> purchaseId = const Value.absent(),
    int? layoutVersion,
  }) => Space(
    id: id ?? this.id,
    sceneId: sceneId ?? this.sceneId,
    name: name ?? this.name,
    purchaseId: purchaseId.present ? purchaseId.value : this.purchaseId,
    layoutVersion: layoutVersion ?? this.layoutVersion,
  );
  Space copyWithCompanion(SpacesCompanion data) {
    return Space(
      id: data.id.present ? data.id.value : this.id,
      sceneId: data.sceneId.present ? data.sceneId.value : this.sceneId,
      name: data.name.present ? data.name.value : this.name,
      purchaseId: data.purchaseId.present
          ? data.purchaseId.value
          : this.purchaseId,
      layoutVersion: data.layoutVersion.present
          ? data.layoutVersion.value
          : this.layoutVersion,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Space(')
          ..write('id: $id, ')
          ..write('sceneId: $sceneId, ')
          ..write('name: $name, ')
          ..write('purchaseId: $purchaseId, ')
          ..write('layoutVersion: $layoutVersion')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, sceneId, name, purchaseId, layoutVersion);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Space &&
          other.id == this.id &&
          other.sceneId == this.sceneId &&
          other.name == this.name &&
          other.purchaseId == this.purchaseId &&
          other.layoutVersion == this.layoutVersion);
}

class SpacesCompanion extends UpdateCompanion<Space> {
  final Value<String> id;
  final Value<String> sceneId;
  final Value<String> name;
  final Value<String?> purchaseId;
  final Value<int> layoutVersion;
  final Value<int> rowid;
  const SpacesCompanion({
    this.id = const Value.absent(),
    this.sceneId = const Value.absent(),
    this.name = const Value.absent(),
    this.purchaseId = const Value.absent(),
    this.layoutVersion = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SpacesCompanion.insert({
    required String id,
    required String sceneId,
    required String name,
    this.purchaseId = const Value.absent(),
    this.layoutVersion = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       sceneId = Value(sceneId),
       name = Value(name);
  static Insertable<Space> custom({
    Expression<String>? id,
    Expression<String>? sceneId,
    Expression<String>? name,
    Expression<String>? purchaseId,
    Expression<int>? layoutVersion,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sceneId != null) 'scene_id': sceneId,
      if (name != null) 'name': name,
      if (purchaseId != null) 'purchase_id': purchaseId,
      if (layoutVersion != null) 'layout_version': layoutVersion,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SpacesCompanion copyWith({
    Value<String>? id,
    Value<String>? sceneId,
    Value<String>? name,
    Value<String?>? purchaseId,
    Value<int>? layoutVersion,
    Value<int>? rowid,
  }) {
    return SpacesCompanion(
      id: id ?? this.id,
      sceneId: sceneId ?? this.sceneId,
      name: name ?? this.name,
      purchaseId: purchaseId ?? this.purchaseId,
      layoutVersion: layoutVersion ?? this.layoutVersion,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sceneId.present) {
      map['scene_id'] = Variable<String>(sceneId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (purchaseId.present) {
      map['purchase_id'] = Variable<String>(purchaseId.value);
    }
    if (layoutVersion.present) {
      map['layout_version'] = Variable<int>(layoutVersion.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SpacesCompanion(')
          ..write('id: $id, ')
          ..write('sceneId: $sceneId, ')
          ..write('name: $name, ')
          ..write('purchaseId: $purchaseId, ')
          ..write('layoutVersion: $layoutVersion, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class Entitlements extends Table with TableInfo<Entitlements, Entitlement> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Entitlements(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  static const VerificationMeta _purchaseIdMeta = const VerificationMeta(
    'purchaseId',
  );
  late final GeneratedColumn<String> purchaseId = GeneratedColumn<String>(
    'purchase_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES purchases(id)',
  );
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
    'item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _assetIdMeta = const VerificationMeta(
    'assetId',
  );
  late final GeneratedColumn<String> assetId = GeneratedColumn<String>(
    'asset_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _slotMeta = const VerificationMeta('slot');
  late final GeneratedColumn<String> slot = GeneratedColumn<String>(
    'slot',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints:
        'CHECK (slot IN (\'head\', \'face\', \'neck\', \'body\'))',
  );
  static const VerificationMeta _boundSpaceMeta = const VerificationMeta(
    'boundSpace',
  );
  late final GeneratedColumn<String> boundSpace = GeneratedColumn<String>(
    'bound_space',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'REFERENCES spaces(id)',
  );
  static const VerificationMeta _revokedMeta = const VerificationMeta(
    'revoked',
  );
  late final GeneratedColumn<int> revoked = GeneratedColumn<int>(
    'revoked',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0 CHECK (revoked IN (0, 1))',
    defaultValue: const CustomExpression('0'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    purchaseId,
    itemId,
    assetId,
    name,
    slot,
    boundSpace,
    revoked,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'entitlements';
  @override
  VerificationContext validateIntegrity(
    Insertable<Entitlement> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('purchase_id')) {
      context.handle(
        _purchaseIdMeta,
        purchaseId.isAcceptableOrUnknown(data['purchase_id']!, _purchaseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_purchaseIdMeta);
    }
    if (data.containsKey('item_id')) {
      context.handle(
        _itemIdMeta,
        itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta),
      );
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('asset_id')) {
      context.handle(
        _assetIdMeta,
        assetId.isAcceptableOrUnknown(data['asset_id']!, _assetIdMeta),
      );
    } else if (isInserting) {
      context.missing(_assetIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('slot')) {
      context.handle(
        _slotMeta,
        slot.isAcceptableOrUnknown(data['slot']!, _slotMeta),
      );
    }
    if (data.containsKey('bound_space')) {
      context.handle(
        _boundSpaceMeta,
        boundSpace.isAcceptableOrUnknown(data['bound_space']!, _boundSpaceMeta),
      );
    }
    if (data.containsKey('revoked')) {
      context.handle(
        _revokedMeta,
        revoked.isAcceptableOrUnknown(data['revoked']!, _revokedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {purchaseId, itemId},
  ];
  @override
  Entitlement map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Entitlement(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      purchaseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}purchase_id'],
      )!,
      itemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_id'],
      )!,
      assetId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}asset_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      slot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}slot'],
      ),
      boundSpace: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bound_space'],
      ),
      revoked: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revoked'],
      )!,
    );
  }

  @override
  Entitlements createAlias(String alias) {
    return Entitlements(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints => const ['UNIQUE(purchase_id, item_id)'];
  @override
  bool get dontWriteConstraints => true;
}

class Entitlement extends DataClass implements Insertable<Entitlement> {
  final String id;
  final String purchaseId;
  final String itemId;
  final String assetId;
  final String name;
  final String? slot;
  final String? boundSpace;
  final int revoked;
  const Entitlement({
    required this.id,
    required this.purchaseId,
    required this.itemId,
    required this.assetId,
    required this.name,
    this.slot,
    this.boundSpace,
    required this.revoked,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['purchase_id'] = Variable<String>(purchaseId);
    map['item_id'] = Variable<String>(itemId);
    map['asset_id'] = Variable<String>(assetId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || slot != null) {
      map['slot'] = Variable<String>(slot);
    }
    if (!nullToAbsent || boundSpace != null) {
      map['bound_space'] = Variable<String>(boundSpace);
    }
    map['revoked'] = Variable<int>(revoked);
    return map;
  }

  EntitlementsCompanion toCompanion(bool nullToAbsent) {
    return EntitlementsCompanion(
      id: Value(id),
      purchaseId: Value(purchaseId),
      itemId: Value(itemId),
      assetId: Value(assetId),
      name: Value(name),
      slot: slot == null && nullToAbsent ? const Value.absent() : Value(slot),
      boundSpace: boundSpace == null && nullToAbsent
          ? const Value.absent()
          : Value(boundSpace),
      revoked: Value(revoked),
    );
  }

  factory Entitlement.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Entitlement(
      id: serializer.fromJson<String>(json['id']),
      purchaseId: serializer.fromJson<String>(json['purchase_id']),
      itemId: serializer.fromJson<String>(json['item_id']),
      assetId: serializer.fromJson<String>(json['asset_id']),
      name: serializer.fromJson<String>(json['name']),
      slot: serializer.fromJson<String?>(json['slot']),
      boundSpace: serializer.fromJson<String?>(json['bound_space']),
      revoked: serializer.fromJson<int>(json['revoked']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'purchase_id': serializer.toJson<String>(purchaseId),
      'item_id': serializer.toJson<String>(itemId),
      'asset_id': serializer.toJson<String>(assetId),
      'name': serializer.toJson<String>(name),
      'slot': serializer.toJson<String?>(slot),
      'bound_space': serializer.toJson<String?>(boundSpace),
      'revoked': serializer.toJson<int>(revoked),
    };
  }

  Entitlement copyWith({
    String? id,
    String? purchaseId,
    String? itemId,
    String? assetId,
    String? name,
    Value<String?> slot = const Value.absent(),
    Value<String?> boundSpace = const Value.absent(),
    int? revoked,
  }) => Entitlement(
    id: id ?? this.id,
    purchaseId: purchaseId ?? this.purchaseId,
    itemId: itemId ?? this.itemId,
    assetId: assetId ?? this.assetId,
    name: name ?? this.name,
    slot: slot.present ? slot.value : this.slot,
    boundSpace: boundSpace.present ? boundSpace.value : this.boundSpace,
    revoked: revoked ?? this.revoked,
  );
  Entitlement copyWithCompanion(EntitlementsCompanion data) {
    return Entitlement(
      id: data.id.present ? data.id.value : this.id,
      purchaseId: data.purchaseId.present
          ? data.purchaseId.value
          : this.purchaseId,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      assetId: data.assetId.present ? data.assetId.value : this.assetId,
      name: data.name.present ? data.name.value : this.name,
      slot: data.slot.present ? data.slot.value : this.slot,
      boundSpace: data.boundSpace.present
          ? data.boundSpace.value
          : this.boundSpace,
      revoked: data.revoked.present ? data.revoked.value : this.revoked,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Entitlement(')
          ..write('id: $id, ')
          ..write('purchaseId: $purchaseId, ')
          ..write('itemId: $itemId, ')
          ..write('assetId: $assetId, ')
          ..write('name: $name, ')
          ..write('slot: $slot, ')
          ..write('boundSpace: $boundSpace, ')
          ..write('revoked: $revoked')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    purchaseId,
    itemId,
    assetId,
    name,
    slot,
    boundSpace,
    revoked,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Entitlement &&
          other.id == this.id &&
          other.purchaseId == this.purchaseId &&
          other.itemId == this.itemId &&
          other.assetId == this.assetId &&
          other.name == this.name &&
          other.slot == this.slot &&
          other.boundSpace == this.boundSpace &&
          other.revoked == this.revoked);
}

class EntitlementsCompanion extends UpdateCompanion<Entitlement> {
  final Value<String> id;
  final Value<String> purchaseId;
  final Value<String> itemId;
  final Value<String> assetId;
  final Value<String> name;
  final Value<String?> slot;
  final Value<String?> boundSpace;
  final Value<int> revoked;
  final Value<int> rowid;
  const EntitlementsCompanion({
    this.id = const Value.absent(),
    this.purchaseId = const Value.absent(),
    this.itemId = const Value.absent(),
    this.assetId = const Value.absent(),
    this.name = const Value.absent(),
    this.slot = const Value.absent(),
    this.boundSpace = const Value.absent(),
    this.revoked = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EntitlementsCompanion.insert({
    required String id,
    required String purchaseId,
    required String itemId,
    required String assetId,
    required String name,
    this.slot = const Value.absent(),
    this.boundSpace = const Value.absent(),
    this.revoked = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       purchaseId = Value(purchaseId),
       itemId = Value(itemId),
       assetId = Value(assetId),
       name = Value(name);
  static Insertable<Entitlement> custom({
    Expression<String>? id,
    Expression<String>? purchaseId,
    Expression<String>? itemId,
    Expression<String>? assetId,
    Expression<String>? name,
    Expression<String>? slot,
    Expression<String>? boundSpace,
    Expression<int>? revoked,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (purchaseId != null) 'purchase_id': purchaseId,
      if (itemId != null) 'item_id': itemId,
      if (assetId != null) 'asset_id': assetId,
      if (name != null) 'name': name,
      if (slot != null) 'slot': slot,
      if (boundSpace != null) 'bound_space': boundSpace,
      if (revoked != null) 'revoked': revoked,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EntitlementsCompanion copyWith({
    Value<String>? id,
    Value<String>? purchaseId,
    Value<String>? itemId,
    Value<String>? assetId,
    Value<String>? name,
    Value<String?>? slot,
    Value<String?>? boundSpace,
    Value<int>? revoked,
    Value<int>? rowid,
  }) {
    return EntitlementsCompanion(
      id: id ?? this.id,
      purchaseId: purchaseId ?? this.purchaseId,
      itemId: itemId ?? this.itemId,
      assetId: assetId ?? this.assetId,
      name: name ?? this.name,
      slot: slot ?? this.slot,
      boundSpace: boundSpace ?? this.boundSpace,
      revoked: revoked ?? this.revoked,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (purchaseId.present) {
      map['purchase_id'] = Variable<String>(purchaseId.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (assetId.present) {
      map['asset_id'] = Variable<String>(assetId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (slot.present) {
      map['slot'] = Variable<String>(slot.value);
    }
    if (boundSpace.present) {
      map['bound_space'] = Variable<String>(boundSpace.value);
    }
    if (revoked.present) {
      map['revoked'] = Variable<int>(revoked.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EntitlementsCompanion(')
          ..write('id: $id, ')
          ..write('purchaseId: $purchaseId, ')
          ..write('itemId: $itemId, ')
          ..write('assetId: $assetId, ')
          ..write('name: $name, ')
          ..write('slot: $slot, ')
          ..write('boundSpace: $boundSpace, ')
          ..write('revoked: $revoked, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class Placements extends Table with TableInfo<Placements, Placement> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Placements(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _entitlementIdMeta = const VerificationMeta(
    'entitlementId',
  );
  late final GeneratedColumn<String> entitlementId = GeneratedColumn<String>(
    'entitlement_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL PRIMARY KEY REFERENCES entitlements(id)',
  );
  static const VerificationMeta _spaceIdMeta = const VerificationMeta(
    'spaceId',
  );
  late final GeneratedColumn<String> spaceId = GeneratedColumn<String>(
    'space_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES spaces(id)',
  );
  static const VerificationMeta _xMeta = const VerificationMeta('x');
  late final GeneratedColumn<double> x = GeneratedColumn<double>(
    'x',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (x BETWEEN 0 AND 1)',
  );
  static const VerificationMeta _yMeta = const VerificationMeta('y');
  late final GeneratedColumn<double> y = GeneratedColumn<double>(
    'y',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (y BETWEEN 0 AND 1)',
  );
  static const VerificationMeta _rotationMeta = const VerificationMeta(
    'rotation',
  );
  late final GeneratedColumn<int> rotation = GeneratedColumn<int>(
    'rotation',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const CustomExpression('0'),
  );
  static const VerificationMeta _flippedMeta = const VerificationMeta(
    'flipped',
  );
  late final GeneratedColumn<int> flipped = GeneratedColumn<int>(
    'flipped',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0 CHECK (flipped IN (0, 1))',
    defaultValue: const CustomExpression('0'),
  );
  static const VerificationMeta _zMeta = const VerificationMeta('z');
  late final GeneratedColumn<int> z = GeneratedColumn<int>(
    'z',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _mountIdMeta = const VerificationMeta(
    'mountId',
  );
  late final GeneratedColumn<String> mountId = GeneratedColumn<String>(
    'mount_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  @override
  List<GeneratedColumn> get $columns => [
    entitlementId,
    spaceId,
    x,
    y,
    rotation,
    flipped,
    z,
    mountId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'placements';
  @override
  VerificationContext validateIntegrity(
    Insertable<Placement> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('entitlement_id')) {
      context.handle(
        _entitlementIdMeta,
        entitlementId.isAcceptableOrUnknown(
          data['entitlement_id']!,
          _entitlementIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_entitlementIdMeta);
    }
    if (data.containsKey('space_id')) {
      context.handle(
        _spaceIdMeta,
        spaceId.isAcceptableOrUnknown(data['space_id']!, _spaceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_spaceIdMeta);
    }
    if (data.containsKey('x')) {
      context.handle(_xMeta, x.isAcceptableOrUnknown(data['x']!, _xMeta));
    } else if (isInserting) {
      context.missing(_xMeta);
    }
    if (data.containsKey('y')) {
      context.handle(_yMeta, y.isAcceptableOrUnknown(data['y']!, _yMeta));
    } else if (isInserting) {
      context.missing(_yMeta);
    }
    if (data.containsKey('rotation')) {
      context.handle(
        _rotationMeta,
        rotation.isAcceptableOrUnknown(data['rotation']!, _rotationMeta),
      );
    }
    if (data.containsKey('flipped')) {
      context.handle(
        _flippedMeta,
        flipped.isAcceptableOrUnknown(data['flipped']!, _flippedMeta),
      );
    }
    if (data.containsKey('z')) {
      context.handle(_zMeta, z.isAcceptableOrUnknown(data['z']!, _zMeta));
    } else if (isInserting) {
      context.missing(_zMeta);
    }
    if (data.containsKey('mount_id')) {
      context.handle(
        _mountIdMeta,
        mountId.isAcceptableOrUnknown(data['mount_id']!, _mountIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {entitlementId};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {spaceId, mountId},
  ];
  @override
  Placement map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Placement(
      entitlementId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entitlement_id'],
      )!,
      spaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}space_id'],
      )!,
      x: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}x'],
      )!,
      y: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}y'],
      )!,
      rotation: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rotation'],
      )!,
      flipped: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}flipped'],
      )!,
      z: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}z'],
      )!,
      mountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mount_id'],
      ),
    );
  }

  @override
  Placements createAlias(String alias) {
    return Placements(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints => const ['UNIQUE(space_id, mount_id)'];
  @override
  bool get dontWriteConstraints => true;
}

class Placement extends DataClass implements Insertable<Placement> {
  final String entitlementId;
  final String spaceId;
  final double x;
  final double y;
  final int rotation;
  final int flipped;
  final int z;
  final String? mountId;
  const Placement({
    required this.entitlementId,
    required this.spaceId,
    required this.x,
    required this.y,
    required this.rotation,
    required this.flipped,
    required this.z,
    this.mountId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['entitlement_id'] = Variable<String>(entitlementId);
    map['space_id'] = Variable<String>(spaceId);
    map['x'] = Variable<double>(x);
    map['y'] = Variable<double>(y);
    map['rotation'] = Variable<int>(rotation);
    map['flipped'] = Variable<int>(flipped);
    map['z'] = Variable<int>(z);
    if (!nullToAbsent || mountId != null) {
      map['mount_id'] = Variable<String>(mountId);
    }
    return map;
  }

  PlacementsCompanion toCompanion(bool nullToAbsent) {
    return PlacementsCompanion(
      entitlementId: Value(entitlementId),
      spaceId: Value(spaceId),
      x: Value(x),
      y: Value(y),
      rotation: Value(rotation),
      flipped: Value(flipped),
      z: Value(z),
      mountId: mountId == null && nullToAbsent
          ? const Value.absent()
          : Value(mountId),
    );
  }

  factory Placement.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Placement(
      entitlementId: serializer.fromJson<String>(json['entitlement_id']),
      spaceId: serializer.fromJson<String>(json['space_id']),
      x: serializer.fromJson<double>(json['x']),
      y: serializer.fromJson<double>(json['y']),
      rotation: serializer.fromJson<int>(json['rotation']),
      flipped: serializer.fromJson<int>(json['flipped']),
      z: serializer.fromJson<int>(json['z']),
      mountId: serializer.fromJson<String?>(json['mount_id']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'entitlement_id': serializer.toJson<String>(entitlementId),
      'space_id': serializer.toJson<String>(spaceId),
      'x': serializer.toJson<double>(x),
      'y': serializer.toJson<double>(y),
      'rotation': serializer.toJson<int>(rotation),
      'flipped': serializer.toJson<int>(flipped),
      'z': serializer.toJson<int>(z),
      'mount_id': serializer.toJson<String?>(mountId),
    };
  }

  Placement copyWith({
    String? entitlementId,
    String? spaceId,
    double? x,
    double? y,
    int? rotation,
    int? flipped,
    int? z,
    Value<String?> mountId = const Value.absent(),
  }) => Placement(
    entitlementId: entitlementId ?? this.entitlementId,
    spaceId: spaceId ?? this.spaceId,
    x: x ?? this.x,
    y: y ?? this.y,
    rotation: rotation ?? this.rotation,
    flipped: flipped ?? this.flipped,
    z: z ?? this.z,
    mountId: mountId.present ? mountId.value : this.mountId,
  );
  Placement copyWithCompanion(PlacementsCompanion data) {
    return Placement(
      entitlementId: data.entitlementId.present
          ? data.entitlementId.value
          : this.entitlementId,
      spaceId: data.spaceId.present ? data.spaceId.value : this.spaceId,
      x: data.x.present ? data.x.value : this.x,
      y: data.y.present ? data.y.value : this.y,
      rotation: data.rotation.present ? data.rotation.value : this.rotation,
      flipped: data.flipped.present ? data.flipped.value : this.flipped,
      z: data.z.present ? data.z.value : this.z,
      mountId: data.mountId.present ? data.mountId.value : this.mountId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Placement(')
          ..write('entitlementId: $entitlementId, ')
          ..write('spaceId: $spaceId, ')
          ..write('x: $x, ')
          ..write('y: $y, ')
          ..write('rotation: $rotation, ')
          ..write('flipped: $flipped, ')
          ..write('z: $z, ')
          ..write('mountId: $mountId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(entitlementId, spaceId, x, y, rotation, flipped, z, mountId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Placement &&
          other.entitlementId == this.entitlementId &&
          other.spaceId == this.spaceId &&
          other.x == this.x &&
          other.y == this.y &&
          other.rotation == this.rotation &&
          other.flipped == this.flipped &&
          other.z == this.z &&
          other.mountId == this.mountId);
}

class PlacementsCompanion extends UpdateCompanion<Placement> {
  final Value<String> entitlementId;
  final Value<String> spaceId;
  final Value<double> x;
  final Value<double> y;
  final Value<int> rotation;
  final Value<int> flipped;
  final Value<int> z;
  final Value<String?> mountId;
  final Value<int> rowid;
  const PlacementsCompanion({
    this.entitlementId = const Value.absent(),
    this.spaceId = const Value.absent(),
    this.x = const Value.absent(),
    this.y = const Value.absent(),
    this.rotation = const Value.absent(),
    this.flipped = const Value.absent(),
    this.z = const Value.absent(),
    this.mountId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlacementsCompanion.insert({
    required String entitlementId,
    required String spaceId,
    required double x,
    required double y,
    this.rotation = const Value.absent(),
    this.flipped = const Value.absent(),
    required int z,
    this.mountId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : entitlementId = Value(entitlementId),
       spaceId = Value(spaceId),
       x = Value(x),
       y = Value(y),
       z = Value(z);
  static Insertable<Placement> custom({
    Expression<String>? entitlementId,
    Expression<String>? spaceId,
    Expression<double>? x,
    Expression<double>? y,
    Expression<int>? rotation,
    Expression<int>? flipped,
    Expression<int>? z,
    Expression<String>? mountId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (entitlementId != null) 'entitlement_id': entitlementId,
      if (spaceId != null) 'space_id': spaceId,
      if (x != null) 'x': x,
      if (y != null) 'y': y,
      if (rotation != null) 'rotation': rotation,
      if (flipped != null) 'flipped': flipped,
      if (z != null) 'z': z,
      if (mountId != null) 'mount_id': mountId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlacementsCompanion copyWith({
    Value<String>? entitlementId,
    Value<String>? spaceId,
    Value<double>? x,
    Value<double>? y,
    Value<int>? rotation,
    Value<int>? flipped,
    Value<int>? z,
    Value<String?>? mountId,
    Value<int>? rowid,
  }) {
    return PlacementsCompanion(
      entitlementId: entitlementId ?? this.entitlementId,
      spaceId: spaceId ?? this.spaceId,
      x: x ?? this.x,
      y: y ?? this.y,
      rotation: rotation ?? this.rotation,
      flipped: flipped ?? this.flipped,
      z: z ?? this.z,
      mountId: mountId ?? this.mountId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (entitlementId.present) {
      map['entitlement_id'] = Variable<String>(entitlementId.value);
    }
    if (spaceId.present) {
      map['space_id'] = Variable<String>(spaceId.value);
    }
    if (x.present) {
      map['x'] = Variable<double>(x.value);
    }
    if (y.present) {
      map['y'] = Variable<double>(y.value);
    }
    if (rotation.present) {
      map['rotation'] = Variable<int>(rotation.value);
    }
    if (flipped.present) {
      map['flipped'] = Variable<int>(flipped.value);
    }
    if (z.present) {
      map['z'] = Variable<int>(z.value);
    }
    if (mountId.present) {
      map['mount_id'] = Variable<String>(mountId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlacementsCompanion(')
          ..write('entitlementId: $entitlementId, ')
          ..write('spaceId: $spaceId, ')
          ..write('x: $x, ')
          ..write('y: $y, ')
          ..write('rotation: $rotation, ')
          ..write('flipped: $flipped, ')
          ..write('z: $z, ')
          ..write('mountId: $mountId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class PetState extends Table with TableInfo<PetState, PetStateData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  PetState(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _petIdMeta = const VerificationMeta('petId');
  late final GeneratedColumn<String> petId = GeneratedColumn<String>(
    'pet_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints:
        'NOT NULL CHECK (pet_id IN (\'fox\', \'rabbit\', \'cat\'))',
  );
  static const VerificationMeta _slotMeta = const VerificationMeta('slot');
  late final GeneratedColumn<String> slot = GeneratedColumn<String>(
    'slot',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints:
        'NOT NULL CHECK (slot IN (\'head\', \'face\', \'neck\', \'body\'))',
  );
  static const VerificationMeta _entitlementIdMeta = const VerificationMeta(
    'entitlementId',
  );
  late final GeneratedColumn<String> entitlementId = GeneratedColumn<String>(
    'entitlement_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES entitlements(id)',
  );
  @override
  List<GeneratedColumn> get $columns => [petId, slot, entitlementId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pet_state';
  @override
  VerificationContext validateIntegrity(
    Insertable<PetStateData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('pet_id')) {
      context.handle(
        _petIdMeta,
        petId.isAcceptableOrUnknown(data['pet_id']!, _petIdMeta),
      );
    } else if (isInserting) {
      context.missing(_petIdMeta);
    }
    if (data.containsKey('slot')) {
      context.handle(
        _slotMeta,
        slot.isAcceptableOrUnknown(data['slot']!, _slotMeta),
      );
    } else if (isInserting) {
      context.missing(_slotMeta);
    }
    if (data.containsKey('entitlement_id')) {
      context.handle(
        _entitlementIdMeta,
        entitlementId.isAcceptableOrUnknown(
          data['entitlement_id']!,
          _entitlementIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_entitlementIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {petId, slot};
  @override
  PetStateData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PetStateData(
      petId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pet_id'],
      )!,
      slot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}slot'],
      )!,
      entitlementId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entitlement_id'],
      )!,
    );
  }

  @override
  PetState createAlias(String alias) {
    return PetState(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints => const ['PRIMARY KEY(pet_id, slot)'];
  @override
  bool get dontWriteConstraints => true;
}

class PetStateData extends DataClass implements Insertable<PetStateData> {
  final String petId;
  final String slot;
  final String entitlementId;
  const PetStateData({
    required this.petId,
    required this.slot,
    required this.entitlementId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['pet_id'] = Variable<String>(petId);
    map['slot'] = Variable<String>(slot);
    map['entitlement_id'] = Variable<String>(entitlementId);
    return map;
  }

  PetStateCompanion toCompanion(bool nullToAbsent) {
    return PetStateCompanion(
      petId: Value(petId),
      slot: Value(slot),
      entitlementId: Value(entitlementId),
    );
  }

  factory PetStateData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PetStateData(
      petId: serializer.fromJson<String>(json['pet_id']),
      slot: serializer.fromJson<String>(json['slot']),
      entitlementId: serializer.fromJson<String>(json['entitlement_id']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'pet_id': serializer.toJson<String>(petId),
      'slot': serializer.toJson<String>(slot),
      'entitlement_id': serializer.toJson<String>(entitlementId),
    };
  }

  PetStateData copyWith({String? petId, String? slot, String? entitlementId}) =>
      PetStateData(
        petId: petId ?? this.petId,
        slot: slot ?? this.slot,
        entitlementId: entitlementId ?? this.entitlementId,
      );
  PetStateData copyWithCompanion(PetStateCompanion data) {
    return PetStateData(
      petId: data.petId.present ? data.petId.value : this.petId,
      slot: data.slot.present ? data.slot.value : this.slot,
      entitlementId: data.entitlementId.present
          ? data.entitlementId.value
          : this.entitlementId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PetStateData(')
          ..write('petId: $petId, ')
          ..write('slot: $slot, ')
          ..write('entitlementId: $entitlementId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(petId, slot, entitlementId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PetStateData &&
          other.petId == this.petId &&
          other.slot == this.slot &&
          other.entitlementId == this.entitlementId);
}

class PetStateCompanion extends UpdateCompanion<PetStateData> {
  final Value<String> petId;
  final Value<String> slot;
  final Value<String> entitlementId;
  final Value<int> rowid;
  const PetStateCompanion({
    this.petId = const Value.absent(),
    this.slot = const Value.absent(),
    this.entitlementId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PetStateCompanion.insert({
    required String petId,
    required String slot,
    required String entitlementId,
    this.rowid = const Value.absent(),
  }) : petId = Value(petId),
       slot = Value(slot),
       entitlementId = Value(entitlementId);
  static Insertable<PetStateData> custom({
    Expression<String>? petId,
    Expression<String>? slot,
    Expression<String>? entitlementId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (petId != null) 'pet_id': petId,
      if (slot != null) 'slot': slot,
      if (entitlementId != null) 'entitlement_id': entitlementId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PetStateCompanion copyWith({
    Value<String>? petId,
    Value<String>? slot,
    Value<String>? entitlementId,
    Value<int>? rowid,
  }) {
    return PetStateCompanion(
      petId: petId ?? this.petId,
      slot: slot ?? this.slot,
      entitlementId: entitlementId ?? this.entitlementId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (petId.present) {
      map['pet_id'] = Variable<String>(petId.value);
    }
    if (slot.present) {
      map['slot'] = Variable<String>(slot.value);
    }
    if (entitlementId.present) {
      map['entitlement_id'] = Variable<String>(entitlementId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PetStateCompanion(')
          ..write('petId: $petId, ')
          ..write('slot: $slot, ')
          ..write('entitlementId: $entitlementId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class GrowthAwards extends Table with TableInfo<GrowthAwards, GrowthAward> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  GrowthAwards(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _childIdMeta = const VerificationMeta(
    'childId',
  );
  late final GeneratedColumn<String> childId = GeneratedColumn<String>(
    'child_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES child_profiles(id)',
  );
  static const VerificationMeta _thresholdMeta = const VerificationMeta(
    'threshold',
  );
  late final GeneratedColumn<int> threshold = GeneratedColumn<int>(
    'threshold',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _stageMeta = const VerificationMeta('stage');
  late final GeneratedColumn<int> stage = GeneratedColumn<int>(
    'stage',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (stage BETWEEN 2 AND 6)',
  );
  static const VerificationMeta _awardedAtMeta = const VerificationMeta(
    'awardedAt',
  );
  late final GeneratedColumn<int> awardedAt = GeneratedColumn<int>(
    'awarded_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  @override
  List<GeneratedColumn> get $columns => [childId, threshold, stage, awardedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'growth_awards';
  @override
  VerificationContext validateIntegrity(
    Insertable<GrowthAward> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('child_id')) {
      context.handle(
        _childIdMeta,
        childId.isAcceptableOrUnknown(data['child_id']!, _childIdMeta),
      );
    } else if (isInserting) {
      context.missing(_childIdMeta);
    }
    if (data.containsKey('threshold')) {
      context.handle(
        _thresholdMeta,
        threshold.isAcceptableOrUnknown(data['threshold']!, _thresholdMeta),
      );
    } else if (isInserting) {
      context.missing(_thresholdMeta);
    }
    if (data.containsKey('stage')) {
      context.handle(
        _stageMeta,
        stage.isAcceptableOrUnknown(data['stage']!, _stageMeta),
      );
    } else if (isInserting) {
      context.missing(_stageMeta);
    }
    if (data.containsKey('awarded_at')) {
      context.handle(
        _awardedAtMeta,
        awardedAt.isAcceptableOrUnknown(data['awarded_at']!, _awardedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_awardedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {childId, threshold};
  @override
  GrowthAward map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GrowthAward(
      childId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}child_id'],
      )!,
      threshold: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}threshold'],
      )!,
      stage: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}stage'],
      )!,
      awardedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}awarded_at'],
      )!,
    );
  }

  @override
  GrowthAwards createAlias(String alias) {
    return GrowthAwards(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints => const [
    'PRIMARY KEY(child_id, threshold)',
  ];
  @override
  bool get dontWriteConstraints => true;
}

class GrowthAward extends DataClass implements Insertable<GrowthAward> {
  final String childId;
  final int threshold;
  final int stage;
  final int awardedAt;
  const GrowthAward({
    required this.childId,
    required this.threshold,
    required this.stage,
    required this.awardedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['child_id'] = Variable<String>(childId);
    map['threshold'] = Variable<int>(threshold);
    map['stage'] = Variable<int>(stage);
    map['awarded_at'] = Variable<int>(awardedAt);
    return map;
  }

  GrowthAwardsCompanion toCompanion(bool nullToAbsent) {
    return GrowthAwardsCompanion(
      childId: Value(childId),
      threshold: Value(threshold),
      stage: Value(stage),
      awardedAt: Value(awardedAt),
    );
  }

  factory GrowthAward.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GrowthAward(
      childId: serializer.fromJson<String>(json['child_id']),
      threshold: serializer.fromJson<int>(json['threshold']),
      stage: serializer.fromJson<int>(json['stage']),
      awardedAt: serializer.fromJson<int>(json['awarded_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'child_id': serializer.toJson<String>(childId),
      'threshold': serializer.toJson<int>(threshold),
      'stage': serializer.toJson<int>(stage),
      'awarded_at': serializer.toJson<int>(awardedAt),
    };
  }

  GrowthAward copyWith({
    String? childId,
    int? threshold,
    int? stage,
    int? awardedAt,
  }) => GrowthAward(
    childId: childId ?? this.childId,
    threshold: threshold ?? this.threshold,
    stage: stage ?? this.stage,
    awardedAt: awardedAt ?? this.awardedAt,
  );
  GrowthAward copyWithCompanion(GrowthAwardsCompanion data) {
    return GrowthAward(
      childId: data.childId.present ? data.childId.value : this.childId,
      threshold: data.threshold.present ? data.threshold.value : this.threshold,
      stage: data.stage.present ? data.stage.value : this.stage,
      awardedAt: data.awardedAt.present ? data.awardedAt.value : this.awardedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GrowthAward(')
          ..write('childId: $childId, ')
          ..write('threshold: $threshold, ')
          ..write('stage: $stage, ')
          ..write('awardedAt: $awardedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(childId, threshold, stage, awardedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GrowthAward &&
          other.childId == this.childId &&
          other.threshold == this.threshold &&
          other.stage == this.stage &&
          other.awardedAt == this.awardedAt);
}

class GrowthAwardsCompanion extends UpdateCompanion<GrowthAward> {
  final Value<String> childId;
  final Value<int> threshold;
  final Value<int> stage;
  final Value<int> awardedAt;
  final Value<int> rowid;
  const GrowthAwardsCompanion({
    this.childId = const Value.absent(),
    this.threshold = const Value.absent(),
    this.stage = const Value.absent(),
    this.awardedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GrowthAwardsCompanion.insert({
    required String childId,
    required int threshold,
    required int stage,
    required int awardedAt,
    this.rowid = const Value.absent(),
  }) : childId = Value(childId),
       threshold = Value(threshold),
       stage = Value(stage),
       awardedAt = Value(awardedAt);
  static Insertable<GrowthAward> custom({
    Expression<String>? childId,
    Expression<int>? threshold,
    Expression<int>? stage,
    Expression<int>? awardedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (childId != null) 'child_id': childId,
      if (threshold != null) 'threshold': threshold,
      if (stage != null) 'stage': stage,
      if (awardedAt != null) 'awarded_at': awardedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GrowthAwardsCompanion copyWith({
    Value<String>? childId,
    Value<int>? threshold,
    Value<int>? stage,
    Value<int>? awardedAt,
    Value<int>? rowid,
  }) {
    return GrowthAwardsCompanion(
      childId: childId ?? this.childId,
      threshold: threshold ?? this.threshold,
      stage: stage ?? this.stage,
      awardedAt: awardedAt ?? this.awardedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (childId.present) {
      map['child_id'] = Variable<String>(childId.value);
    }
    if (threshold.present) {
      map['threshold'] = Variable<int>(threshold.value);
    }
    if (stage.present) {
      map['stage'] = Variable<int>(stage.value);
    }
    if (awardedAt.present) {
      map['awarded_at'] = Variable<int>(awardedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GrowthAwardsCompanion(')
          ..write('childId: $childId, ')
          ..write('threshold: $threshold, ')
          ..write('stage: $stage, ')
          ..write('awardedAt: $awardedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class Wishes extends Table with TableInfo<Wishes, Wishe> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Wishes(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _childIdMeta = const VerificationMeta(
    'childId',
  );
  late final GeneratedColumn<String> childId = GeneratedColumn<String>(
    'child_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL PRIMARY KEY REFERENCES child_profiles(id)',
  );
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
    'item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _selectedPriceMeta = const VerificationMeta(
    'selectedPrice',
  );
  late final GeneratedColumn<int> selectedPrice = GeneratedColumn<int>(
    'selected_price',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (selected_price > 0)',
  );
  static const VerificationMeta _selectedAtMeta = const VerificationMeta(
    'selectedAt',
  );
  late final GeneratedColumn<int> selectedAt = GeneratedColumn<int>(
    'selected_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  @override
  List<GeneratedColumn> get $columns => [
    childId,
    itemId,
    selectedPrice,
    selectedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'wishes';
  @override
  VerificationContext validateIntegrity(
    Insertable<Wishe> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('child_id')) {
      context.handle(
        _childIdMeta,
        childId.isAcceptableOrUnknown(data['child_id']!, _childIdMeta),
      );
    } else if (isInserting) {
      context.missing(_childIdMeta);
    }
    if (data.containsKey('item_id')) {
      context.handle(
        _itemIdMeta,
        itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta),
      );
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('selected_price')) {
      context.handle(
        _selectedPriceMeta,
        selectedPrice.isAcceptableOrUnknown(
          data['selected_price']!,
          _selectedPriceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_selectedPriceMeta);
    }
    if (data.containsKey('selected_at')) {
      context.handle(
        _selectedAtMeta,
        selectedAt.isAcceptableOrUnknown(data['selected_at']!, _selectedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_selectedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {childId};
  @override
  Wishe map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Wishe(
      childId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}child_id'],
      )!,
      itemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_id'],
      )!,
      selectedPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}selected_price'],
      )!,
      selectedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}selected_at'],
      )!,
    );
  }

  @override
  Wishes createAlias(String alias) {
    return Wishes(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class Wishe extends DataClass implements Insertable<Wishe> {
  final String childId;
  final String itemId;
  final int selectedPrice;
  final int selectedAt;
  const Wishe({
    required this.childId,
    required this.itemId,
    required this.selectedPrice,
    required this.selectedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['child_id'] = Variable<String>(childId);
    map['item_id'] = Variable<String>(itemId);
    map['selected_price'] = Variable<int>(selectedPrice);
    map['selected_at'] = Variable<int>(selectedAt);
    return map;
  }

  WishesCompanion toCompanion(bool nullToAbsent) {
    return WishesCompanion(
      childId: Value(childId),
      itemId: Value(itemId),
      selectedPrice: Value(selectedPrice),
      selectedAt: Value(selectedAt),
    );
  }

  factory Wishe.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Wishe(
      childId: serializer.fromJson<String>(json['child_id']),
      itemId: serializer.fromJson<String>(json['item_id']),
      selectedPrice: serializer.fromJson<int>(json['selected_price']),
      selectedAt: serializer.fromJson<int>(json['selected_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'child_id': serializer.toJson<String>(childId),
      'item_id': serializer.toJson<String>(itemId),
      'selected_price': serializer.toJson<int>(selectedPrice),
      'selected_at': serializer.toJson<int>(selectedAt),
    };
  }

  Wishe copyWith({
    String? childId,
    String? itemId,
    int? selectedPrice,
    int? selectedAt,
  }) => Wishe(
    childId: childId ?? this.childId,
    itemId: itemId ?? this.itemId,
    selectedPrice: selectedPrice ?? this.selectedPrice,
    selectedAt: selectedAt ?? this.selectedAt,
  );
  Wishe copyWithCompanion(WishesCompanion data) {
    return Wishe(
      childId: data.childId.present ? data.childId.value : this.childId,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      selectedPrice: data.selectedPrice.present
          ? data.selectedPrice.value
          : this.selectedPrice,
      selectedAt: data.selectedAt.present
          ? data.selectedAt.value
          : this.selectedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Wishe(')
          ..write('childId: $childId, ')
          ..write('itemId: $itemId, ')
          ..write('selectedPrice: $selectedPrice, ')
          ..write('selectedAt: $selectedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(childId, itemId, selectedPrice, selectedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Wishe &&
          other.childId == this.childId &&
          other.itemId == this.itemId &&
          other.selectedPrice == this.selectedPrice &&
          other.selectedAt == this.selectedAt);
}

class WishesCompanion extends UpdateCompanion<Wishe> {
  final Value<String> childId;
  final Value<String> itemId;
  final Value<int> selectedPrice;
  final Value<int> selectedAt;
  final Value<int> rowid;
  const WishesCompanion({
    this.childId = const Value.absent(),
    this.itemId = const Value.absent(),
    this.selectedPrice = const Value.absent(),
    this.selectedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WishesCompanion.insert({
    required String childId,
    required String itemId,
    required int selectedPrice,
    required int selectedAt,
    this.rowid = const Value.absent(),
  }) : childId = Value(childId),
       itemId = Value(itemId),
       selectedPrice = Value(selectedPrice),
       selectedAt = Value(selectedAt);
  static Insertable<Wishe> custom({
    Expression<String>? childId,
    Expression<String>? itemId,
    Expression<int>? selectedPrice,
    Expression<int>? selectedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (childId != null) 'child_id': childId,
      if (itemId != null) 'item_id': itemId,
      if (selectedPrice != null) 'selected_price': selectedPrice,
      if (selectedAt != null) 'selected_at': selectedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WishesCompanion copyWith({
    Value<String>? childId,
    Value<String>? itemId,
    Value<int>? selectedPrice,
    Value<int>? selectedAt,
    Value<int>? rowid,
  }) {
    return WishesCompanion(
      childId: childId ?? this.childId,
      itemId: itemId ?? this.itemId,
      selectedPrice: selectedPrice ?? this.selectedPrice,
      selectedAt: selectedAt ?? this.selectedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (childId.present) {
      map['child_id'] = Variable<String>(childId.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (selectedPrice.present) {
      map['selected_price'] = Variable<int>(selectedPrice.value);
    }
    if (selectedAt.present) {
      map['selected_at'] = Variable<int>(selectedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WishesCompanion(')
          ..write('childId: $childId, ')
          ..write('itemId: $itemId, ')
          ..write('selectedPrice: $selectedPrice, ')
          ..write('selectedAt: $selectedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class CorrectionRecords extends Table
    with TableInfo<CorrectionRecords, CorrectionRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  CorrectionRecords(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _instanceIdMeta = const VerificationMeta(
    'instanceId',
  );
  late final GeneratedColumn<String> instanceId = GeneratedColumn<String>(
    'instance_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL PRIMARY KEY REFERENCES task_instances(id)',
  );
  static const VerificationMeta _originalRewardIdMeta = const VerificationMeta(
    'originalRewardId',
  );
  late final GeneratedColumn<String> originalRewardId = GeneratedColumn<String>(
    'original_reward_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL UNIQUE REFERENCES ledger_entries(id)',
  );
  static const VerificationMeta _recoveredMeta = const VerificationMeta(
    'recovered',
  );
  late final GeneratedColumn<int> recovered = GeneratedColumn<int>(
    'recovered',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (recovered >= 0)',
  );
  static const VerificationMeta _shortfallMeta = const VerificationMeta(
    'shortfall',
  );
  late final GeneratedColumn<int> shortfall = GeneratedColumn<int>(
    'shortfall',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (shortfall >= 0)',
  );
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
    'reason',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _refundedPurchaseIdsMeta =
      const VerificationMeta('refundedPurchaseIds');
  late final GeneratedColumn<String> refundedPurchaseIds =
      GeneratedColumn<String>(
        'refunded_purchase_ids',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
        $customConstraints: 'NOT NULL',
      );
  static const VerificationMeta _commandIdMeta = const VerificationMeta(
    'commandId',
  );
  late final GeneratedColumn<String> commandId = GeneratedColumn<String>(
    'command_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL UNIQUE',
  );
  @override
  List<GeneratedColumn> get $columns => [
    instanceId,
    originalRewardId,
    recovered,
    shortfall,
    reason,
    refundedPurchaseIds,
    commandId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'correction_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<CorrectionRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('instance_id')) {
      context.handle(
        _instanceIdMeta,
        instanceId.isAcceptableOrUnknown(data['instance_id']!, _instanceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_instanceIdMeta);
    }
    if (data.containsKey('original_reward_id')) {
      context.handle(
        _originalRewardIdMeta,
        originalRewardId.isAcceptableOrUnknown(
          data['original_reward_id']!,
          _originalRewardIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_originalRewardIdMeta);
    }
    if (data.containsKey('recovered')) {
      context.handle(
        _recoveredMeta,
        recovered.isAcceptableOrUnknown(data['recovered']!, _recoveredMeta),
      );
    } else if (isInserting) {
      context.missing(_recoveredMeta);
    }
    if (data.containsKey('shortfall')) {
      context.handle(
        _shortfallMeta,
        shortfall.isAcceptableOrUnknown(data['shortfall']!, _shortfallMeta),
      );
    } else if (isInserting) {
      context.missing(_shortfallMeta);
    }
    if (data.containsKey('reason')) {
      context.handle(
        _reasonMeta,
        reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta),
      );
    } else if (isInserting) {
      context.missing(_reasonMeta);
    }
    if (data.containsKey('refunded_purchase_ids')) {
      context.handle(
        _refundedPurchaseIdsMeta,
        refundedPurchaseIds.isAcceptableOrUnknown(
          data['refunded_purchase_ids']!,
          _refundedPurchaseIdsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_refundedPurchaseIdsMeta);
    }
    if (data.containsKey('command_id')) {
      context.handle(
        _commandIdMeta,
        commandId.isAcceptableOrUnknown(data['command_id']!, _commandIdMeta),
      );
    } else if (isInserting) {
      context.missing(_commandIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {instanceId};
  @override
  CorrectionRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CorrectionRecord(
      instanceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}instance_id'],
      )!,
      originalRewardId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}original_reward_id'],
      )!,
      recovered: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}recovered'],
      )!,
      shortfall: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}shortfall'],
      )!,
      reason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason'],
      )!,
      refundedPurchaseIds: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}refunded_purchase_ids'],
      )!,
      commandId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}command_id'],
      )!,
    );
  }

  @override
  CorrectionRecords createAlias(String alias) {
    return CorrectionRecords(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class CorrectionRecord extends DataClass
    implements Insertable<CorrectionRecord> {
  final String instanceId;
  final String originalRewardId;
  final int recovered;
  final int shortfall;
  final String reason;
  final String refundedPurchaseIds;
  final String commandId;
  const CorrectionRecord({
    required this.instanceId,
    required this.originalRewardId,
    required this.recovered,
    required this.shortfall,
    required this.reason,
    required this.refundedPurchaseIds,
    required this.commandId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['instance_id'] = Variable<String>(instanceId);
    map['original_reward_id'] = Variable<String>(originalRewardId);
    map['recovered'] = Variable<int>(recovered);
    map['shortfall'] = Variable<int>(shortfall);
    map['reason'] = Variable<String>(reason);
    map['refunded_purchase_ids'] = Variable<String>(refundedPurchaseIds);
    map['command_id'] = Variable<String>(commandId);
    return map;
  }

  CorrectionRecordsCompanion toCompanion(bool nullToAbsent) {
    return CorrectionRecordsCompanion(
      instanceId: Value(instanceId),
      originalRewardId: Value(originalRewardId),
      recovered: Value(recovered),
      shortfall: Value(shortfall),
      reason: Value(reason),
      refundedPurchaseIds: Value(refundedPurchaseIds),
      commandId: Value(commandId),
    );
  }

  factory CorrectionRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CorrectionRecord(
      instanceId: serializer.fromJson<String>(json['instance_id']),
      originalRewardId: serializer.fromJson<String>(json['original_reward_id']),
      recovered: serializer.fromJson<int>(json['recovered']),
      shortfall: serializer.fromJson<int>(json['shortfall']),
      reason: serializer.fromJson<String>(json['reason']),
      refundedPurchaseIds: serializer.fromJson<String>(
        json['refunded_purchase_ids'],
      ),
      commandId: serializer.fromJson<String>(json['command_id']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'instance_id': serializer.toJson<String>(instanceId),
      'original_reward_id': serializer.toJson<String>(originalRewardId),
      'recovered': serializer.toJson<int>(recovered),
      'shortfall': serializer.toJson<int>(shortfall),
      'reason': serializer.toJson<String>(reason),
      'refunded_purchase_ids': serializer.toJson<String>(refundedPurchaseIds),
      'command_id': serializer.toJson<String>(commandId),
    };
  }

  CorrectionRecord copyWith({
    String? instanceId,
    String? originalRewardId,
    int? recovered,
    int? shortfall,
    String? reason,
    String? refundedPurchaseIds,
    String? commandId,
  }) => CorrectionRecord(
    instanceId: instanceId ?? this.instanceId,
    originalRewardId: originalRewardId ?? this.originalRewardId,
    recovered: recovered ?? this.recovered,
    shortfall: shortfall ?? this.shortfall,
    reason: reason ?? this.reason,
    refundedPurchaseIds: refundedPurchaseIds ?? this.refundedPurchaseIds,
    commandId: commandId ?? this.commandId,
  );
  CorrectionRecord copyWithCompanion(CorrectionRecordsCompanion data) {
    return CorrectionRecord(
      instanceId: data.instanceId.present
          ? data.instanceId.value
          : this.instanceId,
      originalRewardId: data.originalRewardId.present
          ? data.originalRewardId.value
          : this.originalRewardId,
      recovered: data.recovered.present ? data.recovered.value : this.recovered,
      shortfall: data.shortfall.present ? data.shortfall.value : this.shortfall,
      reason: data.reason.present ? data.reason.value : this.reason,
      refundedPurchaseIds: data.refundedPurchaseIds.present
          ? data.refundedPurchaseIds.value
          : this.refundedPurchaseIds,
      commandId: data.commandId.present ? data.commandId.value : this.commandId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CorrectionRecord(')
          ..write('instanceId: $instanceId, ')
          ..write('originalRewardId: $originalRewardId, ')
          ..write('recovered: $recovered, ')
          ..write('shortfall: $shortfall, ')
          ..write('reason: $reason, ')
          ..write('refundedPurchaseIds: $refundedPurchaseIds, ')
          ..write('commandId: $commandId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    instanceId,
    originalRewardId,
    recovered,
    shortfall,
    reason,
    refundedPurchaseIds,
    commandId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CorrectionRecord &&
          other.instanceId == this.instanceId &&
          other.originalRewardId == this.originalRewardId &&
          other.recovered == this.recovered &&
          other.shortfall == this.shortfall &&
          other.reason == this.reason &&
          other.refundedPurchaseIds == this.refundedPurchaseIds &&
          other.commandId == this.commandId);
}

class CorrectionRecordsCompanion extends UpdateCompanion<CorrectionRecord> {
  final Value<String> instanceId;
  final Value<String> originalRewardId;
  final Value<int> recovered;
  final Value<int> shortfall;
  final Value<String> reason;
  final Value<String> refundedPurchaseIds;
  final Value<String> commandId;
  final Value<int> rowid;
  const CorrectionRecordsCompanion({
    this.instanceId = const Value.absent(),
    this.originalRewardId = const Value.absent(),
    this.recovered = const Value.absent(),
    this.shortfall = const Value.absent(),
    this.reason = const Value.absent(),
    this.refundedPurchaseIds = const Value.absent(),
    this.commandId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CorrectionRecordsCompanion.insert({
    required String instanceId,
    required String originalRewardId,
    required int recovered,
    required int shortfall,
    required String reason,
    required String refundedPurchaseIds,
    required String commandId,
    this.rowid = const Value.absent(),
  }) : instanceId = Value(instanceId),
       originalRewardId = Value(originalRewardId),
       recovered = Value(recovered),
       shortfall = Value(shortfall),
       reason = Value(reason),
       refundedPurchaseIds = Value(refundedPurchaseIds),
       commandId = Value(commandId);
  static Insertable<CorrectionRecord> custom({
    Expression<String>? instanceId,
    Expression<String>? originalRewardId,
    Expression<int>? recovered,
    Expression<int>? shortfall,
    Expression<String>? reason,
    Expression<String>? refundedPurchaseIds,
    Expression<String>? commandId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (instanceId != null) 'instance_id': instanceId,
      if (originalRewardId != null) 'original_reward_id': originalRewardId,
      if (recovered != null) 'recovered': recovered,
      if (shortfall != null) 'shortfall': shortfall,
      if (reason != null) 'reason': reason,
      if (refundedPurchaseIds != null)
        'refunded_purchase_ids': refundedPurchaseIds,
      if (commandId != null) 'command_id': commandId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CorrectionRecordsCompanion copyWith({
    Value<String>? instanceId,
    Value<String>? originalRewardId,
    Value<int>? recovered,
    Value<int>? shortfall,
    Value<String>? reason,
    Value<String>? refundedPurchaseIds,
    Value<String>? commandId,
    Value<int>? rowid,
  }) {
    return CorrectionRecordsCompanion(
      instanceId: instanceId ?? this.instanceId,
      originalRewardId: originalRewardId ?? this.originalRewardId,
      recovered: recovered ?? this.recovered,
      shortfall: shortfall ?? this.shortfall,
      reason: reason ?? this.reason,
      refundedPurchaseIds: refundedPurchaseIds ?? this.refundedPurchaseIds,
      commandId: commandId ?? this.commandId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (instanceId.present) {
      map['instance_id'] = Variable<String>(instanceId.value);
    }
    if (originalRewardId.present) {
      map['original_reward_id'] = Variable<String>(originalRewardId.value);
    }
    if (recovered.present) {
      map['recovered'] = Variable<int>(recovered.value);
    }
    if (shortfall.present) {
      map['shortfall'] = Variable<int>(shortfall.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (refundedPurchaseIds.present) {
      map['refunded_purchase_ids'] = Variable<String>(
        refundedPurchaseIds.value,
      );
    }
    if (commandId.present) {
      map['command_id'] = Variable<String>(commandId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CorrectionRecordsCompanion(')
          ..write('instanceId: $instanceId, ')
          ..write('originalRewardId: $originalRewardId, ')
          ..write('recovered: $recovered, ')
          ..write('shortfall: $shortfall, ')
          ..write('reason: $reason, ')
          ..write('refundedPurchaseIds: $refundedPurchaseIds, ')
          ..write('commandId: $commandId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$FamilyDatabase extends GeneratedDatabase {
  _$FamilyDatabase(QueryExecutor e) : super(e);
  $FamilyDatabaseManager get managers => $FamilyDatabaseManager(this);
  late final Households households = Households(this);
  late final ChildProfiles childProfiles = ChildProfiles(this);
  late final Accounts accounts = Accounts(this);
  late final TaskTemplates taskTemplates = TaskTemplates(this);
  late final TaskVersions taskVersions = TaskVersions(this);
  late final ProjectStages projectStages = ProjectStages(this);
  late final TaskInstances taskInstances = TaskInstances(this);
  late final Index taskStateIdx = Index(
    'task_state_idx',
    'CREATE INDEX task_state_idx ON task_instances (state, planned_day)',
  );
  late final Index taskPlanIdx = Index(
    'task_plan_idx',
    'CREATE INDEX task_plan_idx ON task_instances (template_id, planned_day, slot)',
  );
  late final Submissions submissions = Submissions(this);
  late final Index submissionInstanceIdx = Index(
    'submission_instance_idx',
    'CREATE INDEX submission_instance_idx ON submissions (instance_id, created_at)',
  );
  late final Completions completions = Completions(this);
  late final Index completionDateIdx = Index(
    'completion_date_idx',
    'CREATE INDEX completion_date_idx ON completions (is_valid, actual_date)',
  );
  late final LedgerEntries ledgerEntries = LedgerEntries(this);
  late final ProcessedCommands processedCommands = ProcessedCommands(this);
  late final PenaltyRules penaltyRules = PenaltyRules(this);
  late final PenaltyEvents penaltyEvents = PenaltyEvents(this);
  late final PenaltyDayUsage penaltyDayUsage = PenaltyDayUsage(this);
  late final Purchases purchases = Purchases(this);
  late final Index purchasedOnce = Index(
    'purchased_once',
    'CREATE UNIQUE INDEX purchased_once ON purchases (item_id) WHERE refunded_at IS NULL',
  );
  late final Spaces spaces = Spaces(this);
  late final Entitlements entitlements = Entitlements(this);
  late final Index activeEntitlement = Index(
    'active_entitlement',
    'CREATE UNIQUE INDEX active_entitlement ON entitlements (item_id) WHERE revoked = 0',
  );
  late final Placements placements = Placements(this);
  late final PetState petState = PetState(this);
  late final GrowthAwards growthAwards = GrowthAwards(this);
  late final Wishes wishes = Wishes(this);
  late final CorrectionRecords correctionRecords = CorrectionRecords(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    households,
    childProfiles,
    accounts,
    taskTemplates,
    taskVersions,
    projectStages,
    taskInstances,
    taskStateIdx,
    taskPlanIdx,
    submissions,
    submissionInstanceIdx,
    completions,
    completionDateIdx,
    ledgerEntries,
    processedCommands,
    penaltyRules,
    penaltyEvents,
    penaltyDayUsage,
    purchases,
    purchasedOnce,
    spaces,
    entitlements,
    activeEntitlement,
    placements,
    petState,
    growthAwards,
    wishes,
    correctionRecords,
  ];
}

typedef $HouseholdsCreateCompanionBuilder = HouseholdsCompanion Function({
  required String id,
  Value<int> singleton,
  required String lineageId,
  required String timezone,
  required String rulesVersion,
  required String catalogVersion,
  Value<int> domainRevision,
  Value<String?> latestLocalDay,
  Value<int> rowid,
});
typedef $HouseholdsUpdateCompanionBuilder = HouseholdsCompanion Function({
  Value<String> id,
  Value<int> singleton,
  Value<String> lineageId,
  Value<String> timezone,
  Value<String> rulesVersion,
  Value<String> catalogVersion,
  Value<int> domainRevision,
  Value<String?> latestLocalDay,
  Value<int> rowid,
});

final class $HouseholdsReferences
    extends BaseReferences<_$FamilyDatabase, Households, Household> {
  $HouseholdsReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<ChildProfiles, List<ChildProfile>>
  _childProfilesRefsTable(_$FamilyDatabase db) => MultiTypedResultKey.fromTable(
    db.childProfiles,
    aliasName: 'households__id__child_profiles__family_id',
  );

  $ChildProfilesProcessedTableManager get childProfilesRefs {
    final manager = $ChildProfilesTableManager(
      $_db,
      $_db.childProfiles,
    ).filter((f) => f.familyId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_childProfilesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<TaskTemplates, List<TaskTemplate>>
  _taskTemplatesRefsTable(_$FamilyDatabase db) => MultiTypedResultKey.fromTable(
    db.taskTemplates,
    aliasName: 'households__id__task_templates__family_id',
  );

  $TaskTemplatesProcessedTableManager get taskTemplatesRefs {
    final manager = $TaskTemplatesTableManager(
      $_db,
      $_db.taskTemplates,
    ).filter((f) => f.familyId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_taskTemplatesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $HouseholdsFilterComposer extends Composer<_$FamilyDatabase, Households> {
  $HouseholdsFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get singleton => $composableBuilder(
    column: $table.singleton,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lineageId => $composableBuilder(
    column: $table.lineageId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get timezone => $composableBuilder(
    column: $table.timezone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rulesVersion => $composableBuilder(
    column: $table.rulesVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get catalogVersion => $composableBuilder(
    column: $table.catalogVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get domainRevision => $composableBuilder(
    column: $table.domainRevision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get latestLocalDay => $composableBuilder(
    column: $table.latestLocalDay,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> childProfilesRefs(
    Expression<bool> Function($ChildProfilesFilterComposer f) f,
  ) {
    final $ChildProfilesFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.childProfiles,
      getReferencedColumn: (t) => t.familyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ChildProfilesFilterComposer(
            $db: $db,
            $table: $db.childProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> taskTemplatesRefs(
    Expression<bool> Function($TaskTemplatesFilterComposer f) f,
  ) {
    final $TaskTemplatesFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.taskTemplates,
      getReferencedColumn: (t) => t.familyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $TaskTemplatesFilterComposer(
            $db: $db,
            $table: $db.taskTemplates,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $HouseholdsOrderingComposer
    extends Composer<_$FamilyDatabase, Households> {
  $HouseholdsOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get singleton => $composableBuilder(
    column: $table.singleton,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lineageId => $composableBuilder(
    column: $table.lineageId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get timezone => $composableBuilder(
    column: $table.timezone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rulesVersion => $composableBuilder(
    column: $table.rulesVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get catalogVersion => $composableBuilder(
    column: $table.catalogVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get domainRevision => $composableBuilder(
    column: $table.domainRevision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get latestLocalDay => $composableBuilder(
    column: $table.latestLocalDay,
    builder: (column) => ColumnOrderings(column),
  );
}

class $HouseholdsAnnotationComposer
    extends Composer<_$FamilyDatabase, Households> {
  $HouseholdsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get singleton =>
      $composableBuilder(column: $table.singleton, builder: (column) => column);

  GeneratedColumn<String> get lineageId =>
      $composableBuilder(column: $table.lineageId, builder: (column) => column);

  GeneratedColumn<String> get timezone =>
      $composableBuilder(column: $table.timezone, builder: (column) => column);

  GeneratedColumn<String> get rulesVersion => $composableBuilder(
    column: $table.rulesVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get catalogVersion => $composableBuilder(
    column: $table.catalogVersion,
    builder: (column) => column,
  );

  GeneratedColumn<int> get domainRevision => $composableBuilder(
    column: $table.domainRevision,
    builder: (column) => column,
  );

  GeneratedColumn<String> get latestLocalDay => $composableBuilder(
    column: $table.latestLocalDay,
    builder: (column) => column,
  );

  Expression<T> childProfilesRefs<T extends Object>(
    Expression<T> Function($ChildProfilesAnnotationComposer a) f,
  ) {
    final $ChildProfilesAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.childProfiles,
      getReferencedColumn: (t) => t.familyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ChildProfilesAnnotationComposer(
            $db: $db,
            $table: $db.childProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> taskTemplatesRefs<T extends Object>(
    Expression<T> Function($TaskTemplatesAnnotationComposer a) f,
  ) {
    final $TaskTemplatesAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.taskTemplates,
      getReferencedColumn: (t) => t.familyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $TaskTemplatesAnnotationComposer(
            $db: $db,
            $table: $db.taskTemplates,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $HouseholdsTableManager
    extends
        RootTableManager<
          _$FamilyDatabase,
          Households,
          Household,
          $HouseholdsFilterComposer,
          $HouseholdsOrderingComposer,
          $HouseholdsAnnotationComposer,
          $HouseholdsCreateCompanionBuilder,
          $HouseholdsUpdateCompanionBuilder,
          (Household, $HouseholdsReferences),
          Household,
          PrefetchHooks Function({
            bool childProfilesRefs,
            bool taskTemplatesRefs,
          })
        > {
  $HouseholdsTableManager(_$FamilyDatabase db, Households table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $HouseholdsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $HouseholdsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $HouseholdsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> singleton = const Value.absent(),
                Value<String> lineageId = const Value.absent(),
                Value<String> timezone = const Value.absent(),
                Value<String> rulesVersion = const Value.absent(),
                Value<String> catalogVersion = const Value.absent(),
                Value<int> domainRevision = const Value.absent(),
                Value<String?> latestLocalDay = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HouseholdsCompanion(
                id: id,
                singleton: singleton,
                lineageId: lineageId,
                timezone: timezone,
                rulesVersion: rulesVersion,
                catalogVersion: catalogVersion,
                domainRevision: domainRevision,
                latestLocalDay: latestLocalDay,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<int> singleton = const Value.absent(),
                required String lineageId,
                required String timezone,
                required String rulesVersion,
                required String catalogVersion,
                Value<int> domainRevision = const Value.absent(),
                Value<String?> latestLocalDay = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HouseholdsCompanion.insert(
                id: id,
                singleton: singleton,
                lineageId: lineageId,
                timezone: timezone,
                rulesVersion: rulesVersion,
                catalogVersion: catalogVersion,
                domainRevision: domainRevision,
                latestLocalDay: latestLocalDay,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<Households, Household>(table),
                  $HouseholdsReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({childProfilesRefs = false, taskTemplatesRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (childProfilesRefs) db.childProfiles,
                    if (taskTemplatesRefs) db.taskTemplates,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (childProfilesRefs)
                        await $_getPrefetchedDataByColumns<
                          Household,
                          Households,
                          ChildProfile,
                          ChildProfiles
                        >(
                          currentTable: table,
                          referencedTable: $HouseholdsReferences
                              ._childProfilesRefsTable(db),
                          managerFromTypedResult: (p0) => $HouseholdsReferences(
                            db,
                            table,
                            p0,
                          ).childProfilesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'family_id',
                          typedResults: items,
                        ),
                      if (taskTemplatesRefs)
                        await $_getPrefetchedDataByColumns<
                          Household,
                          Households,
                          TaskTemplate,
                          TaskTemplates
                        >(
                          currentTable: table,
                          referencedTable: $HouseholdsReferences
                              ._taskTemplatesRefsTable(db),
                          managerFromTypedResult: (p0) => $HouseholdsReferences(
                            db,
                            table,
                            p0,
                          ).taskTemplatesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'family_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $HouseholdsProcessedTableManager =
    ProcessedTableManager<
      _$FamilyDatabase,
      Households,
      Household,
      $HouseholdsFilterComposer,
      $HouseholdsOrderingComposer,
      $HouseholdsAnnotationComposer,
      $HouseholdsCreateCompanionBuilder,
      $HouseholdsUpdateCompanionBuilder,
      (Household, $HouseholdsReferences),
      Household,
      PrefetchHooks Function({bool childProfilesRefs, bool taskTemplatesRefs})
    >;
typedef $ChildProfilesCreateCompanionBuilder = ChildProfilesCompanion Function({
  required String id,
  required String familyId,
  required String nickname,
  required String activePetId,
  Value<int> rowid,
});
typedef $ChildProfilesUpdateCompanionBuilder = ChildProfilesCompanion Function({
  Value<String> id,
  Value<String> familyId,
  Value<String> nickname,
  Value<String> activePetId,
  Value<int> rowid,
});

final class $ChildProfilesReferences
    extends BaseReferences<_$FamilyDatabase, ChildProfiles, ChildProfile> {
  $ChildProfilesReferences(super.$_db, super.$_table, super.$_typedResult);

  static Households _familyIdTable(_$FamilyDatabase db) =>
      db.households.createAlias('child_profiles__family_id__households__id');

  $HouseholdsProcessedTableManager get familyId {
    final $_column = $_itemColumn<String>('family_id')!;

    final manager = $HouseholdsTableManager(
      $_db,
      $_db.households,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_familyIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<Accounts, List<Account>> _accountsRefsTable(
    _$FamilyDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.accounts,
    aliasName: 'child_profiles__id__accounts__child_id',
  );

  $AccountsProcessedTableManager get accountsRefs {
    final manager = $AccountsTableManager(
      $_db,
      $_db.accounts,
    ).filter((f) => f.childId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_accountsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<GrowthAwards, List<GrowthAward>>
  _growthAwardsRefsTable(_$FamilyDatabase db) => MultiTypedResultKey.fromTable(
    db.growthAwards,
    aliasName: 'child_profiles__id__growth_awards__child_id',
  );

  $GrowthAwardsProcessedTableManager get growthAwardsRefs {
    final manager = $GrowthAwardsTableManager(
      $_db,
      $_db.growthAwards,
    ).filter((f) => f.childId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_growthAwardsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<Wishes, List<Wishe>> _wishesRefsTable(
    _$FamilyDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.wishes,
    aliasName: 'child_profiles__id__wishes__child_id',
  );

  $WishesProcessedTableManager get wishesRefs {
    final manager = $WishesTableManager(
      $_db,
      $_db.wishes,
    ).filter((f) => f.childId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_wishesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $ChildProfilesFilterComposer
    extends Composer<_$FamilyDatabase, ChildProfiles> {
  $ChildProfilesFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nickname => $composableBuilder(
    column: $table.nickname,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get activePetId => $composableBuilder(
    column: $table.activePetId,
    builder: (column) => ColumnFilters(column),
  );

  $HouseholdsFilterComposer get familyId {
    final $HouseholdsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.familyId,
      referencedTable: $db.households,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $HouseholdsFilterComposer(
            $db: $db,
            $table: $db.households,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> accountsRefs(
    Expression<bool> Function($AccountsFilterComposer f) f,
  ) {
    final $AccountsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.childId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $AccountsFilterComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> growthAwardsRefs(
    Expression<bool> Function($GrowthAwardsFilterComposer f) f,
  ) {
    final $GrowthAwardsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.growthAwards,
      getReferencedColumn: (t) => t.childId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $GrowthAwardsFilterComposer(
            $db: $db,
            $table: $db.growthAwards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> wishesRefs(
    Expression<bool> Function($WishesFilterComposer f) f,
  ) {
    final $WishesFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.wishes,
      getReferencedColumn: (t) => t.childId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $WishesFilterComposer(
            $db: $db,
            $table: $db.wishes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $ChildProfilesOrderingComposer
    extends Composer<_$FamilyDatabase, ChildProfiles> {
  $ChildProfilesOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nickname => $composableBuilder(
    column: $table.nickname,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get activePetId => $composableBuilder(
    column: $table.activePetId,
    builder: (column) => ColumnOrderings(column),
  );

  $HouseholdsOrderingComposer get familyId {
    final $HouseholdsOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.familyId,
      referencedTable: $db.households,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $HouseholdsOrderingComposer(
            $db: $db,
            $table: $db.households,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $ChildProfilesAnnotationComposer
    extends Composer<_$FamilyDatabase, ChildProfiles> {
  $ChildProfilesAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nickname =>
      $composableBuilder(column: $table.nickname, builder: (column) => column);

  GeneratedColumn<String> get activePetId => $composableBuilder(
    column: $table.activePetId,
    builder: (column) => column,
  );

  $HouseholdsAnnotationComposer get familyId {
    final $HouseholdsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.familyId,
      referencedTable: $db.households,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $HouseholdsAnnotationComposer(
            $db: $db,
            $table: $db.households,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> accountsRefs<T extends Object>(
    Expression<T> Function($AccountsAnnotationComposer a) f,
  ) {
    final $AccountsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.childId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $AccountsAnnotationComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> growthAwardsRefs<T extends Object>(
    Expression<T> Function($GrowthAwardsAnnotationComposer a) f,
  ) {
    final $GrowthAwardsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.growthAwards,
      getReferencedColumn: (t) => t.childId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $GrowthAwardsAnnotationComposer(
            $db: $db,
            $table: $db.growthAwards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> wishesRefs<T extends Object>(
    Expression<T> Function($WishesAnnotationComposer a) f,
  ) {
    final $WishesAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.wishes,
      getReferencedColumn: (t) => t.childId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $WishesAnnotationComposer(
            $db: $db,
            $table: $db.wishes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $ChildProfilesTableManager
    extends
        RootTableManager<
          _$FamilyDatabase,
          ChildProfiles,
          ChildProfile,
          $ChildProfilesFilterComposer,
          $ChildProfilesOrderingComposer,
          $ChildProfilesAnnotationComposer,
          $ChildProfilesCreateCompanionBuilder,
          $ChildProfilesUpdateCompanionBuilder,
          (ChildProfile, $ChildProfilesReferences),
          ChildProfile,
          PrefetchHooks Function({
            bool familyId,
            bool accountsRefs,
            bool growthAwardsRefs,
            bool wishesRefs,
          })
        > {
  $ChildProfilesTableManager(_$FamilyDatabase db, ChildProfiles table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $ChildProfilesFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $ChildProfilesOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $ChildProfilesAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> familyId = const Value.absent(),
                Value<String> nickname = const Value.absent(),
                Value<String> activePetId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChildProfilesCompanion(
                id: id,
                familyId: familyId,
                nickname: nickname,
                activePetId: activePetId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String familyId,
                required String nickname,
                required String activePetId,
                Value<int> rowid = const Value.absent(),
              }) => ChildProfilesCompanion.insert(
                id: id,
                familyId: familyId,
                nickname: nickname,
                activePetId: activePetId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<ChildProfiles, ChildProfile>(table),
                  $ChildProfilesReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                familyId = false,
                accountsRefs = false,
                growthAwardsRefs = false,
                wishesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (accountsRefs) db.accounts,
                    if (growthAwardsRefs) db.growthAwards,
                    if (wishesRefs) db.wishes,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (familyId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.familyId,
                            referencedTable: $ChildProfilesReferences
                                ._familyIdTable(db),
                            referencedColumn: $ChildProfilesReferences
                                ._familyIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (accountsRefs)
                        await $_getPrefetchedDataByColumns<
                          ChildProfile,
                          ChildProfiles,
                          Account,
                          Accounts
                        >(
                          currentTable: table,
                          referencedTable: $ChildProfilesReferences
                              ._accountsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $ChildProfilesReferences(
                                db,
                                table,
                                p0,
                              ).accountsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'child_id',
                          typedResults: items,
                        ),
                      if (growthAwardsRefs)
                        await $_getPrefetchedDataByColumns<
                          ChildProfile,
                          ChildProfiles,
                          GrowthAward,
                          GrowthAwards
                        >(
                          currentTable: table,
                          referencedTable: $ChildProfilesReferences
                              ._growthAwardsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $ChildProfilesReferences(
                                db,
                                table,
                                p0,
                              ).growthAwardsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'child_id',
                          typedResults: items,
                        ),
                      if (wishesRefs)
                        await $_getPrefetchedDataByColumns<
                          ChildProfile,
                          ChildProfiles,
                          Wishe,
                          Wishes
                        >(
                          currentTable: table,
                          referencedTable: $ChildProfilesReferences
                              ._wishesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $ChildProfilesReferences(
                                db,
                                table,
                                p0,
                              ).wishesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'child_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $ChildProfilesProcessedTableManager =
    ProcessedTableManager<
      _$FamilyDatabase,
      ChildProfiles,
      ChildProfile,
      $ChildProfilesFilterComposer,
      $ChildProfilesOrderingComposer,
      $ChildProfilesAnnotationComposer,
      $ChildProfilesCreateCompanionBuilder,
      $ChildProfilesUpdateCompanionBuilder,
      (ChildProfile, $ChildProfilesReferences),
      ChildProfile,
      PrefetchHooks Function({
        bool familyId,
        bool accountsRefs,
        bool growthAwardsRefs,
        bool wishesRefs,
      })
    >;
typedef $AccountsCreateCompanionBuilder = AccountsCompanion Function({
  required String id,
  required String childId,
  Value<int> balance,
  Value<int> rowid,
});
typedef $AccountsUpdateCompanionBuilder = AccountsCompanion Function({
  Value<String> id,
  Value<String> childId,
  Value<int> balance,
  Value<int> rowid,
});

final class $AccountsReferences
    extends BaseReferences<_$FamilyDatabase, Accounts, Account> {
  $AccountsReferences(super.$_db, super.$_table, super.$_typedResult);

  static ChildProfiles _childIdTable(_$FamilyDatabase db) =>
      db.childProfiles.createAlias('accounts__child_id__child_profiles__id');

  $ChildProfilesProcessedTableManager get childId {
    final $_column = $_itemColumn<String>('child_id')!;

    final manager = $ChildProfilesTableManager(
      $_db,
      $_db.childProfiles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_childIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<LedgerEntries, List<LedgerEntry>>
  _ledgerEntriesRefsTable(_$FamilyDatabase db) => MultiTypedResultKey.fromTable(
    db.ledgerEntries,
    aliasName: 'accounts__id__ledger_entries__account_id',
  );

  $LedgerEntriesProcessedTableManager get ledgerEntriesRefs {
    final manager = $LedgerEntriesTableManager(
      $_db,
      $_db.ledgerEntries,
    ).filter((f) => f.accountId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_ledgerEntriesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<PenaltyDayUsage, List<PenaltyDayUsageData>>
  _penaltyDayUsageRefsTable(_$FamilyDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.penaltyDayUsage,
        aliasName: 'accounts__id__penalty_day_usage__account_id',
      );

  $PenaltyDayUsageProcessedTableManager get penaltyDayUsageRefs {
    final manager = $PenaltyDayUsageTableManager(
      $_db,
      $_db.penaltyDayUsage,
    ).filter((f) => f.accountId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _penaltyDayUsageRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $AccountsFilterComposer extends Composer<_$FamilyDatabase, Accounts> {
  $AccountsFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get balance => $composableBuilder(
    column: $table.balance,
    builder: (column) => ColumnFilters(column),
  );

  $ChildProfilesFilterComposer get childId {
    final $ChildProfilesFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.childId,
      referencedTable: $db.childProfiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ChildProfilesFilterComposer(
            $db: $db,
            $table: $db.childProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> ledgerEntriesRefs(
    Expression<bool> Function($LedgerEntriesFilterComposer f) f,
  ) {
    final $LedgerEntriesFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.ledgerEntries,
      getReferencedColumn: (t) => t.accountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $LedgerEntriesFilterComposer(
            $db: $db,
            $table: $db.ledgerEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> penaltyDayUsageRefs(
    Expression<bool> Function($PenaltyDayUsageFilterComposer f) f,
  ) {
    final $PenaltyDayUsageFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.penaltyDayUsage,
      getReferencedColumn: (t) => t.accountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $PenaltyDayUsageFilterComposer(
            $db: $db,
            $table: $db.penaltyDayUsage,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $AccountsOrderingComposer extends Composer<_$FamilyDatabase, Accounts> {
  $AccountsOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get balance => $composableBuilder(
    column: $table.balance,
    builder: (column) => ColumnOrderings(column),
  );

  $ChildProfilesOrderingComposer get childId {
    final $ChildProfilesOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.childId,
      referencedTable: $db.childProfiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ChildProfilesOrderingComposer(
            $db: $db,
            $table: $db.childProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $AccountsAnnotationComposer extends Composer<_$FamilyDatabase, Accounts> {
  $AccountsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get balance =>
      $composableBuilder(column: $table.balance, builder: (column) => column);

  $ChildProfilesAnnotationComposer get childId {
    final $ChildProfilesAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.childId,
      referencedTable: $db.childProfiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ChildProfilesAnnotationComposer(
            $db: $db,
            $table: $db.childProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> ledgerEntriesRefs<T extends Object>(
    Expression<T> Function($LedgerEntriesAnnotationComposer a) f,
  ) {
    final $LedgerEntriesAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.ledgerEntries,
      getReferencedColumn: (t) => t.accountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $LedgerEntriesAnnotationComposer(
            $db: $db,
            $table: $db.ledgerEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> penaltyDayUsageRefs<T extends Object>(
    Expression<T> Function($PenaltyDayUsageAnnotationComposer a) f,
  ) {
    final $PenaltyDayUsageAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.penaltyDayUsage,
      getReferencedColumn: (t) => t.accountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $PenaltyDayUsageAnnotationComposer(
            $db: $db,
            $table: $db.penaltyDayUsage,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $AccountsTableManager
    extends
        RootTableManager<
          _$FamilyDatabase,
          Accounts,
          Account,
          $AccountsFilterComposer,
          $AccountsOrderingComposer,
          $AccountsAnnotationComposer,
          $AccountsCreateCompanionBuilder,
          $AccountsUpdateCompanionBuilder,
          (Account, $AccountsReferences),
          Account,
          PrefetchHooks Function({
            bool childId,
            bool ledgerEntriesRefs,
            bool penaltyDayUsageRefs,
          })
        > {
  $AccountsTableManager(_$FamilyDatabase db, Accounts table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $AccountsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $AccountsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $AccountsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> childId = const Value.absent(),
                Value<int> balance = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AccountsCompanion(
                id: id,
                childId: childId,
                balance: balance,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String childId,
                Value<int> balance = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AccountsCompanion.insert(
                id: id,
                childId: childId,
                balance: balance,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<Accounts, Account>(table),
                  $AccountsReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                childId = false,
                ledgerEntriesRefs = false,
                penaltyDayUsageRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (ledgerEntriesRefs) db.ledgerEntries,
                    if (penaltyDayUsageRefs) db.penaltyDayUsage,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (childId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.childId,
                            referencedTable: $AccountsReferences._childIdTable(
                              db,
                            ),
                            referencedColumn: $AccountsReferences
                                ._childIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (ledgerEntriesRefs)
                        await $_getPrefetchedDataByColumns<
                          Account,
                          Accounts,
                          LedgerEntry,
                          LedgerEntries
                        >(
                          currentTable: table,
                          referencedTable: $AccountsReferences
                              ._ledgerEntriesRefsTable(db),
                          managerFromTypedResult: (p0) => $AccountsReferences(
                            db,
                            table,
                            p0,
                          ).ledgerEntriesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'account_id',
                          typedResults: items,
                        ),
                      if (penaltyDayUsageRefs)
                        await $_getPrefetchedDataByColumns<
                          Account,
                          Accounts,
                          PenaltyDayUsageData,
                          PenaltyDayUsage
                        >(
                          currentTable: table,
                          referencedTable: $AccountsReferences
                              ._penaltyDayUsageRefsTable(db),
                          managerFromTypedResult: (p0) => $AccountsReferences(
                            db,
                            table,
                            p0,
                          ).penaltyDayUsageRefs,
                          currentColumn: 'id',
                          referencedColumn: 'account_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $AccountsProcessedTableManager =
    ProcessedTableManager<
      _$FamilyDatabase,
      Accounts,
      Account,
      $AccountsFilterComposer,
      $AccountsOrderingComposer,
      $AccountsAnnotationComposer,
      $AccountsCreateCompanionBuilder,
      $AccountsUpdateCompanionBuilder,
      (Account, $AccountsReferences),
      Account,
      PrefetchHooks Function({
        bool childId,
        bool ledgerEntriesRefs,
        bool penaltyDayUsageRefs,
      })
    >;
typedef $TaskTemplatesCreateCompanionBuilder = TaskTemplatesCompanion Function({
  required String id,
  required String familyId,
  required String mode,
  Value<int> currentVersion,
  Value<int> paused,
  Value<int> rowid,
});
typedef $TaskTemplatesUpdateCompanionBuilder = TaskTemplatesCompanion Function({
  Value<String> id,
  Value<String> familyId,
  Value<String> mode,
  Value<int> currentVersion,
  Value<int> paused,
  Value<int> rowid,
});

final class $TaskTemplatesReferences
    extends BaseReferences<_$FamilyDatabase, TaskTemplates, TaskTemplate> {
  $TaskTemplatesReferences(super.$_db, super.$_table, super.$_typedResult);

  static Households _familyIdTable(_$FamilyDatabase db) =>
      db.households.createAlias('task_templates__family_id__households__id');

  $HouseholdsProcessedTableManager get familyId {
    final $_column = $_itemColumn<String>('family_id')!;

    final manager = $HouseholdsTableManager(
      $_db,
      $_db.households,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_familyIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<TaskVersions, List<TaskVersion>>
  _taskVersionsRefsTable(_$FamilyDatabase db) => MultiTypedResultKey.fromTable(
    db.taskVersions,
    aliasName: 'task_templates__id__task_versions__template_id',
  );

  $TaskVersionsProcessedTableManager get taskVersionsRefs {
    final manager = $TaskVersionsTableManager(
      $_db,
      $_db.taskVersions,
    ).filter((f) => f.templateId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_taskVersionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<TaskInstances, List<TaskInstance>>
  _taskInstancesRefsTable(_$FamilyDatabase db) => MultiTypedResultKey.fromTable(
    db.taskInstances,
    aliasName: 'task_templates__id__task_instances__template_id',
  );

  $TaskInstancesProcessedTableManager get taskInstancesRefs {
    final manager = $TaskInstancesTableManager(
      $_db,
      $_db.taskInstances,
    ).filter((f) => f.templateId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_taskInstancesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $TaskTemplatesFilterComposer
    extends Composer<_$FamilyDatabase, TaskTemplates> {
  $TaskTemplatesFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get currentVersion => $composableBuilder(
    column: $table.currentVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get paused => $composableBuilder(
    column: $table.paused,
    builder: (column) => ColumnFilters(column),
  );

  $HouseholdsFilterComposer get familyId {
    final $HouseholdsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.familyId,
      referencedTable: $db.households,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $HouseholdsFilterComposer(
            $db: $db,
            $table: $db.households,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> taskVersionsRefs(
    Expression<bool> Function($TaskVersionsFilterComposer f) f,
  ) {
    final $TaskVersionsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.taskVersions,
      getReferencedColumn: (t) => t.templateId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $TaskVersionsFilterComposer(
            $db: $db,
            $table: $db.taskVersions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> taskInstancesRefs(
    Expression<bool> Function($TaskInstancesFilterComposer f) f,
  ) {
    final $TaskInstancesFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.taskInstances,
      getReferencedColumn: (t) => t.templateId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $TaskInstancesFilterComposer(
            $db: $db,
            $table: $db.taskInstances,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $TaskTemplatesOrderingComposer
    extends Composer<_$FamilyDatabase, TaskTemplates> {
  $TaskTemplatesOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get currentVersion => $composableBuilder(
    column: $table.currentVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get paused => $composableBuilder(
    column: $table.paused,
    builder: (column) => ColumnOrderings(column),
  );

  $HouseholdsOrderingComposer get familyId {
    final $HouseholdsOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.familyId,
      referencedTable: $db.households,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $HouseholdsOrderingComposer(
            $db: $db,
            $table: $db.households,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $TaskTemplatesAnnotationComposer
    extends Composer<_$FamilyDatabase, TaskTemplates> {
  $TaskTemplatesAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get mode =>
      $composableBuilder(column: $table.mode, builder: (column) => column);

  GeneratedColumn<int> get currentVersion => $composableBuilder(
    column: $table.currentVersion,
    builder: (column) => column,
  );

  GeneratedColumn<int> get paused =>
      $composableBuilder(column: $table.paused, builder: (column) => column);

  $HouseholdsAnnotationComposer get familyId {
    final $HouseholdsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.familyId,
      referencedTable: $db.households,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $HouseholdsAnnotationComposer(
            $db: $db,
            $table: $db.households,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> taskVersionsRefs<T extends Object>(
    Expression<T> Function($TaskVersionsAnnotationComposer a) f,
  ) {
    final $TaskVersionsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.taskVersions,
      getReferencedColumn: (t) => t.templateId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $TaskVersionsAnnotationComposer(
            $db: $db,
            $table: $db.taskVersions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> taskInstancesRefs<T extends Object>(
    Expression<T> Function($TaskInstancesAnnotationComposer a) f,
  ) {
    final $TaskInstancesAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.taskInstances,
      getReferencedColumn: (t) => t.templateId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $TaskInstancesAnnotationComposer(
            $db: $db,
            $table: $db.taskInstances,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $TaskTemplatesTableManager
    extends
        RootTableManager<
          _$FamilyDatabase,
          TaskTemplates,
          TaskTemplate,
          $TaskTemplatesFilterComposer,
          $TaskTemplatesOrderingComposer,
          $TaskTemplatesAnnotationComposer,
          $TaskTemplatesCreateCompanionBuilder,
          $TaskTemplatesUpdateCompanionBuilder,
          (TaskTemplate, $TaskTemplatesReferences),
          TaskTemplate,
          PrefetchHooks Function({
            bool familyId,
            bool taskVersionsRefs,
            bool taskInstancesRefs,
          })
        > {
  $TaskTemplatesTableManager(_$FamilyDatabase db, TaskTemplates table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $TaskTemplatesFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $TaskTemplatesOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $TaskTemplatesAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> familyId = const Value.absent(),
                Value<String> mode = const Value.absent(),
                Value<int> currentVersion = const Value.absent(),
                Value<int> paused = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TaskTemplatesCompanion(
                id: id,
                familyId: familyId,
                mode: mode,
                currentVersion: currentVersion,
                paused: paused,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String familyId,
                required String mode,
                Value<int> currentVersion = const Value.absent(),
                Value<int> paused = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TaskTemplatesCompanion.insert(
                id: id,
                familyId: familyId,
                mode: mode,
                currentVersion: currentVersion,
                paused: paused,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<TaskTemplates, TaskTemplate>(table),
                  $TaskTemplatesReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                familyId = false,
                taskVersionsRefs = false,
                taskInstancesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (taskVersionsRefs) db.taskVersions,
                    if (taskInstancesRefs) db.taskInstances,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (familyId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.familyId,
                            referencedTable: $TaskTemplatesReferences
                                ._familyIdTable(db),
                            referencedColumn: $TaskTemplatesReferences
                                ._familyIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (taskVersionsRefs)
                        await $_getPrefetchedDataByColumns<
                          TaskTemplate,
                          TaskTemplates,
                          TaskVersion,
                          TaskVersions
                        >(
                          currentTable: table,
                          referencedTable: $TaskTemplatesReferences
                              ._taskVersionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $TaskTemplatesReferences(
                                db,
                                table,
                                p0,
                              ).taskVersionsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'template_id',
                          typedResults: items,
                        ),
                      if (taskInstancesRefs)
                        await $_getPrefetchedDataByColumns<
                          TaskTemplate,
                          TaskTemplates,
                          TaskInstance,
                          TaskInstances
                        >(
                          currentTable: table,
                          referencedTable: $TaskTemplatesReferences
                              ._taskInstancesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $TaskTemplatesReferences(
                                db,
                                table,
                                p0,
                              ).taskInstancesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'template_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $TaskTemplatesProcessedTableManager =
    ProcessedTableManager<
      _$FamilyDatabase,
      TaskTemplates,
      TaskTemplate,
      $TaskTemplatesFilterComposer,
      $TaskTemplatesOrderingComposer,
      $TaskTemplatesAnnotationComposer,
      $TaskTemplatesCreateCompanionBuilder,
      $TaskTemplatesUpdateCompanionBuilder,
      (TaskTemplate, $TaskTemplatesReferences),
      TaskTemplate,
      PrefetchHooks Function({
        bool familyId,
        bool taskVersionsRefs,
        bool taskInstancesRefs,
      })
    >;
typedef $TaskVersionsCreateCompanionBuilder = TaskVersionsCompanion Function({
  required String id,
  required String templateId,
  required int version,
  required String title,
  required String content,
  required String criteria,
  required String taskType,
  required int reward,
  required String rulesVersion,
  required String scheduleJson,
  Value<int> rowid,
});
typedef $TaskVersionsUpdateCompanionBuilder = TaskVersionsCompanion Function({
  Value<String> id,
  Value<String> templateId,
  Value<int> version,
  Value<String> title,
  Value<String> content,
  Value<String> criteria,
  Value<String> taskType,
  Value<int> reward,
  Value<String> rulesVersion,
  Value<String> scheduleJson,
  Value<int> rowid,
});

final class $TaskVersionsReferences
    extends BaseReferences<_$FamilyDatabase, TaskVersions, TaskVersion> {
  $TaskVersionsReferences(super.$_db, super.$_table, super.$_typedResult);

  static TaskTemplates _templateIdTable(_$FamilyDatabase db) => db.taskTemplates
      .createAlias('task_versions__template_id__task_templates__id');

  $TaskTemplatesProcessedTableManager get templateId {
    final $_column = $_itemColumn<String>('template_id')!;

    final manager = $TaskTemplatesTableManager(
      $_db,
      $_db.taskTemplates,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_templateIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<ProjectStages, List<ProjectStage>>
  _projectStagesRefsTable(_$FamilyDatabase db) => MultiTypedResultKey.fromTable(
    db.projectStages,
    aliasName: 'task_versions__id__project_stages__version_id',
  );

  $ProjectStagesProcessedTableManager get projectStagesRefs {
    final manager = $ProjectStagesTableManager(
      $_db,
      $_db.projectStages,
    ).filter((f) => f.versionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_projectStagesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<TaskInstances, List<TaskInstance>>
  _taskInstancesRefsTable(_$FamilyDatabase db) => MultiTypedResultKey.fromTable(
    db.taskInstances,
    aliasName: 'task_versions__id__task_instances__version_id',
  );

  $TaskInstancesProcessedTableManager get taskInstancesRefs {
    final manager = $TaskInstancesTableManager(
      $_db,
      $_db.taskInstances,
    ).filter((f) => f.versionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_taskInstancesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $TaskVersionsFilterComposer
    extends Composer<_$FamilyDatabase, TaskVersions> {
  $TaskVersionsFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get criteria => $composableBuilder(
    column: $table.criteria,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get taskType => $composableBuilder(
    column: $table.taskType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reward => $composableBuilder(
    column: $table.reward,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rulesVersion => $composableBuilder(
    column: $table.rulesVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scheduleJson => $composableBuilder(
    column: $table.scheduleJson,
    builder: (column) => ColumnFilters(column),
  );

  $TaskTemplatesFilterComposer get templateId {
    final $TaskTemplatesFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.templateId,
      referencedTable: $db.taskTemplates,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $TaskTemplatesFilterComposer(
            $db: $db,
            $table: $db.taskTemplates,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> projectStagesRefs(
    Expression<bool> Function($ProjectStagesFilterComposer f) f,
  ) {
    final $ProjectStagesFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.projectStages,
      getReferencedColumn: (t) => t.versionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ProjectStagesFilterComposer(
            $db: $db,
            $table: $db.projectStages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> taskInstancesRefs(
    Expression<bool> Function($TaskInstancesFilterComposer f) f,
  ) {
    final $TaskInstancesFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.taskInstances,
      getReferencedColumn: (t) => t.versionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $TaskInstancesFilterComposer(
            $db: $db,
            $table: $db.taskInstances,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $TaskVersionsOrderingComposer
    extends Composer<_$FamilyDatabase, TaskVersions> {
  $TaskVersionsOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get criteria => $composableBuilder(
    column: $table.criteria,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get taskType => $composableBuilder(
    column: $table.taskType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reward => $composableBuilder(
    column: $table.reward,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rulesVersion => $composableBuilder(
    column: $table.rulesVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scheduleJson => $composableBuilder(
    column: $table.scheduleJson,
    builder: (column) => ColumnOrderings(column),
  );

  $TaskTemplatesOrderingComposer get templateId {
    final $TaskTemplatesOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.templateId,
      referencedTable: $db.taskTemplates,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $TaskTemplatesOrderingComposer(
            $db: $db,
            $table: $db.taskTemplates,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $TaskVersionsAnnotationComposer
    extends Composer<_$FamilyDatabase, TaskVersions> {
  $TaskVersionsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get criteria =>
      $composableBuilder(column: $table.criteria, builder: (column) => column);

  GeneratedColumn<String> get taskType =>
      $composableBuilder(column: $table.taskType, builder: (column) => column);

  GeneratedColumn<int> get reward =>
      $composableBuilder(column: $table.reward, builder: (column) => column);

  GeneratedColumn<String> get rulesVersion => $composableBuilder(
    column: $table.rulesVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get scheduleJson => $composableBuilder(
    column: $table.scheduleJson,
    builder: (column) => column,
  );

  $TaskTemplatesAnnotationComposer get templateId {
    final $TaskTemplatesAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.templateId,
      referencedTable: $db.taskTemplates,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $TaskTemplatesAnnotationComposer(
            $db: $db,
            $table: $db.taskTemplates,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> projectStagesRefs<T extends Object>(
    Expression<T> Function($ProjectStagesAnnotationComposer a) f,
  ) {
    final $ProjectStagesAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.projectStages,
      getReferencedColumn: (t) => t.versionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ProjectStagesAnnotationComposer(
            $db: $db,
            $table: $db.projectStages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> taskInstancesRefs<T extends Object>(
    Expression<T> Function($TaskInstancesAnnotationComposer a) f,
  ) {
    final $TaskInstancesAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.taskInstances,
      getReferencedColumn: (t) => t.versionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $TaskInstancesAnnotationComposer(
            $db: $db,
            $table: $db.taskInstances,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $TaskVersionsTableManager
    extends
        RootTableManager<
          _$FamilyDatabase,
          TaskVersions,
          TaskVersion,
          $TaskVersionsFilterComposer,
          $TaskVersionsOrderingComposer,
          $TaskVersionsAnnotationComposer,
          $TaskVersionsCreateCompanionBuilder,
          $TaskVersionsUpdateCompanionBuilder,
          (TaskVersion, $TaskVersionsReferences),
          TaskVersion,
          PrefetchHooks Function({
            bool templateId,
            bool projectStagesRefs,
            bool taskInstancesRefs,
          })
        > {
  $TaskVersionsTableManager(_$FamilyDatabase db, TaskVersions table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $TaskVersionsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $TaskVersionsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $TaskVersionsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> templateId = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<String> criteria = const Value.absent(),
                Value<String> taskType = const Value.absent(),
                Value<int> reward = const Value.absent(),
                Value<String> rulesVersion = const Value.absent(),
                Value<String> scheduleJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TaskVersionsCompanion(
                id: id,
                templateId: templateId,
                version: version,
                title: title,
                content: content,
                criteria: criteria,
                taskType: taskType,
                reward: reward,
                rulesVersion: rulesVersion,
                scheduleJson: scheduleJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String templateId,
                required int version,
                required String title,
                required String content,
                required String criteria,
                required String taskType,
                required int reward,
                required String rulesVersion,
                required String scheduleJson,
                Value<int> rowid = const Value.absent(),
              }) => TaskVersionsCompanion.insert(
                id: id,
                templateId: templateId,
                version: version,
                title: title,
                content: content,
                criteria: criteria,
                taskType: taskType,
                reward: reward,
                rulesVersion: rulesVersion,
                scheduleJson: scheduleJson,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<TaskVersions, TaskVersion>(table),
                  $TaskVersionsReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                templateId = false,
                projectStagesRefs = false,
                taskInstancesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (projectStagesRefs) db.projectStages,
                    if (taskInstancesRefs) db.taskInstances,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (templateId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.templateId,
                            referencedTable: $TaskVersionsReferences
                                ._templateIdTable(db),
                            referencedColumn: $TaskVersionsReferences
                                ._templateIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (projectStagesRefs)
                        await $_getPrefetchedDataByColumns<
                          TaskVersion,
                          TaskVersions,
                          ProjectStage,
                          ProjectStages
                        >(
                          currentTable: table,
                          referencedTable: $TaskVersionsReferences
                              ._projectStagesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $TaskVersionsReferences(
                                db,
                                table,
                                p0,
                              ).projectStagesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'version_id',
                          typedResults: items,
                        ),
                      if (taskInstancesRefs)
                        await $_getPrefetchedDataByColumns<
                          TaskVersion,
                          TaskVersions,
                          TaskInstance,
                          TaskInstances
                        >(
                          currentTable: table,
                          referencedTable: $TaskVersionsReferences
                              ._taskInstancesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $TaskVersionsReferences(
                                db,
                                table,
                                p0,
                              ).taskInstancesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'version_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $TaskVersionsProcessedTableManager =
    ProcessedTableManager<
      _$FamilyDatabase,
      TaskVersions,
      TaskVersion,
      $TaskVersionsFilterComposer,
      $TaskVersionsOrderingComposer,
      $TaskVersionsAnnotationComposer,
      $TaskVersionsCreateCompanionBuilder,
      $TaskVersionsUpdateCompanionBuilder,
      (TaskVersion, $TaskVersionsReferences),
      TaskVersion,
      PrefetchHooks Function({
        bool templateId,
        bool projectStagesRefs,
        bool taskInstancesRefs,
      })
    >;
typedef $ProjectStagesCreateCompanionBuilder = ProjectStagesCompanion Function({
  required String id,
  required String versionId,
  required int sequence,
  required String title,
  required String criteria,
  required String taskType,
  required int reward,
  Value<int> rowid,
});
typedef $ProjectStagesUpdateCompanionBuilder = ProjectStagesCompanion Function({
  Value<String> id,
  Value<String> versionId,
  Value<int> sequence,
  Value<String> title,
  Value<String> criteria,
  Value<String> taskType,
  Value<int> reward,
  Value<int> rowid,
});

final class $ProjectStagesReferences
    extends BaseReferences<_$FamilyDatabase, ProjectStages, ProjectStage> {
  $ProjectStagesReferences(super.$_db, super.$_table, super.$_typedResult);

  static TaskVersions _versionIdTable(_$FamilyDatabase db) => db.taskVersions
      .createAlias('project_stages__version_id__task_versions__id');

  $TaskVersionsProcessedTableManager get versionId {
    final $_column = $_itemColumn<String>('version_id')!;

    final manager = $TaskVersionsTableManager(
      $_db,
      $_db.taskVersions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_versionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<TaskInstances, List<TaskInstance>>
  _taskInstancesRefsTable(_$FamilyDatabase db) => MultiTypedResultKey.fromTable(
    db.taskInstances,
    aliasName: 'project_stages__id__task_instances__stage_id',
  );

  $TaskInstancesProcessedTableManager get taskInstancesRefs {
    final manager = $TaskInstancesTableManager(
      $_db,
      $_db.taskInstances,
    ).filter((f) => f.stageId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_taskInstancesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $ProjectStagesFilterComposer
    extends Composer<_$FamilyDatabase, ProjectStages> {
  $ProjectStagesFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sequence => $composableBuilder(
    column: $table.sequence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get criteria => $composableBuilder(
    column: $table.criteria,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get taskType => $composableBuilder(
    column: $table.taskType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reward => $composableBuilder(
    column: $table.reward,
    builder: (column) => ColumnFilters(column),
  );

  $TaskVersionsFilterComposer get versionId {
    final $TaskVersionsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.versionId,
      referencedTable: $db.taskVersions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $TaskVersionsFilterComposer(
            $db: $db,
            $table: $db.taskVersions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> taskInstancesRefs(
    Expression<bool> Function($TaskInstancesFilterComposer f) f,
  ) {
    final $TaskInstancesFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.taskInstances,
      getReferencedColumn: (t) => t.stageId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $TaskInstancesFilterComposer(
            $db: $db,
            $table: $db.taskInstances,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $ProjectStagesOrderingComposer
    extends Composer<_$FamilyDatabase, ProjectStages> {
  $ProjectStagesOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sequence => $composableBuilder(
    column: $table.sequence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get criteria => $composableBuilder(
    column: $table.criteria,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get taskType => $composableBuilder(
    column: $table.taskType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reward => $composableBuilder(
    column: $table.reward,
    builder: (column) => ColumnOrderings(column),
  );

  $TaskVersionsOrderingComposer get versionId {
    final $TaskVersionsOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.versionId,
      referencedTable: $db.taskVersions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $TaskVersionsOrderingComposer(
            $db: $db,
            $table: $db.taskVersions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $ProjectStagesAnnotationComposer
    extends Composer<_$FamilyDatabase, ProjectStages> {
  $ProjectStagesAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get sequence =>
      $composableBuilder(column: $table.sequence, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get criteria =>
      $composableBuilder(column: $table.criteria, builder: (column) => column);

  GeneratedColumn<String> get taskType =>
      $composableBuilder(column: $table.taskType, builder: (column) => column);

  GeneratedColumn<int> get reward =>
      $composableBuilder(column: $table.reward, builder: (column) => column);

  $TaskVersionsAnnotationComposer get versionId {
    final $TaskVersionsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.versionId,
      referencedTable: $db.taskVersions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $TaskVersionsAnnotationComposer(
            $db: $db,
            $table: $db.taskVersions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> taskInstancesRefs<T extends Object>(
    Expression<T> Function($TaskInstancesAnnotationComposer a) f,
  ) {
    final $TaskInstancesAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.taskInstances,
      getReferencedColumn: (t) => t.stageId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $TaskInstancesAnnotationComposer(
            $db: $db,
            $table: $db.taskInstances,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $ProjectStagesTableManager
    extends
        RootTableManager<
          _$FamilyDatabase,
          ProjectStages,
          ProjectStage,
          $ProjectStagesFilterComposer,
          $ProjectStagesOrderingComposer,
          $ProjectStagesAnnotationComposer,
          $ProjectStagesCreateCompanionBuilder,
          $ProjectStagesUpdateCompanionBuilder,
          (ProjectStage, $ProjectStagesReferences),
          ProjectStage,
          PrefetchHooks Function({bool versionId, bool taskInstancesRefs})
        > {
  $ProjectStagesTableManager(_$FamilyDatabase db, ProjectStages table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $ProjectStagesFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $ProjectStagesOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $ProjectStagesAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> versionId = const Value.absent(),
                Value<int> sequence = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> criteria = const Value.absent(),
                Value<String> taskType = const Value.absent(),
                Value<int> reward = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProjectStagesCompanion(
                id: id,
                versionId: versionId,
                sequence: sequence,
                title: title,
                criteria: criteria,
                taskType: taskType,
                reward: reward,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String versionId,
                required int sequence,
                required String title,
                required String criteria,
                required String taskType,
                required int reward,
                Value<int> rowid = const Value.absent(),
              }) => ProjectStagesCompanion.insert(
                id: id,
                versionId: versionId,
                sequence: sequence,
                title: title,
                criteria: criteria,
                taskType: taskType,
                reward: reward,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<ProjectStages, ProjectStage>(table),
                  $ProjectStagesReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({versionId = false, taskInstancesRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (taskInstancesRefs) db.taskInstances,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (versionId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.versionId,
                            referencedTable: $ProjectStagesReferences
                                ._versionIdTable(db),
                            referencedColumn: $ProjectStagesReferences
                                ._versionIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (taskInstancesRefs)
                        await $_getPrefetchedDataByColumns<
                          ProjectStage,
                          ProjectStages,
                          TaskInstance,
                          TaskInstances
                        >(
                          currentTable: table,
                          referencedTable: $ProjectStagesReferences
                              ._taskInstancesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $ProjectStagesReferences(
                                db,
                                table,
                                p0,
                              ).taskInstancesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'stage_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $ProjectStagesProcessedTableManager =
    ProcessedTableManager<
      _$FamilyDatabase,
      ProjectStages,
      ProjectStage,
      $ProjectStagesFilterComposer,
      $ProjectStagesOrderingComposer,
      $ProjectStagesAnnotationComposer,
      $ProjectStagesCreateCompanionBuilder,
      $ProjectStagesUpdateCompanionBuilder,
      (ProjectStage, $ProjectStagesReferences),
      ProjectStage,
      PrefetchHooks Function({bool versionId, bool taskInstancesRefs})
    >;
typedef $TaskInstancesCreateCompanionBuilder = TaskInstancesCompanion Function({
  required String id,
  required String instanceKey,
  required String templateId,
  required String versionId,
  Value<String?> stageId,
  Value<String?> priorInstanceId,
  required String plannedDay,
  Value<int> slot,
  Value<String?> dueDay,
  required String state,
  Value<String?> actualDate,
  Value<int?> approvedAt,
  Value<String> resolutionNote,
  Value<int> rowid,
});
typedef $TaskInstancesUpdateCompanionBuilder = TaskInstancesCompanion Function({
  Value<String> id,
  Value<String> instanceKey,
  Value<String> templateId,
  Value<String> versionId,
  Value<String?> stageId,
  Value<String?> priorInstanceId,
  Value<String> plannedDay,
  Value<int> slot,
  Value<String?> dueDay,
  Value<String> state,
  Value<String?> actualDate,
  Value<int?> approvedAt,
  Value<String> resolutionNote,
  Value<int> rowid,
});

final class $TaskInstancesReferences
    extends BaseReferences<_$FamilyDatabase, TaskInstances, TaskInstance> {
  $TaskInstancesReferences(super.$_db, super.$_table, super.$_typedResult);

  static TaskTemplates _templateIdTable(_$FamilyDatabase db) => db.taskTemplates
      .createAlias('task_instances__template_id__task_templates__id');

  $TaskTemplatesProcessedTableManager get templateId {
    final $_column = $_itemColumn<String>('template_id')!;

    final manager = $TaskTemplatesTableManager(
      $_db,
      $_db.taskTemplates,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_templateIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static TaskVersions _versionIdTable(_$FamilyDatabase db) => db.taskVersions
      .createAlias('task_instances__version_id__task_versions__id');

  $TaskVersionsProcessedTableManager get versionId {
    final $_column = $_itemColumn<String>('version_id')!;

    final manager = $TaskVersionsTableManager(
      $_db,
      $_db.taskVersions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_versionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static ProjectStages _stageIdTable(_$FamilyDatabase db) => db.projectStages
      .createAlias('task_instances__stage_id__project_stages__id');

  $ProjectStagesProcessedTableManager? get stageId {
    final $_column = $_itemColumn<String>('stage_id');
    if ($_column == null) return null;
    final manager = $ProjectStagesTableManager(
      $_db,
      $_db.projectStages,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_stageIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static TaskInstances _priorInstanceIdTable(_$FamilyDatabase db) => db
      .taskInstances
      .createAlias('task_instances__prior_instance_id__task_instances__id');

  $TaskInstancesProcessedTableManager? get priorInstanceId {
    final $_column = $_itemColumn<String>('prior_instance_id');
    if ($_column == null) return null;
    final manager = $TaskInstancesTableManager(
      $_db,
      $_db.taskInstances,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_priorInstanceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<Submissions, List<Submission>>
  _submissionsRefsTable(_$FamilyDatabase db) => MultiTypedResultKey.fromTable(
    db.submissions,
    aliasName: 'task_instances__id__submissions__instance_id',
  );

  $SubmissionsProcessedTableManager get submissionsRefs {
    final manager = $SubmissionsTableManager(
      $_db,
      $_db.submissions,
    ).filter((f) => f.instanceId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_submissionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<Completions, List<Completion>>
  _completionsRefsTable(_$FamilyDatabase db) => MultiTypedResultKey.fromTable(
    db.completions,
    aliasName: 'task_instances__id__completions__instance_id',
  );

  $CompletionsProcessedTableManager get completionsRefs {
    final manager = $CompletionsTableManager(
      $_db,
      $_db.completions,
    ).filter((f) => f.instanceId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_completionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<CorrectionRecords, List<CorrectionRecord>>
  _correctionRecordsRefsTable(_$FamilyDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.correctionRecords,
        aliasName: 'task_instances__id__correction_records__instance_id',
      );

  $CorrectionRecordsProcessedTableManager get correctionRecordsRefs {
    final manager = $CorrectionRecordsTableManager(
      $_db,
      $_db.correctionRecords,
    ).filter((f) => f.instanceId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _correctionRecordsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $TaskInstancesFilterComposer
    extends Composer<_$FamilyDatabase, TaskInstances> {
  $TaskInstancesFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get instanceKey => $composableBuilder(
    column: $table.instanceKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get plannedDay => $composableBuilder(
    column: $table.plannedDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get slot => $composableBuilder(
    column: $table.slot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dueDay => $composableBuilder(
    column: $table.dueDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get actualDate => $composableBuilder(
    column: $table.actualDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get approvedAt => $composableBuilder(
    column: $table.approvedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get resolutionNote => $composableBuilder(
    column: $table.resolutionNote,
    builder: (column) => ColumnFilters(column),
  );

  $TaskTemplatesFilterComposer get templateId {
    final $TaskTemplatesFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.templateId,
      referencedTable: $db.taskTemplates,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $TaskTemplatesFilterComposer(
            $db: $db,
            $table: $db.taskTemplates,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $TaskVersionsFilterComposer get versionId {
    final $TaskVersionsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.versionId,
      referencedTable: $db.taskVersions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $TaskVersionsFilterComposer(
            $db: $db,
            $table: $db.taskVersions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $ProjectStagesFilterComposer get stageId {
    final $ProjectStagesFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.stageId,
      referencedTable: $db.projectStages,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ProjectStagesFilterComposer(
            $db: $db,
            $table: $db.projectStages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $TaskInstancesFilterComposer get priorInstanceId {
    final $TaskInstancesFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.priorInstanceId,
      referencedTable: $db.taskInstances,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $TaskInstancesFilterComposer(
            $db: $db,
            $table: $db.taskInstances,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> submissionsRefs(
    Expression<bool> Function($SubmissionsFilterComposer f) f,
  ) {
    final $SubmissionsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.submissions,
      getReferencedColumn: (t) => t.instanceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $SubmissionsFilterComposer(
            $db: $db,
            $table: $db.submissions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> completionsRefs(
    Expression<bool> Function($CompletionsFilterComposer f) f,
  ) {
    final $CompletionsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.completions,
      getReferencedColumn: (t) => t.instanceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $CompletionsFilterComposer(
            $db: $db,
            $table: $db.completions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> correctionRecordsRefs(
    Expression<bool> Function($CorrectionRecordsFilterComposer f) f,
  ) {
    final $CorrectionRecordsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.correctionRecords,
      getReferencedColumn: (t) => t.instanceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $CorrectionRecordsFilterComposer(
            $db: $db,
            $table: $db.correctionRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $TaskInstancesOrderingComposer
    extends Composer<_$FamilyDatabase, TaskInstances> {
  $TaskInstancesOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get instanceKey => $composableBuilder(
    column: $table.instanceKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get plannedDay => $composableBuilder(
    column: $table.plannedDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get slot => $composableBuilder(
    column: $table.slot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dueDay => $composableBuilder(
    column: $table.dueDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get actualDate => $composableBuilder(
    column: $table.actualDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get approvedAt => $composableBuilder(
    column: $table.approvedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get resolutionNote => $composableBuilder(
    column: $table.resolutionNote,
    builder: (column) => ColumnOrderings(column),
  );

  $TaskTemplatesOrderingComposer get templateId {
    final $TaskTemplatesOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.templateId,
      referencedTable: $db.taskTemplates,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $TaskTemplatesOrderingComposer(
            $db: $db,
            $table: $db.taskTemplates,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $TaskVersionsOrderingComposer get versionId {
    final $TaskVersionsOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.versionId,
      referencedTable: $db.taskVersions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $TaskVersionsOrderingComposer(
            $db: $db,
            $table: $db.taskVersions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $ProjectStagesOrderingComposer get stageId {
    final $ProjectStagesOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.stageId,
      referencedTable: $db.projectStages,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ProjectStagesOrderingComposer(
            $db: $db,
            $table: $db.projectStages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $TaskInstancesOrderingComposer get priorInstanceId {
    final $TaskInstancesOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.priorInstanceId,
      referencedTable: $db.taskInstances,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $TaskInstancesOrderingComposer(
            $db: $db,
            $table: $db.taskInstances,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $TaskInstancesAnnotationComposer
    extends Composer<_$FamilyDatabase, TaskInstances> {
  $TaskInstancesAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get instanceKey => $composableBuilder(
    column: $table.instanceKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get plannedDay => $composableBuilder(
    column: $table.plannedDay,
    builder: (column) => column,
  );

  GeneratedColumn<int> get slot =>
      $composableBuilder(column: $table.slot, builder: (column) => column);

  GeneratedColumn<String> get dueDay =>
      $composableBuilder(column: $table.dueDay, builder: (column) => column);

  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<String> get actualDate => $composableBuilder(
    column: $table.actualDate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get approvedAt => $composableBuilder(
    column: $table.approvedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get resolutionNote => $composableBuilder(
    column: $table.resolutionNote,
    builder: (column) => column,
  );

  $TaskTemplatesAnnotationComposer get templateId {
    final $TaskTemplatesAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.templateId,
      referencedTable: $db.taskTemplates,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $TaskTemplatesAnnotationComposer(
            $db: $db,
            $table: $db.taskTemplates,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $TaskVersionsAnnotationComposer get versionId {
    final $TaskVersionsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.versionId,
      referencedTable: $db.taskVersions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $TaskVersionsAnnotationComposer(
            $db: $db,
            $table: $db.taskVersions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $ProjectStagesAnnotationComposer get stageId {
    final $ProjectStagesAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.stageId,
      referencedTable: $db.projectStages,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ProjectStagesAnnotationComposer(
            $db: $db,
            $table: $db.projectStages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $TaskInstancesAnnotationComposer get priorInstanceId {
    final $TaskInstancesAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.priorInstanceId,
      referencedTable: $db.taskInstances,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $TaskInstancesAnnotationComposer(
            $db: $db,
            $table: $db.taskInstances,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> submissionsRefs<T extends Object>(
    Expression<T> Function($SubmissionsAnnotationComposer a) f,
  ) {
    final $SubmissionsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.submissions,
      getReferencedColumn: (t) => t.instanceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $SubmissionsAnnotationComposer(
            $db: $db,
            $table: $db.submissions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> completionsRefs<T extends Object>(
    Expression<T> Function($CompletionsAnnotationComposer a) f,
  ) {
    final $CompletionsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.completions,
      getReferencedColumn: (t) => t.instanceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $CompletionsAnnotationComposer(
            $db: $db,
            $table: $db.completions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> correctionRecordsRefs<T extends Object>(
    Expression<T> Function($CorrectionRecordsAnnotationComposer a) f,
  ) {
    final $CorrectionRecordsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.correctionRecords,
      getReferencedColumn: (t) => t.instanceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $CorrectionRecordsAnnotationComposer(
            $db: $db,
            $table: $db.correctionRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $TaskInstancesTableManager
    extends
        RootTableManager<
          _$FamilyDatabase,
          TaskInstances,
          TaskInstance,
          $TaskInstancesFilterComposer,
          $TaskInstancesOrderingComposer,
          $TaskInstancesAnnotationComposer,
          $TaskInstancesCreateCompanionBuilder,
          $TaskInstancesUpdateCompanionBuilder,
          (TaskInstance, $TaskInstancesReferences),
          TaskInstance,
          PrefetchHooks Function({
            bool templateId,
            bool versionId,
            bool stageId,
            bool priorInstanceId,
            bool submissionsRefs,
            bool completionsRefs,
            bool correctionRecordsRefs,
          })
        > {
  $TaskInstancesTableManager(_$FamilyDatabase db, TaskInstances table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $TaskInstancesFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $TaskInstancesOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $TaskInstancesAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> instanceKey = const Value.absent(),
                Value<String> templateId = const Value.absent(),
                Value<String> versionId = const Value.absent(),
                Value<String?> stageId = const Value.absent(),
                Value<String?> priorInstanceId = const Value.absent(),
                Value<String> plannedDay = const Value.absent(),
                Value<int> slot = const Value.absent(),
                Value<String?> dueDay = const Value.absent(),
                Value<String> state = const Value.absent(),
                Value<String?> actualDate = const Value.absent(),
                Value<int?> approvedAt = const Value.absent(),
                Value<String> resolutionNote = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TaskInstancesCompanion(
                id: id,
                instanceKey: instanceKey,
                templateId: templateId,
                versionId: versionId,
                stageId: stageId,
                priorInstanceId: priorInstanceId,
                plannedDay: plannedDay,
                slot: slot,
                dueDay: dueDay,
                state: state,
                actualDate: actualDate,
                approvedAt: approvedAt,
                resolutionNote: resolutionNote,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String instanceKey,
                required String templateId,
                required String versionId,
                Value<String?> stageId = const Value.absent(),
                Value<String?> priorInstanceId = const Value.absent(),
                required String plannedDay,
                Value<int> slot = const Value.absent(),
                Value<String?> dueDay = const Value.absent(),
                required String state,
                Value<String?> actualDate = const Value.absent(),
                Value<int?> approvedAt = const Value.absent(),
                Value<String> resolutionNote = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TaskInstancesCompanion.insert(
                id: id,
                instanceKey: instanceKey,
                templateId: templateId,
                versionId: versionId,
                stageId: stageId,
                priorInstanceId: priorInstanceId,
                plannedDay: plannedDay,
                slot: slot,
                dueDay: dueDay,
                state: state,
                actualDate: actualDate,
                approvedAt: approvedAt,
                resolutionNote: resolutionNote,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<TaskInstances, TaskInstance>(table),
                  $TaskInstancesReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                templateId = false,
                versionId = false,
                stageId = false,
                priorInstanceId = false,
                submissionsRefs = false,
                completionsRefs = false,
                correctionRecordsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (submissionsRefs) db.submissions,
                    if (completionsRefs) db.completions,
                    if (correctionRecordsRefs) db.correctionRecords,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (templateId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.templateId,
                            referencedTable: $TaskInstancesReferences
                                ._templateIdTable(db),
                            referencedColumn: $TaskInstancesReferences
                                ._templateIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (versionId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.versionId,
                            referencedTable: $TaskInstancesReferences
                                ._versionIdTable(db),
                            referencedColumn: $TaskInstancesReferences
                                ._versionIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (stageId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.stageId,
                            referencedTable: $TaskInstancesReferences
                                ._stageIdTable(db),
                            referencedColumn: $TaskInstancesReferences
                                ._stageIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (priorInstanceId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.priorInstanceId,
                            referencedTable: $TaskInstancesReferences
                                ._priorInstanceIdTable(db),
                            referencedColumn: $TaskInstancesReferences
                                ._priorInstanceIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (submissionsRefs)
                        await $_getPrefetchedDataByColumns<
                          TaskInstance,
                          TaskInstances,
                          Submission,
                          Submissions
                        >(
                          currentTable: table,
                          referencedTable: $TaskInstancesReferences
                              ._submissionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $TaskInstancesReferences(
                                db,
                                table,
                                p0,
                              ).submissionsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'instance_id',
                          typedResults: items,
                        ),
                      if (completionsRefs)
                        await $_getPrefetchedDataByColumns<
                          TaskInstance,
                          TaskInstances,
                          Completion,
                          Completions
                        >(
                          currentTable: table,
                          referencedTable: $TaskInstancesReferences
                              ._completionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $TaskInstancesReferences(
                                db,
                                table,
                                p0,
                              ).completionsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'instance_id',
                          typedResults: items,
                        ),
                      if (correctionRecordsRefs)
                        await $_getPrefetchedDataByColumns<
                          TaskInstance,
                          TaskInstances,
                          CorrectionRecord,
                          CorrectionRecords
                        >(
                          currentTable: table,
                          referencedTable: $TaskInstancesReferences
                              ._correctionRecordsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $TaskInstancesReferences(
                                db,
                                table,
                                p0,
                              ).correctionRecordsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'instance_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $TaskInstancesProcessedTableManager =
    ProcessedTableManager<
      _$FamilyDatabase,
      TaskInstances,
      TaskInstance,
      $TaskInstancesFilterComposer,
      $TaskInstancesOrderingComposer,
      $TaskInstancesAnnotationComposer,
      $TaskInstancesCreateCompanionBuilder,
      $TaskInstancesUpdateCompanionBuilder,
      (TaskInstance, $TaskInstancesReferences),
      TaskInstance,
      PrefetchHooks Function({
        bool templateId,
        bool versionId,
        bool stageId,
        bool priorInstanceId,
        bool submissionsRefs,
        bool completionsRefs,
        bool correctionRecordsRefs,
      })
    >;
typedef $SubmissionsCreateCompanionBuilder = SubmissionsCompanion Function({
  required String id,
  required String instanceId,
  required String note,
  required String actualDate,
  required int createdAt,
  Value<int> rowid,
});
typedef $SubmissionsUpdateCompanionBuilder = SubmissionsCompanion Function({
  Value<String> id,
  Value<String> instanceId,
  Value<String> note,
  Value<String> actualDate,
  Value<int> createdAt,
  Value<int> rowid,
});

final class $SubmissionsReferences
    extends BaseReferences<_$FamilyDatabase, Submissions, Submission> {
  $SubmissionsReferences(super.$_db, super.$_table, super.$_typedResult);

  static TaskInstances _instanceIdTable(_$FamilyDatabase db) => db.taskInstances
      .createAlias('submissions__instance_id__task_instances__id');

  $TaskInstancesProcessedTableManager get instanceId {
    final $_column = $_itemColumn<String>('instance_id')!;

    final manager = $TaskInstancesTableManager(
      $_db,
      $_db.taskInstances,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_instanceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $SubmissionsFilterComposer
    extends Composer<_$FamilyDatabase, Submissions> {
  $SubmissionsFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get actualDate => $composableBuilder(
    column: $table.actualDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $TaskInstancesFilterComposer get instanceId {
    final $TaskInstancesFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.instanceId,
      referencedTable: $db.taskInstances,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $TaskInstancesFilterComposer(
            $db: $db,
            $table: $db.taskInstances,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $SubmissionsOrderingComposer
    extends Composer<_$FamilyDatabase, Submissions> {
  $SubmissionsOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get actualDate => $composableBuilder(
    column: $table.actualDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $TaskInstancesOrderingComposer get instanceId {
    final $TaskInstancesOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.instanceId,
      referencedTable: $db.taskInstances,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $TaskInstancesOrderingComposer(
            $db: $db,
            $table: $db.taskInstances,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $SubmissionsAnnotationComposer
    extends Composer<_$FamilyDatabase, Submissions> {
  $SubmissionsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get actualDate => $composableBuilder(
    column: $table.actualDate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $TaskInstancesAnnotationComposer get instanceId {
    final $TaskInstancesAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.instanceId,
      referencedTable: $db.taskInstances,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $TaskInstancesAnnotationComposer(
            $db: $db,
            $table: $db.taskInstances,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $SubmissionsTableManager
    extends
        RootTableManager<
          _$FamilyDatabase,
          Submissions,
          Submission,
          $SubmissionsFilterComposer,
          $SubmissionsOrderingComposer,
          $SubmissionsAnnotationComposer,
          $SubmissionsCreateCompanionBuilder,
          $SubmissionsUpdateCompanionBuilder,
          (Submission, $SubmissionsReferences),
          Submission,
          PrefetchHooks Function({bool instanceId})
        > {
  $SubmissionsTableManager(_$FamilyDatabase db, Submissions table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $SubmissionsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $SubmissionsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $SubmissionsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> instanceId = const Value.absent(),
                Value<String> note = const Value.absent(),
                Value<String> actualDate = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SubmissionsCompanion(
                id: id,
                instanceId: instanceId,
                note: note,
                actualDate: actualDate,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String instanceId,
                required String note,
                required String actualDate,
                required int createdAt,
                Value<int> rowid = const Value.absent(),
              }) => SubmissionsCompanion.insert(
                id: id,
                instanceId: instanceId,
                note: note,
                actualDate: actualDate,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<Submissions, Submission>(table),
                  $SubmissionsReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({instanceId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (instanceId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.instanceId,
                        referencedTable: $SubmissionsReferences
                            ._instanceIdTable(db),
                        referencedColumn: $SubmissionsReferences
                            ._instanceIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $SubmissionsProcessedTableManager =
    ProcessedTableManager<
      _$FamilyDatabase,
      Submissions,
      Submission,
      $SubmissionsFilterComposer,
      $SubmissionsOrderingComposer,
      $SubmissionsAnnotationComposer,
      $SubmissionsCreateCompanionBuilder,
      $SubmissionsUpdateCompanionBuilder,
      (Submission, $SubmissionsReferences),
      Submission,
      PrefetchHooks Function({bool instanceId})
    >;
typedef $CompletionsCreateCompanionBuilder = CompletionsCompanion Function({
  required String id,
  required String instanceId,
  required String actualDate,
  required String feedback,
  Value<int> isValid,
  required String approvalCommandId,
  Value<int> rowid,
});
typedef $CompletionsUpdateCompanionBuilder = CompletionsCompanion Function({
  Value<String> id,
  Value<String> instanceId,
  Value<String> actualDate,
  Value<String> feedback,
  Value<int> isValid,
  Value<String> approvalCommandId,
  Value<int> rowid,
});

final class $CompletionsReferences
    extends BaseReferences<_$FamilyDatabase, Completions, Completion> {
  $CompletionsReferences(super.$_db, super.$_table, super.$_typedResult);

  static TaskInstances _instanceIdTable(_$FamilyDatabase db) => db.taskInstances
      .createAlias('completions__instance_id__task_instances__id');

  $TaskInstancesProcessedTableManager get instanceId {
    final $_column = $_itemColumn<String>('instance_id')!;

    final manager = $TaskInstancesTableManager(
      $_db,
      $_db.taskInstances,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_instanceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $CompletionsFilterComposer
    extends Composer<_$FamilyDatabase, Completions> {
  $CompletionsFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get actualDate => $composableBuilder(
    column: $table.actualDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get feedback => $composableBuilder(
    column: $table.feedback,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get isValid => $composableBuilder(
    column: $table.isValid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get approvalCommandId => $composableBuilder(
    column: $table.approvalCommandId,
    builder: (column) => ColumnFilters(column),
  );

  $TaskInstancesFilterComposer get instanceId {
    final $TaskInstancesFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.instanceId,
      referencedTable: $db.taskInstances,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $TaskInstancesFilterComposer(
            $db: $db,
            $table: $db.taskInstances,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $CompletionsOrderingComposer
    extends Composer<_$FamilyDatabase, Completions> {
  $CompletionsOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get actualDate => $composableBuilder(
    column: $table.actualDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get feedback => $composableBuilder(
    column: $table.feedback,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get isValid => $composableBuilder(
    column: $table.isValid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get approvalCommandId => $composableBuilder(
    column: $table.approvalCommandId,
    builder: (column) => ColumnOrderings(column),
  );

  $TaskInstancesOrderingComposer get instanceId {
    final $TaskInstancesOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.instanceId,
      referencedTable: $db.taskInstances,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $TaskInstancesOrderingComposer(
            $db: $db,
            $table: $db.taskInstances,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $CompletionsAnnotationComposer
    extends Composer<_$FamilyDatabase, Completions> {
  $CompletionsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get actualDate => $composableBuilder(
    column: $table.actualDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get feedback =>
      $composableBuilder(column: $table.feedback, builder: (column) => column);

  GeneratedColumn<int> get isValid =>
      $composableBuilder(column: $table.isValid, builder: (column) => column);

  GeneratedColumn<String> get approvalCommandId => $composableBuilder(
    column: $table.approvalCommandId,
    builder: (column) => column,
  );

  $TaskInstancesAnnotationComposer get instanceId {
    final $TaskInstancesAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.instanceId,
      referencedTable: $db.taskInstances,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $TaskInstancesAnnotationComposer(
            $db: $db,
            $table: $db.taskInstances,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $CompletionsTableManager
    extends
        RootTableManager<
          _$FamilyDatabase,
          Completions,
          Completion,
          $CompletionsFilterComposer,
          $CompletionsOrderingComposer,
          $CompletionsAnnotationComposer,
          $CompletionsCreateCompanionBuilder,
          $CompletionsUpdateCompanionBuilder,
          (Completion, $CompletionsReferences),
          Completion,
          PrefetchHooks Function({bool instanceId})
        > {
  $CompletionsTableManager(_$FamilyDatabase db, Completions table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $CompletionsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $CompletionsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $CompletionsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> instanceId = const Value.absent(),
                Value<String> actualDate = const Value.absent(),
                Value<String> feedback = const Value.absent(),
                Value<int> isValid = const Value.absent(),
                Value<String> approvalCommandId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CompletionsCompanion(
                id: id,
                instanceId: instanceId,
                actualDate: actualDate,
                feedback: feedback,
                isValid: isValid,
                approvalCommandId: approvalCommandId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String instanceId,
                required String actualDate,
                required String feedback,
                Value<int> isValid = const Value.absent(),
                required String approvalCommandId,
                Value<int> rowid = const Value.absent(),
              }) => CompletionsCompanion.insert(
                id: id,
                instanceId: instanceId,
                actualDate: actualDate,
                feedback: feedback,
                isValid: isValid,
                approvalCommandId: approvalCommandId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<Completions, Completion>(table),
                  $CompletionsReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({instanceId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (instanceId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.instanceId,
                        referencedTable: $CompletionsReferences
                            ._instanceIdTable(db),
                        referencedColumn: $CompletionsReferences
                            ._instanceIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $CompletionsProcessedTableManager =
    ProcessedTableManager<
      _$FamilyDatabase,
      Completions,
      Completion,
      $CompletionsFilterComposer,
      $CompletionsOrderingComposer,
      $CompletionsAnnotationComposer,
      $CompletionsCreateCompanionBuilder,
      $CompletionsUpdateCompanionBuilder,
      (Completion, $CompletionsReferences),
      Completion,
      PrefetchHooks Function({bool instanceId})
    >;
typedef $LedgerEntriesCreateCompanionBuilder = LedgerEntriesCompanion Function({
  required String id,
  required String accountId,
  required int delta,
  required int balanceAfter,
  required String kind,
  required String sourceKey,
  Value<String?> reversalOf,
  required String actualDate,
  required String postedDay,
  required int createdAt,
  required String commandId,
  Value<int> rowid,
});
typedef $LedgerEntriesUpdateCompanionBuilder = LedgerEntriesCompanion Function({
  Value<String> id,
  Value<String> accountId,
  Value<int> delta,
  Value<int> balanceAfter,
  Value<String> kind,
  Value<String> sourceKey,
  Value<String?> reversalOf,
  Value<String> actualDate,
  Value<String> postedDay,
  Value<int> createdAt,
  Value<String> commandId,
  Value<int> rowid,
});

final class $LedgerEntriesReferences
    extends BaseReferences<_$FamilyDatabase, LedgerEntries, LedgerEntry> {
  $LedgerEntriesReferences(super.$_db, super.$_table, super.$_typedResult);

  static Accounts _accountIdTable(_$FamilyDatabase db) =>
      db.accounts.createAlias('ledger_entries__account_id__accounts__id');

  $AccountsProcessedTableManager get accountId {
    final $_column = $_itemColumn<String>('account_id')!;

    final manager = $AccountsTableManager(
      $_db,
      $_db.accounts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_accountIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static LedgerEntries _reversalOfTable(_$FamilyDatabase db) => db.ledgerEntries
      .createAlias('ledger_entries__reversal_of__ledger_entries__id');

  $LedgerEntriesProcessedTableManager? get reversalOf {
    final $_column = $_itemColumn<String>('reversal_of');
    if ($_column == null) return null;
    final manager = $LedgerEntriesTableManager(
      $_db,
      $_db.ledgerEntries,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_reversalOfTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<PenaltyEvents, List<PenaltyEvent>>
  _penaltyEventsRefsTable(_$FamilyDatabase db) => MultiTypedResultKey.fromTable(
    db.penaltyEvents,
    aliasName: 'ledger_entries__id__penalty_events__ledger_id',
  );

  $PenaltyEventsProcessedTableManager get penaltyEventsRefs {
    final manager = $PenaltyEventsTableManager(
      $_db,
      $_db.penaltyEvents,
    ).filter((f) => f.ledgerId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_penaltyEventsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<Purchases, List<Purchase>> _purchasesRefsTable(
    _$FamilyDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.purchases,
    aliasName: 'ledger_entries__id__purchases__ledger_id',
  );

  $PurchasesProcessedTableManager get purchasesRefs {
    final manager = $PurchasesTableManager(
      $_db,
      $_db.purchases,
    ).filter((f) => f.ledgerId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_purchasesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<CorrectionRecords, List<CorrectionRecord>>
  _correctionRecordsRefsTable(_$FamilyDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.correctionRecords,
        aliasName: 'ledger_entries__id__correction_records__original_reward_id',
      );

  $CorrectionRecordsProcessedTableManager get correctionRecordsRefs {
    final manager = $CorrectionRecordsTableManager($_db, $_db.correctionRecords)
        .filter(
          (f) => f.originalRewardId.id.sqlEquals($_itemColumn<String>('id')!),
        );

    final cache = $_typedResult.readTableOrNull(
      _correctionRecordsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $LedgerEntriesFilterComposer
    extends Composer<_$FamilyDatabase, LedgerEntries> {
  $LedgerEntriesFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get delta => $composableBuilder(
    column: $table.delta,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get balanceAfter => $composableBuilder(
    column: $table.balanceAfter,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceKey => $composableBuilder(
    column: $table.sourceKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get actualDate => $composableBuilder(
    column: $table.actualDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get postedDay => $composableBuilder(
    column: $table.postedDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get commandId => $composableBuilder(
    column: $table.commandId,
    builder: (column) => ColumnFilters(column),
  );

  $AccountsFilterComposer get accountId {
    final $AccountsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $AccountsFilterComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $LedgerEntriesFilterComposer get reversalOf {
    final $LedgerEntriesFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.reversalOf,
      referencedTable: $db.ledgerEntries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $LedgerEntriesFilterComposer(
            $db: $db,
            $table: $db.ledgerEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> penaltyEventsRefs(
    Expression<bool> Function($PenaltyEventsFilterComposer f) f,
  ) {
    final $PenaltyEventsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.penaltyEvents,
      getReferencedColumn: (t) => t.ledgerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $PenaltyEventsFilterComposer(
            $db: $db,
            $table: $db.penaltyEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> purchasesRefs(
    Expression<bool> Function($PurchasesFilterComposer f) f,
  ) {
    final $PurchasesFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.purchases,
      getReferencedColumn: (t) => t.ledgerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $PurchasesFilterComposer(
            $db: $db,
            $table: $db.purchases,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> correctionRecordsRefs(
    Expression<bool> Function($CorrectionRecordsFilterComposer f) f,
  ) {
    final $CorrectionRecordsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.correctionRecords,
      getReferencedColumn: (t) => t.originalRewardId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $CorrectionRecordsFilterComposer(
            $db: $db,
            $table: $db.correctionRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $LedgerEntriesOrderingComposer
    extends Composer<_$FamilyDatabase, LedgerEntries> {
  $LedgerEntriesOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get delta => $composableBuilder(
    column: $table.delta,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get balanceAfter => $composableBuilder(
    column: $table.balanceAfter,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceKey => $composableBuilder(
    column: $table.sourceKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get actualDate => $composableBuilder(
    column: $table.actualDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get postedDay => $composableBuilder(
    column: $table.postedDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get commandId => $composableBuilder(
    column: $table.commandId,
    builder: (column) => ColumnOrderings(column),
  );

  $AccountsOrderingComposer get accountId {
    final $AccountsOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $AccountsOrderingComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $LedgerEntriesOrderingComposer get reversalOf {
    final $LedgerEntriesOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.reversalOf,
      referencedTable: $db.ledgerEntries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $LedgerEntriesOrderingComposer(
            $db: $db,
            $table: $db.ledgerEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $LedgerEntriesAnnotationComposer
    extends Composer<_$FamilyDatabase, LedgerEntries> {
  $LedgerEntriesAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get delta =>
      $composableBuilder(column: $table.delta, builder: (column) => column);

  GeneratedColumn<int> get balanceAfter => $composableBuilder(
    column: $table.balanceAfter,
    builder: (column) => column,
  );

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get sourceKey =>
      $composableBuilder(column: $table.sourceKey, builder: (column) => column);

  GeneratedColumn<String> get actualDate => $composableBuilder(
    column: $table.actualDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get postedDay =>
      $composableBuilder(column: $table.postedDay, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get commandId =>
      $composableBuilder(column: $table.commandId, builder: (column) => column);

  $AccountsAnnotationComposer get accountId {
    final $AccountsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $AccountsAnnotationComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $LedgerEntriesAnnotationComposer get reversalOf {
    final $LedgerEntriesAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.reversalOf,
      referencedTable: $db.ledgerEntries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $LedgerEntriesAnnotationComposer(
            $db: $db,
            $table: $db.ledgerEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> penaltyEventsRefs<T extends Object>(
    Expression<T> Function($PenaltyEventsAnnotationComposer a) f,
  ) {
    final $PenaltyEventsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.penaltyEvents,
      getReferencedColumn: (t) => t.ledgerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $PenaltyEventsAnnotationComposer(
            $db: $db,
            $table: $db.penaltyEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> purchasesRefs<T extends Object>(
    Expression<T> Function($PurchasesAnnotationComposer a) f,
  ) {
    final $PurchasesAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.purchases,
      getReferencedColumn: (t) => t.ledgerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $PurchasesAnnotationComposer(
            $db: $db,
            $table: $db.purchases,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> correctionRecordsRefs<T extends Object>(
    Expression<T> Function($CorrectionRecordsAnnotationComposer a) f,
  ) {
    final $CorrectionRecordsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.correctionRecords,
      getReferencedColumn: (t) => t.originalRewardId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $CorrectionRecordsAnnotationComposer(
            $db: $db,
            $table: $db.correctionRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $LedgerEntriesTableManager
    extends
        RootTableManager<
          _$FamilyDatabase,
          LedgerEntries,
          LedgerEntry,
          $LedgerEntriesFilterComposer,
          $LedgerEntriesOrderingComposer,
          $LedgerEntriesAnnotationComposer,
          $LedgerEntriesCreateCompanionBuilder,
          $LedgerEntriesUpdateCompanionBuilder,
          (LedgerEntry, $LedgerEntriesReferences),
          LedgerEntry,
          PrefetchHooks Function({
            bool accountId,
            bool reversalOf,
            bool penaltyEventsRefs,
            bool purchasesRefs,
            bool correctionRecordsRefs,
          })
        > {
  $LedgerEntriesTableManager(_$FamilyDatabase db, LedgerEntries table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $LedgerEntriesFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $LedgerEntriesOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $LedgerEntriesAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> accountId = const Value.absent(),
                Value<int> delta = const Value.absent(),
                Value<int> balanceAfter = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> sourceKey = const Value.absent(),
                Value<String?> reversalOf = const Value.absent(),
                Value<String> actualDate = const Value.absent(),
                Value<String> postedDay = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<String> commandId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LedgerEntriesCompanion(
                id: id,
                accountId: accountId,
                delta: delta,
                balanceAfter: balanceAfter,
                kind: kind,
                sourceKey: sourceKey,
                reversalOf: reversalOf,
                actualDate: actualDate,
                postedDay: postedDay,
                createdAt: createdAt,
                commandId: commandId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String accountId,
                required int delta,
                required int balanceAfter,
                required String kind,
                required String sourceKey,
                Value<String?> reversalOf = const Value.absent(),
                required String actualDate,
                required String postedDay,
                required int createdAt,
                required String commandId,
                Value<int> rowid = const Value.absent(),
              }) => LedgerEntriesCompanion.insert(
                id: id,
                accountId: accountId,
                delta: delta,
                balanceAfter: balanceAfter,
                kind: kind,
                sourceKey: sourceKey,
                reversalOf: reversalOf,
                actualDate: actualDate,
                postedDay: postedDay,
                createdAt: createdAt,
                commandId: commandId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<LedgerEntries, LedgerEntry>(table),
                  $LedgerEntriesReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                accountId = false,
                reversalOf = false,
                penaltyEventsRefs = false,
                purchasesRefs = false,
                correctionRecordsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (penaltyEventsRefs) db.penaltyEvents,
                    if (purchasesRefs) db.purchases,
                    if (correctionRecordsRefs) db.correctionRecords,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (accountId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.accountId,
                            referencedTable: $LedgerEntriesReferences
                                ._accountIdTable(db),
                            referencedColumn: $LedgerEntriesReferences
                                ._accountIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (reversalOf) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.reversalOf,
                            referencedTable: $LedgerEntriesReferences
                                ._reversalOfTable(db),
                            referencedColumn: $LedgerEntriesReferences
                                ._reversalOfTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (penaltyEventsRefs)
                        await $_getPrefetchedDataByColumns<
                          LedgerEntry,
                          LedgerEntries,
                          PenaltyEvent,
                          PenaltyEvents
                        >(
                          currentTable: table,
                          referencedTable: $LedgerEntriesReferences
                              ._penaltyEventsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $LedgerEntriesReferences(
                                db,
                                table,
                                p0,
                              ).penaltyEventsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'ledger_id',
                          typedResults: items,
                        ),
                      if (purchasesRefs)
                        await $_getPrefetchedDataByColumns<
                          LedgerEntry,
                          LedgerEntries,
                          Purchase,
                          Purchases
                        >(
                          currentTable: table,
                          referencedTable: $LedgerEntriesReferences
                              ._purchasesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $LedgerEntriesReferences(
                                db,
                                table,
                                p0,
                              ).purchasesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'ledger_id',
                          typedResults: items,
                        ),
                      if (correctionRecordsRefs)
                        await $_getPrefetchedDataByColumns<
                          LedgerEntry,
                          LedgerEntries,
                          CorrectionRecord,
                          CorrectionRecords
                        >(
                          currentTable: table,
                          referencedTable: $LedgerEntriesReferences
                              ._correctionRecordsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $LedgerEntriesReferences(
                                db,
                                table,
                                p0,
                              ).correctionRecordsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'original_reward_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $LedgerEntriesProcessedTableManager =
    ProcessedTableManager<
      _$FamilyDatabase,
      LedgerEntries,
      LedgerEntry,
      $LedgerEntriesFilterComposer,
      $LedgerEntriesOrderingComposer,
      $LedgerEntriesAnnotationComposer,
      $LedgerEntriesCreateCompanionBuilder,
      $LedgerEntriesUpdateCompanionBuilder,
      (LedgerEntry, $LedgerEntriesReferences),
      LedgerEntry,
      PrefetchHooks Function({
        bool accountId,
        bool reversalOf,
        bool penaltyEventsRefs,
        bool purchasesRefs,
        bool correctionRecordsRefs,
      })
    >;
typedef $ProcessedCommandsCreateCompanionBuilder =
    ProcessedCommandsCompanion Function({
      required String id,
      required String payloadHash,
      required String resultJson,
      required int createdAt,
      Value<int> rowid,
    });
typedef $ProcessedCommandsUpdateCompanionBuilder =
    ProcessedCommandsCompanion Function({
      Value<String> id,
      Value<String> payloadHash,
      Value<String> resultJson,
      Value<int> createdAt,
      Value<int> rowid,
    });

class $ProcessedCommandsFilterComposer
    extends Composer<_$FamilyDatabase, ProcessedCommands> {
  $ProcessedCommandsFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadHash => $composableBuilder(
    column: $table.payloadHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get resultJson => $composableBuilder(
    column: $table.resultJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $ProcessedCommandsOrderingComposer
    extends Composer<_$FamilyDatabase, ProcessedCommands> {
  $ProcessedCommandsOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadHash => $composableBuilder(
    column: $table.payloadHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get resultJson => $composableBuilder(
    column: $table.resultJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $ProcessedCommandsAnnotationComposer
    extends Composer<_$FamilyDatabase, ProcessedCommands> {
  $ProcessedCommandsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get payloadHash => $composableBuilder(
    column: $table.payloadHash,
    builder: (column) => column,
  );

  GeneratedColumn<String> get resultJson => $composableBuilder(
    column: $table.resultJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $ProcessedCommandsTableManager
    extends
        RootTableManager<
          _$FamilyDatabase,
          ProcessedCommands,
          ProcessedCommand,
          $ProcessedCommandsFilterComposer,
          $ProcessedCommandsOrderingComposer,
          $ProcessedCommandsAnnotationComposer,
          $ProcessedCommandsCreateCompanionBuilder,
          $ProcessedCommandsUpdateCompanionBuilder,
          (
            ProcessedCommand,
            BaseReferences<
              _$FamilyDatabase,
              ProcessedCommands,
              ProcessedCommand
            >,
          ),
          ProcessedCommand,
          PrefetchHooks Function()
        > {
  $ProcessedCommandsTableManager(_$FamilyDatabase db, ProcessedCommands table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $ProcessedCommandsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $ProcessedCommandsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $ProcessedCommandsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> payloadHash = const Value.absent(),
                Value<String> resultJson = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProcessedCommandsCompanion(
                id: id,
                payloadHash: payloadHash,
                resultJson: resultJson,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String payloadHash,
                required String resultJson,
                required int createdAt,
                Value<int> rowid = const Value.absent(),
              }) => ProcessedCommandsCompanion.insert(
                id: id,
                payloadHash: payloadHash,
                resultJson: resultJson,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<ProcessedCommands, ProcessedCommand>(table),
                  BaseReferences<
                    _$FamilyDatabase,
                    ProcessedCommands,
                    ProcessedCommand
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $ProcessedCommandsProcessedTableManager =
    ProcessedTableManager<
      _$FamilyDatabase,
      ProcessedCommands,
      ProcessedCommand,
      $ProcessedCommandsFilterComposer,
      $ProcessedCommandsOrderingComposer,
      $ProcessedCommandsAnnotationComposer,
      $ProcessedCommandsCreateCompanionBuilder,
      $ProcessedCommandsUpdateCompanionBuilder,
      (
        ProcessedCommand,
        BaseReferences<_$FamilyDatabase, ProcessedCommands, ProcessedCommand>,
      ),
      ProcessedCommand,
      PrefetchHooks Function()
    >;
typedef $PenaltyRulesCreateCompanionBuilder = PenaltyRulesCompanion Function({
  required String id,
  required String behavior,
  required String conditionText,
  required int points,
  Value<int> rowid,
});
typedef $PenaltyRulesUpdateCompanionBuilder = PenaltyRulesCompanion Function({
  Value<String> id,
  Value<String> behavior,
  Value<String> conditionText,
  Value<int> points,
  Value<int> rowid,
});

final class $PenaltyRulesReferences
    extends BaseReferences<_$FamilyDatabase, PenaltyRules, PenaltyRule> {
  $PenaltyRulesReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<PenaltyEvents, List<PenaltyEvent>>
  _penaltyEventsRefsTable(_$FamilyDatabase db) => MultiTypedResultKey.fromTable(
    db.penaltyEvents,
    aliasName: 'penalty_rules__id__penalty_events__rule_id',
  );

  $PenaltyEventsProcessedTableManager get penaltyEventsRefs {
    final manager = $PenaltyEventsTableManager(
      $_db,
      $_db.penaltyEvents,
    ).filter((f) => f.ruleId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_penaltyEventsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $PenaltyRulesFilterComposer
    extends Composer<_$FamilyDatabase, PenaltyRules> {
  $PenaltyRulesFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get behavior => $composableBuilder(
    column: $table.behavior,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get conditionText => $composableBuilder(
    column: $table.conditionText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get points => $composableBuilder(
    column: $table.points,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> penaltyEventsRefs(
    Expression<bool> Function($PenaltyEventsFilterComposer f) f,
  ) {
    final $PenaltyEventsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.penaltyEvents,
      getReferencedColumn: (t) => t.ruleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $PenaltyEventsFilterComposer(
            $db: $db,
            $table: $db.penaltyEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $PenaltyRulesOrderingComposer
    extends Composer<_$FamilyDatabase, PenaltyRules> {
  $PenaltyRulesOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get behavior => $composableBuilder(
    column: $table.behavior,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get conditionText => $composableBuilder(
    column: $table.conditionText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get points => $composableBuilder(
    column: $table.points,
    builder: (column) => ColumnOrderings(column),
  );
}

class $PenaltyRulesAnnotationComposer
    extends Composer<_$FamilyDatabase, PenaltyRules> {
  $PenaltyRulesAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get behavior =>
      $composableBuilder(column: $table.behavior, builder: (column) => column);

  GeneratedColumn<String> get conditionText => $composableBuilder(
    column: $table.conditionText,
    builder: (column) => column,
  );

  GeneratedColumn<int> get points =>
      $composableBuilder(column: $table.points, builder: (column) => column);

  Expression<T> penaltyEventsRefs<T extends Object>(
    Expression<T> Function($PenaltyEventsAnnotationComposer a) f,
  ) {
    final $PenaltyEventsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.penaltyEvents,
      getReferencedColumn: (t) => t.ruleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $PenaltyEventsAnnotationComposer(
            $db: $db,
            $table: $db.penaltyEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $PenaltyRulesTableManager
    extends
        RootTableManager<
          _$FamilyDatabase,
          PenaltyRules,
          PenaltyRule,
          $PenaltyRulesFilterComposer,
          $PenaltyRulesOrderingComposer,
          $PenaltyRulesAnnotationComposer,
          $PenaltyRulesCreateCompanionBuilder,
          $PenaltyRulesUpdateCompanionBuilder,
          (PenaltyRule, $PenaltyRulesReferences),
          PenaltyRule,
          PrefetchHooks Function({bool penaltyEventsRefs})
        > {
  $PenaltyRulesTableManager(_$FamilyDatabase db, PenaltyRules table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $PenaltyRulesFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $PenaltyRulesOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $PenaltyRulesAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> behavior = const Value.absent(),
                Value<String> conditionText = const Value.absent(),
                Value<int> points = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PenaltyRulesCompanion(
                id: id,
                behavior: behavior,
                conditionText: conditionText,
                points: points,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String behavior,
                required String conditionText,
                required int points,
                Value<int> rowid = const Value.absent(),
              }) => PenaltyRulesCompanion.insert(
                id: id,
                behavior: behavior,
                conditionText: conditionText,
                points: points,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<PenaltyRules, PenaltyRule>(table),
                  $PenaltyRulesReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({penaltyEventsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (penaltyEventsRefs) db.penaltyEvents,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (penaltyEventsRefs)
                    await $_getPrefetchedDataByColumns<
                      PenaltyRule,
                      PenaltyRules,
                      PenaltyEvent,
                      PenaltyEvents
                    >(
                      currentTable: table,
                      referencedTable: $PenaltyRulesReferences
                          ._penaltyEventsRefsTable(db),
                      managerFromTypedResult: (p0) => $PenaltyRulesReferences(
                        db,
                        table,
                        p0,
                      ).penaltyEventsRefs,
                      currentColumn: 'id',
                      referencedColumn: 'rule_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $PenaltyRulesProcessedTableManager =
    ProcessedTableManager<
      _$FamilyDatabase,
      PenaltyRules,
      PenaltyRule,
      $PenaltyRulesFilterComposer,
      $PenaltyRulesOrderingComposer,
      $PenaltyRulesAnnotationComposer,
      $PenaltyRulesCreateCompanionBuilder,
      $PenaltyRulesUpdateCompanionBuilder,
      (PenaltyRule, $PenaltyRulesReferences),
      PenaltyRule,
      PrefetchHooks Function({bool penaltyEventsRefs})
    >;
typedef $PenaltyEventsCreateCompanionBuilder = PenaltyEventsCompanion Function({
  required String id,
  required String ruleId,
  required String fact,
  required String actualDate,
  required String postedDay,
  required int plannedPoints,
  required int deducted,
  required String ledgerId,
  Value<int> rowid,
});
typedef $PenaltyEventsUpdateCompanionBuilder = PenaltyEventsCompanion Function({
  Value<String> id,
  Value<String> ruleId,
  Value<String> fact,
  Value<String> actualDate,
  Value<String> postedDay,
  Value<int> plannedPoints,
  Value<int> deducted,
  Value<String> ledgerId,
  Value<int> rowid,
});

final class $PenaltyEventsReferences
    extends BaseReferences<_$FamilyDatabase, PenaltyEvents, PenaltyEvent> {
  $PenaltyEventsReferences(super.$_db, super.$_table, super.$_typedResult);

  static PenaltyRules _ruleIdTable(_$FamilyDatabase db) =>
      db.penaltyRules.createAlias('penalty_events__rule_id__penalty_rules__id');

  $PenaltyRulesProcessedTableManager get ruleId {
    final $_column = $_itemColumn<String>('rule_id')!;

    final manager = $PenaltyRulesTableManager(
      $_db,
      $_db.penaltyRules,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_ruleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static LedgerEntries _ledgerIdTable(_$FamilyDatabase db) => db.ledgerEntries
      .createAlias('penalty_events__ledger_id__ledger_entries__id');

  $LedgerEntriesProcessedTableManager get ledgerId {
    final $_column = $_itemColumn<String>('ledger_id')!;

    final manager = $LedgerEntriesTableManager(
      $_db,
      $_db.ledgerEntries,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_ledgerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $PenaltyEventsFilterComposer
    extends Composer<_$FamilyDatabase, PenaltyEvents> {
  $PenaltyEventsFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fact => $composableBuilder(
    column: $table.fact,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get actualDate => $composableBuilder(
    column: $table.actualDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get postedDay => $composableBuilder(
    column: $table.postedDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get plannedPoints => $composableBuilder(
    column: $table.plannedPoints,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deducted => $composableBuilder(
    column: $table.deducted,
    builder: (column) => ColumnFilters(column),
  );

  $PenaltyRulesFilterComposer get ruleId {
    final $PenaltyRulesFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ruleId,
      referencedTable: $db.penaltyRules,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $PenaltyRulesFilterComposer(
            $db: $db,
            $table: $db.penaltyRules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $LedgerEntriesFilterComposer get ledgerId {
    final $LedgerEntriesFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ledgerId,
      referencedTable: $db.ledgerEntries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $LedgerEntriesFilterComposer(
            $db: $db,
            $table: $db.ledgerEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $PenaltyEventsOrderingComposer
    extends Composer<_$FamilyDatabase, PenaltyEvents> {
  $PenaltyEventsOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fact => $composableBuilder(
    column: $table.fact,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get actualDate => $composableBuilder(
    column: $table.actualDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get postedDay => $composableBuilder(
    column: $table.postedDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get plannedPoints => $composableBuilder(
    column: $table.plannedPoints,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deducted => $composableBuilder(
    column: $table.deducted,
    builder: (column) => ColumnOrderings(column),
  );

  $PenaltyRulesOrderingComposer get ruleId {
    final $PenaltyRulesOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ruleId,
      referencedTable: $db.penaltyRules,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $PenaltyRulesOrderingComposer(
            $db: $db,
            $table: $db.penaltyRules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $LedgerEntriesOrderingComposer get ledgerId {
    final $LedgerEntriesOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ledgerId,
      referencedTable: $db.ledgerEntries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $LedgerEntriesOrderingComposer(
            $db: $db,
            $table: $db.ledgerEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $PenaltyEventsAnnotationComposer
    extends Composer<_$FamilyDatabase, PenaltyEvents> {
  $PenaltyEventsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get fact =>
      $composableBuilder(column: $table.fact, builder: (column) => column);

  GeneratedColumn<String> get actualDate => $composableBuilder(
    column: $table.actualDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get postedDay =>
      $composableBuilder(column: $table.postedDay, builder: (column) => column);

  GeneratedColumn<int> get plannedPoints => $composableBuilder(
    column: $table.plannedPoints,
    builder: (column) => column,
  );

  GeneratedColumn<int> get deducted =>
      $composableBuilder(column: $table.deducted, builder: (column) => column);

  $PenaltyRulesAnnotationComposer get ruleId {
    final $PenaltyRulesAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ruleId,
      referencedTable: $db.penaltyRules,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $PenaltyRulesAnnotationComposer(
            $db: $db,
            $table: $db.penaltyRules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $LedgerEntriesAnnotationComposer get ledgerId {
    final $LedgerEntriesAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ledgerId,
      referencedTable: $db.ledgerEntries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $LedgerEntriesAnnotationComposer(
            $db: $db,
            $table: $db.ledgerEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $PenaltyEventsTableManager
    extends
        RootTableManager<
          _$FamilyDatabase,
          PenaltyEvents,
          PenaltyEvent,
          $PenaltyEventsFilterComposer,
          $PenaltyEventsOrderingComposer,
          $PenaltyEventsAnnotationComposer,
          $PenaltyEventsCreateCompanionBuilder,
          $PenaltyEventsUpdateCompanionBuilder,
          (PenaltyEvent, $PenaltyEventsReferences),
          PenaltyEvent,
          PrefetchHooks Function({bool ruleId, bool ledgerId})
        > {
  $PenaltyEventsTableManager(_$FamilyDatabase db, PenaltyEvents table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $PenaltyEventsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $PenaltyEventsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $PenaltyEventsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> ruleId = const Value.absent(),
                Value<String> fact = const Value.absent(),
                Value<String> actualDate = const Value.absent(),
                Value<String> postedDay = const Value.absent(),
                Value<int> plannedPoints = const Value.absent(),
                Value<int> deducted = const Value.absent(),
                Value<String> ledgerId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PenaltyEventsCompanion(
                id: id,
                ruleId: ruleId,
                fact: fact,
                actualDate: actualDate,
                postedDay: postedDay,
                plannedPoints: plannedPoints,
                deducted: deducted,
                ledgerId: ledgerId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String ruleId,
                required String fact,
                required String actualDate,
                required String postedDay,
                required int plannedPoints,
                required int deducted,
                required String ledgerId,
                Value<int> rowid = const Value.absent(),
              }) => PenaltyEventsCompanion.insert(
                id: id,
                ruleId: ruleId,
                fact: fact,
                actualDate: actualDate,
                postedDay: postedDay,
                plannedPoints: plannedPoints,
                deducted: deducted,
                ledgerId: ledgerId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<PenaltyEvents, PenaltyEvent>(table),
                  $PenaltyEventsReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({ruleId = false, ledgerId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (ruleId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.ruleId,
                        referencedTable: $PenaltyEventsReferences._ruleIdTable(
                          db,
                        ),
                        referencedColumn: $PenaltyEventsReferences
                            ._ruleIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (ledgerId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.ledgerId,
                        referencedTable: $PenaltyEventsReferences
                            ._ledgerIdTable(db),
                        referencedColumn: $PenaltyEventsReferences
                            ._ledgerIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $PenaltyEventsProcessedTableManager =
    ProcessedTableManager<
      _$FamilyDatabase,
      PenaltyEvents,
      PenaltyEvent,
      $PenaltyEventsFilterComposer,
      $PenaltyEventsOrderingComposer,
      $PenaltyEventsAnnotationComposer,
      $PenaltyEventsCreateCompanionBuilder,
      $PenaltyEventsUpdateCompanionBuilder,
      (PenaltyEvent, $PenaltyEventsReferences),
      PenaltyEvent,
      PrefetchHooks Function({bool ruleId, bool ledgerId})
    >;
typedef $PenaltyDayUsageCreateCompanionBuilder =
    PenaltyDayUsageCompanion Function({
      required String accountId,
      required String postedDay,
      required int used,
      Value<int> rowid,
    });
typedef $PenaltyDayUsageUpdateCompanionBuilder =
    PenaltyDayUsageCompanion Function({
      Value<String> accountId,
      Value<String> postedDay,
      Value<int> used,
      Value<int> rowid,
    });

final class $PenaltyDayUsageReferences
    extends
        BaseReferences<_$FamilyDatabase, PenaltyDayUsage, PenaltyDayUsageData> {
  $PenaltyDayUsageReferences(super.$_db, super.$_table, super.$_typedResult);

  static Accounts _accountIdTable(_$FamilyDatabase db) =>
      db.accounts.createAlias('penalty_day_usage__account_id__accounts__id');

  $AccountsProcessedTableManager get accountId {
    final $_column = $_itemColumn<String>('account_id')!;

    final manager = $AccountsTableManager(
      $_db,
      $_db.accounts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_accountIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $PenaltyDayUsageFilterComposer
    extends Composer<_$FamilyDatabase, PenaltyDayUsage> {
  $PenaltyDayUsageFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get postedDay => $composableBuilder(
    column: $table.postedDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get used => $composableBuilder(
    column: $table.used,
    builder: (column) => ColumnFilters(column),
  );

  $AccountsFilterComposer get accountId {
    final $AccountsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $AccountsFilterComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $PenaltyDayUsageOrderingComposer
    extends Composer<_$FamilyDatabase, PenaltyDayUsage> {
  $PenaltyDayUsageOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get postedDay => $composableBuilder(
    column: $table.postedDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get used => $composableBuilder(
    column: $table.used,
    builder: (column) => ColumnOrderings(column),
  );

  $AccountsOrderingComposer get accountId {
    final $AccountsOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $AccountsOrderingComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $PenaltyDayUsageAnnotationComposer
    extends Composer<_$FamilyDatabase, PenaltyDayUsage> {
  $PenaltyDayUsageAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get postedDay =>
      $composableBuilder(column: $table.postedDay, builder: (column) => column);

  GeneratedColumn<int> get used =>
      $composableBuilder(column: $table.used, builder: (column) => column);

  $AccountsAnnotationComposer get accountId {
    final $AccountsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $AccountsAnnotationComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $PenaltyDayUsageTableManager
    extends
        RootTableManager<
          _$FamilyDatabase,
          PenaltyDayUsage,
          PenaltyDayUsageData,
          $PenaltyDayUsageFilterComposer,
          $PenaltyDayUsageOrderingComposer,
          $PenaltyDayUsageAnnotationComposer,
          $PenaltyDayUsageCreateCompanionBuilder,
          $PenaltyDayUsageUpdateCompanionBuilder,
          (PenaltyDayUsageData, $PenaltyDayUsageReferences),
          PenaltyDayUsageData,
          PrefetchHooks Function({bool accountId})
        > {
  $PenaltyDayUsageTableManager(_$FamilyDatabase db, PenaltyDayUsage table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $PenaltyDayUsageFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $PenaltyDayUsageOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $PenaltyDayUsageAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> accountId = const Value.absent(),
                Value<String> postedDay = const Value.absent(),
                Value<int> used = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PenaltyDayUsageCompanion(
                accountId: accountId,
                postedDay: postedDay,
                used: used,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String accountId,
                required String postedDay,
                required int used,
                Value<int> rowid = const Value.absent(),
              }) => PenaltyDayUsageCompanion.insert(
                accountId: accountId,
                postedDay: postedDay,
                used: used,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<PenaltyDayUsage, PenaltyDayUsageData>(table),
                  $PenaltyDayUsageReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({accountId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (accountId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.accountId,
                        referencedTable: $PenaltyDayUsageReferences
                            ._accountIdTable(db),
                        referencedColumn: $PenaltyDayUsageReferences
                            ._accountIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $PenaltyDayUsageProcessedTableManager =
    ProcessedTableManager<
      _$FamilyDatabase,
      PenaltyDayUsage,
      PenaltyDayUsageData,
      $PenaltyDayUsageFilterComposer,
      $PenaltyDayUsageOrderingComposer,
      $PenaltyDayUsageAnnotationComposer,
      $PenaltyDayUsageCreateCompanionBuilder,
      $PenaltyDayUsageUpdateCompanionBuilder,
      (PenaltyDayUsageData, $PenaltyDayUsageReferences),
      PenaltyDayUsageData,
      PrefetchHooks Function({bool accountId})
    >;
typedef $PurchasesCreateCompanionBuilder = PurchasesCompanion Function({
  required String id,
  required String itemId,
  required String name,
  required int pricePaid,
  required String ledgerId,
  required int createdAt,
  Value<int?> refundedAt,
  required String commandId,
  required String assetId,
  Value<int> rowid,
});
typedef $PurchasesUpdateCompanionBuilder = PurchasesCompanion Function({
  Value<String> id,
  Value<String> itemId,
  Value<String> name,
  Value<int> pricePaid,
  Value<String> ledgerId,
  Value<int> createdAt,
  Value<int?> refundedAt,
  Value<String> commandId,
  Value<String> assetId,
  Value<int> rowid,
});

final class $PurchasesReferences
    extends BaseReferences<_$FamilyDatabase, Purchases, Purchase> {
  $PurchasesReferences(super.$_db, super.$_table, super.$_typedResult);

  static LedgerEntries _ledgerIdTable(_$FamilyDatabase db) =>
      db.ledgerEntries.createAlias('purchases__ledger_id__ledger_entries__id');

  $LedgerEntriesProcessedTableManager get ledgerId {
    final $_column = $_itemColumn<String>('ledger_id')!;

    final manager = $LedgerEntriesTableManager(
      $_db,
      $_db.ledgerEntries,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_ledgerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<Spaces, List<Space>> _spacesRefsTable(
    _$FamilyDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.spaces,
    aliasName: 'purchases__id__spaces__purchase_id',
  );

  $SpacesProcessedTableManager get spacesRefs {
    final manager = $SpacesTableManager(
      $_db,
      $_db.spaces,
    ).filter((f) => f.purchaseId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_spacesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<Entitlements, List<Entitlement>>
  _entitlementsRefsTable(_$FamilyDatabase db) => MultiTypedResultKey.fromTable(
    db.entitlements,
    aliasName: 'purchases__id__entitlements__purchase_id',
  );

  $EntitlementsProcessedTableManager get entitlementsRefs {
    final manager = $EntitlementsTableManager(
      $_db,
      $_db.entitlements,
    ).filter((f) => f.purchaseId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_entitlementsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $PurchasesFilterComposer extends Composer<_$FamilyDatabase, Purchases> {
  $PurchasesFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pricePaid => $composableBuilder(
    column: $table.pricePaid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get refundedAt => $composableBuilder(
    column: $table.refundedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get commandId => $composableBuilder(
    column: $table.commandId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get assetId => $composableBuilder(
    column: $table.assetId,
    builder: (column) => ColumnFilters(column),
  );

  $LedgerEntriesFilterComposer get ledgerId {
    final $LedgerEntriesFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ledgerId,
      referencedTable: $db.ledgerEntries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $LedgerEntriesFilterComposer(
            $db: $db,
            $table: $db.ledgerEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> spacesRefs(
    Expression<bool> Function($SpacesFilterComposer f) f,
  ) {
    final $SpacesFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.spaces,
      getReferencedColumn: (t) => t.purchaseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $SpacesFilterComposer(
            $db: $db,
            $table: $db.spaces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> entitlementsRefs(
    Expression<bool> Function($EntitlementsFilterComposer f) f,
  ) {
    final $EntitlementsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.entitlements,
      getReferencedColumn: (t) => t.purchaseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $EntitlementsFilterComposer(
            $db: $db,
            $table: $db.entitlements,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $PurchasesOrderingComposer extends Composer<_$FamilyDatabase, Purchases> {
  $PurchasesOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pricePaid => $composableBuilder(
    column: $table.pricePaid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get refundedAt => $composableBuilder(
    column: $table.refundedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get commandId => $composableBuilder(
    column: $table.commandId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get assetId => $composableBuilder(
    column: $table.assetId,
    builder: (column) => ColumnOrderings(column),
  );

  $LedgerEntriesOrderingComposer get ledgerId {
    final $LedgerEntriesOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ledgerId,
      referencedTable: $db.ledgerEntries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $LedgerEntriesOrderingComposer(
            $db: $db,
            $table: $db.ledgerEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $PurchasesAnnotationComposer
    extends Composer<_$FamilyDatabase, Purchases> {
  $PurchasesAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get pricePaid =>
      $composableBuilder(column: $table.pricePaid, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get refundedAt => $composableBuilder(
    column: $table.refundedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get commandId =>
      $composableBuilder(column: $table.commandId, builder: (column) => column);

  GeneratedColumn<String> get assetId =>
      $composableBuilder(column: $table.assetId, builder: (column) => column);

  $LedgerEntriesAnnotationComposer get ledgerId {
    final $LedgerEntriesAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ledgerId,
      referencedTable: $db.ledgerEntries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $LedgerEntriesAnnotationComposer(
            $db: $db,
            $table: $db.ledgerEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> spacesRefs<T extends Object>(
    Expression<T> Function($SpacesAnnotationComposer a) f,
  ) {
    final $SpacesAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.spaces,
      getReferencedColumn: (t) => t.purchaseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $SpacesAnnotationComposer(
            $db: $db,
            $table: $db.spaces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> entitlementsRefs<T extends Object>(
    Expression<T> Function($EntitlementsAnnotationComposer a) f,
  ) {
    final $EntitlementsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.entitlements,
      getReferencedColumn: (t) => t.purchaseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $EntitlementsAnnotationComposer(
            $db: $db,
            $table: $db.entitlements,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $PurchasesTableManager
    extends
        RootTableManager<
          _$FamilyDatabase,
          Purchases,
          Purchase,
          $PurchasesFilterComposer,
          $PurchasesOrderingComposer,
          $PurchasesAnnotationComposer,
          $PurchasesCreateCompanionBuilder,
          $PurchasesUpdateCompanionBuilder,
          (Purchase, $PurchasesReferences),
          Purchase,
          PrefetchHooks Function({
            bool ledgerId,
            bool spacesRefs,
            bool entitlementsRefs,
          })
        > {
  $PurchasesTableManager(_$FamilyDatabase db, Purchases table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $PurchasesFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $PurchasesOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $PurchasesAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> itemId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> pricePaid = const Value.absent(),
                Value<String> ledgerId = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int?> refundedAt = const Value.absent(),
                Value<String> commandId = const Value.absent(),
                Value<String> assetId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PurchasesCompanion(
                id: id,
                itemId: itemId,
                name: name,
                pricePaid: pricePaid,
                ledgerId: ledgerId,
                createdAt: createdAt,
                refundedAt: refundedAt,
                commandId: commandId,
                assetId: assetId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String itemId,
                required String name,
                required int pricePaid,
                required String ledgerId,
                required int createdAt,
                Value<int?> refundedAt = const Value.absent(),
                required String commandId,
                required String assetId,
                Value<int> rowid = const Value.absent(),
              }) => PurchasesCompanion.insert(
                id: id,
                itemId: itemId,
                name: name,
                pricePaid: pricePaid,
                ledgerId: ledgerId,
                createdAt: createdAt,
                refundedAt: refundedAt,
                commandId: commandId,
                assetId: assetId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<Purchases, Purchase>(table),
                  $PurchasesReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                ledgerId = false,
                spacesRefs = false,
                entitlementsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (spacesRefs) db.spaces,
                    if (entitlementsRefs) db.entitlements,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (ledgerId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.ledgerId,
                            referencedTable: $PurchasesReferences
                                ._ledgerIdTable(db),
                            referencedColumn: $PurchasesReferences
                                ._ledgerIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (spacesRefs)
                        await $_getPrefetchedDataByColumns<
                          Purchase,
                          Purchases,
                          Space,
                          Spaces
                        >(
                          currentTable: table,
                          referencedTable: $PurchasesReferences
                              ._spacesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $PurchasesReferences(db, table, p0).spacesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'purchase_id',
                          typedResults: items,
                        ),
                      if (entitlementsRefs)
                        await $_getPrefetchedDataByColumns<
                          Purchase,
                          Purchases,
                          Entitlement,
                          Entitlements
                        >(
                          currentTable: table,
                          referencedTable: $PurchasesReferences
                              ._entitlementsRefsTable(db),
                          managerFromTypedResult: (p0) => $PurchasesReferences(
                            db,
                            table,
                            p0,
                          ).entitlementsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'purchase_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $PurchasesProcessedTableManager =
    ProcessedTableManager<
      _$FamilyDatabase,
      Purchases,
      Purchase,
      $PurchasesFilterComposer,
      $PurchasesOrderingComposer,
      $PurchasesAnnotationComposer,
      $PurchasesCreateCompanionBuilder,
      $PurchasesUpdateCompanionBuilder,
      (Purchase, $PurchasesReferences),
      Purchase,
      PrefetchHooks Function({
        bool ledgerId,
        bool spacesRefs,
        bool entitlementsRefs,
      })
    >;
typedef $SpacesCreateCompanionBuilder = SpacesCompanion Function({
  required String id,
  required String sceneId,
  required String name,
  Value<String?> purchaseId,
  Value<int> layoutVersion,
  Value<int> rowid,
});
typedef $SpacesUpdateCompanionBuilder = SpacesCompanion Function({
  Value<String> id,
  Value<String> sceneId,
  Value<String> name,
  Value<String?> purchaseId,
  Value<int> layoutVersion,
  Value<int> rowid,
});

final class $SpacesReferences
    extends BaseReferences<_$FamilyDatabase, Spaces, Space> {
  $SpacesReferences(super.$_db, super.$_table, super.$_typedResult);

  static Purchases _purchaseIdTable(_$FamilyDatabase db) =>
      db.purchases.createAlias('spaces__purchase_id__purchases__id');

  $PurchasesProcessedTableManager? get purchaseId {
    final $_column = $_itemColumn<String>('purchase_id');
    if ($_column == null) return null;
    final manager = $PurchasesTableManager(
      $_db,
      $_db.purchases,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_purchaseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<Entitlements, List<Entitlement>>
  _entitlementsRefsTable(_$FamilyDatabase db) => MultiTypedResultKey.fromTable(
    db.entitlements,
    aliasName: 'spaces__id__entitlements__bound_space',
  );

  $EntitlementsProcessedTableManager get entitlementsRefs {
    final manager = $EntitlementsTableManager(
      $_db,
      $_db.entitlements,
    ).filter((f) => f.boundSpace.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_entitlementsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<Placements, List<Placement>> _placementsRefsTable(
    _$FamilyDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.placements,
    aliasName: 'spaces__id__placements__space_id',
  );

  $PlacementsProcessedTableManager get placementsRefs {
    final manager = $PlacementsTableManager(
      $_db,
      $_db.placements,
    ).filter((f) => f.spaceId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_placementsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $SpacesFilterComposer extends Composer<_$FamilyDatabase, Spaces> {
  $SpacesFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sceneId => $composableBuilder(
    column: $table.sceneId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get layoutVersion => $composableBuilder(
    column: $table.layoutVersion,
    builder: (column) => ColumnFilters(column),
  );

  $PurchasesFilterComposer get purchaseId {
    final $PurchasesFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.purchaseId,
      referencedTable: $db.purchases,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $PurchasesFilterComposer(
            $db: $db,
            $table: $db.purchases,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> entitlementsRefs(
    Expression<bool> Function($EntitlementsFilterComposer f) f,
  ) {
    final $EntitlementsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.entitlements,
      getReferencedColumn: (t) => t.boundSpace,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $EntitlementsFilterComposer(
            $db: $db,
            $table: $db.entitlements,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> placementsRefs(
    Expression<bool> Function($PlacementsFilterComposer f) f,
  ) {
    final $PlacementsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.placements,
      getReferencedColumn: (t) => t.spaceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $PlacementsFilterComposer(
            $db: $db,
            $table: $db.placements,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $SpacesOrderingComposer extends Composer<_$FamilyDatabase, Spaces> {
  $SpacesOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sceneId => $composableBuilder(
    column: $table.sceneId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get layoutVersion => $composableBuilder(
    column: $table.layoutVersion,
    builder: (column) => ColumnOrderings(column),
  );

  $PurchasesOrderingComposer get purchaseId {
    final $PurchasesOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.purchaseId,
      referencedTable: $db.purchases,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $PurchasesOrderingComposer(
            $db: $db,
            $table: $db.purchases,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $SpacesAnnotationComposer extends Composer<_$FamilyDatabase, Spaces> {
  $SpacesAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sceneId =>
      $composableBuilder(column: $table.sceneId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get layoutVersion => $composableBuilder(
    column: $table.layoutVersion,
    builder: (column) => column,
  );

  $PurchasesAnnotationComposer get purchaseId {
    final $PurchasesAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.purchaseId,
      referencedTable: $db.purchases,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $PurchasesAnnotationComposer(
            $db: $db,
            $table: $db.purchases,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> entitlementsRefs<T extends Object>(
    Expression<T> Function($EntitlementsAnnotationComposer a) f,
  ) {
    final $EntitlementsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.entitlements,
      getReferencedColumn: (t) => t.boundSpace,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $EntitlementsAnnotationComposer(
            $db: $db,
            $table: $db.entitlements,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> placementsRefs<T extends Object>(
    Expression<T> Function($PlacementsAnnotationComposer a) f,
  ) {
    final $PlacementsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.placements,
      getReferencedColumn: (t) => t.spaceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $PlacementsAnnotationComposer(
            $db: $db,
            $table: $db.placements,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $SpacesTableManager
    extends
        RootTableManager<
          _$FamilyDatabase,
          Spaces,
          Space,
          $SpacesFilterComposer,
          $SpacesOrderingComposer,
          $SpacesAnnotationComposer,
          $SpacesCreateCompanionBuilder,
          $SpacesUpdateCompanionBuilder,
          (Space, $SpacesReferences),
          Space,
          PrefetchHooks Function({
            bool purchaseId,
            bool entitlementsRefs,
            bool placementsRefs,
          })
        > {
  $SpacesTableManager(_$FamilyDatabase db, Spaces table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $SpacesFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $SpacesOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $SpacesAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> sceneId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> purchaseId = const Value.absent(),
                Value<int> layoutVersion = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SpacesCompanion(
                id: id,
                sceneId: sceneId,
                name: name,
                purchaseId: purchaseId,
                layoutVersion: layoutVersion,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String sceneId,
                required String name,
                Value<String?> purchaseId = const Value.absent(),
                Value<int> layoutVersion = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SpacesCompanion.insert(
                id: id,
                sceneId: sceneId,
                name: name,
                purchaseId: purchaseId,
                layoutVersion: layoutVersion,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<Spaces, Space>(table),
                  $SpacesReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                purchaseId = false,
                entitlementsRefs = false,
                placementsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (entitlementsRefs) db.entitlements,
                    if (placementsRefs) db.placements,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (purchaseId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.purchaseId,
                            referencedTable: $SpacesReferences._purchaseIdTable(
                              db,
                            ),
                            referencedColumn: $SpacesReferences
                                ._purchaseIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (entitlementsRefs)
                        await $_getPrefetchedDataByColumns<
                          Space,
                          Spaces,
                          Entitlement,
                          Entitlements
                        >(
                          currentTable: table,
                          referencedTable: $SpacesReferences
                              ._entitlementsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $SpacesReferences(db, table, p0).entitlementsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'bound_space',
                          typedResults: items,
                        ),
                      if (placementsRefs)
                        await $_getPrefetchedDataByColumns<
                          Space,
                          Spaces,
                          Placement,
                          Placements
                        >(
                          currentTable: table,
                          referencedTable: $SpacesReferences
                              ._placementsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $SpacesReferences(db, table, p0).placementsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'space_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $SpacesProcessedTableManager =
    ProcessedTableManager<
      _$FamilyDatabase,
      Spaces,
      Space,
      $SpacesFilterComposer,
      $SpacesOrderingComposer,
      $SpacesAnnotationComposer,
      $SpacesCreateCompanionBuilder,
      $SpacesUpdateCompanionBuilder,
      (Space, $SpacesReferences),
      Space,
      PrefetchHooks Function({
        bool purchaseId,
        bool entitlementsRefs,
        bool placementsRefs,
      })
    >;
typedef $EntitlementsCreateCompanionBuilder = EntitlementsCompanion Function({
  required String id,
  required String purchaseId,
  required String itemId,
  required String assetId,
  required String name,
  Value<String?> slot,
  Value<String?> boundSpace,
  Value<int> revoked,
  Value<int> rowid,
});
typedef $EntitlementsUpdateCompanionBuilder = EntitlementsCompanion Function({
  Value<String> id,
  Value<String> purchaseId,
  Value<String> itemId,
  Value<String> assetId,
  Value<String> name,
  Value<String?> slot,
  Value<String?> boundSpace,
  Value<int> revoked,
  Value<int> rowid,
});

final class $EntitlementsReferences
    extends BaseReferences<_$FamilyDatabase, Entitlements, Entitlement> {
  $EntitlementsReferences(super.$_db, super.$_table, super.$_typedResult);

  static Purchases _purchaseIdTable(_$FamilyDatabase db) =>
      db.purchases.createAlias('entitlements__purchase_id__purchases__id');

  $PurchasesProcessedTableManager get purchaseId {
    final $_column = $_itemColumn<String>('purchase_id')!;

    final manager = $PurchasesTableManager(
      $_db,
      $_db.purchases,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_purchaseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static Spaces _boundSpaceTable(_$FamilyDatabase db) =>
      db.spaces.createAlias('entitlements__bound_space__spaces__id');

  $SpacesProcessedTableManager? get boundSpace {
    final $_column = $_itemColumn<String>('bound_space');
    if ($_column == null) return null;
    final manager = $SpacesTableManager(
      $_db,
      $_db.spaces,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_boundSpaceTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<Placements, List<Placement>> _placementsRefsTable(
    _$FamilyDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.placements,
    aliasName: 'entitlements__id__placements__entitlement_id',
  );

  $PlacementsProcessedTableManager get placementsRefs {
    final manager = $PlacementsTableManager(
      $_db,
      $_db.placements,
    ).filter((f) => f.entitlementId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_placementsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<PetState, List<PetStateData>> _petStateRefsTable(
    _$FamilyDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.petState,
    aliasName: 'entitlements__id__pet_state__entitlement_id',
  );

  $PetStateProcessedTableManager get petStateRefs {
    final manager = $PetStateTableManager(
      $_db,
      $_db.petState,
    ).filter((f) => f.entitlementId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_petStateRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $EntitlementsFilterComposer
    extends Composer<_$FamilyDatabase, Entitlements> {
  $EntitlementsFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get assetId => $composableBuilder(
    column: $table.assetId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get slot => $composableBuilder(
    column: $table.slot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revoked => $composableBuilder(
    column: $table.revoked,
    builder: (column) => ColumnFilters(column),
  );

  $PurchasesFilterComposer get purchaseId {
    final $PurchasesFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.purchaseId,
      referencedTable: $db.purchases,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $PurchasesFilterComposer(
            $db: $db,
            $table: $db.purchases,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $SpacesFilterComposer get boundSpace {
    final $SpacesFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.boundSpace,
      referencedTable: $db.spaces,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $SpacesFilterComposer(
            $db: $db,
            $table: $db.spaces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> placementsRefs(
    Expression<bool> Function($PlacementsFilterComposer f) f,
  ) {
    final $PlacementsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.placements,
      getReferencedColumn: (t) => t.entitlementId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $PlacementsFilterComposer(
            $db: $db,
            $table: $db.placements,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> petStateRefs(
    Expression<bool> Function($PetStateFilterComposer f) f,
  ) {
    final $PetStateFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.petState,
      getReferencedColumn: (t) => t.entitlementId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $PetStateFilterComposer(
            $db: $db,
            $table: $db.petState,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $EntitlementsOrderingComposer
    extends Composer<_$FamilyDatabase, Entitlements> {
  $EntitlementsOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get assetId => $composableBuilder(
    column: $table.assetId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get slot => $composableBuilder(
    column: $table.slot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revoked => $composableBuilder(
    column: $table.revoked,
    builder: (column) => ColumnOrderings(column),
  );

  $PurchasesOrderingComposer get purchaseId {
    final $PurchasesOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.purchaseId,
      referencedTable: $db.purchases,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $PurchasesOrderingComposer(
            $db: $db,
            $table: $db.purchases,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $SpacesOrderingComposer get boundSpace {
    final $SpacesOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.boundSpace,
      referencedTable: $db.spaces,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $SpacesOrderingComposer(
            $db: $db,
            $table: $db.spaces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $EntitlementsAnnotationComposer
    extends Composer<_$FamilyDatabase, Entitlements> {
  $EntitlementsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);

  GeneratedColumn<String> get assetId =>
      $composableBuilder(column: $table.assetId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get slot =>
      $composableBuilder(column: $table.slot, builder: (column) => column);

  GeneratedColumn<int> get revoked =>
      $composableBuilder(column: $table.revoked, builder: (column) => column);

  $PurchasesAnnotationComposer get purchaseId {
    final $PurchasesAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.purchaseId,
      referencedTable: $db.purchases,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $PurchasesAnnotationComposer(
            $db: $db,
            $table: $db.purchases,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $SpacesAnnotationComposer get boundSpace {
    final $SpacesAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.boundSpace,
      referencedTable: $db.spaces,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $SpacesAnnotationComposer(
            $db: $db,
            $table: $db.spaces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> placementsRefs<T extends Object>(
    Expression<T> Function($PlacementsAnnotationComposer a) f,
  ) {
    final $PlacementsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.placements,
      getReferencedColumn: (t) => t.entitlementId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $PlacementsAnnotationComposer(
            $db: $db,
            $table: $db.placements,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> petStateRefs<T extends Object>(
    Expression<T> Function($PetStateAnnotationComposer a) f,
  ) {
    final $PetStateAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.petState,
      getReferencedColumn: (t) => t.entitlementId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $PetStateAnnotationComposer(
            $db: $db,
            $table: $db.petState,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $EntitlementsTableManager
    extends
        RootTableManager<
          _$FamilyDatabase,
          Entitlements,
          Entitlement,
          $EntitlementsFilterComposer,
          $EntitlementsOrderingComposer,
          $EntitlementsAnnotationComposer,
          $EntitlementsCreateCompanionBuilder,
          $EntitlementsUpdateCompanionBuilder,
          (Entitlement, $EntitlementsReferences),
          Entitlement,
          PrefetchHooks Function({
            bool purchaseId,
            bool boundSpace,
            bool placementsRefs,
            bool petStateRefs,
          })
        > {
  $EntitlementsTableManager(_$FamilyDatabase db, Entitlements table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $EntitlementsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $EntitlementsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $EntitlementsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> purchaseId = const Value.absent(),
                Value<String> itemId = const Value.absent(),
                Value<String> assetId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> slot = const Value.absent(),
                Value<String?> boundSpace = const Value.absent(),
                Value<int> revoked = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EntitlementsCompanion(
                id: id,
                purchaseId: purchaseId,
                itemId: itemId,
                assetId: assetId,
                name: name,
                slot: slot,
                boundSpace: boundSpace,
                revoked: revoked,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String purchaseId,
                required String itemId,
                required String assetId,
                required String name,
                Value<String?> slot = const Value.absent(),
                Value<String?> boundSpace = const Value.absent(),
                Value<int> revoked = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EntitlementsCompanion.insert(
                id: id,
                purchaseId: purchaseId,
                itemId: itemId,
                assetId: assetId,
                name: name,
                slot: slot,
                boundSpace: boundSpace,
                revoked: revoked,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<Entitlements, Entitlement>(table),
                  $EntitlementsReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                purchaseId = false,
                boundSpace = false,
                placementsRefs = false,
                petStateRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (placementsRefs) db.placements,
                    if (petStateRefs) db.petState,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (purchaseId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.purchaseId,
                            referencedTable: $EntitlementsReferences
                                ._purchaseIdTable(db),
                            referencedColumn: $EntitlementsReferences
                                ._purchaseIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (boundSpace) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.boundSpace,
                            referencedTable: $EntitlementsReferences
                                ._boundSpaceTable(db),
                            referencedColumn: $EntitlementsReferences
                                ._boundSpaceTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (placementsRefs)
                        await $_getPrefetchedDataByColumns<
                          Entitlement,
                          Entitlements,
                          Placement,
                          Placements
                        >(
                          currentTable: table,
                          referencedTable: $EntitlementsReferences
                              ._placementsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $EntitlementsReferences(
                                db,
                                table,
                                p0,
                              ).placementsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'entitlement_id',
                          typedResults: items,
                        ),
                      if (petStateRefs)
                        await $_getPrefetchedDataByColumns<
                          Entitlement,
                          Entitlements,
                          PetStateData,
                          PetState
                        >(
                          currentTable: table,
                          referencedTable: $EntitlementsReferences
                              ._petStateRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $EntitlementsReferences(
                                db,
                                table,
                                p0,
                              ).petStateRefs,
                          currentColumn: 'id',
                          referencedColumn: 'entitlement_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $EntitlementsProcessedTableManager =
    ProcessedTableManager<
      _$FamilyDatabase,
      Entitlements,
      Entitlement,
      $EntitlementsFilterComposer,
      $EntitlementsOrderingComposer,
      $EntitlementsAnnotationComposer,
      $EntitlementsCreateCompanionBuilder,
      $EntitlementsUpdateCompanionBuilder,
      (Entitlement, $EntitlementsReferences),
      Entitlement,
      PrefetchHooks Function({
        bool purchaseId,
        bool boundSpace,
        bool placementsRefs,
        bool petStateRefs,
      })
    >;
typedef $PlacementsCreateCompanionBuilder = PlacementsCompanion Function({
  required String entitlementId,
  required String spaceId,
  required double x,
  required double y,
  Value<int> rotation,
  Value<int> flipped,
  required int z,
  Value<String?> mountId,
  Value<int> rowid,
});
typedef $PlacementsUpdateCompanionBuilder = PlacementsCompanion Function({
  Value<String> entitlementId,
  Value<String> spaceId,
  Value<double> x,
  Value<double> y,
  Value<int> rotation,
  Value<int> flipped,
  Value<int> z,
  Value<String?> mountId,
  Value<int> rowid,
});

final class $PlacementsReferences
    extends BaseReferences<_$FamilyDatabase, Placements, Placement> {
  $PlacementsReferences(super.$_db, super.$_table, super.$_typedResult);

  static Entitlements _entitlementIdTable(_$FamilyDatabase db) => db
      .entitlements
      .createAlias('placements__entitlement_id__entitlements__id');

  $EntitlementsProcessedTableManager get entitlementId {
    final $_column = $_itemColumn<String>('entitlement_id')!;

    final manager = $EntitlementsTableManager(
      $_db,
      $_db.entitlements,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_entitlementIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static Spaces _spaceIdTable(_$FamilyDatabase db) =>
      db.spaces.createAlias('placements__space_id__spaces__id');

  $SpacesProcessedTableManager get spaceId {
    final $_column = $_itemColumn<String>('space_id')!;

    final manager = $SpacesTableManager(
      $_db,
      $_db.spaces,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_spaceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $PlacementsFilterComposer extends Composer<_$FamilyDatabase, Placements> {
  $PlacementsFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<double> get x => $composableBuilder(
    column: $table.x,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get y => $composableBuilder(
    column: $table.y,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rotation => $composableBuilder(
    column: $table.rotation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get flipped => $composableBuilder(
    column: $table.flipped,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get z => $composableBuilder(
    column: $table.z,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mountId => $composableBuilder(
    column: $table.mountId,
    builder: (column) => ColumnFilters(column),
  );

  $EntitlementsFilterComposer get entitlementId {
    final $EntitlementsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.entitlementId,
      referencedTable: $db.entitlements,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $EntitlementsFilterComposer(
            $db: $db,
            $table: $db.entitlements,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $SpacesFilterComposer get spaceId {
    final $SpacesFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.spaceId,
      referencedTable: $db.spaces,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $SpacesFilterComposer(
            $db: $db,
            $table: $db.spaces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $PlacementsOrderingComposer
    extends Composer<_$FamilyDatabase, Placements> {
  $PlacementsOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<double> get x => $composableBuilder(
    column: $table.x,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get y => $composableBuilder(
    column: $table.y,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rotation => $composableBuilder(
    column: $table.rotation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get flipped => $composableBuilder(
    column: $table.flipped,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get z => $composableBuilder(
    column: $table.z,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mountId => $composableBuilder(
    column: $table.mountId,
    builder: (column) => ColumnOrderings(column),
  );

  $EntitlementsOrderingComposer get entitlementId {
    final $EntitlementsOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.entitlementId,
      referencedTable: $db.entitlements,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $EntitlementsOrderingComposer(
            $db: $db,
            $table: $db.entitlements,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $SpacesOrderingComposer get spaceId {
    final $SpacesOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.spaceId,
      referencedTable: $db.spaces,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $SpacesOrderingComposer(
            $db: $db,
            $table: $db.spaces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $PlacementsAnnotationComposer
    extends Composer<_$FamilyDatabase, Placements> {
  $PlacementsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<double> get x =>
      $composableBuilder(column: $table.x, builder: (column) => column);

  GeneratedColumn<double> get y =>
      $composableBuilder(column: $table.y, builder: (column) => column);

  GeneratedColumn<int> get rotation =>
      $composableBuilder(column: $table.rotation, builder: (column) => column);

  GeneratedColumn<int> get flipped =>
      $composableBuilder(column: $table.flipped, builder: (column) => column);

  GeneratedColumn<int> get z =>
      $composableBuilder(column: $table.z, builder: (column) => column);

  GeneratedColumn<String> get mountId =>
      $composableBuilder(column: $table.mountId, builder: (column) => column);

  $EntitlementsAnnotationComposer get entitlementId {
    final $EntitlementsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.entitlementId,
      referencedTable: $db.entitlements,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $EntitlementsAnnotationComposer(
            $db: $db,
            $table: $db.entitlements,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $SpacesAnnotationComposer get spaceId {
    final $SpacesAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.spaceId,
      referencedTable: $db.spaces,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $SpacesAnnotationComposer(
            $db: $db,
            $table: $db.spaces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $PlacementsTableManager
    extends
        RootTableManager<
          _$FamilyDatabase,
          Placements,
          Placement,
          $PlacementsFilterComposer,
          $PlacementsOrderingComposer,
          $PlacementsAnnotationComposer,
          $PlacementsCreateCompanionBuilder,
          $PlacementsUpdateCompanionBuilder,
          (Placement, $PlacementsReferences),
          Placement,
          PrefetchHooks Function({bool entitlementId, bool spaceId})
        > {
  $PlacementsTableManager(_$FamilyDatabase db, Placements table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $PlacementsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $PlacementsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $PlacementsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> entitlementId = const Value.absent(),
                Value<String> spaceId = const Value.absent(),
                Value<double> x = const Value.absent(),
                Value<double> y = const Value.absent(),
                Value<int> rotation = const Value.absent(),
                Value<int> flipped = const Value.absent(),
                Value<int> z = const Value.absent(),
                Value<String?> mountId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlacementsCompanion(
                entitlementId: entitlementId,
                spaceId: spaceId,
                x: x,
                y: y,
                rotation: rotation,
                flipped: flipped,
                z: z,
                mountId: mountId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String entitlementId,
                required String spaceId,
                required double x,
                required double y,
                Value<int> rotation = const Value.absent(),
                Value<int> flipped = const Value.absent(),
                required int z,
                Value<String?> mountId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlacementsCompanion.insert(
                entitlementId: entitlementId,
                spaceId: spaceId,
                x: x,
                y: y,
                rotation: rotation,
                flipped: flipped,
                z: z,
                mountId: mountId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<Placements, Placement>(table),
                  $PlacementsReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({entitlementId = false, spaceId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (entitlementId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.entitlementId,
                        referencedTable: $PlacementsReferences
                            ._entitlementIdTable(db),
                        referencedColumn: $PlacementsReferences
                            ._entitlementIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (spaceId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.spaceId,
                        referencedTable: $PlacementsReferences._spaceIdTable(
                          db,
                        ),
                        referencedColumn: $PlacementsReferences
                            ._spaceIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $PlacementsProcessedTableManager =
    ProcessedTableManager<
      _$FamilyDatabase,
      Placements,
      Placement,
      $PlacementsFilterComposer,
      $PlacementsOrderingComposer,
      $PlacementsAnnotationComposer,
      $PlacementsCreateCompanionBuilder,
      $PlacementsUpdateCompanionBuilder,
      (Placement, $PlacementsReferences),
      Placement,
      PrefetchHooks Function({bool entitlementId, bool spaceId})
    >;
typedef $PetStateCreateCompanionBuilder = PetStateCompanion Function({
  required String petId,
  required String slot,
  required String entitlementId,
  Value<int> rowid,
});
typedef $PetStateUpdateCompanionBuilder = PetStateCompanion Function({
  Value<String> petId,
  Value<String> slot,
  Value<String> entitlementId,
  Value<int> rowid,
});

final class $PetStateReferences
    extends BaseReferences<_$FamilyDatabase, PetState, PetStateData> {
  $PetStateReferences(super.$_db, super.$_table, super.$_typedResult);

  static Entitlements _entitlementIdTable(_$FamilyDatabase db) => db
      .entitlements
      .createAlias('pet_state__entitlement_id__entitlements__id');

  $EntitlementsProcessedTableManager get entitlementId {
    final $_column = $_itemColumn<String>('entitlement_id')!;

    final manager = $EntitlementsTableManager(
      $_db,
      $_db.entitlements,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_entitlementIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $PetStateFilterComposer extends Composer<_$FamilyDatabase, PetState> {
  $PetStateFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get petId => $composableBuilder(
    column: $table.petId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get slot => $composableBuilder(
    column: $table.slot,
    builder: (column) => ColumnFilters(column),
  );

  $EntitlementsFilterComposer get entitlementId {
    final $EntitlementsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.entitlementId,
      referencedTable: $db.entitlements,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $EntitlementsFilterComposer(
            $db: $db,
            $table: $db.entitlements,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $PetStateOrderingComposer extends Composer<_$FamilyDatabase, PetState> {
  $PetStateOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get petId => $composableBuilder(
    column: $table.petId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get slot => $composableBuilder(
    column: $table.slot,
    builder: (column) => ColumnOrderings(column),
  );

  $EntitlementsOrderingComposer get entitlementId {
    final $EntitlementsOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.entitlementId,
      referencedTable: $db.entitlements,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $EntitlementsOrderingComposer(
            $db: $db,
            $table: $db.entitlements,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $PetStateAnnotationComposer extends Composer<_$FamilyDatabase, PetState> {
  $PetStateAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get petId =>
      $composableBuilder(column: $table.petId, builder: (column) => column);

  GeneratedColumn<String> get slot =>
      $composableBuilder(column: $table.slot, builder: (column) => column);

  $EntitlementsAnnotationComposer get entitlementId {
    final $EntitlementsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.entitlementId,
      referencedTable: $db.entitlements,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $EntitlementsAnnotationComposer(
            $db: $db,
            $table: $db.entitlements,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $PetStateTableManager
    extends
        RootTableManager<
          _$FamilyDatabase,
          PetState,
          PetStateData,
          $PetStateFilterComposer,
          $PetStateOrderingComposer,
          $PetStateAnnotationComposer,
          $PetStateCreateCompanionBuilder,
          $PetStateUpdateCompanionBuilder,
          (PetStateData, $PetStateReferences),
          PetStateData,
          PrefetchHooks Function({bool entitlementId})
        > {
  $PetStateTableManager(_$FamilyDatabase db, PetState table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $PetStateFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $PetStateOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $PetStateAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> petId = const Value.absent(),
                Value<String> slot = const Value.absent(),
                Value<String> entitlementId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PetStateCompanion(
                petId: petId,
                slot: slot,
                entitlementId: entitlementId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String petId,
                required String slot,
                required String entitlementId,
                Value<int> rowid = const Value.absent(),
              }) => PetStateCompanion.insert(
                petId: petId,
                slot: slot,
                entitlementId: entitlementId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<PetState, PetStateData>(table),
                  $PetStateReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({entitlementId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (entitlementId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.entitlementId,
                        referencedTable: $PetStateReferences
                            ._entitlementIdTable(db),
                        referencedColumn: $PetStateReferences
                            ._entitlementIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $PetStateProcessedTableManager =
    ProcessedTableManager<
      _$FamilyDatabase,
      PetState,
      PetStateData,
      $PetStateFilterComposer,
      $PetStateOrderingComposer,
      $PetStateAnnotationComposer,
      $PetStateCreateCompanionBuilder,
      $PetStateUpdateCompanionBuilder,
      (PetStateData, $PetStateReferences),
      PetStateData,
      PrefetchHooks Function({bool entitlementId})
    >;
typedef $GrowthAwardsCreateCompanionBuilder = GrowthAwardsCompanion Function({
  required String childId,
  required int threshold,
  required int stage,
  required int awardedAt,
  Value<int> rowid,
});
typedef $GrowthAwardsUpdateCompanionBuilder = GrowthAwardsCompanion Function({
  Value<String> childId,
  Value<int> threshold,
  Value<int> stage,
  Value<int> awardedAt,
  Value<int> rowid,
});

final class $GrowthAwardsReferences
    extends BaseReferences<_$FamilyDatabase, GrowthAwards, GrowthAward> {
  $GrowthAwardsReferences(super.$_db, super.$_table, super.$_typedResult);

  static ChildProfiles _childIdTable(_$FamilyDatabase db) => db.childProfiles
      .createAlias('growth_awards__child_id__child_profiles__id');

  $ChildProfilesProcessedTableManager get childId {
    final $_column = $_itemColumn<String>('child_id')!;

    final manager = $ChildProfilesTableManager(
      $_db,
      $_db.childProfiles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_childIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $GrowthAwardsFilterComposer
    extends Composer<_$FamilyDatabase, GrowthAwards> {
  $GrowthAwardsFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get threshold => $composableBuilder(
    column: $table.threshold,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get stage => $composableBuilder(
    column: $table.stage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get awardedAt => $composableBuilder(
    column: $table.awardedAt,
    builder: (column) => ColumnFilters(column),
  );

  $ChildProfilesFilterComposer get childId {
    final $ChildProfilesFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.childId,
      referencedTable: $db.childProfiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ChildProfilesFilterComposer(
            $db: $db,
            $table: $db.childProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $GrowthAwardsOrderingComposer
    extends Composer<_$FamilyDatabase, GrowthAwards> {
  $GrowthAwardsOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get threshold => $composableBuilder(
    column: $table.threshold,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get stage => $composableBuilder(
    column: $table.stage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get awardedAt => $composableBuilder(
    column: $table.awardedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $ChildProfilesOrderingComposer get childId {
    final $ChildProfilesOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.childId,
      referencedTable: $db.childProfiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ChildProfilesOrderingComposer(
            $db: $db,
            $table: $db.childProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $GrowthAwardsAnnotationComposer
    extends Composer<_$FamilyDatabase, GrowthAwards> {
  $GrowthAwardsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get threshold =>
      $composableBuilder(column: $table.threshold, builder: (column) => column);

  GeneratedColumn<int> get stage =>
      $composableBuilder(column: $table.stage, builder: (column) => column);

  GeneratedColumn<int> get awardedAt =>
      $composableBuilder(column: $table.awardedAt, builder: (column) => column);

  $ChildProfilesAnnotationComposer get childId {
    final $ChildProfilesAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.childId,
      referencedTable: $db.childProfiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ChildProfilesAnnotationComposer(
            $db: $db,
            $table: $db.childProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $GrowthAwardsTableManager
    extends
        RootTableManager<
          _$FamilyDatabase,
          GrowthAwards,
          GrowthAward,
          $GrowthAwardsFilterComposer,
          $GrowthAwardsOrderingComposer,
          $GrowthAwardsAnnotationComposer,
          $GrowthAwardsCreateCompanionBuilder,
          $GrowthAwardsUpdateCompanionBuilder,
          (GrowthAward, $GrowthAwardsReferences),
          GrowthAward,
          PrefetchHooks Function({bool childId})
        > {
  $GrowthAwardsTableManager(_$FamilyDatabase db, GrowthAwards table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $GrowthAwardsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $GrowthAwardsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $GrowthAwardsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> childId = const Value.absent(),
                Value<int> threshold = const Value.absent(),
                Value<int> stage = const Value.absent(),
                Value<int> awardedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GrowthAwardsCompanion(
                childId: childId,
                threshold: threshold,
                stage: stage,
                awardedAt: awardedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String childId,
                required int threshold,
                required int stage,
                required int awardedAt,
                Value<int> rowid = const Value.absent(),
              }) => GrowthAwardsCompanion.insert(
                childId: childId,
                threshold: threshold,
                stage: stage,
                awardedAt: awardedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<GrowthAwards, GrowthAward>(table),
                  $GrowthAwardsReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({childId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (childId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.childId,
                        referencedTable: $GrowthAwardsReferences._childIdTable(
                          db,
                        ),
                        referencedColumn: $GrowthAwardsReferences
                            ._childIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $GrowthAwardsProcessedTableManager =
    ProcessedTableManager<
      _$FamilyDatabase,
      GrowthAwards,
      GrowthAward,
      $GrowthAwardsFilterComposer,
      $GrowthAwardsOrderingComposer,
      $GrowthAwardsAnnotationComposer,
      $GrowthAwardsCreateCompanionBuilder,
      $GrowthAwardsUpdateCompanionBuilder,
      (GrowthAward, $GrowthAwardsReferences),
      GrowthAward,
      PrefetchHooks Function({bool childId})
    >;
typedef $WishesCreateCompanionBuilder = WishesCompanion Function({
  required String childId,
  required String itemId,
  required int selectedPrice,
  required int selectedAt,
  Value<int> rowid,
});
typedef $WishesUpdateCompanionBuilder = WishesCompanion Function({
  Value<String> childId,
  Value<String> itemId,
  Value<int> selectedPrice,
  Value<int> selectedAt,
  Value<int> rowid,
});

final class $WishesReferences
    extends BaseReferences<_$FamilyDatabase, Wishes, Wishe> {
  $WishesReferences(super.$_db, super.$_table, super.$_typedResult);

  static ChildProfiles _childIdTable(_$FamilyDatabase db) =>
      db.childProfiles.createAlias('wishes__child_id__child_profiles__id');

  $ChildProfilesProcessedTableManager get childId {
    final $_column = $_itemColumn<String>('child_id')!;

    final manager = $ChildProfilesTableManager(
      $_db,
      $_db.childProfiles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_childIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $WishesFilterComposer extends Composer<_$FamilyDatabase, Wishes> {
  $WishesFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get selectedPrice => $composableBuilder(
    column: $table.selectedPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get selectedAt => $composableBuilder(
    column: $table.selectedAt,
    builder: (column) => ColumnFilters(column),
  );

  $ChildProfilesFilterComposer get childId {
    final $ChildProfilesFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.childId,
      referencedTable: $db.childProfiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ChildProfilesFilterComposer(
            $db: $db,
            $table: $db.childProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $WishesOrderingComposer extends Composer<_$FamilyDatabase, Wishes> {
  $WishesOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get selectedPrice => $composableBuilder(
    column: $table.selectedPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get selectedAt => $composableBuilder(
    column: $table.selectedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $ChildProfilesOrderingComposer get childId {
    final $ChildProfilesOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.childId,
      referencedTable: $db.childProfiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ChildProfilesOrderingComposer(
            $db: $db,
            $table: $db.childProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $WishesAnnotationComposer extends Composer<_$FamilyDatabase, Wishes> {
  $WishesAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);

  GeneratedColumn<int> get selectedPrice => $composableBuilder(
    column: $table.selectedPrice,
    builder: (column) => column,
  );

  GeneratedColumn<int> get selectedAt => $composableBuilder(
    column: $table.selectedAt,
    builder: (column) => column,
  );

  $ChildProfilesAnnotationComposer get childId {
    final $ChildProfilesAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.childId,
      referencedTable: $db.childProfiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ChildProfilesAnnotationComposer(
            $db: $db,
            $table: $db.childProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $WishesTableManager
    extends
        RootTableManager<
          _$FamilyDatabase,
          Wishes,
          Wishe,
          $WishesFilterComposer,
          $WishesOrderingComposer,
          $WishesAnnotationComposer,
          $WishesCreateCompanionBuilder,
          $WishesUpdateCompanionBuilder,
          (Wishe, $WishesReferences),
          Wishe,
          PrefetchHooks Function({bool childId})
        > {
  $WishesTableManager(_$FamilyDatabase db, Wishes table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $WishesFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $WishesOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $WishesAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> childId = const Value.absent(),
                Value<String> itemId = const Value.absent(),
                Value<int> selectedPrice = const Value.absent(),
                Value<int> selectedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WishesCompanion(
                childId: childId,
                itemId: itemId,
                selectedPrice: selectedPrice,
                selectedAt: selectedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String childId,
                required String itemId,
                required int selectedPrice,
                required int selectedAt,
                Value<int> rowid = const Value.absent(),
              }) => WishesCompanion.insert(
                childId: childId,
                itemId: itemId,
                selectedPrice: selectedPrice,
                selectedAt: selectedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<Wishes, Wishe>(table),
                  $WishesReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({childId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (childId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.childId,
                        referencedTable: $WishesReferences._childIdTable(db),
                        referencedColumn: $WishesReferences
                            ._childIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $WishesProcessedTableManager =
    ProcessedTableManager<
      _$FamilyDatabase,
      Wishes,
      Wishe,
      $WishesFilterComposer,
      $WishesOrderingComposer,
      $WishesAnnotationComposer,
      $WishesCreateCompanionBuilder,
      $WishesUpdateCompanionBuilder,
      (Wishe, $WishesReferences),
      Wishe,
      PrefetchHooks Function({bool childId})
    >;
typedef $CorrectionRecordsCreateCompanionBuilder =
    CorrectionRecordsCompanion Function({
      required String instanceId,
      required String originalRewardId,
      required int recovered,
      required int shortfall,
      required String reason,
      required String refundedPurchaseIds,
      required String commandId,
      Value<int> rowid,
    });
typedef $CorrectionRecordsUpdateCompanionBuilder =
    CorrectionRecordsCompanion Function({
      Value<String> instanceId,
      Value<String> originalRewardId,
      Value<int> recovered,
      Value<int> shortfall,
      Value<String> reason,
      Value<String> refundedPurchaseIds,
      Value<String> commandId,
      Value<int> rowid,
    });

final class $CorrectionRecordsReferences
    extends
        BaseReferences<_$FamilyDatabase, CorrectionRecords, CorrectionRecord> {
  $CorrectionRecordsReferences(super.$_db, super.$_table, super.$_typedResult);

  static TaskInstances _instanceIdTable(_$FamilyDatabase db) => db.taskInstances
      .createAlias('correction_records__instance_id__task_instances__id');

  $TaskInstancesProcessedTableManager get instanceId {
    final $_column = $_itemColumn<String>('instance_id')!;

    final manager = $TaskInstancesTableManager(
      $_db,
      $_db.taskInstances,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_instanceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static LedgerEntries _originalRewardIdTable(_$FamilyDatabase db) =>
      db.ledgerEntries.createAlias(
        'correction_records__original_reward_id__ledger_entries__id',
      );

  $LedgerEntriesProcessedTableManager get originalRewardId {
    final $_column = $_itemColumn<String>('original_reward_id')!;

    final manager = $LedgerEntriesTableManager(
      $_db,
      $_db.ledgerEntries,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_originalRewardIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $CorrectionRecordsFilterComposer
    extends Composer<_$FamilyDatabase, CorrectionRecords> {
  $CorrectionRecordsFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get recovered => $composableBuilder(
    column: $table.recovered,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get shortfall => $composableBuilder(
    column: $table.shortfall,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get refundedPurchaseIds => $composableBuilder(
    column: $table.refundedPurchaseIds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get commandId => $composableBuilder(
    column: $table.commandId,
    builder: (column) => ColumnFilters(column),
  );

  $TaskInstancesFilterComposer get instanceId {
    final $TaskInstancesFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.instanceId,
      referencedTable: $db.taskInstances,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $TaskInstancesFilterComposer(
            $db: $db,
            $table: $db.taskInstances,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $LedgerEntriesFilterComposer get originalRewardId {
    final $LedgerEntriesFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.originalRewardId,
      referencedTable: $db.ledgerEntries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $LedgerEntriesFilterComposer(
            $db: $db,
            $table: $db.ledgerEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $CorrectionRecordsOrderingComposer
    extends Composer<_$FamilyDatabase, CorrectionRecords> {
  $CorrectionRecordsOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get recovered => $composableBuilder(
    column: $table.recovered,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get shortfall => $composableBuilder(
    column: $table.shortfall,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get refundedPurchaseIds => $composableBuilder(
    column: $table.refundedPurchaseIds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get commandId => $composableBuilder(
    column: $table.commandId,
    builder: (column) => ColumnOrderings(column),
  );

  $TaskInstancesOrderingComposer get instanceId {
    final $TaskInstancesOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.instanceId,
      referencedTable: $db.taskInstances,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $TaskInstancesOrderingComposer(
            $db: $db,
            $table: $db.taskInstances,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $LedgerEntriesOrderingComposer get originalRewardId {
    final $LedgerEntriesOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.originalRewardId,
      referencedTable: $db.ledgerEntries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $LedgerEntriesOrderingComposer(
            $db: $db,
            $table: $db.ledgerEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $CorrectionRecordsAnnotationComposer
    extends Composer<_$FamilyDatabase, CorrectionRecords> {
  $CorrectionRecordsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get recovered =>
      $composableBuilder(column: $table.recovered, builder: (column) => column);

  GeneratedColumn<int> get shortfall =>
      $composableBuilder(column: $table.shortfall, builder: (column) => column);

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<String> get refundedPurchaseIds => $composableBuilder(
    column: $table.refundedPurchaseIds,
    builder: (column) => column,
  );

  GeneratedColumn<String> get commandId =>
      $composableBuilder(column: $table.commandId, builder: (column) => column);

  $TaskInstancesAnnotationComposer get instanceId {
    final $TaskInstancesAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.instanceId,
      referencedTable: $db.taskInstances,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $TaskInstancesAnnotationComposer(
            $db: $db,
            $table: $db.taskInstances,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $LedgerEntriesAnnotationComposer get originalRewardId {
    final $LedgerEntriesAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.originalRewardId,
      referencedTable: $db.ledgerEntries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $LedgerEntriesAnnotationComposer(
            $db: $db,
            $table: $db.ledgerEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $CorrectionRecordsTableManager
    extends
        RootTableManager<
          _$FamilyDatabase,
          CorrectionRecords,
          CorrectionRecord,
          $CorrectionRecordsFilterComposer,
          $CorrectionRecordsOrderingComposer,
          $CorrectionRecordsAnnotationComposer,
          $CorrectionRecordsCreateCompanionBuilder,
          $CorrectionRecordsUpdateCompanionBuilder,
          (CorrectionRecord, $CorrectionRecordsReferences),
          CorrectionRecord,
          PrefetchHooks Function({bool instanceId, bool originalRewardId})
        > {
  $CorrectionRecordsTableManager(_$FamilyDatabase db, CorrectionRecords table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $CorrectionRecordsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $CorrectionRecordsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $CorrectionRecordsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> instanceId = const Value.absent(),
                Value<String> originalRewardId = const Value.absent(),
                Value<int> recovered = const Value.absent(),
                Value<int> shortfall = const Value.absent(),
                Value<String> reason = const Value.absent(),
                Value<String> refundedPurchaseIds = const Value.absent(),
                Value<String> commandId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CorrectionRecordsCompanion(
                instanceId: instanceId,
                originalRewardId: originalRewardId,
                recovered: recovered,
                shortfall: shortfall,
                reason: reason,
                refundedPurchaseIds: refundedPurchaseIds,
                commandId: commandId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String instanceId,
                required String originalRewardId,
                required int recovered,
                required int shortfall,
                required String reason,
                required String refundedPurchaseIds,
                required String commandId,
                Value<int> rowid = const Value.absent(),
              }) => CorrectionRecordsCompanion.insert(
                instanceId: instanceId,
                originalRewardId: originalRewardId,
                recovered: recovered,
                shortfall: shortfall,
                reason: reason,
                refundedPurchaseIds: refundedPurchaseIds,
                commandId: commandId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<CorrectionRecords, CorrectionRecord>(table),
                  $CorrectionRecordsReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({instanceId = false, originalRewardId = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (instanceId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.instanceId,
                            referencedTable: $CorrectionRecordsReferences
                                ._instanceIdTable(db),
                            referencedColumn: $CorrectionRecordsReferences
                                ._instanceIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (originalRewardId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.originalRewardId,
                            referencedTable: $CorrectionRecordsReferences
                                ._originalRewardIdTable(db),
                            referencedColumn: $CorrectionRecordsReferences
                                ._originalRewardIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $CorrectionRecordsProcessedTableManager =
    ProcessedTableManager<
      _$FamilyDatabase,
      CorrectionRecords,
      CorrectionRecord,
      $CorrectionRecordsFilterComposer,
      $CorrectionRecordsOrderingComposer,
      $CorrectionRecordsAnnotationComposer,
      $CorrectionRecordsCreateCompanionBuilder,
      $CorrectionRecordsUpdateCompanionBuilder,
      (CorrectionRecord, $CorrectionRecordsReferences),
      CorrectionRecord,
      PrefetchHooks Function({bool instanceId, bool originalRewardId})
    >;

class $FamilyDatabaseManager {
  final _$FamilyDatabase _db;
  $FamilyDatabaseManager(this._db);
  $HouseholdsTableManager get households =>
      $HouseholdsTableManager(_db, _db.households);
  $ChildProfilesTableManager get childProfiles =>
      $ChildProfilesTableManager(_db, _db.childProfiles);
  $AccountsTableManager get accounts =>
      $AccountsTableManager(_db, _db.accounts);
  $TaskTemplatesTableManager get taskTemplates =>
      $TaskTemplatesTableManager(_db, _db.taskTemplates);
  $TaskVersionsTableManager get taskVersions =>
      $TaskVersionsTableManager(_db, _db.taskVersions);
  $ProjectStagesTableManager get projectStages =>
      $ProjectStagesTableManager(_db, _db.projectStages);
  $TaskInstancesTableManager get taskInstances =>
      $TaskInstancesTableManager(_db, _db.taskInstances);
  $SubmissionsTableManager get submissions =>
      $SubmissionsTableManager(_db, _db.submissions);
  $CompletionsTableManager get completions =>
      $CompletionsTableManager(_db, _db.completions);
  $LedgerEntriesTableManager get ledgerEntries =>
      $LedgerEntriesTableManager(_db, _db.ledgerEntries);
  $ProcessedCommandsTableManager get processedCommands =>
      $ProcessedCommandsTableManager(_db, _db.processedCommands);
  $PenaltyRulesTableManager get penaltyRules =>
      $PenaltyRulesTableManager(_db, _db.penaltyRules);
  $PenaltyEventsTableManager get penaltyEvents =>
      $PenaltyEventsTableManager(_db, _db.penaltyEvents);
  $PenaltyDayUsageTableManager get penaltyDayUsage =>
      $PenaltyDayUsageTableManager(_db, _db.penaltyDayUsage);
  $PurchasesTableManager get purchases =>
      $PurchasesTableManager(_db, _db.purchases);
  $SpacesTableManager get spaces => $SpacesTableManager(_db, _db.spaces);
  $EntitlementsTableManager get entitlements =>
      $EntitlementsTableManager(_db, _db.entitlements);
  $PlacementsTableManager get placements =>
      $PlacementsTableManager(_db, _db.placements);
  $PetStateTableManager get petState =>
      $PetStateTableManager(_db, _db.petState);
  $GrowthAwardsTableManager get growthAwards =>
      $GrowthAwardsTableManager(_db, _db.growthAwards);
  $WishesTableManager get wishes => $WishesTableManager(_db, _db.wishes);
  $CorrectionRecordsTableManager get correctionRecords =>
      $CorrectionRecordsTableManager(_db, _db.correctionRecords);
}
