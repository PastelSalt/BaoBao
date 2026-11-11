import 'dart:io';

import 'package:baobao/app/app.dart';
import 'package:baobao/app/theme/app_theme.dart';
import 'package:baobao/core/audio/audio_director.dart';
import 'package:baobao/core/content/app_content.dart';
import 'package:baobao/core/database/app_database.dart';
import 'package:baobao/core/links/link_opener.dart';
import 'package:baobao/core/providers.dart';
import 'package:baobao/core/security/app_lock.dart';
import 'package:baobao/core/settings/app_settings.dart';
import 'package:baobao/l10n/app_localizations.dart';
import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/audio/audio_director_test.dart' show FakeChannel;
import '../core/security/app_lock_test.dart' show FakeAuthenticator;
import 'test_database.dart';

/// Everything a widget test needs in place of the real device: an in-memory
/// database, the shipped content, recorded audio, a fixed clock.
class Harness {
  Harness._(
    this.container,
    this.database,
    this.content,
    this.music,
    this.voice,
    this.sfx,
    this.auth,
  );

  final ProviderContainer container;
  final AppDatabase database;
  final AppContent content;
  final FakeChannel music;
  final FakeChannel voice;
  final FakeChannel sfx;
  final FakeAuthenticator? auth;

  /// 10:00 on a fixed day, so greetings are predictable.
  static final defaultNow = DateTime(2026, 11, 11, 10);

  static AppContent? _content;

  /// Call from `setUpAll`: reads content from disk once, using real I/O.
  static Future<void> loadContent() async {
    _content ??= await AppContent.load((path) => File(path).readAsString());
  }

  /// [lockAvailable] null means the device has no screen lock at all.
  static Future<Harness> create({
    Map<String, Object> prefs = const {},
    DateTime? now,
    bool? lockAvailable,
    bool reducedMotion = true,
    LinkOpener? links,
  }) async {
    SharedPreferences.setMockInitialValues({
      'a11y.reducedMotion': reducedMotion,
      'onboarding.tutorialSeen': true,
      ...prefs,
    });
    final preferences = await SharedPreferences.getInstance();
    final database = memoryDatabase();
    final music = FakeChannel(), voice = FakeChannel(), sfx = FakeChannel();
    final auth = lockAvailable == null ? null : FakeAuthenticator(succeeds: lockAvailable);

    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(preferences),
        contentProvider.overrideWithValue(_content!),
        databaseProvider.overrideWithValue(database),
        clockProvider.overrideWithValue(Clock.fixed(now ?? defaultNow)),
        audioDirectorProvider.overrideWithValue(
          AudioDirector(music: music, voice: voice, sfx: sfx),
        ),
        if (auth != null) deviceAuthenticatorProvider.overrideWithValue(auth),
        if (links != null) linkOpenerProvider.overrideWithValue(links),
      ],
    );
    return Harness._(container, database, _content!, music, voice, sfx, auth);
  }

  /// Wraps [child] with providers, theme and localisation.
  Widget wrap(Widget child) => UncontrolledProviderScope(
    container: container,
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: Center(child: child)),
    ),
  );

  /// Tears the widget tree down. Call at the end of every test that pumped
  /// widgets backed by this harness.
  ///
  /// The in-memory database is deliberately not closed: closing it from
  /// inside the test's fake clock while queries are still being cancelled
  /// never completes. It is freed with the test.
  Future<void> dispose(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 10));
    container.dispose();
    await tester.pump(const Duration(seconds: 1));
  }
}

/// Lets real asynchronous work (the database) finish, then rebuilds.
Future<void> settle(WidgetTester tester, {int rounds = 6}) async {
  for (var i = 0; i < rounds; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 15)));
    await tester.pump(const Duration(milliseconds: 120));
  }
}

/// Registers Quicksand so golden images show the real typeface.
Future<void> loadAppFonts() async {
  final loader = FontLoader(AppTheme.fontFamily);
  for (final weight in ['Light', 'Regular', 'Medium', 'SemiBold', 'Bold']) {
    final bytes = File('assets/fonts/Quicksand-$weight.ttf').readAsBytesSync();
    loader.addFont(Future.value(ByteData.sublistView(bytes)));
  }
  await loader.load();

  // Icons, from the Flutter SDK running the tests, so golden images show
  // them instead of empty boxes.
  final root = Platform.environment['FLUTTER_ROOT'];
  final icons = File('$root/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf');
  if (root != null && icons.existsSync()) {
    final iconLoader = FontLoader('MaterialIcons')
      ..addFont(Future.value(ByteData.sublistView(icons.readAsBytesSync())));
    await iconLoader.load();
  }
}

/// Creates a profile, marks onboarding done, and returns the profile id.
/// Uses real I/O, so call it through `tester.runAsync` inside widget tests.
Future<int> onboard(Harness harness, {String name = 'Mei'}) async {
  final profile = await harness.container
      .read(profileRepositoryProvider)
      .create(name, harness.container.read(clockProvider).now());
  final settings = harness.container.read(settingsProvider.notifier);
  await settings.acceptConsent();
  await settings.setActiveProfile(profile.id);
  return profile.id;
}

/// Pumps the whole app on a phone-sized screen.
Future<void> pumpApp(
  WidgetTester tester,
  Harness harness, {
  Size size = const Size(420, 900),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    UncontrolledProviderScope(container: harness.container, child: const BaoBaoApp()),
  );
  await settle(tester);
}

/// Taps the widget showing [label] and lets the result settle.
Future<void> tapLabel(WidgetTester tester, String label, {int rounds = 3}) async {
  final finder = find.text(label);
  await tester.ensureVisible(finder.first);
  await tester.pump();
  await tester.tap(finder.first);
  await settle(tester, rounds: rounds);
}
