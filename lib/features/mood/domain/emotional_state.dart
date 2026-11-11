/// The running summary of how a profile has been feeling.
///
/// [weight] rises with negative check-ins and falls with positive ones.
/// It never represents a diagnosis; it only decides when BaoBao should
/// suggest extra support.
class EmotionalState {
  const EmotionalState({this.weight = 0, this.consecutiveNegative = 0, this.lastInterventionAt})
    : assert(weight >= minWeight && weight <= maxWeight),
      assert(consecutiveNegative >= 0);

  static const minWeight = 0;
  static const maxWeight = 10;

  final int weight;

  /// Negative check-ins in a row, reset by any positive check-in.
  final int consecutiveNegative;

  /// When the intervention conversation was last started, if ever.
  final DateTime? lastInterventionAt;

  EmotionalState copyWith({int? weight, int? consecutiveNegative, DateTime? lastInterventionAt}) {
    return EmotionalState(
      weight: weight ?? this.weight,
      consecutiveNegative: consecutiveNegative ?? this.consecutiveNegative,
      lastInterventionAt: lastInterventionAt ?? this.lastInterventionAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is EmotionalState &&
      other.weight == weight &&
      other.consecutiveNegative == consecutiveNegative &&
      other.lastInterventionAt == lastInterventionAt;

  @override
  int get hashCode => Object.hash(weight, consecutiveNegative, lastInterventionAt);

  @override
  String toString() =>
      'EmotionalState(weight: $weight, consecutiveNegative: $consecutiveNegative, '
      'lastInterventionAt: $lastInterventionAt)';
}
