import 'package:drift/drift.dart';

/// A person using the app on this device. Everything else hangs off a profile
/// and is deleted with it.
class Profiles extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get displayName => text().withLength(min: 1, max: 40)();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get lastActiveAt => dateTime()();
}

mixin _OwnedByProfile on Table {
  IntColumn get profileId => integer().references(Profiles, #id, onDelete: KeyAction.cascade)();
}

/// One row per profile: the ✷ balance. It can never go below zero.
class Wallets extends Table with _OwnedByProfile {
  // The self-reference is how drift expresses a CHECK constraint.
  // ignore: recursive_getters
  IntColumn get balance => integer().check(balance.isBiggerOrEqualValue(0))();

  @override
  Set<Column> get primaryKey => {profileId};
}

/// Every change to a wallet, so the balance can always be explained.
class LedgerEntries extends Table with _OwnedByProfile {
  IntColumn get id => integer().autoIncrement()();

  /// Positive for ✷ earned, negative for ✷ spent.
  IntColumn get amount => integer()();

  /// A short machine-readable reason, such as `purchase:blue_bao` or `claw:win`.
  TextColumn get reason => text()();
  DateTimeColumn get createdAt => dateTime()();
}

/// One row per mood check-in.
@DataClassName('MoodEntryRow')
class MoodEntries extends Table with _OwnedByProfile {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get mood => text()();
  IntColumn get weightDelta => integer()();
  DateTimeColumn get createdAt => dateTime()();
}

/// One row per profile: the running emotional summary.
@DataClassName('EmotionalStateRow')
class EmotionalStates extends Table with _OwnedByProfile {
  IntColumn get weight => integer().withDefault(const Constant(0))();
  IntColumn get consecutiveNegative => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastInterventionAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {profileId};
}

/// Catalogue items a profile owns.
class OwnedItems extends Table with _OwnedByProfile {
  TextColumn get itemId => text()();
  DateTimeColumn get acquiredAt => dateTime()();

  @override
  Set<Column> get primaryKey => {profileId, itemId};
}

/// The item a profile has equipped in each slot.
class Selections extends Table with _OwnedByProfile {
  TextColumn get slot => text()();
  TextColumn get itemId => text()();

  @override
  Set<Column> get primaryKey => {profileId, slot};
}

/// One row per profile: where the most recent conversation got to.
class ConversationProgress extends Table with _OwnedByProfile {
  TextColumn get treeId => text()();
  TextColumn get lastNodeId => text()();

  /// JSON array of the node ids visited, in order.
  TextColumn get path => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {profileId};
}

/// One row per profile: claw-machine tries and the daily purchase count.
class ClawStates extends Table with _OwnedByProfile {
  IntColumn get tries => integer()();
  DateTimeColumn get nextRefillAt => dateTime().nullable()();
  IntColumn get purchasesToday => integer().withDefault(const Constant(0))();
  TextColumn get purchasesDay => text().nullable()();

  @override
  Set<Column> get primaryKey => {profileId};
}

/// One row per profile: lifetime claw-machine statistics.
class ClawStats extends Table with _OwnedByProfile {
  IntColumn get plays => integer().withDefault(const Constant(0))();
  IntColumn get wins => integer().withDefault(const Constant(0))();
  IntColumn get earnings => integer().withDefault(const Constant(0))();
  IntColumn get bestWin => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {profileId};
}
