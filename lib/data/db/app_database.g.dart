// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ProfilesTable extends Profiles
    with TableInfo<$ProfilesTable, ProfilesRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _sexMeta = const VerificationMeta('sex');
  @override
  late final GeneratedColumn<String> sex = GeneratedColumn<String>(
    'sex',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('female'),
  );
  static const VerificationMeta _birthYearMeta = const VerificationMeta(
    'birthYear',
  );
  @override
  late final GeneratedColumn<int> birthYear = GeneratedColumn<int>(
    'birth_year',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1990),
  );
  static const VerificationMeta _heightCmMeta = const VerificationMeta(
    'heightCm',
  );
  @override
  late final GeneratedColumn<double> heightCm = GeneratedColumn<double>(
    'height_cm',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(170),
  );
  static const VerificationMeta _weightKgMeta = const VerificationMeta(
    'weightKg',
  );
  @override
  late final GeneratedColumn<double> weightKg = GeneratedColumn<double>(
    'weight_kg',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(70),
  );
  static const VerificationMeta _targetWeightKgMeta = const VerificationMeta(
    'targetWeightKg',
  );
  @override
  late final GeneratedColumn<double> targetWeightKg = GeneratedColumn<double>(
    'target_weight_kg',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(65),
  );
  static const VerificationMeta _waistCmMeta = const VerificationMeta(
    'waistCm',
  );
  @override
  late final GeneratedColumn<double> waistCm = GeneratedColumn<double>(
    'waist_cm',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _chestCmMeta = const VerificationMeta(
    'chestCm',
  );
  @override
  late final GeneratedColumn<double> chestCm = GeneratedColumn<double>(
    'chest_cm',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hipsCmMeta = const VerificationMeta('hipsCm');
  @override
  late final GeneratedColumn<double> hipsCm = GeneratedColumn<double>(
    'hips_cm',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _trainingMinutesMeta = const VerificationMeta(
    'trainingMinutes',
  );
  @override
  late final GeneratedColumn<int> trainingMinutes = GeneratedColumn<int>(
    'training_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(20),
  );
  static const VerificationMeta _trainingSlotMeta = const VerificationMeta(
    'trainingSlot',
  );
  @override
  late final GeneratedColumn<String> trainingSlot = GeneratedColumn<String>(
    'training_slot',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('evening'),
  );
  static const VerificationMeta _onboardingDoneMeta = const VerificationMeta(
    'onboardingDone',
  );
  @override
  late final GeneratedColumn<bool> onboardingDone = GeneratedColumn<bool>(
    'onboarding_done',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("onboarding_done" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    sex,
    birthYear,
    heightCm,
    weightKg,
    targetWeightKg,
    waistCm,
    chestCm,
    hipsCm,
    trainingMinutes,
    trainingSlot,
    onboardingDone,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProfilesRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    }
    if (data.containsKey('sex')) {
      context.handle(
        _sexMeta,
        sex.isAcceptableOrUnknown(data['sex']!, _sexMeta),
      );
    }
    if (data.containsKey('birth_year')) {
      context.handle(
        _birthYearMeta,
        birthYear.isAcceptableOrUnknown(data['birth_year']!, _birthYearMeta),
      );
    }
    if (data.containsKey('height_cm')) {
      context.handle(
        _heightCmMeta,
        heightCm.isAcceptableOrUnknown(data['height_cm']!, _heightCmMeta),
      );
    }
    if (data.containsKey('weight_kg')) {
      context.handle(
        _weightKgMeta,
        weightKg.isAcceptableOrUnknown(data['weight_kg']!, _weightKgMeta),
      );
    }
    if (data.containsKey('target_weight_kg')) {
      context.handle(
        _targetWeightKgMeta,
        targetWeightKg.isAcceptableOrUnknown(
          data['target_weight_kg']!,
          _targetWeightKgMeta,
        ),
      );
    }
    if (data.containsKey('waist_cm')) {
      context.handle(
        _waistCmMeta,
        waistCm.isAcceptableOrUnknown(data['waist_cm']!, _waistCmMeta),
      );
    }
    if (data.containsKey('chest_cm')) {
      context.handle(
        _chestCmMeta,
        chestCm.isAcceptableOrUnknown(data['chest_cm']!, _chestCmMeta),
      );
    }
    if (data.containsKey('hips_cm')) {
      context.handle(
        _hipsCmMeta,
        hipsCm.isAcceptableOrUnknown(data['hips_cm']!, _hipsCmMeta),
      );
    }
    if (data.containsKey('training_minutes')) {
      context.handle(
        _trainingMinutesMeta,
        trainingMinutes.isAcceptableOrUnknown(
          data['training_minutes']!,
          _trainingMinutesMeta,
        ),
      );
    }
    if (data.containsKey('training_slot')) {
      context.handle(
        _trainingSlotMeta,
        trainingSlot.isAcceptableOrUnknown(
          data['training_slot']!,
          _trainingSlotMeta,
        ),
      );
    }
    if (data.containsKey('onboarding_done')) {
      context.handle(
        _onboardingDoneMeta,
        onboardingDone.isAcceptableOrUnknown(
          data['onboarding_done']!,
          _onboardingDoneMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProfilesRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProfilesRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      sex: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sex'],
      )!,
      birthYear: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}birth_year'],
      )!,
      heightCm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}height_cm'],
      )!,
      weightKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight_kg'],
      )!,
      targetWeightKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}target_weight_kg'],
      )!,
      waistCm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}waist_cm'],
      ),
      chestCm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}chest_cm'],
      ),
      hipsCm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}hips_cm'],
      ),
      trainingMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}training_minutes'],
      )!,
      trainingSlot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}training_slot'],
      )!,
      onboardingDone: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}onboarding_done'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ProfilesTable createAlias(String alias) {
    return $ProfilesTable(attachedDatabase, alias);
  }
}

class ProfilesRow extends DataClass implements Insertable<ProfilesRow> {
  final int id;
  final String name;

  /// 'female' | 'male'
  final String sex;
  final int birthYear;
  final double heightCm;
  final double weightKg;
  final double targetWeightKg;
  final double? waistCm;
  final double? chestCm;
  final double? hipsCm;

  /// Сколько минут в день человек готов отдавать тренировкам.
  final int trainingMinutes;

