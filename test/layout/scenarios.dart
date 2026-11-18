import 'package:baobao/app/router.dart';
import 'package:baobao/core/providers.dart';
import 'package:baobao/core/security/app_lock.dart';
import 'package:baobao/core/widgets/character_view.dart';
import 'package:baobao/core/widgets/speech_bubble.dart';
import 'package:baobao/features/economy/domain/catalog.dart';
import 'package:flutter/widgets.dart' show ListView;
import 'package:flutter_test/flutter_test.dart';

import '../support/app_harness.dart';
import '../support/layout_checks.dart';

/// One screen in one state, to be checked at every size and text scale.
class Scenario {
  const Scenario(
    this.name,
    this.start, {
    this.lockAvailable,
    this.prefs = const {},
    this.extraChecks,
    this.prepare,
  });

  final String name;
  final Future<void> Function(WidgetTester tester, Harness harness) start;
  final bool? lockAvailable;
  final Map<String, Object> prefs;

  /// Writes to the database before the app is on screen. (Writing behind a
  /// mounted screen from a test deadlocks.)
  final Future<void> Function(Harness harness)? prepare;

  /// Checks specific to this screen, such as "the speech bubble is fully visible".
  final List<String> Function(WidgetTester tester)? extraChecks;
}

/// Unlocks every shop item, so every card is on screen.
Future<void> _ownEverything(Harness harness) async {
  final economy = harness.container.read(economyRepositoryProvider);
  for (final item in harness.content.catalog.items) {
    await harness.database.adjustBalance(
      profileId: 1,
      amount: item.price,
      reason: 'test',
      now: Harness.defaultNow,
    );
    await economy.purchase(1, item, Harness.defaultNow);
  }
}

Future<void> _openRoute(WidgetTester tester, Harness harness, String route) async {
  harness.container.read(routerProvider).push(route).ignore();
  await settle(tester);
}

List<String> _homeChecks(WidgetTester tester) => [
  ...notFullyVisible(tester, find.byType(SpeechBubble), 'the speech bubble'),
  ...notFullyVisible(tester, find.byType(CharacterView), 'the character'),
];

final scenarios = <Scenario>[
  Scenario('onboarding_welcome', (tester, harness) async {}, prefs: {}),
  Scenario('onboarding_promise', (tester, harness) async {
    await tapLabel(tester, "Let's begin");
  }),
  Scenario('onboarding_name', (tester, harness) async {
    await tapLabel(tester, "Let's begin");
    await tapLabel(tester, 'I understand BaoBao is not a substitute for professional care.');
    await tapLabel(tester, 'I am 13 or older.');
    await tapLabel(tester, 'Continue');
  }),
  Scenario('unlock', (tester, harness) async {
    harness.container.read(appLockProvider.notifier).lock();
    await settle(tester);
  }, lockAvailable: false),
  Scenario('tutorial', (tester, harness) async => _openRoute(tester, harness, Routes.tutorial)),
  Scenario('home_idle', (tester, harness) async {}, extraChecks: _homeChecks),
  Scenario('home_conversation', (tester, harness) async {
    await tapLabel(tester, 'How are you feeling?');
    await tapLabel(tester, 'Sad');
  }, extraChecks: _homeChecks),
  Scenario('home_longest_line', (tester, harness) async {
    // Driven through the screen, not the controller: writing to the database
    // behind a mounted screen from a test deadlocks.
    for (var i = 0; i < 2; i++) {
      await tapLabel(tester, 'How are you feeling?');
      await tapLabel(tester, 'Anxious');
      if (i == 0) await tapLabel(tester, 'End chat for now');
    }
    // The intervention's longest line.
    await tapLabel(tester, 'Tell me more');
  }, extraChecks: _homeChecks),
  Scenario('mood_sheet', (tester, harness) async {
    await tapLabel(tester, 'How are you feeling?');
  }),
  Scenario('style_sheet', (tester, harness) async {
    await tester.tap(find.byTooltip('Style'));
    await settle(tester);
  }, prepare: _ownEverything),
  Scenario('shop', (tester, harness) async => _openRoute(tester, harness, Routes.shop)),
  Scenario('shop_confirm', (tester, harness) async {
    await _openRoute(tester, harness, Routes.shop);
    // The list builds cards lazily, so scroll until a Buy button exists on screen.
    final buy = find.text('Buy');
    for (var i = 0; i < 12 && buy.evaluate().isEmpty; i++) {
      await tester.drag(find.byType(ListView).first, const Offset(0, -250));
      await tester.pump();
    }
    await tester.ensureVisible(buy.first);
    await tester.tap(buy.first);
    await settle(tester);
  }),
  Scenario(
    'settings',
    (tester, harness) async => _openRoute(tester, harness, Routes.settings),
    lockAvailable: true,
  ),
  Scenario(
    'help_known_country',
    (tester, harness) async => _openRoute(tester, harness, Routes.resources),
    prefs: {'help.country': 'US'},
  ),
  Scenario(
    'help_unknown_country',
    (tester, harness) async => _openRoute(tester, harness, Routes.resources),
    prefs: {'help.country': 'ZZ'},
  ),
  Scenario('claw_machine', (tester, harness) async => _openRoute(tester, harness, Routes.claw)),
];

/// Scenarios that start before onboarding is complete.
const beforeOnboarding = {'onboarding_welcome', 'onboarding_promise', 'onboarding_name'};

/// Catalogue items, used by tests that need every one.
Iterable<CatalogItem> allItems(Harness harness) => harness.content.catalog.items;
