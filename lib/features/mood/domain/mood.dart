/// The five moods a person can check in with.
enum Mood {
  happy(weightDelta: -3),
  okay(weightDelta: -2),
  sad(weightDelta: 1),
  tired(weightDelta: 1),
  anxious(weightDelta: 2);

  const Mood({required this.weightDelta});

  /// How much a check-in with this mood moves the emotional weight.
  final int weightDelta;

  /// Negative moods add weight and count towards the intervention pattern.
  bool get isNegative => weightDelta > 0;

  static Mood? tryParse(String name) {
    for (final mood in values) {
      if (mood.name == name) return mood;
    }
    return null;
  }
}
