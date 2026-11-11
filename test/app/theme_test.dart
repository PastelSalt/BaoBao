import 'package:baobao/app/theme/app_colors.dart';
import 'package:baobao/core/widgets/bamboo_button.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('contrast maths matches known values', () {
    const black = Color(0xFF000000);
    expect(AppColors.contrast(black, AppColors.white), closeTo(21, 0.01));
    expect(AppColors.contrast(black, black), 1);
  });

  test('body text meets WCAG AA (4.5:1) on every surface', () {
    for (final surface in [AppColors.offWhite, AppColors.cream, AppColors.white]) {
      expect(AppColors.contrast(AppColors.ink, surface), greaterThanOrEqualTo(4.5));
      expect(AppColors.contrast(AppColors.inkSoft, surface), greaterThanOrEqualTo(4.5));
      expect(AppColors.contrast(AppColors.deepGreen, surface), greaterThanOrEqualTo(4.5));
      expect(AppColors.contrast(AppColors.alert, surface), greaterThanOrEqualTo(4.5));
    }
  });

  test('button labels meet WCAG AA on every button colour', () {
    for (final tone in BambooButtonTone.values) {
      expect(
        AppColors.contrast(AppColors.ink, tone.fill),
        greaterThanOrEqualTo(4.5),
        reason: tone.name,
      );
    }
  });
}
