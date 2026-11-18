import 'package:baobao/app/theme/app_palette.dart';
import 'package:baobao/app/theme/page_transitions.dart';
import 'package:baobao/app/theme/tokens.dart';
import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const fontFamily = 'Quicksand';

  /// Emoji in dialogue come from this bundled font, so they look the same and
  /// never appear as empty boxes on older Android versions.
  static const emojiFamily = 'BaoBaoEmoji';

  static ThemeData get light => _build(AppPalette.light, Brightness.light);
  static ThemeData get dark => _build(AppPalette.dark, Brightness.dark);

  static ThemeData _build(AppPalette p, Brightness brightness) {
    final scheme = ColorScheme(
      brightness: brightness,
      primary: p.primary,
      onPrimary: p.onPrimary,
      primaryContainer: p.fillPrimary,
      onPrimaryContainer: p.onFillPrimary,
      secondary: p.fillSecondary,
      onSecondary: p.onFillSecondary,
      secondaryContainer: p.fillSoft,
      onSecondaryContainer: p.onFillSoft,
      error: p.alert,
      onError: p.onPrimary,
      surface: p.background,
      onSurface: p.ink,
      onSurfaceVariant: p.inkSoft,
      outline: p.border,
    );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      brightness: brightness,
      fontFamily: fontFamily,
      scaffoldBackgroundColor: p.background,
      extensions: [p],
      pageTransitionsTheme: pageTransitions,
    );

    // The type scale. Quicksand reads light at small sizes, so body text sits
    // at medium weight. Six sizes cover everything.
    TextStyle s(double size, FontWeight weight, {double height = 1.3}) =>
        TextStyle(fontSize: size, fontWeight: weight, height: height, color: p.ink);
    final text = base.textTheme
        .copyWith(
          headlineMedium: s(28, FontWeight.w700, height: 1.2),
          headlineSmall: s(22, FontWeight.w700, height: 1.25),
          titleLarge: s(19, FontWeight.w700),
          titleMedium: s(16, FontWeight.w700),
          bodyLarge: s(17, FontWeight.w500, height: 1.4),
          bodyMedium: s(15, FontWeight.w500, height: 1.4),
          labelLarge: s(16, FontWeight.w700, height: 1.2),
        )
        .apply(fontFamily: fontFamily, fontFamilyFallback: const [emojiFamily]);

    return base.copyWith(
      textTheme: text,
      iconTheme: IconThemeData(color: p.ink),
      dividerColor: p.border,
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? p.primary : null,
        ),
        checkColor: WidgetStatePropertyAll(p.onPrimary),
        side: BorderSide(color: p.inkSoft, width: 2),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? p.onPrimary : p.inkSoft,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? p.primary : p.panelSelected,
        ),
        trackOutlineColor: WidgetStatePropertyAll(p.inkSoft),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: p.primary,
        inactiveTrackColor: p.border,
        thumbColor: p.primary,
        overlayColor: p.primary.withValues(alpha: 0.15),
        valueIndicatorColor: p.primary,
        valueIndicatorTextStyle: TextStyle(color: p.onPrimary, fontWeight: FontWeight.w700),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: p.panel,
        labelStyle: TextStyle(color: p.inkSoft),
        helperStyle: TextStyle(color: p.inkSoft),
        border: OutlineInputBorder(
          borderRadius: Corners.medium,
          borderSide: BorderSide(color: p.border, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: Corners.medium,
          borderSide: BorderSide(color: p.border, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: Corners.medium,
          borderSide: BorderSide(color: p.primary, width: 2.5),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: p.primary,
          minimumSize: const Size(Sizes.touch, Sizes.touch),
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: p.ink,
        contentTextStyle: TextStyle(
          color: p.background,
          fontFamily: fontFamily,
          fontWeight: FontWeight.w600,
        ),
        behavior: SnackBarBehavior.floating,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: p.background,
        showDragHandle: true,
        dragHandleColor: p.inkSoft,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(Corners.l + 4)),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: p.primary),
    );
  }
}
