import 'dart:math';

import 'package:baobao/core/audio/audio_director.dart';
import 'package:baobao/core/content/app_content.dart';
import 'package:baobao/core/database/app_database.dart';
import 'package:baobao/core/settings/app_settings.dart';
import 'package:baobao/features/claw_machine/data/claw_repository.dart';
import 'package:baobao/features/conversation/data/conversation_repository.dart';
import 'package:baobao/features/economy/data/economy_repository.dart';
import 'package:baobao/features/economy/domain/catalog.dart';
import 'package:baobao/features/mood/data/mood_repository.dart';
import 'package:baobao/features/mood/domain/mood.dart';
import 'package:baobao/features/profiles/data/profile_repository.dart';
import 'package:clock/clock.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// The three below are created during startup and injected as overrides.

final databaseProvider = Provider<AppDatabase>(
  (ref) => throw UnimplementedError('databaseProvider must be overridden'),
);

final contentProvider = Provider<AppContent>(
  (ref) => throw UnimplementedError('contentProvider must be overridden'),
);

/// Silent unless overridden, so widgets work in tests without any setup.
final audioDirectorProvider = Provider<AudioDirector>((ref) {
  final director = AudioDirector.silent();
  ref.onDispose(director.dispose);
  return director;
});

/// The source of chance, for picking lines. Tests override this with a seed.
final randomProvider = Provider<Random>((ref) => Random());

/// The source of "now". Tests override this to control time.
final clockProvider = Provider<Clock>((ref) => const Clock());

final catalogProvider = Provider<Catalog>((ref) => ref.watch(contentProvider).catalog);

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => ProfileRepository(ref.watch(databaseProvider), ref.watch(catalogProvider)),
);

final moodRepositoryProvider = Provider<MoodRepository>(
  (ref) => MoodRepository(ref.watch(databaseProvider)),
);

final economyRepositoryProvider = Provider<EconomyRepository>(
  (ref) => EconomyRepository(ref.watch(databaseProvider), ref.watch(catalogProvider)),
);

final clawRepositoryProvider = Provider<ClawRepository>(
  (ref) => ClawRepository(ref.watch(databaseProvider)),
);

final conversationRepositoryProvider = Provider<ConversationRepository>(
  (ref) => ConversationRepository(ref.watch(databaseProvider)),
);

/// The id of the profile in use, or null before onboarding.
final activeProfileIdProvider = Provider<int?>(
  (ref) => ref.watch(settingsProvider.select((settings) => settings.activeProfileId)),
);

final activeProfileProvider = StreamProvider<Profile?>((ref) {
  final id = ref.watch(activeProfileIdProvider);
  if (id == null) return Stream.value(null);
  return ref.watch(profileRepositoryProvider).watch(id);
});

final balanceProvider = StreamProvider<int>((ref) {
  final id = ref.watch(activeProfileIdProvider);
  if (id == null) return const Stream.empty();
  return ref.watch(economyRepositoryProvider).watchBalance(id);
});

/// The equipped item in each slot for the active profile.
final selectionsProvider = StreamProvider<Map<ItemSlot, CatalogItem>>((ref) {
  final id = ref.watch(activeProfileIdProvider);
  final catalog = ref.watch(catalogProvider);
  if (id == null) {
    return Stream.value({for (final slot in ItemSlot.values) slot: catalog.defaultFor(slot)});
  }
  return ref.watch(economyRepositoryProvider).watchSelections(id);
});

/// The latest mood the active profile checked in with, if any.
final latestMoodProvider = StreamProvider<Mood?>((ref) {
  final id = ref.watch(activeProfileIdProvider);
  if (id == null) return const Stream.empty();
  return ref.watch(moodRepositoryProvider).watchLatestMood(id);
});

final ownedItemsProvider = StreamProvider<Set<String>>((ref) {
  final id = ref.watch(activeProfileIdProvider);
  if (id == null) return const Stream.empty();
  return ref.watch(economyRepositoryProvider).watchOwned(id);
});

/// Whether animation should be kept to a minimum, from the in-app setting.
/// Widgets also honour the system setting through `MediaQuery.disableAnimations`.
final reducedMotionProvider = Provider<bool>(
  (ref) => ref.watch(settingsProvider.select((settings) => settings.reducedMotion)),
);
