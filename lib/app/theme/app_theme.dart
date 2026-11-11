import 'package:baobao/app/theme/app_colors.dart';
import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const fontFamily = 'Quicksand';

  static ThemeData get light {
    const scheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.deepGreen,
      onPrimary: AppColors.white,
      primaryContainer: AppColors.green,
      onPrimaryContainer: AppColors.ink,
      secondary: AppColors.tan,
      onSecondary: AppColors.ink,
      secondaryContainer: AppColors.cream,
      onSecondaryContainer: AppColors.ink,
      error: AppColors.alert,
      onError: AppColors.white,
      surface: AppColors.offWhite,
      onSurface: AppColors.ink,
      onSurfaceVariant: AppColors.inkSoft,
      outline: AppColors.tan,
    );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: fontFamily,
      scaffoldBackgroundColor: AppColors.offWhite,
    );

    // Quicksand reads light at small sizes, so body text sits at medium weight.
    final text = base.textTheme
        .apply(bodyColor: AppColors.ink, displayColor: AppColors.ink)
        .copyWith(
          headlineMedium: base.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
          headlineSmall: base.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          titleLarge: base.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          titleMedium: base.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          bodyLarge: base.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500, height: 1.4),
          bodyMedium: base.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500, height: 1.4),
          labelLarge: base.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
        );

    return base.copyWith(
      textTheme: text,
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? AppColors.deepGreen : null,
        ),
        side: const BorderSide(color: AppColors.inkSoft, width: 2),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.tan, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.tan, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.deepGreen, width: 2.5),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.deepGreen,
          minimumSize: const Size(48, 48),
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: AppColors.deepGreen),
    );
  }
}
