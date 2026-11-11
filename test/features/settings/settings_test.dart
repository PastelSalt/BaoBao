import 'dart:async';

import 'package:baobao/app/router.dart';
import 'package:baobao/core/providers.dart';
import 'package:baobao/core/settings/app_settings.dart';
import 'package:baobao/features/home/presentation/home_screen.dart';
import 'package:baobao/features/onboarding/presentation/onboarding_screen.dart';
import 'package:baobao/features/tutorial/presentation/tutorial_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/app_harness.dart';

void main() {
  setUpAll(Harness.loadContent);

  Future<Harness> open(WidgetTester tester, {bool? lockAvailable, int profiles = 1}) async {
    final harness = await Harness.create(lockAvailable: lockAvailable);
    await tester.runAsync(() async {
      await onboard(harness);
      for (var i = 1; i < profiles; i++) {
        await harness.container
            .read(profileRepositoryProvider)
            .create('Other $i', Harness.defaultNow.add(Duration(minutes: i)));
      }
    });
    await pumpApp(tester, harness, size: const Size(420, 2600));
    unawaited(harness.container.read(routerProvider).push(Routes.settings));
    await settle(tester);
    return harness;
  }

  AppSettings settings(Harness harness) => harness.container.read(settingsProvider);

  testWidgets('volume sliders change playback straight away and are saved', (tester) async {
    final harness = await open(tester);

    final music = find.byType(Slider).first;
    await tester.drag(music, const Offset(-500, 0));
    await tester.pump();

    expect(settings(harness).musicVolume, 0);
    expect(harness.music.volume, 0);
    await harness.dispose(tester);
  });

  testWidgets('switching the voice off silences BaoBao but keeps the words', (tester) async {
    final harness = await open(tester);
    await tapLabel(tester, "BaoBao's voice");
    expect(settings(harness).voiceEnabled, isFalse);

    harness.voice.log.clear();
    await tester.pageBack();
    await settle(tester);
    await tapLabel(tester, 'Joke');
    expect(harness.voice.log.where((entry) => entry.startsWith('play')), isEmpty);
    await harness.dispose(tester);
  });

  testWidgets('accessibility switches are saved', (tester) async {
    final harness = await Harness.create(reducedMotion: false);
    await tester.runAsync(() => onboard(harness));
    await pumpApp(tester, harness, size: const Size(420, 2600));
    unawaited(harness.container.read(routerProvider).push(Routes.settings));
    await settle(tester);

    await tapLabel(tester, 'Reduce motion');
    await tapLabel(tester, 'Tap instead of hold in the claw machine');
    expect(settings(harness).reducedMotion, isTrue);
    expect(settings(harness).clawTapMode, isTrue);
    await harness.dispose(tester);
  });

  testWidgets('the name can be changed', (tester) async {
    final harness = await open(tester);
    await tapLabel(tester, 'Change name');
    await tester.enterText(find.byType(TextField), 'Lin');
    await tapLabel(tester, 'Save');

    await tester.pageBack();
    await settle(tester);
    expect(find.text('Hi, Lin'), findsOneWidget);
    await harness.dispose(tester);
  });

  group('app lock', () {
    testWidgets('is hidden on devices without a screen lock', (tester) async {
      final harness = await open(tester);
      expect(find.text('App lock'), findsNothing);
      await harness.dispose(tester);
    });

    testWidgets('needs the device to confirm before switching on or off', (tester) async {
      final harness = await open(tester, lockAvailable: false);
      await tapLabel(tester, 'App lock');
      expect(settings(harness).appLockEnabled, isFalse);

      harness.auth!.succeeds = true;
      await tapLabel(tester, 'App lock');
      expect(settings(harness).appLockEnabled, isTrue);

      harness.auth!.succeeds = false;
      await tapLabel(tester, 'App lock');
      expect(settings(harness).appLockEnabled, isTrue, reason: 'someone else cannot turn it off');
      await harness.dispose(tester);
    });
  });

  group('delete my data', () {
    testWidgets('asks first, and cancelling keeps everything', (tester) async {
      final harness = await open(tester);
      await tapLabel(tester, 'Delete my data');
      expect(find.text('Delete everything?'), findsOneWidget);
      await tapLabel(tester, 'Cancel');

      final left = await tester.runAsync(
        () => harness.container.read(profileRepositoryProvider).all(),
      );
      expect(left, hasLength(1));
      await harness.dispose(tester);
    });

    testWidgets('deleting the only profile wipes it and returns to the welcome', (tester) async {
      final harness = await open(tester);
      await tapLabel(tester, 'Delete my data');
      await tapLabel(tester, 'Delete');
      await settle(tester);

      final left = await tester.runAsync(
        () => harness.container.read(profileRepositoryProvider).all(),
      );
      expect(left, isEmpty);
      expect(settings(harness).hasConsented, isFalse);
      expect(find.byType(OnboardingScreen), findsOneWidget);
      await harness.dispose(tester);
    });

    testWidgets('with another profile left, the app switches to it', (tester) async {
      final harness = await open(tester, profiles: 2);
      await tapLabel(tester, 'Delete my data');
      await tapLabel(tester, 'Delete');
      await settle(tester);

      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.text('Hi, Other 1'), findsOneWidget);
      await harness.dispose(tester);
    });
  });

  testWidgets('profiles can be added and switched between', (tester) async {
    final harness = await open(tester, profiles: 2);
    await tapLabel(tester, 'Switch to Other 1');
    expect(settings(harness).activeProfileId, 2);

    await tapLabel(tester, 'Add another profile');
    await tester.enterText(find.byType(TextField), 'Kai');
    await tapLabel(tester, 'Save');
    await settle(tester);
    expect(settings(harness).activeProfileId, 3);
    await harness.dispose(tester);
  });

  testWidgets('the tour can be replayed and walked through', (tester) async {
    final harness = await open(tester);
    await tapLabel(tester, 'Replay the tour');
    expect(find.byType(TutorialScreen), findsOneWidget);

    final steps = harness.content.tutorial;
    for (final step in steps) {
      expect(find.text(step.title), findsOneWidget);
      await tapLabel(tester, step == steps.last ? 'Got it!' : 'Next');
    }
    expect(find.byType(TutorialScreen), findsNothing);
    await harness.dispose(tester);
  });
}
