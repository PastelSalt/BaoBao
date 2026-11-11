import 'dart:math' as math;

import 'package:flutter/painting.dart';

/// BaoBao's palette: soft bamboo greens and warm creams, with a dark ink for
/// text so everything stays readable.
abstract final class AppColors {
  // Surfaces
  static const offWhite = Color(0xFFF6F6DB);
  static const cream = Color(0xFFECEBC9);
  static const white = Color(0xFFFFFFFF);

  // Greens
  static const paleGreen = Color(0xFFD5E7B8);
  static const lightGreen = Color(0xFFC4DEA4);
  static const green = Color(0xFFA7D489);

  /// A green dark enough to carry text and borders on light surfaces.
  static const deepGreen = Color(0xFF3F6B2B);

  // Bamboo
  static const tan = Color(0xFFCAAD7E);
  static const bambooEdge = Color(0xFFD2B48C);
  static const bambooLight = Color(0xFFF5EFE0);
  static const bambooShade = Color(0xFFE6D5B8);
  static const bambooKnot = Color(0x33A68B67);
  static const bambooLine = Color(0x40A68B67);

  // Text
  static const ink = Color(0xFF2E3B26);
  static const inkSoft = Color(0xFF55604C);

  // Accents
  static const gold = Color(0xFFFFD54F);
  static const alert = Color(0xFFA63D2F);

  /// WCAG 2 contrast ratio between two opaque colours, from 1 to 21.
  static double contrast(Color a, Color b) {
    final la = _luminance(a), lb = _luminance(b);
    final lighter = math.max(la, lb), darker = math.min(la, lb);
    return (lighter + 0.05) / (darker + 0.05);
  }

  static double _luminance(Color c) {
    double channel(double v) =>
        v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
    return 0.2126 * channel(c.r) + 0.7152 * channel(c.g) + 0.0722 * channel(c.b);
  }
}
