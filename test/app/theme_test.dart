import 'package:baobao/app/theme/app_colors.dart';
import 'package:baobao/app/theme/app_palette.dart';
import 'package:baobao/app/theme/app_theme.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('contrast maths matches known values', () {
    const black = Color(0xFF000000);
    expect(AppColors.contrast(black, const Color(0xFFFFFFFF)), closeTo(21, 0.01));
    expect(AppColors.contrast(black, black), 1);
  });

  for (final (name, p) in [('light', AppPalette.light), ('dark', AppPalette.dark)]) {
    group('$name palette meets WCAG AA (4.5:1)', () {
      test('text on every surface', () {
        for (final surface in [p.background, p.panel, p.panelSelected, p.bubble]) {
          for (final (label, text) in [
            ('ink', p.ink),
            ('inkSoft', p.inkSoft),
            ('primary', p.primary),
            ('alert', p.alert),
          ]) {
            expect(
              AppColors.contrast(text, surface),
              greaterThanOrEqualTo(4.5),
              reason: '$label on $surface',
            );
          }
        }
      });

      test('text on every button fill', () {
        for (final (label, text, fill) in [
          ('primary', p.onFillPrimary, p.fillPrimary),
          ('secondary', p.onFillSecondary, p.fillSecondary),
          ('soft', p.onFillSoft, p.fillSoft),
          ('on primary', p.onPrimary, p.primary),
        ]) {
          expect(AppColors.contrast(text, fill), greaterThanOrEqualTo(4.5), reason: label);
        }
      });

      test('secondary and quiet buttons read on their surface', () {
        // Secondary buttons use panel with ink text; quiet buttons use primary on the background.
        expect(AppColors.contrast(p.ink, p.panel), greaterThanOrEqualTo(4.5));
        expect(AppColors.contrast(p.primary, p.background), greaterThanOrEqualTo(4.5));
      });

      test('icons and borders that carry meaning reach 3:1', () {
        expect(AppColors.contrast(p.primary, p.panel), greaterThanOrEqualTo(3));
        expect(
          AppColors.contrast(p.gold, p.background),
          greaterThanOrEqualTo(1.2),
          reason: 'gold is decorative only, always paired with text',
        );
      });
    });
  }

  test('both themes carry their palette', () {
    expect(AppTheme.light.extension<AppPalette>(), AppPalette.light);
    expect(AppTheme.dark.extension<AppPalette>(), AppPalette.dark);
  });
}
