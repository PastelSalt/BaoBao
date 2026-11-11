import 'package:baobao/core/database/app_database.dart';
import 'package:baobao/features/claw_machine/domain/claw_game.dart';
import 'package:baobao/features/claw_machine/domain/claw_tries.dart';
import 'package:drift/drift.dart';

class ClawRepository {
  const ClawRepository(this._db);

  final AppDatabase _db;

  /// The stored tries, exactly as saved. Call [ClawTries.refreshed] with the
  /// current time before showing them.
  Stream<ClawTries> watchTries(int profileId) => (_db.select(
    _db.clawStates,
  )..where((s) => s.profileId.equals(profileId))).watchSingle().map(_toTries);

  Stream<ClawStat> watchStats(int profileId) =>
      (_db.select(_db.clawStats)..where((s) => s.profileId.equals(profileId))).watchSingle();

  /// The tries as of [now], with any refills saved.
  Future<ClawTries> tries(int profileId, DateTime now) {
    return _db.transaction(() async {
      final current = (await _read(profileId)).refreshed(now);
      await _write(profileId, current);
      return current;
    });
  }

  /// Uses one try. Returns null, changing nothing, if there are none.
  Future<ClawTries?> consumeTry(int profileId, DateTime now) {
    return _db.transaction(() async {
      final next = (await _read(profileId)).consume(now);
      if (next != null) await _write(profileId, next);
      return next;
    });
  }

  /// Buys an extra try. Payment and the new try are one transaction.
  Future<BuyTryResult> buyTry(int profileId, DateTime now) {
    return _db.transaction(() async {
      final current = await _read(profileId);
      final wallet = await (_db.select(
        _db.wallets,
      )..where((w) => w.profileId.equals(profileId))).getSingle();
      final result = current.canBuy(balance: wallet.balance, now: now);
      if (result != BuyTryResult.bought) return result;

      await _db.adjustBalance(
        profileId: profileId,
        amount: -ClawTries.tryPrice,
        reason: 'claw:try',
        now: now,
      );
      await _write(profileId, current.withBoughtTry(now));
      return result;
    });
  }

  /// Records a finished round: statistics, and the payout if it was a win.
  Future<void> recordResult(int profileId, ClawResult result, DateTime now) {
    return _db.transaction(() async {
      final stats = await (_db.select(
        _db.clawStats,
      )..where((s) => s.profileId.equals(profileId))).getSingle();
      final payout = result.payout;
      await (_db.update(_db.clawStats)..where((s) => s.profileId.equals(profileId))).write(
        ClawStatsCompanion(
          plays: Value(stats.plays + 1),
          wins: Value(stats.wins + (result.won ? 1 : 0)),
          earnings: Value(stats.earnings + payout),
          bestWin: Value(payout > stats.bestWin ? payout : stats.bestWin),
        ),
      );
      await _db.adjustBalance(profileId: profileId, amount: payout, reason: 'claw:win', now: now);
    });
  }

  Future<ClawTries> _read(int profileId) async => _toTries(
    await (_db.select(_db.clawStates)..where((s) => s.profileId.equals(profileId))).getSingle(),
  );

  Future<void> _write(int profileId, ClawTries tries) {
    return (_db.update(_db.clawStates)..where((s) => s.profileId.equals(profileId))).write(
      ClawStatesCompanion(
        tries: Value(tries.tries),
        nextRefillAt: Value(tries.nextRefillAt),
        purchasesToday: Value(tries.purchasesToday),
        purchasesDay: Value(tries.purchasesDay),
      ),
    );
  }

  static ClawTries _toTries(ClawState row) => ClawTries(
    tries: row.tries,
    nextRefillAt: row.nextRefillAt,
    purchasesToday: row.purchasesToday,
    purchasesDay: row.purchasesDay,
  );
}
