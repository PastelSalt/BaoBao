import 'dart:async';

import 'package:baobao/app/router.dart';
import 'package:baobao/app/theme/app_theme.dart';
import 'package:baobao/core/audio/audio_director.dart';
import 'package:baobao/core/providers.dart';
import 'package:baobao/core/security/app_lock.dart';
import 'package:baobao/core/settings/app_settings.dart';
import 'package:baobao/features/economy/domain/catalog.dart';
import 'package:baobao/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class BaoBaoApp extends ConsumerStatefulWidget {
  const BaoBaoApp({super.key});

  @override
  ConsumerState<BaoBaoApp> createState() => _BaoBaoAppState();
}

class _BaoBaoAppState extends ConsumerState<BaoBaoApp> {
  late final AppLifecycleListener _lifecycle;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(onHide: _onBackgrounded, onShow: _onForegrounded);
    _router = ref.read(routerProvider);
    _router.routerDelegate.addListener(_syncMusic);
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncMusic());
  }

  /// Plays the track that belongs to the screen on top.
  void _syncMusic() {
    if (!mounted) return;
    final matches = _router.routerDelegate.currentConfiguration;
    if (matches.isEmpty) return;
    final selected =
        ref.read(selectionsProvider).value?[ItemSlot.music] ??
        ref.read(catalogProvider).defaultFor(ItemSlot.music);
    final asset = musicFor(matches.last.matchedLocation, selectedMusic: selected.asset);
    final audio = ref.read(audioDirectorProvider);
    unawaited(asset == null ? audio.stopMusic() : audio.playMusic(asset));
  }

  void _onBackgrounded() {
    unawaited(ref.read(audioDirectorProvider).suspend());
    ref.read(appLockProvider.notifier).onBackgrounded(ref.read(clockProvider).now());
  }

  void _onForegrounded() {
    ref
        .read(appLockProvider.notifier)
        .onForegrounded(
          ref.read(clockProvider).now(),
          enabled: ref.read(settingsProvider).appLockEnabled,
        );
    unawaited(ref.read(audioDirectorProvider).resume());
  }

  @override
  void dispose() {
    _router.routerDelegate.removeListener(_syncMusic);
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Keep playback volumes in step with settings.
    ref.listen(settingsProvider, (_, settings) {
      unawaited(ref.read(audioDirectorProvider).updateLevels(levelsFrom(settings)));
    });

    // A newly chosen track starts straight away.
    ref.listen(selectionsProvider, (_, _) => _syncMusic());

    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: _router,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}

AudioLevels levelsFrom(AppSettings settings) => AudioLevels(
  music: settings.musicVolume,
  sfx: settings.sfxVolume,
  voice: settings.voiceVolume,
  voiceEnabled: settings.voiceEnabled,
);