  /// 'morning' | 'day' | 'evening'
  final String trainingSlot;
  final bool onboardingDone;
  final DateTime createdAt;
  final DateTime updatedAt;
  const ProfilesRow({
    required this.id,
    required this.name,
    required this.sex,
    required this.birthYear,
    required this.heightCm,
    required this.weightKg,
    required this.targetWeightKg,
    this.waistCm,
    this.chestCm,
    this.hipsCm,
    required this.trainingMinutes,
    required this.trainingSlot,
    required this.onboardingDone,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['sex'] = Variable<String>(sex);
    map['birth_year'] = Variable<int>(birthYear);
    map['height_cm'] = Variable<double>(heightCm);
    map['weight_kg'] = Variable<double>(weightKg);
    map['target_weight_kg'] = Variable<double>(targetWeightKg);
    if (!nullToAbsent || waistCm != null) {
      map['waist_cm'] = Variable<double>(waistCm);
    }
    if (!nullToAbsent || chestCm != null) {
      map['chest_cm'] = Variable<double>(chestCm);
    }
    if (!nullToAbsent || hipsCm != null) {
      map['hips_cm'] = Variable<double>(hipsCm);
    }
    map['training_minutes'] = Variable<int>(trainingMinutes);
    map['training_slot'] = Variable<String>(trainingSlot);
    map['onboarding_done'] = Variable<bool>(onboardingDone);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ProfilesCompanion toCompanion(bool nullToAbsent) {
    return ProfilesCompanion(
      id: Value(id),
      name: Value(name),
      sex: Value(sex),
      birthYear: Value(birthYear),
      heightCm: Value(heightCm),
      weightKg: Value(weightKg),
      targetWeightKg: Value(targetWeightKg),
      waistCm: waistCm == null && nullToAbsent
          ? const Value.absent()
          : Value(waistCm),
      chestCm: chestCm == null && nullToAbsent
          ? const Value.absent()
          : Value(chestCm),
      hipsCm: hipsCm == null && nullToAbsent
          ? const Value.absent()
          : Value(hipsCm),
      trainingMinutes: Value(trainingMinutes),
      trainingSlot: Value(trainingSlot),
      onboardingDone: Value(onboardingDone),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory ProfilesRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProfilesRow(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      sex: serializer.fromJson<String>(json['sex']),
      birthYear: serializer.fromJson<int>(json['birthYear']),
      heightCm: serializer.fromJson<double>(json['heightCm']),
      weightKg: serializer.fromJson<double>(json['weightKg']),
      targetWeightKg: serializer.fromJson<double>(json['targetWeightKg']),
      waistCm: serializer.fromJson<double?>(json['waistCm']),
      chestCm: serializer.fromJson<double?>(json['chestCm']),
      hipsCm: serializer.fromJson<double?>(json['hipsCm']),
      trainingMinutes: serializer.fromJson<int>(json['trainingMinutes']),
      trainingSlot: serializer.fromJson<String>(json['trainingSlot']),
      onboardingDone: serializer.fromJson<bool>(json['onboardingDone']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'sex': serializer.toJson<String>(sex),
      'birthYear': serializer.toJson<int>(birthYear),
      'heightCm': serializer.toJson<double>(heightCm),
      'weightKg': serializer.toJson<double>(weightKg),
      'targetWeightKg': serializer.toJson<double>(targetWeightKg),
      'waistCm': serializer.toJson<double?>(waistCm),
      'chestCm': serializer.toJson<double?>(chestCm),
      'hipsCm': serializer.toJson<double?>(hipsCm),
      'trainingMinutes': serializer.toJson<int>(trainingMinutes),
      'trainingSlot': serializer.toJson<String>(trainingSlot),
      'onboardingDone': serializer.toJson<bool>(onboardingDone),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ProfilesRow copyWith({
    int? id,
    String? name,
    String? sex,
    int? birthYear,
    double? heightCm,
    double? weightKg,
    double? targetWeightKg,
    Value<double?> waistCm = const Value.absent(),
    Value<double?> chestCm = const Value.absent(),
    Value<double?> hipsCm = const Value.absent(),
    int? trainingMinutes,
    String? trainingSlot,
    bool? onboardingDone,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => ProfilesRow(
    id: id ?? this.id,
    name: name ?? this.name,
    sex: sex ?? this.sex,
    birthYear: birthYear ?? this.birthYear,
    heightCm: heightCm ?? this.heightCm,
    weightKg: weightKg ?? this.weightKg,
    targetWeightKg: targetWeightKg ?? this.targetWeightKg,
    waistCm: waistCm.present ? waistCm.value : this.waistCm,
    chestCm: chestCm.present ? chestCm.value : this.chestCm,
    hipsCm: hipsCm.present ? hipsCm.value : this.hipsCm,
    trainingMinutes: trainingMinutes ?? this.trainingMinutes,
    trainingSlot: trainingSlot ?? this.trainingSlot,
    onboardingDone: onboardingDone ?? this.onboardingDone,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ProfilesRow copyWithCompanion(ProfilesCompanion data) {
    return ProfilesRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      sex: data.sex.present ? data.sex.value : this.sex,
      birthYear: data.birthYear.present ? data.birthYear.value : this.birthYear,
      heightCm: data.heightCm.present ? data.heightCm.value : this.heightCm,
      weightKg: data.weightKg.present ? data.weightKg.value : this.weightKg,
      targetWeightKg: data.targetWeightKg.present
          ? data.targetWeightKg.value
          : this.targetWeightKg,
      waistCm: data.waistCm.present ? data.waistCm.value : this.waistCm,
      chestCm: data.chestCm.present ? data.chestCm.value : this.chestCm,
      hipsCm: data.hipsCm.present ? data.hipsCm.value : this.hipsCm,
      trainingMinutes: data.trainingMinutes.present
          ? data.trainingMinutes.value
          : this.trainingMinutes,
      trainingSlot: data.trainingSlot.present
          ? data.trainingSlot.value
          : this.trainingSlot,
      onboardingDone: data.onboardingDone.present
          ? data.onboardingDone.value
          : this.onboardingDone,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProfilesRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('sex: $sex, ')
          ..write('birthYear: $birthYear, ')
          ..write('heightCm: $heightCm, ')
          ..write('weightKg: $weightKg, ')
          ..write('targetWeightKg: $targetWeightKg, ')
          ..write('waistCm: $waistCm, ')
          ..write('chestCm: $chestCm, ')
          ..write('hipsCm: $hipsCm, ')
          ..write('trainingMinutes: $trainingMinutes, ')
          ..write('trainingSlot: $trainingSlot, ')
          ..write('onboardingDone: $onboardingDone, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    sex,
    birthYear,
    heightCm,
    weightKg,
    targetWeightKg,
    waistCm,
    chestCm,
    hipsCm,
    trainingMinutes,
    trainingSlot,
    onboardingDone,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProfilesRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.sex == this.sex &&
          other.birthYear == this.birthYear &&
          other.heightCm == this.heightCm &&
          other.weightKg == this.weightKg &&
          other.targetWeightKg == this.targetWeightKg &&
          other.waistCm == this.waistCm &&
          other.chestCm == this.chestCm &&
          other.hipsCm == this.hipsCm &&
          other.trainingMinutes == this.trainingMinutes &&
          other.trainingSlot == this.trainingSlot &&
          other.onboardingDone == this.onboardingDone &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ProfilesCompanion extends UpdateCompanion<ProfilesRow> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> sex;
  final Value<int> birthYear;
  final Value<double> heightCm;
  final Value<double> weightKg;
  final Value<double> targetWeightKg;
  final Value<double?> waistCm;
  final Value<double?> chestCm;
  final Value<double?> hipsCm;
  final Value<int> trainingMinutes;
  final Value<String> trainingSlot;
  final Value<bool> onboardingDone;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const ProfilesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.sex = const Value.absent(),
    this.birthYear = const Value.absent(),
    this.heightCm = const Value.absent(),
    this.weightKg = const Value.absent(),
    this.targetWeightKg = const Value.absent(),
    this.waistCm = const Value.absent(),
    this.chestCm = const Value.absent(),
    this.hipsCm = const Value.absent(),
    this.trainingMinutes = const Value.absent(),
    this.trainingSlot = const Value.absent(),
    this.onboardingDone = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  ProfilesCompanion.insert({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.sex = const Value.absent(),
    this.birthYear = const Value.absent(),
    this.heightCm = const Value.absent(),
    this.weightKg = const Value.absent(),
    this.targetWeightKg = const Value.absent(),
    this.waistCm = const Value.absent(),
    this.chestCm = const Value.absent(),
    this.hipsCm = const Value.absent(),
    this.trainingMinutes = const Value.absent(),
    this.trainingSlot = const Value.absent(),
    this.onboardingDone = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<ProfilesRow> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? sex,
    Expression<int>? birthYear,
    Expression<double>? heightCm,
    Expression<double>? weightKg,
    Expression<double>? targetWeightKg,
    Expression<double>? waistCm,
    Expression<double>? chestCm,
    Expression<double>? hipsCm,
    Expression<int>? trainingMinutes,
    Expression<String>? trainingSlot,
    Expression<bool>? onboardingDone,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (sex != null) 'sex': sex,
      if (birthYear != null) 'birth_year': birthYear,
      if (heightCm != null) 'height_cm': heightCm,
      if (weightKg != null) 'weight_kg': weightKg,
      if (targetWeightKg != null) 'target_weight_kg': targetWeightKg,
      if (waistCm != null) 'waist_cm': waistCm,
      if (chestCm != null) 'chest_cm': chestCm,
      if (hipsCm != null) 'hips_cm': hipsCm,
      if (trainingMinutes != null) 'training_minutes': trainingMinutes,
      if (trainingSlot != null) 'training_slot': trainingSlot,
      if (onboardingDone != null) 'onboarding_done': onboardingDone,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  ProfilesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? sex,
    Value<int>? birthYear,
    Value<double>? heightCm,
    Value<double>? weightKg,
    Value<double>? targetWeightKg,
    Value<double?>? waistCm,
    Value<double?>? chestCm,
    Value<double?>? hipsCm,
    Value<int>? trainingMinutes,
    Value<String>? trainingSlot,
    Value<bool>? onboardingDone,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return ProfilesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      sex: sex ?? this.sex,
      birthYear: birthYear ?? this.birthYear,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      targetWeightKg: targetWeightKg ?? this.targetWeightKg,
      waistCm: waistCm ?? this.waistCm,
      chestCm: chestCm ?? this.chestCm,
      hipsCm: hipsCm ?? this.hipsCm,
      trainingMinutes: trainingMinutes ?? this.trainingMinutes,
      trainingSlot: trainingSlot ?? this.trainingSlot,
      onboardingDone: onboardingDone ?? this.onboardingDone,
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
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (sex.present) {
      map['sex'] = Variable<String>(sex.value);
    }
    if (birthYear.present) {
      map['birth_year'] = Variable<int>(birthYear.value);
    }
    if (heightCm.present) {
      map['height_cm'] = Variable<double>(heightCm.value);
    }
    if (weightKg.present) {
      map['weight_kg'] = Variable<double>(weightKg.value);
    }
    if (targetWeightKg.present) {
      map['target_weight_kg'] = Variable<double>(targetWeightKg.value);
    }
    if (waistCm.present) {
      map['waist_cm'] = Variable<double>(waistCm.value);
    }
    if (chestCm.present) {
      map['chest_cm'] = Variable<double>(chestCm.value);
    }
    if (hipsCm.present) {
      map['hips_cm'] = Variable<double>(hipsCm.value);
    }
    if (trainingMinutes.present) {
      map['training_minutes'] = Variable<int>(trainingMinutes.value);
    }
    if (trainingSlot.present) {
      map['training_slot'] = Variable<String>(trainingSlot.value);
    }
    if (onboardingDone.present) {
      map['onboarding_done'] = Variable<bool>(onboardingDone.value);
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
    return (StringBuffer('ProfilesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('sex: $sex, ')
          ..write('birthYear: $birthYear, ')
          ..write('heightCm: $heightCm, ')
          ..write('weightKg: $weightKg, ')
          ..write('targetWeightKg: $targetWeightKg, ')
          ..write('waistCm: $waistCm, ')
          ..write('chestCm: $chestCm, ')
          ..write('hipsCm: $hipsCm, ')
          ..write('trainingMinutes: $trainingMinutes, ')
          ..write('trainingSlot: $trainingSlot, ')
          ..write('onboardingDone: $onboardingDone, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $ProfileHistoryTable extends ProfileHistory
    with TableInfo<$ProfileHistoryTable, ProfileHistoryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProfileHistoryTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _recordedAtMeta = const VerificationMeta(
    'recordedAt',
  );
  @override
  late final GeneratedColumn<DateTime> recordedAt = GeneratedColumn<DateTime>(
    'recorded_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weightKgMeta = const VerificationMeta(
    'weightKg',
  );
  @override
  late final GeneratedColumn<double> weightKg = GeneratedColumn<double>(
    'weight_kg',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetWeightKgMeta = const VerificationMeta(
    'targetWeightKg',
  );
  @override
  late final GeneratedColumn<double> targetWeightKg = GeneratedColumn<double>(
    'target_weight_kg',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _heightCmMeta = const VerificationMeta(
    'heightCm',
  );
  @override
  late final GeneratedColumn<double> heightCm = GeneratedColumn<double>(
    'height_cm',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _waistCmMeta = const VerificationMeta(
    'waistCm',
  );
  @override
  late final GeneratedColumn<double> waistCm = GeneratedColumn<double>(
    'waist_cm',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _chestCmMeta = const VerificationMeta(
    'chestCm',
  );
  @override
  late final GeneratedColumn<double> chestCm = GeneratedColumn<double>(
    'chest_cm',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hipsCmMeta = const VerificationMeta('hipsCm');
  @override
  late final GeneratedColumn<double> hipsCm = GeneratedColumn<double>(
    'hips_cm',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('settings'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    recordedAt,
    weightKg,
    targetWeightKg,
    heightCm,
    waistCm,
    chestCm,
    hipsCm,
    source,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'profile_history';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProfileHistoryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('recorded_at')) {
      context.handle(
        _recordedAtMeta,
        recordedAt.isAcceptableOrUnknown(data['recorded_at']!, _recordedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_recordedAtMeta);
    }
    if (data.containsKey('weight_kg')) {
      context.handle(
        _weightKgMeta,
        weightKg.isAcceptableOrUnknown(data['weight_kg']!, _weightKgMeta),
      );
    } else if (isInserting) {
      context.missing(_weightKgMeta);
    }
    if (data.containsKey('target_weight_kg')) {
      context.handle(
        _targetWeightKgMeta,
        targetWeightKg.isAcceptableOrUnknown(
          data['target_weight_kg']!,
          _targetWeightKgMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetWeightKgMeta);
    }
    if (data.containsKey('height_cm')) {
      context.handle(
        _heightCmMeta,
        heightCm.isAcceptableOrUnknown(data['height_cm']!, _heightCmMeta),
      );
    } else if (isInserting) {
      context.missing(_heightCmMeta);
    }
    if (data.containsKey('waist_cm')) {
      context.handle(
        _waistCmMeta,
        waistCm.isAcceptableOrUnknown(data['waist_cm']!, _waistCmMeta),
      );
    }
    if (data.containsKey('chest_cm')) {
      context.handle(
        _chestCmMeta,
        chestCm.isAcceptableOrUnknown(data['chest_cm']!, _chestCmMeta),
      );
    }
    if (data.containsKey('hips_cm')) {
      context.handle(
        _hipsCmMeta,
        hipsCm.isAcceptableOrUnknown(data['hips_cm']!, _hipsCmMeta),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProfileHistoryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProfileHistoryRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      recordedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}recorded_at'],
      )!,
      weightKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight_kg'],
      )!,
      targetWeightKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}target_weight_kg'],
      )!,
      heightCm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}height_cm'],
      )!,
      waistCm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}waist_cm'],
      ),
      chestCm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}chest_cm'],
      ),
      hipsCm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}hips_cm'],
      ),
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
    );
  }

  @override
  $ProfileHistoryTable createAlias(String alias) {
    return $ProfileHistoryTable(attachedDatabase, alias);
  }
}

class ProfileHistoryRow extends DataClass
    implements Insertable<ProfileHistoryRow> {
  final int id;
  final DateTime recordedAt;
  final double weightKg;
  final double targetWeightKg;
  final double heightCm;
  final double? waistCm;
  final double? chestCm;
  final double? hipsCm;

  /// 'onboarding' | 'settings' | 'chat' | 'workout'
  final String source;
  const ProfileHistoryRow({
    required this.id,
    required this.recordedAt,
    required this.weightKg,
    required this.targetWeightKg,
    required this.heightCm,
    this.waistCm,
    this.chestCm,
    this.hipsCm,
    required this.source,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['recorded_at'] = Variable<DateTime>(recordedAt);
    map['weight_kg'] = Variable<double>(weightKg);
    map['target_weight_kg'] = Variable<double>(targetWeightKg);
    map['height_cm'] = Variable<double>(heightCm);
    if (!nullToAbsent || waistCm != null) {
      map['waist_cm'] = Variable<double>(waistCm);
    }
    if (!nullToAbsent || chestCm != null) {
      map['chest_cm'] = Variable<double>(chestCm);
    }
    if (!nullToAbsent || hipsCm != null) {
      map['hips_cm'] = Variable<double>(hipsCm);
    }
    map['source'] = Variable<String>(source);
    return map;
  }

  ProfileHistoryCompanion toCompanion(bool nullToAbsent) {
    return ProfileHistoryCompanion(
      id: Value(id),
      recordedAt: Value(recordedAt),
      weightKg: Value(weightKg),
      targetWeightKg: Value(targetWeightKg),
      heightCm: Value(heightCm),
      waistCm: waistCm == null && nullToAbsent
          ? const Value.absent()
          : Value(waistCm),
      chestCm: chestCm == null && nullToAbsent
          ? const Value.absent()
          : Value(chestCm),
      hipsCm: hipsCm == null && nullToAbsent
          ? const Value.absent()
          : Value(hipsCm),
      source: Value(source),
    );
  }

  factory ProfileHistoryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProfileHistoryRow(
      id: serializer.fromJson<int>(json['id']),
      recordedAt: serializer.fromJson<DateTime>(json['recordedAt']),
      weightKg: serializer.fromJson<double>(json['weightKg']),
      targetWeightKg: serializer.fromJson<double>(json['targetWeightKg']),
      heightCm: serializer.fromJson<double>(json['heightCm']),
      waistCm: serializer.fromJson<double?>(json['waistCm']),
      chestCm: serializer.fromJson<double?>(json['chestCm']),
      hipsCm: serializer.fromJson<double?>(json['hipsCm']),
      source: serializer.fromJson<String>(json['source']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'recordedAt': serializer.toJson<DateTime>(recordedAt),
      'weightKg': serializer.toJson<double>(weightKg),
      'targetWeightKg': serializer.toJson<double>(targetWeightKg),
      'heightCm': serializer.toJson<double>(heightCm),
      'waistCm': serializer.toJson<double?>(waistCm),
      'chestCm': serializer.toJson<double?>(chestCm),
      'hipsCm': serializer.toJson<double?>(hipsCm),
      'source': serializer.toJson<String>(source),
    };
  }

  ProfileHistoryRow copyWith({
    int? id,
    DateTime? recordedAt,
    double? weightKg,
    double? targetWeightKg,
    double? heightCm,
    Value<double?> waistCm = const Value.absent(),
    Value<double?> chestCm = const Value.absent(),
    Value<double?> hipsCm = const Value.absent(),
    String? source,
  }) => ProfileHistoryRow(
    id: id ?? this.id,
    recordedAt: recordedAt ?? this.recordedAt,
    weightKg: weightKg ?? this.weightKg,
    targetWeightKg: targetWeightKg ?? this.targetWeightKg,
    heightCm: heightCm ?? this.heightCm,
    waistCm: waistCm.present ? waistCm.value : this.waistCm,
    chestCm: chestCm.present ? chestCm.value : this.chestCm,
    hipsCm: hipsCm.present ? hipsCm.value : this.hipsCm,
    source: source ?? this.source,
  );
  ProfileHistoryRow copyWithCompanion(ProfileHistoryCompanion data) {
    return ProfileHistoryRow(
      id: data.id.present ? data.id.value : this.id,
      recordedAt: data.recordedAt.present
          ? data.recordedAt.value
          : this.recordedAt,
      weightKg: data.weightKg.present ? data.weightKg.value : this.weightKg,
      targetWeightKg: data.targetWeightKg.present
          ? data.targetWeightKg.value
          : this.targetWeightKg,
      heightCm: data.heightCm.present ? data.heightCm.value : this.heightCm,
      waistCm: data.waistCm.present ? data.waistCm.value : this.waistCm,
      chestCm: data.chestCm.present ? data.chestCm.value : this.chestCm,
      hipsCm: data.hipsCm.present ? data.hipsCm.value : this.hipsCm,
      source: data.source.present ? data.source.value : this.source,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProfileHistoryRow(')
          ..write('id: $id, ')
          ..write('recordedAt: $recordedAt, ')
          ..write('weightKg: $weightKg, ')
          ..write('targetWeightKg: $targetWeightKg, ')
          ..write('heightCm: $heightCm, ')
          ..write('waistCm: $waistCm, ')
          ..write('chestCm: $chestCm, ')
          ..write('hipsCm: $hipsCm, ')
          ..write('source: $source')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    recordedAt,
    weightKg,
    targetWeightKg,
    heightCm,
    waistCm,
    chestCm,
    hipsCm,
    source,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProfileHistoryRow &&
          other.id == this.id &&
          other.recordedAt == this.recordedAt &&
          other.weightKg == this.weightKg &&
          other.targetWeightKg == this.targetWeightKg &&
          other.heightCm == this.heightCm &&
          other.waistCm == this.waistCm &&
          other.chestCm == this.chestCm &&
          other.hipsCm == this.hipsCm &&
          other.source == this.source);
}

class ProfileHistoryCompanion extends UpdateCompanion<ProfileHistoryRow> {
  final Value<int> id;
  final Value<DateTime> recordedAt;
  final Value<double> weightKg;
  final Value<double> targetWeightKg;
  final Value<double> heightCm;
  final Value<double?> waistCm;
  final Value<double?> chestCm;
  final Value<double?> hipsCm;
  final Value<String> source;
  const ProfileHistoryCompanion({
    this.id = const Value.absent(),
    this.recordedAt = const Value.absent(),
    this.weightKg = const Value.absent(),
    this.targetWeightKg = const Value.absent(),
    this.heightCm = const Value.absent(),
    this.waistCm = const Value.absent(),
    this.chestCm = const Value.absent(),
    this.hipsCm = const Value.absent(),
    this.source = const Value.absent(),
  });
  ProfileHistoryCompanion.insert({
    this.id = const Value.absent(),
    required DateTime recordedAt,
    required double weightKg,
    required double targetWeightKg,
    required double heightCm,
    this.waistCm = const Value.absent(),
    this.chestCm = const Value.absent(),
    this.hipsCm = const Value.absent(),
    this.source = const Value.absent(),
  }) : recordedAt = Value(recordedAt),
       weightKg = Value(weightKg),
       targetWeightKg = Value(targetWeightKg),
       heightCm = Value(heightCm);
  static Insertable<ProfileHistoryRow> custom({
    Expression<int>? id,
    Expression<DateTime>? recordedAt,
    Expression<double>? weightKg,
    Expression<double>? targetWeightKg,
    Expression<double>? heightCm,
    Expression<double>? waistCm,
    Expression<double>? chestCm,
    Expression<double>? hipsCm,
    Expression<String>? source,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (recordedAt != null) 'recorded_at': recordedAt,
      if (weightKg != null) 'weight_kg': weightKg,
      if (targetWeightKg != null) 'target_weight_kg': targetWeightKg,
      if (heightCm != null) 'height_cm': heightCm,
      if (waistCm != null) 'waist_cm': waistCm,
      if (chestCm != null) 'chest_cm': chestCm,
      if (hipsCm != null) 'hips_cm': hipsCm,
      if (source != null) 'source': source,
    });
  }

  ProfileHistoryCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? recordedAt,
    Value<double>? weightKg,
    Value<double>? targetWeightKg,
    Value<double>? heightCm,
    Value<double?>? waistCm,
    Value<double?>? chestCm,
    Value<double?>? hipsCm,
    Value<String>? source,
  }) {
    return ProfileHistoryCompanion(
      id: id ?? this.id,
      recordedAt: recordedAt ?? this.recordedAt,
      weightKg: weightKg ?? this.weightKg,
      targetWeightKg: targetWeightKg ?? this.targetWeightKg,
      heightCm: heightCm ?? this.heightCm,
      waistCm: waistCm ?? this.waistCm,
      chestCm: chestCm ?? this.chestCm,
      hipsCm: hipsCm ?? this.hipsCm,
      source: source ?? this.source,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (recordedAt.present) {
      map['recorded_at'] = Variable<DateTime>(recordedAt.value);
    }
    if (weightKg.present) {
      map['weight_kg'] = Variable<double>(weightKg.value);
    }
    if (targetWeightKg.present) {
      map['target_weight_kg'] = Variable<double>(targetWeightKg.value);
    }
    if (heightCm.present) {
      map['height_cm'] = Variable<double>(heightCm.value);
    }
    if (waistCm.present) {
      map['waist_cm'] = Variable<double>(waistCm.value);
    }
    if (chestCm.present) {
      map['chest_cm'] = Variable<double>(chestCm.value);
    }
    if (hipsCm.present) {
      map['hips_cm'] = Variable<double>(hipsCm.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProfileHistoryCompanion(')
          ..write('id: $id, ')
          ..write('recordedAt: $recordedAt, ')
          ..write('weightKg: $weightKg, ')
          ..write('targetWeightKg: $targetWeightKg, ')
          ..write('heightCm: $heightCm, ')
          ..write('waistCm: $waistCm, ')
          ..write('chestCm: $chestCm, ')
          ..write('hipsCm: $hipsCm, ')
          ..write('source: $source')
          ..write(')'))
        .toString();
  }
}

class $GoalsTable extends Goals with TableInfo<$GoalsTable, GoalsRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GoalsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _startWeightKgMeta = const VerificationMeta(
    'startWeightKg',
  );
  @override
  late final GeneratedColumn<double> startWeightKg = GeneratedColumn<double>(
    'start_weight_kg',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetWeightKgMeta = const VerificationMeta(
    'targetWeightKg',
  );
  @override
  late final GeneratedColumn<double> targetWeightKg = GeneratedColumn<double>(
    'target_weight_kg',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
    'start_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetDateMeta = const VerificationMeta(
    'targetDate',
  );
  @override
  late final GeneratedColumn<DateTime> targetDate = GeneratedColumn<DateTime>(
    'target_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weeksMeta = const VerificationMeta('weeks');
  @override
  late final GeneratedColumn<int> weeks = GeneratedColumn<int>(
    'weeks',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('active'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    startWeightKg,
    targetWeightKg,
    startDate,
    targetDate,
    weeks,
    status,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'goals';
  @override
  VerificationContext validateIntegrity(
    Insertable<GoalsRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('start_weight_kg')) {
      context.handle(
        _startWeightKgMeta,
        startWeightKg.isAcceptableOrUnknown(
          data['start_weight_kg']!,
          _startWeightKgMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_startWeightKgMeta);
    }
    if (data.containsKey('target_weight_kg')) {
      context.handle(
        _targetWeightKgMeta,
        targetWeightKg.isAcceptableOrUnknown(
          data['target_weight_kg']!,
          _targetWeightKgMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetWeightKgMeta);
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('target_date')) {
      context.handle(
        _targetDateMeta,
        targetDate.isAcceptableOrUnknown(data['target_date']!, _targetDateMeta),
      );
    } else if (isInserting) {
      context.missing(_targetDateMeta);
    }
    if (data.containsKey('weeks')) {
      context.handle(
        _weeksMeta,
        weeks.isAcceptableOrUnknown(data['weeks']!, _weeksMeta),
      );
    } else if (isInserting) {
      context.missing(_weeksMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
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
  GoalsRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GoalsRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      startWeightKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}start_weight_kg'],
      )!,
      targetWeightKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}target_weight_kg'],
      )!,
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_date'],
      )!,
      targetDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}target_date'],
      )!,
      weeks: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}weeks'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $GoalsTable createAlias(String alias) {
    return $GoalsTable(attachedDatabase, alias);
  }
}

class GoalsRow extends DataClass implements Insertable<GoalsRow> {
  final int id;
  final double startWeightKg;
  final double targetWeightKg;
  final DateTime startDate;
  final DateTime targetDate;
  final int weeks;

  /// 'active' | 'archived'
  final String status;
  final DateTime createdAt;
  const GoalsRow({
    required this.id,
    required this.startWeightKg,
    required this.targetWeightKg,
    required this.startDate,
    required this.targetDate,
    required this.weeks,
    required this.status,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['start_weight_kg'] = Variable<double>(startWeightKg);
    map['target_weight_kg'] = Variable<double>(targetWeightKg);
    map['start_date'] = Variable<DateTime>(startDate);
    map['target_date'] = Variable<DateTime>(targetDate);
    map['weeks'] = Variable<int>(weeks);
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  GoalsCompanion toCompanion(bool nullToAbsent) {
    return GoalsCompanion(
      id: Value(id),
      startWeightKg: Value(startWeightKg),
      targetWeightKg: Value(targetWeightKg),
      startDate: Value(startDate),
      targetDate: Value(targetDate),
      weeks: Value(weeks),
      status: Value(status),
      createdAt: Value(createdAt),
    );
  }

  factory GoalsRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GoalsRow(
      id: serializer.fromJson<int>(json['id']),
      startWeightKg: serializer.fromJson<double>(json['startWeightKg']),
      targetWeightKg: serializer.fromJson<double>(json['targetWeightKg']),
      startDate: serializer.fromJson<DateTime>(json['startDate']),
      targetDate: serializer.fromJson<DateTime>(json['targetDate']),
      weeks: serializer.fromJson<int>(json['weeks']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'startWeightKg': serializer.toJson<double>(startWeightKg),
      'targetWeightKg': serializer.toJson<double>(targetWeightKg),
      'startDate': serializer.toJson<DateTime>(startDate),
      'targetDate': serializer.toJson<DateTime>(targetDate),
      'weeks': serializer.toJson<int>(weeks),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  GoalsRow copyWith({
    int? id,
    double? startWeightKg,
    double? targetWeightKg,
    DateTime? startDate,
    DateTime? targetDate,
    int? weeks,
    String? status,
    DateTime? createdAt,
  }) => GoalsRow(
    id: id ?? this.id,
    startWeightKg: startWeightKg ?? this.startWeightKg,
    targetWeightKg: targetWeightKg ?? this.targetWeightKg,
    startDate: startDate ?? this.startDate,
    targetDate: targetDate ?? this.targetDate,
    weeks: weeks ?? this.weeks,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
  );
  GoalsRow copyWithCompanion(GoalsCompanion data) {
    return GoalsRow(
      id: data.id.present ? data.id.value : this.id,
      startWeightKg: data.startWeightKg.present
          ? data.startWeightKg.value
          : this.startWeightKg,
      targetWeightKg: data.targetWeightKg.present
          ? data.targetWeightKg.value
          : this.targetWeightKg,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      targetDate: data.targetDate.present
          ? data.targetDate.value
          : this.targetDate,
      weeks: data.weeks.present ? data.weeks.value : this.weeks,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GoalsRow(')
          ..write('id: $id, ')
          ..write('startWeightKg: $startWeightKg, ')
          ..write('targetWeightKg: $targetWeightKg, ')
          ..write('startDate: $startDate, ')
          ..write('targetDate: $targetDate, ')
          ..write('weeks: $weeks, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    startWeightKg,
    targetWeightKg,
    startDate,
    targetDate,
    weeks,
    status,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GoalsRow &&
          other.id == this.id &&
          other.startWeightKg == this.startWeightKg &&
          other.targetWeightKg == this.targetWeightKg &&
          other.startDate == this.startDate &&
          other.targetDate == this.targetDate &&
          other.weeks == this.weeks &&
          other.status == this.status &&
          other.createdAt == this.createdAt);
}

class GoalsCompanion extends UpdateCompanion<GoalsRow> {
  final Value<int> id;
  final Value<double> startWeightKg;
  final Value<double> targetWeightKg;
  final Value<DateTime> startDate;
  final Value<DateTime> targetDate;
  final Value<int> weeks;
  final Value<String> status;
  final Value<DateTime> createdAt;
  const GoalsCompanion({
    this.id = const Value.absent(),
    this.startWeightKg = const Value.absent(),
    this.targetWeightKg = const Value.absent(),
    this.startDate = const Value.absent(),
    this.targetDate = const Value.absent(),
    this.weeks = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  GoalsCompanion.insert({
    this.id = const Value.absent(),
    required double startWeightKg,
    required double targetWeightKg,
    required DateTime startDate,
    required DateTime targetDate,
    required int weeks,
    this.status = const Value.absent(),
    required DateTime createdAt,
  }) : startWeightKg = Value(startWeightKg),
       targetWeightKg = Value(targetWeightKg),
       startDate = Value(startDate),
       targetDate = Value(targetDate),
       weeks = Value(weeks),
       createdAt = Value(createdAt);
  static Insertable<GoalsRow> custom({
    Expression<int>? id,
    Expression<double>? startWeightKg,
    Expression<double>? targetWeightKg,
    Expression<DateTime>? startDate,
    Expression<DateTime>? targetDate,
    Expression<int>? weeks,
    Expression<String>? status,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (startWeightKg != null) 'start_weight_kg': startWeightKg,
      if (targetWeightKg != null) 'target_weight_kg': targetWeightKg,
      if (startDate != null) 'start_date': startDate,
      if (targetDate != null) 'target_date': targetDate,
      if (weeks != null) 'weeks': weeks,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  GoalsCompanion copyWith({
    Value<int>? id,
    Value<double>? startWeightKg,
    Value<double>? targetWeightKg,
    Value<DateTime>? startDate,
    Value<DateTime>? targetDate,
    Value<int>? weeks,
    Value<String>? status,
    Value<DateTime>? createdAt,
  }) {
    return GoalsCompanion(
      id: id ?? this.id,
      startWeightKg: startWeightKg ?? this.startWeightKg,
      targetWeightKg: targetWeightKg ?? this.targetWeightKg,
      startDate: startDate ?? this.startDate,
      targetDate: targetDate ?? this.targetDate,
      weeks: weeks ?? this.weeks,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (startWeightKg.present) {
      map['start_weight_kg'] = Variable<double>(startWeightKg.value);
    }
    if (targetWeightKg.present) {
      map['target_weight_kg'] = Variable<double>(targetWeightKg.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (targetDate.present) {
      map['target_date'] = Variable<DateTime>(targetDate.value);
    }
    if (weeks.present) {
      map['weeks'] = Variable<int>(weeks.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GoalsCompanion(')
          ..write('id: $id, ')
          ..write('startWeightKg: $startWeightKg, ')
          ..write('targetWeightKg: $targetWeightKg, ')
          ..write('startDate: $startDate, ')
          ..write('targetDate: $targetDate, ')
          ..write('weeks: $weeks, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $MemoryFactsTable extends MemoryFacts
    with TableInfo<$MemoryFactsTable, MemoryFactsRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MemoryFactsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _factMeta = const VerificationMeta('fact');
  @override
  late final GeneratedColumn<String> fact = GeneratedColumn<String>(
    'fact',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('other'),
  );
  static const VerificationMeta _confidenceMeta = const VerificationMeta(
    'confidence',
  );
  @override
  late final GeneratedColumn<double> confidence = GeneratedColumn<double>(
    'confidence',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.8),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('active'),
  );
  static const VerificationMeta _supersededByMeta = const VerificationMeta(
    'supersededBy',
  );
  @override
  late final GeneratedColumn<int> supersededBy = GeneratedColumn<int>(
    'superseded_by',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceMessageIdMeta = const VerificationMeta(
    'sourceMessageId',
  );
  @override
  late final GeneratedColumn<int> sourceMessageId = GeneratedColumn<int>(
    'source_message_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    key,
    fact,
    category,
    confidence,
    status,
    supersededBy,
    sourceMessageId,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'memory_facts';
  @override
  VerificationContext validateIntegrity(
    Insertable<MemoryFactsRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('fact')) {
      context.handle(
        _factMeta,
        fact.isAcceptableOrUnknown(data['fact']!, _factMeta),
      );
    } else if (isInserting) {
      context.missing(_factMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    if (data.containsKey('confidence')) {
      context.handle(
        _confidenceMeta,
        confidence.isAcceptableOrUnknown(data['confidence']!, _confidenceMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('superseded_by')) {
      context.handle(
        _supersededByMeta,
        supersededBy.isAcceptableOrUnknown(
          data['superseded_by']!,
          _supersededByMeta,
        ),
      );
    }
    if (data.containsKey('source_message_id')) {
      context.handle(
        _sourceMessageIdMeta,
        sourceMessageId.isAcceptableOrUnknown(
          data['source_message_id']!,
          _sourceMessageIdMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MemoryFactsRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MemoryFactsRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      fact: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fact'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      confidence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}confidence'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      supersededBy: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}superseded_by'],
      ),
      sourceMessageId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}source_message_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $MemoryFactsTable createAlias(String alias) {
    return $MemoryFactsTable(attachedDatabase, alias);
  }
}

class MemoryFactsRow extends DataClass implements Insertable<MemoryFactsRow> {
  final int id;

  /// Стабильный ключ темы, например «intolerance.lactose». Один ключ —
  /// один актуальный факт.
  final String key;
  final String fact;

  /// lifestyle | schedule | intolerance | food | budget | health | habit |
  /// motivation | obstacle | other
  final String category;
  final double confidence;

  /// 'active' | 'superseded'
  final String status;
  final int? supersededBy;
  final int? sourceMessageId;
  final DateTime createdAt;
  final DateTime updatedAt;
  const MemoryFactsRow({
    required this.id,
    required this.key,
    required this.fact,
    required this.category,
    required this.confidence,
    required this.status,
    this.supersededBy,
    this.sourceMessageId,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['key'] = Variable<String>(key);
    map['fact'] = Variable<String>(fact);
    map['category'] = Variable<String>(category);
    map['confidence'] = Variable<double>(confidence);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || supersededBy != null) {
      map['superseded_by'] = Variable<int>(supersededBy);
    }
    if (!nullToAbsent || sourceMessageId != null) {
      map['source_message_id'] = Variable<int>(sourceMessageId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  MemoryFactsCompanion toCompanion(bool nullToAbsent) {
    return MemoryFactsCompanion(
      id: Value(id),
      key: Value(key),
      fact: Value(fact),
      category: Value(category),
      confidence: Value(confidence),
      status: Value(status),
      supersededBy: supersededBy == null && nullToAbsent
          ? const Value.absent()
          : Value(supersededBy),
      sourceMessageId: sourceMessageId == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceMessageId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory MemoryFactsRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MemoryFactsRow(
      id: serializer.fromJson<int>(json['id']),
      key: serializer.fromJson<String>(json['key']),
      fact: serializer.fromJson<String>(json['fact']),
      category: serializer.fromJson<String>(json['category']),
      confidence: serializer.fromJson<double>(json['confidence']),
      status: serializer.fromJson<String>(json['status']),
      supersededBy: serializer.fromJson<int?>(json['supersededBy']),
      sourceMessageId: serializer.fromJson<int?>(json['sourceMessageId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'key': serializer.toJson<String>(key),
      'fact': serializer.toJson<String>(fact),
      'category': serializer.toJson<String>(category),
      'confidence': serializer.toJson<double>(confidence),
      'status': serializer.toJson<String>(status),
      'supersededBy': serializer.toJson<int?>(supersededBy),
      'sourceMessageId': serializer.toJson<int?>(sourceMessageId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  MemoryFactsRow copyWith({
    int? id,
    String? key,
    String? fact,
    String? category,
    double? confidence,
    String? status,
    Value<int?> supersededBy = const Value.absent(),
    Value<int?> sourceMessageId = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => MemoryFactsRow(
    id: id ?? this.id,
    key: key ?? this.key,
    fact: fact ?? this.fact,
    category: category ?? this.category,
    confidence: confidence ?? this.confidence,
    status: status ?? this.status,
    supersededBy: supersededBy.present ? supersededBy.value : this.supersededBy,
    sourceMessageId: sourceMessageId.present
        ? sourceMessageId.value
        : this.sourceMessageId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  MemoryFactsRow copyWithCompanion(MemoryFactsCompanion data) {
    return MemoryFactsRow(
      id: data.id.present ? data.id.value : this.id,
      key: data.key.present ? data.key.value : this.key,
      fact: data.fact.present ? data.fact.value : this.fact,
      category: data.category.present ? data.category.value : this.category,
      confidence: data.confidence.present
          ? data.confidence.value
          : this.confidence,
      status: data.status.present ? data.status.value : this.status,
      supersededBy: data.supersededBy.present
          ? data.supersededBy.value
          : this.supersededBy,
      sourceMessageId: data.sourceMessageId.present
          ? data.sourceMessageId.value
          : this.sourceMessageId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MemoryFactsRow(')
          ..write('id: $id, ')
          ..write('key: $key, ')
          ..write('fact: $fact, ')
          ..write('category: $category, ')
          ..write('confidence: $confidence, ')
          ..write('status: $status, ')
          ..write('supersededBy: $supersededBy, ')
          ..write('sourceMessageId: $sourceMessageId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    key,
    fact,
    category,
    confidence,
    status,
    supersededBy,
    sourceMessageId,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MemoryFactsRow &&
          other.id == this.id &&
          other.key == this.key &&
          other.fact == this.fact &&
          other.category == this.category &&
          other.confidence == this.confidence &&
          other.status == this.status &&
          other.supersededBy == this.supersededBy &&
          other.sourceMessageId == this.sourceMessageId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class MemoryFactsCompanion extends UpdateCompanion<MemoryFactsRow> {
  final Value<int> id;
  final Value<String> key;
  final Value<String> fact;
  final Value<String> category;
  final Value<double> confidence;
  final Value<String> status;
  final Value<int?> supersededBy;
  final Value<int?> sourceMessageId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const MemoryFactsCompanion({
    this.id = const Value.absent(),
    this.key = const Value.absent(),
    this.fact = const Value.absent(),
    this.category = const Value.absent(),
    this.confidence = const Value.absent(),
    this.status = const Value.absent(),
    this.supersededBy = const Value.absent(),
    this.sourceMessageId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  MemoryFactsCompanion.insert({
    this.id = const Value.absent(),
    required String key,
    required String fact,
    this.category = const Value.absent(),
    this.confidence = const Value.absent(),
    this.status = const Value.absent(),
    this.supersededBy = const Value.absent(),
    this.sourceMessageId = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : key = Value(key),
       fact = Value(fact),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<MemoryFactsRow> custom({
    Expression<int>? id,
    Expression<String>? key,
    Expression<String>? fact,
    Expression<String>? category,
    Expression<double>? confidence,
    Expression<String>? status,
    Expression<int>? supersededBy,
    Expression<int>? sourceMessageId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (key != null) 'key': key,
      if (fact != null) 'fact': fact,
      if (category != null) 'category': category,
      if (confidence != null) 'confidence': confidence,
      if (status != null) 'status': status,
      if (supersededBy != null) 'superseded_by': supersededBy,
      if (sourceMessageId != null) 'source_message_id': sourceMessageId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  MemoryFactsCompanion copyWith({
    Value<int>? id,
    Value<String>? key,
    Value<String>? fact,
    Value<String>? category,
    Value<double>? confidence,
    Value<String>? status,
    Value<int?>? supersededBy,
    Value<int?>? sourceMessageId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return MemoryFactsCompanion(
      id: id ?? this.id,
      key: key ?? this.key,
      fact: fact ?? this.fact,
      category: category ?? this.category,
      confidence: confidence ?? this.confidence,
      status: status ?? this.status,
      supersededBy: supersededBy ?? this.supersededBy,
      sourceMessageId: sourceMessageId ?? this.sourceMessageId,
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
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (fact.present) {
      map['fact'] = Variable<String>(fact.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (confidence.present) {
      map['confidence'] = Variable<double>(confidence.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (supersededBy.present) {
      map['superseded_by'] = Variable<int>(supersededBy.value);
    }
    if (sourceMessageId.present) {
      map['source_message_id'] = Variable<int>(sourceMessageId.value);
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
    return (StringBuffer('MemoryFactsCompanion(')
          ..write('id: $id, ')
          ..write('key: $key, ')
          ..write('fact: $fact, ')
          ..write('category: $category, ')
          ..write('confidence: $confidence, ')
          ..write('status: $status, ')
          ..write('supersededBy: $supersededBy, ')
          ..write('sourceMessageId: $sourceMessageId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $DietPlansTable extends DietPlans
    with TableInfo<$DietPlansTable, DietPlansRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DietPlansTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kcalTargetMeta = const VerificationMeta(
    'kcalTarget',
  );
  @override
  late final GeneratedColumn<int> kcalTarget = GeneratedColumn<int>(
    'kcal_target',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _proteinGMeta = const VerificationMeta(
    'proteinG',
  );
  @override
  late final GeneratedColumn<int> proteinG = GeneratedColumn<int>(
    'protein_g',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fatGMeta = const VerificationMeta('fatG');
  @override
  late final GeneratedColumn<int> fatG = GeneratedColumn<int>(
    'fat_g',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _carbsGMeta = const VerificationMeta('carbsG');
  @override
  late final GeneratedColumn<int> carbsG = GeneratedColumn<int>(
    'carbs_g',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bmrMeta = const VerificationMeta('bmr');
  @override
  late final GeneratedColumn<int> bmr = GeneratedColumn<int>(
    'bmr',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tdeeMeta = const VerificationMeta('tdee');
  @override
  late final GeneratedColumn<int> tdee = GeneratedColumn<int>(
    'tdee',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deficitKcalMeta = const VerificationMeta(
    'deficitKcal',
  );
  @override
  late final GeneratedColumn<int> deficitKcal = GeneratedColumn<int>(
    'deficit_kcal',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weeklyLossKgMeta = const VerificationMeta(
    'weeklyLossKg',
  );
  @override
  late final GeneratedColumn<double> weeklyLossKg = GeneratedColumn<double>(
    'weekly_loss_kg',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _toleranceKcalMeta = const VerificationMeta(
    'toleranceKcal',
  );
  @override
  late final GeneratedColumn<int> toleranceKcal = GeneratedColumn<int>(
    'tolerance_kcal',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(100),
  );
  static const VerificationMeta _notesJsonMeta = const VerificationMeta(
    'notesJson',
  );
  @override
  late final GeneratedColumn<String> notesJson = GeneratedColumn<String>(
    'notes_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _activeMeta = const VerificationMeta('active');
  @override
  late final GeneratedColumn<bool> active = GeneratedColumn<bool>(
    'active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    kcalTarget,
    proteinG,
    fatG,
    carbsG,
    bmr,
    tdee,
    deficitKcal,
    weeklyLossKg,
    toleranceKcal,
    notesJson,
    active,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'diet_plans';
  @override
  VerificationContext validateIntegrity(
    Insertable<DietPlansRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('kcal_target')) {
      context.handle(
        _kcalTargetMeta,
        kcalTarget.isAcceptableOrUnknown(data['kcal_target']!, _kcalTargetMeta),
      );
    } else if (isInserting) {
      context.missing(_kcalTargetMeta);
    }
    if (data.containsKey('protein_g')) {
      context.handle(
        _proteinGMeta,
        proteinG.isAcceptableOrUnknown(data['protein_g']!, _proteinGMeta),
      );
    } else if (isInserting) {
      context.missing(_proteinGMeta);
    }
    if (data.containsKey('fat_g')) {
      context.handle(
        _fatGMeta,
        fatG.isAcceptableOrUnknown(data['fat_g']!, _fatGMeta),
      );
    } else if (isInserting) {
      context.missing(_fatGMeta);
    }
    if (data.containsKey('carbs_g')) {
      context.handle(
        _carbsGMeta,
        carbsG.isAcceptableOrUnknown(data['carbs_g']!, _carbsGMeta),
      );
    } else if (isInserting) {
      context.missing(_carbsGMeta);
    }
    if (data.containsKey('bmr')) {
      context.handle(
        _bmrMeta,
        bmr.isAcceptableOrUnknown(data['bmr']!, _bmrMeta),
      );
    } else if (isInserting) {
      context.missing(_bmrMeta);
    }
    if (data.containsKey('tdee')) {
      context.handle(
        _tdeeMeta,
        tdee.isAcceptableOrUnknown(data['tdee']!, _tdeeMeta),
      );
    } else if (isInserting) {
      context.missing(_tdeeMeta);
    }
    if (data.containsKey('deficit_kcal')) {
      context.handle(
        _deficitKcalMeta,
        deficitKcal.isAcceptableOrUnknown(
          data['deficit_kcal']!,
          _deficitKcalMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_deficitKcalMeta);
    }
    if (data.containsKey('weekly_loss_kg')) {
      context.handle(
        _weeklyLossKgMeta,
        weeklyLossKg.isAcceptableOrUnknown(
          data['weekly_loss_kg']!,
          _weeklyLossKgMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_weeklyLossKgMeta);
    }
    if (data.containsKey('tolerance_kcal')) {
      context.handle(
        _toleranceKcalMeta,
        toleranceKcal.isAcceptableOrUnknown(
          data['tolerance_kcal']!,
          _toleranceKcalMeta,
        ),
      );
    }
    if (data.containsKey('notes_json')) {
      context.handle(
        _notesJsonMeta,
        notesJson.isAcceptableOrUnknown(data['notes_json']!, _notesJsonMeta),
      );
    }
    if (data.containsKey('active')) {
      context.handle(
        _activeMeta,
        active.isAcceptableOrUnknown(data['active']!, _activeMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DietPlansRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DietPlansRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      kcalTarget: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}kcal_target'],
      )!,
      proteinG: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}protein_g'],
      )!,
      fatG: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fat_g'],
      )!,
      carbsG: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}carbs_g'],
      )!,
      bmr: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}bmr'],
      )!,
      tdee: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tdee'],
      )!,
      deficitKcal: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deficit_kcal'],
      )!,
      weeklyLossKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weekly_loss_kg'],
      )!,
      toleranceKcal: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tolerance_kcal'],
      )!,
      notesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes_json'],
      )!,
      active: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}active'],
      )!,
    );
  }

  @override
  $DietPlansTable createAlias(String alias) {
    return $DietPlansTable(attachedDatabase, alias);
  }
}

class DietPlansRow extends DataClass implements Insertable<DietPlansRow> {
  final int id;
  final DateTime createdAt;
  final int kcalTarget;
  final int proteinG;
  final int fatG;
  final int carbsG;
  final int bmr;
  final int tdee;
  final int deficitKcal;
  final double weeklyLossKg;

  /// Допустимое отклонение от нормы в день (± ккал).
  final int toleranceKcal;

  /// Предупреждения и заметки о расчёте (JSON-массив строк).
  final String notesJson;
  final bool active;
  const DietPlansRow({
    required this.id,
    required this.createdAt,
    required this.kcalTarget,
    required this.proteinG,
    required this.fatG,
    required this.carbsG,
    required this.bmr,
    required this.tdee,
    required this.deficitKcal,
    required this.weeklyLossKg,
    required this.toleranceKcal,
    required this.notesJson,
    required this.active,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['kcal_target'] = Variable<int>(kcalTarget);
    map['protein_g'] = Variable<int>(proteinG);
    map['fat_g'] = Variable<int>(fatG);
    map['carbs_g'] = Variable<int>(carbsG);
    map['bmr'] = Variable<int>(bmr);
    map['tdee'] = Variable<int>(tdee);
    map['deficit_kcal'] = Variable<int>(deficitKcal);
    map['weekly_loss_kg'] = Variable<double>(weeklyLossKg);
    map['tolerance_kcal'] = Variable<int>(toleranceKcal);
    map['notes_json'] = Variable<String>(notesJson);
    map['active'] = Variable<bool>(active);
    return map;
  }

  DietPlansCompanion toCompanion(bool nullToAbsent) {
    return DietPlansCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      kcalTarget: Value(kcalTarget),
      proteinG: Value(proteinG),
      fatG: Value(fatG),
      carbsG: Value(carbsG),
      bmr: Value(bmr),
      tdee: Value(tdee),
      deficitKcal: Value(deficitKcal),
      weeklyLossKg: Value(weeklyLossKg),
      toleranceKcal: Value(toleranceKcal),
      notesJson: Value(notesJson),
      active: Value(active),
    );
  }

  factory DietPlansRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DietPlansRow(
      id: serializer.fromJson<int>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      kcalTarget: serializer.fromJson<int>(json['kcalTarget']),
      proteinG: serializer.fromJson<int>(json['proteinG']),
      fatG: serializer.fromJson<int>(json['fatG']),
      carbsG: serializer.fromJson<int>(json['carbsG']),
      bmr: serializer.fromJson<int>(json['bmr']),
      tdee: serializer.fromJson<int>(json['tdee']),
      deficitKcal: serializer.fromJson<int>(json['deficitKcal']),
      weeklyLossKg: serializer.fromJson<double>(json['weeklyLossKg']),
      toleranceKcal: serializer.fromJson<int>(json['toleranceKcal']),
      notesJson: serializer.fromJson<String>(json['notesJson']),
      active: serializer.fromJson<bool>(json['active']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'kcalTarget': serializer.toJson<int>(kcalTarget),
      'proteinG': serializer.toJson<int>(proteinG),
      'fatG': serializer.toJson<int>(fatG),
      'carbsG': serializer.toJson<int>(carbsG),
      'bmr': serializer.toJson<int>(bmr),
      'tdee': serializer.toJson<int>(tdee),
      'deficitKcal': serializer.toJson<int>(deficitKcal),
      'weeklyLossKg': serializer.toJson<double>(weeklyLossKg),
      'toleranceKcal': serializer.toJson<int>(toleranceKcal),
      'notesJson': serializer.toJson<String>(notesJson),
      'active': serializer.toJson<bool>(active),
    };
  }

  DietPlansRow copyWith({
    int? id,
    DateTime? createdAt,
    int? kcalTarget,
    int? proteinG,
    int? fatG,
    int? carbsG,
    int? bmr,
    int? tdee,
    int? deficitKcal,
    double? weeklyLossKg,
    int? toleranceKcal,
    String? notesJson,
    bool? active,
  }) => DietPlansRow(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    kcalTarget: kcalTarget ?? this.kcalTarget,
    proteinG: proteinG ?? this.proteinG,
    fatG: fatG ?? this.fatG,
    carbsG: carbsG ?? this.carbsG,
    bmr: bmr ?? this.bmr,
    tdee: tdee ?? this.tdee,
    deficitKcal: deficitKcal ?? this.deficitKcal,
    weeklyLossKg: weeklyLossKg ?? this.weeklyLossKg,
    toleranceKcal: toleranceKcal ?? this.toleranceKcal,
    notesJson: notesJson ?? this.notesJson,
    active: active ?? this.active,
  );
  DietPlansRow copyWithCompanion(DietPlansCompanion data) {
    return DietPlansRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      kcalTarget: data.kcalTarget.present
          ? data.kcalTarget.value
          : this.kcalTarget,
      proteinG: data.proteinG.present ? data.proteinG.value : this.proteinG,
      fatG: data.fatG.present ? data.fatG.value : this.fatG,
      carbsG: data.carbsG.present ? data.carbsG.value : this.carbsG,
      bmr: data.bmr.present ? data.bmr.value : this.bmr,
      tdee: data.tdee.present ? data.tdee.value : this.tdee,
      deficitKcal: data.deficitKcal.present
          ? data.deficitKcal.value
          : this.deficitKcal,
      weeklyLossKg: data.weeklyLossKg.present
          ? data.weeklyLossKg.value
          : this.weeklyLossKg,
      toleranceKcal: data.toleranceKcal.present
          ? data.toleranceKcal.value
          : this.toleranceKcal,
      notesJson: data.notesJson.present ? data.notesJson.value : this.notesJson,
      active: data.active.present ? data.active.value : this.active,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DietPlansRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('kcalTarget: $kcalTarget, ')
          ..write('proteinG: $proteinG, ')
          ..write('fatG: $fatG, ')
          ..write('carbsG: $carbsG, ')
          ..write('bmr: $bmr, ')
          ..write('tdee: $tdee, ')
          ..write('deficitKcal: $deficitKcal, ')
          ..write('weeklyLossKg: $weeklyLossKg, ')
          ..write('toleranceKcal: $toleranceKcal, ')
          ..write('notesJson: $notesJson, ')
          ..write('active: $active')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    kcalTarget,
    proteinG,
    fatG,
    carbsG,
    bmr,
    tdee,
    deficitKcal,
    weeklyLossKg,
    toleranceKcal,
    notesJson,
    active,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DietPlansRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.kcalTarget == this.kcalTarget &&
          other.proteinG == this.proteinG &&
          other.fatG == this.fatG &&
          other.carbsG == this.carbsG &&
          other.bmr == this.bmr &&
          other.tdee == this.tdee &&
          other.deficitKcal == this.deficitKcal &&
          other.weeklyLossKg == this.weeklyLossKg &&
          other.toleranceKcal == this.toleranceKcal &&
          other.notesJson == this.notesJson &&
          other.active == this.active);
}

class DietPlansCompanion extends UpdateCompanion<DietPlansRow> {
  final Value<int> id;
  final Value<DateTime> createdAt;
  final Value<int> kcalTarget;
  final Value<int> proteinG;
  final Value<int> fatG;
  final Value<int> carbsG;
  final Value<int> bmr;
  final Value<int> tdee;
  final Value<int> deficitKcal;
  final Value<double> weeklyLossKg;
  final Value<int> toleranceKcal;
  final Value<String> notesJson;
  final Value<bool> active;
  const DietPlansCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.kcalTarget = const Value.absent(),
    this.proteinG = const Value.absent(),
    this.fatG = const Value.absent(),
    this.carbsG = const Value.absent(),
    this.bmr = const Value.absent(),
    this.tdee = const Value.absent(),
    this.deficitKcal = const Value.absent(),
    this.weeklyLossKg = const Value.absent(),
    this.toleranceKcal = const Value.absent(),
    this.notesJson = const Value.absent(),
    this.active = const Value.absent(),
  });
  DietPlansCompanion.insert({
    this.id = const Value.absent(),
    required DateTime createdAt,
    required int kcalTarget,
    required int proteinG,
    required int fatG,
    required int carbsG,
    required int bmr,
    required int tdee,
    required int deficitKcal,
    required double weeklyLossKg,
    this.toleranceKcal = const Value.absent(),
    this.notesJson = const Value.absent(),
    this.active = const Value.absent(),
  }) : createdAt = Value(createdAt),
       kcalTarget = Value(kcalTarget),
       proteinG = Value(proteinG),
       fatG = Value(fatG),
       carbsG = Value(carbsG),
       bmr = Value(bmr),
       tdee = Value(tdee),
       deficitKcal = Value(deficitKcal),
       weeklyLossKg = Value(weeklyLossKg);
  static Insertable<DietPlansRow> custom({
    Expression<int>? id,
    Expression<DateTime>? createdAt,
    Expression<int>? kcalTarget,
    Expression<int>? proteinG,
    Expression<int>? fatG,
    Expression<int>? carbsG,
    Expression<int>? bmr,
    Expression<int>? tdee,
    Expression<int>? deficitKcal,
    Expression<double>? weeklyLossKg,
    Expression<int>? toleranceKcal,
    Expression<String>? notesJson,
    Expression<bool>? active,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (kcalTarget != null) 'kcal_target': kcalTarget,
      if (proteinG != null) 'protein_g': proteinG,
      if (fatG != null) 'fat_g': fatG,
      if (carbsG != null) 'carbs_g': carbsG,
      if (bmr != null) 'bmr': bmr,
      if (tdee != null) 'tdee': tdee,
      if (deficitKcal != null) 'deficit_kcal': deficitKcal,
      if (weeklyLossKg != null) 'weekly_loss_kg': weeklyLossKg,
      if (toleranceKcal != null) 'tolerance_kcal': toleranceKcal,
      if (notesJson != null) 'notes_json': notesJson,
      if (active != null) 'active': active,
    });
  }

  DietPlansCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? createdAt,
    Value<int>? kcalTarget,
    Value<int>? proteinG,
    Value<int>? fatG,
    Value<int>? carbsG,
    Value<int>? bmr,
    Value<int>? tdee,
    Value<int>? deficitKcal,
    Value<double>? weeklyLossKg,
    Value<int>? toleranceKcal,
    Value<String>? notesJson,
    Value<bool>? active,
  }) {
    return DietPlansCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      kcalTarget: kcalTarget ?? this.kcalTarget,
      proteinG: proteinG ?? this.proteinG,
      fatG: fatG ?? this.fatG,
      carbsG: carbsG ?? this.carbsG,
      bmr: bmr ?? this.bmr,
      tdee: tdee ?? this.tdee,
      deficitKcal: deficitKcal ?? this.deficitKcal,
      weeklyLossKg: weeklyLossKg ?? this.weeklyLossKg,
      toleranceKcal: toleranceKcal ?? this.toleranceKcal,
      notesJson: notesJson ?? this.notesJson,
      active: active ?? this.active,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (kcalTarget.present) {
      map['kcal_target'] = Variable<int>(kcalTarget.value);
    }
    if (proteinG.present) {
      map['protein_g'] = Variable<int>(proteinG.value);
    }
    if (fatG.present) {
      map['fat_g'] = Variable<int>(fatG.value);
    }
    if (carbsG.present) {
      map['carbs_g'] = Variable<int>(carbsG.value);
    }
    if (bmr.present) {
      map['bmr'] = Variable<int>(bmr.value);
    }
    if (tdee.present) {
      map['tdee'] = Variable<int>(tdee.value);
    }
    if (deficitKcal.present) {
      map['deficit_kcal'] = Variable<int>(deficitKcal.value);
    }
    if (weeklyLossKg.present) {
      map['weekly_loss_kg'] = Variable<double>(weeklyLossKg.value);
    }
    if (toleranceKcal.present) {
      map['tolerance_kcal'] = Variable<int>(toleranceKcal.value);
    }
    if (notesJson.present) {
      map['notes_json'] = Variable<String>(notesJson.value);
    }
    if (active.present) {
      map['active'] = Variable<bool>(active.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DietPlansCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('kcalTarget: $kcalTarget, ')
          ..write('proteinG: $proteinG, ')
          ..write('fatG: $fatG, ')
          ..write('carbsG: $carbsG, ')
          ..write('bmr: $bmr, ')
          ..write('tdee: $tdee, ')
          ..write('deficitKcal: $deficitKcal, ')
          ..write('weeklyLossKg: $weeklyLossKg, ')
          ..write('toleranceKcal: $toleranceKcal, ')
          ..write('notesJson: $notesJson, ')
          ..write('active: $active')
          ..write(')'))
        .toString();
  }
}

class $DiaryEntriesTable extends DiaryEntries
    with TableInfo<$DiaryEntriesTable, DiaryEntriesRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DiaryEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _eatenAtMeta = const VerificationMeta(
    'eatenAt',
  );
  @override
  late final GeneratedColumn<DateTime> eatenAt = GeneratedColumn<DateTime>(
    'eaten_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mealMeta = const VerificationMeta('meal');
  @override
  late final GeneratedColumn<String> meal = GeneratedColumn<String>(
    'meal',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('snack'),
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kcalMeta = const VerificationMeta('kcal');
  @override
  late final GeneratedColumn<int> kcal = GeneratedColumn<int>(
    'kcal',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _proteinGMeta = const VerificationMeta(
    'proteinG',
  );
  @override
  late final GeneratedColumn<double> proteinG = GeneratedColumn<double>(
    'protein_g',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fatGMeta = const VerificationMeta('fatG');
  @override
  late final GeneratedColumn<double> fatG = GeneratedColumn<double>(
    'fat_g',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _carbsGMeta = const VerificationMeta('carbsG');
  @override
  late final GeneratedColumn<double> carbsG = GeneratedColumn<double>(
    'carbs_g',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _photoPathsJsonMeta = const VerificationMeta(
    'photoPathsJson',
  );
  @override
  late final GeneratedColumn<String> photoPathsJson = GeneratedColumn<String>(
    'photo_paths_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('chat_text'),
  );
  static const VerificationMeta _messageIdMeta = const VerificationMeta(
    'messageId',
  );
  @override
  late final GeneratedColumn<int> messageId = GeneratedColumn<int>(
    'message_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    eatenAt,
    meal,
    description,
    kcal,
    proteinG,
    fatG,
    carbsG,
    photoPathsJson,
    source,
    messageId,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'diary_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<DiaryEntriesRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('eaten_at')) {
      context.handle(
        _eatenAtMeta,
        eatenAt.isAcceptableOrUnknown(data['eaten_at']!, _eatenAtMeta),
      );
    } else if (isInserting) {
      context.missing(_eatenAtMeta);
    }
    if (data.containsKey('meal')) {
      context.handle(
        _mealMeta,
        meal.isAcceptableOrUnknown(data['meal']!, _mealMeta),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('kcal')) {
      context.handle(
        _kcalMeta,
        kcal.isAcceptableOrUnknown(data['kcal']!, _kcalMeta),
      );
    }
    if (data.containsKey('protein_g')) {
      context.handle(
        _proteinGMeta,
        proteinG.isAcceptableOrUnknown(data['protein_g']!, _proteinGMeta),
      );
    }
    if (data.containsKey('fat_g')) {
      context.handle(
        _fatGMeta,
        fatG.isAcceptableOrUnknown(data['fat_g']!, _fatGMeta),
      );
    }
    if (data.containsKey('carbs_g')) {
      context.handle(
        _carbsGMeta,
        carbsG.isAcceptableOrUnknown(data['carbs_g']!, _carbsGMeta),
      );
    }
    if (data.containsKey('photo_paths_json')) {
      context.handle(
        _photoPathsJsonMeta,
        photoPathsJson.isAcceptableOrUnknown(
          data['photo_paths_json']!,
          _photoPathsJsonMeta,
        ),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    }
    if (data.containsKey('message_id')) {
      context.handle(
        _messageIdMeta,
        messageId.isAcceptableOrUnknown(data['message_id']!, _messageIdMeta),
      );
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
  DiaryEntriesRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DiaryEntriesRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      eatenAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}eaten_at'],
      )!,
      meal: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}meal'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      kcal: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}kcal'],
      ),
      proteinG: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}protein_g'],
      ),
      fatG: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fat_g'],
      ),
      carbsG: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}carbs_g'],
      ),
      photoPathsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}photo_paths_json'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      messageId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}message_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $DiaryEntriesTable createAlias(String alias) {
    return $DiaryEntriesTable(attachedDatabase, alias);
  }
}

class DiaryEntriesRow extends DataClass implements Insertable<DiaryEntriesRow> {
  final int id;
  final DateTime eatenAt;

  /// breakfast | lunch | dinner | snack
  final String meal;
  final String description;

  /// Калории «примерно».
  final int? kcal;
  final double? proteinG;
  final double? fatG;
  final double? carbsG;
  final String photoPathsJson;

  /// chat_text | chat_photo | chat_voice | manual
  final String source;
  final int? messageId;
  final DateTime createdAt;
  const DiaryEntriesRow({
    required this.id,
    required this.eatenAt,
    required this.meal,
    required this.description,
    this.kcal,
    this.proteinG,
    this.fatG,
    this.carbsG,
    required this.photoPathsJson,
    required this.source,
    this.messageId,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['eaten_at'] = Variable<DateTime>(eatenAt);
    map['meal'] = Variable<String>(meal);
    map['description'] = Variable<String>(description);
    if (!nullToAbsent || kcal != null) {
      map['kcal'] = Variable<int>(kcal);
    }
    if (!nullToAbsent || proteinG != null) {
      map['protein_g'] = Variable<double>(proteinG);
    }
    if (!nullToAbsent || fatG != null) {
      map['fat_g'] = Variable<double>(fatG);
    }
    if (!nullToAbsent || carbsG != null) {
      map['carbs_g'] = Variable<double>(carbsG);
    }
    map['photo_paths_json'] = Variable<String>(photoPathsJson);
    map['source'] = Variable<String>(source);
    if (!nullToAbsent || messageId != null) {
      map['message_id'] = Variable<int>(messageId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  DiaryEntriesCompanion toCompanion(bool nullToAbsent) {
    return DiaryEntriesCompanion(
      id: Value(id),
      eatenAt: Value(eatenAt),
      meal: Value(meal),
      description: Value(description),
      kcal: kcal == null && nullToAbsent ? const Value.absent() : Value(kcal),
      proteinG: proteinG == null && nullToAbsent
          ? const Value.absent()
          : Value(proteinG),
      fatG: fatG == null && nullToAbsent ? const Value.absent() : Value(fatG),
      carbsG: carbsG == null && nullToAbsent
          ? const Value.absent()
          : Value(carbsG),
      photoPathsJson: Value(photoPathsJson),
      source: Value(source),
      messageId: messageId == null && nullToAbsent
          ? const Value.absent()
          : Value(messageId),
      createdAt: Value(createdAt),
    );
  }

  factory DiaryEntriesRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DiaryEntriesRow(
      id: serializer.fromJson<int>(json['id']),
      eatenAt: serializer.fromJson<DateTime>(json['eatenAt']),
      meal: serializer.fromJson<String>(json['meal']),
      description: serializer.fromJson<String>(json['description']),
      kcal: serializer.fromJson<int?>(json['kcal']),
      proteinG: serializer.fromJson<double?>(json['proteinG']),
      fatG: serializer.fromJson<double?>(json['fatG']),
      carbsG: serializer.fromJson<double?>(json['carbsG']),
      photoPathsJson: serializer.fromJson<String>(json['photoPathsJson']),
      source: serializer.fromJson<String>(json['source']),
      messageId: serializer.fromJson<int?>(json['messageId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'eatenAt': serializer.toJson<DateTime>(eatenAt),
      'meal': serializer.toJson<String>(meal),
      'description': serializer.toJson<String>(description),
      'kcal': serializer.toJson<int?>(kcal),
      'proteinG': serializer.toJson<double?>(proteinG),
      'fatG': serializer.toJson<double?>(fatG),
      'carbsG': serializer.toJson<double?>(carbsG),
      'photoPathsJson': serializer.toJson<String>(photoPathsJson),
      'source': serializer.toJson<String>(source),
      'messageId': serializer.toJson<int?>(messageId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  DiaryEntriesRow copyWith({
    int? id,
    DateTime? eatenAt,
    String? meal,
    String? description,
    Value<int?> kcal = const Value.absent(),
    Value<double?> proteinG = const Value.absent(),
    Value<double?> fatG = const Value.absent(),
    Value<double?> carbsG = const Value.absent(),
    String? photoPathsJson,
    String? source,
    Value<int?> messageId = const Value.absent(),
    DateTime? createdAt,
  }) => DiaryEntriesRow(
    id: id ?? this.id,
    eatenAt: eatenAt ?? this.eatenAt,
    meal: meal ?? this.meal,
    description: description ?? this.description,
    kcal: kcal.present ? kcal.value : this.kcal,
    proteinG: proteinG.present ? proteinG.value : this.proteinG,
    fatG: fatG.present ? fatG.value : this.fatG,
    carbsG: carbsG.present ? carbsG.value : this.carbsG,
    photoPathsJson: photoPathsJson ?? this.photoPathsJson,
    source: source ?? this.source,
    messageId: messageId.present ? messageId.value : this.messageId,
    createdAt: createdAt ?? this.createdAt,
  );
  DiaryEntriesRow copyWithCompanion(DiaryEntriesCompanion data) {
    return DiaryEntriesRow(
      id: data.id.present ? data.id.value : this.id,
      eatenAt: data.eatenAt.present ? data.eatenAt.value : this.eatenAt,
      meal: data.meal.present ? data.meal.value : this.meal,
      description: data.description.present
          ? data.description.value
          : this.description,
      kcal: data.kcal.present ? data.kcal.value : this.kcal,
      proteinG: data.proteinG.present ? data.proteinG.value : this.proteinG,
      fatG: data.fatG.present ? data.fatG.value : this.fatG,
      carbsG: data.carbsG.present ? data.carbsG.value : this.carbsG,
      photoPathsJson: data.photoPathsJson.present
          ? data.photoPathsJson.value
          : this.photoPathsJson,
      source: data.source.present ? data.source.value : this.source,
      messageId: data.messageId.present ? data.messageId.value : this.messageId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DiaryEntriesRow(')
          ..write('id: $id, ')
          ..write('eatenAt: $eatenAt, ')
          ..write('meal: $meal, ')
          ..write('description: $description, ')
          ..write('kcal: $kcal, ')
          ..write('proteinG: $proteinG, ')
          ..write('fatG: $fatG, ')
          ..write('carbsG: $carbsG, ')
          ..write('photoPathsJson: $photoPathsJson, ')
          ..write('source: $source, ')
          ..write('messageId: $messageId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    eatenAt,
    meal,
    description,
    kcal,
    proteinG,
    fatG,
    carbsG,
    photoPathsJson,
    source,
    messageId,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DiaryEntriesRow &&
          other.id == this.id &&
          other.eatenAt == this.eatenAt &&
          other.meal == this.meal &&
          other.description == this.description &&
          other.kcal == this.kcal &&
          other.proteinG == this.proteinG &&
          other.fatG == this.fatG &&
          other.carbsG == this.carbsG &&
          other.photoPathsJson == this.photoPathsJson &&
          other.source == this.source &&
          other.messageId == this.messageId &&
          other.createdAt == this.createdAt);
}

class DiaryEntriesCompanion extends UpdateCompanion<DiaryEntriesRow> {
  final Value<int> id;
  final Value<DateTime> eatenAt;
  final Value<String> meal;
  final Value<String> description;
  final Value<int?> kcal;
  final Value<double?> proteinG;
  final Value<double?> fatG;
  final Value<double?> carbsG;
  final Value<String> photoPathsJson;
  final Value<String> source;
  final Value<int?> messageId;
  final Value<DateTime> createdAt;
  const DiaryEntriesCompanion({
    this.id = const Value.absent(),
    this.eatenAt = const Value.absent(),
    this.meal = const Value.absent(),
    this.description = const Value.absent(),
    this.kcal = const Value.absent(),
    this.proteinG = const Value.absent(),
    this.fatG = const Value.absent(),
    this.carbsG = const Value.absent(),
    this.photoPathsJson = const Value.absent(),
    this.source = const Value.absent(),
    this.messageId = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  DiaryEntriesCompanion.insert({
    this.id = const Value.absent(),
    required DateTime eatenAt,
    this.meal = const Value.absent(),
    required String description,
    this.kcal = const Value.absent(),
    this.proteinG = const Value.absent(),
    this.fatG = const Value.absent(),
    this.carbsG = const Value.absent(),
    this.photoPathsJson = const Value.absent(),
    this.source = const Value.absent(),
    this.messageId = const Value.absent(),
    required DateTime createdAt,
  }) : eatenAt = Value(eatenAt),
       description = Value(description),
       createdAt = Value(createdAt);
  static Insertable<DiaryEntriesRow> custom({
    Expression<int>? id,
    Expression<DateTime>? eatenAt,
    Expression<String>? meal,
    Expression<String>? description,
    Expression<int>? kcal,
    Expression<double>? proteinG,
    Expression<double>? fatG,
    Expression<double>? carbsG,
    Expression<String>? photoPathsJson,
    Expression<String>? source,
    Expression<int>? messageId,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (eatenAt != null) 'eaten_at': eatenAt,
      if (meal != null) 'meal': meal,
      if (description != null) 'description': description,
      if (kcal != null) 'kcal': kcal,
      if (proteinG != null) 'protein_g': proteinG,
      if (fatG != null) 'fat_g': fatG,
      if (carbsG != null) 'carbs_g': carbsG,
      if (photoPathsJson != null) 'photo_paths_json': photoPathsJson,
      if (source != null) 'source': source,
      if (messageId != null) 'message_id': messageId,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  DiaryEntriesCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? eatenAt,
    Value<String>? meal,
    Value<String>? description,
    Value<int?>? kcal,
    Value<double?>? proteinG,
    Value<double?>? fatG,
    Value<double?>? carbsG,
    Value<String>? photoPathsJson,
    Value<String>? source,
    Value<int?>? messageId,
    Value<DateTime>? createdAt,
  }) {
    return DiaryEntriesCompanion(
      id: id ?? this.id,
      eatenAt: eatenAt ?? this.eatenAt,
      meal: meal ?? this.meal,
      description: description ?? this.description,
      kcal: kcal ?? this.kcal,
      proteinG: proteinG ?? this.proteinG,
      fatG: fatG ?? this.fatG,
      carbsG: carbsG ?? this.carbsG,
      photoPathsJson: photoPathsJson ?? this.photoPathsJson,
      source: source ?? this.source,
      messageId: messageId ?? this.messageId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (eatenAt.present) {
      map['eaten_at'] = Variable<DateTime>(eatenAt.value);
    }
    if (meal.present) {
      map['meal'] = Variable<String>(meal.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (kcal.present) {
      map['kcal'] = Variable<int>(kcal.value);
    }
    if (proteinG.present) {
      map['protein_g'] = Variable<double>(proteinG.value);
    }
    if (fatG.present) {
      map['fat_g'] = Variable<double>(fatG.value);
    }
    if (carbsG.present) {
      map['carbs_g'] = Variable<double>(carbsG.value);
    }
    if (photoPathsJson.present) {
      map['photo_paths_json'] = Variable<String>(photoPathsJson.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (messageId.present) {
      map['message_id'] = Variable<int>(messageId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DiaryEntriesCompanion(')
          ..write('id: $id, ')
          ..write('eatenAt: $eatenAt, ')
          ..write('meal: $meal, ')
          ..write('description: $description, ')
          ..write('kcal: $kcal, ')
          ..write('proteinG: $proteinG, ')
          ..write('fatG: $fatG, ')
          ..write('carbsG: $carbsG, ')
          ..write('photoPathsJson: $photoPathsJson, ')
          ..write('source: $source, ')
          ..write('messageId: $messageId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $WorkoutsTable extends Workouts
    with TableInfo<$WorkoutsTable, WorkoutsRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkoutsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scheduledAtMeta = const VerificationMeta(
    'scheduledAt',
  );
  @override
  late final GeneratedColumn<DateTime> scheduledAt = GeneratedColumn<DateTime>(
    'scheduled_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _planJsonMeta = const VerificationMeta(
    'planJson',
  );
  @override
  late final GeneratedColumn<String> planJson = GeneratedColumn<String>(
    'plan_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('coach'),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('planned'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    scheduledAt,
    title,
    planJson,
    source,
    status,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'workouts';
  @override
  VerificationContext validateIntegrity(
    Insertable<WorkoutsRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('scheduled_at')) {
      context.handle(
        _scheduledAtMeta,
        scheduledAt.isAcceptableOrUnknown(
          data['scheduled_at']!,
          _scheduledAtMeta,
        ),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('plan_json')) {
      context.handle(
        _planJsonMeta,
        planJson.isAcceptableOrUnknown(data['plan_json']!, _planJsonMeta),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WorkoutsRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkoutsRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      scheduledAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}scheduled_at'],
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      planJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}plan_json'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
    );
  }

  @override
  $WorkoutsTable createAlias(String alias) {
    return $WorkoutsTable(attachedDatabase, alias);
  }
}

class WorkoutsRow extends DataClass implements Insertable<WorkoutsRow> {
  final int id;
  final DateTime createdAt;
  final DateTime? scheduledAt;
  final String title;
  final String planJson;

  /// coach | local | manual
  final String source;

  /// planned | done | skipped
  final String status;
  const WorkoutsRow({
    required this.id,
    required this.createdAt,
    this.scheduledAt,
    required this.title,
    required this.planJson,
    required this.source,
    required this.status,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || scheduledAt != null) {
      map['scheduled_at'] = Variable<DateTime>(scheduledAt);
    }
    map['title'] = Variable<String>(title);
    map['plan_json'] = Variable<String>(planJson);
    map['source'] = Variable<String>(source);
    map['status'] = Variable<String>(status);
    return map;
  }

  WorkoutsCompanion toCompanion(bool nullToAbsent) {
    return WorkoutsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      scheduledAt: scheduledAt == null && nullToAbsent
          ? const Value.absent()
          : Value(scheduledAt),
      title: Value(title),
      planJson: Value(planJson),
      source: Value(source),
      status: Value(status),
    );
  }

  factory WorkoutsRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkoutsRow(
      id: serializer.fromJson<int>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      scheduledAt: serializer.fromJson<DateTime?>(json['scheduledAt']),
      title: serializer.fromJson<String>(json['title']),
      planJson: serializer.fromJson<String>(json['planJson']),
      source: serializer.fromJson<String>(json['source']),
      status: serializer.fromJson<String>(json['status']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'scheduledAt': serializer.toJson<DateTime?>(scheduledAt),
      'title': serializer.toJson<String>(title),
      'planJson': serializer.toJson<String>(planJson),
      'source': serializer.toJson<String>(source),
      'status': serializer.toJson<String>(status),
    };
  }

  WorkoutsRow copyWith({
    int? id,
    DateTime? createdAt,
    Value<DateTime?> scheduledAt = const Value.absent(),
    String? title,
    String? planJson,
    String? source,
    String? status,
  }) => WorkoutsRow(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    scheduledAt: scheduledAt.present ? scheduledAt.value : this.scheduledAt,
    title: title ?? this.title,
    planJson: planJson ?? this.planJson,
    source: source ?? this.source,
    status: status ?? this.status,
  );
  WorkoutsRow copyWithCompanion(WorkoutsCompanion data) {
    return WorkoutsRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      scheduledAt: data.scheduledAt.present
          ? data.scheduledAt.value
          : this.scheduledAt,
      title: data.title.present ? data.title.value : this.title,
      planJson: data.planJson.present ? data.planJson.value : this.planJson,
      source: data.source.present ? data.source.value : this.source,
      status: data.status.present ? data.status.value : this.status,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutsRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('scheduledAt: $scheduledAt, ')
          ..write('title: $title, ')
          ..write('planJson: $planJson, ')
          ..write('source: $source, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, createdAt, scheduledAt, title, planJson, source, status);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkoutsRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.scheduledAt == this.scheduledAt &&
          other.title == this.title &&
          other.planJson == this.planJson &&
          other.source == this.source &&
          other.status == this.status);
}

class WorkoutsCompanion extends UpdateCompanion<WorkoutsRow> {
  final Value<int> id;
  final Value<DateTime> createdAt;
  final Value<DateTime?> scheduledAt;
  final Value<String> title;
  final Value<String> planJson;
  final Value<String> source;
  final Value<String> status;
  const WorkoutsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.scheduledAt = const Value.absent(),
    this.title = const Value.absent(),
    this.planJson = const Value.absent(),
    this.source = const Value.absent(),
    this.status = const Value.absent(),
  });
  WorkoutsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime createdAt,
    this.scheduledAt = const Value.absent(),
    required String title,
    this.planJson = const Value.absent(),
    this.source = const Value.absent(),
    this.status = const Value.absent(),
  }) : createdAt = Value(createdAt),
       title = Value(title);
  static Insertable<WorkoutsRow> custom({
    Expression<int>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? scheduledAt,
    Expression<String>? title,
    Expression<String>? planJson,
    Expression<String>? source,
    Expression<String>? status,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (scheduledAt != null) 'scheduled_at': scheduledAt,
      if (title != null) 'title': title,
      if (planJson != null) 'plan_json': planJson,
      if (source != null) 'source': source,
      if (status != null) 'status': status,
    });
  }

  WorkoutsCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? createdAt,
    Value<DateTime?>? scheduledAt,
    Value<String>? title,
    Value<String>? planJson,
    Value<String>? source,
    Value<String>? status,
  }) {
    return WorkoutsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      title: title ?? this.title,
      planJson: planJson ?? this.planJson,
      source: source ?? this.source,
      status: status ?? this.status,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (scheduledAt.present) {
      map['scheduled_at'] = Variable<DateTime>(scheduledAt.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (planJson.present) {
      map['plan_json'] = Variable<String>(planJson.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('scheduledAt: $scheduledAt, ')
          ..write('title: $title, ')
          ..write('planJson: $planJson, ')
          ..write('source: $source, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }
}

class $WorkoutResultsTable extends WorkoutResults
    with TableInfo<$WorkoutResultsTable, WorkoutResultsRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkoutResultsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _workoutIdMeta = const VerificationMeta(
    'workoutId',
  );
  @override
  late final GeneratedColumn<int> workoutId = GeneratedColumn<int>(
    'workout_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _finishedAtMeta = const VerificationMeta(
    'finishedAt',
  );
  @override
  late final GeneratedColumn<DateTime> finishedAt = GeneratedColumn<DateTime>(
    'finished_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _doneExercisesMeta = const VerificationMeta(
    'doneExercises',
  );
  @override
  late final GeneratedColumn<int> doneExercises = GeneratedColumn<int>(
    'done_exercises',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _skippedExercisesMeta = const VerificationMeta(
    'skippedExercises',
  );
  @override
  late final GeneratedColumn<int> skippedExercises = GeneratedColumn<int>(
    'skipped_exercises',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _pausesMeta = const VerificationMeta('pauses');
  @override
  late final GeneratedColumn<int> pauses = GeneratedColumn<int>(
    'pauses',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _pausedSecondsMeta = const VerificationMeta(
    'pausedSeconds',
  );
  @override
  late final GeneratedColumn<int> pausedSeconds = GeneratedColumn<int>(
    'paused_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _durationSecMeta = const VerificationMeta(
    'durationSec',
  );
  @override
  late final GeneratedColumn<int> durationSec = GeneratedColumn<int>(
    'duration_sec',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _kcalMeta = const VerificationMeta('kcal');
  @override
  late final GeneratedColumn<int> kcal = GeneratedColumn<int>(
    'kcal',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    workoutId,
    startedAt,
    finishedAt,
    status,
    doneExercises,
    skippedExercises,
    pauses,
    pausedSeconds,
    durationSec,
    kcal,
    note,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'workout_results';
  @override
  VerificationContext validateIntegrity(
    Insertable<WorkoutResultsRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('workout_id')) {
      context.handle(
        _workoutIdMeta,
        workoutId.isAcceptableOrUnknown(data['workout_id']!, _workoutIdMeta),
      );
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('finished_at')) {
      context.handle(
        _finishedAtMeta,
        finishedAt.isAcceptableOrUnknown(data['finished_at']!, _finishedAtMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('done_exercises')) {
      context.handle(
        _doneExercisesMeta,
        doneExercises.isAcceptableOrUnknown(
          data['done_exercises']!,
          _doneExercisesMeta,
        ),
      );
    }
    if (data.containsKey('skipped_exercises')) {
      context.handle(
        _skippedExercisesMeta,
        skippedExercises.isAcceptableOrUnknown(
          data['skipped_exercises']!,
          _skippedExercisesMeta,
        ),
      );
    }
    if (data.containsKey('pauses')) {
      context.handle(
        _pausesMeta,
        pauses.isAcceptableOrUnknown(data['pauses']!, _pausesMeta),
      );
    }
    if (data.containsKey('paused_seconds')) {
      context.handle(
        _pausedSecondsMeta,
        pausedSeconds.isAcceptableOrUnknown(
          data['paused_seconds']!,
          _pausedSecondsMeta,
        ),
      );
    }
    if (data.containsKey('duration_sec')) {
      context.handle(
        _durationSecMeta,
        durationSec.isAcceptableOrUnknown(
          data['duration_sec']!,
          _durationSecMeta,
        ),
      );
    }
    if (data.containsKey('kcal')) {
      context.handle(
        _kcalMeta,
        kcal.isAcceptableOrUnknown(data['kcal']!, _kcalMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WorkoutResultsRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkoutResultsRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      workoutId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}workout_id'],
      ),
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      finishedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}finished_at'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      doneExercises: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}done_exercises'],
      )!,
      skippedExercises: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}skipped_exercises'],
      )!,
      pauses: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pauses'],
      )!,
      pausedSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}paused_seconds'],
      )!,
      durationSec: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_sec'],
      )!,
      kcal: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}kcal'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
    );
  }

  @override
  $WorkoutResultsTable createAlias(String alias) {
    return $WorkoutResultsTable(attachedDatabase, alias);
  }
}

class WorkoutResultsRow extends DataClass
    implements Insertable<WorkoutResultsRow> {
  final int id;
  final int? workoutId;
  final DateTime startedAt;
  final DateTime? finishedAt;

  /// completed | aborted | skipped
  final String status;
  final int doneExercises;
  final int skippedExercises;
  final int pauses;
  final int pausedSeconds;
  final int durationSec;
  final int kcal;
  final String? note;
  const WorkoutResultsRow({
    required this.id,
    this.workoutId,
    required this.startedAt,
    this.finishedAt,
    required this.status,
    required this.doneExercises,
    required this.skippedExercises,
    required this.pauses,
    required this.pausedSeconds,
    required this.durationSec,
    required this.kcal,
    this.note,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || workoutId != null) {
      map['workout_id'] = Variable<int>(workoutId);
    }
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || finishedAt != null) {
      map['finished_at'] = Variable<DateTime>(finishedAt);
    }
    map['status'] = Variable<String>(status);
    map['done_exercises'] = Variable<int>(doneExercises);
    map['skipped_exercises'] = Variable<int>(skippedExercises);
    map['pauses'] = Variable<int>(pauses);
    map['paused_seconds'] = Variable<int>(pausedSeconds);
    map['duration_sec'] = Variable<int>(durationSec);
    map['kcal'] = Variable<int>(kcal);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    return map;
  }

  WorkoutResultsCompanion toCompanion(bool nullToAbsent) {
    return WorkoutResultsCompanion(
      id: Value(id),
      workoutId: workoutId == null && nullToAbsent
          ? const Value.absent()
          : Value(workoutId),
      startedAt: Value(startedAt),
      finishedAt: finishedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(finishedAt),
      status: Value(status),
      doneExercises: Value(doneExercises),
      skippedExercises: Value(skippedExercises),
      pauses: Value(pauses),
      pausedSeconds: Value(pausedSeconds),
      durationSec: Value(durationSec),
      kcal: Value(kcal),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
    );
  }

  factory WorkoutResultsRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkoutResultsRow(
      id: serializer.fromJson<int>(json['id']),
      workoutId: serializer.fromJson<int?>(json['workoutId']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      finishedAt: serializer.fromJson<DateTime?>(json['finishedAt']),
      status: serializer.fromJson<String>(json['status']),
      doneExercises: serializer.fromJson<int>(json['doneExercises']),
      skippedExercises: serializer.fromJson<int>(json['skippedExercises']),
      pauses: serializer.fromJson<int>(json['pauses']),
      pausedSeconds: serializer.fromJson<int>(json['pausedSeconds']),
      durationSec: serializer.fromJson<int>(json['durationSec']),
      kcal: serializer.fromJson<int>(json['kcal']),
      note: serializer.fromJson<String?>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'workoutId': serializer.toJson<int?>(workoutId),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'finishedAt': serializer.toJson<DateTime?>(finishedAt),
      'status': serializer.toJson<String>(status),
      'doneExercises': serializer.toJson<int>(doneExercises),
      'skippedExercises': serializer.toJson<int>(skippedExercises),
      'pauses': serializer.toJson<int>(pauses),
      'pausedSeconds': serializer.toJson<int>(pausedSeconds),
      'durationSec': serializer.toJson<int>(durationSec),
      'kcal': serializer.toJson<int>(kcal),
      'note': serializer.toJson<String?>(note),
    };
  }

  WorkoutResultsRow copyWith({
    int? id,
    Value<int?> workoutId = const Value.absent(),
    DateTime? startedAt,
    Value<DateTime?> finishedAt = const Value.absent(),
    String? status,
    int? doneExercises,
    int? skippedExercises,
    int? pauses,
    int? pausedSeconds,
    int? durationSec,
    int? kcal,
    Value<String?> note = const Value.absent(),
  }) => WorkoutResultsRow(
    id: id ?? this.id,
    workoutId: workoutId.present ? workoutId.value : this.workoutId,
    startedAt: startedAt ?? this.startedAt,
    finishedAt: finishedAt.present ? finishedAt.value : this.finishedAt,
    status: status ?? this.status,
    doneExercises: doneExercises ?? this.doneExercises,
    skippedExercises: skippedExercises ?? this.skippedExercises,
    pauses: pauses ?? this.pauses,
    pausedSeconds: pausedSeconds ?? this.pausedSeconds,
    durationSec: durationSec ?? this.durationSec,
    kcal: kcal ?? this.kcal,
    note: note.present ? note.value : this.note,
  );
  WorkoutResultsRow copyWithCompanion(WorkoutResultsCompanion data) {
    return WorkoutResultsRow(
      id: data.id.present ? data.id.value : this.id,
      workoutId: data.workoutId.present ? data.workoutId.value : this.workoutId,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      finishedAt: data.finishedAt.present
          ? data.finishedAt.value
          : this.finishedAt,
      status: data.status.present ? data.status.value : this.status,
      doneExercises: data.doneExercises.present
          ? data.doneExercises.value
          : this.doneExercises,
      skippedExercises: data.skippedExercises.present
          ? data.skippedExercises.value
          : this.skippedExercises,
      pauses: data.pauses.present ? data.pauses.value : this.pauses,
      pausedSeconds: data.pausedSeconds.present
          ? data.pausedSeconds.value
          : this.pausedSeconds,
      durationSec: data.durationSec.present
          ? data.durationSec.value
          : this.durationSec,
      kcal: data.kcal.present ? data.kcal.value : this.kcal,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutResultsRow(')
          ..write('id: $id, ')
          ..write('workoutId: $workoutId, ')
          ..write('startedAt: $startedAt, ')
          ..write('finishedAt: $finishedAt, ')
          ..write('status: $status, ')
          ..write('doneExercises: $doneExercises, ')
          ..write('skippedExercises: $skippedExercises, ')
          ..write('pauses: $pauses, ')
          ..write('pausedSeconds: $pausedSeconds, ')
          ..write('durationSec: $durationSec, ')
          ..write('kcal: $kcal, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    workoutId,
    startedAt,
    finishedAt,
    status,
    doneExercises,
    skippedExercises,
    pauses,
    pausedSeconds,
    durationSec,
    kcal,
    note,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkoutResultsRow &&
          other.id == this.id &&
          other.workoutId == this.workoutId &&
          other.startedAt == this.startedAt &&
          other.finishedAt == this.finishedAt &&
          other.status == this.status &&
          other.doneExercises == this.doneExercises &&
          other.skippedExercises == this.skippedExercises &&
          other.pauses == this.pauses &&
          other.pausedSeconds == this.pausedSeconds &&
          other.durationSec == this.durationSec &&
          other.kcal == this.kcal &&
          other.note == this.note);
}

class WorkoutResultsCompanion extends UpdateCompanion<WorkoutResultsRow> {
  final Value<int> id;
  final Value<int?> workoutId;
  final Value<DateTime> startedAt;
  final Value<DateTime?> finishedAt;
  final Value<String> status;
  final Value<int> doneExercises;
  final Value<int> skippedExercises;
  final Value<int> pauses;
  final Value<int> pausedSeconds;
  final Value<int> durationSec;
  final Value<int> kcal;
  final Value<String?> note;
  const WorkoutResultsCompanion({
    this.id = const Value.absent(),
    this.workoutId = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.finishedAt = const Value.absent(),
    this.status = const Value.absent(),
    this.doneExercises = const Value.absent(),
    this.skippedExercises = const Value.absent(),
    this.pauses = const Value.absent(),
    this.pausedSeconds = const Value.absent(),
    this.durationSec = const Value.absent(),
    this.kcal = const Value.absent(),
    this.note = const Value.absent(),
  });
  WorkoutResultsCompanion.insert({
    this.id = const Value.absent(),
    this.workoutId = const Value.absent(),
    required DateTime startedAt,
    this.finishedAt = const Value.absent(),
    required String status,
    this.doneExercises = const Value.absent(),
    this.skippedExercises = const Value.absent(),
    this.pauses = const Value.absent(),
    this.pausedSeconds = const Value.absent(),
    this.durationSec = const Value.absent(),
    this.kcal = const Value.absent(),
    this.note = const Value.absent(),
  }) : startedAt = Value(startedAt),
       status = Value(status);
  static Insertable<WorkoutResultsRow> custom({
    Expression<int>? id,
    Expression<int>? workoutId,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? finishedAt,
    Expression<String>? status,
    Expression<int>? doneExercises,
    Expression<int>? skippedExercises,
    Expression<int>? pauses,
    Expression<int>? pausedSeconds,
    Expression<int>? durationSec,
    Expression<int>? kcal,
    Expression<String>? note,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (workoutId != null) 'workout_id': workoutId,
      if (startedAt != null) 'started_at': startedAt,
      if (finishedAt != null) 'finished_at': finishedAt,
      if (status != null) 'status': status,
      if (doneExercises != null) 'done_exercises': doneExercises,
      if (skippedExercises != null) 'skipped_exercises': skippedExercises,
      if (pauses != null) 'pauses': pauses,
      if (pausedSeconds != null) 'paused_seconds': pausedSeconds,
      if (durationSec != null) 'duration_sec': durationSec,
      if (kcal != null) 'kcal': kcal,
      if (note != null) 'note': note,
    });
  }

  WorkoutResultsCompanion copyWith({
    Value<int>? id,
    Value<int?>? workoutId,
    Value<DateTime>? startedAt,
    Value<DateTime?>? finishedAt,
    Value<String>? status,
    Value<int>? doneExercises,
    Value<int>? skippedExercises,
    Value<int>? pauses,
    Value<int>? pausedSeconds,
    Value<int>? durationSec,
    Value<int>? kcal,
    Value<String?>? note,
  }) {
    return WorkoutResultsCompanion(
      id: id ?? this.id,
      workoutId: workoutId ?? this.workoutId,
      startedAt: startedAt ?? this.startedAt,
      finishedAt: finishedAt ?? this.finishedAt,
      status: status ?? this.status,
      doneExercises: doneExercises ?? this.doneExercises,
      skippedExercises: skippedExercises ?? this.skippedExercises,
      pauses: pauses ?? this.pauses,
      pausedSeconds: pausedSeconds ?? this.pausedSeconds,
      durationSec: durationSec ?? this.durationSec,
      kcal: kcal ?? this.kcal,
      note: note ?? this.note,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (workoutId.present) {
      map['workout_id'] = Variable<int>(workoutId.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (finishedAt.present) {
      map['finished_at'] = Variable<DateTime>(finishedAt.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (doneExercises.present) {
      map['done_exercises'] = Variable<int>(doneExercises.value);
    }
    if (skippedExercises.present) {
      map['skipped_exercises'] = Variable<int>(skippedExercises.value);
    }
    if (pauses.present) {
      map['pauses'] = Variable<int>(pauses.value);
    }
    if (pausedSeconds.present) {
      map['paused_seconds'] = Variable<int>(pausedSeconds.value);
    }
    if (durationSec.present) {
      map['duration_sec'] = Variable<int>(durationSec.value);
    }
    if (kcal.present) {
      map['kcal'] = Variable<int>(kcal.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutResultsCompanion(')
          ..write('id: $id, ')
          ..write('workoutId: $workoutId, ')
          ..write('startedAt: $startedAt, ')
          ..write('finishedAt: $finishedAt, ')
          ..write('status: $status, ')
          ..write('doneExercises: $doneExercises, ')
          ..write('skippedExercises: $skippedExercises, ')
          ..write('pauses: $pauses, ')
          ..write('pausedSeconds: $pausedSeconds, ')
          ..write('durationSec: $durationSec, ')
          ..write('kcal: $kcal, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }
}

class $NotificationScheduleTable extends NotificationSchedule
    with TableInfo<$NotificationScheduleTable, NotificationScheduleRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NotificationScheduleTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _minuteOfDayMeta = const VerificationMeta(
    'minuteOfDay',
  );
  @override
  late final GeneratedColumn<int> minuteOfDay = GeneratedColumn<int>(
    'minute_of_day',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weekdaysMaskMeta = const VerificationMeta(
    'weekdaysMask',
  );
  @override
  late final GeneratedColumn<int> weekdaysMask = GeneratedColumn<int>(
    'weekdays_mask',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(127),
  );
  static const VerificationMeta _oneOffAtMeta = const VerificationMeta(
    'oneOffAt',
  );
  @override
  late final GeneratedColumn<DateTime> oneOffAt = GeneratedColumn<DateTime>(
    'one_off_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _enabledMeta = const VerificationMeta(
    'enabled',
  );
  @override
  late final GeneratedColumn<bool> enabled = GeneratedColumn<bool>(
    'enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('fitty'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    kind,
    title,
    body,
    minuteOfDay,
    weekdaysMask,
    oneOffAt,
    enabled,
    createdBy,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'notification_schedule';
  @override
  VerificationContext validateIntegrity(
    Insertable<NotificationScheduleRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    }
    if (data.containsKey('minute_of_day')) {
      context.handle(
        _minuteOfDayMeta,
        minuteOfDay.isAcceptableOrUnknown(
          data['minute_of_day']!,
          _minuteOfDayMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_minuteOfDayMeta);
    }
    if (data.containsKey('weekdays_mask')) {
      context.handle(
        _weekdaysMaskMeta,
        weekdaysMask.isAcceptableOrUnknown(
          data['weekdays_mask']!,
          _weekdaysMaskMeta,
        ),
      );
    }
    if (data.containsKey('one_off_at')) {
      context.handle(
        _oneOffAtMeta,
        oneOffAt.isAcceptableOrUnknown(data['one_off_at']!, _oneOffAtMeta),
      );
    }
    if (data.containsKey('enabled')) {
      context.handle(
        _enabledMeta,
        enabled.isAcceptableOrUnknown(data['enabled']!, _enabledMeta),
      );
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
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
  NotificationScheduleRow map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NotificationScheduleRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
      minuteOfDay: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}minute_of_day'],
      )!,
      weekdaysMask: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}weekdays_mask'],
      )!,
      oneOffAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}one_off_at'],
      ),
      enabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}enabled'],
      )!,
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $NotificationScheduleTable createAlias(String alias) {
    return $NotificationScheduleTable(attachedDatabase, alias);
  }
}

class NotificationScheduleRow extends DataClass
    implements Insertable<NotificationScheduleRow> {
  final int id;

  /// meal | water | workout | weigh_in | custom
  final String kind;
  final String title;
  final String body;

  /// Минуты от полуночи (локальное время).
  final int minuteOfDay;

  /// Битовая маска дней недели (bit0 = Пн … bit6 = Вс); 127 = каждый день.
  final int weekdaysMask;
  final DateTime? oneOffAt;
  final bool enabled;

  /// user | fitty
  final String createdBy;
  final DateTime createdAt;
  const NotificationScheduleRow({
    required this.id,
    required this.kind,
    required this.title,
    required this.body,
    required this.minuteOfDay,
    required this.weekdaysMask,
    this.oneOffAt,
    required this.enabled,
    required this.createdBy,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['kind'] = Variable<String>(kind);
    map['title'] = Variable<String>(title);
    map['body'] = Variable<String>(body);
    map['minute_of_day'] = Variable<int>(minuteOfDay);
    map['weekdays_mask'] = Variable<int>(weekdaysMask);
    if (!nullToAbsent || oneOffAt != null) {
      map['one_off_at'] = Variable<DateTime>(oneOffAt);
    }
    map['enabled'] = Variable<bool>(enabled);
    map['created_by'] = Variable<String>(createdBy);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  NotificationScheduleCompanion toCompanion(bool nullToAbsent) {
    return NotificationScheduleCompanion(
      id: Value(id),
      kind: Value(kind),
      title: Value(title),
      body: Value(body),
      minuteOfDay: Value(minuteOfDay),
      weekdaysMask: Value(weekdaysMask),
      oneOffAt: oneOffAt == null && nullToAbsent
          ? const Value.absent()
          : Value(oneOffAt),
      enabled: Value(enabled),
      createdBy: Value(createdBy),
      createdAt: Value(createdAt),
    );
  }

  factory NotificationScheduleRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NotificationScheduleRow(
      id: serializer.fromJson<int>(json['id']),
      kind: serializer.fromJson<String>(json['kind']),
      title: serializer.fromJson<String>(json['title']),
      body: serializer.fromJson<String>(json['body']),
      minuteOfDay: serializer.fromJson<int>(json['minuteOfDay']),
      weekdaysMask: serializer.fromJson<int>(json['weekdaysMask']),
      oneOffAt: serializer.fromJson<DateTime?>(json['oneOffAt']),
      enabled: serializer.fromJson<bool>(json['enabled']),
      createdBy: serializer.fromJson<String>(json['createdBy']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'kind': serializer.toJson<String>(kind),
      'title': serializer.toJson<String>(title),
      'body': serializer.toJson<String>(body),
      'minuteOfDay': serializer.toJson<int>(minuteOfDay),
      'weekdaysMask': serializer.toJson<int>(weekdaysMask),
      'oneOffAt': serializer.toJson<DateTime?>(oneOffAt),
      'enabled': serializer.toJson<bool>(enabled),
      'createdBy': serializer.toJson<String>(createdBy),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  NotificationScheduleRow copyWith({
    int? id,
    String? kind,
    String? title,
    String? body,
    int? minuteOfDay,
    int? weekdaysMask,
    Value<DateTime?> oneOffAt = const Value.absent(),
    bool? enabled,
    String? createdBy,
    DateTime? createdAt,
  }) => NotificationScheduleRow(
    id: id ?? this.id,
    kind: kind ?? this.kind,
    title: title ?? this.title,
    body: body ?? this.body,
    minuteOfDay: minuteOfDay ?? this.minuteOfDay,
    weekdaysMask: weekdaysMask ?? this.weekdaysMask,
    oneOffAt: oneOffAt.present ? oneOffAt.value : this.oneOffAt,
    enabled: enabled ?? this.enabled,
    createdBy: createdBy ?? this.createdBy,
    createdAt: createdAt ?? this.createdAt,
  );
  NotificationScheduleRow copyWithCompanion(
    NotificationScheduleCompanion data,
  ) {
    return NotificationScheduleRow(
      id: data.id.present ? data.id.value : this.id,
      kind: data.kind.present ? data.kind.value : this.kind,
      title: data.title.present ? data.title.value : this.title,
      body: data.body.present ? data.body.value : this.body,
      minuteOfDay: data.minuteOfDay.present
          ? data.minuteOfDay.value
          : this.minuteOfDay,
      weekdaysMask: data.weekdaysMask.present
          ? data.weekdaysMask.value
          : this.weekdaysMask,
      oneOffAt: data.oneOffAt.present ? data.oneOffAt.value : this.oneOffAt,
      enabled: data.enabled.present ? data.enabled.value : this.enabled,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NotificationScheduleRow(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('minuteOfDay: $minuteOfDay, ')
          ..write('weekdaysMask: $weekdaysMask, ')
          ..write('oneOffAt: $oneOffAt, ')
          ..write('enabled: $enabled, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    kind,
    title,
    body,
    minuteOfDay,
    weekdaysMask,
    oneOffAt,
    enabled,
    createdBy,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NotificationScheduleRow &&
          other.id == this.id &&
          other.kind == this.kind &&
          other.title == this.title &&
          other.body == this.body &&
          other.minuteOfDay == this.minuteOfDay &&
          other.weekdaysMask == this.weekdaysMask &&
          other.oneOffAt == this.oneOffAt &&
          other.enabled == this.enabled &&
          other.createdBy == this.createdBy &&
          other.createdAt == this.createdAt);
}

class NotificationScheduleCompanion
    extends UpdateCompanion<NotificationScheduleRow> {
  final Value<int> id;
  final Value<String> kind;
  final Value<String> title;
  final Value<String> body;
  final Value<int> minuteOfDay;
  final Value<int> weekdaysMask;
  final Value<DateTime?> oneOffAt;
  final Value<bool> enabled;
  final Value<String> createdBy;
  final Value<DateTime> createdAt;
  const NotificationScheduleCompanion({
    this.id = const Value.absent(),
    this.kind = const Value.absent(),
    this.title = const Value.absent(),
    this.body = const Value.absent(),
    this.minuteOfDay = const Value.absent(),
    this.weekdaysMask = const Value.absent(),
    this.oneOffAt = const Value.absent(),
    this.enabled = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  NotificationScheduleCompanion.insert({
    this.id = const Value.absent(),
    required String kind,
    required String title,
    this.body = const Value.absent(),
    required int minuteOfDay,
    this.weekdaysMask = const Value.absent(),
    this.oneOffAt = const Value.absent(),
    this.enabled = const Value.absent(),
    this.createdBy = const Value.absent(),
    required DateTime createdAt,
  }) : kind = Value(kind),
       title = Value(title),
       minuteOfDay = Value(minuteOfDay),
       createdAt = Value(createdAt);
  static Insertable<NotificationScheduleRow> custom({
    Expression<int>? id,
    Expression<String>? kind,
    Expression<String>? title,
    Expression<String>? body,
    Expression<int>? minuteOfDay,
    Expression<int>? weekdaysMask,
    Expression<DateTime>? oneOffAt,
    Expression<bool>? enabled,
    Expression<String>? createdBy,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (kind != null) 'kind': kind,
      if (title != null) 'title': title,
      if (body != null) 'body': body,
      if (minuteOfDay != null) 'minute_of_day': minuteOfDay,
      if (weekdaysMask != null) 'weekdays_mask': weekdaysMask,
      if (oneOffAt != null) 'one_off_at': oneOffAt,
      if (enabled != null) 'enabled': enabled,
      if (createdBy != null) 'created_by': createdBy,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  NotificationScheduleCompanion copyWith({
    Value<int>? id,
    Value<String>? kind,
    Value<String>? title,
    Value<String>? body,
    Value<int>? minuteOfDay,
    Value<int>? weekdaysMask,
    Value<DateTime?>? oneOffAt,
    Value<bool>? enabled,
    Value<String>? createdBy,
    Value<DateTime>? createdAt,
  }) {
    return NotificationScheduleCompanion(
      id: id ?? this.id,
      kind: kind ?? this.kind,
      title: title ?? this.title,
      body: body ?? this.body,
      minuteOfDay: minuteOfDay ?? this.minuteOfDay,
      weekdaysMask: weekdaysMask ?? this.weekdaysMask,
      oneOffAt: oneOffAt ?? this.oneOffAt,
      enabled: enabled ?? this.enabled,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (minuteOfDay.present) {
      map['minute_of_day'] = Variable<int>(minuteOfDay.value);
    }
    if (weekdaysMask.present) {
      map['weekdays_mask'] = Variable<int>(weekdaysMask.value);
    }
    if (oneOffAt.present) {
      map['one_off_at'] = Variable<DateTime>(oneOffAt.value);
    }
    if (enabled.present) {
      map['enabled'] = Variable<bool>(enabled.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NotificationScheduleCompanion(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('minuteOfDay: $minuteOfDay, ')
          ..write('weekdaysMask: $weekdaysMask, ')
          ..write('oneOffAt: $oneOffAt, ')
          ..write('enabled: $enabled, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $MessagesTable extends Messages
    with TableInfo<$MessagesTable, MessagesRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MessagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('chat'),
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _imagesJsonMeta = const VerificationMeta(
    'imagesJson',
  );
  @override
  late final GeneratedColumn<String> imagesJson = GeneratedColumn<String>(
    'images_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _audioPathMeta = const VerificationMeta(
    'audioPath',
  );
  @override
  late final GeneratedColumn<String> audioPath = GeneratedColumn<String>(
    'audio_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _audioMsMeta = const VerificationMeta(
    'audioMs',
  );
  @override
  late final GeneratedColumn<int> audioMs = GeneratedColumn<int>(
    'audio_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _waveformJsonMeta = const VerificationMeta(
    'waveformJson',
  );
  @override
  late final GeneratedColumn<String> waveformJson = GeneratedColumn<String>(
    'waveform_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _summaryIdMeta = const VerificationMeta(
    'summaryId',
  );
  @override
  late final GeneratedColumn<int> summaryId = GeneratedColumn<int>(
    'summary_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    role,
    kind,
    body,
    imagesJson,
    audioPath,
    audioMs,
    waveformJson,
    createdAt,
    summaryId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'messages';
  @override
  VerificationContext validateIntegrity(
    Insertable<MessagesRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    }
    if (data.containsKey('images_json')) {
      context.handle(
        _imagesJsonMeta,
        imagesJson.isAcceptableOrUnknown(data['images_json']!, _imagesJsonMeta),
      );
    }
    if (data.containsKey('audio_path')) {
      context.handle(
        _audioPathMeta,
        audioPath.isAcceptableOrUnknown(data['audio_path']!, _audioPathMeta),
      );
    }
    if (data.containsKey('audio_ms')) {
      context.handle(
        _audioMsMeta,
        audioMs.isAcceptableOrUnknown(data['audio_ms']!, _audioMsMeta),
      );
    }
    if (data.containsKey('waveform_json')) {
      context.handle(
        _waveformJsonMeta,
        waveformJson.isAcceptableOrUnknown(
          data['waveform_json']!,
          _waveformJsonMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('summary_id')) {
      context.handle(
        _summaryIdMeta,
        summaryId.isAcceptableOrUnknown(data['summary_id']!, _summaryIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MessagesRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MessagesRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
      imagesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}images_json'],
      )!,
      audioPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}audio_path'],
      ),
      audioMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}audio_ms'],
      )!,
      waveformJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}waveform_json'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      summaryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}summary_id'],
      ),
    );
  }

  @override
  $MessagesTable createAlias(String alias) {
    return $MessagesTable(attachedDatabase, alias);
  }
}

class MessagesRow extends DataClass implements Insertable<MessagesRow> {
  final int id;

  /// 'user' | 'fitty'
  final String role;

  /// 'chat' | 'notice' (служебные сообщения не попадают в контекст модели)
  final String kind;
  final String body;
  final String imagesJson;
  final String? audioPath;
  final int audioMs;
  final String waveformJson;
  final DateTime createdAt;

  /// Если сообщение уже сжато в резюме — id резюме.
  final int? summaryId;
  const MessagesRow({
    required this.id,
    required this.role,
    required this.kind,
    required this.body,
    required this.imagesJson,
    this.audioPath,
    required this.audioMs,
    required this.waveformJson,
    required this.createdAt,
    this.summaryId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['role'] = Variable<String>(role);
    map['kind'] = Variable<String>(kind);
    map['body'] = Variable<String>(body);
    map['images_json'] = Variable<String>(imagesJson);
    if (!nullToAbsent || audioPath != null) {
      map['audio_path'] = Variable<String>(audioPath);
    }
    map['audio_ms'] = Variable<int>(audioMs);
    map['waveform_json'] = Variable<String>(waveformJson);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || summaryId != null) {
      map['summary_id'] = Variable<int>(summaryId);
    }
    return map;
  }

  MessagesCompanion toCompanion(bool nullToAbsent) {
    return MessagesCompanion(
      id: Value(id),
      role: Value(role),
      kind: Value(kind),
      body: Value(body),
      imagesJson: Value(imagesJson),
      audioPath: audioPath == null && nullToAbsent
          ? const Value.absent()
          : Value(audioPath),
      audioMs: Value(audioMs),
      waveformJson: Value(waveformJson),
      createdAt: Value(createdAt),
      summaryId: summaryId == null && nullToAbsent
          ? const Value.absent()
          : Value(summaryId),
    );
  }

  factory MessagesRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MessagesRow(
      id: serializer.fromJson<int>(json['id']),
      role: serializer.fromJson<String>(json['role']),
      kind: serializer.fromJson<String>(json['kind']),
      body: serializer.fromJson<String>(json['body']),
      imagesJson: serializer.fromJson<String>(json['imagesJson']),
      audioPath: serializer.fromJson<String?>(json['audioPath']),
      audioMs: serializer.fromJson<int>(json['audioMs']),
      waveformJson: serializer.fromJson<String>(json['waveformJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      summaryId: serializer.fromJson<int?>(json['summaryId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'role': serializer.toJson<String>(role),
      'kind': serializer.toJson<String>(kind),
      'body': serializer.toJson<String>(body),
      'imagesJson': serializer.toJson<String>(imagesJson),
      'audioPath': serializer.toJson<String?>(audioPath),
      'audioMs': serializer.toJson<int>(audioMs),
      'waveformJson': serializer.toJson<String>(waveformJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'summaryId': serializer.toJson<int?>(summaryId),
    };
  }

  MessagesRow copyWith({
    int? id,
    String? role,
    String? kind,
    String? body,
    String? imagesJson,
    Value<String?> audioPath = const Value.absent(),
    int? audioMs,
    String? waveformJson,
    DateTime? createdAt,
    Value<int?> summaryId = const Value.absent(),
  }) => MessagesRow(
    id: id ?? this.id,
    role: role ?? this.role,
    kind: kind ?? this.kind,
    body: body ?? this.body,
    imagesJson: imagesJson ?? this.imagesJson,
    audioPath: audioPath.present ? audioPath.value : this.audioPath,
    audioMs: audioMs ?? this.audioMs,
    waveformJson: waveformJson ?? this.waveformJson,
    createdAt: createdAt ?? this.createdAt,
    summaryId: summaryId.present ? summaryId.value : this.summaryId,
  );
  MessagesRow copyWithCompanion(MessagesCompanion data) {
    return MessagesRow(
      id: data.id.present ? data.id.value : this.id,
      role: data.role.present ? data.role.value : this.role,
      kind: data.kind.present ? data.kind.value : this.kind,
      body: data.body.present ? data.body.value : this.body,
      imagesJson: data.imagesJson.present
          ? data.imagesJson.value
          : this.imagesJson,
      audioPath: data.audioPath.present ? data.audioPath.value : this.audioPath,
      audioMs: data.audioMs.present ? data.audioMs.value : this.audioMs,
      waveformJson: data.waveformJson.present
          ? data.waveformJson.value
          : this.waveformJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      summaryId: data.summaryId.present ? data.summaryId.value : this.summaryId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MessagesRow(')
          ..write('id: $id, ')
          ..write('role: $role, ')
          ..write('kind: $kind, ')
          ..write('body: $body, ')
          ..write('imagesJson: $imagesJson, ')
          ..write('audioPath: $audioPath, ')
          ..write('audioMs: $audioMs, ')
          ..write('waveformJson: $waveformJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('summaryId: $summaryId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    role,
    kind,
    body,
    imagesJson,
    audioPath,
    audioMs,
    waveformJson,
    createdAt,
    summaryId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MessagesRow &&
          other.id == this.id &&
          other.role == this.role &&
          other.kind == this.kind &&
          other.body == this.body &&
          other.imagesJson == this.imagesJson &&
          other.audioPath == this.audioPath &&
          other.audioMs == this.audioMs &&
          other.waveformJson == this.waveformJson &&
          other.createdAt == this.createdAt &&
          other.summaryId == this.summaryId);
}

class MessagesCompanion extends UpdateCompanion<MessagesRow> {
  final Value<int> id;
  final Value<String> role;
  final Value<String> kind;
  final Value<String> body;
  final Value<String> imagesJson;
  final Value<String?> audioPath;
  final Value<int> audioMs;
  final Value<String> waveformJson;
  final Value<DateTime> createdAt;
  final Value<int?> summaryId;
  const MessagesCompanion({
    this.id = const Value.absent(),
    this.role = const Value.absent(),
    this.kind = const Value.absent(),
    this.body = const Value.absent(),
    this.imagesJson = const Value.absent(),
    this.audioPath = const Value.absent(),
    this.audioMs = const Value.absent(),
    this.waveformJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.summaryId = const Value.absent(),
  });
  MessagesCompanion.insert({
    this.id = const Value.absent(),
    required String role,
    this.kind = const Value.absent(),
    this.body = const Value.absent(),
    this.imagesJson = const Value.absent(),
    this.audioPath = const Value.absent(),
    this.audioMs = const Value.absent(),
    this.waveformJson = const Value.absent(),
    required DateTime createdAt,
    this.summaryId = const Value.absent(),
  }) : role = Value(role),
       createdAt = Value(createdAt);
  static Insertable<MessagesRow> custom({
    Expression<int>? id,
    Expression<String>? role,
    Expression<String>? kind,
    Expression<String>? body,
    Expression<String>? imagesJson,
    Expression<String>? audioPath,
    Expression<int>? audioMs,
    Expression<String>? waveformJson,
    Expression<DateTime>? createdAt,
    Expression<int>? summaryId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (role != null) 'role': role,
      if (kind != null) 'kind': kind,
      if (body != null) 'body': body,
      if (imagesJson != null) 'images_json': imagesJson,
      if (audioPath != null) 'audio_path': audioPath,
      if (audioMs != null) 'audio_ms': audioMs,
      if (waveformJson != null) 'waveform_json': waveformJson,
      if (createdAt != null) 'created_at': createdAt,
      if (summaryId != null) 'summary_id': summaryId,
    });
  }

  MessagesCompanion copyWith({
    Value<int>? id,
    Value<String>? role,
    Value<String>? kind,
    Value<String>? body,
    Value<String>? imagesJson,
    Value<String?>? audioPath,
    Value<int>? audioMs,
    Value<String>? waveformJson,
    Value<DateTime>? createdAt,
    Value<int?>? summaryId,
  }) {
    return MessagesCompanion(
      id: id ?? this.id,
      role: role ?? this.role,
      kind: kind ?? this.kind,
      body: body ?? this.body,
      imagesJson: imagesJson ?? this.imagesJson,
      audioPath: audioPath ?? this.audioPath,
      audioMs: audioMs ?? this.audioMs,
      waveformJson: waveformJson ?? this.waveformJson,
      createdAt: createdAt ?? this.createdAt,
      summaryId: summaryId ?? this.summaryId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (imagesJson.present) {
      map['images_json'] = Variable<String>(imagesJson.value);
    }
    if (audioPath.present) {
      map['audio_path'] = Variable<String>(audioPath.value);
    }
    if (audioMs.present) {
      map['audio_ms'] = Variable<int>(audioMs.value);
    }
    if (waveformJson.present) {
      map['waveform_json'] = Variable<String>(waveformJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (summaryId.present) {
      map['summary_id'] = Variable<int>(summaryId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MessagesCompanion(')
          ..write('id: $id, ')
          ..write('role: $role, ')
          ..write('kind: $kind, ')
          ..write('body: $body, ')
          ..write('imagesJson: $imagesJson, ')
          ..write('audioPath: $audioPath, ')
          ..write('audioMs: $audioMs, ')
          ..write('waveformJson: $waveformJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('summaryId: $summaryId')
          ..write(')'))
        .toString();
  }
}

class $ConversationSummariesTable extends ConversationSummaries
    with TableInfo<$ConversationSummariesTable, ConversationSummariesRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ConversationSummariesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fromTimeMeta = const VerificationMeta(
    'fromTime',
  );
  @override
  late final GeneratedColumn<DateTime> fromTime = GeneratedColumn<DateTime>(
    'from_time',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _toTimeMeta = const VerificationMeta('toTime');
  @override
  late final GeneratedColumn<DateTime> toTime = GeneratedColumn<DateTime>(
    'to_time',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _messageCountMeta = const VerificationMeta(
    'messageCount',
  );
  @override
  late final GeneratedColumn<int> messageCount = GeneratedColumn<int>(
    'message_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    fromTime,
    toTime,
    body,
    messageCount,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'conversation_summaries';
  @override
  VerificationContext validateIntegrity(
    Insertable<ConversationSummariesRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('from_time')) {
      context.handle(
        _fromTimeMeta,
        fromTime.isAcceptableOrUnknown(data['from_time']!, _fromTimeMeta),
      );
    } else if (isInserting) {
      context.missing(_fromTimeMeta);
    }
    if (data.containsKey('to_time')) {
      context.handle(
        _toTimeMeta,
        toTime.isAcceptableOrUnknown(data['to_time']!, _toTimeMeta),
      );
    } else if (isInserting) {
      context.missing(_toTimeMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('message_count')) {
      context.handle(
        _messageCountMeta,
        messageCount.isAcceptableOrUnknown(
          data['message_count']!,
          _messageCountMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ConversationSummariesRow map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ConversationSummariesRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      fromTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}from_time'],
      )!,
      toTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}to_time'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
      messageCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}message_count'],
      )!,
    );
  }

  @override
  $ConversationSummariesTable createAlias(String alias) {
    return $ConversationSummariesTable(attachedDatabase, alias);
  }
}

class ConversationSummariesRow extends DataClass
    implements Insertable<ConversationSummariesRow> {
  final int id;
  final DateTime createdAt;
  final DateTime fromTime;
  final DateTime toTime;
  final String body;
  final int messageCount;
  const ConversationSummariesRow({
    required this.id,
    required this.createdAt,
    required this.fromTime,
    required this.toTime,
    required this.body,
    required this.messageCount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['from_time'] = Variable<DateTime>(fromTime);
    map['to_time'] = Variable<DateTime>(toTime);
    map['body'] = Variable<String>(body);
    map['message_count'] = Variable<int>(messageCount);
    return map;
  }

  ConversationSummariesCompanion toCompanion(bool nullToAbsent) {
    return ConversationSummariesCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      fromTime: Value(fromTime),
      toTime: Value(toTime),
      body: Value(body),
      messageCount: Value(messageCount),
    );
  }

  factory ConversationSummariesRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ConversationSummariesRow(
      id: serializer.fromJson<int>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      fromTime: serializer.fromJson<DateTime>(json['fromTime']),
      toTime: serializer.fromJson<DateTime>(json['toTime']),
      body: serializer.fromJson<String>(json['body']),
      messageCount: serializer.fromJson<int>(json['messageCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'fromTime': serializer.toJson<DateTime>(fromTime),
      'toTime': serializer.toJson<DateTime>(toTime),
      'body': serializer.toJson<String>(body),
      'messageCount': serializer.toJson<int>(messageCount),
    };
  }

  ConversationSummariesRow copyWith({
    int? id,
    DateTime? createdAt,
    DateTime? fromTime,
    DateTime? toTime,
    String? body,
    int? messageCount,
  }) => ConversationSummariesRow(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    fromTime: fromTime ?? this.fromTime,
    toTime: toTime ?? this.toTime,
    body: body ?? this.body,
    messageCount: messageCount ?? this.messageCount,
  );
  ConversationSummariesRow copyWithCompanion(
    ConversationSummariesCompanion data,
  ) {
    return ConversationSummariesRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      fromTime: data.fromTime.present ? data.fromTime.value : this.fromTime,
      toTime: data.toTime.present ? data.toTime.value : this.toTime,
      body: data.body.present ? data.body.value : this.body,
      messageCount: data.messageCount.present
          ? data.messageCount.value
          : this.messageCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ConversationSummariesRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('fromTime: $fromTime, ')
          ..write('toTime: $toTime, ')
          ..write('body: $body, ')
          ..write('messageCount: $messageCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, createdAt, fromTime, toTime, body, messageCount);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ConversationSummariesRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.fromTime == this.fromTime &&
          other.toTime == this.toTime &&
          other.body == this.body &&
          other.messageCount == this.messageCount);
}

class ConversationSummariesCompanion
    extends UpdateCompanion<ConversationSummariesRow> {
  final Value<int> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> fromTime;
  final Value<DateTime> toTime;
  final Value<String> body;
  final Value<int> messageCount;
  const ConversationSummariesCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.fromTime = const Value.absent(),
    this.toTime = const Value.absent(),
    this.body = const Value.absent(),
    this.messageCount = const Value.absent(),
  });
  ConversationSummariesCompanion.insert({
    this.id = const Value.absent(),
    required DateTime createdAt,
    required DateTime fromTime,
    required DateTime toTime,
    required String body,
    this.messageCount = const Value.absent(),
  }) : createdAt = Value(createdAt),
       fromTime = Value(fromTime),
       toTime = Value(toTime),
       body = Value(body);
  static Insertable<ConversationSummariesRow> custom({
    Expression<int>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? fromTime,
    Expression<DateTime>? toTime,
    Expression<String>? body,
    Expression<int>? messageCount,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (fromTime != null) 'from_time': fromTime,
      if (toTime != null) 'to_time': toTime,
      if (body != null) 'body': body,
      if (messageCount != null) 'message_count': messageCount,
    });
  }

  ConversationSummariesCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? fromTime,
    Value<DateTime>? toTime,
    Value<String>? body,
    Value<int>? messageCount,
  }) {
    return ConversationSummariesCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      fromTime: fromTime ?? this.fromTime,
      toTime: toTime ?? this.toTime,
      body: body ?? this.body,
      messageCount: messageCount ?? this.messageCount,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (fromTime.present) {
      map['from_time'] = Variable<DateTime>(fromTime.value);
    }
    if (toTime.present) {
      map['to_time'] = Variable<DateTime>(toTime.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (messageCount.present) {
      map['message_count'] = Variable<int>(messageCount.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ConversationSummariesCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('fromTime: $fromTime, ')
          ..write('toTime: $toTime, ')
          ..write('body: $body, ')
          ..write('messageCount: $messageCount')
          ..write(')'))
        .toString();
  }
}

class $ApiUsageTable extends ApiUsage
    with TableInfo<$ApiUsageTable, ApiUsageRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ApiUsageTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dayMeta = const VerificationMeta('day');
  @override
  late final GeneratedColumn<String> day = GeneratedColumn<String>(
    'day',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modelMeta = const VerificationMeta('model');
  @override
  late final GeneratedColumn<String> model = GeneratedColumn<String>(
    'model',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _countMeta = const VerificationMeta('count');
  @override
  late final GeneratedColumn<int> count = GeneratedColumn<int>(
    'count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [day, model, count];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'api_usage';
  @override
  VerificationContext validateIntegrity(
    Insertable<ApiUsageRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('day')) {
      context.handle(
        _dayMeta,
        day.isAcceptableOrUnknown(data['day']!, _dayMeta),
      );
    } else if (isInserting) {
      context.missing(_dayMeta);
    }
    if (data.containsKey('model')) {
      context.handle(
        _modelMeta,
        model.isAcceptableOrUnknown(data['model']!, _modelMeta),
      );
    } else if (isInserting) {
      context.missing(_modelMeta);
    }
    if (data.containsKey('count')) {
      context.handle(
        _countMeta,
        count.isAcceptableOrUnknown(data['count']!, _countMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {day, model};
  @override
  ApiUsageRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ApiUsageRow(
      day: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}day'],
      )!,
      model: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model'],
      )!,
      count: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}count'],
      )!,
    );
  }

  @override
  $ApiUsageTable createAlias(String alias) {
    return $ApiUsageTable(attachedDatabase, alias);
  }
}

class ApiUsageRow extends DataClass implements Insertable<ApiUsageRow> {
  final String day;
  final String model;
  final int count;
  const ApiUsageRow({
    required this.day,
    required this.model,
    required this.count,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['day'] = Variable<String>(day);
    map['model'] = Variable<String>(model);
    map['count'] = Variable<int>(count);
    return map;
  }

  ApiUsageCompanion toCompanion(bool nullToAbsent) {
    return ApiUsageCompanion(
      day: Value(day),
      model: Value(model),
      count: Value(count),
    );
  }

  factory ApiUsageRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ApiUsageRow(
      day: serializer.fromJson<String>(json['day']),
      model: serializer.fromJson<String>(json['model']),
      count: serializer.fromJson<int>(json['count']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'day': serializer.toJson<String>(day),
      'model': serializer.toJson<String>(model),
      'count': serializer.toJson<int>(count),
    };
  }

  ApiUsageRow copyWith({String? day, String? model, int? count}) => ApiUsageRow(
    day: day ?? this.day,
    model: model ?? this.model,
    count: count ?? this.count,
  );
  ApiUsageRow copyWithCompanion(ApiUsageCompanion data) {
    return ApiUsageRow(
      day: data.day.present ? data.day.value : this.day,
      model: data.model.present ? data.model.value : this.model,
      count: data.count.present ? data.count.value : this.count,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ApiUsageRow(')
          ..write('day: $day, ')
          ..write('model: $model, ')
          ..write('count: $count')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(day, model, count);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ApiUsageRow &&
          other.day == this.day &&
          other.model == this.model &&
          other.count == this.count);
}

class ApiUsageCompanion extends UpdateCompanion<ApiUsageRow> {
  final Value<String> day;
  final Value<String> model;
  final Value<int> count;
  final Value<int> rowid;
  const ApiUsageCompanion({
    this.day = const Value.absent(),
    this.model = const Value.absent(),
    this.count = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ApiUsageCompanion.insert({
    required String day,
    required String model,
    this.count = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : day = Value(day),
       model = Value(model);
  static Insertable<ApiUsageRow> custom({
    Expression<String>? day,
    Expression<String>? model,
    Expression<int>? count,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (day != null) 'day': day,
      if (model != null) 'model': model,
      if (count != null) 'count': count,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ApiUsageCompanion copyWith({
    Value<String>? day,
    Value<String>? model,
    Value<int>? count,
    Value<int>? rowid,
  }) {
    return ApiUsageCompanion(
      day: day ?? this.day,
      model: model ?? this.model,
      count: count ?? this.count,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (day.present) {
      map['day'] = Variable<String>(day.value);
    }
    if (model.present) {
      map['model'] = Variable<String>(model.value);
    }
    if (count.present) {
      map['count'] = Variable<int>(count.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ApiUsageCompanion(')
          ..write('day: $day, ')
          ..write('model: $model, ')
          ..write('count: $count, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ProfilesTable profiles = $ProfilesTable(this);
  late final $ProfileHistoryTable profileHistory = $ProfileHistoryTable(this);
  late final $GoalsTable goals = $GoalsTable(this);
  late final $MemoryFactsTable memoryFacts = $MemoryFactsTable(this);
  late final $DietPlansTable dietPlans = $DietPlansTable(this);
  late final $DiaryEntriesTable diaryEntries = $DiaryEntriesTable(this);
  late final $WorkoutsTable workouts = $WorkoutsTable(this);
  late final $WorkoutResultsTable workoutResults = $WorkoutResultsTable(this);
  late final $NotificationScheduleTable notificationSchedule =
      $NotificationScheduleTable(this);
  late final $MessagesTable messages = $MessagesTable(this);
  late final $ConversationSummariesTable conversationSummaries =
      $ConversationSummariesTable(this);
  late final $ApiUsageTable apiUsage = $ApiUsageTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    profiles,
    profileHistory,
    goals,
    memoryFacts,
    dietPlans,
    diaryEntries,
    workouts,
    workoutResults,
    notificationSchedule,
    messages,
    conversationSummaries,
    apiUsage,
  ];
}

typedef $$ProfilesTableCreateCompanionBuilder =
    ProfilesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> sex,
      Value<int> birthYear,
      Value<double> heightCm,
      Value<double> weightKg,
      Value<double> targetWeightKg,
      Value<double?> waistCm,
      Value<double?> chestCm,
      Value<double?> hipsCm,
      Value<int> trainingMinutes,
      Value<String> trainingSlot,
      Value<bool> onboardingDone,
      required DateTime createdAt,
      required DateTime updatedAt,
    });
typedef $$ProfilesTableUpdateCompanionBuilder =
    ProfilesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> sex,
      Value<int> birthYear,
      Value<double> heightCm,
      Value<double> weightKg,
      Value<double> targetWeightKg,
      Value<double?> waistCm,
      Value<double?> chestCm,
      Value<double?> hipsCm,
      Value<int> trainingMinutes,
      Value<String> trainingSlot,
      Value<bool> onboardingDone,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

class $$ProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sex => $composableBuilder(
    column: $table.sex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get birthYear => $composableBuilder(
    column: $table.birthYear,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get heightCm => $composableBuilder(
    column: $table.heightCm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get targetWeightKg => $composableBuilder(
    column: $table.targetWeightKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get waistCm => $composableBuilder(
    column: $table.waistCm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get chestCm => $composableBuilder(
    column: $table.chestCm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get hipsCm => $composableBuilder(
    column: $table.hipsCm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get trainingMinutes => $composableBuilder(
    column: $table.trainingMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get trainingSlot => $composableBuilder(
    column: $table.trainingSlot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get onboardingDone => $composableBuilder(
    column: $table.onboardingDone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sex => $composableBuilder(
    column: $table.sex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get birthYear => $composableBuilder(
    column: $table.birthYear,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get heightCm => $composableBuilder(
    column: $table.heightCm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get targetWeightKg => $composableBuilder(
    column: $table.targetWeightKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get waistCm => $composableBuilder(
    column: $table.waistCm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get chestCm => $composableBuilder(
    column: $table.chestCm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get hipsCm => $composableBuilder(
    column: $table.hipsCm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get trainingMinutes => $composableBuilder(
    column: $table.trainingMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get trainingSlot => $composableBuilder(
    column: $table.trainingSlot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get onboardingDone => $composableBuilder(
    column: $table.onboardingDone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get sex =>
      $composableBuilder(column: $table.sex, builder: (column) => column);

  GeneratedColumn<int> get birthYear =>
      $composableBuilder(column: $table.birthYear, builder: (column) => column);

  GeneratedColumn<double> get heightCm =>
      $composableBuilder(column: $table.heightCm, builder: (column) => column);

  GeneratedColumn<double> get weightKg =>
      $composableBuilder(column: $table.weightKg, builder: (column) => column);

  GeneratedColumn<double> get targetWeightKg => $composableBuilder(
    column: $table.targetWeightKg,
    builder: (column) => column,
  );

  GeneratedColumn<double> get waistCm =>
      $composableBuilder(column: $table.waistCm, builder: (column) => column);

  GeneratedColumn<double> get chestCm =>
      $composableBuilder(column: $table.chestCm, builder: (column) => column);

  GeneratedColumn<double> get hipsCm =>
      $composableBuilder(column: $table.hipsCm, builder: (column) => column);

  GeneratedColumn<int> get trainingMinutes => $composableBuilder(
    column: $table.trainingMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get trainingSlot => $composableBuilder(
    column: $table.trainingSlot,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get onboardingDone => $composableBuilder(
    column: $table.onboardingDone,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProfilesTable,
          ProfilesRow,
          $$ProfilesTableFilterComposer,
          $$ProfilesTableOrderingComposer,
          $$ProfilesTableAnnotationComposer,
          $$ProfilesTableCreateCompanionBuilder,
          $$ProfilesTableUpdateCompanionBuilder,
          (
            ProfilesRow,
            BaseReferences<_$AppDatabase, $ProfilesTable, ProfilesRow>,
          ),
          ProfilesRow,
          PrefetchHooks Function()
        > {
  $$ProfilesTableTableManager(_$AppDatabase db, $ProfilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> sex = const Value.absent(),
                Value<int> birthYear = const Value.absent(),
                Value<double> heightCm = const Value.absent(),
                Value<double> weightKg = const Value.absent(),
                Value<double> targetWeightKg = const Value.absent(),
                Value<double?> waistCm = const Value.absent(),
                Value<double?> chestCm = const Value.absent(),
                Value<double?> hipsCm = const Value.absent(),
                Value<int> trainingMinutes = const Value.absent(),
                Value<String> trainingSlot = const Value.absent(),
                Value<bool> onboardingDone = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => ProfilesCompanion(
                id: id,
                name: name,
                sex: sex,
                birthYear: birthYear,
                heightCm: heightCm,
                weightKg: weightKg,
                targetWeightKg: targetWeightKg,
                waistCm: waistCm,
                chestCm: chestCm,
                hipsCm: hipsCm,
                trainingMinutes: trainingMinutes,
                trainingSlot: trainingSlot,
                onboardingDone: onboardingDone,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> sex = const Value.absent(),
                Value<int> birthYear = const Value.absent(),
                Value<double> heightCm = const Value.absent(),
                Value<double> weightKg = const Value.absent(),
                Value<double> targetWeightKg = const Value.absent(),
                Value<double?> waistCm = const Value.absent(),
                Value<double?> chestCm = const Value.absent(),
                Value<double?> hipsCm = const Value.absent(),
                Value<int> trainingMinutes = const Value.absent(),
                Value<String> trainingSlot = const Value.absent(),
                Value<bool> onboardingDone = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
              }) => ProfilesCompanion.insert(
                id: id,
                name: name,
                sex: sex,
                birthYear: birthYear,
                heightCm: heightCm,
                weightKg: weightKg,
                targetWeightKg: targetWeightKg,
                waistCm: waistCm,
                chestCm: chestCm,
                hipsCm: hipsCm,
                trainingMinutes: trainingMinutes,
                trainingSlot: trainingSlot,
                onboardingDone: onboardingDone,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProfilesTable,
      ProfilesRow,
      $$ProfilesTableFilterComposer,
      $$ProfilesTableOrderingComposer,
      $$ProfilesTableAnnotationComposer,
      $$ProfilesTableCreateCompanionBuilder,
      $$ProfilesTableUpdateCompanionBuilder,
      (ProfilesRow, BaseReferences<_$AppDatabase, $ProfilesTable, ProfilesRow>),
      ProfilesRow,
      PrefetchHooks Function()
    >;
typedef $$ProfileHistoryTableCreateCompanionBuilder =
    ProfileHistoryCompanion Function({
      Value<int> id,
      required DateTime recordedAt,
      required double weightKg,
      required double targetWeightKg,
      required double heightCm,
      Value<double?> waistCm,
      Value<double?> chestCm,
      Value<double?> hipsCm,
      Value<String> source,
    });
typedef $$ProfileHistoryTableUpdateCompanionBuilder =
    ProfileHistoryCompanion Function({
      Value<int> id,
      Value<DateTime> recordedAt,
      Value<double> weightKg,
      Value<double> targetWeightKg,
      Value<double> heightCm,
      Value<double?> waistCm,
      Value<double?> chestCm,
      Value<double?> hipsCm,
      Value<String> source,
    });

class $$ProfileHistoryTableFilterComposer
    extends Composer<_$AppDatabase, $ProfileHistoryTable> {
  $$ProfileHistoryTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get targetWeightKg => $composableBuilder(
    column: $table.targetWeightKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get heightCm => $composableBuilder(
    column: $table.heightCm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get waistCm => $composableBuilder(
    column: $table.waistCm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get chestCm => $composableBuilder(
    column: $table.chestCm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get hipsCm => $composableBuilder(
    column: $table.hipsCm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ProfileHistoryTableOrderingComposer
    extends Composer<_$AppDatabase, $ProfileHistoryTable> {
  $$ProfileHistoryTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get targetWeightKg => $composableBuilder(
    column: $table.targetWeightKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get heightCm => $composableBuilder(
    column: $table.heightCm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get waistCm => $composableBuilder(
    column: $table.waistCm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get chestCm => $composableBuilder(
    column: $table.chestCm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get hipsCm => $composableBuilder(
    column: $table.hipsCm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProfileHistoryTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProfileHistoryTable> {
  $$ProfileHistoryTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => column,
  );

  GeneratedColumn<double> get weightKg =>
      $composableBuilder(column: $table.weightKg, builder: (column) => column);

  GeneratedColumn<double> get targetWeightKg => $composableBuilder(
    column: $table.targetWeightKg,
    builder: (column) => column,
  );

  GeneratedColumn<double> get heightCm =>
      $composableBuilder(column: $table.heightCm, builder: (column) => column);

  GeneratedColumn<double> get waistCm =>
      $composableBuilder(column: $table.waistCm, builder: (column) => column);

  GeneratedColumn<double> get chestCm =>
      $composableBuilder(column: $table.chestCm, builder: (column) => column);

  GeneratedColumn<double> get hipsCm =>
      $composableBuilder(column: $table.hipsCm, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);
}

class $$ProfileHistoryTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProfileHistoryTable,
          ProfileHistoryRow,
          $$ProfileHistoryTableFilterComposer,
          $$ProfileHistoryTableOrderingComposer,
          $$ProfileHistoryTableAnnotationComposer,
          $$ProfileHistoryTableCreateCompanionBuilder,
          $$ProfileHistoryTableUpdateCompanionBuilder,
          (
            ProfileHistoryRow,
            BaseReferences<
              _$AppDatabase,
              $ProfileHistoryTable,
              ProfileHistoryRow
            >,
          ),
          ProfileHistoryRow,
          PrefetchHooks Function()
        > {
  $$ProfileHistoryTableTableManager(
    _$AppDatabase db,
    $ProfileHistoryTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProfileHistoryTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProfileHistoryTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProfileHistoryTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> recordedAt = const Value.absent(),
                Value<double> weightKg = const Value.absent(),
                Value<double> targetWeightKg = const Value.absent(),
                Value<double> heightCm = const Value.absent(),
                Value<double?> waistCm = const Value.absent(),
                Value<double?> chestCm = const Value.absent(),
                Value<double?> hipsCm = const Value.absent(),
                Value<String> source = const Value.absent(),
              }) => ProfileHistoryCompanion(
                id: id,
                recordedAt: recordedAt,
                weightKg: weightKg,
                targetWeightKg: targetWeightKg,
                heightCm: heightCm,
                waistCm: waistCm,
                chestCm: chestCm,
                hipsCm: hipsCm,
                source: source,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime recordedAt,
                required double weightKg,
                required double targetWeightKg,
                required double heightCm,
                Value<double?> waistCm = const Value.absent(),
                Value<double?> chestCm = const Value.absent(),
                Value<double?> hipsCm = const Value.absent(),
                Value<String> source = const Value.absent(),
              }) => ProfileHistoryCompanion.insert(
                id: id,
                recordedAt: recordedAt,
                weightKg: weightKg,
                targetWeightKg: targetWeightKg,
                heightCm: heightCm,
                waistCm: waistCm,
                chestCm: chestCm,
                hipsCm: hipsCm,
                source: source,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProfileHistoryTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProfileHistoryTable,
      ProfileHistoryRow,
      $$ProfileHistoryTableFilterComposer,
      $$ProfileHistoryTableOrderingComposer,
      $$ProfileHistoryTableAnnotationComposer,
      $$ProfileHistoryTableCreateCompanionBuilder,
      $$ProfileHistoryTableUpdateCompanionBuilder,
      (
        ProfileHistoryRow,
        BaseReferences<_$AppDatabase, $ProfileHistoryTable, ProfileHistoryRow>,
      ),
      ProfileHistoryRow,
      PrefetchHooks Function()
    >;
typedef $$GoalsTableCreateCompanionBuilder =
    GoalsCompanion Function({
      Value<int> id,
      required double startWeightKg,
      required double targetWeightKg,
      required DateTime startDate,
      required DateTime targetDate,
      required int weeks,
      Value<String> status,
      required DateTime createdAt,
    });
typedef $$GoalsTableUpdateCompanionBuilder =
    GoalsCompanion Function({
      Value<int> id,
      Value<double> startWeightKg,
      Value<double> targetWeightKg,
      Value<DateTime> startDate,
      Value<DateTime> targetDate,
      Value<int> weeks,
      Value<String> status,
      Value<DateTime> createdAt,
    });

class $$GoalsTableFilterComposer extends Composer<_$AppDatabase, $GoalsTable> {
  $$GoalsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get startWeightKg => $composableBuilder(
    column: $table.startWeightKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get targetWeightKg => $composableBuilder(
    column: $table.targetWeightKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get targetDate => $composableBuilder(
    column: $table.targetDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get weeks => $composableBuilder(
    column: $table.weeks,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$GoalsTableOrderingComposer
    extends Composer<_$AppDatabase, $GoalsTable> {
  $$GoalsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get startWeightKg => $composableBuilder(
    column: $table.startWeightKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get targetWeightKg => $composableBuilder(
    column: $table.targetWeightKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get targetDate => $composableBuilder(
    column: $table.targetDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get weeks => $composableBuilder(
    column: $table.weeks,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GoalsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GoalsTable> {
  $$GoalsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get startWeightKg => $composableBuilder(
    column: $table.startWeightKg,
    builder: (column) => column,
  );

  GeneratedColumn<double> get targetWeightKg => $composableBuilder(
    column: $table.targetWeightKg,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<DateTime> get targetDate => $composableBuilder(
    column: $table.targetDate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get weeks =>
      $composableBuilder(column: $table.weeks, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$GoalsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GoalsTable,
          GoalsRow,
          $$GoalsTableFilterComposer,
          $$GoalsTableOrderingComposer,
          $$GoalsTableAnnotationComposer,
          $$GoalsTableCreateCompanionBuilder,
          $$GoalsTableUpdateCompanionBuilder,
          (GoalsRow, BaseReferences<_$AppDatabase, $GoalsTable, GoalsRow>),
          GoalsRow,
          PrefetchHooks Function()
        > {
  $$GoalsTableTableManager(_$AppDatabase db, $GoalsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GoalsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GoalsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GoalsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<double> startWeightKg = const Value.absent(),
                Value<double> targetWeightKg = const Value.absent(),
                Value<DateTime> startDate = const Value.absent(),
                Value<DateTime> targetDate = const Value.absent(),
                Value<int> weeks = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => GoalsCompanion(
                id: id,
                startWeightKg: startWeightKg,
                targetWeightKg: targetWeightKg,
                startDate: startDate,
                targetDate: targetDate,
                weeks: weeks,
                status: status,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required double startWeightKg,
                required double targetWeightKg,
                required DateTime startDate,
                required DateTime targetDate,
                required int weeks,
                Value<String> status = const Value.absent(),
                required DateTime createdAt,
              }) => GoalsCompanion.insert(
                id: id,
                startWeightKg: startWeightKg,
                targetWeightKg: targetWeightKg,
                startDate: startDate,
                targetDate: targetDate,
                weeks: weeks,
                status: status,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$GoalsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GoalsTable,
      GoalsRow,
      $$GoalsTableFilterComposer,
      $$GoalsTableOrderingComposer,
      $$GoalsTableAnnotationComposer,
      $$GoalsTableCreateCompanionBuilder,
      $$GoalsTableUpdateCompanionBuilder,
      (GoalsRow, BaseReferences<_$AppDatabase, $GoalsTable, GoalsRow>),
      GoalsRow,
      PrefetchHooks Function()
    >;
typedef $$MemoryFactsTableCreateCompanionBuilder =
    MemoryFactsCompanion Function({
      Value<int> id,
      required String key,
      required String fact,
      Value<String> category,
      Value<double> confidence,
      Value<String> status,
      Value<int?> supersededBy,
      Value<int?> sourceMessageId,
      required DateTime createdAt,
      required DateTime updatedAt,
    });
typedef $$MemoryFactsTableUpdateCompanionBuilder =
    MemoryFactsCompanion Function({
      Value<int> id,
      Value<String> key,
      Value<String> fact,
      Value<String> category,
      Value<double> confidence,
      Value<String> status,
      Value<int?> supersededBy,
      Value<int?> sourceMessageId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

class $$MemoryFactsTableFilterComposer
    extends Composer<_$AppDatabase, $MemoryFactsTable> {
  $$MemoryFactsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fact => $composableBuilder(
    column: $table.fact,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get supersededBy => $composableBuilder(
    column: $table.supersededBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sourceMessageId => $composableBuilder(
    column: $table.sourceMessageId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MemoryFactsTableOrderingComposer
    extends Composer<_$AppDatabase, $MemoryFactsTable> {
  $$MemoryFactsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fact => $composableBuilder(
    column: $table.fact,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get supersededBy => $composableBuilder(
    column: $table.supersededBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sourceMessageId => $composableBuilder(
    column: $table.sourceMessageId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MemoryFactsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MemoryFactsTable> {
  $$MemoryFactsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get fact =>
      $composableBuilder(column: $table.fact, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get supersededBy => $composableBuilder(
    column: $table.supersededBy,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sourceMessageId => $composableBuilder(
    column: $table.sourceMessageId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$MemoryFactsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MemoryFactsTable,
          MemoryFactsRow,
          $$MemoryFactsTableFilterComposer,
          $$MemoryFactsTableOrderingComposer,
          $$MemoryFactsTableAnnotationComposer,
          $$MemoryFactsTableCreateCompanionBuilder,
          $$MemoryFactsTableUpdateCompanionBuilder,
          (
            MemoryFactsRow,
            BaseReferences<_$AppDatabase, $MemoryFactsTable, MemoryFactsRow>,
          ),
          MemoryFactsRow,
          PrefetchHooks Function()
        > {
  $$MemoryFactsTableTableManager(_$AppDatabase db, $MemoryFactsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MemoryFactsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MemoryFactsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MemoryFactsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> key = const Value.absent(),
                Value<String> fact = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<double> confidence = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int?> supersededBy = const Value.absent(),
                Value<int?> sourceMessageId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => MemoryFactsCompanion(
                id: id,
                key: key,
                fact: fact,
                category: category,
                confidence: confidence,
                status: status,
                supersededBy: supersededBy,
                sourceMessageId: sourceMessageId,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String key,
                required String fact,
                Value<String> category = const Value.absent(),
                Value<double> confidence = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int?> supersededBy = const Value.absent(),
                Value<int?> sourceMessageId = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
              }) => MemoryFactsCompanion.insert(
                id: id,
                key: key,
                fact: fact,
                category: category,
                confidence: confidence,
                status: status,
                supersededBy: supersededBy,
                sourceMessageId: sourceMessageId,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MemoryFactsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MemoryFactsTable,
      MemoryFactsRow,
      $$MemoryFactsTableFilterComposer,
      $$MemoryFactsTableOrderingComposer,
      $$MemoryFactsTableAnnotationComposer,
      $$MemoryFactsTableCreateCompanionBuilder,
      $$MemoryFactsTableUpdateCompanionBuilder,
      (
        MemoryFactsRow,
        BaseReferences<_$AppDatabase, $MemoryFactsTable, MemoryFactsRow>,
      ),
      MemoryFactsRow,
      PrefetchHooks Function()
    >;
typedef $$DietPlansTableCreateCompanionBuilder =
    DietPlansCompanion Function({
      Value<int> id,
      required DateTime createdAt,
      required int kcalTarget,
      required int proteinG,
      required int fatG,
      required int carbsG,
      required int bmr,
      required int tdee,
      required int deficitKcal,
      required double weeklyLossKg,
      Value<int> toleranceKcal,
      Value<String> notesJson,
      Value<bool> active,
    });
typedef $$DietPlansTableUpdateCompanionBuilder =
    DietPlansCompanion Function({
      Value<int> id,
      Value<DateTime> createdAt,
      Value<int> kcalTarget,
      Value<int> proteinG,
      Value<int> fatG,
      Value<int> carbsG,
      Value<int> bmr,
      Value<int> tdee,
      Value<int> deficitKcal,
      Value<double> weeklyLossKg,
      Value<int> toleranceKcal,
      Value<String> notesJson,
      Value<bool> active,
    });

class $$DietPlansTableFilterComposer
    extends Composer<_$AppDatabase, $DietPlansTable> {
  $$DietPlansTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get kcalTarget => $composableBuilder(
    column: $table.kcalTarget,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get proteinG => $composableBuilder(
    column: $table.proteinG,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fatG => $composableBuilder(
    column: $table.fatG,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get carbsG => $composableBuilder(
    column: $table.carbsG,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bmr => $composableBuilder(
    column: $table.bmr,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get tdee => $composableBuilder(
    column: $table.tdee,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deficitKcal => $composableBuilder(
    column: $table.deficitKcal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weeklyLossKg => $composableBuilder(
    column: $table.weeklyLossKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get toleranceKcal => $composableBuilder(
    column: $table.toleranceKcal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notesJson => $composableBuilder(
    column: $table.notesJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DietPlansTableOrderingComposer
    extends Composer<_$AppDatabase, $DietPlansTable> {
  $$DietPlansTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get kcalTarget => $composableBuilder(
    column: $table.kcalTarget,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get proteinG => $composableBuilder(
    column: $table.proteinG,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fatG => $composableBuilder(
    column: $table.fatG,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get carbsG => $composableBuilder(
    column: $table.carbsG,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bmr => $composableBuilder(
    column: $table.bmr,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tdee => $composableBuilder(
    column: $table.tdee,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deficitKcal => $composableBuilder(
    column: $table.deficitKcal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weeklyLossKg => $composableBuilder(
    column: $table.weeklyLossKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get toleranceKcal => $composableBuilder(
    column: $table.toleranceKcal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notesJson => $composableBuilder(
    column: $table.notesJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DietPlansTableAnnotationComposer
    extends Composer<_$AppDatabase, $DietPlansTable> {
  $$DietPlansTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get kcalTarget => $composableBuilder(
    column: $table.kcalTarget,
    builder: (column) => column,
  );

  GeneratedColumn<int> get proteinG =>
      $composableBuilder(column: $table.proteinG, builder: (column) => column);

  GeneratedColumn<int> get fatG =>
      $composableBuilder(column: $table.fatG, builder: (column) => column);

  GeneratedColumn<int> get carbsG =>
      $composableBuilder(column: $table.carbsG, builder: (column) => column);

  GeneratedColumn<int> get bmr =>
      $composableBuilder(column: $table.bmr, builder: (column) => column);

  GeneratedColumn<int> get tdee =>
      $composableBuilder(column: $table.tdee, builder: (column) => column);

  GeneratedColumn<int> get deficitKcal => $composableBuilder(
    column: $table.deficitKcal,
    builder: (column) => column,
  );

  GeneratedColumn<double> get weeklyLossKg => $composableBuilder(
    column: $table.weeklyLossKg,
    builder: (column) => column,
  );

  GeneratedColumn<int> get toleranceKcal => $composableBuilder(
    column: $table.toleranceKcal,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notesJson =>
      $composableBuilder(column: $table.notesJson, builder: (column) => column);

  GeneratedColumn<bool> get active =>
      $composableBuilder(column: $table.active, builder: (column) => column);
}

class $$DietPlansTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DietPlansTable,
          DietPlansRow,
          $$DietPlansTableFilterComposer,
          $$DietPlansTableOrderingComposer,
          $$DietPlansTableAnnotationComposer,
          $$DietPlansTableCreateCompanionBuilder,
          $$DietPlansTableUpdateCompanionBuilder,
          (
            DietPlansRow,
            BaseReferences<_$AppDatabase, $DietPlansTable, DietPlansRow>,
          ),
          DietPlansRow,
          PrefetchHooks Function()
        > {
  $$DietPlansTableTableManager(_$AppDatabase db, $DietPlansTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DietPlansTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DietPlansTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DietPlansTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> kcalTarget = const Value.absent(),
                Value<int> proteinG = const Value.absent(),
                Value<int> fatG = const Value.absent(),
                Value<int> carbsG = const Value.absent(),
                Value<int> bmr = const Value.absent(),
                Value<int> tdee = const Value.absent(),
                Value<int> deficitKcal = const Value.absent(),
                Value<double> weeklyLossKg = const Value.absent(),
                Value<int> toleranceKcal = const Value.absent(),
                Value<String> notesJson = const Value.absent(),
                Value<bool> active = const Value.absent(),
              }) => DietPlansCompanion(
                id: id,
                createdAt: createdAt,
                kcalTarget: kcalTarget,
                proteinG: proteinG,
                fatG: fatG,
                carbsG: carbsG,
                bmr: bmr,
                tdee: tdee,
                deficitKcal: deficitKcal,
                weeklyLossKg: weeklyLossKg,
                toleranceKcal: toleranceKcal,
                notesJson: notesJson,
                active: active,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime createdAt,
                required int kcalTarget,
                required int proteinG,
                required int fatG,
                required int carbsG,
                required int bmr,
                required int tdee,
                required int deficitKcal,
                required double weeklyLossKg,
                Value<int> toleranceKcal = const Value.absent(),
                Value<String> notesJson = const Value.absent(),
                Value<bool> active = const Value.absent(),
              }) => DietPlansCompanion.insert(
                id: id,
                createdAt: createdAt,
                kcalTarget: kcalTarget,
                proteinG: proteinG,
                fatG: fatG,
                carbsG: carbsG,
                bmr: bmr,
                tdee: tdee,
                deficitKcal: deficitKcal,
                weeklyLossKg: weeklyLossKg,
                toleranceKcal: toleranceKcal,
                notesJson: notesJson,
                active: active,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DietPlansTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DietPlansTable,
      DietPlansRow,
      $$DietPlansTableFilterComposer,
      $$DietPlansTableOrderingComposer,
      $$DietPlansTableAnnotationComposer,
      $$DietPlansTableCreateCompanionBuilder,
      $$DietPlansTableUpdateCompanionBuilder,
      (
        DietPlansRow,
        BaseReferences<_$AppDatabase, $DietPlansTable, DietPlansRow>,
      ),
      DietPlansRow,
      PrefetchHooks Function()
    >;
typedef $$DiaryEntriesTableCreateCompanionBuilder =
    DiaryEntriesCompanion Function({
      Value<int> id,
      required DateTime eatenAt,
      Value<String> meal,
      required String description,
      Value<int?> kcal,
      Value<double?> proteinG,
      Value<double?> fatG,
      Value<double?> carbsG,
      Value<String> photoPathsJson,
      Value<String> source,
      Value<int?> messageId,
      required DateTime createdAt,
    });
typedef $$DiaryEntriesTableUpdateCompanionBuilder =
    DiaryEntriesCompanion Function({
      Value<int> id,
      Value<DateTime> eatenAt,
      Value<String> meal,
      Value<String> description,
      Value<int?> kcal,
      Value<double?> proteinG,
      Value<double?> fatG,
      Value<double?> carbsG,
      Value<String> photoPathsJson,
      Value<String> source,
      Value<int?> messageId,
      Value<DateTime> createdAt,
    });

class $$DiaryEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $DiaryEntriesTable> {
  $$DiaryEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get eatenAt => $composableBuilder(
    column: $table.eatenAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get meal => $composableBuilder(
    column: $table.meal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get kcal => $composableBuilder(
    column: $table.kcal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get proteinG => $composableBuilder(
    column: $table.proteinG,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fatG => $composableBuilder(
    column: $table.fatG,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get carbsG => $composableBuilder(
    column: $table.carbsG,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get photoPathsJson => $composableBuilder(
    column: $table.photoPathsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get messageId => $composableBuilder(
    column: $table.messageId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DiaryEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $DiaryEntriesTable> {
  $$DiaryEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get eatenAt => $composableBuilder(
    column: $table.eatenAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get meal => $composableBuilder(
    column: $table.meal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get kcal => $composableBuilder(
    column: $table.kcal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get proteinG => $composableBuilder(
    column: $table.proteinG,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fatG => $composableBuilder(
    column: $table.fatG,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get carbsG => $composableBuilder(
    column: $table.carbsG,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get photoPathsJson => $composableBuilder(
    column: $table.photoPathsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get messageId => $composableBuilder(
    column: $table.messageId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DiaryEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DiaryEntriesTable> {
  $$DiaryEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get eatenAt =>
      $composableBuilder(column: $table.eatenAt, builder: (column) => column);

  GeneratedColumn<String> get meal =>
      $composableBuilder(column: $table.meal, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<int> get kcal =>
      $composableBuilder(column: $table.kcal, builder: (column) => column);

  GeneratedColumn<double> get proteinG =>
      $composableBuilder(column: $table.proteinG, builder: (column) => column);

  GeneratedColumn<double> get fatG =>
      $composableBuilder(column: $table.fatG, builder: (column) => column);

  GeneratedColumn<double> get carbsG =>
      $composableBuilder(column: $table.carbsG, builder: (column) => column);

  GeneratedColumn<String> get photoPathsJson => $composableBuilder(
    column: $table.photoPathsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<int> get messageId =>
      $composableBuilder(column: $table.messageId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$DiaryEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DiaryEntriesTable,
          DiaryEntriesRow,
          $$DiaryEntriesTableFilterComposer,
          $$DiaryEntriesTableOrderingComposer,
          $$DiaryEntriesTableAnnotationComposer,
          $$DiaryEntriesTableCreateCompanionBuilder,
          $$DiaryEntriesTableUpdateCompanionBuilder,
          (
            DiaryEntriesRow,
            BaseReferences<_$AppDatabase, $DiaryEntriesTable, DiaryEntriesRow>,
          ),
          DiaryEntriesRow,
          PrefetchHooks Function()
        > {
  $$DiaryEntriesTableTableManager(_$AppDatabase db, $DiaryEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DiaryEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DiaryEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DiaryEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> eatenAt = const Value.absent(),
                Value<String> meal = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<int?> kcal = const Value.absent(),
                Value<double?> proteinG = const Value.absent(),
                Value<double?> fatG = const Value.absent(),
                Value<double?> carbsG = const Value.absent(),
                Value<String> photoPathsJson = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<int?> messageId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => DiaryEntriesCompanion(
                id: id,
                eatenAt: eatenAt,
                meal: meal,
                description: description,
                kcal: kcal,
                proteinG: proteinG,
                fatG: fatG,
                carbsG: carbsG,
                photoPathsJson: photoPathsJson,
                source: source,
                messageId: messageId,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime eatenAt,
                Value<String> meal = const Value.absent(),
                required String description,
                Value<int?> kcal = const Value.absent(),
                Value<double?> proteinG = const Value.absent(),
                Value<double?> fatG = const Value.absent(),
                Value<double?> carbsG = const Value.absent(),
                Value<String> photoPathsJson = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<int?> messageId = const Value.absent(),
                required DateTime createdAt,
              }) => DiaryEntriesCompanion.insert(
                id: id,
                eatenAt: eatenAt,
                meal: meal,
                description: description,
                kcal: kcal,
                proteinG: proteinG,
                fatG: fatG,
                carbsG: carbsG,
                photoPathsJson: photoPathsJson,
                source: source,
                messageId: messageId,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DiaryEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DiaryEntriesTable,
      DiaryEntriesRow,
      $$DiaryEntriesTableFilterComposer,
      $$DiaryEntriesTableOrderingComposer,
      $$DiaryEntriesTableAnnotationComposer,
      $$DiaryEntriesTableCreateCompanionBuilder,
      $$DiaryEntriesTableUpdateCompanionBuilder,
      (
        DiaryEntriesRow,
        BaseReferences<_$AppDatabase, $DiaryEntriesTable, DiaryEntriesRow>,
      ),
      DiaryEntriesRow,
      PrefetchHooks Function()
    >;
typedef $$WorkoutsTableCreateCompanionBuilder =
    WorkoutsCompanion Function({
      Value<int> id,
      required DateTime createdAt,
      Value<DateTime?> scheduledAt,
      required String title,
      Value<String> planJson,
      Value<String> source,
      Value<String> status,
    });
typedef $$WorkoutsTableUpdateCompanionBuilder =
    WorkoutsCompanion Function({
      Value<int> id,
      Value<DateTime> createdAt,
      Value<DateTime?> scheduledAt,
      Value<String> title,
      Value<String> planJson,
      Value<String> source,
      Value<String> status,
    });

class $$WorkoutsTableFilterComposer
    extends Composer<_$AppDatabase, $WorkoutsTable> {
  $$WorkoutsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get scheduledAt => $composableBuilder(
    column: $table.scheduledAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get planJson => $composableBuilder(
    column: $table.planJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WorkoutsTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkoutsTable> {
  $$WorkoutsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get scheduledAt => $composableBuilder(
    column: $table.scheduledAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get planJson => $composableBuilder(
    column: $table.planJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WorkoutsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkoutsTable> {
  $$WorkoutsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get scheduledAt => $composableBuilder(
    column: $table.scheduledAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get planJson =>
      $composableBuilder(column: $table.planJson, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);
}

class $$WorkoutsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WorkoutsTable,
          WorkoutsRow,
          $$WorkoutsTableFilterComposer,
          $$WorkoutsTableOrderingComposer,
          $$WorkoutsTableAnnotationComposer,
          $$WorkoutsTableCreateCompanionBuilder,
          $$WorkoutsTableUpdateCompanionBuilder,
          (
            WorkoutsRow,
            BaseReferences<_$AppDatabase, $WorkoutsTable, WorkoutsRow>,
          ),
          WorkoutsRow,
          PrefetchHooks Function()
        > {
  $$WorkoutsTableTableManager(_$AppDatabase db, $WorkoutsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkoutsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkoutsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkoutsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> scheduledAt = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> planJson = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String> status = const Value.absent(),
              }) => WorkoutsCompanion(
                id: id,
                createdAt: createdAt,
                scheduledAt: scheduledAt,
                title: title,
                planJson: planJson,
                source: source,
                status: status,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime createdAt,
                Value<DateTime?> scheduledAt = const Value.absent(),
                required String title,
                Value<String> planJson = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String> status = const Value.absent(),
              }) => WorkoutsCompanion.insert(
                id: id,
                createdAt: createdAt,
                scheduledAt: scheduledAt,
                title: title,
                planJson: planJson,
                source: source,
                status: status,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WorkoutsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WorkoutsTable,
      WorkoutsRow,
      $$WorkoutsTableFilterComposer,
      $$WorkoutsTableOrderingComposer,
      $$WorkoutsTableAnnotationComposer,
      $$WorkoutsTableCreateCompanionBuilder,
      $$WorkoutsTableUpdateCompanionBuilder,
      (WorkoutsRow, BaseReferences<_$AppDatabase, $WorkoutsTable, WorkoutsRow>),
      WorkoutsRow,
      PrefetchHooks Function()
    >;
typedef $$WorkoutResultsTableCreateCompanionBuilder =
    WorkoutResultsCompanion Function({
      Value<int> id,
      Value<int?> workoutId,
      required DateTime startedAt,
      Value<DateTime?> finishedAt,
      required String status,
      Value<int> doneExercises,
      Value<int> skippedExercises,
      Value<int> pauses,
      Value<int> pausedSeconds,
      Value<int> durationSec,
      Value<int> kcal,
      Value<String?> note,
    });
typedef $$WorkoutResultsTableUpdateCompanionBuilder =
    WorkoutResultsCompanion Function({
      Value<int> id,
      Value<int?> workoutId,
      Value<DateTime> startedAt,
      Value<DateTime?> finishedAt,
      Value<String> status,
      Value<int> doneExercises,
      Value<int> skippedExercises,
      Value<int> pauses,
      Value<int> pausedSeconds,
      Value<int> durationSec,
      Value<int> kcal,
      Value<String?> note,
    });

class $$WorkoutResultsTableFilterComposer
    extends Composer<_$AppDatabase, $WorkoutResultsTable> {
  $$WorkoutResultsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get workoutId => $composableBuilder(
    column: $table.workoutId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get doneExercises => $composableBuilder(
    column: $table.doneExercises,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get skippedExercises => $composableBuilder(
    column: $table.skippedExercises,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pauses => $composableBuilder(
    column: $table.pauses,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pausedSeconds => $composableBuilder(
    column: $table.pausedSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationSec => $composableBuilder(
    column: $table.durationSec,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get kcal => $composableBuilder(
    column: $table.kcal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WorkoutResultsTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkoutResultsTable> {
  $$WorkoutResultsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get workoutId => $composableBuilder(
    column: $table.workoutId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get doneExercises => $composableBuilder(
    column: $table.doneExercises,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get skippedExercises => $composableBuilder(
    column: $table.skippedExercises,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pauses => $composableBuilder(
    column: $table.pauses,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pausedSeconds => $composableBuilder(
    column: $table.pausedSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationSec => $composableBuilder(
    column: $table.durationSec,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get kcal => $composableBuilder(
    column: $table.kcal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WorkoutResultsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkoutResultsTable> {
  $$WorkoutResultsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get workoutId =>
      $composableBuilder(column: $table.workoutId, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get doneExercises => $composableBuilder(
    column: $table.doneExercises,
    builder: (column) => column,
  );

  GeneratedColumn<int> get skippedExercises => $composableBuilder(
    column: $table.skippedExercises,
    builder: (column) => column,
  );

  GeneratedColumn<int> get pauses =>
      $composableBuilder(column: $table.pauses, builder: (column) => column);

  GeneratedColumn<int> get pausedSeconds => $composableBuilder(
    column: $table.pausedSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get durationSec => $composableBuilder(
    column: $table.durationSec,
    builder: (column) => column,
  );

  GeneratedColumn<int> get kcal =>
      $composableBuilder(column: $table.kcal, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);
}

class $$WorkoutResultsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WorkoutResultsTable,
          WorkoutResultsRow,
          $$WorkoutResultsTableFilterComposer,
          $$WorkoutResultsTableOrderingComposer,
          $$WorkoutResultsTableAnnotationComposer,
          $$WorkoutResultsTableCreateCompanionBuilder,
          $$WorkoutResultsTableUpdateCompanionBuilder,
          (
            WorkoutResultsRow,
            BaseReferences<
              _$AppDatabase,
              $WorkoutResultsTable,
              WorkoutResultsRow
            >,
          ),
          WorkoutResultsRow,
          PrefetchHooks Function()
        > {
  $$WorkoutResultsTableTableManager(
    _$AppDatabase db,
    $WorkoutResultsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkoutResultsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkoutResultsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkoutResultsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> workoutId = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime?> finishedAt = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> doneExercises = const Value.absent(),
                Value<int> skippedExercises = const Value.absent(),
                Value<int> pauses = const Value.absent(),
                Value<int> pausedSeconds = const Value.absent(),
                Value<int> durationSec = const Value.absent(),
                Value<int> kcal = const Value.absent(),
                Value<String?> note = const Value.absent(),
              }) => WorkoutResultsCompanion(
                id: id,
                workoutId: workoutId,
                startedAt: startedAt,
                finishedAt: finishedAt,
                status: status,
                doneExercises: doneExercises,
                skippedExercises: skippedExercises,
                pauses: pauses,
                pausedSeconds: pausedSeconds,
                durationSec: durationSec,
                kcal: kcal,
                note: note,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> workoutId = const Value.absent(),
                required DateTime startedAt,
                Value<DateTime?> finishedAt = const Value.absent(),
                required String status,
                Value<int> doneExercises = const Value.absent(),
                Value<int> skippedExercises = const Value.absent(),
                Value<int> pauses = const Value.absent(),
                Value<int> pausedSeconds = const Value.absent(),
                Value<int> durationSec = const Value.absent(),
                Value<int> kcal = const Value.absent(),
                Value<String?> note = const Value.absent(),
              }) => WorkoutResultsCompanion.insert(
                id: id,
                workoutId: workoutId,
                startedAt: startedAt,
                finishedAt: finishedAt,
                status: status,
                doneExercises: doneExercises,
                skippedExercises: skippedExercises,
                pauses: pauses,
                pausedSeconds: pausedSeconds,
                durationSec: durationSec,
                kcal: kcal,
                note: note,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WorkoutResultsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WorkoutResultsTable,
      WorkoutResultsRow,
      $$WorkoutResultsTableFilterComposer,
      $$WorkoutResultsTableOrderingComposer,
      $$WorkoutResultsTableAnnotationComposer,
      $$WorkoutResultsTableCreateCompanionBuilder,
      $$WorkoutResultsTableUpdateCompanionBuilder,
      (
        WorkoutResultsRow,
        BaseReferences<_$AppDatabase, $WorkoutResultsTable, WorkoutResultsRow>,
      ),
      WorkoutResultsRow,
      PrefetchHooks Function()
    >;
typedef $$NotificationScheduleTableCreateCompanionBuilder =
    NotificationScheduleCompanion Function({
      Value<int> id,
      required String kind,
      required String title,
      Value<String> body,
      required int minuteOfDay,
      Value<int> weekdaysMask,
      Value<DateTime?> oneOffAt,
      Value<bool> enabled,
      Value<String> createdBy,
      required DateTime createdAt,
    });
typedef $$NotificationScheduleTableUpdateCompanionBuilder =
    NotificationScheduleCompanion Function({
      Value<int> id,
      Value<String> kind,
      Value<String> title,
      Value<String> body,
      Value<int> minuteOfDay,
      Value<int> weekdaysMask,
      Value<DateTime?> oneOffAt,
      Value<bool> enabled,
      Value<String> createdBy,
      Value<DateTime> createdAt,
    });

class $$NotificationScheduleTableFilterComposer
    extends Composer<_$AppDatabase, $NotificationScheduleTable> {
  $$NotificationScheduleTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get minuteOfDay => $composableBuilder(
    column: $table.minuteOfDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get weekdaysMask => $composableBuilder(
    column: $table.weekdaysMask,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get oneOffAt => $composableBuilder(
    column: $table.oneOffAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$NotificationScheduleTableOrderingComposer
    extends Composer<_$AppDatabase, $NotificationScheduleTable> {
  $$NotificationScheduleTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get minuteOfDay => $composableBuilder(
    column: $table.minuteOfDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get weekdaysMask => $composableBuilder(
    column: $table.weekdaysMask,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get oneOffAt => $composableBuilder(
    column: $table.oneOffAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$NotificationScheduleTableAnnotationComposer
    extends Composer<_$AppDatabase, $NotificationScheduleTable> {
  $$NotificationScheduleTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<int> get minuteOfDay => $composableBuilder(
    column: $table.minuteOfDay,
    builder: (column) => column,
  );

  GeneratedColumn<int> get weekdaysMask => $composableBuilder(
    column: $table.weekdaysMask,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get oneOffAt =>
      $composableBuilder(column: $table.oneOffAt, builder: (column) => column);

  GeneratedColumn<bool> get enabled =>
      $composableBuilder(column: $table.enabled, builder: (column) => column);

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$NotificationScheduleTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NotificationScheduleTable,
          NotificationScheduleRow,
          $$NotificationScheduleTableFilterComposer,
          $$NotificationScheduleTableOrderingComposer,
          $$NotificationScheduleTableAnnotationComposer,
          $$NotificationScheduleTableCreateCompanionBuilder,
          $$NotificationScheduleTableUpdateCompanionBuilder,
          (
            NotificationScheduleRow,
            BaseReferences<
              _$AppDatabase,
              $NotificationScheduleTable,
              NotificationScheduleRow
            >,
          ),
          NotificationScheduleRow,
          PrefetchHooks Function()
        > {
  $$NotificationScheduleTableTableManager(
    _$AppDatabase db,
    $NotificationScheduleTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NotificationScheduleTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NotificationScheduleTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$NotificationScheduleTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<int> minuteOfDay = const Value.absent(),
                Value<int> weekdaysMask = const Value.absent(),
                Value<DateTime?> oneOffAt = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
                Value<String> createdBy = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => NotificationScheduleCompanion(
                id: id,
                kind: kind,
                title: title,
                body: body,
                minuteOfDay: minuteOfDay,
                weekdaysMask: weekdaysMask,
                oneOffAt: oneOffAt,
                enabled: enabled,
                createdBy: createdBy,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String kind,
                required String title,
                Value<String> body = const Value.absent(),
                required int minuteOfDay,
                Value<int> weekdaysMask = const Value.absent(),
                Value<DateTime?> oneOffAt = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
                Value<String> createdBy = const Value.absent(),
                required DateTime createdAt,
              }) => NotificationScheduleCompanion.insert(
                id: id,
                kind: kind,
                title: title,
                body: body,
                minuteOfDay: minuteOfDay,
                weekdaysMask: weekdaysMask,
                oneOffAt: oneOffAt,
                enabled: enabled,
                createdBy: createdBy,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$NotificationScheduleTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NotificationScheduleTable,
      NotificationScheduleRow,
      $$NotificationScheduleTableFilterComposer,
      $$NotificationScheduleTableOrderingComposer,
      $$NotificationScheduleTableAnnotationComposer,
      $$NotificationScheduleTableCreateCompanionBuilder,
      $$NotificationScheduleTableUpdateCompanionBuilder,
      (
        NotificationScheduleRow,
        BaseReferences<
          _$AppDatabase,
          $NotificationScheduleTable,
          NotificationScheduleRow
        >,
      ),
      NotificationScheduleRow,
      PrefetchHooks Function()
    >;
typedef $$MessagesTableCreateCompanionBuilder =
    MessagesCompanion Function({
      Value<int> id,
      required String role,
      Value<String> kind,
      Value<String> body,
      Value<String> imagesJson,
      Value<String?> audioPath,
      Value<int> audioMs,
      Value<String> waveformJson,
      required DateTime createdAt,
      Value<int?> summaryId,
    });
typedef $$MessagesTableUpdateCompanionBuilder =
    MessagesCompanion Function({
      Value<int> id,
      Value<String> role,
      Value<String> kind,
      Value<String> body,
      Value<String> imagesJson,
      Value<String?> audioPath,
      Value<int> audioMs,
      Value<String> waveformJson,
      Value<DateTime> createdAt,
      Value<int?> summaryId,
    });

class $$MessagesTableFilterComposer
    extends Composer<_$AppDatabase, $MessagesTable> {
  $$MessagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imagesJson => $composableBuilder(
    column: $table.imagesJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get audioPath => $composableBuilder(
    column: $table.audioPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get audioMs => $composableBuilder(
    column: $table.audioMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get waveformJson => $composableBuilder(
    column: $table.waveformJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get summaryId => $composableBuilder(
    column: $table.summaryId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MessagesTableOrderingComposer
    extends Composer<_$AppDatabase, $MessagesTable> {
  $$MessagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imagesJson => $composableBuilder(
    column: $table.imagesJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get audioPath => $composableBuilder(
    column: $table.audioPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get audioMs => $composableBuilder(
    column: $table.audioMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get waveformJson => $composableBuilder(
    column: $table.waveformJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get summaryId => $composableBuilder(
    column: $table.summaryId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MessagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MessagesTable> {
  $$MessagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<String> get imagesJson => $composableBuilder(
    column: $table.imagesJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get audioPath =>
      $composableBuilder(column: $table.audioPath, builder: (column) => column);

  GeneratedColumn<int> get audioMs =>
      $composableBuilder(column: $table.audioMs, builder: (column) => column);

  GeneratedColumn<String> get waveformJson => $composableBuilder(
    column: $table.waveformJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get summaryId =>
      $composableBuilder(column: $table.summaryId, builder: (column) => column);
}

class $$MessagesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MessagesTable,
          MessagesRow,
          $$MessagesTableFilterComposer,
          $$MessagesTableOrderingComposer,
          $$MessagesTableAnnotationComposer,
          $$MessagesTableCreateCompanionBuilder,
          $$MessagesTableUpdateCompanionBuilder,
          (
            MessagesRow,
            BaseReferences<_$AppDatabase, $MessagesTable, MessagesRow>,
          ),
          MessagesRow,
          PrefetchHooks Function()
        > {
  $$MessagesTableTableManager(_$AppDatabase db, $MessagesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MessagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MessagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MessagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<String> imagesJson = const Value.absent(),
                Value<String?> audioPath = const Value.absent(),
                Value<int> audioMs = const Value.absent(),
                Value<String> waveformJson = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int?> summaryId = const Value.absent(),
              }) => MessagesCompanion(
                id: id,
                role: role,
                kind: kind,
                body: body,
                imagesJson: imagesJson,
                audioPath: audioPath,
                audioMs: audioMs,
                waveformJson: waveformJson,
                createdAt: createdAt,
                summaryId: summaryId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String role,
                Value<String> kind = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<String> imagesJson = const Value.absent(),
                Value<String?> audioPath = const Value.absent(),
                Value<int> audioMs = const Value.absent(),
                Value<String> waveformJson = const Value.absent(),
                required DateTime createdAt,
                Value<int?> summaryId = const Value.absent(),
              }) => MessagesCompanion.insert(
                id: id,
                role: role,
                kind: kind,
                body: body,
                imagesJson: imagesJson,
                audioPath: audioPath,
                audioMs: audioMs,
                waveformJson: waveformJson,
                createdAt: createdAt,
                summaryId: summaryId,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MessagesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MessagesTable,
      MessagesRow,
      $$MessagesTableFilterComposer,
      $$MessagesTableOrderingComposer,
      $$MessagesTableAnnotationComposer,
      $$MessagesTableCreateCompanionBuilder,
      $$MessagesTableUpdateCompanionBuilder,
      (MessagesRow, BaseReferences<_$AppDatabase, $MessagesTable, MessagesRow>),
      MessagesRow,
      PrefetchHooks Function()
    >;
typedef $$ConversationSummariesTableCreateCompanionBuilder =
    ConversationSummariesCompanion Function({
      Value<int> id,
      required DateTime createdAt,
      required DateTime fromTime,
      required DateTime toTime,
      required String body,
      Value<int> messageCount,
    });
typedef $$ConversationSummariesTableUpdateCompanionBuilder =
    ConversationSummariesCompanion Function({
      Value<int> id,
      Value<DateTime> createdAt,
      Value<DateTime> fromTime,
      Value<DateTime> toTime,
      Value<String> body,
      Value<int> messageCount,
    });

class $$ConversationSummariesTableFilterComposer
    extends Composer<_$AppDatabase, $ConversationSummariesTable> {
  $$ConversationSummariesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fromTime => $composableBuilder(
    column: $table.fromTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get toTime => $composableBuilder(
    column: $table.toTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get messageCount => $composableBuilder(
    column: $table.messageCount,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ConversationSummariesTableOrderingComposer
    extends Composer<_$AppDatabase, $ConversationSummariesTable> {
  $$ConversationSummariesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fromTime => $composableBuilder(
    column: $table.fromTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get toTime => $composableBuilder(
    column: $table.toTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get messageCount => $composableBuilder(
    column: $table.messageCount,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ConversationSummariesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ConversationSummariesTable> {
  $$ConversationSummariesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get fromTime =>
      $composableBuilder(column: $table.fromTime, builder: (column) => column);

  GeneratedColumn<DateTime> get toTime =>
      $composableBuilder(column: $table.toTime, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<int> get messageCount => $composableBuilder(
    column: $table.messageCount,
    builder: (column) => column,
  );
}

class $$ConversationSummariesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ConversationSummariesTable,
          ConversationSummariesRow,
          $$ConversationSummariesTableFilterComposer,
          $$ConversationSummariesTableOrderingComposer,
          $$ConversationSummariesTableAnnotationComposer,
          $$ConversationSummariesTableCreateCompanionBuilder,
          $$ConversationSummariesTableUpdateCompanionBuilder,
          (
            ConversationSummariesRow,
            BaseReferences<
              _$AppDatabase,
              $ConversationSummariesTable,
              ConversationSummariesRow
            >,
          ),
          ConversationSummariesRow,
          PrefetchHooks Function()
        > {
  $$ConversationSummariesTableTableManager(
    _$AppDatabase db,
    $ConversationSummariesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ConversationSummariesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$ConversationSummariesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ConversationSummariesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> fromTime = const Value.absent(),
                Value<DateTime> toTime = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<int> messageCount = const Value.absent(),
              }) => ConversationSummariesCompanion(
                id: id,
                createdAt: createdAt,
                fromTime: fromTime,
                toTime: toTime,
                body: body,
                messageCount: messageCount,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime createdAt,
                required DateTime fromTime,
                required DateTime toTime,
                required String body,
                Value<int> messageCount = const Value.absent(),
              }) => ConversationSummariesCompanion.insert(
                id: id,
                createdAt: createdAt,
                fromTime: fromTime,
                toTime: toTime,
                body: body,
                messageCount: messageCount,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ConversationSummariesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ConversationSummariesTable,
      ConversationSummariesRow,
      $$ConversationSummariesTableFilterComposer,
      $$ConversationSummariesTableOrderingComposer,
      $$ConversationSummariesTableAnnotationComposer,
      $$ConversationSummariesTableCreateCompanionBuilder,
      $$ConversationSummariesTableUpdateCompanionBuilder,
      (
        ConversationSummariesRow,
        BaseReferences<
          _$AppDatabase,
          $ConversationSummariesTable,
          ConversationSummariesRow
        >,
      ),
      ConversationSummariesRow,
      PrefetchHooks Function()
    >;
typedef $$ApiUsageTableCreateCompanionBuilder =
    ApiUsageCompanion Function({
      required String day,
      required String model,
      Value<int> count,
      Value<int> rowid,
    });
typedef $$ApiUsageTableUpdateCompanionBuilder =
    ApiUsageCompanion Function({
      Value<String> day,
      Value<String> model,
      Value<int> count,
      Value<int> rowid,
    });

class $$ApiUsageTableFilterComposer
    extends Composer<_$AppDatabase, $ApiUsageTable> {
  $$ApiUsageTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get model => $composableBuilder(
    column: $table.model,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get count => $composableBuilder(
    column: $table.count,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ApiUsageTableOrderingComposer
    extends Composer<_$AppDatabase, $ApiUsageTable> {
  $$ApiUsageTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get model => $composableBuilder(
    column: $table.model,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get count => $composableBuilder(
    column: $table.count,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ApiUsageTableAnnotationComposer
    extends Composer<_$AppDatabase, $ApiUsageTable> {
  $$ApiUsageTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get day =>
      $composableBuilder(column: $table.day, builder: (column) => column);

  GeneratedColumn<String> get model =>
      $composableBuilder(column: $table.model, builder: (column) => column);

  GeneratedColumn<int> get count =>
      $composableBuilder(column: $table.count, builder: (column) => column);
}

class $$ApiUsageTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ApiUsageTable,
          ApiUsageRow,
          $$ApiUsageTableFilterComposer,
          $$ApiUsageTableOrderingComposer,
          $$ApiUsageTableAnnotationComposer,
          $$ApiUsageTableCreateCompanionBuilder,
          $$ApiUsageTableUpdateCompanionBuilder,
          (
            ApiUsageRow,
            BaseReferences<_$AppDatabase, $ApiUsageTable, ApiUsageRow>,
          ),
          ApiUsageRow,
          PrefetchHooks Function()
        > {
  $$ApiUsageTableTableManager(_$AppDatabase db, $ApiUsageTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ApiUsageTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ApiUsageTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ApiUsageTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> day = const Value.absent(),
                Value<String> model = const Value.absent(),
                Value<int> count = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ApiUsageCompanion(
                day: day,
                model: model,
                count: count,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String day,
                required String model,
                Value<int> count = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ApiUsageCompanion.insert(
                day: day,
                model: model,
                count: count,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ApiUsageTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ApiUsageTable,
      ApiUsageRow,
      $$ApiUsageTableFilterComposer,
      $$ApiUsageTableOrderingComposer,
      $$ApiUsageTableAnnotationComposer,
      $$ApiUsageTableCreateCompanionBuilder,
      $$ApiUsageTableUpdateCompanionBuilder,
      (ApiUsageRow, BaseReferences<_$AppDatabase, $ApiUsageTable, ApiUsageRow>),
      ApiUsageRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ProfilesTableTableManager get profiles =>
      $$ProfilesTableTableManager(_db, _db.profiles);
  $$ProfileHistoryTableTableManager get profileHistory =>
      $$ProfileHistoryTableTableManager(_db, _db.profileHistory);
  $$GoalsTableTableManager get goals =>
      $$GoalsTableTableManager(_db, _db.goals);
  $$MemoryFactsTableTableManager get memoryFacts =>
      $$MemoryFactsTableTableManager(_db, _db.memoryFacts);
  $$DietPlansTableTableManager get dietPlans =>
      $$DietPlansTableTableManager(_db, _db.dietPlans);
  $$DiaryEntriesTableTableManager get diaryEntries =>
      $$DiaryEntriesTableTableManager(_db, _db.diaryEntries);
  $$WorkoutsTableTableManager get workouts =>
      $$WorkoutsTableTableManager(_db, _db.workouts);
  $$WorkoutResultsTableTableManager get workoutResults =>
      $$WorkoutResultsTableTableManager(_db, _db.workoutResults);
  $$NotificationScheduleTableTableManager get notificationSchedule =>
      $$NotificationScheduleTableTableManager(_db, _db.notificationSchedule);
  $$MessagesTableTableManager get messages =>
      $$MessagesTableTableManager(_db, _db.messages);
  $$ConversationSummariesTableTableManager get conversationSummaries =>
      $$ConversationSummariesTableTableManager(_db, _db.conversationSummaries);
  $$ApiUsageTableTableManager get apiUsage =>
      $$ApiUsageTableTableManager(_db, _db.apiUsage);
}
