import 'package:baobao/core/database/app_database.dart';
import 'package:baobao/features/economy/domain/catalog.dart';
import 'package:baobao/features/economy/domain/purchase_rules.dart';
import 'package:drift/drift.dart';

/// Wallet, ownership and equipped items for a profile.
class EconomyRepository {
  const EconomyRepository(this._db, this._catalog);

  final AppDatabase _db;
  final Catalog _catalog;

  Future<int> balance(int profileId) async {
    final wallet = await (_db.select(
      _db.wallets,
    )..where((w) => w.profileId.equals(profileId))).getSingle();
    return wallet.balance;
  }

  Stream<int> watchBalance(int profileId) => (_db.select(
    _db.wallets,
  )..where((w) => w.profileId.equals(profileId))).watchSingle().map((w) => w.balance);

  Future<Set<String>> owned(int profileId) async {
    final rows = await (_db.select(
      _db.ownedItems,
    )..where((o) => o.profileId.equals(profileId))).get();
    return {for (final row in rows) row.itemId};
  }

  Stream<Set<String>> watchOwned(int profileId) =>
      (_db.select(_db.ownedItems)..where((o) => o.profileId.equals(profileId))).watch().map(
        (rows) => {for (final row in rows) row.itemId},
      );

  /// The equipped item in each slot. Falls back to the slot's default if a
  /// stored selection no longer exists in the catalogue.
  Stream<Map<ItemSlot, CatalogItem>> watchSelections(int profileId) =>
      (_db.select(_db.selections)..where((s) => s.profileId.equals(profileId))).watch().map((rows) {
        final chosen = {for (final row in rows) row.slot: row.itemId};
        return {
          for (final slot in ItemSlot.values)
            slot: _catalog.byId(chosen[slot.name] ?? '') ?? _catalog.defaultFor(slot),
        };
      });

  /// Buys [item] if the rules allow it. Payment and ownership are one transaction.
  Future<PurchaseDecision> purchase(int profileId, CatalogItem item, DateTime now) {
    return _db.transaction(() async {
      final decision = PurchaseRules.evaluate(
        item: item,
        balance: await balance(profileId),
        ownedItemIds: await owned(profileId),
      );
      if (decision is! PurchaseAllowed) return decision;

      await _db.adjustBalance(
        profileId: profileId,
        amount: -item.price,
        reason: 'purchase:${item.id}',
        now: now,
      );
      await _db
          .into(_db.ownedItems)
          .insert(
            OwnedItemsCompanion.insert(profileId: profileId, itemId: item.id, acquiredAt: now),
          );
      return decision;
    });
  }

  /// Equips [item]. Returns false, changing nothing, if the profile does not own it.
  Future<bool> select(int profileId, CatalogItem item) {
    return _db.transaction(() async {
      if (!(await owned(profileId)).contains(item.id)) return false;
      await _db
          .into(_db.selections)
          .insertOnConflictUpdate(
            SelectionsCompanion.insert(profileId: profileId, slot: item.slot.name, itemId: item.id),
          );
      return true;
    });
  }

  /// The wallet's history, newest first.
  Future<List<LedgerEntry>> ledger(int profileId) =>
      (_db.select(_db.ledgerEntries)
            ..where((l) => l.profileId.equals(profileId))
            ..orderBy([(l) => OrderingTerm.desc(l.id)]))
          .get();
}
