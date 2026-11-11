import 'package:baobao/features/mood/domain/emotional_state.dart';
import 'package:baobao/features/mood/domain/mood.dart';
import 'package:baobao/features/mood/domain/mood_tracker.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  EmotionalState checkIns(List<Mood> moods, [EmotionalState start = const EmotionalState()]) =>
      moods.fold(start, MoodTracker.checkIn);

  group('Mood', () {
    test('sad, tired and anxious are negative; happy and okay are not', () {
      expect(Mood.values.where((m) => m.isNegative), [Mood.sad, Mood.tired, Mood.anxious]);
    });

    test('parses names and rejects unknown ones', () {
      expect(Mood.tryParse('anxious'), Mood.anxious);
      expect(Mood.tryParse('intervention'), isNull);
    });
  });

  group('MoodTracker.checkIn', () {
    test('negative moods add weight and extend the streak', () {
      final state = checkIns([Mood.sad, Mood.anxious, Mood.tired]);
      expect(state.weight, 4);
      expect(state.consecutiveNegative, 3);
    });

    test('a positive mood lowers the weight and resets the streak', () {
      final state = checkIns([Mood.anxious, Mood.anxious, Mood.okay]);
      expect(state.weight, 2);
      expect(state.consecutiveNegative, 0);
    });

    test('weight never leaves the 0–10 range', () {
      expect(checkIns([Mood.happy]).weight, 0);
      expect(checkIns(List.filled(8, Mood.anxious)).weight, 10);
    });

    test('keeps the last intervention time', () {
      final at = DateTime(2026, 11, 11);
      final state = MoodTracker.checkIn(EmotionalState(lastInterventionAt: at), Mood.sad);
      expect(state.lastInterventionAt, at);
    });
  });

  group('MoodTracker.applyEffect', () {
    test('a positive effect lifts the mood by lowering the weight', () {
      expect(MoodTracker.applyEffect(const EmotionalState(weight: 5), 1).weight, 4);
    });

    test('a negative effect raises the weight', () {
      expect(MoodTracker.applyEffect(const EmotionalState(weight: 5), -2).weight, 7);
    });

    test('is clamped and leaves the streak alone', () {
      const start = EmotionalState(weight: 0, consecutiveNegative: 2);
      final state = MoodTracker.applyEffect(start, 3);
      expect(state.weight, 0);
      expect(state.consecutiveNegative, 2);
    });
  });
}
