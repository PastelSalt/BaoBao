import 'package:baobao/core/settings/app_settings.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<ProviderContainer> containerWith(Map<String, Object> stored) async {
  SharedPreferences.setMockInitialValues(stored);
  final prefs = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  test('starts with defaults and is not onboarded', () async {
    final settings = (await containerWith({})).read(settingsProvider);
    expect((settings.musicVolume, settings.sfxVolume, settings.voiceVolume), (0.7, 0.8, 0.8));
    expect(settings.voiceEnabled, isTrue);
    expect(settings.reducedMotion, isFalse);
    expect(settings.isOnboarded, isFalse);
  });

  test('onboarding needs both consent and an active profile', () async {
    final container = await containerWith({});
    final controller = container.read(settingsProvider.notifier);

    await controller.acceptConsent();
    expect(container.read(settingsProvider).isOnboarded, isFalse);

    await controller.setActiveProfile(7);
    expect(container.read(settingsProvider).isOnboarded, isTrue);

    await controller.setActiveProfile(null);
    expect(container.read(settingsProvider).isOnboarded, isFalse);
  });

  test('consent given for an older version must be given again', () async {
    final container = await containerWith({
      'onboarding.consentVersion': AppSettings.currentConsentVersion - 1,
      'profiles.activeId': 1,
    });
    expect(container.read(settingsProvider).isOnboarded, isFalse);
  });

  test('changes are saved and read back by a fresh controller', () async {
    final first = await containerWith({});
    final controller = first.read(settingsProvider.notifier);
    await controller.setMusicVolume(0.25);
    await controller.setVoiceEnabled(false);
    await controller.setReducedMotion(true);
    await controller.setAppLockEnabled(true);
    await controller.setTutorialSeen(true);

    final prefs = await SharedPreferences.getInstance();
    final second = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    addTearDown(second.dispose);
    final settings = second.read(settingsProvider);
    expect(settings.musicVolume, 0.25);
    expect(settings.voiceEnabled, isFalse);
    expect(settings.reducedMotion, isTrue);
    expect(settings.appLockEnabled, isTrue);
    expect(settings.tutorialSeen, isTrue);
  });

  test('volumes are kept between 0 and 1', () async {
    final container = await containerWith({'audio.sfxVolume': 9.0});
    expect(container.read(settingsProvider).sfxVolume, 1.0);

    await container.read(settingsProvider.notifier).setVoiceVolume(-3);
    expect(container.read(settingsProvider).voiceVolume, 0.0);
  });
}
