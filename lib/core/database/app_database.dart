import 'package:baobao/core/database/tables.dart';
import 'package:drift/drift.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Profiles,
    Wallets,
    LedgerEntries,
    MoodEntries,
    EmotionalStates,
    OwnedItems,
    Selections,
    ConversationProgress,
    ClawStates,
    ClawStats,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  /// Raise this with every schema change, add a step to [migration], and run
  /// `dart run drift_dev make-migrations` to snapshot the schema and generate
  /// the migration test. Never fall back to dropping data.
  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    beforeOpen: (details) async {
      // Needed for ON DELETE CASCADE, which profile deletion relies on.
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  /// Changes a wallet by [amount] and records why. Must run inside a
  /// transaction with whatever the ✷ are being exchanged for.
  ///
  /// Throws if the balance would go below zero.
  Future<void> adjustBalance({
    required int profileId,
    required int amount,
    required String reason,
    required DateTime now,
  }) async {
    if (amount == 0) return;
    await customUpdate(
      'UPDATE wallets SET balance = balance + ? WHERE profile_id = ?',
      variables: [Variable.withInt(amount), Variable.withInt(profileId)],
      updates: {wallets},
    );
    await into(ledgerEntries).insert(
      LedgerEntriesCompanion.insert(
        profileId: profileId,
        amount: amount,
        reason: reason,
        createdAt: now,
      ),
    );
  }
}
