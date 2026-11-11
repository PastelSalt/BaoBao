import 'package:baobao/core/database/app_database.dart';
import 'package:baobao/features/claw_machine/domain/claw_tries.dart';
import 'package:baobao/features/economy/domain/catalog.dart';
import 'package:drift/drift.dart';

class ProfileRepository {
  const ProfileRepository(this._db, this._catalog);

  final AppDatabase _db;
  final Catalog _catalog;

  static const maxNameLength = 40;

  Stream<List<Profile>> watchAll() =>
      (_db.select(_db.profiles)..orderBy([(p) => OrderingTerm.asc(p.createdAt)])).watch();

  Future<List<Profile>> all() =>
      (_db.select(_db.profiles)..orderBy([(p) => OrderingTerm.asc(p.createdAt)])).get();

  Future<Profile?> byId(int id) =>
      (_db.select(_db.profiles)..where((p) => p.id.equals(id))).getSingleOrNull();

  Stream<Profile?> watch(int id) =>
      (_db.select(_db.profiles)..where((p) => p.id.equals(id))).watchSingleOrNull();

  /// Creates a profile with a starting balance, the default item in every
  /// slot, and a full set of claw-machine tries.
  Future<Profile> create(String displayName, DateTime now) {
    final name = cleanName(displayName);
    return _db.transaction(() async {
      final id = await _db
          .into(_db.profiles)
          .insert(ProfilesCompanion.insert(displayName: name, createdAt: now, lastActiveAt: now));

      await _db.into(_db.wallets).insert(WalletsCompanion.insert(profileId: Value(id), balance: 0));
      await _db.adjustBalance(
        profileId: id,
        amount: _catalog.startingBalance,
        reason: 'welcome',
        now: now,
      );
      await _db.into(_db.emotionalStates).insert(EmotionalStatesCompanion(profileId: Value(id)));
      await _db
          .into(_db.clawStates)
          .insert(ClawStatesCompanion.insert(profileId: Value(id), tries: ClawTries.maxFreeTries));
      await _db.into(_db.clawStats).insert(ClawStatsCompanion(profileId: Value(id)));

      for (final slot in ItemSlot.values) {
        final item = _catalog.defaultFor(slot);
        await _db
            .into(_db.ownedItems)
            .insert(OwnedItemsCompanion.insert(profileId: id, itemId: item.id, acquiredAt: now));
        await _db
            .into(_db.selections)
            .insert(SelectionsCompanion.insert(profileId: id, slot: slot.name, itemId: item.id));
      }
      return (await byId(id))!;
    });
  }

  Future<void> rename(int id, String displayName) {
    return (_db.update(_db.profiles)..where((p) => p.id.equals(id))).write(
      ProfilesCompanion(displayName: Value(cleanName(displayName))),
    );
  }

  Future<void> touch(int id, DateTime now) {
    return (_db.update(
      _db.profiles,
    )..where((p) => p.id.equals(id))).write(ProfilesCompanion(lastActiveAt: Value(now)));
  }

  /// Deletes the profile and, through cascading foreign keys, every row that
  /// belongs to it. This is the "delete my data" operation.
  Future<void> delete(int id) => (_db.delete(_db.profiles)..where((p) => p.id.equals(id))).go();

  /// Trims a display name and limits its length. Blank names become "Friend".
  static String cleanName(String raw) {
    final collapsed = raw.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (collapsed.isEmpty) return 'Friend';
    final characters = collapsed.runes.take(maxNameLength);
    return String.fromCharCodes(characters);
  }
}
