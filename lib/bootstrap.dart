import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:audio_session/audio_session.dart';
import 'package:baobao/app/app.dart';
import 'package:baobao/app/theme/app_theme.dart';
import 'package:baobao/core/audio/audio_channel.dart';
import 'package:baobao/core/audio/audio_director.dart';
import 'package:baobao/core/content/app_content.dart';
import 'package:baobao/core/database/database_opener.dart';
import 'package:baobao/core/providers.dart';
import 'package:baobao/core/security/app_lock.dart';
import 'package:baobao/core/security/secure_key_store.dart';
import 'package:baobao/core/settings/app_settings.dart';
import 'package:baobao/features/profiles/data/profile_repository.dart';
import 'package:baobao/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppFlavor { dev, prod }

/// Loads everything the app needs before the first frame, then runs it.
Future<void> bootstrap(AppFlavor flavor) async {
  WidgetsFlutterBinding.ensureInitialized();

  // Crash reporting arrives in Phase 6. Until then, errors go to the console
  // and never include anything the person told BaoBao.
  FlutterError.onError = FlutterError.presentError;
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('Uncaught error: $error\n$stack');
    return true;
  };

  try {
    final container = await _createContainer();
    runApp(UncontrolledProviderScope(container: container, child: const BaoBaoApp()));
  } catch (error, stack) {
    debugPrint('Startup failed: $error\n$stack');
    runApp(StartupErrorApp(onRetry: () => bootstrap(flavor)));
  }
}

Future<ProviderContainer> _createContainer() async {
  final prefs = await SharedPreferences.getInstance();
  final content = await AppContent.load(
    rootBundle.loadString,
    languageCode: PlatformDispatcher.instance.locale.languageCode,
  );

  // Application Support is private to the app and not shown to the user.
  final directory = await getApplicationSupportDirectory();
  final key = await DatabaseOpener.loadOrCreateKey(const SecureKeyStore());
  final database = await DatabaseOpener.open(File(p.join(directory.path, 'baobao.sqlite')), key);

  final session = await AudioSession.instance;
  await session.configure(const AudioSessionConfiguration.music());

  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      contentProvider.overrideWithValue(content),
      databaseProvider.overrideWithValue(database),
      deviceAuthenticatorProvider.overrideWithValue(LocalAuthAuthenticator()),
      audioDirectorProvider.overrideWith((ref) {
        final director = AudioDirector(
          music: JustAudioChannel(primary: true),
          voice: JustAudioChannel(),
          sfx: JustAudioChannel(),
          levels: levelsFrom(ref.read(settingsProvider)),
          onError: (error, stack) => debugPrint('Audio error: $error'),
        );
        ref.onDispose(director.dispose);
        unawaited(director.init());
        return director;
      }),
    ],
  );

  await _reconcileActiveProfile(container);
  if (container.read(settingsProvider).appLockEnabled) {
    container.read(appLockProvider.notifier).lock();
  }
  return container;
}

/// Makes sure the remembered profile still exists. It will not if the database
/// had to be recreated, in which case onboarding runs again.
Future<void> _reconcileActiveProfile(ProviderContainer container) async {
  final settings = container.read(settingsProvider);
  final ProfileRepository profiles = container.read(profileRepositoryProvider);
  final id = settings.activeProfileId;
  if (id != null && await profiles.byId(id) != null) return;

  final existing = await profiles.all();
  await container
      .read(settingsProvider.notifier)
      .setActiveProfile(existing.isEmpty ? null : existing.first.id);
}

/// Shown if startup fails, so the person is never left on a blank screen.
class StartupErrorApp extends StatelessWidget {
  const StartupErrorApp({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(
        builder: (context) {
          final l10n = AppLocalizations.of(context);
          return Scaffold(
            body: SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l10n.startupErrorTitle,
                        style: Theme.of(context).textTheme.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(l10n.startupErrorBody, textAlign: TextAlign.center),
                      const SizedBox(height: 24),
                      FilledButton(onPressed: onRetry, child: Text(l10n.actionRetry)),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
