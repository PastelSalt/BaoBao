// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ProfilesTable extends Profiles with TableInfo<$ProfilesTable, Profile> {
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
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'),
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta('displayName');
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 40),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastActiveAtMeta = const VerificationMeta('lastActiveAt');
  @override
  late final GeneratedColumn<DateTime> lastActiveAt = GeneratedColumn<DateTime>(
    'last_active_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, displayName, createdAt, lastActiveAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'profiles';
  @override
  VerificationContext validateIntegrity(Insertable<Profile> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(data['display_name']!, _displayNameMeta),
      );
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('last_active_at')) {
      context.handle(
        _lastActiveAtMeta,
        lastActiveAt.isAcceptableOrUnknown(data['last_active_at']!, _lastActiveAtMeta),
      );
    } else if (isInserting) {
      context.missing(_lastActiveAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Profile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Profile(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      lastActiveAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_active_at'],
      )!,
    );
  }

  @override
  $ProfilesTable createAlias(String alias) {
    return $ProfilesTable(attachedDatabase, alias);
  }
}

class Profile extends DataClass implements Insertable<Profile> {
  final int id;
  final String displayName;
  final DateTime createdAt;
  final DateTime lastActiveAt;
  const Profile({
    required this.id,
    required this.displayName,
    required this.createdAt,
    required this.lastActiveAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['display_name'] = Variable<String>(displayName);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['last_active_at'] = Variable<DateTime>(lastActiveAt);
    return map;
  }

  ProfilesCompanion toCompanion(bool nullToAbsent) {
    return ProfilesCompanion(
      id: Value(id),
      displayName: Value(displayName),
      createdAt: Value(createdAt),
      lastActiveAt: Value(lastActiveAt),
    );
  }

  factory Profile.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Profile(
      id: serializer.fromJson<int>(json['id']),
      displayName: serializer.fromJson<String>(json['displayName']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      lastActiveAt: serializer.fromJson<DateTime>(json['lastActiveAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'displayName': serializer.toJson<String>(displayName),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'lastActiveAt': serializer.toJson<DateTime>(lastActiveAt),
    };
  }

  Profile copyWith({int? id, String? displayName, DateTime? createdAt, DateTime? lastActiveAt}) =>
      Profile(
        id: id ?? this.id,
        displayName: displayName ?? this.displayName,
        createdAt: createdAt ?? this.createdAt,
        lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      );
  Profile copyWithCompanion(ProfilesCompanion data) {
    return Profile(
      id: data.id.present ? data.id.value : this.id,
      displayName: data.displayName.present ? data.displayName.value : this.displayName,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      lastActiveAt: data.lastActiveAt.present ? data.lastActiveAt.value : this.lastActiveAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Profile(')
          ..write('id: $id, ')
          ..write('displayName: $displayName, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastActiveAt: $lastActiveAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, displayName, createdAt, lastActiveAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Profile &&
          other.id == this.id &&
          other.displayName == this.displayName &&
          other.createdAt == this.createdAt &&
          other.lastActiveAt == this.lastActiveAt);
}

class ProfilesCompanion extends UpdateCompanion<Profile> {
  final Value<int> id;
  final Value<String> displayName;
  final Value<DateTime> createdAt;
  final Value<DateTime> lastActiveAt;
  const ProfilesCompanion({
    this.id = const Value.absent(),
    this.displayName = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastActiveAt = const Value.absent(),
  });
  ProfilesCompanion.insert({
    this.id = const Value.absent(),
    required String displayName,
    required DateTime createdAt,
    required DateTime lastActiveAt,
  }) : displayName = Value(displayName),
       createdAt = Value(createdAt),
       lastActiveAt = Value(lastActiveAt);
  static Insertable<Profile> custom({
    Expression<int>? id,
    Expression<String>? displayName,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? lastActiveAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (displayName != null) 'display_name': displayName,
      if (createdAt != null) 'created_at': createdAt,
      if (lastActiveAt != null) 'last_active_at': lastActiveAt,
    });
  }

  ProfilesCompanion copyWith({
    Value<int>? id,
    Value<String>? displayName,
    Value<DateTime>? createdAt,
    Value<DateTime>? lastActiveAt,
  }) {
    return ProfilesCompanion(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      createdAt: createdAt ?? this.createdAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (lastActiveAt.present) {
      map['last_active_at'] = Variable<DateTime>(lastActiveAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProfilesCompanion(')
          ..write('id: $id, ')
          ..write('displayName: $displayName, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastActiveAt: $lastActiveAt')
          ..write(')'))
        .toString();
  }
}

class $WalletsTable extends Wallets with TableInfo<$WalletsTable, Wallet> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WalletsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _profileIdMeta = const VerificationMeta('profileId');
  @override
  late final GeneratedColumn<int> profileId = GeneratedColumn<int>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES profiles (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _balanceMeta = const VerificationMeta('balance');
  @override
  late final GeneratedColumn<int> balance = GeneratedColumn<int>(
    'balance',
    aliasedName,
    false,
    check: () => ComparableExpr(balance).isBiggerOrEqualValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [profileId, balance];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'wallets';
  @override
  VerificationContext validateIntegrity(Insertable<Wallet> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    }
    if (data.containsKey('balance')) {
      context.handle(_balanceMeta, balance.isAcceptableOrUnknown(data['balance']!, _balanceMeta));
    } else if (isInserting) {
      context.missing(_balanceMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {profileId};
  @override
  Wallet map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Wallet(
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}profile_id'],
      )!,
      balance: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}balance'],
      )!,
    );
  }

  @override
  $WalletsTable createAlias(String alias) {
    return $WalletsTable(attachedDatabase, alias);
  }
}

class Wallet extends DataClass implements Insertable<Wallet> {
  final int profileId;
  final int balance;
  const Wallet({required this.profileId, required this.balance});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['profile_id'] = Variable<int>(profileId);
    map['balance'] = Variable<int>(balance);
    return map;
  }

  WalletsCompanion toCompanion(bool nullToAbsent) {
    return WalletsCompanion(profileId: Value(profileId), balance: Value(balance));
  }

  factory Wallet.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Wallet(
      profileId: serializer.fromJson<int>(json['profileId']),
      balance: serializer.fromJson<int>(json['balance']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'profileId': serializer.toJson<int>(profileId),
      'balance': serializer.toJson<int>(balance),
    };
  }

  Wallet copyWith({int? profileId, int? balance}) =>
      Wallet(profileId: profileId ?? this.profileId, balance: balance ?? this.balance);
  Wallet copyWithCompanion(WalletsCompanion data) {
    return Wallet(
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      balance: data.balance.present ? data.balance.value : this.balance,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Wallet(')
          ..write('profileId: $profileId, ')
          ..write('balance: $balance')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(profileId, balance);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Wallet && other.profileId == this.profileId && other.balance == this.balance);
}

class WalletsCompanion extends UpdateCompanion<Wallet> {
  final Value<int> profileId;
  final Value<int> balance;
  const WalletsCompanion({
    this.profileId = const Value.absent(),
    this.balance = const Value.absent(),
  });
  WalletsCompanion.insert({this.profileId = const Value.absent(), required int balance})
    : balance = Value(balance);
  static Insertable<Wallet> custom({Expression<int>? profileId, Expression<int>? balance}) {
    return RawValuesInsertable({
      if (profileId != null) 'profile_id': profileId,
      if (balance != null) 'balance': balance,
    });
  }

  WalletsCompanion copyWith({Value<int>? profileId, Value<int>? balance}) {
    return WalletsCompanion(
      profileId: profileId ?? this.profileId,
      balance: balance ?? this.balance,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (profileId.present) {
      map['profile_id'] = Variable<int>(profileId.value);
    }
    if (balance.present) {
      map['balance'] = Variable<int>(balance.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WalletsCompanion(')
          ..write('profileId: $profileId, ')
          ..write('balance: $balance')
          ..write(')'))
        .toString();
  }
}

class $LedgerEntriesTable extends LedgerEntries with TableInfo<$LedgerEntriesTable, LedgerEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LedgerEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _profileIdMeta = const VerificationMeta('profileId');
  @override
  late final GeneratedColumn<int> profileId = GeneratedColumn<int>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES profiles (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'),
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<int> amount = GeneratedColumn<int>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
    'reason',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [profileId, id, amount, reason, createdAt];
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
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta, amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('reason')) {
      context.handle(_reasonMeta, reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta));
    } else if (isInserting) {
      context.missing(_reasonMeta);
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
  LedgerEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LedgerEntry(
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}profile_id'],
      )!,
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount'],
      )!,
      reason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $LedgerEntriesTable createAlias(String alias) {
    return $LedgerEntriesTable(attachedDatabase, alias);
  }
}

class LedgerEntry extends DataClass implements Insertable<LedgerEntry> {
  final int profileId;
  final int id;

  /// Positive for ✷ earned, negative for ✷ spent.
  final int amount;

  /// A short machine-readable reason, such as `purchase:blue_bao` or `claw:win`.
  final String reason;
  final DateTime createdAt;
  const LedgerEntry({
    required this.profileId,
    required this.id,
    required this.amount,
    required this.reason,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['profile_id'] = Variable<int>(profileId);
    map['id'] = Variable<int>(id);
    map['amount'] = Variable<int>(amount);
    map['reason'] = Variable<String>(reason);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  LedgerEntriesCompanion toCompanion(bool nullToAbsent) {
    return LedgerEntriesCompanion(
      profileId: Value(profileId),
      id: Value(id),
      amount: Value(amount),
      reason: Value(reason),
      createdAt: Value(createdAt),
    );
  }

  factory LedgerEntry.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LedgerEntry(
      profileId: serializer.fromJson<int>(json['profileId']),
      id: serializer.fromJson<int>(json['id']),
      amount: serializer.fromJson<int>(json['amount']),
      reason: serializer.fromJson<String>(json['reason']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'profileId': serializer.toJson<int>(profileId),
      'id': serializer.toJson<int>(id),
      'amount': serializer.toJson<int>(amount),
      'reason': serializer.toJson<String>(reason),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  LedgerEntry copyWith({
    int? profileId,
    int? id,
    int? amount,
    String? reason,
    DateTime? createdAt,
  }) => LedgerEntry(
    profileId: profileId ?? this.profileId,
    id: id ?? this.id,
    amount: amount ?? this.amount,
    reason: reason ?? this.reason,
    createdAt: createdAt ?? this.createdAt,
  );
  LedgerEntry copyWithCompanion(LedgerEntriesCompanion data) {
    return LedgerEntry(
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      id: data.id.present ? data.id.value : this.id,
      amount: data.amount.present ? data.amount.value : this.amount,
      reason: data.reason.present ? data.reason.value : this.reason,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LedgerEntry(')
          ..write('profileId: $profileId, ')
          ..write('id: $id, ')
          ..write('amount: $amount, ')
          ..write('reason: $reason, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(profileId, id, amount, reason, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LedgerEntry &&
          other.profileId == this.profileId &&
          other.id == this.id &&
          other.amount == this.amount &&
          other.reason == this.reason &&
          other.createdAt == this.createdAt);
}

class LedgerEntriesCompanion extends UpdateCompanion<LedgerEntry> {
  final Value<int> profileId;
  final Value<int> id;
  final Value<int> amount;
  final Value<String> reason;
  final Value<DateTime> createdAt;
  const LedgerEntriesCompanion({
    this.profileId = const Value.absent(),
    this.id = const Value.absent(),
    this.amount = const Value.absent(),
    this.reason = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  LedgerEntriesCompanion.insert({
    required int profileId,
    this.id = const Value.absent(),
    required int amount,
    required String reason,
    required DateTime createdAt,
  }) : profileId = Value(profileId),
       amount = Value(amount),
       reason = Value(reason),
       createdAt = Value(createdAt);
  static Insertable<LedgerEntry> custom({
    Expression<int>? profileId,
    Expression<int>? id,
    Expression<int>? amount,
    Expression<String>? reason,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (profileId != null) 'profile_id': profileId,
      if (id != null) 'id': id,
      if (amount != null) 'amount': amount,
      if (reason != null) 'reason': reason,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  LedgerEntriesCompanion copyWith({
    Value<int>? profileId,
    Value<int>? id,
    Value<int>? amount,
    Value<String>? reason,
    Value<DateTime>? createdAt,
  }) {
    return LedgerEntriesCompanion(
      profileId: profileId ?? this.profileId,
      id: id ?? this.id,
      amount: amount ?? this.amount,
      reason: reason ?? this.reason,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (profileId.present) {
      map['profile_id'] = Variable<int>(profileId.value);
    }
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (amount.present) {
      map['amount'] = Variable<int>(amount.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LedgerEntriesCompanion(')
          ..write('profileId: $profileId, ')
          ..write('id: $id, ')
          ..write('amount: $amount, ')
          ..write('reason: $reason, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $MoodEntriesTable extends MoodEntries with TableInfo<$MoodEntriesTable, MoodEntryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MoodEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _profileIdMeta = const VerificationMeta('profileId');
  @override
  late final GeneratedColumn<int> profileId = GeneratedColumn<int>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES profiles (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'),
  );
  static const VerificationMeta _moodMeta = const VerificationMeta('mood');
  @override
  late final GeneratedColumn<String> mood = GeneratedColumn<String>(
    'mood',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weightDeltaMeta = const VerificationMeta('weightDelta');
  @override
  late final GeneratedColumn<int> weightDelta = GeneratedColumn<int>(
    'weight_delta',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [profileId, id, mood, weightDelta, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'mood_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<MoodEntryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('mood')) {
      context.handle(_moodMeta, mood.isAcceptableOrUnknown(data['mood']!, _moodMeta));
    } else if (isInserting) {
      context.missing(_moodMeta);
    }
    if (data.containsKey('weight_delta')) {
      context.handle(
        _weightDeltaMeta,
        weightDelta.isAcceptableOrUnknown(data['weight_delta']!, _weightDeltaMeta),
      );
    } else if (isInserting) {
      context.missing(_weightDeltaMeta);
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
  MoodEntryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MoodEntryRow(
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}profile_id'],
      )!,
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      mood: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}mood'])!,
      weightDelta: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}weight_delta'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $MoodEntriesTable createAlias(String alias) {
    return $MoodEntriesTable(attachedDatabase, alias);
  }
}

class MoodEntryRow extends DataClass implements Insertable<MoodEntryRow> {
  final int profileId;
  final int id;
  final String mood;
  final int weightDelta;
  final DateTime createdAt;
  const MoodEntryRow({
    required this.profileId,
    required this.id,
    required this.mood,
    required this.weightDelta,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['profile_id'] = Variable<int>(profileId);
    map['id'] = Variable<int>(id);
    map['mood'] = Variable<String>(mood);
    map['weight_delta'] = Variable<int>(weightDelta);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  MoodEntriesCompanion toCompanion(bool nullToAbsent) {
    return MoodEntriesCompanion(
      profileId: Value(profileId),
      id: Value(id),
      mood: Value(mood),
      weightDelta: Value(weightDelta),
      createdAt: Value(createdAt),
    );
  }

  factory MoodEntryRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MoodEntryRow(
      profileId: serializer.fromJson<int>(json['profileId']),
      id: serializer.fromJson<int>(json['id']),
      mood: serializer.fromJson<String>(json['mood']),
      weightDelta: serializer.fromJson<int>(json['weightDelta']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'profileId': serializer.toJson<int>(profileId),
      'id': serializer.toJson<int>(id),
      'mood': serializer.toJson<String>(mood),
      'weightDelta': serializer.toJson<int>(weightDelta),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  MoodEntryRow copyWith({
    int? profileId,
    int? id,
    String? mood,
    int? weightDelta,
    DateTime? createdAt,
  }) => MoodEntryRow(
    profileId: profileId ?? this.profileId,
    id: id ?? this.id,
    mood: mood ?? this.mood,
    weightDelta: weightDelta ?? this.weightDelta,
    createdAt: createdAt ?? this.createdAt,
  );
  MoodEntryRow copyWithCompanion(MoodEntriesCompanion data) {
    return MoodEntryRow(
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      id: data.id.present ? data.id.value : this.id,
      mood: data.mood.present ? data.mood.value : this.mood,
      weightDelta: data.weightDelta.present ? data.weightDelta.value : this.weightDelta,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MoodEntryRow(')
          ..write('profileId: $profileId, ')
          ..write('id: $id, ')
          ..write('mood: $mood, ')
          ..write('weightDelta: $weightDelta, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(profileId, id, mood, weightDelta, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MoodEntryRow &&
          other.profileId == this.profileId &&
          other.id == this.id &&
          other.mood == this.mood &&
          other.weightDelta == this.weightDelta &&
          other.createdAt == this.createdAt);
}

class MoodEntriesCompanion extends UpdateCompanion<MoodEntryRow> {
  final Value<int> profileId;
  final Value<int> id;
  final Value<String> mood;
  final Value<int> weightDelta;
  final Value<DateTime> createdAt;
  const MoodEntriesCompanion({
    this.profileId = const Value.absent(),
    this.id = const Value.absent(),
    this.mood = const Value.absent(),
    this.weightDelta = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  MoodEntriesCompanion.insert({
    required int profileId,
    this.id = const Value.absent(),
    required String mood,
    required int weightDelta,
    required DateTime createdAt,
  }) : profileId = Value(profileId),
       mood = Value(mood),
       weightDelta = Value(weightDelta),
       createdAt = Value(createdAt);
  static Insertable<MoodEntryRow> custom({
    Expression<int>? profileId,
    Expression<int>? id,
    Expression<String>? mood,
    Expression<int>? weightDelta,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (profileId != null) 'profile_id': profileId,
      if (id != null) 'id': id,
      if (mood != null) 'mood': mood,
      if (weightDelta != null) 'weight_delta': weightDelta,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  MoodEntriesCompanion copyWith({
    Value<int>? profileId,
    Value<int>? id,
    Value<String>? mood,
    Value<int>? weightDelta,
    Value<DateTime>? createdAt,
  }) {
    return MoodEntriesCompanion(
      profileId: profileId ?? this.profileId,
      id: id ?? this.id,
      mood: mood ?? this.mood,
      weightDelta: weightDelta ?? this.weightDelta,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (profileId.present) {
      map['profile_id'] = Variable<int>(profileId.value);
    }
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (mood.present) {
      map['mood'] = Variable<String>(mood.value);
    }
    if (weightDelta.present) {
      map['weight_delta'] = Variable<int>(weightDelta.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MoodEntriesCompanion(')
          ..write('profileId: $profileId, ')
          ..write('id: $id, ')
          ..write('mood: $mood, ')
          ..write('weightDelta: $weightDelta, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $EmotionalStatesTable extends EmotionalStates
    with TableInfo<$EmotionalStatesTable, EmotionalStateRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EmotionalStatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _profileIdMeta = const VerificationMeta('profileId');
  @override
  late final GeneratedColumn<int> profileId = GeneratedColumn<int>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES profiles (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _weightMeta = const VerificationMeta('weight');
  @override
  late final GeneratedColumn<int> weight = GeneratedColumn<int>(
    'weight',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _consecutiveNegativeMeta = const VerificationMeta(
    'consecutiveNegative',
  );
  @override
  late final GeneratedColumn<int> consecutiveNegative = GeneratedColumn<int>(
    'consecutive_negative',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastInterventionAtMeta = const VerificationMeta(
    'lastInterventionAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastInterventionAt = GeneratedColumn<DateTime>(
    'last_intervention_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    profileId,
    weight,
    consecutiveNegative,
    lastInterventionAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'emotional_states';
  @override
  VerificationContext validateIntegrity(
    Insertable<EmotionalStateRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    }
    if (data.containsKey('weight')) {
      context.handle(_weightMeta, weight.isAcceptableOrUnknown(data['weight']!, _weightMeta));
    }
    if (data.containsKey('consecutive_negative')) {
      context.handle(
        _consecutiveNegativeMeta,
        consecutiveNegative.isAcceptableOrUnknown(
          data['consecutive_negative']!,
          _consecutiveNegativeMeta,
        ),
      );
    }
    if (data.containsKey('last_intervention_at')) {
      context.handle(
        _lastInterventionAtMeta,
        lastInterventionAt.isAcceptableOrUnknown(
          data['last_intervention_at']!,
          _lastInterventionAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {profileId};
  @override
  EmotionalStateRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EmotionalStateRow(
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}profile_id'],
      )!,
      weight: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}weight'],
      )!,
      consecutiveNegative: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}consecutive_negative'],
      )!,
      lastInterventionAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_intervention_at'],
      ),
    );
  }

  @override
  $EmotionalStatesTable createAlias(String alias) {
    return $EmotionalStatesTable(attachedDatabase, alias);
  }
}

class EmotionalStateRow extends DataClass implements Insertable<EmotionalStateRow> {
  final int profileId;
  final int weight;
  final int consecutiveNegative;
  final DateTime? lastInterventionAt;
  const EmotionalStateRow({
    required this.profileId,
    required this.weight,
    required this.consecutiveNegative,
    this.lastInterventionAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['profile_id'] = Variable<int>(profileId);
    map['weight'] = Variable<int>(weight);
    map['consecutive_negative'] = Variable<int>(consecutiveNegative);
    if (!nullToAbsent || lastInterventionAt != null) {
      map['last_intervention_at'] = Variable<DateTime>(lastInterventionAt);
    }
    return map;
  }

  EmotionalStatesCompanion toCompanion(bool nullToAbsent) {
    return EmotionalStatesCompanion(
      profileId: Value(profileId),
      weight: Value(weight),
      consecutiveNegative: Value(consecutiveNegative),
      lastInterventionAt: lastInterventionAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastInterventionAt),
    );
  }

  factory EmotionalStateRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EmotionalStateRow(
      profileId: serializer.fromJson<int>(json['profileId']),
      weight: serializer.fromJson<int>(json['weight']),
      consecutiveNegative: serializer.fromJson<int>(json['consecutiveNegative']),
      lastInterventionAt: serializer.fromJson<DateTime?>(json['lastInterventionAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'profileId': serializer.toJson<int>(profileId),
      'weight': serializer.toJson<int>(weight),
      'consecutiveNegative': serializer.toJson<int>(consecutiveNegative),
      'lastInterventionAt': serializer.toJson<DateTime?>(lastInterventionAt),
    };
  }

  EmotionalStateRow copyWith({
    int? profileId,
    int? weight,
    int? consecutiveNegative,
    Value<DateTime?> lastInterventionAt = const Value.absent(),
  }) => EmotionalStateRow(
    profileId: profileId ?? this.profileId,
    weight: weight ?? this.weight,
    consecutiveNegative: consecutiveNegative ?? this.consecutiveNegative,
    lastInterventionAt: lastInterventionAt.present
        ? lastInterventionAt.value
        : this.lastInterventionAt,
  );
  EmotionalStateRow copyWithCompanion(EmotionalStatesCompanion data) {
    return EmotionalStateRow(
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      weight: data.weight.present ? data.weight.value : this.weight,
      consecutiveNegative: data.consecutiveNegative.present
          ? data.consecutiveNegative.value
          : this.consecutiveNegative,
      lastInterventionAt: data.lastInterventionAt.present
          ? data.lastInterventionAt.value
          : this.lastInterventionAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EmotionalStateRow(')
          ..write('profileId: $profileId, ')
          ..write('weight: $weight, ')
          ..write('consecutiveNegative: $consecutiveNegative, ')
          ..write('lastInterventionAt: $lastInterventionAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(profileId, weight, consecutiveNegative, lastInterventionAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EmotionalStateRow &&
          other.profileId == this.profileId &&
          other.weight == this.weight &&
          other.consecutiveNegative == this.consecutiveNegative &&
          other.lastInterventionAt == this.lastInterventionAt);
}

class EmotionalStatesCompanion extends UpdateCompanion<EmotionalStateRow> {
  final Value<int> profileId;
  final Value<int> weight;
  final Value<int> consecutiveNegative;
  final Value<DateTime?> lastInterventionAt;
  const EmotionalStatesCompanion({
    this.profileId = const Value.absent(),
    this.weight = const Value.absent(),
    this.consecutiveNegative = const Value.absent(),
    this.lastInterventionAt = const Value.absent(),
  });
  EmotionalStatesCompanion.insert({
    this.profileId = const Value.absent(),
    this.weight = const Value.absent(),
    this.consecutiveNegative = const Value.absent(),
    this.lastInterventionAt = const Value.absent(),
  });
  static Insertable<EmotionalStateRow> custom({
    Expression<int>? profileId,
    Expression<int>? weight,
    Expression<int>? consecutiveNegative,
    Expression<DateTime>? lastInterventionAt,
  }) {
    return RawValuesInsertable({
      if (profileId != null) 'profile_id': profileId,
      if (weight != null) 'weight': weight,
      if (consecutiveNegative != null) 'consecutive_negative': consecutiveNegative,
      if (lastInterventionAt != null) 'last_intervention_at': lastInterventionAt,
    });
  }

  EmotionalStatesCompanion copyWith({
    Value<int>? profileId,
    Value<int>? weight,
    Value<int>? consecutiveNegative,
    Value<DateTime?>? lastInterventionAt,
  }) {
    return EmotionalStatesCompanion(
      profileId: profileId ?? this.profileId,
      weight: weight ?? this.weight,
      consecutiveNegative: consecutiveNegative ?? this.consecutiveNegative,
      lastInterventionAt: lastInterventionAt ?? this.lastInterventionAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (profileId.present) {
      map['profile_id'] = Variable<int>(profileId.value);
    }
    if (weight.present) {
      map['weight'] = Variable<int>(weight.value);
    }
    if (consecutiveNegative.present) {
      map['consecutive_negative'] = Variable<int>(consecutiveNegative.value);
    }
    if (lastInterventionAt.present) {
      map['last_intervention_at'] = Variable<DateTime>(lastInterventionAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EmotionalStatesCompanion(')
          ..write('profileId: $profileId, ')
          ..write('weight: $weight, ')
          ..write('consecutiveNegative: $consecutiveNegative, ')
          ..write('lastInterventionAt: $lastInterventionAt')
          ..write(')'))
        .toString();
  }
}

class $OwnedItemsTable extends OwnedItems with TableInfo<$OwnedItemsTable, OwnedItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OwnedItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _profileIdMeta = const VerificationMeta('profileId');
  @override
  late final GeneratedColumn<int> profileId = GeneratedColumn<int>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES profiles (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
    'item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _acquiredAtMeta = const VerificationMeta('acquiredAt');
  @override
  late final GeneratedColumn<DateTime> acquiredAt = GeneratedColumn<DateTime>(
    'acquired_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [profileId, itemId, acquiredAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'owned_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<OwnedItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('item_id')) {
      context.handle(_itemIdMeta, itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta));
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('acquired_at')) {
      context.handle(
        _acquiredAtMeta,
        acquiredAt.isAcceptableOrUnknown(data['acquired_at']!, _acquiredAtMeta),
      );
    } else if (isInserting) {
      context.missing(_acquiredAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {profileId, itemId};
  @override
  OwnedItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OwnedItem(
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}profile_id'],
      )!,
      itemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_id'],
      )!,
      acquiredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}acquired_at'],
      )!,
    );
  }

  @override
  $OwnedItemsTable createAlias(String alias) {
    return $OwnedItemsTable(attachedDatabase, alias);
  }
}

class OwnedItem extends DataClass implements Insertable<OwnedItem> {
  final int profileId;
  final String itemId;
  final DateTime acquiredAt;
  const OwnedItem({required this.profileId, required this.itemId, required this.acquiredAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['profile_id'] = Variable<int>(profileId);
    map['item_id'] = Variable<String>(itemId);
    map['acquired_at'] = Variable<DateTime>(acquiredAt);
    return map;
  }

  OwnedItemsCompanion toCompanion(bool nullToAbsent) {
    return OwnedItemsCompanion(
      profileId: Value(profileId),
      itemId: Value(itemId),
      acquiredAt: Value(acquiredAt),
    );
  }

  factory OwnedItem.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OwnedItem(
      profileId: serializer.fromJson<int>(json['profileId']),
      itemId: serializer.fromJson<String>(json['itemId']),
      acquiredAt: serializer.fromJson<DateTime>(json['acquiredAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'profileId': serializer.toJson<int>(profileId),
      'itemId': serializer.toJson<String>(itemId),
      'acquiredAt': serializer.toJson<DateTime>(acquiredAt),
    };
  }

  OwnedItem copyWith({int? profileId, String? itemId, DateTime? acquiredAt}) => OwnedItem(
    profileId: profileId ?? this.profileId,
    itemId: itemId ?? this.itemId,
    acquiredAt: acquiredAt ?? this.acquiredAt,
  );
  OwnedItem copyWithCompanion(OwnedItemsCompanion data) {
    return OwnedItem(
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      acquiredAt: data.acquiredAt.present ? data.acquiredAt.value : this.acquiredAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OwnedItem(')
          ..write('profileId: $profileId, ')
          ..write('itemId: $itemId, ')
          ..write('acquiredAt: $acquiredAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(profileId, itemId, acquiredAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OwnedItem &&
          other.profileId == this.profileId &&
          other.itemId == this.itemId &&
          other.acquiredAt == this.acquiredAt);
}

class OwnedItemsCompanion extends UpdateCompanion<OwnedItem> {
  final Value<int> profileId;
  final Value<String> itemId;
  final Value<DateTime> acquiredAt;
  final Value<int> rowid;
  const OwnedItemsCompanion({
    this.profileId = const Value.absent(),
    this.itemId = const Value.absent(),
    this.acquiredAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OwnedItemsCompanion.insert({
    required int profileId,
    required String itemId,
    required DateTime acquiredAt,
    this.rowid = const Value.absent(),
  }) : profileId = Value(profileId),
       itemId = Value(itemId),
       acquiredAt = Value(acquiredAt);
  static Insertable<OwnedItem> custom({
    Expression<int>? profileId,
    Expression<String>? itemId,
    Expression<DateTime>? acquiredAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (profileId != null) 'profile_id': profileId,
      if (itemId != null) 'item_id': itemId,
      if (acquiredAt != null) 'acquired_at': acquiredAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OwnedItemsCompanion copyWith({
    Value<int>? profileId,
    Value<String>? itemId,
    Value<DateTime>? acquiredAt,
    Value<int>? rowid,
  }) {
    return OwnedItemsCompanion(
      profileId: profileId ?? this.profileId,
      itemId: itemId ?? this.itemId,
      acquiredAt: acquiredAt ?? this.acquiredAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (profileId.present) {
      map['profile_id'] = Variable<int>(profileId.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (acquiredAt.present) {
      map['acquired_at'] = Variable<DateTime>(acquiredAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OwnedItemsCompanion(')
          ..write('profileId: $profileId, ')
          ..write('itemId: $itemId, ')
          ..write('acquiredAt: $acquiredAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SelectionsTable extends Selections with TableInfo<$SelectionsTable, Selection> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SelectionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _profileIdMeta = const VerificationMeta('profileId');
  @override
  late final GeneratedColumn<int> profileId = GeneratedColumn<int>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES profiles (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _slotMeta = const VerificationMeta('slot');
  @override
  late final GeneratedColumn<String> slot = GeneratedColumn<String>(
    'slot',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
    'item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [profileId, slot, itemId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'selections';
  @override
  VerificationContext validateIntegrity(
    Insertable<Selection> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('slot')) {
      context.handle(_slotMeta, slot.isAcceptableOrUnknown(data['slot']!, _slotMeta));
    } else if (isInserting) {
      context.missing(_slotMeta);
    }
    if (data.containsKey('item_id')) {
      context.handle(_itemIdMeta, itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta));
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {profileId, slot};
  @override
  Selection map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Selection(
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}profile_id'],
      )!,
      slot: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}slot'])!,
      itemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_id'],
      )!,
    );
  }

  @override
  $SelectionsTable createAlias(String alias) {
    return $SelectionsTable(attachedDatabase, alias);
  }
}

class Selection extends DataClass implements Insertable<Selection> {
  final int profileId;
  final String slot;
  final String itemId;
  const Selection({required this.profileId, required this.slot, required this.itemId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['profile_id'] = Variable<int>(profileId);
    map['slot'] = Variable<String>(slot);
    map['item_id'] = Variable<String>(itemId);
    return map;
  }

  SelectionsCompanion toCompanion(bool nullToAbsent) {
    return SelectionsCompanion(
      profileId: Value(profileId),
      slot: Value(slot),
      itemId: Value(itemId),
    );
  }

  factory Selection.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Selection(
      profileId: serializer.fromJson<int>(json['profileId']),
      slot: serializer.fromJson<String>(json['slot']),
      itemId: serializer.fromJson<String>(json['itemId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'profileId': serializer.toJson<int>(profileId),
      'slot': serializer.toJson<String>(slot),
      'itemId': serializer.toJson<String>(itemId),
    };
  }

  Selection copyWith({int? profileId, String? slot, String? itemId}) => Selection(
    profileId: profileId ?? this.profileId,
    slot: slot ?? this.slot,
    itemId: itemId ?? this.itemId,
  );
  Selection copyWithCompanion(SelectionsCompanion data) {
    return Selection(
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      slot: data.slot.present ? data.slot.value : this.slot,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Selection(')
          ..write('profileId: $profileId, ')
          ..write('slot: $slot, ')
          ..write('itemId: $itemId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(profileId, slot, itemId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Selection &&
          other.profileId == this.profileId &&
          other.slot == this.slot &&
          other.itemId == this.itemId);
}

class SelectionsCompanion extends UpdateCompanion<Selection> {
  final Value<int> profileId;
  final Value<String> slot;
  final Value<String> itemId;
  final Value<int> rowid;
  const SelectionsCompanion({
    this.profileId = const Value.absent(),
    this.slot = const Value.absent(),
    this.itemId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SelectionsCompanion.insert({
    required int profileId,
    required String slot,
    required String itemId,
    this.rowid = const Value.absent(),
  }) : profileId = Value(profileId),
       slot = Value(slot),
       itemId = Value(itemId);
  static Insertable<Selection> custom({
    Expression<int>? profileId,
    Expression<String>? slot,
    Expression<String>? itemId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (profileId != null) 'profile_id': profileId,
      if (slot != null) 'slot': slot,
      if (itemId != null) 'item_id': itemId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SelectionsCompanion copyWith({
    Value<int>? profileId,
    Value<String>? slot,
    Value<String>? itemId,
    Value<int>? rowid,
  }) {
    return SelectionsCompanion(
      profileId: profileId ?? this.profileId,
      slot: slot ?? this.slot,
      itemId: itemId ?? this.itemId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (profileId.present) {
      map['profile_id'] = Variable<int>(profileId.value);
    }
    if (slot.present) {
      map['slot'] = Variable<String>(slot.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SelectionsCompanion(')
          ..write('profileId: $profileId, ')
          ..write('slot: $slot, ')
          ..write('itemId: $itemId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ConversationProgressTable extends ConversationProgress
    with TableInfo<$ConversationProgressTable, ConversationProgressData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ConversationProgressTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _profileIdMeta = const VerificationMeta('profileId');
  @override
  late final GeneratedColumn<int> profileId = GeneratedColumn<int>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES profiles (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _treeIdMeta = const VerificationMeta('treeId');
  @override
  late final GeneratedColumn<String> treeId = GeneratedColumn<String>(
    'tree_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastNodeIdMeta = const VerificationMeta('lastNodeId');
  @override
  late final GeneratedColumn<String> lastNodeId = GeneratedColumn<String>(
    'last_node_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pathMeta = const VerificationMeta('path');
  @override
  late final GeneratedColumn<String> path = GeneratedColumn<String>(
    'path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [profileId, treeId, lastNodeId, path, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'conversation_progress';
  @override
  VerificationContext validateIntegrity(
    Insertable<ConversationProgressData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    }
    if (data.containsKey('tree_id')) {
      context.handle(_treeIdMeta, treeId.isAcceptableOrUnknown(data['tree_id']!, _treeIdMeta));
    } else if (isInserting) {
      context.missing(_treeIdMeta);
    }
    if (data.containsKey('last_node_id')) {
      context.handle(
        _lastNodeIdMeta,
        lastNodeId.isAcceptableOrUnknown(data['last_node_id']!, _lastNodeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_lastNodeIdMeta);
    }
    if (data.containsKey('path')) {
      context.handle(_pathMeta, path.isAcceptableOrUnknown(data['path']!, _pathMeta));
    } else if (isInserting) {
      context.missing(_pathMeta);
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
  Set<GeneratedColumn> get $primaryKey => {profileId};
  @override
  ConversationProgressData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ConversationProgressData(
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}profile_id'],
      )!,
      treeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tree_id'],
      )!,
      lastNodeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_node_id'],
      )!,
      path: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}path'])!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ConversationProgressTable createAlias(String alias) {
    return $ConversationProgressTable(attachedDatabase, alias);
  }
}

class ConversationProgressData extends DataClass implements Insertable<ConversationProgressData> {
  final int profileId;
  final String treeId;
  final String lastNodeId;

  /// JSON array of the node ids visited, in order.
  final String path;
  final DateTime updatedAt;
  const ConversationProgressData({
    required this.profileId,
    required this.treeId,
    required this.lastNodeId,
    required this.path,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['profile_id'] = Variable<int>(profileId);
    map['tree_id'] = Variable<String>(treeId);
    map['last_node_id'] = Variable<String>(lastNodeId);
    map['path'] = Variable<String>(path);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ConversationProgressCompanion toCompanion(bool nullToAbsent) {
    return ConversationProgressCompanion(
      profileId: Value(profileId),
      treeId: Value(treeId),
      lastNodeId: Value(lastNodeId),
      path: Value(path),
      updatedAt: Value(updatedAt),
    );
  }

  factory ConversationProgressData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ConversationProgressData(
      profileId: serializer.fromJson<int>(json['profileId']),
      treeId: serializer.fromJson<String>(json['treeId']),
      lastNodeId: serializer.fromJson<String>(json['lastNodeId']),
      path: serializer.fromJson<String>(json['path']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'profileId': serializer.toJson<int>(profileId),
      'treeId': serializer.toJson<String>(treeId),
      'lastNodeId': serializer.toJson<String>(lastNodeId),
      'path': serializer.toJson<String>(path),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ConversationProgressData copyWith({
    int? profileId,
    String? treeId,
    String? lastNodeId,
    String? path,
    DateTime? updatedAt,
  }) => ConversationProgressData(
    profileId: profileId ?? this.profileId,
    treeId: treeId ?? this.treeId,
    lastNodeId: lastNodeId ?? this.lastNodeId,
    path: path ?? this.path,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ConversationProgressData copyWithCompanion(ConversationProgressCompanion data) {
    return ConversationProgressData(
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      treeId: data.treeId.present ? data.treeId.value : this.treeId,
      lastNodeId: data.lastNodeId.present ? data.lastNodeId.value : this.lastNodeId,
      path: data.path.present ? data.path.value : this.path,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ConversationProgressData(')
          ..write('profileId: $profileId, ')
          ..write('treeId: $treeId, ')
          ..write('lastNodeId: $lastNodeId, ')
          ..write('path: $path, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(profileId, treeId, lastNodeId, path, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ConversationProgressData &&
          other.profileId == this.profileId &&
          other.treeId == this.treeId &&
          other.lastNodeId == this.lastNodeId &&
          other.path == this.path &&
          other.updatedAt == this.updatedAt);
}

class ConversationProgressCompanion extends UpdateCompanion<ConversationProgressData> {
  final Value<int> profileId;
  final Value<String> treeId;
  final Value<String> lastNodeId;
  final Value<String> path;
  final Value<DateTime> updatedAt;
  const ConversationProgressCompanion({
    this.profileId = const Value.absent(),
    this.treeId = const Value.absent(),
    this.lastNodeId = const Value.absent(),
    this.path = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  ConversationProgressCompanion.insert({
    this.profileId = const Value.absent(),
    required String treeId,
    required String lastNodeId,
    required String path,
    required DateTime updatedAt,
  }) : treeId = Value(treeId),
       lastNodeId = Value(lastNodeId),
       path = Value(path),
       updatedAt = Value(updatedAt);
  static Insertable<ConversationProgressData> custom({
    Expression<int>? profileId,
    Expression<String>? treeId,
    Expression<String>? lastNodeId,
    Expression<String>? path,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (profileId != null) 'profile_id': profileId,
      if (treeId != null) 'tree_id': treeId,
      if (lastNodeId != null) 'last_node_id': lastNodeId,
      if (path != null) 'path': path,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  ConversationProgressCompanion copyWith({
    Value<int>? profileId,
    Value<String>? treeId,
    Value<String>? lastNodeId,
    Value<String>? path,
    Value<DateTime>? updatedAt,
  }) {
    return ConversationProgressCompanion(
      profileId: profileId ?? this.profileId,
      treeId: treeId ?? this.treeId,
      lastNodeId: lastNodeId ?? this.lastNodeId,
      path: path ?? this.path,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (profileId.present) {
      map['profile_id'] = Variable<int>(profileId.value);
    }
    if (treeId.present) {
      map['tree_id'] = Variable<String>(treeId.value);
    }
    if (lastNodeId.present) {
      map['last_node_id'] = Variable<String>(lastNodeId.value);
    }
    if (path.present) {
      map['path'] = Variable<String>(path.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ConversationProgressCompanion(')
          ..write('profileId: $profileId, ')
          ..write('treeId: $treeId, ')
          ..write('lastNodeId: $lastNodeId, ')
          ..write('path: $path, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $ClawStatesTable extends ClawStates with TableInfo<$ClawStatesTable, ClawState> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ClawStatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _profileIdMeta = const VerificationMeta('profileId');
  @override
  late final GeneratedColumn<int> profileId = GeneratedColumn<int>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES profiles (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _triesMeta = const VerificationMeta('tries');
  @override
  late final GeneratedColumn<int> tries = GeneratedColumn<int>(
    'tries',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nextRefillAtMeta = const VerificationMeta('nextRefillAt');
  @override
  late final GeneratedColumn<DateTime> nextRefillAt = GeneratedColumn<DateTime>(
    'next_refill_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _purchasesTodayMeta = const VerificationMeta('purchasesToday');
  @override
  late final GeneratedColumn<int> purchasesToday = GeneratedColumn<int>(
    'purchases_today',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _purchasesDayMeta = const VerificationMeta('purchasesDay');
  @override
  late final GeneratedColumn<String> purchasesDay = GeneratedColumn<String>(
    'purchases_day',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    profileId,
    tries,
    nextRefillAt,
    purchasesToday,
    purchasesDay,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'claw_states';
  @override
  VerificationContext validateIntegrity(
    Insertable<ClawState> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    }
    if (data.containsKey('tries')) {
      context.handle(_triesMeta, tries.isAcceptableOrUnknown(data['tries']!, _triesMeta));
    } else if (isInserting) {
      context.missing(_triesMeta);
    }
    if (data.containsKey('next_refill_at')) {
      context.handle(
        _nextRefillAtMeta,
        nextRefillAt.isAcceptableOrUnknown(data['next_refill_at']!, _nextRefillAtMeta),
      );
    }
    if (data.containsKey('purchases_today')) {
      context.handle(
        _purchasesTodayMeta,
        purchasesToday.isAcceptableOrUnknown(data['purchases_today']!, _purchasesTodayMeta),
      );
    }
    if (data.containsKey('purchases_day')) {
      context.handle(
        _purchasesDayMeta,
        purchasesDay.isAcceptableOrUnknown(data['purchases_day']!, _purchasesDayMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {profileId};
  @override
  ClawState map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ClawState(
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}profile_id'],
      )!,
      tries: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}tries'])!,
      nextRefillAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}next_refill_at'],
      ),
      purchasesToday: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}purchases_today'],
      )!,
      purchasesDay: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}purchases_day'],
      ),
    );
  }

  @override
  $ClawStatesTable createAlias(String alias) {
    return $ClawStatesTable(attachedDatabase, alias);
  }
}

class ClawState extends DataClass implements Insertable<ClawState> {
  final int profileId;
  final int tries;
  final DateTime? nextRefillAt;
  final int purchasesToday;
  final String? purchasesDay;
  const ClawState({
    required this.profileId,
    required this.tries,
    this.nextRefillAt,
    required this.purchasesToday,
    this.purchasesDay,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['profile_id'] = Variable<int>(profileId);
    map['tries'] = Variable<int>(tries);
    if (!nullToAbsent || nextRefillAt != null) {
      map['next_refill_at'] = Variable<DateTime>(nextRefillAt);
    }
    map['purchases_today'] = Variable<int>(purchasesToday);
    if (!nullToAbsent || purchasesDay != null) {
      map['purchases_day'] = Variable<String>(purchasesDay);
    }
    return map;
  }

  ClawStatesCompanion toCompanion(bool nullToAbsent) {
    return ClawStatesCompanion(
      profileId: Value(profileId),
      tries: Value(tries),
      nextRefillAt: nextRefillAt == null && nullToAbsent
          ? const Value.absent()
          : Value(nextRefillAt),
      purchasesToday: Value(purchasesToday),
      purchasesDay: purchasesDay == null && nullToAbsent
          ? const Value.absent()
          : Value(purchasesDay),
    );
  }

  factory ClawState.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ClawState(
      profileId: serializer.fromJson<int>(json['profileId']),
      tries: serializer.fromJson<int>(json['tries']),
      nextRefillAt: serializer.fromJson<DateTime?>(json['nextRefillAt']),
      purchasesToday: serializer.fromJson<int>(json['purchasesToday']),
      purchasesDay: serializer.fromJson<String?>(json['purchasesDay']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'profileId': serializer.toJson<int>(profileId),
      'tries': serializer.toJson<int>(tries),
      'nextRefillAt': serializer.toJson<DateTime?>(nextRefillAt),
      'purchasesToday': serializer.toJson<int>(purchasesToday),
      'purchasesDay': serializer.toJson<String?>(purchasesDay),
    };
  }

  ClawState copyWith({
    int? profileId,
    int? tries,
    Value<DateTime?> nextRefillAt = const Value.absent(),
    int? purchasesToday,
    Value<String?> purchasesDay = const Value.absent(),
  }) => ClawState(
    profileId: profileId ?? this.profileId,
    tries: tries ?? this.tries,
    nextRefillAt: nextRefillAt.present ? nextRefillAt.value : this.nextRefillAt,
    purchasesToday: purchasesToday ?? this.purchasesToday,
    purchasesDay: purchasesDay.present ? purchasesDay.value : this.purchasesDay,
  );
  ClawState copyWithCompanion(ClawStatesCompanion data) {
    return ClawState(
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      tries: data.tries.present ? data.tries.value : this.tries,
      nextRefillAt: data.nextRefillAt.present ? data.nextRefillAt.value : this.nextRefillAt,
      purchasesToday: data.purchasesToday.present ? data.purchasesToday.value : this.purchasesToday,
      purchasesDay: data.purchasesDay.present ? data.purchasesDay.value : this.purchasesDay,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ClawState(')
          ..write('profileId: $profileId, ')
          ..write('tries: $tries, ')
          ..write('nextRefillAt: $nextRefillAt, ')
          ..write('purchasesToday: $purchasesToday, ')
          ..write('purchasesDay: $purchasesDay')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(profileId, tries, nextRefillAt, purchasesToday, purchasesDay);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ClawState &&
          other.profileId == this.profileId &&
          other.tries == this.tries &&
          other.nextRefillAt == this.nextRefillAt &&
          other.purchasesToday == this.purchasesToday &&
          other.purchasesDay == this.purchasesDay);
}

class ClawStatesCompanion extends UpdateCompanion<ClawState> {
  final Value<int> profileId;
  final Value<int> tries;
  final Value<DateTime?> nextRefillAt;
  final Value<int> purchasesToday;
  final Value<String?> purchasesDay;
  const ClawStatesCompanion({
    this.profileId = const Value.absent(),
    this.tries = const Value.absent(),
    this.nextRefillAt = const Value.absent(),
    this.purchasesToday = const Value.absent(),
    this.purchasesDay = const Value.absent(),
  });
  ClawStatesCompanion.insert({
    this.profileId = const Value.absent(),
    required int tries,
    this.nextRefillAt = const Value.absent(),
    this.purchasesToday = const Value.absent(),
    this.purchasesDay = const Value.absent(),
  }) : tries = Value(tries);
  static Insertable<ClawState> custom({
    Expression<int>? profileId,
    Expression<int>? tries,
    Expression<DateTime>? nextRefillAt,
    Expression<int>? purchasesToday,
    Expression<String>? purchasesDay,
  }) {
    return RawValuesInsertable({
      if (profileId != null) 'profile_id': profileId,
      if (tries != null) 'tries': tries,
      if (nextRefillAt != null) 'next_refill_at': nextRefillAt,
      if (purchasesToday != null) 'purchases_today': purchasesToday,
      if (purchasesDay != null) 'purchases_day': purchasesDay,
    });
  }

  ClawStatesCompanion copyWith({
    Value<int>? profileId,
    Value<int>? tries,
    Value<DateTime?>? nextRefillAt,
    Value<int>? purchasesToday,
    Value<String?>? purchasesDay,
  }) {
    return ClawStatesCompanion(
      profileId: profileId ?? this.profileId,
      tries: tries ?? this.tries,
      nextRefillAt: nextRefillAt ?? this.nextRefillAt,
      purchasesToday: purchasesToday ?? this.purchasesToday,
      purchasesDay: purchasesDay ?? this.purchasesDay,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (profileId.present) {
      map['profile_id'] = Variable<int>(profileId.value);
    }
    if (tries.present) {
      map['tries'] = Variable<int>(tries.value);
    }
    if (nextRefillAt.present) {
      map['next_refill_at'] = Variable<DateTime>(nextRefillAt.value);
    }
    if (purchasesToday.present) {
      map['purchases_today'] = Variable<int>(purchasesToday.value);
    }
    if (purchasesDay.present) {
      map['purchases_day'] = Variable<String>(purchasesDay.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ClawStatesCompanion(')
          ..write('profileId: $profileId, ')
          ..write('tries: $tries, ')
          ..write('nextRefillAt: $nextRefillAt, ')
          ..write('purchasesToday: $purchasesToday, ')
          ..write('purchasesDay: $purchasesDay')
          ..write(')'))
        .toString();
  }
}

class $ClawStatsTable extends ClawStats with TableInfo<$ClawStatsTable, ClawStat> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ClawStatsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _profileIdMeta = const VerificationMeta('profileId');
  @override
  late final GeneratedColumn<int> profileId = GeneratedColumn<int>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES profiles (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _playsMeta = const VerificationMeta('plays');
  @override
  late final GeneratedColumn<int> plays = GeneratedColumn<int>(
    'plays',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _winsMeta = const VerificationMeta('wins');
  @override
  late final GeneratedColumn<int> wins = GeneratedColumn<int>(
    'wins',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _earningsMeta = const VerificationMeta('earnings');
  @override
  late final GeneratedColumn<int> earnings = GeneratedColumn<int>(
    'earnings',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _bestWinMeta = const VerificationMeta('bestWin');
  @override
  late final GeneratedColumn<int> bestWin = GeneratedColumn<int>(
    'best_win',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [profileId, plays, wins, earnings, bestWin];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'claw_stats';
  @override
  VerificationContext validateIntegrity(Insertable<ClawStat> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    }
    if (data.containsKey('plays')) {
      context.handle(_playsMeta, plays.isAcceptableOrUnknown(data['plays']!, _playsMeta));
    }
    if (data.containsKey('wins')) {
      context.handle(_winsMeta, wins.isAcceptableOrUnknown(data['wins']!, _winsMeta));
    }
    if (data.containsKey('earnings')) {
      context.handle(
        _earningsMeta,
        earnings.isAcceptableOrUnknown(data['earnings']!, _earningsMeta),
      );
    }
    if (data.containsKey('best_win')) {
      context.handle(_bestWinMeta, bestWin.isAcceptableOrUnknown(data['best_win']!, _bestWinMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {profileId};
  @override
  ClawStat map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ClawStat(
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}profile_id'],
      )!,
      plays: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}plays'])!,
      wins: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}wins'])!,
      earnings: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}earnings'],
      )!,
      bestWin: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}best_win'],
      )!,
    );
  }

  @override
  $ClawStatsTable createAlias(String alias) {
    return $ClawStatsTable(attachedDatabase, alias);
  }
}

class ClawStat extends DataClass implements Insertable<ClawStat> {
  final int profileId;
  final int plays;
  final int wins;
  final int earnings;
  final int bestWin;
  const ClawStat({
    required this.profileId,
    required this.plays,
    required this.wins,
    required this.earnings,
    required this.bestWin,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['profile_id'] = Variable<int>(profileId);
    map['plays'] = Variable<int>(plays);
    map['wins'] = Variable<int>(wins);
    map['earnings'] = Variable<int>(earnings);
    map['best_win'] = Variable<int>(bestWin);
    return map;
  }

  ClawStatsCompanion toCompanion(bool nullToAbsent) {
    return ClawStatsCompanion(
      profileId: Value(profileId),
      plays: Value(plays),
      wins: Value(wins),
      earnings: Value(earnings),
      bestWin: Value(bestWin),
    );
  }

  factory ClawStat.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ClawStat(
      profileId: serializer.fromJson<int>(json['profileId']),
      plays: serializer.fromJson<int>(json['plays']),
      wins: serializer.fromJson<int>(json['wins']),
      earnings: serializer.fromJson<int>(json['earnings']),
      bestWin: serializer.fromJson<int>(json['bestWin']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'profileId': serializer.toJson<int>(profileId),
      'plays': serializer.toJson<int>(plays),
      'wins': serializer.toJson<int>(wins),
      'earnings': serializer.toJson<int>(earnings),
      'bestWin': serializer.toJson<int>(bestWin),
    };
  }

  ClawStat copyWith({int? profileId, int? plays, int? wins, int? earnings, int? bestWin}) =>
      ClawStat(
        profileId: profileId ?? this.profileId,
        plays: plays ?? this.plays,
        wins: wins ?? this.wins,
        earnings: earnings ?? this.earnings,
        bestWin: bestWin ?? this.bestWin,
      );
  ClawStat copyWithCompanion(ClawStatsCompanion data) {
    return ClawStat(
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      plays: data.plays.present ? data.plays.value : this.plays,
      wins: data.wins.present ? data.wins.value : this.wins,
      earnings: data.earnings.present ? data.earnings.value : this.earnings,
      bestWin: data.bestWin.present ? data.bestWin.value : this.bestWin,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ClawStat(')
          ..write('profileId: $profileId, ')
          ..write('plays: $plays, ')
          ..write('wins: $wins, ')
          ..write('earnings: $earnings, ')
          ..write('bestWin: $bestWin')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(profileId, plays, wins, earnings, bestWin);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ClawStat &&
          other.profileId == this.profileId &&
          other.plays == this.plays &&
          other.wins == this.wins &&
          other.earnings == this.earnings &&
          other.bestWin == this.bestWin);
}

class ClawStatsCompanion extends UpdateCompanion<ClawStat> {
  final Value<int> profileId;
  final Value<int> plays;
  final Value<int> wins;
  final Value<int> earnings;
  final Value<int> bestWin;
  const ClawStatsCompanion({
    this.profileId = const Value.absent(),
    this.plays = const Value.absent(),
    this.wins = const Value.absent(),
    this.earnings = const Value.absent(),
    this.bestWin = const Value.absent(),
  });
  ClawStatsCompanion.insert({
    this.profileId = const Value.absent(),
    this.plays = const Value.absent(),
    this.wins = const Value.absent(),
    this.earnings = const Value.absent(),
    this.bestWin = const Value.absent(),
  });
  static Insertable<ClawStat> custom({
    Expression<int>? profileId,
    Expression<int>? plays,
    Expression<int>? wins,
    Expression<int>? earnings,
    Expression<int>? bestWin,
  }) {
    return RawValuesInsertable({
      if (profileId != null) 'profile_id': profileId,
      if (plays != null) 'plays': plays,
      if (wins != null) 'wins': wins,
      if (earnings != null) 'earnings': earnings,
      if (bestWin != null) 'best_win': bestWin,
    });
  }

  ClawStatsCompanion copyWith({
    Value<int>? profileId,
    Value<int>? plays,
    Value<int>? wins,
    Value<int>? earnings,
    Value<int>? bestWin,
  }) {
    return ClawStatsCompanion(
      profileId: profileId ?? this.profileId,
      plays: plays ?? this.plays,
      wins: wins ?? this.wins,
      earnings: earnings ?? this.earnings,
      bestWin: bestWin ?? this.bestWin,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (profileId.present) {
      map['profile_id'] = Variable<int>(profileId.value);
    }
    if (plays.present) {
      map['plays'] = Variable<int>(plays.value);
    }
    if (wins.present) {
      map['wins'] = Variable<int>(wins.value);
    }
    if (earnings.present) {
      map['earnings'] = Variable<int>(earnings.value);
    }
    if (bestWin.present) {
      map['best_win'] = Variable<int>(bestWin.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ClawStatsCompanion(')
          ..write('profileId: $profileId, ')
          ..write('plays: $plays, ')
          ..write('wins: $wins, ')
          ..write('earnings: $earnings, ')
          ..write('bestWin: $bestWin')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ProfilesTable profiles = $ProfilesTable(this);
  late final $WalletsTable wallets = $WalletsTable(this);
  late final $LedgerEntriesTable ledgerEntries = $LedgerEntriesTable(this);
  late final $MoodEntriesTable moodEntries = $MoodEntriesTable(this);
  late final $EmotionalStatesTable emotionalStates = $EmotionalStatesTable(this);
  late final $OwnedItemsTable ownedItems = $OwnedItemsTable(this);
  late final $SelectionsTable selections = $SelectionsTable(this);
  late final $ConversationProgressTable conversationProgress = $ConversationProgressTable(this);
  late final $ClawStatesTable clawStates = $ClawStatesTable(this);
  late final $ClawStatsTable clawStats = $ClawStatsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    profiles,
    wallets,
    ledgerEntries,
    moodEntries,
    emotionalStates,
    ownedItems,
    selections,
    conversationProgress,
    clawStates,
    clawStats,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName('profiles', limitUpdateKind: UpdateKind.delete),
      result: [TableUpdate('wallets', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName('profiles', limitUpdateKind: UpdateKind.delete),
      result: [TableUpdate('ledger_entries', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName('profiles', limitUpdateKind: UpdateKind.delete),
      result: [TableUpdate('mood_entries', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName('profiles', limitUpdateKind: UpdateKind.delete),
      result: [TableUpdate('emotional_states', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName('profiles', limitUpdateKind: UpdateKind.delete),
      result: [TableUpdate('owned_items', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName('profiles', limitUpdateKind: UpdateKind.delete),
      result: [TableUpdate('selections', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName('profiles', limitUpdateKind: UpdateKind.delete),
      result: [TableUpdate('conversation_progress', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName('profiles', limitUpdateKind: UpdateKind.delete),
      result: [TableUpdate('claw_states', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName('profiles', limitUpdateKind: UpdateKind.delete),
      result: [TableUpdate('claw_stats', kind: UpdateKind.delete)],
    ),
  ]);
  @override
  DriftDatabaseOptions get options => const DriftDatabaseOptions(storeDateTimeAsText: true);
}

typedef $$ProfilesTableCreateCompanionBuilder = ProfilesCompanion Function({
  Value<int> id,
  required String displayName,
  required DateTime createdAt,
  required DateTime lastActiveAt,
});
typedef $$ProfilesTableUpdateCompanionBuilder = ProfilesCompanion Function({
  Value<int> id,
  Value<String> displayName,
  Value<DateTime> createdAt,
  Value<DateTime> lastActiveAt,
});

final class $$ProfilesTableReferences
    extends BaseReferences<_$AppDatabase, $ProfilesTable, Profile> {
  $$ProfilesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$WalletsTable, List<Wallet>> _walletsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.wallets, aliasName: 'profiles__id__wallets__profile_id');

  $$WalletsTableProcessedTableManager get walletsRefs {
    final manager = $$WalletsTableTableManager(
      $_db,
      $_db.wallets,
    ).filter((f) => f.profileId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_walletsRefsTable($_db));
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$LedgerEntriesTable, List<LedgerEntry>> _ledgerEntriesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.ledgerEntries,
    aliasName: 'profiles__id__ledger_entries__profile_id',
  );

  $$LedgerEntriesTableProcessedTableManager get ledgerEntriesRefs {
    final manager = $$LedgerEntriesTableTableManager(
      $_db,
      $_db.ledgerEntries,
    ).filter((f) => f.profileId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_ledgerEntriesRefsTable($_db));
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$MoodEntriesTable, List<MoodEntryRow>> _moodEntriesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.moodEntries,
    aliasName: 'profiles__id__mood_entries__profile_id',
  );

  $$MoodEntriesTableProcessedTableManager get moodEntriesRefs {
    final manager = $$MoodEntriesTableTableManager(
      $_db,
      $_db.moodEntries,
    ).filter((f) => f.profileId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_moodEntriesRefsTable($_db));
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$EmotionalStatesTable, List<EmotionalStateRow>>
  _emotionalStatesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.emotionalStates,
    aliasName: 'profiles__id__emotional_states__profile_id',
  );

  $$EmotionalStatesTableProcessedTableManager get emotionalStatesRefs {
    final manager = $$EmotionalStatesTableTableManager(
      $_db,
      $_db.emotionalStates,
    ).filter((f) => f.profileId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_emotionalStatesRefsTable($_db));
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$OwnedItemsTable, List<OwnedItem>> _ownedItemsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.ownedItems,
    aliasName: 'profiles__id__owned_items__profile_id',
  );

  $$OwnedItemsTableProcessedTableManager get ownedItemsRefs {
    final manager = $$OwnedItemsTableTableManager(
      $_db,
      $_db.ownedItems,
    ).filter((f) => f.profileId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_ownedItemsRefsTable($_db));
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$SelectionsTable, List<Selection>> _selectionsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.selections,
    aliasName: 'profiles__id__selections__profile_id',
  );

  $$SelectionsTableProcessedTableManager get selectionsRefs {
    final manager = $$SelectionsTableTableManager(
      $_db,
      $_db.selections,
    ).filter((f) => f.profileId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_selectionsRefsTable($_db));
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$ConversationProgressTable, List<ConversationProgressData>>
  _conversationProgressRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.conversationProgress,
    aliasName: 'profiles__id__conversation_progress__profile_id',
  );

  $$ConversationProgressTableProcessedTableManager get conversationProgressRefs {
    final manager = $$ConversationProgressTableTableManager(
      $_db,
      $_db.conversationProgress,
    ).filter((f) => f.profileId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_conversationProgressRefsTable($_db));
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$ClawStatesTable, List<ClawState>> _clawStatesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.clawStates,
    aliasName: 'profiles__id__claw_states__profile_id',
  );

  $$ClawStatesTableProcessedTableManager get clawStatesRefs {
    final manager = $$ClawStatesTableTableManager(
      $_db,
      $_db.clawStates,
    ).filter((f) => f.profileId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_clawStatesRefsTable($_db));
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$ClawStatsTable, List<ClawStat>> _clawStatsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.clawStats,
    aliasName: 'profiles__id__claw_stats__profile_id',
  );

  $$ClawStatsTableProcessedTableManager get clawStatsRefs {
    final manager = $$ClawStatsTableTableManager(
      $_db,
      $_db.clawStats,
    ).filter((f) => f.profileId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_clawStatsRefsTable($_db));
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$ProfilesTableFilterComposer extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get displayName =>
      $composableBuilder(column: $table.displayName, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastActiveAt =>
      $composableBuilder(column: $table.lastActiveAt, builder: (column) => ColumnFilters(column));

  Expression<bool> walletsRefs(Expression<bool> Function($$WalletsTableFilterComposer f) f) {
    final $$WalletsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.wallets,
      getReferencedColumn: (t) => t.profileId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$WalletsTableFilterComposer(
            $db: $db,
            $table: $db.wallets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> ledgerEntriesRefs(
    Expression<bool> Function($$LedgerEntriesTableFilterComposer f) f,
  ) {
    final $$LedgerEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.ledgerEntries,
      getReferencedColumn: (t) => t.profileId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$LedgerEntriesTableFilterComposer(
            $db: $db,
            $table: $db.ledgerEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> moodEntriesRefs(
    Expression<bool> Function($$MoodEntriesTableFilterComposer f) f,
  ) {
    final $$MoodEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.moodEntries,
      getReferencedColumn: (t) => t.profileId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$MoodEntriesTableFilterComposer(
            $db: $db,
            $table: $db.moodEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> emotionalStatesRefs(
    Expression<bool> Function($$EmotionalStatesTableFilterComposer f) f,
  ) {
    final $$EmotionalStatesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.emotionalStates,
      getReferencedColumn: (t) => t.profileId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$EmotionalStatesTableFilterComposer(
            $db: $db,
            $table: $db.emotionalStates,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> ownedItemsRefs(Expression<bool> Function($$OwnedItemsTableFilterComposer f) f) {
    final $$OwnedItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.ownedItems,
      getReferencedColumn: (t) => t.profileId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$OwnedItemsTableFilterComposer(
            $db: $db,
            $table: $db.ownedItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> selectionsRefs(Expression<bool> Function($$SelectionsTableFilterComposer f) f) {
    final $$SelectionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.selections,
      getReferencedColumn: (t) => t.profileId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$SelectionsTableFilterComposer(
            $db: $db,
            $table: $db.selections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> conversationProgressRefs(
    Expression<bool> Function($$ConversationProgressTableFilterComposer f) f,
  ) {
    final $$ConversationProgressTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.conversationProgress,
      getReferencedColumn: (t) => t.profileId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$ConversationProgressTableFilterComposer(
            $db: $db,
            $table: $db.conversationProgress,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> clawStatesRefs(Expression<bool> Function($$ClawStatesTableFilterComposer f) f) {
    final $$ClawStatesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.clawStates,
      getReferencedColumn: (t) => t.profileId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$ClawStatesTableFilterComposer(
            $db: $db,
            $table: $db.clawStates,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> clawStatsRefs(Expression<bool> Function($$ClawStatsTableFilterComposer f) f) {
    final $$ClawStatsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.clawStats,
      getReferencedColumn: (t) => t.profileId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$ClawStatsTableFilterComposer(
            $db: $db,
            $table: $db.clawStats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProfilesTableOrderingComposer extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get displayName =>
      $composableBuilder(column: $table.displayName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastActiveAt =>
      $composableBuilder(column: $table.lastActiveAt, builder: (column) => ColumnOrderings(column));
}

class $$ProfilesTableAnnotationComposer extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get displayName =>
      $composableBuilder(column: $table.displayName, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastActiveAt =>
      $composableBuilder(column: $table.lastActiveAt, builder: (column) => column);

  Expression<T> walletsRefs<T extends Object>(
    Expression<T> Function($$WalletsTableAnnotationComposer a) f,
  ) {
    final $$WalletsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.wallets,
      getReferencedColumn: (t) => t.profileId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$WalletsTableAnnotationComposer(
            $db: $db,
            $table: $db.wallets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> ledgerEntriesRefs<T extends Object>(
    Expression<T> Function($$LedgerEntriesTableAnnotationComposer a) f,
  ) {
    final $$LedgerEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.ledgerEntries,
      getReferencedColumn: (t) => t.profileId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$LedgerEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.ledgerEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> moodEntriesRefs<T extends Object>(
    Expression<T> Function($$MoodEntriesTableAnnotationComposer a) f,
  ) {
    final $$MoodEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.moodEntries,
      getReferencedColumn: (t) => t.profileId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$MoodEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.moodEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> emotionalStatesRefs<T extends Object>(
    Expression<T> Function($$EmotionalStatesTableAnnotationComposer a) f,
  ) {
    final $$EmotionalStatesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.emotionalStates,
      getReferencedColumn: (t) => t.profileId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$EmotionalStatesTableAnnotationComposer(
            $db: $db,
            $table: $db.emotionalStates,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> ownedItemsRefs<T extends Object>(
    Expression<T> Function($$OwnedItemsTableAnnotationComposer a) f,
  ) {
    final $$OwnedItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.ownedItems,
      getReferencedColumn: (t) => t.profileId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$OwnedItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.ownedItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> selectionsRefs<T extends Object>(
    Expression<T> Function($$SelectionsTableAnnotationComposer a) f,
  ) {
    final $$SelectionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.selections,
      getReferencedColumn: (t) => t.profileId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$SelectionsTableAnnotationComposer(
            $db: $db,
            $table: $db.selections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> conversationProgressRefs<T extends Object>(
    Expression<T> Function($$ConversationProgressTableAnnotationComposer a) f,
  ) {
    final $$ConversationProgressTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.conversationProgress,
      getReferencedColumn: (t) => t.profileId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$ConversationProgressTableAnnotationComposer(
            $db: $db,
            $table: $db.conversationProgress,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> clawStatesRefs<T extends Object>(
    Expression<T> Function($$ClawStatesTableAnnotationComposer a) f,
  ) {
    final $$ClawStatesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.clawStates,
      getReferencedColumn: (t) => t.profileId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$ClawStatesTableAnnotationComposer(
            $db: $db,
            $table: $db.clawStates,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> clawStatsRefs<T extends Object>(
    Expression<T> Function($$ClawStatsTableAnnotationComposer a) f,
  ) {
    final $$ClawStatsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.clawStats,
      getReferencedColumn: (t) => t.profileId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$ClawStatsTableAnnotationComposer(
            $db: $db,
            $table: $db.clawStats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProfilesTable,
          Profile,
          $$ProfilesTableFilterComposer,
          $$ProfilesTableOrderingComposer,
          $$ProfilesTableAnnotationComposer,
          $$ProfilesTableCreateCompanionBuilder,
          $$ProfilesTableUpdateCompanionBuilder,
          (Profile, $$ProfilesTableReferences),
          Profile,
          PrefetchHooks Function({
            bool walletsRefs,
            bool ledgerEntriesRefs,
            bool moodEntriesRefs,
            bool emotionalStatesRefs,
            bool ownedItemsRefs,
            bool selectionsRefs,
            bool conversationProgressRefs,
            bool clawStatesRefs,
            bool clawStatsRefs,
          })
        > {
  $$ProfilesTableTableManager(_$AppDatabase db, $ProfilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$ProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$ProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> lastActiveAt = const Value.absent(),
              }) => ProfilesCompanion(
                id: id,
                displayName: displayName,
                createdAt: createdAt,
                lastActiveAt: lastActiveAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String displayName,
                required DateTime createdAt,
                required DateTime lastActiveAt,
              }) => ProfilesCompanion.insert(
                id: id,
                displayName: displayName,
                createdAt: createdAt,
                lastActiveAt: lastActiveAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ProfilesTable, Profile>(table),
                  $$ProfilesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                walletsRefs = false,
                ledgerEntriesRefs = false,
                moodEntriesRefs = false,
                emotionalStatesRefs = false,
                ownedItemsRefs = false,
                selectionsRefs = false,
                conversationProgressRefs = false,
                clawStatesRefs = false,
                clawStatsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (walletsRefs) db.wallets,
                    if (ledgerEntriesRefs) db.ledgerEntries,
                    if (moodEntriesRefs) db.moodEntries,
                    if (emotionalStatesRefs) db.emotionalStates,
                    if (ownedItemsRefs) db.ownedItems,
                    if (selectionsRefs) db.selections,
                    if (conversationProgressRefs) db.conversationProgress,
                    if (clawStatesRefs) db.clawStates,
                    if (clawStatsRefs) db.clawStats,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (walletsRefs)
                        await $_getPrefetchedDataByColumns<
                          Profile,
                          $ProfilesTable,
                          Wallet,
                          $WalletsTable
                        >(
                          currentTable: table,
                          referencedTable: $$ProfilesTableReferences._walletsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProfilesTableReferences(db, table, p0).walletsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'profile_id',
                          typedResults: items,
                        ),
                      if (ledgerEntriesRefs)
                        await $_getPrefetchedDataByColumns<
                          Profile,
                          $ProfilesTable,
                          LedgerEntry,
                          $LedgerEntriesTable
                        >(
                          currentTable: table,
                          referencedTable: $$ProfilesTableReferences._ledgerEntriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProfilesTableReferences(db, table, p0).ledgerEntriesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'profile_id',
                          typedResults: items,
                        ),
                      if (moodEntriesRefs)
                        await $_getPrefetchedDataByColumns<
                          Profile,
                          $ProfilesTable,
                          MoodEntryRow,
                          $MoodEntriesTable
                        >(
                          currentTable: table,
                          referencedTable: $$ProfilesTableReferences._moodEntriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProfilesTableReferences(db, table, p0).moodEntriesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'profile_id',
                          typedResults: items,
                        ),
                      if (emotionalStatesRefs)
                        await $_getPrefetchedDataByColumns<
                          Profile,
                          $ProfilesTable,
                          EmotionalStateRow,
                          $EmotionalStatesTable
                        >(
                          currentTable: table,
                          referencedTable: $$ProfilesTableReferences._emotionalStatesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProfilesTableReferences(db, table, p0).emotionalStatesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'profile_id',
                          typedResults: items,
                        ),
                      if (ownedItemsRefs)
                        await $_getPrefetchedDataByColumns<
                          Profile,
                          $ProfilesTable,
                          OwnedItem,
                          $OwnedItemsTable
                        >(
                          currentTable: table,
                          referencedTable: $$ProfilesTableReferences._ownedItemsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProfilesTableReferences(db, table, p0).ownedItemsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'profile_id',
                          typedResults: items,
                        ),
                      if (selectionsRefs)
                        await $_getPrefetchedDataByColumns<
                          Profile,
                          $ProfilesTable,
                          Selection,
                          $SelectionsTable
                        >(
                          currentTable: table,
                          referencedTable: $$ProfilesTableReferences._selectionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProfilesTableReferences(db, table, p0).selectionsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'profile_id',
                          typedResults: items,
                        ),
                      if (conversationProgressRefs)
                        await $_getPrefetchedDataByColumns<
                          Profile,
                          $ProfilesTable,
                          ConversationProgressData,
                          $ConversationProgressTable
                        >(
                          currentTable: table,
                          referencedTable: $$ProfilesTableReferences._conversationProgressRefsTable(
                            db,
                          ),
                          managerFromTypedResult: (p0) =>
                              $$ProfilesTableReferences(db, table, p0).conversationProgressRefs,
                          currentColumn: 'id',
                          referencedColumn: 'profile_id',
                          typedResults: items,
                        ),
                      if (clawStatesRefs)
                        await $_getPrefetchedDataByColumns<
                          Profile,
                          $ProfilesTable,
                          ClawState,
                          $ClawStatesTable
                        >(
                          currentTable: table,
                          referencedTable: $$ProfilesTableReferences._clawStatesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProfilesTableReferences(db, table, p0).clawStatesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'profile_id',
                          typedResults: items,
                        ),
                      if (clawStatsRefs)
                        await $_getPrefetchedDataByColumns<
                          Profile,
                          $ProfilesTable,
                          ClawStat,
                          $ClawStatsTable
                        >(
                          currentTable: table,
                          referencedTable: $$ProfilesTableReferences._clawStatsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProfilesTableReferences(db, table, p0).clawStatsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'profile_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProfilesTable,
      Profile,
      $$ProfilesTableFilterComposer,
      $$ProfilesTableOrderingComposer,
      $$ProfilesTableAnnotationComposer,
      $$ProfilesTableCreateCompanionBuilder,
      $$ProfilesTableUpdateCompanionBuilder,
      (Profile, $$ProfilesTableReferences),
      Profile,
      PrefetchHooks Function({
        bool walletsRefs,
        bool ledgerEntriesRefs,
        bool moodEntriesRefs,
        bool emotionalStatesRefs,
        bool ownedItemsRefs,
        bool selectionsRefs,
        bool conversationProgressRefs,
        bool clawStatesRefs,
        bool clawStatsRefs,
      })
    >;
typedef $$WalletsTableCreateCompanionBuilder = WalletsCompanion Function({
  Value<int> profileId,
  required int balance,
});
typedef $$WalletsTableUpdateCompanionBuilder = WalletsCompanion Function({
  Value<int> profileId,
  Value<int> balance,
});

final class $$WalletsTableReferences extends BaseReferences<_$AppDatabase, $WalletsTable, Wallet> {
  $$WalletsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProfilesTable _profileIdTable(_$AppDatabase db) =>
      db.profiles.createAlias('wallets__profile_id__profiles__id');

  $$ProfilesTableProcessedTableManager get profileId {
    final $_column = $_itemColumn<int>('profile_id')!;

    final manager = $$ProfilesTableTableManager(
      $_db,
      $_db.profiles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_profileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$WalletsTableFilterComposer extends Composer<_$AppDatabase, $WalletsTable> {
  $$WalletsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get balance =>
      $composableBuilder(column: $table.balance, builder: (column) => ColumnFilters(column));

  $$ProfilesTableFilterComposer get profileId {
    final $$ProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$ProfilesTableFilterComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WalletsTableOrderingComposer extends Composer<_$AppDatabase, $WalletsTable> {
  $$WalletsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get balance =>
      $composableBuilder(column: $table.balance, builder: (column) => ColumnOrderings(column));

  $$ProfilesTableOrderingComposer get profileId {
    final $$ProfilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$ProfilesTableOrderingComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WalletsTableAnnotationComposer extends Composer<_$AppDatabase, $WalletsTable> {
  $$WalletsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get balance =>
      $composableBuilder(column: $table.balance, builder: (column) => column);

  $$ProfilesTableAnnotationComposer get profileId {
    final $$ProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$ProfilesTableAnnotationComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WalletsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WalletsTable,
          Wallet,
          $$WalletsTableFilterComposer,
          $$WalletsTableOrderingComposer,
          $$WalletsTableAnnotationComposer,
          $$WalletsTableCreateCompanionBuilder,
          $$WalletsTableUpdateCompanionBuilder,
          (Wallet, $$WalletsTableReferences),
          Wallet,
          PrefetchHooks Function({bool profileId})
        > {
  $$WalletsTableTableManager(_$AppDatabase db, $WalletsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$WalletsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$WalletsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WalletsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> profileId = const Value.absent(),
            Value<int> balance = const Value.absent(),
          }) => WalletsCompanion(profileId: profileId, balance: balance),
          createCompanionCallback: ({
            Value<int> profileId = const Value.absent(),
            required int balance,
          }) => WalletsCompanion.insert(profileId: profileId, balance: balance),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$WalletsTable, Wallet>(table),
                  $$WalletsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({profileId = false}) {
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
                    if (profileId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.profileId,
                        referencedTable: $$WalletsTableReferences._profileIdTable(db),
                        referencedColumn: $$WalletsTableReferences._profileIdTable(db).id,
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

typedef $$WalletsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WalletsTable,
      Wallet,
      $$WalletsTableFilterComposer,
      $$WalletsTableOrderingComposer,
      $$WalletsTableAnnotationComposer,
      $$WalletsTableCreateCompanionBuilder,
      $$WalletsTableUpdateCompanionBuilder,
      (Wallet, $$WalletsTableReferences),
      Wallet,
      PrefetchHooks Function({bool profileId})
    >;
typedef $$LedgerEntriesTableCreateCompanionBuilder = LedgerEntriesCompanion Function({
  required int profileId,
  Value<int> id,
  required int amount,
  required String reason,
  required DateTime createdAt,
});
typedef $$LedgerEntriesTableUpdateCompanionBuilder = LedgerEntriesCompanion Function({
  Value<int> profileId,
  Value<int> id,
  Value<int> amount,
  Value<String> reason,
  Value<DateTime> createdAt,
});

final class $$LedgerEntriesTableReferences
    extends BaseReferences<_$AppDatabase, $LedgerEntriesTable, LedgerEntry> {
  $$LedgerEntriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProfilesTable _profileIdTable(_$AppDatabase db) =>
      db.profiles.createAlias('ledger_entries__profile_id__profiles__id');

  $$ProfilesTableProcessedTableManager get profileId {
    final $_column = $_itemColumn<int>('profile_id')!;

    final manager = $$ProfilesTableTableManager(
      $_db,
      $_db.profiles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_profileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$LedgerEntriesTableFilterComposer extends Composer<_$AppDatabase, $LedgerEntriesTable> {
  $$LedgerEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$ProfilesTableFilterComposer get profileId {
    final $$ProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$ProfilesTableFilterComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LedgerEntriesTableOrderingComposer extends Composer<_$AppDatabase, $LedgerEntriesTable> {
  $$LedgerEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$ProfilesTableOrderingComposer get profileId {
    final $$ProfilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$ProfilesTableOrderingComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LedgerEntriesTableAnnotationComposer extends Composer<_$AppDatabase, $LedgerEntriesTable> {
  $$LedgerEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$ProfilesTableAnnotationComposer get profileId {
    final $$ProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$ProfilesTableAnnotationComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LedgerEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LedgerEntriesTable,
          LedgerEntry,
          $$LedgerEntriesTableFilterComposer,
          $$LedgerEntriesTableOrderingComposer,
          $$LedgerEntriesTableAnnotationComposer,
          $$LedgerEntriesTableCreateCompanionBuilder,
          $$LedgerEntriesTableUpdateCompanionBuilder,
          (LedgerEntry, $$LedgerEntriesTableReferences),
          LedgerEntry,
          PrefetchHooks Function({bool profileId})
        > {
  $$LedgerEntriesTableTableManager(_$AppDatabase db, $LedgerEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$LedgerEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LedgerEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LedgerEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> profileId = const Value.absent(),
                Value<int> id = const Value.absent(),
                Value<int> amount = const Value.absent(),
                Value<String> reason = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => LedgerEntriesCompanion(
                profileId: profileId,
                id: id,
                amount: amount,
                reason: reason,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                required int profileId,
                Value<int> id = const Value.absent(),
                required int amount,
                required String reason,
                required DateTime createdAt,
              }) => LedgerEntriesCompanion.insert(
                profileId: profileId,
                id: id,
                amount: amount,
                reason: reason,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LedgerEntriesTable, LedgerEntry>(table),
                  $$LedgerEntriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({profileId = false}) {
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
                    if (profileId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.profileId,
                        referencedTable: $$LedgerEntriesTableReferences._profileIdTable(db),
                        referencedColumn: $$LedgerEntriesTableReferences._profileIdTable(db).id,
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

typedef $$LedgerEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LedgerEntriesTable,
      LedgerEntry,
      $$LedgerEntriesTableFilterComposer,
      $$LedgerEntriesTableOrderingComposer,
      $$LedgerEntriesTableAnnotationComposer,
      $$LedgerEntriesTableCreateCompanionBuilder,
      $$LedgerEntriesTableUpdateCompanionBuilder,
      (LedgerEntry, $$LedgerEntriesTableReferences),
      LedgerEntry,
      PrefetchHooks Function({bool profileId})
    >;
typedef $$MoodEntriesTableCreateCompanionBuilder = MoodEntriesCompanion Function({
  required int profileId,
  Value<int> id,
  required String mood,
  required int weightDelta,
  required DateTime createdAt,
});
typedef $$MoodEntriesTableUpdateCompanionBuilder = MoodEntriesCompanion Function({
  Value<int> profileId,
  Value<int> id,
  Value<String> mood,
  Value<int> weightDelta,
  Value<DateTime> createdAt,
});

final class $$MoodEntriesTableReferences
    extends BaseReferences<_$AppDatabase, $MoodEntriesTable, MoodEntryRow> {
  $$MoodEntriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProfilesTable _profileIdTable(_$AppDatabase db) =>
      db.profiles.createAlias('mood_entries__profile_id__profiles__id');

  $$ProfilesTableProcessedTableManager get profileId {
    final $_column = $_itemColumn<int>('profile_id')!;

    final manager = $$ProfilesTableTableManager(
      $_db,
      $_db.profiles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_profileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$MoodEntriesTableFilterComposer extends Composer<_$AppDatabase, $MoodEntriesTable> {
  $$MoodEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get mood =>
      $composableBuilder(column: $table.mood, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get weightDelta =>
      $composableBuilder(column: $table.weightDelta, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$ProfilesTableFilterComposer get profileId {
    final $$ProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$ProfilesTableFilterComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MoodEntriesTableOrderingComposer extends Composer<_$AppDatabase, $MoodEntriesTable> {
  $$MoodEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get mood =>
      $composableBuilder(column: $table.mood, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get weightDelta =>
      $composableBuilder(column: $table.weightDelta, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$ProfilesTableOrderingComposer get profileId {
    final $$ProfilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$ProfilesTableOrderingComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MoodEntriesTableAnnotationComposer extends Composer<_$AppDatabase, $MoodEntriesTable> {
  $$MoodEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get mood =>
      $composableBuilder(column: $table.mood, builder: (column) => column);

  GeneratedColumn<int> get weightDelta =>
      $composableBuilder(column: $table.weightDelta, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$ProfilesTableAnnotationComposer get profileId {
    final $$ProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$ProfilesTableAnnotationComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MoodEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MoodEntriesTable,
          MoodEntryRow,
          $$MoodEntriesTableFilterComposer,
          $$MoodEntriesTableOrderingComposer,
          $$MoodEntriesTableAnnotationComposer,
          $$MoodEntriesTableCreateCompanionBuilder,
          $$MoodEntriesTableUpdateCompanionBuilder,
          (MoodEntryRow, $$MoodEntriesTableReferences),
          MoodEntryRow,
          PrefetchHooks Function({bool profileId})
        > {
  $$MoodEntriesTableTableManager(_$AppDatabase db, $MoodEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$MoodEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$MoodEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MoodEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> profileId = const Value.absent(),
                Value<int> id = const Value.absent(),
                Value<String> mood = const Value.absent(),
                Value<int> weightDelta = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => MoodEntriesCompanion(
                profileId: profileId,
                id: id,
                mood: mood,
                weightDelta: weightDelta,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                required int profileId,
                Value<int> id = const Value.absent(),
                required String mood,
                required int weightDelta,
                required DateTime createdAt,
              }) => MoodEntriesCompanion.insert(
                profileId: profileId,
                id: id,
                mood: mood,
                weightDelta: weightDelta,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MoodEntriesTable, MoodEntryRow>(table),
                  $$MoodEntriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({profileId = false}) {
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
                    if (profileId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.profileId,
                        referencedTable: $$MoodEntriesTableReferences._profileIdTable(db),
                        referencedColumn: $$MoodEntriesTableReferences._profileIdTable(db).id,
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

typedef $$MoodEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MoodEntriesTable,
      MoodEntryRow,
      $$MoodEntriesTableFilterComposer,
      $$MoodEntriesTableOrderingComposer,
      $$MoodEntriesTableAnnotationComposer,
      $$MoodEntriesTableCreateCompanionBuilder,
      $$MoodEntriesTableUpdateCompanionBuilder,
      (MoodEntryRow, $$MoodEntriesTableReferences),
      MoodEntryRow,
      PrefetchHooks Function({bool profileId})
    >;
typedef $$EmotionalStatesTableCreateCompanionBuilder = EmotionalStatesCompanion Function({
  Value<int> profileId,
  Value<int> weight,
  Value<int> consecutiveNegative,
  Value<DateTime?> lastInterventionAt,
});
typedef $$EmotionalStatesTableUpdateCompanionBuilder = EmotionalStatesCompanion Function({
  Value<int> profileId,
  Value<int> weight,
  Value<int> consecutiveNegative,
  Value<DateTime?> lastInterventionAt,
});

final class $$EmotionalStatesTableReferences
    extends BaseReferences<_$AppDatabase, $EmotionalStatesTable, EmotionalStateRow> {
  $$EmotionalStatesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProfilesTable _profileIdTable(_$AppDatabase db) =>
      db.profiles.createAlias('emotional_states__profile_id__profiles__id');

  $$ProfilesTableProcessedTableManager get profileId {
    final $_column = $_itemColumn<int>('profile_id')!;

    final manager = $$ProfilesTableTableManager(
      $_db,
      $_db.profiles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_profileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$EmotionalStatesTableFilterComposer extends Composer<_$AppDatabase, $EmotionalStatesTable> {
  $$EmotionalStatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get weight =>
      $composableBuilder(column: $table.weight, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get consecutiveNegative => $composableBuilder(
    column: $table.consecutiveNegative,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastInterventionAt => $composableBuilder(
    column: $table.lastInterventionAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ProfilesTableFilterComposer get profileId {
    final $$ProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$ProfilesTableFilterComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EmotionalStatesTableOrderingComposer
    extends Composer<_$AppDatabase, $EmotionalStatesTable> {
  $$EmotionalStatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get weight =>
      $composableBuilder(column: $table.weight, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get consecutiveNegative => $composableBuilder(
    column: $table.consecutiveNegative,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastInterventionAt => $composableBuilder(
    column: $table.lastInterventionAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProfilesTableOrderingComposer get profileId {
    final $$ProfilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$ProfilesTableOrderingComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EmotionalStatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $EmotionalStatesTable> {
  $$EmotionalStatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get weight =>
      $composableBuilder(column: $table.weight, builder: (column) => column);

  GeneratedColumn<int> get consecutiveNegative =>
      $composableBuilder(column: $table.consecutiveNegative, builder: (column) => column);

  GeneratedColumn<DateTime> get lastInterventionAt =>
      $composableBuilder(column: $table.lastInterventionAt, builder: (column) => column);

  $$ProfilesTableAnnotationComposer get profileId {
    final $$ProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$ProfilesTableAnnotationComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EmotionalStatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EmotionalStatesTable,
          EmotionalStateRow,
          $$EmotionalStatesTableFilterComposer,
          $$EmotionalStatesTableOrderingComposer,
          $$EmotionalStatesTableAnnotationComposer,
          $$EmotionalStatesTableCreateCompanionBuilder,
          $$EmotionalStatesTableUpdateCompanionBuilder,
          (EmotionalStateRow, $$EmotionalStatesTableReferences),
          EmotionalStateRow,
          PrefetchHooks Function({bool profileId})
        > {
  $$EmotionalStatesTableTableManager(_$AppDatabase db, $EmotionalStatesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EmotionalStatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EmotionalStatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EmotionalStatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> profileId = const Value.absent(),
                Value<int> weight = const Value.absent(),
                Value<int> consecutiveNegative = const Value.absent(),
                Value<DateTime?> lastInterventionAt = const Value.absent(),
              }) => EmotionalStatesCompanion(
                profileId: profileId,
                weight: weight,
                consecutiveNegative: consecutiveNegative,
                lastInterventionAt: lastInterventionAt,
              ),
          createCompanionCallback:
              ({
                Value<int> profileId = const Value.absent(),
                Value<int> weight = const Value.absent(),
                Value<int> consecutiveNegative = const Value.absent(),
                Value<DateTime?> lastInterventionAt = const Value.absent(),
              }) => EmotionalStatesCompanion.insert(
                profileId: profileId,
                weight: weight,
                consecutiveNegative: consecutiveNegative,
                lastInterventionAt: lastInterventionAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$EmotionalStatesTable, EmotionalStateRow>(table),
                  $$EmotionalStatesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({profileId = false}) {
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
                    if (profileId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.profileId,
                        referencedTable: $$EmotionalStatesTableReferences._profileIdTable(db),
                        referencedColumn: $$EmotionalStatesTableReferences._profileIdTable(db).id,
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

typedef $$EmotionalStatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EmotionalStatesTable,
      EmotionalStateRow,
      $$EmotionalStatesTableFilterComposer,
      $$EmotionalStatesTableOrderingComposer,
      $$EmotionalStatesTableAnnotationComposer,
      $$EmotionalStatesTableCreateCompanionBuilder,
      $$EmotionalStatesTableUpdateCompanionBuilder,
      (EmotionalStateRow, $$EmotionalStatesTableReferences),
      EmotionalStateRow,
      PrefetchHooks Function({bool profileId})
    >;
typedef $$OwnedItemsTableCreateCompanionBuilder = OwnedItemsCompanion Function({
  required int profileId,
  required String itemId,
  required DateTime acquiredAt,
  Value<int> rowid,
});
typedef $$OwnedItemsTableUpdateCompanionBuilder = OwnedItemsCompanion Function({
  Value<int> profileId,
  Value<String> itemId,
  Value<DateTime> acquiredAt,
  Value<int> rowid,
});

final class $$OwnedItemsTableReferences
    extends BaseReferences<_$AppDatabase, $OwnedItemsTable, OwnedItem> {
  $$OwnedItemsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProfilesTable _profileIdTable(_$AppDatabase db) =>
      db.profiles.createAlias('owned_items__profile_id__profiles__id');

  $$ProfilesTableProcessedTableManager get profileId {
    final $_column = $_itemColumn<int>('profile_id')!;

    final manager = $$ProfilesTableTableManager(
      $_db,
      $_db.profiles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_profileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$OwnedItemsTableFilterComposer extends Composer<_$AppDatabase, $OwnedItemsTable> {
  $$OwnedItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get acquiredAt =>
      $composableBuilder(column: $table.acquiredAt, builder: (column) => ColumnFilters(column));

  $$ProfilesTableFilterComposer get profileId {
    final $$ProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$ProfilesTableFilterComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$OwnedItemsTableOrderingComposer extends Composer<_$AppDatabase, $OwnedItemsTable> {
  $$OwnedItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get acquiredAt =>
      $composableBuilder(column: $table.acquiredAt, builder: (column) => ColumnOrderings(column));

  $$ProfilesTableOrderingComposer get profileId {
    final $$ProfilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$ProfilesTableOrderingComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$OwnedItemsTableAnnotationComposer extends Composer<_$AppDatabase, $OwnedItemsTable> {
  $$OwnedItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);

  GeneratedColumn<DateTime> get acquiredAt =>
      $composableBuilder(column: $table.acquiredAt, builder: (column) => column);

  $$ProfilesTableAnnotationComposer get profileId {
    final $$ProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$ProfilesTableAnnotationComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$OwnedItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OwnedItemsTable,
          OwnedItem,
          $$OwnedItemsTableFilterComposer,
          $$OwnedItemsTableOrderingComposer,
          $$OwnedItemsTableAnnotationComposer,
          $$OwnedItemsTableCreateCompanionBuilder,
          $$OwnedItemsTableUpdateCompanionBuilder,
          (OwnedItem, $$OwnedItemsTableReferences),
          OwnedItem,
          PrefetchHooks Function({bool profileId})
        > {
  $$OwnedItemsTableTableManager(_$AppDatabase db, $OwnedItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$OwnedItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$OwnedItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OwnedItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> profileId = const Value.absent(),
                Value<String> itemId = const Value.absent(),
                Value<DateTime> acquiredAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OwnedItemsCompanion(
                profileId: profileId,
                itemId: itemId,
                acquiredAt: acquiredAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int profileId,
                required String itemId,
                required DateTime acquiredAt,
                Value<int> rowid = const Value.absent(),
              }) => OwnedItemsCompanion.insert(
                profileId: profileId,
                itemId: itemId,
                acquiredAt: acquiredAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$OwnedItemsTable, OwnedItem>(table),
                  $$OwnedItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({profileId = false}) {
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
                    if (profileId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.profileId,
                        referencedTable: $$OwnedItemsTableReferences._profileIdTable(db),
                        referencedColumn: $$OwnedItemsTableReferences._profileIdTable(db).id,
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

typedef $$OwnedItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OwnedItemsTable,
      OwnedItem,
      $$OwnedItemsTableFilterComposer,
      $$OwnedItemsTableOrderingComposer,
      $$OwnedItemsTableAnnotationComposer,
      $$OwnedItemsTableCreateCompanionBuilder,
      $$OwnedItemsTableUpdateCompanionBuilder,
      (OwnedItem, $$OwnedItemsTableReferences),
      OwnedItem,
      PrefetchHooks Function({bool profileId})
    >;
typedef $$SelectionsTableCreateCompanionBuilder = SelectionsCompanion Function({
  required int profileId,
  required String slot,
  required String itemId,
  Value<int> rowid,
});
typedef $$SelectionsTableUpdateCompanionBuilder = SelectionsCompanion Function({
  Value<int> profileId,
  Value<String> slot,
  Value<String> itemId,
  Value<int> rowid,
});

final class $$SelectionsTableReferences
    extends BaseReferences<_$AppDatabase, $SelectionsTable, Selection> {
  $$SelectionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProfilesTable _profileIdTable(_$AppDatabase db) =>
      db.profiles.createAlias('selections__profile_id__profiles__id');

  $$ProfilesTableProcessedTableManager get profileId {
    final $_column = $_itemColumn<int>('profile_id')!;

    final manager = $$ProfilesTableTableManager(
      $_db,
      $_db.profiles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_profileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$SelectionsTableFilterComposer extends Composer<_$AppDatabase, $SelectionsTable> {
  $$SelectionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get slot =>
      $composableBuilder(column: $table.slot, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => ColumnFilters(column));

  $$ProfilesTableFilterComposer get profileId {
    final $$ProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$ProfilesTableFilterComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SelectionsTableOrderingComposer extends Composer<_$AppDatabase, $SelectionsTable> {
  $$SelectionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get slot =>
      $composableBuilder(column: $table.slot, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => ColumnOrderings(column));

  $$ProfilesTableOrderingComposer get profileId {
    final $$ProfilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$ProfilesTableOrderingComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SelectionsTableAnnotationComposer extends Composer<_$AppDatabase, $SelectionsTable> {
  $$SelectionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get slot =>
      $composableBuilder(column: $table.slot, builder: (column) => column);

  GeneratedColumn<String> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);

  $$ProfilesTableAnnotationComposer get profileId {
    final $$ProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$ProfilesTableAnnotationComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SelectionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SelectionsTable,
          Selection,
          $$SelectionsTableFilterComposer,
          $$SelectionsTableOrderingComposer,
          $$SelectionsTableAnnotationComposer,
          $$SelectionsTableCreateCompanionBuilder,
          $$SelectionsTableUpdateCompanionBuilder,
          (Selection, $$SelectionsTableReferences),
          Selection,
          PrefetchHooks Function({bool profileId})
        > {
  $$SelectionsTableTableManager(_$AppDatabase db, $SelectionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$SelectionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$SelectionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SelectionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> profileId = const Value.absent(),
            Value<String> slot = const Value.absent(),
            Value<String> itemId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => SelectionsCompanion(profileId: profileId, slot: slot, itemId: itemId, rowid: rowid),
          createCompanionCallback:
              ({
                required int profileId,
                required String slot,
                required String itemId,
                Value<int> rowid = const Value.absent(),
              }) => SelectionsCompanion.insert(
                profileId: profileId,
                slot: slot,
                itemId: itemId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SelectionsTable, Selection>(table),
                  $$SelectionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({profileId = false}) {
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
                    if (profileId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.profileId,
                        referencedTable: $$SelectionsTableReferences._profileIdTable(db),
                        referencedColumn: $$SelectionsTableReferences._profileIdTable(db).id,
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

typedef $$SelectionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SelectionsTable,
      Selection,
      $$SelectionsTableFilterComposer,
      $$SelectionsTableOrderingComposer,
      $$SelectionsTableAnnotationComposer,
      $$SelectionsTableCreateCompanionBuilder,
      $$SelectionsTableUpdateCompanionBuilder,
      (Selection, $$SelectionsTableReferences),
      Selection,
      PrefetchHooks Function({bool profileId})
    >;
typedef $$ConversationProgressTableCreateCompanionBuilder = ConversationProgressCompanion Function({
  Value<int> profileId,
  required String treeId,
  required String lastNodeId,
  required String path,
  required DateTime updatedAt,
});
typedef $$ConversationProgressTableUpdateCompanionBuilder = ConversationProgressCompanion Function({
  Value<int> profileId,
  Value<String> treeId,
  Value<String> lastNodeId,
  Value<String> path,
  Value<DateTime> updatedAt,
});

final class $$ConversationProgressTableReferences
    extends BaseReferences<_$AppDatabase, $ConversationProgressTable, ConversationProgressData> {
  $$ConversationProgressTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProfilesTable _profileIdTable(_$AppDatabase db) =>
      db.profiles.createAlias('conversation_progress__profile_id__profiles__id');

  $$ProfilesTableProcessedTableManager get profileId {
    final $_column = $_itemColumn<int>('profile_id')!;

    final manager = $$ProfilesTableTableManager(
      $_db,
      $_db.profiles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_profileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$ConversationProgressTableFilterComposer
    extends Composer<_$AppDatabase, $ConversationProgressTable> {
  $$ConversationProgressTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get treeId =>
      $composableBuilder(column: $table.treeId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lastNodeId =>
      $composableBuilder(column: $table.lastNodeId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get path =>
      $composableBuilder(column: $table.path, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  $$ProfilesTableFilterComposer get profileId {
    final $$ProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$ProfilesTableFilterComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ConversationProgressTableOrderingComposer
    extends Composer<_$AppDatabase, $ConversationProgressTable> {
  $$ConversationProgressTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get treeId =>
      $composableBuilder(column: $table.treeId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lastNodeId =>
      $composableBuilder(column: $table.lastNodeId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get path =>
      $composableBuilder(column: $table.path, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  $$ProfilesTableOrderingComposer get profileId {
    final $$ProfilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$ProfilesTableOrderingComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ConversationProgressTableAnnotationComposer
    extends Composer<_$AppDatabase, $ConversationProgressTable> {
  $$ConversationProgressTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get treeId =>
      $composableBuilder(column: $table.treeId, builder: (column) => column);

  GeneratedColumn<String> get lastNodeId =>
      $composableBuilder(column: $table.lastNodeId, builder: (column) => column);

  GeneratedColumn<String> get path =>
      $composableBuilder(column: $table.path, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$ProfilesTableAnnotationComposer get profileId {
    final $$ProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$ProfilesTableAnnotationComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ConversationProgressTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ConversationProgressTable,
          ConversationProgressData,
          $$ConversationProgressTableFilterComposer,
          $$ConversationProgressTableOrderingComposer,
          $$ConversationProgressTableAnnotationComposer,
          $$ConversationProgressTableCreateCompanionBuilder,
          $$ConversationProgressTableUpdateCompanionBuilder,
          (ConversationProgressData, $$ConversationProgressTableReferences),
          ConversationProgressData,
          PrefetchHooks Function({bool profileId})
        > {
  $$ConversationProgressTableTableManager(_$AppDatabase db, $ConversationProgressTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ConversationProgressTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ConversationProgressTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ConversationProgressTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> profileId = const Value.absent(),
                Value<String> treeId = const Value.absent(),
                Value<String> lastNodeId = const Value.absent(),
                Value<String> path = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => ConversationProgressCompanion(
                profileId: profileId,
                treeId: treeId,
                lastNodeId: lastNodeId,
                path: path,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> profileId = const Value.absent(),
                required String treeId,
                required String lastNodeId,
                required String path,
                required DateTime updatedAt,
              }) => ConversationProgressCompanion.insert(
                profileId: profileId,
                treeId: treeId,
                lastNodeId: lastNodeId,
                path: path,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ConversationProgressTable, ConversationProgressData>(table),
                  $$ConversationProgressTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({profileId = false}) {
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
                    if (profileId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.profileId,
                        referencedTable: $$ConversationProgressTableReferences._profileIdTable(db),
                        referencedColumn: $$ConversationProgressTableReferences
                            ._profileIdTable(db)
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

typedef $$ConversationProgressTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ConversationProgressTable,
      ConversationProgressData,
      $$ConversationProgressTableFilterComposer,
      $$ConversationProgressTableOrderingComposer,
      $$ConversationProgressTableAnnotationComposer,
      $$ConversationProgressTableCreateCompanionBuilder,
      $$ConversationProgressTableUpdateCompanionBuilder,
      (ConversationProgressData, $$ConversationProgressTableReferences),
      ConversationProgressData,
      PrefetchHooks Function({bool profileId})
    >;
typedef $$ClawStatesTableCreateCompanionBuilder = ClawStatesCompanion Function({
  Value<int> profileId,
  required int tries,
  Value<DateTime?> nextRefillAt,
  Value<int> purchasesToday,
  Value<String?> purchasesDay,
});
typedef $$ClawStatesTableUpdateCompanionBuilder = ClawStatesCompanion Function({
  Value<int> profileId,
  Value<int> tries,
  Value<DateTime?> nextRefillAt,
  Value<int> purchasesToday,
  Value<String?> purchasesDay,
});

final class $$ClawStatesTableReferences
    extends BaseReferences<_$AppDatabase, $ClawStatesTable, ClawState> {
  $$ClawStatesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProfilesTable _profileIdTable(_$AppDatabase db) =>
      db.profiles.createAlias('claw_states__profile_id__profiles__id');

  $$ProfilesTableProcessedTableManager get profileId {
    final $_column = $_itemColumn<int>('profile_id')!;

    final manager = $$ProfilesTableTableManager(
      $_db,
      $_db.profiles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_profileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$ClawStatesTableFilterComposer extends Composer<_$AppDatabase, $ClawStatesTable> {
  $$ClawStatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get tries =>
      $composableBuilder(column: $table.tries, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get nextRefillAt =>
      $composableBuilder(column: $table.nextRefillAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get purchasesToday =>
      $composableBuilder(column: $table.purchasesToday, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get purchasesDay =>
      $composableBuilder(column: $table.purchasesDay, builder: (column) => ColumnFilters(column));

  $$ProfilesTableFilterComposer get profileId {
    final $$ProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$ProfilesTableFilterComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ClawStatesTableOrderingComposer extends Composer<_$AppDatabase, $ClawStatesTable> {
  $$ClawStatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get tries =>
      $composableBuilder(column: $table.tries, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get nextRefillAt =>
      $composableBuilder(column: $table.nextRefillAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get purchasesToday => $composableBuilder(
    column: $table.purchasesToday,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get purchasesDay =>
      $composableBuilder(column: $table.purchasesDay, builder: (column) => ColumnOrderings(column));

  $$ProfilesTableOrderingComposer get profileId {
    final $$ProfilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$ProfilesTableOrderingComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ClawStatesTableAnnotationComposer extends Composer<_$AppDatabase, $ClawStatesTable> {
  $$ClawStatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get tries =>
      $composableBuilder(column: $table.tries, builder: (column) => column);

  GeneratedColumn<DateTime> get nextRefillAt =>
      $composableBuilder(column: $table.nextRefillAt, builder: (column) => column);

  GeneratedColumn<int> get purchasesToday =>
      $composableBuilder(column: $table.purchasesToday, builder: (column) => column);

  GeneratedColumn<String> get purchasesDay =>
      $composableBuilder(column: $table.purchasesDay, builder: (column) => column);

  $$ProfilesTableAnnotationComposer get profileId {
    final $$ProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$ProfilesTableAnnotationComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ClawStatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ClawStatesTable,
          ClawState,
          $$ClawStatesTableFilterComposer,
          $$ClawStatesTableOrderingComposer,
          $$ClawStatesTableAnnotationComposer,
          $$ClawStatesTableCreateCompanionBuilder,
          $$ClawStatesTableUpdateCompanionBuilder,
          (ClawState, $$ClawStatesTableReferences),
          ClawState,
          PrefetchHooks Function({bool profileId})
        > {
  $$ClawStatesTableTableManager(_$AppDatabase db, $ClawStatesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$ClawStatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$ClawStatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ClawStatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> profileId = const Value.absent(),
                Value<int> tries = const Value.absent(),
                Value<DateTime?> nextRefillAt = const Value.absent(),
                Value<int> purchasesToday = const Value.absent(),
                Value<String?> purchasesDay = const Value.absent(),
              }) => ClawStatesCompanion(
                profileId: profileId,
                tries: tries,
                nextRefillAt: nextRefillAt,
                purchasesToday: purchasesToday,
                purchasesDay: purchasesDay,
              ),
          createCompanionCallback:
              ({
                Value<int> profileId = const Value.absent(),
                required int tries,
                Value<DateTime?> nextRefillAt = const Value.absent(),
                Value<int> purchasesToday = const Value.absent(),
                Value<String?> purchasesDay = const Value.absent(),
              }) => ClawStatesCompanion.insert(
                profileId: profileId,
                tries: tries,
                nextRefillAt: nextRefillAt,
                purchasesToday: purchasesToday,
                purchasesDay: purchasesDay,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ClawStatesTable, ClawState>(table),
                  $$ClawStatesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({profileId = false}) {
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
                    if (profileId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.profileId,
                        referencedTable: $$ClawStatesTableReferences._profileIdTable(db),
                        referencedColumn: $$ClawStatesTableReferences._profileIdTable(db).id,
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

typedef $$ClawStatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ClawStatesTable,
      ClawState,
      $$ClawStatesTableFilterComposer,
      $$ClawStatesTableOrderingComposer,
      $$ClawStatesTableAnnotationComposer,
      $$ClawStatesTableCreateCompanionBuilder,
      $$ClawStatesTableUpdateCompanionBuilder,
      (ClawState, $$ClawStatesTableReferences),
      ClawState,
      PrefetchHooks Function({bool profileId})
    >;
typedef $$ClawStatsTableCreateCompanionBuilder = ClawStatsCompanion Function({
  Value<int> profileId,
  Value<int> plays,
  Value<int> wins,
  Value<int> earnings,
  Value<int> bestWin,
});
typedef $$ClawStatsTableUpdateCompanionBuilder = ClawStatsCompanion Function({
  Value<int> profileId,
  Value<int> plays,
  Value<int> wins,
  Value<int> earnings,
  Value<int> bestWin,
});

final class $$ClawStatsTableReferences
    extends BaseReferences<_$AppDatabase, $ClawStatsTable, ClawStat> {
  $$ClawStatsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProfilesTable _profileIdTable(_$AppDatabase db) =>
      db.profiles.createAlias('claw_stats__profile_id__profiles__id');

  $$ProfilesTableProcessedTableManager get profileId {
    final $_column = $_itemColumn<int>('profile_id')!;

    final manager = $$ProfilesTableTableManager(
      $_db,
      $_db.profiles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_profileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$ClawStatsTableFilterComposer extends Composer<_$AppDatabase, $ClawStatsTable> {
  $$ClawStatsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get plays =>
      $composableBuilder(column: $table.plays, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get wins =>
      $composableBuilder(column: $table.wins, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get earnings =>
      $composableBuilder(column: $table.earnings, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get bestWin =>
      $composableBuilder(column: $table.bestWin, builder: (column) => ColumnFilters(column));

  $$ProfilesTableFilterComposer get profileId {
    final $$ProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$ProfilesTableFilterComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ClawStatsTableOrderingComposer extends Composer<_$AppDatabase, $ClawStatsTable> {
  $$ClawStatsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get plays =>
      $composableBuilder(column: $table.plays, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get wins =>
      $composableBuilder(column: $table.wins, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get earnings =>
      $composableBuilder(column: $table.earnings, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get bestWin =>
      $composableBuilder(column: $table.bestWin, builder: (column) => ColumnOrderings(column));

  $$ProfilesTableOrderingComposer get profileId {
    final $$ProfilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$ProfilesTableOrderingComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ClawStatsTableAnnotationComposer extends Composer<_$AppDatabase, $ClawStatsTable> {
  $$ClawStatsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get plays =>
      $composableBuilder(column: $table.plays, builder: (column) => column);

  GeneratedColumn<int> get wins =>
      $composableBuilder(column: $table.wins, builder: (column) => column);

  GeneratedColumn<int> get earnings =>
      $composableBuilder(column: $table.earnings, builder: (column) => column);

  GeneratedColumn<int> get bestWin =>
      $composableBuilder(column: $table.bestWin, builder: (column) => column);

  $$ProfilesTableAnnotationComposer get profileId {
    final $$ProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$ProfilesTableAnnotationComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ClawStatsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ClawStatsTable,
          ClawStat,
          $$ClawStatsTableFilterComposer,
          $$ClawStatsTableOrderingComposer,
          $$ClawStatsTableAnnotationComposer,
          $$ClawStatsTableCreateCompanionBuilder,
          $$ClawStatsTableUpdateCompanionBuilder,
          (ClawStat, $$ClawStatsTableReferences),
          ClawStat,
          PrefetchHooks Function({bool profileId})
        > {
  $$ClawStatsTableTableManager(_$AppDatabase db, $ClawStatsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$ClawStatsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$ClawStatsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ClawStatsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> profileId = const Value.absent(),
                Value<int> plays = const Value.absent(),
                Value<int> wins = const Value.absent(),
                Value<int> earnings = const Value.absent(),
                Value<int> bestWin = const Value.absent(),
              }) => ClawStatsCompanion(
                profileId: profileId,
                plays: plays,
                wins: wins,
                earnings: earnings,
                bestWin: bestWin,
              ),
          createCompanionCallback:
              ({
                Value<int> profileId = const Value.absent(),
                Value<int> plays = const Value.absent(),
                Value<int> wins = const Value.absent(),
                Value<int> earnings = const Value.absent(),
                Value<int> bestWin = const Value.absent(),
              }) => ClawStatsCompanion.insert(
                profileId: profileId,
                plays: plays,
                wins: wins,
                earnings: earnings,
                bestWin: bestWin,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ClawStatsTable, ClawStat>(table),
                  $$ClawStatsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({profileId = false}) {
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
                    if (profileId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.profileId,
                        referencedTable: $$ClawStatsTableReferences._profileIdTable(db),
                        referencedColumn: $$ClawStatsTableReferences._profileIdTable(db).id,
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

typedef $$ClawStatsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ClawStatsTable,
      ClawStat,
      $$ClawStatsTableFilterComposer,
      $$ClawStatsTableOrderingComposer,
      $$ClawStatsTableAnnotationComposer,
      $$ClawStatsTableCreateCompanionBuilder,
      $$ClawStatsTableUpdateCompanionBuilder,
      (ClawStat, $$ClawStatsTableReferences),
      ClawStat,
      PrefetchHooks Function({bool profileId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ProfilesTableTableManager get profiles => $$ProfilesTableTableManager(_db, _db.profiles);
  $$WalletsTableTableManager get wallets => $$WalletsTableTableManager(_db, _db.wallets);
  $$LedgerEntriesTableTableManager get ledgerEntries =>
      $$LedgerEntriesTableTableManager(_db, _db.ledgerEntries);
  $$MoodEntriesTableTableManager get moodEntries =>
      $$MoodEntriesTableTableManager(_db, _db.moodEntries);
  $$EmotionalStatesTableTableManager get emotionalStates =>
      $$EmotionalStatesTableTableManager(_db, _db.emotionalStates);
  $$OwnedItemsTableTableManager get ownedItems =>
      $$OwnedItemsTableTableManager(_db, _db.ownedItems);
  $$SelectionsTableTableManager get selections =>
      $$SelectionsTableTableManager(_db, _db.selections);
  $$ConversationProgressTableTableManager get conversationProgress =>
      $$ConversationProgressTableTableManager(_db, _db.conversationProgress);
  $$ClawStatesTableTableManager get clawStates =>
      $$ClawStatesTableTableManager(_db, _db.clawStates);
  $$ClawStatsTableTableManager get clawStats => $$ClawStatsTableTableManager(_db, _db.clawStats);
}
