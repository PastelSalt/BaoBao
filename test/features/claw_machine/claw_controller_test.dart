import 'dart:io';
import 'dart:math';

import 'package:baobao/app/router.dart';
import 'package:baobao/core/audio/audio_director.dart';
import 'package:baobao/core/content/app_content.dart';
import 'package:baobao/core/database/app_database.dart';
import 'package:baobao/features/claw_machine/application/claw_controller.dart';
import 'package:baobao/features/claw_machine/data/claw_repository.dart';
import 'package:baobao/features/claw_machine/domain/claw_game.dart';
import 'package:baobao/features/claw_machine/presentation/claw_machine_screen.dart';
import 'package:baobao/features/economy/data/economy_repository.dart';
import 'package:baobao/features/profiles/data/profile_repository.dart';
import 'package:baobao/features/shop/presentation/shop_screen.dart';
import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../core/audio/audio_director_test.dart' show FakeChannel;
import '../../support/test_database.dart';

const frame = Duration(milliseconds: 16);

void main() {
  final now = DateTime(2026, 11, 11, 12);
  late AppContent content;
  late AppDatabase db;
  late ClawRepository repository;
  late EconomyRepository economy;
  late FakeChannel voice;
  late int id;

  setUpAll(() async => content = await AppContent.load((path) => File(path).readAsString()));

  setUp(() async {
    db = memoryDatabase();
    repository = ClawRepository(db);
    economy = EconomyRepository(db, content.catalog);
    voice = FakeChannel();
    id = (await ProfileRepository(db, content.catalog).create('A', now)).id;
  });
  tearDown(() => db.close());

  ClawController controller(List<Prize> prizes) {
    final c = ClawController(
      profileId: id,
      repository: repository,
      audio: AudioDirector(music: FakeChannel(), voice: voice, sfx: FakeChannel()),
      content: content,
      clock: Clock.fixed(now),
      game: ClawGame(random: Random(1), prizes: prizes),
    );
    addTearDown(c.dispose);
    return c;
  }

  /// Advances until [done], failing rather than looping forever.
  void run(ClawController c, bool Function() done) {
    for (var i = 0; i < 3000 && !done(); i++) {
      c.advance(frame);
    }
    expect(done(), isTrue);
  }

  test('greets with the intro line', () async {
    controller([]);
    await pumpEventQueue();
    expect(voice.log, ['play assets/audio/voice/en/h_01.m4a']);
  });

  test('a winning round spends a try, pays out, and resets for the next go', () async {
    final c = controller([
      Prize(x: 0.5, value: 80, rare: false),
      Prize(x: 0.8, value: 5, rare: false),
    ]);

    await c.press();
    expect(c.game.phase, ClawPhase.moving);
    expect((await repository.tries(id, now)).tries, 4);
    c.release();

    run(c, () => c.shownResult != null);
    expect(c.shownResult!.payout, 80);
    await pumpEventQueue();
    expect(voice.log.last, 'play assets/audio/voice/en/h_03.m4a');

    // Let the write finish, then check the money arrived exactly once.
    await Future<void>.delayed(Duration.zero);
    run(c, () => c.game.phase == ClawPhase.idle);
    await pumpEventQueue();
    expect(await economy.balance(id), 3080);
    expect(c.shownResult, isNull);
    expect(c.canStart, isTrue);
  });

  test('a miss pays nothing and BaoBao encourages another try', () async {
    final c = controller([Prize(x: 0.85, value: 80, rare: false)]);
    await c.press();
    c.release();
    run(c, () => c.shownResult != null);

    expect(c.shownResult!.won, isFalse);
    await pumpEventQueue();
    expect(voice.log.last, 'play assets/audio/voice/en/h_04.m4a');
    await pumpEventQueue();
    expect(await economy.balance(id), 3000);
    final stats = await repository.watchStats(id).first;
    expect((stats.plays, stats.wins), (1, 0));
  });

  test('with no tries left the claw does not move', () async {
    for (var i = 0; i < 5; i++) {
      await repository.consumeTry(id, now);
    }
    final c = controller([]);
    await c.press();
    expect(c.game.phase, ClawPhase.idle);
    expect(c.notice, ClawNotice.noTries);
  });

  test('letting go before the try is spent still drops the claw', () async {
    final c = controller([]);
    final pressing = c.press();
    c.release();
    await pressing;
    expect(c.game.phase, ClawPhase.dropping);
  });

  test('pressing mid-round does nothing and costs nothing', () async {
    final c = controller([]);
    await c.press();
    c.release();
    await c.press();
    expect((await repository.tries(id, now)).tries, 4);
  });

  test('tap mode: one tap starts, the next drops', () async {
    final c = controller([]);
    await c.tap();
    expect(c.game.phase, ClawPhase.moving);
    await c.tap();
    expect(c.game.phase, ClawPhase.dropping);
  });

  test('buying a try reports what happened', () async {
    final c = controller([]);
    await c.buyTry();
    expect(c.notice, ClawNotice.boughtTry);
    expect(await economy.balance(id), 2950);

    for (var i = 0; i < 9; i++) {
      await c.buyTry();
    }
    await c.buyTry();
    expect(c.notice, ClawNotice.dailyLimit);
  });

  test('buying a try without enough stars is refused', () async {
    await db.adjustBalance(profileId: id, amount: -2990, reason: 'test', now: now);
    final c = controller([]);
    await c.buyTry();
    expect(c.notice, ClawNotice.notEnoughStars);
  });

  test('each screen gets its own music, and the lock screen is silent', () {
    const chosen = 'assets/audio/music/little.mp3';
    expect(musicFor(Routes.home, selectedMusic: chosen), chosen);
    expect(musicFor(Routes.settings, selectedMusic: chosen), chosen);
    expect(musicFor(Routes.shop, selectedMusic: chosen), shopMusicAsset);
    expect(musicFor(Routes.claw, selectedMusic: chosen), clawMusicAsset);
    expect(musicFor(Routes.unlock, selectedMusic: chosen), isNull);
  });
}
