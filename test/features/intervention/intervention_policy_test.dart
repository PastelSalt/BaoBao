import 'package:baobao/features/intervention/domain/intervention_policy.dart';
import 'package:baobao/features/mood/domain/emotional_state.dart';
import 'package:baobao/features/mood/domain/mood.dart';
import 'package:baobao/features/mood/domain/mood_tracker.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 11, 11, 12);

  /// Runs a series of check-ins and asks the policy after the last one.
  bool decide(List<Mood> moods, {DateTime? lastInterventionAt}) {
    final state = moods.fold(
      EmotionalState(lastInterventionAt: lastInterventionAt),
      MoodTracker.checkIn,
    );
    return InterventionPolicy.shouldIntervene(state: state, recentMoods: moods, now: now);
  }

  test('one anxious check-in is not enough', () {
    expect(decide([Mood.anxious]), isFalse);
  });

  test('two anxious check-ins in a row trigger', () {
    expect(decide([Mood.anxious, Mood.anxious]), isTrue);
  });

  test('sad and tired trigger once the weight reaches the threshold', () {
    expect(decide([Mood.sad, Mood.tired, Mood.sad]), isFalse);
    expect(decide([Mood.sad, Mood.tired, Mood.sad, Mood.sad]), isTrue);
  });

  test('a high weight alone does not trigger without a recent negative pattern', () {
    const state = EmotionalState(weight: 8);
    expect(
      InterventionPolicy.shouldIntervene(
        state: state,
        recentMoods: [Mood.sad, Mood.happy, Mood.okay],
        now: now,
      ),
      isFalse,
    );
  });

  test('two negatives in the last three check-ins count as a pattern', () {
    // The streak is broken by "okay", but the pattern still holds.
    const state = EmotionalState(weight: 5, consecutiveNegative: 1);
    expect(
      InterventionPolicy.shouldIntervene(
        state: state,
        recentMoods: [Mood.anxious, Mood.okay, Mood.sad],
        now: now,
      ),
      isTrue,
    );
  });

  test('only the newest three check-ins are examined', () {
    expect(
      InterventionPolicy.hasNegativePattern([
        Mood.sad,
        Mood.sad,
        Mood.happy,
        Mood.okay,
        Mood.happy,
      ]),
      isFalse,
    );
  });

  test('does not repeat within 24 hours', () {
    final recently = now.subtract(const Duration(hours: 23, minutes: 59));
    expect(
      decide([Mood.anxious, Mood.anxious, Mood.anxious], lastInterventionAt: recently),
      isFalse,
    );
  });

  test('can repeat once 24 hours have passed', () {
    final yesterday = now.subtract(const Duration(hours: 24));
    expect(decide([Mood.anxious, Mood.anxious], lastInterventionAt: yesterday), isTrue);
  });

  test('a happy check-in after a low stretch does not trigger', () {
    expect(decide([Mood.anxious, Mood.anxious, Mood.happy]), isFalse);
  });
}
