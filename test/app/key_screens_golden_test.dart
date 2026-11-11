import 'dart:async';

import 'package:baobao/app/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/app_harness.dart';

/// Decodes every image on screen so it appears in the golden. Image decoding
/// needs real time, which the test clock does not provide on its own.
Future<void> showImages(WidgetTester tester) async {
  await tester.runAsync(() async {
    for (final element in find.byType(Image).evaluate()) {
      await precacheImage((element.widget as Image).image, element);
    }
    await Future<void>.delayed(const Duration(milliseconds: 300));
  });
  await tester.pump(const Duration(milliseconds: 400));
}

void main() {
  setUpAll(() async {
    await Harness.loadContent();
    await loadAppFonts();
  });

  Future<Harness> start(WidgetTester tester, {double textScale = 1}) async {
    tester.platformDispatcher.textScaleFactorTestValue = textScale;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final harness = await Harness.create(prefs: {'help.country': 'US'});
    await tester.runAsync(() => onboard(harness));
    await pumpApp(tester, harness, size: const Size(412, 892));
    return harness;
  }

  Future<void> snap(WidgetTester tester, String name) async {
    await showImages(tester);
    expect(tester.takeException(), isNull);
    await expectLater(find.byType(MaterialApp), matchesGoldenFile('goldens/$name.png'));
  }

  for (final scale in [1.0, 2.0]) {
    final suffix = '${scale.toStringAsFixed(0)}x';

    testWidgets('home at $suffix text', (tester) async {
      final harness = await start(tester, textScale: scale);
      await snap(tester, 'home_$suffix');
      await harness.dispose(tester);
    });

    testWidgets('conversation at $suffix text', (tester) async {
      final harness = await start(tester, textScale: scale);
      await tapLabel(tester, 'How are you feeling?');
      await tapLabel(tester, 'Sad');
      await snap(tester, 'conversation_$suffix');
      await harness.dispose(tester);
    });

    for (final (name, route) in [
      ('shop', Routes.shop),
      ('settings', Routes.settings),
      ('resources', Routes.resources),
    ]) {
      testWidgets('$name at $suffix text', (tester) async {
        final harness = await start(tester, textScale: scale);
        unawaited(harness.container.read(routerProvider).push(route));
        await settle(tester);
        await snap(tester, '${name}_$suffix');
        await harness.dispose(tester);
      });
    }
  }
}
