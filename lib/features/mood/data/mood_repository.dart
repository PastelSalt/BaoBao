import 'package:baobao/core/database/app_database.dart';
import 'package:baobao/features/intervention/domain/intervention_policy.dart';
import 'package:baobao/features/mood/domain/emotional_state.dart';
import 'package:baobao/features/mood/domain/mood.dart';
import 'package:baobao/features/mood/domain/mood_tracker.dart';
import 'package:drift/drift.dart';

/// What a check-in led to.
class CheckInOutcome {
  const CheckInOutcome({required this.state, required this.intervene});

  final EmotionalState state;

  /// Whether the intervention conversation should replace the mood's own.
  final bool intervene;
}

class MoodRepository {
  const MoodRepository(this._db);

  final AppDatabase _db;

  Future<EmotionalState> state(int profileId) async {
    final row = await (_db.select(
      _db.emotionalStates,
    )..where((s) => s.profileId.equals(profileId))).getSingle();
    return _toState(row);
  }

  Stream<EmotionalState> watchState(int profileId) => (_db.select(
    _db.emotionalStates,
  )..where((s) => s.profileId.equals(profileId))).watchSingle().map(_toState);

  /// The most recent moods, oldest first.
  Future<List<Mood>> recentMoods(
    int profileId, {
    int limit = InterventionPolicy.patternWindow,
  }) async {
    final rows =
        await (_db.select(_db.moodEntries)
              ..where((e) => e.profileId.equals(profileId))
              ..orderBy([(e) => OrderingTerm.desc(e.id)])
              ..limit(limit))
            .get();
    return [for (final row in rows.reversed) ?Mood.tryParse(row.mood)];
  }

  Stream<Mood?> watchLatestMood(int profileId) {
    final query = _db.select(_db.moodEntries)
      ..where((e) => e.profileId.equals(profileId))
      ..orderBy([(e) => OrderingTerm.desc(e.id)])
      ..limit(1);
    return query.watchSingleOrNull().map((row) => row == null ? null : Mood.tryParse(row.mood));
  }

  /// Records a check-in and decides, in the same transaction, whether to
  /// intervene. If so, the intervention time is stamped so the cooldown starts.
  Future<CheckInOutcome> recordCheckIn(int profileId, Mood mood, DateTime now) {
    return _db.transaction(() async {
      await _db
          .into(_db.moodEntries)
          .insert(
            MoodEntriesCompanion.insert(
              profileId: profileId,
              mood: mood.name,
              weightDelta: mood.weightDelta,
              createdAt: now,
            ),
          );
      var next = MoodTracker.checkIn(await state(profileId), mood);
      final intervene = InterventionPolicy.shouldIntervene(
        state: next,
        recentMoods: await recentMoods(profileId),
        now: now,
      );
      if (intervene) next = next.copyWith(lastInterventionAt: now);
      await _write(profileId, next);
      return CheckInOutcome(state: next, intervene: intervene);
    });
  }

  /// Applies the mood effect of a conversation choice.
  Future<void> applyEffect(int profileId, int effect) {
    if (effect == 0) return Future.value();
    return _db.transaction(() async {
      await _write(profileId, MoodTracker.applyEffect(await state(profileId), effect));
    });
  }

  Future<void> _write(int profileId, EmotionalState state) {
    return (_db.update(_db.emotionalStates)..where((s) => s.profileId.equals(profileId))).write(
      EmotionalStatesCompanion(
        weight: Value(state.weight),
        consecutiveNegative: Value(state.consecutiveNegative),
        lastInterventionAt: Value(state.lastInterventionAt),
      ),
    );
  }

  static EmotionalState _toState(EmotionalStateRow row) => EmotionalState(
    weight: row.weight,
    consecutiveNegative: row.consecutiveNegative,
    lastInterventionAt: row.lastInterventionAt,
  );
}
