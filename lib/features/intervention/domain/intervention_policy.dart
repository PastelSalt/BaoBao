import 'package:baobao/features/mood/domain/emotional_state.dart';
import 'package:baobao/features/mood/domain/mood.dart';

/// Decides when BaoBao should swap the usual conversation for the
/// intervention conversation that points to professional support.
abstract final class InterventionPolicy {
  /// The emotional weight at which an intervention becomes possible.
  static const weightThreshold = 4;

  /// Negative check-ins in a row that count as a sustained low.
  static const consecutiveThreshold = 2;

  /// How many of the most recent check-ins are examined for a pattern.
  static const patternWindow = 3;

  /// Negative check-ins within [patternWindow] that count as a pattern.
  static const patternThreshold = 2;

  /// Minimum time between two interventions, so BaoBao never nags.
  static const cooldown = Duration(hours: 24);

  /// Whether to start the intervention conversation now.
  ///
  /// [recentMoods] is ordered oldest to newest and must already include the
  /// check-in that was just recorded.
  static bool shouldIntervene({
    required EmotionalState state,
    required List<Mood> recentMoods,
    required DateTime now,
  }) {
    if (state.weight < weightThreshold) return false;

    final last = state.lastInterventionAt;
    if (last != null && now.difference(last) < cooldown) return false;

    final sustained = state.consecutiveNegative >= consecutiveThreshold;
    return sustained || hasNegativePattern(recentMoods);
  }

  static bool hasNegativePattern(List<Mood> recentMoods) {
    final window = recentMoods.length <= patternWindow
        ? recentMoods
        : recentMoods.sublist(recentMoods.length - patternWindow);
    return window.where((mood) => mood.isNegative).length >= patternThreshold;
  }
}
