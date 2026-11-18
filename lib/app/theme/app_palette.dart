import 'package:flutter/material.dart';

/// Every colour the interface uses, by role. There is a light and a dark set;
/// widgets read the current one with `context.palette` and never hard-code a
/// colour. (Illustrations keep their own colours.)
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.isDark,
    required this.background,
    required this.panel,
    required this.panelSelected,
    required this.border,
    required this.ink,
    required this.inkSoft,
    required this.primary,
    required this.onPrimary,
    required this.fillPrimary,
    required this.onFillPrimary,
    required this.fillSecondary,
    required this.onFillSecondary,
    required this.fillSoft,
    required this.onFillSoft,
    required this.gold,
    required this.alert,
    required this.bubble,
    required this.bubbleBorder,
    required this.rim,
    required this.rimLight,
    required this.rimShade,
    required this.knot,
    required this.scrim,
  });

  final bool isDark;

  /// Behind everything.
  final Color background;

  /// Cards, list rows, chips.
  final Color panel;

  /// A panel that is chosen or in use.
  final Color panelSelected;
  final Color border;

  /// Text on [background] and [panel].
  final Color ink;
  final Color inkSoft;

  /// Links, switches, and emphasis: readable on [background] and [panel].
  final Color primary;
  final Color onPrimary;

  /// Button fills and the text on them.
  final Color fillPrimary;
  final Color onFillPrimary;
  final Color fillSecondary;
  final Color onFillSecondary;
  final Color fillSoft;
  final Color onFillSoft;

  final Color gold;
  final Color alert;

  /// The speech bubble.
  final Color bubble;
  final Color bubbleBorder;

  /// The bamboo frame: outer edge, light and shaded cane, and knots.
  final Color rim;
  final Color rimLight;
  final Color rimShade;
  final Color knot;

  final Color scrim;

  static const light = AppPalette(
    isDark: false,
    background: Color(0xFFF6F6DB),
    panel: Color(0xFFFFFFFF),
    panelSelected: Color(0xFFD5E7B8),
    border: Color(0xFFC4DEA4),
    ink: Color(0xFF2E3B26),
    inkSoft: Color(0xFF55604C),
    primary: Color(0xFF3F6B2B),
    onPrimary: Color(0xFFFFFFFF),
    fillPrimary: Color(0xFFA7D489),
    onFillPrimary: Color(0xFF2E3B26),
    fillSecondary: Color(0xFFCAAD7E),
    onFillSecondary: Color(0xFF2E3B26),
    fillSoft: Color(0xFFD5E7B8),
    onFillSoft: Color(0xFF2E3B26),
    gold: Color(0xFFFFD54F),
    alert: Color(0xFFA63D2F),
    bubble: Color(0xFFFFFFFF),
    bubbleBorder: Color(0xFFA7D489),
    rim: Color(0xFFD2B48C),
    rimLight: Color(0xFFF5EFE0),
    rimShade: Color(0xFFE6D5B8),
    knot: Color(0x33A68B67),
    scrim: Color(0x592E3B26),
  );

  static const dark = AppPalette(
    isDark: true,
    background: Color(0xFF16231A),
    panel: Color(0xFF213529),
    panelSelected: Color(0xFF2F4D38),
    border: Color(0xFF3E5C47),
    ink: Color(0xFFEAF3DE),
    inkSoft: Color(0xFFB7C8AC),
    primary: Color(0xFFA7D489),
    onPrimary: Color(0xFF14231A),
    fillPrimary: Color(0xFFA7D489),
    onFillPrimary: Color(0xFF14231A),
    fillSecondary: Color(0xFFCAAD7E),
    onFillSecondary: Color(0xFF14231A),
    fillSoft: Color(0xFF2F4D38),
    onFillSoft: Color(0xFFEAF3DE),
    gold: Color(0xFFFFD54F),
    alert: Color(0xFFF2A097),
    bubble: Color(0xFF243B2C),
    bubbleBorder: Color(0xFF5F8F55),
    rim: Color(0xFF8A7552),
    rimLight: Color(0xFF3A3626),
    rimShade: Color(0xFF2A281C),
    knot: Color(0x33000000),
    scrim: Color(0x99000000),
  );

  @override
  AppPalette copyWith({bool? isDark}) => (isDark ?? this.isDark) ? dark : light;

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    Color c(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppPalette(
      isDark: t < 0.5 ? isDark : other.isDark,
      background: c(background, other.background),
      panel: c(panel, other.panel),
      panelSelected: c(panelSelected, other.panelSelected),
      border: c(border, other.border),
      ink: c(ink, other.ink),
      inkSoft: c(inkSoft, other.inkSoft),
      primary: c(primary, other.primary),
      onPrimary: c(onPrimary, other.onPrimary),
      fillPrimary: c(fillPrimary, other.fillPrimary),
      onFillPrimary: c(onFillPrimary, other.onFillPrimary),
      fillSecondary: c(fillSecondary, other.fillSecondary),
      onFillSecondary: c(onFillSecondary, other.onFillSecondary),
      fillSoft: c(fillSoft, other.fillSoft),
      onFillSoft: c(onFillSoft, other.onFillSoft),
      gold: c(gold, other.gold),
      alert: c(alert, other.alert),
      bubble: c(bubble, other.bubble),
      bubbleBorder: c(bubbleBorder, other.bubbleBorder),
      rim: c(rim, other.rim),
      rimLight: c(rimLight, other.rimLight),
      rimShade: c(rimShade, other.rimShade),
      knot: c(knot, other.knot),
      scrim: c(scrim, other.scrim),
    );
  }
}

extension PaletteOnContext on BuildContext {
  AppPalette get palette => Theme.of(this).extension<AppPalette>()!;
}
