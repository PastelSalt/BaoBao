import 'dart:async';

import 'package:baobao/app/router.dart';
import 'package:baobao/core/providers.dart';
import 'package:baobao/features/customization/presentation/item_card.dart';
import 'package:baobao/features/economy/domain/catalog.dart';
import 'package:baobao/features/shop/presentation/shop_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/app_harness.dart';

/// The [button] on the card of the item called [item].
Finder onCard(String item, String button) => find.descendant(
  of: find.ancestor(of: find.text(item), matching: find.byType(ItemCard)),
  matching: find.text(button),
);

void main() {
  setUpAll(Harness.loadContent);

  Future<Harness> open(WidgetTester tester, {int spend = 0}) async {
    final harness = await Harness.create();
    await tester.runAsync(() async {
      await onboard(harness);
      // Done before any screen is listening to the wallet.
      await harness.database.adjustBalance(
        profileId: 1,
        amount: -spend,
        reason: 'test',
        now: Harness.defaultNow,
      );
    });
    await pumpApp(tester, harness, size: const Size(420, 2000));
    unawaited(harness.container.read(routerProvider).push(Routes.shop));
    await settle(tester);
    return harness;
  }

  Future<Map<ItemSlot, String>> selections(WidgetTester tester, Harness harness) async {
    final map = await tester.runAsync(
      () => harness.container.read(economyRepositoryProvider).watchSelections(1).first,
    );
    return map!.map((slot, item) => MapEntry(slot, item.id));
  }

  testWidgets('the shop has its own music and a voiced welcome', (tester) async {
    final harness = await open(tester);
    expect(harness.music.log.last, 'play $shopMusicAsset loop');
    expect(harness.voice.log.last, matches(RegExp(r'voice/en/c_0\d\.m4a$')));

    // Leaving returns to the chosen home track.
    await tester.pageBack();
    await settle(tester);
    expect(harness.music.log.last, 'play assets/audio/music/bamboo_morning.m4a loop');
    await harness.dispose(tester);
  });

  testWidgets('buying asks first, then charges, grants and equips', (tester) async {
    final harness = await open(tester);

    await tester.tap(onCard('Blue Bao', 'Buy'));
    await settle(tester);
    expect(find.text('Buy Blue Bao?'), findsOneWidget);

    // Cancelling changes nothing.
    await tapLabel(tester, 'Cancel');
    expect(
      await tester.runAsync(() => harness.container.read(economyRepositoryProvider).balance(1)),
      3000,
    );

    await tester.tap(onCard('Blue Bao', 'Buy'));
    await settle(tester);
    await tester.tap(find.descendant(of: find.byType(Dialog), matching: find.text('Buy')));
    await settle(tester);

    expect(
      await tester.runAsync(() => harness.container.read(economyRepositoryProvider).balance(1)),
      2000,
    );
    expect((await selections(tester, harness))[ItemSlot.outfit], 'blue_bao');
    expect(find.textContaining('Blue Bao is yours'), findsOneWidget);
    await harness.dispose(tester);
  });

  testWidgets('a purchase that cannot be afforded explains why and charges nothing', (
    tester,
  ) async {
    final harness = await open(tester, spend: 2900);

    await tester.tap(onCard('Paper Lanterns', 'Buy'));
    await settle(tester);
    await tester.tap(find.descendant(of: find.byType(Dialog), matching: find.text('Buy')));
    await settle(tester);

    expect(find.textContaining('You need 400 more stars'), findsOneWidget);
    expect(
      await tester.runAsync(() => harness.container.read(economyRepositoryProvider).balance(1)),
      100,
    );
    await harness.dispose(tester);
  });

  testWidgets('music can be previewed and the shop track returns afterwards', (tester) async {
    final harness = await open(tester);

    await tester.tap(find.byTooltip('Preview Paper Lanterns'));
    await tester.pump();
    expect(harness.music.log.last, 'play assets/audio/music/paper_lanterns.m4a loop');

    await tester.tap(find.byTooltip('Stop preview of Paper Lanterns'));
    await tester.pump();
    expect(harness.music.log.last, 'play $shopMusicAsset loop');
    await harness.dispose(tester);
  });

  testWidgets('owned items can be switched from the style sheet on home', (tester) async {
    final harness = await Harness.create();
    await tester.runAsync(() async {
      await onboard(harness);
      final economy = harness.container.read(economyRepositoryProvider);
      await economy.purchase(1, harness.content.catalog.byId('bamboo_plum')!, Harness.defaultNow);
    });
    await pumpApp(tester, harness, size: const Size(420, 2600));

    await tapLabel(tester, 'Style');
    expect(find.text('Bamboo Plum'), findsOneWidget);
    expect(find.text('Bamboo Clouds'), findsNothing, reason: 'only owned items are listed');

    await tester.tap(onCard('Bamboo Plum', 'Use'));
    await settle(tester);
    expect((await selections(tester, harness))[ItemSlot.background], 'bamboo_plum');
    await harness.dispose(tester);
  });
}
