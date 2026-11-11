import 'package:baobao/core/security/app_lock.dart';
import 'package:baobao/core/settings/app_settings.dart';
import 'package:baobao/features/app_lock/presentation/unlock_screen.dart';
import 'package:baobao/features/claw_machine/presentation/claw_machine_screen.dart';
import 'package:baobao/features/home/presentation/home_screen.dart';
import 'package:baobao/features/intervention/presentation/resources_screen.dart';
import 'package:baobao/features/onboarding/presentation/onboarding_screen.dart';
import 'package:baobao/features/settings/presentation/settings_screen.dart';
import 'package:baobao/features/shop/presentation/shop_screen.dart';
import 'package:baobao/features/tutorial/presentation/tutorial_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

abstract final class Routes {
  static const home = '/';
  static const onboarding = '/onboarding';
  static const unlock = '/unlock';
  static const shop = '/shop';
  static const claw = '/claw';
  static const settings = '/settings';
  static const resources = '/resources';
  static const tutorial = '/tutorial';
}

/// Where someone should be sent instead of [location], or null to stay.
///
/// Order matters: onboarding comes first (there is nothing to protect before
/// it), then the lock, and only then the app itself.
String? guard({required bool onboarded, required bool locked, required String location}) {
  if (!onboarded) return location == Routes.onboarding ? null : Routes.onboarding;
  if (locked) return location == Routes.unlock ? null : Routes.unlock;
  if (location == Routes.onboarding || location == Routes.unlock) return Routes.home;
  return null;
}

final routerProvider = Provider<GoRouter>((ref) {
  // Re-run the guard whenever onboarding or lock state changes.
  final refresh = ValueNotifier(0);
  ref.onDispose(refresh.dispose);
  ref.listen(settingsProvider.select((s) => s.isOnboarded), (_, _) => refresh.value++);
  ref.listen(appLockProvider, (_, _) => refresh.value++);

  final router = GoRouter(
    initialLocation: Routes.home,
    refreshListenable: refresh,
    redirect: (context, state) => guard(
      onboarded: ref.read(settingsProvider).isOnboarded,
      locked: ref.read(appLockProvider),
      location: state.matchedLocation,
    ),
    routes: [
      GoRoute(path: Routes.home, builder: (context, state) => const HomeScreen()),
      GoRoute(path: Routes.onboarding, builder: (context, state) => const OnboardingScreen()),
      GoRoute(path: Routes.unlock, builder: (context, state) => const UnlockScreen()),
      GoRoute(path: Routes.shop, builder: (context, state) => const ShopScreen()),
      GoRoute(path: Routes.claw, builder: (context, state) => const ClawMachineScreen()),
      GoRoute(path: Routes.settings, builder: (context, state) => const SettingsScreen()),
      GoRoute(path: Routes.resources, builder: (context, state) => const ResourcesScreen()),
      GoRoute(path: Routes.tutorial, builder: (context, state) => const TutorialScreen()),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});

/// The music for the screen at [location], given the track the person chose.
///
/// Returns null to stay silent: before the app is unlocked nothing personal
/// should be heard.
String? musicFor(String location, {required String selectedMusic}) => switch (location) {
  Routes.unlock => null,
  Routes.shop => shopMusicAsset,
  Routes.claw => clawMusicAsset,
  _ => selectedMusic,
};
