import 'package:flutter/painting.dart';

/// The spacing scale. Use these instead of loose numbers.
abstract final class Space {
  static const xs = 4.0;
  static const s = 8.0;
  static const m = 12.0;
  static const l = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;
}

/// Corner radii.
abstract final class Corners {
  static const s = 12.0;
  static const m = 16.0;
  static const l = 24.0;

  static BorderRadius get small => BorderRadius.circular(s);
  static BorderRadius get medium => BorderRadius.circular(m);
  static BorderRadius get large => BorderRadius.circular(l);
}

/// Sizes that apply to many screens.
abstract final class Sizes {
  /// The smallest touch target (Android and iOS guidelines).
  static const touch = 48.0;

  /// The widest a column of content gets on a tablet.
  static const contentWidth = 560.0;

  /// Border thickness of panels.
  static const border = 1.5;
}
