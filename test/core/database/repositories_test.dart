import 'package:baobao/core/database/app_database.dart';
import 'package:baobao/features/claw_machine/data/claw_repository.dart';
import 'package:baobao/features/claw_machine/domain/claw_game.dart';
import 'package:baobao/features/claw_machine/domain/claw_tries.dart';
import 'package:baobao/features/conversation/data/conversation_repository.dart';
import 'package:baobao/features/conversation/domain/conversation_models.dart';
import 'package:baobao/features/conversation/domain/conversation_session.dart';
import 'package:baobao/features/economy/data/economy_repository.dart';
import 'package:baobao/features/economy/domain/catalog.dart';
import 'package:baobao/features/economy/domain/purchase_rules.dart';
import 'package:baobao/features/mood/data/mood_repository.dart';
import 'package:baobao/features/mood/domain/mood.dart';
import 'package:baobao/features/profiles/data/profile_repository.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';

import '../../support/test_database.dart';

void main() {
  final now = DateTime.utc(2026, 11, 11, 12);
  final catalog = shippedCatalog();
  late AppDatabase db;
  late ProfileRepository profiles;
  late EconomyRepository economy;
  late MoodRepository moods;
  late ClawRepository claw;

  setUp(() {
    db = memoryDatabase();
    profiles = ProfileRepository(db, catalog);
    economy = EconomyRepository(db, catalog);
    moods = MoodRepository(db);
    claw = ClawRepository(db);
  });
  tearDown(() => db.close());

  group('profiles', () {
    test('a new profile starts with 3000 ✷, the defaults equipped and five tries', () async {
      final profile = await profiles.create('  Mei  ', now);

      expect(profile.displayName, 'Mei');
      expect(await economy.balance(profile.id), 3000);
      expect(await economy.owned(profile.id), {'bamboo_morning', 'classic', 'bamboo'});
      final selections = await economy.watchSelections(profile.id).first;
      expect(selections.map((slot, item) => MapEntry(slot, item.id)), {
        ItemSlot.music: 'bamboo_morning',
        ItemSlot.outfit: 'classic',
        ItemSlot.background: 'bamboo',
      });
      expect((await claw.tries(profile.id, now)).tries, 5);
      expect((await moods.state(profile.id)).weight, 0);
      expect((await economy.ledger(profile.id)).single.reason, 'welcome');
    });

    test('cleans up display names', () {
      expect(ProfileRepository.cleanName('   '), 'Friend');
      expect(ProfileRepository.cleanName(' a   b '), 'a b');
      expect(ProfileRepository.cleanName('x' * 60), hasLength(40));
    });

    test('renames and lists profiles oldest first', () async {
      final a = await profiles.create('A', now);
      await profiles.create('B', now.add(const Duration(minutes: 1)));
      await profiles.rename(a.id, 'Ann');
      expect((await profiles.all()).map((p) => p.displayName), ['Ann', 'B']);
    });

    test('two profiles have independent wallets, items, moods and claw state', () async {
      final a = await profiles.create('A', now);
      final b = await profiles.create('B', now);

      await economy.purchase(a.id, catalog.byId('blue_bao')!, now);
      await moods.recordCheckIn(a.id, Mood.anxious, now);
      await claw.consumeTry(a.id, now);

      expect(await economy.balance(a.id), 2000);
      expect(await economy.balance(b.id), 3000);
      expect(await economy.owned(b.id), isNot(contains('blue_bao')));
      expect((await moods.state(b.id)).weight, 0);
      expect((await claw.tries(b.id, now)).tries, 5);

      // The prototype's bug: one account buying an item blocked the other.
      expect(await economy.purchase(b.id, catalog.byId('blue_bao')!, now), isA<PurchaseAllowed>());
    });

    test('deleting a profile removes every row that belonged to it', () async {
      final a = await profiles.create('A', now);
      final b = await profiles.create('B', now);
      await moods.recordCheckIn(a.id, Mood.sad, now);
      await economy.purchase(a.id, catalog.byId('paper_lanterns')!, now);

      await profiles.delete(a.id);

      for (final table in db.allTables) {
        final column = table.columnsByName['profile_id'] ?? table.columnsByName['id']!;
        final rows = await db
            .customSelect('SELECT ${column.name} AS owner FROM ${table.actualTableName}')
            .get();
        expect(
          rows.map((r) => r.read<int>('owner')),
          everyElement(b.id),
          reason: table.actualTableName,
        );
      }
    });
  });

  group('economy', () {
    late int id;
    setUp(() async => id = (await profiles.create('A', now)).id);

    test('a purchase takes the ✷, grants the item and is logged', () async {
      final decision = await economy.purchase(id, catalog.byId('bamboo_clouds')!, now);

      expect(decision, isA<PurchaseAllowed>());
      expect(await economy.balance(id), 2200);
      expect(await economy.owned(id), contains('bamboo_clouds'));
      final entry = (await economy.ledger(id)).first;
      expect((entry.amount, entry.reason), (-800, 'purchase:bamboo_clouds'));
    });

    test('buying something twice is refused and charges nothing', () async {
      final item = catalog.byId('paper_lanterns')!;
      await economy.purchase(id, item, now);
      expect(await economy.purchase(id, item, now), isA<AlreadyOwned>());
      expect(await economy.balance(id), 2500);
    });

    test('a purchase that cannot be afforded changes nothing', () async {
      for (final item in ['blue_bao', 'bamboo_plum', 'bamboo_clouds']) {
        await economy.purchase(id, catalog.byId(item)!, now);
      }
      expect(await economy.balance(id), 200);

      final decision = await economy.purchase(id, catalog.byId('paper_lanterns')!, now);
      expect((decision as InsufficientFunds).shortBy, 300);
      expect(await economy.balance(id), 200);
      expect(await economy.owned(id), isNot(contains('paper_lanterns')));
    });

    test('the balance can never go negative, even by a direct write', () async {
      await expectLater(
        db.adjustBalance(profileId: id, amount: -3001, reason: 'bug', now: now),
        throwsA(anything),
      );
      expect(await economy.balance(id), 3000);
    });

    test('only owned items can be equipped', () async {
      final outfit = catalog.byId('blue_bao')!;
      expect(await economy.select(id, outfit), isFalse);

      await economy.purchase(id, outfit, now);
      expect(await economy.select(id, outfit), isTrue);
      expect((await economy.watchSelections(id).first)[ItemSlot.outfit]!.id, 'blue_bao');
    });

    test('a selection that left the catalogue falls back to the default', () async {
      await (db.update(db.selections)..where((s) => s.slot.equals('music'))).write(
        const SelectionsCompanion(itemId: Value('removed_track')),
      );
      expect((await economy.watchSelections(id).first)[ItemSlot.music]!.id, 'bamboo_morning');
    });

    test('the balance stream emits after a purchase', () async {
      final balances = economy.watchBalance(id);
      expect(await balances.first, 3000);
      await economy.purchase(id, catalog.byId('paper_lanterns')!, now);
      expect(await balances.first, 2500);
    });
  });

  group('mood', () {
    late int id;
    setUp(() async => id = (await profiles.create('A', now)).id);

    test('two anxious check-ins start the intervention and stamp the time', () async {
      final first = await moods.recordCheckIn(id, Mood.anxious, now);
      expect(first.intervene, isFalse);

      final second = await moods.recordCheckIn(id, Mood.anxious, now);
      expect(second.intervene, isTrue);
      expect(second.state.weight, 4);
      expect((await moods.state(id)).lastInterventionAt, now);
    });

    test('the intervention does not repeat within 24 hours, then can', () async {
      await moods.recordCheckIn(id, Mood.anxious, now);
      await moods.recordCheckIn(id, Mood.anxious, now);

      final soon = await moods.recordCheckIn(id, Mood.sad, now.add(const Duration(hours: 5)));
      expect(soon.intervene, isFalse);

      final later = await moods.recordCheckIn(id, Mood.sad, now.add(const Duration(hours: 25)));
      expect(later.intervene, isTrue);
    });

    test('remembers the newest moods, oldest first', () async {
      for (final mood in [Mood.happy, Mood.sad, Mood.tired, Mood.okay]) {
        await moods.recordCheckIn(id, mood, now);
      }
      expect(await moods.recentMoods(id), [Mood.sad, Mood.tired, Mood.okay]);
      expect(await moods.watchLatestMood(id).first, Mood.okay);
    });

    test('there is no latest mood before the first check-in', () async {
      expect(await moods.watchLatestMood(id).first, isNull);
    });

    test('a conversation choice can lift the mood', () async {
      await moods.recordCheckIn(id, Mood.anxious, now);
      await moods.applyEffect(id, 1);
      expect((await moods.state(id)).weight, 1);
    });
  });

  group('claw machine', () {
    late int id;
    setUp(() async => id = (await profiles.create('A', now)).id);

    test('tries are used up and then refused', () async {
      for (var i = 0; i < 5; i++) {
        expect(await claw.consumeTry(id, now), isNotNull);
      }
      expect(await claw.consumeTry(id, now), isNull);
    });

    test('refills are saved', () async {
      await claw.consumeTry(id, now);
      await claw.consumeTry(id, now);
      final later = await claw.tries(id, now.add(const Duration(minutes: 6)));
      expect(later.tries, 4);
      expect((await claw.watchTries(id).first).tries, 4);
    });

    test('buying a try costs 50 ✷', () async {
      expect(await claw.buyTry(id, now), BuyTryResult.bought);
      expect(await economy.balance(id), 2950);
      expect((await claw.tries(id, now)).tries, 6);
      expect((await economy.ledger(id)).first.reason, 'claw:try');
    });

    test('a refused purchase charges nothing', () async {
      for (var i = 0; i < 10; i++) {
        await claw.buyTry(id, now);
      }
      expect(await claw.buyTry(id, now), BuyTryResult.dailyLimitReached);
      expect(await economy.balance(id), 2500);
    });

    test('a win pays out and updates the statistics; a miss only counts the play', () async {
      final prize = Prize(x: 0.5, value: 99, rare: false);
      await claw.recordResult(id, ClawResult(prize: prize, multiplier: 1.2, streak: 3), now);
      await claw.recordResult(id, const ClawResult.miss(), now);

      expect(await economy.balance(id), 3118);
      final stats = await claw.watchStats(id).first;
      expect((stats.plays, stats.wins, stats.earnings, stats.bestWin), (2, 1, 118, 118));
    });
  });

  group('conversation progress', () {
    test('keeps only the latest conversation', () async {
      final id = (await profiles.create('A', now)).id;
      final repository = ConversationRepository(db);
      final tree = ConversationTree.fromJson({
        'id': 'sad',
        'start': 'a',
        'nodes': {
          'a': {
            'line': 'Hi',
            'options': [
              {'text': 'Next', 'next': 'b'},
            ],
          },
          'b': {
            'line': 'Bye',
            'options': [
              {'text': 'Done', 'next': '@end'},
            ],
          },
        },
      });
      final start = ConversationSession.start(tree);
      await repository.save(id, start, now);
      final next = (start.choose(tree.start.options.single) as ContinueStep).session;
      await repository.save(id, next, now);

      final saved = (await repository.latest(id))!;
      expect((saved.treeId, saved.lastNodeId, saved.path), ('sad', 'b', '["a","b"]'));
    });
  });
}
