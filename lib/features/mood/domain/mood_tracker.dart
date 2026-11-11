import 'package:baobao/features/mood/domain/emotional_state.dart';
import 'package:baobao/features/mood/domain/mood.dart';

/// Rules for how check-ins and conversation choices change [EmotionalState].
abstract final class MoodTracker {
  /// Applies one mood check-in.
  static EmotionalState checkIn(EmotionalState state, Mood mood) {
    return state.copyWith(
      weight: _clamp(state.weight + mood.weightDelta),
      consecutiveNegative: mood.isNegative ? state.consecutiveNegative + 1 : 0,
    );
  }

  /// Applies the mood effect of a conversation choice.
  ///
  /// A positive [effect] is a lift, so it lowers the weight.
  static EmotionalState applyEffect(EmotionalState state, int effect) {
    if (effect == 0) return state;
    return state.copyWith(weight: _clamp(state.weight - effect));
  }

  static int _clamp(int weight) => weight.clamp(EmotionalState.minWeight, EmotionalState.maxWeight);
}
