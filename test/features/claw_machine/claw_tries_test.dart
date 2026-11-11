import 'package:baobao/features/claw_machine/domain/claw_tries.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final noon = DateTime(2026, 11, 11, 12);
  const interval = ClawTries.refillInterval;

  group('consume', () {
    test('starts full with no timer', () {
      final tries = const ClawTries().refreshed(noon);
      expect(tries.tries, 5);
      expect(tries.nextRefillAt, isNull);
    });

    test('using a try starts the refill timer', () {
      final tries = const ClawTries().consume(noon)!;
      expect(tries.tries, 4);
      expect(tries.nextRefillAt, noon.add(interval));
    });

    test('using another try does not restart the timer', () {
      final first = const ClawTries().consume(noon)!;
      final second = first.consume(noon.add(const Duration(minutes: 2)))!;
      expect(second.tries, 3);
      expect(second.nextRefillAt, noon.add(interval));
    });

    test('returns null when there are no tries', () {
      final empty = ClawTries(tries: 0, nextRefillAt: noon.add(interval));
      expect(empty.consume(noon), isNull);
    });
  });

  group('refill', () {
    final used = ClawTries(tries: 1, nextRefillAt: noon.add(interval));

    test('nothing arrives early', () {
      expect(used.refreshed(noon.add(const Duration(minutes: 4, seconds: 59))).tries, 1);
    });

    test('one try arrives per interval and keeps leftover progress', () {
      final later = used.refreshed(noon.add(const Duration(minutes: 12)));
      expect(later.tries, 3);
      expect(later.nextRefillAt, noon.add(interval * 3));
    });

    test('stops at the free maximum and clears the timer', () {
      final later = used.refreshed(noon.add(const Duration(hours: 3)));
      expect(later.tries, 5);
      expect(later.nextRefillAt, isNull);
    });

    test('bought tries above the maximum are kept and pause refilling', () {
      final rich = const ClawTries(tries: 7).refreshed(noon.add(const Duration(hours: 1)));
      expect(rich.tries, 7);
      expect(rich.nextRefillAt, isNull);
    });

    test('a clock moved backwards never makes the wait longer than one interval', () {
      final lastWeek = noon.subtract(const Duration(days: 7));
      expect(used.refreshed(lastWeek).nextRefillAt, lastWeek.add(interval));
    });

    test('a missing timer below the maximum is repaired', () {
      expect(const ClawTries(tries: 2).refreshed(noon).nextRefillAt, noon.add(interval));
    });
  });

  group('buying tries', () {
    test('is allowed with enough ✷ and purchases left', () {
      expect(const ClawTries().canBuy(balance: 50, now: noon), BuyTryResult.bought);
    });

    test('is refused without enough ✷', () {
      expect(const ClawTries().canBuy(balance: 49, now: noon), BuyTryResult.insufficientFunds);
    });

    test('is limited to ten a day', () {
      var tries = const ClawTries(tries: 0);
      for (var i = 0; i < 10; i++) {
        tries = tries.withBoughtTry(noon);
      }
      expect(tries.tries, 10);
      expect(tries.purchasesLeft(noon), 0);
      expect(tries.canBuy(balance: 9999, now: noon), BuyTryResult.dailyLimitReached);
    });

    test('the daily limit resets the next day', () {
      final spent = ClawTries(purchasesToday: 10, purchasesDay: ClawTries.dayOf(noon));
      final tomorrow = noon.add(const Duration(days: 1));
      expect(spent.purchasesLeft(tomorrow), 10);
      expect(spent.canBuy(balance: 50, now: tomorrow), BuyTryResult.bought);
    });

    test('buying up to the maximum clears the timer', () {
      final tries = ClawTries(tries: 4, nextRefillAt: noon.add(interval)).withBoughtTry(noon);
      expect(tries.tries, 5);
      expect(tries.nextRefillAt, isNull);
    });
  });
}
