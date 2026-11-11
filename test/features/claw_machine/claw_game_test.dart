import 'dart:math';

import 'package:baobao/features/claw_machine/domain/claw_game.dart';
import 'package:flutter_test/flutter_test.dart';

const frame = Duration(milliseconds: 16);

/// Ticks until [phase] is reached. Fails rather than looping forever.
void runUntil(ClawGame game, ClawPhase phase) {
  for (var i = 0; i < 2000 && game.phase != phase; i++) {
    game.tick(frame);
  }
  expect(game.phase, phase);
}

ClawGame gameWith(List<Prize> prizes) => ClawGame(random: Random(1), prizes: prizes);

void main() {
  group('multiplier', () {
    test('grows with the win streak', () {
      expect([1, 2, 3, 4, 5, 6, 7, 20].map(ClawGame.multiplierFor), [
        1.0, 1.0, 1.2, 1.2, 1.5, 1.5, 2.0, 2.0, //
      ]);
    });
  });

  group('prize generation', () {
    test('makes four prizes inside the play area that do not overlap', () {
      for (var seed = 0; seed < 50; seed++) {
        final prizes = ClawGame.generatePrizes(Random(seed));
        expect(prizes, hasLength(4));
        for (var i = 0; i < prizes.length; i++) {
          expect(prizes[i].x - prizes[i].width / 2, greaterThanOrEqualTo(ClawGame.minX - 1e-9));
          expect(prizes[i].x + prizes[i].width / 2, lessThanOrEqualTo(ClawGame.maxX + 1e-9));
          if (i > 0) {
            expect(prizes[i].x - prizes[i - 1].x, greaterThanOrEqualTo(Prize.defaultWidth - 1e-9));
          }
        }
      }
    });

    test('normal prizes are worth 10–100 and rare ones 150–250', () {
      final prizes = [for (var s = 0; s < 200; s++) ...ClawGame.generatePrizes(Random(s))];
      for (final prize in prizes) {
        expect(prize.value, prize.rare ? inInclusiveRange(150, 250) : inInclusiveRange(10, 100));
      }
      final rareShare = prizes.where((p) => p.rare).length / prizes.length;
      expect(rareShare, closeTo(ClawGame.rareChance, 0.05));
    });
  });

  group('movement', () {
    test('does nothing until started', () {
      final game = gameWith([]);
      game.tick(const Duration(seconds: 1));
      expect(game.clawX, 0.5);
      expect(game.phase, ClawPhase.idle);
    });

    test('sweeps and bounces between the walls', () {
      final game = gameWith([])..startMoving();
      var sawLeft = false, sawRight = false;
      for (var i = 0; i < 400; i++) {
        game.tick(frame);
        expect(game.clawX, inInclusiveRange(ClawGame.minX, ClawGame.maxX));
        sawLeft |= game.clawX < 0.15;
        sawRight |= game.clawX > 0.85;
      }
      expect(sawLeft && sawRight, isTrue);
    });

    test('stays in bounds even after a very long frame', () {
      final game = gameWith([])..startMoving();
      game.tick(const Duration(seconds: 37));
      expect(game.clawX, inInclusiveRange(ClawGame.minX, ClawGame.maxX));
    });

    test('drop is ignored unless the claw is sweeping', () {
      final game = gameWith([])..drop();
      expect(game.phase, ClawPhase.idle);
    });
  });

  group('a round', () {
    test('catching a prize carries it to the chute and pays out', () {
      final prize = Prize(x: 0.5, value: 80, rare: false);
      final game = gameWith([prize])
        ..startMoving()
        ..drop();

      runUntil(game, ClawPhase.lifting);
      expect(game.held, prize);
      expect(game.result!.won, isTrue);

      runUntil(game, ClawPhase.releasing);
      expect(game.clawX, closeTo(ClawGame.chuteX, 1e-9));

      runUntil(game, ClawPhase.finished);
      expect(game.held, isNull);
      expect(prize.taken, isTrue);
      expect(game.result!.payout, 80);
      expect(game.streak, 1);
    });

    test('a miss lifts an empty claw, pays nothing and resets the streak', () {
      final game = gameWith([Prize(x: 0.85, value: 80, rare: false)])
        ..streak = 4
        ..startMoving()
        ..drop();

      runUntil(game, ClawPhase.finished);
      expect(game.result!.won, isFalse);
      expect(game.result!.payout, 0);
      expect(game.streak, 0);
      expect(game.clawX, 0.5, reason: 'an empty claw does not travel to the chute');
    });

    test('the third win in a row pays 1.2×, rounded down', () {
      final game = gameWith([Prize(x: 0.5, value: 99, rare: true)])
        ..streak = 2
        ..startMoving()
        ..drop();

      runUntil(game, ClawPhase.finished);
      expect(game.result!.streak, 3);
      expect(game.result!.multiplier, 1.2);
      expect(game.result!.payout, 118);
      expect(game.result!.rare, isTrue);
    });

    test('the catch zone is forgiving but not unlimited', () {
      final game = gameWith([Prize(x: 0.5, value: 10, rare: false)]);
      const reach = Prize.defaultWidth / ClawGame.catchTolerance;
      expect(game.prizeAt(0.5 + reach - 0.001), isNotNull);
      expect(game.prizeAt(0.5 + reach + 0.001), isNull);
    });

    test('picks the nearest prize and ignores taken ones', () {
      final near = Prize(x: 0.52, value: 1, rare: false);
      final far = Prize(x: 0.42, value: 2, rare: false);
      final game = gameWith([far, near]);
      expect(game.prizeAt(0.5), near);
      near.taken = true;
      expect(game.prizeAt(0.5), far);
    });

    test('the drop takes its full duration', () {
      final game = gameWith([])
        ..startMoving()
        ..drop();
      game.tick(ClawGame.dropDuration - const Duration(milliseconds: 1));
      expect(game.phase, ClawPhase.dropping);
      game.tick(const Duration(milliseconds: 1));
      expect(game.phase, ClawPhase.lifting);
    });
  });

  group('nextRound', () {
    test('resets the claw and keeps remaining prizes', () {
      final left = Prize(x: 0.3, value: 10, rare: false);
      final game = gameWith([Prize(x: 0.5, value: 10, rare: false), left])
        ..startMoving()
        ..drop();
      runUntil(game, ClawPhase.finished);

      game.nextRound();
      expect(game.phase, ClawPhase.idle);
      expect(game.clawX, 0.5);
      expect(game.result, isNull);
      expect(game.prizes.where((p) => !p.taken), [left]);
      expect(game.streak, 1, reason: 'the streak carries into the next round');
    });

    test('refills the machine once every prize is taken', () {
      final game = gameWith([Prize(x: 0.5, value: 10, rare: false)])
        ..startMoving()
        ..drop();
      runUntil(game, ClawPhase.finished);

      game.nextRound();
      expect(game.prizes, hasLength(ClawGame.prizeCount));
      expect(game.prizes.every((p) => !p.taken), isTrue);
    });

    test('is ignored mid-round', () {
      final game = gameWith([])..startMoving();
      game.nextRound();
      expect(game.phase, ClawPhase.moving);
    });
  });
}
