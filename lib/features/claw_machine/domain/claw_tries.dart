/// The outcome of trying to buy an extra try.
enum BuyTryResult { bought, dailyLimitReached, insufficientFunds }

/// How many claw-machine tries a profile has, and when more arrive.
///
/// Free tries refill one at a time up to [maxFreeTries]. Bought tries can
/// push the count above that; refilling simply pauses until it drops again.
class ClawTries {
  const ClawTries({
    this.tries = maxFreeTries,
    this.nextRefillAt,
    this.purchasesToday = 0,
    this.purchasesDay,
  });

  static const maxFreeTries = 5;
  static const refillInterval = Duration(minutes: 5);
  static const tryPrice = 50;
  static const maxPurchasesPerDay = 10;

  final int tries;

  /// When the next free try arrives. Null while at or above [maxFreeTries].
  final DateTime? nextRefillAt;

  /// Extra tries bought on [purchasesDay].
  final int purchasesToday;

  /// The local calendar day [purchasesToday] refers to, as `yyyy-mm-dd`.
  final String? purchasesDay;

  bool get hasTries => tries > 0;

  /// The state as it should be at [now]: refills applied, daily count rolled over.
  ClawTries refreshed(DateTime now) {
    var tries = this.tries;
    var next = nextRefillAt;

    if (tries >= maxFreeTries) {
      next = null;
    } else if (next == null) {
      next = now.add(refillInterval);
    } else if (next.difference(now) > refillInterval) {
      // The device clock moved backwards. Never make someone wait longer
      // than one full interval.
      next = now.add(refillInterval);
    } else if (!now.isBefore(next)) {
      final earned = 1 + now.difference(next).inMicroseconds ~/ refillInterval.inMicroseconds;
      final granted = earned.clamp(0, maxFreeTries - tries);
      tries += granted;
      next = tries >= maxFreeTries ? null : next.add(refillInterval * earned);
    }

    final today = dayOf(now);
    return ClawTries(
      tries: tries,
      nextRefillAt: next,
      purchasesToday: purchasesDay == today ? purchasesToday : 0,
      purchasesDay: today,
    );
  }

  /// Uses one try. Returns null if there are none.
  ClawTries? consume(DateTime now) {
    final current = refreshed(now);
    if (!current.hasTries) return null;
    final tries = current.tries - 1;
    return ClawTries(
      tries: tries,
      nextRefillAt: tries < maxFreeTries ? current.nextRefillAt ?? now.add(refillInterval) : null,
      purchasesToday: current.purchasesToday,
      purchasesDay: current.purchasesDay,
    );
  }

  int purchasesLeft(DateTime now) => maxPurchasesPerDay - refreshed(now).purchasesToday;

  /// Whether an extra try can be bought with [balance] ✷ at [now].
  BuyTryResult canBuy({required int balance, required DateTime now}) {
    if (purchasesLeft(now) <= 0) return BuyTryResult.dailyLimitReached;
    if (balance < tryPrice) return BuyTryResult.insufficientFunds;
    return BuyTryResult.bought;
  }

  /// Adds a bought try. Call only after [canBuy] returns [BuyTryResult.bought].
  ClawTries withBoughtTry(DateTime now) {
    final current = refreshed(now);
    final tries = current.tries + 1;
    return ClawTries(
      tries: tries,
      nextRefillAt: tries >= maxFreeTries ? null : current.nextRefillAt,
      purchasesToday: current.purchasesToday + 1,
      purchasesDay: current.purchasesDay,
    );
  }

  static String dayOf(DateTime time) {
    final local = time.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${local.year}-${two(local.month)}-${two(local.day)}';
  }
}
