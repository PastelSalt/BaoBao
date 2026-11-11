import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Device-wide preferences. Nothing sensitive is kept here: mood data lives in
/// the encrypted database.
class AppSettings {
  const AppSettings({
    this.musicVolume = 0.7,
    this.sfxVolume = 0.8,
    this.voiceVolume = 0.8,
    this.voiceEnabled = true,
    this.reducedMotion = false,
    this.consentVersion = 0,
    this.activeProfileId,
    this.appLockEnabled = false,
    this.tutorialSeen = false,
    this.helpCountry,
    this.clawTapMode = false,
  });

  /// Raise this when the disclaimer or privacy summary changes in a way that
  /// people must agree to again.
  static const currentConsentVersion = 1;

  final double musicVolume;
  final double sfxVolume;
  final double voiceVolume;
  final bool voiceEnabled;
  final bool reducedMotion;

  /// The consent version the person last agreed to. Zero means never.
  final int consentVersion;
  final int? activeProfileId;
  final bool appLockEnabled;
  final bool tutorialSeen;

  /// ISO country code whose helplines to show. Null follows the device region.
  final String? helpCountry;

  /// Claw machine control: tap to start and tap again to drop, instead of
  /// press-and-hold. For anyone who finds holding difficult.
  final bool clawTapMode;

  bool get hasConsented => consentVersion >= currentConsentVersion;

  /// Onboarding is complete once consent is given and a profile is active.
  bool get isOnboarded => hasConsented && activeProfileId != null;

  AppSettings copyWith({
    double? musicVolume,
    double? sfxVolume,
    double? voiceVolume,
    bool? voiceEnabled,
    bool? reducedMotion,
    int? consentVersion,
    int? Function()? activeProfileId,
    bool? appLockEnabled,
    bool? tutorialSeen,
    String? Function()? helpCountry,
    bool? clawTapMode,
  }) {
    return AppSettings(
      musicVolume: musicVolume ?? this.musicVolume,
      sfxVolume: sfxVolume ?? this.sfxVolume,
      voiceVolume: voiceVolume ?? this.voiceVolume,
      voiceEnabled: voiceEnabled ?? this.voiceEnabled,
      reducedMotion: reducedMotion ?? this.reducedMotion,
      consentVersion: consentVersion ?? this.consentVersion,
      activeProfileId: activeProfileId == null ? this.activeProfileId : activeProfileId(),
      appLockEnabled: appLockEnabled ?? this.appLockEnabled,
      tutorialSeen: tutorialSeen ?? this.tutorialSeen,
      helpCountry: helpCountry == null ? this.helpCountry : helpCountry(),
      clawTapMode: clawTapMode ?? this.clawTapMode,
    );
  }
}

/// Overridden at startup with the loaded instance.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('sharedPreferencesProvider must be overridden'),
);

final settingsProvider = NotifierProvider<SettingsController, AppSettings>(SettingsController.new);

class SettingsController extends Notifier<AppSettings> {
  static const _musicVolume = 'audio.musicVolume';
  static const _sfxVolume = 'audio.sfxVolume';
  static const _voiceVolume = 'audio.voiceVolume';
  static const _voiceEnabled = 'audio.voiceEnabled';
  static const _reducedMotion = 'a11y.reducedMotion';
  static const _consentVersion = 'onboarding.consentVersion';
  static const _activeProfileId = 'profiles.activeId';
  static const _appLockEnabled = 'security.appLock';
  static const _tutorialSeen = 'onboarding.tutorialSeen';
  static const _helpCountry = 'help.country';
  static const _clawTapMode = 'a11y.clawTapMode';

  SharedPreferences get _prefs => ref.read(sharedPreferencesProvider);

  @override
  AppSettings build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    const defaults = AppSettings();
    double volume(String key, double fallback) =>
        (prefs.getDouble(key) ?? fallback).clamp(0.0, 1.0).toDouble();
    return AppSettings(
      musicVolume: volume(_musicVolume, defaults.musicVolume),
      sfxVolume: volume(_sfxVolume, defaults.sfxVolume),
      voiceVolume: volume(_voiceVolume, defaults.voiceVolume),
      voiceEnabled: prefs.getBool(_voiceEnabled) ?? defaults.voiceEnabled,
      reducedMotion: prefs.getBool(_reducedMotion) ?? defaults.reducedMotion,
      consentVersion: prefs.getInt(_consentVersion) ?? defaults.consentVersion,
      activeProfileId: prefs.getInt(_activeProfileId),
      appLockEnabled: prefs.getBool(_appLockEnabled) ?? defaults.appLockEnabled,
      tutorialSeen: prefs.getBool(_tutorialSeen) ?? defaults.tutorialSeen,
      helpCountry: prefs.getString(_helpCountry),
      clawTapMode: prefs.getBool(_clawTapMode) ?? defaults.clawTapMode,
    );
  }

  Future<void> setMusicVolume(double value) async {
    state = state.copyWith(musicVolume: value.clamp(0.0, 1.0).toDouble());
    await _prefs.setDouble(_musicVolume, state.musicVolume);
  }

  Future<void> setSfxVolume(double value) async {
    state = state.copyWith(sfxVolume: value.clamp(0.0, 1.0).toDouble());
    await _prefs.setDouble(_sfxVolume, state.sfxVolume);
  }

  Future<void> setVoiceVolume(double value) async {
    state = state.copyWith(voiceVolume: value.clamp(0.0, 1.0).toDouble());
    await _prefs.setDouble(_voiceVolume, state.voiceVolume);
  }

  Future<void> setVoiceEnabled(bool value) async {
    state = state.copyWith(voiceEnabled: value);
    await _prefs.setBool(_voiceEnabled, value);
  }

  Future<void> setReducedMotion(bool value) async {
    state = state.copyWith(reducedMotion: value);
    await _prefs.setBool(_reducedMotion, value);
  }

  Future<void> acceptConsent() async {
    state = state.copyWith(consentVersion: AppSettings.currentConsentVersion);
    await _prefs.setInt(_consentVersion, state.consentVersion);
  }

  Future<void> setActiveProfile(int? id) async {
    state = state.copyWith(activeProfileId: () => id);
    if (id == null) {
      await _prefs.remove(_activeProfileId);
    } else {
      await _prefs.setInt(_activeProfileId, id);
    }
  }

  Future<void> setAppLockEnabled(bool value) async {
    state = state.copyWith(appLockEnabled: value);
    await _prefs.setBool(_appLockEnabled, value);
  }

  Future<void> setTutorialSeen(bool value) async {
    state = state.copyWith(tutorialSeen: value);
    await _prefs.setBool(_tutorialSeen, value);
  }

  /// Pass null to follow the device region again.
  Future<void> setHelpCountry(String? code) async {
    state = state.copyWith(helpCountry: () => code);
    if (code == null) {
      await _prefs.remove(_helpCountry);
    } else {
      await _prefs.setString(_helpCountry, code);
    }
  }

  Future<void> setClawTapMode(bool value) async {
    state = state.copyWith(clawTapMode: value);
    await _prefs.setBool(_clawTapMode, value);
  }

  /// Forgets everything tied to a person: used when the last profile is
  /// deleted. Sound and accessibility preferences are kept.
  Future<void> resetPersonalState() async {
    state = state.copyWith(
      consentVersion: 0,
      activeProfileId: () => null,
      appLockEnabled: false,
      tutorialSeen: false,
      helpCountry: () => null,
    );
    for (final key in [
      _consentVersion,
      _activeProfileId,
      _appLockEnabled,
      _tutorialSeen,
      _helpCountry,
    ]) {
      await _prefs.remove(key);
    }
  }
}
