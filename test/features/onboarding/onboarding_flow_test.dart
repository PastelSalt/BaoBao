import 'package:baobao/core/providers.dart';
import 'package:baobao/core/security/app_lock.dart';
import 'package:baobao/core/settings/app_settings.dart';
import 'package:baobao/features/app_lock/presentation/unlock_screen.dart';
import 'package:baobao/features/home/presentation/home_screen.dart';
import 'package:baobao/features/onboarding/presentation/onboarding_screen.dart';
import 'package:baobao/features/tutorial/presentation/tutorial_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/app_harness.dart';

void main() {
  setUpAll(Harness.loadContent);

  testWidgets('a new person is taken through onboarding to home', (tester) async {
    final harness = await Harness.create(prefs: {'onboarding.tutorialSeen': false});
    await pumpApp(tester, harness);

    // Welcome: BaoBao speaks one of the welcome lines aloud.
    expect(find.byType(OnboardingScreen), findsOneWidget);
    expect(find.text("Hi, I'm BaoBao!"), findsOneWidget);
    expect(harness.voice.log.single, matches(RegExp(r'^play assets/audio/voice/en/a_0\d\.m4a$')));
    await tapLabel(tester, "Let's begin");

    // Promise: cannot continue until both boxes are ticked.
    expect(find.text('Before we start'), findsOneWidget);
    await tapLabel(tester, 'Continue');
    expect(find.text('Before we start'), findsOneWidget);
    await tapLabel(tester, 'I understand BaoBao is not a substitute for professional care.');
    await tapLabel(tester, 'Continue');
    expect(find.text('Before we start'), findsOneWidget);
    await tapLabel(tester, 'I am 13 or older.');
    await tapLabel(tester, 'Continue');

    // Name: the last step on a device without a screen lock.
    expect(find.text('Step 3 of 3'), findsOneWidget);
    await tester.enterText(find.byType(TextField), '  Mei ');
    await tapLabel(tester, "Let's begin");
    await settle(tester);

    // The tour runs once, before BaoBao's first greeting.
    expect(find.byType(TutorialScreen), findsOneWidget);
    expect(find.text('Welcome to BaoBao!'), findsOneWidget);
    await tapLabel(tester, 'Skip tour');

    expect(find.byType(TutorialScreen), findsNothing);
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('Hi, Mei'), findsOneWidget);
    expect(find.text('3000'), findsOneWidget);
    expect(harness.voice.log.last, 'play assets/audio/voice/en/g_greetings_01.m4a');

    final settings = harness.container.read(settingsProvider);
    expect(settings.isOnboarded, isTrue);
    expect(settings.appLockEnabled, isFalse);
    await harness.dispose(tester);
  });

  testWidgets('nothing is saved if onboarding is abandoned part-way', (tester) async {
    final harness = await Harness.create(prefs: {'onboarding.tutorialSeen': false});
    await pumpApp(tester, harness);
    await tapLabel(tester, "Let's begin");
    await tapLabel(tester, 'I am 13 or older.');

    final profiles = await tester.runAsync(
      () => harness.container.read(profileRepositoryProvider).all(),
    );
    expect(profiles, isEmpty);
    expect(harness.container.read(settingsProvider).hasConsented, isFalse);
    await harness.dispose(tester);
  });

  testWidgets('back returns to the previous step and keeps the answers', (tester) async {
    final harness = await Harness.create(prefs: {'onboarding.tutorialSeen': false});
    await pumpApp(tester, harness);
    await tapLabel(tester, "Let's begin");
    await tapLabel(tester, 'I am 13 or older.');
    await tapLabel(tester, 'Back');
    expect(find.text("Hi, I'm BaoBao!"), findsOneWidget);

    await tapLabel(tester, "Let's begin");
    final box = tester.widget<CheckboxListTile>(
      find.widgetWithText(CheckboxListTile, 'I am 13 or older.'),
    );
    expect(box.value, isTrue);
    await harness.dispose(tester);
  });

  testWidgets('a blank name becomes "Friend"', (tester) async {
    final harness = await Harness.create(prefs: {'onboarding.tutorialSeen': false});
    await pumpApp(tester, harness);
    await tapLabel(tester, "Let's begin");
    await tapLabel(tester, 'I understand BaoBao is not a substitute for professional care.');
    await tapLabel(tester, 'I am 13 or older.');
    await tapLabel(tester, 'Continue');
    await tapLabel(tester, "Let's begin");
    await settle(tester);
    await tapLabel(tester, 'Skip tour');

    expect(find.text('Hi, Friend'), findsOneWidget);
    await harness.dispose(tester);
  });

  group('app lock', () {
    Future<void> reachLockStep(WidgetTester tester, Harness harness) async {
      await pumpApp(tester, harness);
      await tapLabel(tester, "Let's begin");
      await tapLabel(tester, 'I understand BaoBao is not a substitute for professional care.');
      await tapLabel(tester, 'I am 13 or older.');
      await tapLabel(tester, 'Continue');
      await tapLabel(tester, 'Continue');
      expect(find.text('Keep our chats private?'), findsOneWidget);
    }

    testWidgets('is offered when the device has a screen lock, and can be switched on', (
      tester,
    ) async {
      final harness = await Harness.create(
        lockAvailable: true,
        prefs: {'onboarding.tutorialSeen': false},
      );
      await reachLockStep(tester, harness);
      await tapLabel(tester, 'Yes, lock the app');
      await settle(tester);

      expect(find.byType(TutorialScreen), findsOneWidget);
      expect(harness.container.read(settingsProvider).appLockEnabled, isTrue);
      await harness.dispose(tester);
    });

    testWidgets('stays off if the device check fails, and can be skipped', (tester) async {
      final harness = await Harness.create(
        lockAvailable: false,
        prefs: {'onboarding.tutorialSeen': false},
      );
      await reachLockStep(tester, harness);
      await tapLabel(tester, 'Yes, lock the app');
      expect(find.textContaining("That didn't work"), findsOneWidget);
      expect(find.byType(OnboardingScreen), findsOneWidget);

      await tapLabel(tester, 'Not now');
      await settle(tester);
      expect(find.byType(TutorialScreen), findsOneWidget);
      expect(harness.container.read(settingsProvider).appLockEnabled, isFalse);
      await harness.dispose(tester);
    });
  });

  group('returning', () {
    Future<Harness> onboarded({bool locked = false}) async {
      final harness = await Harness.create(
        lockAvailable: true,
        prefs: {'security.appLock': locked},
      );
      await onboard(harness);
      if (locked) harness.container.read(appLockProvider.notifier).lock();
      return harness;
    }

    testWidgets('home greets by time of day, with voice and the selected music', (tester) async {
      final harness = (await tester.runAsync(onboarded))!;
      await pumpApp(tester, harness);

      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.bySemanticsLabel(RegExp('^Good morning')), findsOneWidget);
      expect(harness.voice.log, ['play assets/audio/voice/en/g_greetings_01.m4a']);
      expect(harness.music.log, ['play assets/audio/music/bamboo_morning.m4a loop']);
      await harness.dispose(tester);
    });

    testWidgets('a locked app shows only the unlock screen until the device confirms', (
      tester,
    ) async {
      final harness = (await tester.runAsync(() => onboarded(locked: true)))!;
      harness.auth!.succeeds = false;
      await pumpApp(tester, harness);

      expect(find.byType(UnlockScreen), findsOneWidget);
      expect(find.byType(HomeScreen), findsNothing);
      expect(find.textContaining("That didn't work"), findsOneWidget);
      expect(harness.voice.log, isEmpty, reason: 'nothing private plays while locked');

      harness.auth!.succeeds = true;
      await tapLabel(tester, 'Unlock');
      await settle(tester);
      expect(find.byType(HomeScreen), findsOneWidget);
      await harness.dispose(tester);
    });

    testWidgets('going to the background pauses sound', (tester) async {
      final harness = (await tester.runAsync(onboarded))!;
      await pumpApp(tester, harness);

      // The platform always passes through "inactive" on the way in and out.
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      await tester.pump();
      expect(harness.music.log.last, 'pause');

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();
      expect(harness.music.log.last, 'resume');
      await harness.dispose(tester);
    });
  });
}
