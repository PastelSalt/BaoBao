import 'dart:async';

import 'package:baobao/app/router.dart';
import 'package:baobao/core/providers.dart';
import 'package:baobao/features/claw_machine/presentation/claw_machine_screen.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/app_harness.dart';

void main() {
  setUpAll(() async {
    await Harness.loadContent();
    await loadAppFonts();
  });

  Future<Harness> open(WidgetTester tester, {Map<String, Object> prefs = const {}}) async {
    final harness = await Harness.create(prefs: prefs);
    await tester.runAsync(() => onboard(harness));
    await pumpApp(tester, harness);
    unawaited(harness.container.read(routerProvider).push(Routes.claw));
    await settle(tester);
    return harness;
  }

  Future<int> tries(WidgetTester tester, Harness harness) async => (await tester.runAsync(
    () => harness.container.read(clawRepositoryProvider).tries(1, Harness.defaultNow),
  ))!.tries;

  testWidgets('shows tries, plays its music, and looks right', (tester) async {
    final harness = await open(tester);

    expect(find.text('Tries: 5'), findsOneWidget);
    expect(find.text('Hold to move'), findsOneWidget);
    expect(harness.music.log.last, 'play $clawMusicAsset loop');
    expect(tester.takeException(), isNull);
    await harness.dispose(tester);
  });

  testWidgets('holding moves the claw and letting go drops it, using one try', (tester) async {
    final harness = await open(tester);

    final gesture = await tester.startGesture(tester.getCenter(find.text('Hold to move')));
    await settle(tester, rounds: 2);
    expect(find.text('Let go to drop'), findsOneWidget);

    await gesture.up();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('…'), findsOneWidget);
    expect(await tries(tester, harness), 4);

    // The round plays out and the machine is ready again.
    for (var i = 0; i < 400; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    await settle(tester, rounds: 2);
    expect(find.text('Hold to move'), findsOneWidget);
    await harness.dispose(tester);
  });

  testWidgets('tap mode needs no holding', (tester) async {
    final harness = await open(tester, prefs: {'a11y.clawTapMode': true});

    await tapLabel(tester, 'Tap to start', rounds: 2);
    expect(find.text('Tap to drop'), findsOneWidget);
    await tester.tap(find.text('Tap to drop'));
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('…'), findsOneWidget);
    await harness.dispose(tester);
  });

  testWidgets('an extra try can be bought', (tester) async {
    final harness = await open(tester);
    await tapLabel(tester, '+1 try (50)');

    expect(find.text('Yay, an extra try!'), findsOneWidget);
    expect(await tries(tester, harness), 6);
    await harness.dispose(tester);
  });

  testWidgets('stats are one tap away', (tester) async {
    final harness = await open(tester);
    await tester.tap(find.byTooltip('Your claw stats'));
    await settle(tester, rounds: 2);
    expect(find.text('Plays'), findsOneWidget);
    expect(find.text('Best win'), findsOneWidget);
    await harness.dispose(tester);
  });
}
