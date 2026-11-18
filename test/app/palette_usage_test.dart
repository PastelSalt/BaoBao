import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Interface code takes its colours from `AppPalette` (through
/// `context.palette`), so both themes always look right. Only the theme
/// itself and the illustrations (painters) may name colours directly.
void main() {
  test('no screen or widget hard-codes a colour', () {
    final allowed = [
      RegExp(r'lib/app/theme/'),
      RegExp(r'_painter\.dart$'),
      RegExp(r'lib/core/widgets/star_amount\.dart$'), // the star illustration
      RegExp(r'\.g\.dart$'),
      RegExp(r'lib/l10n/'),
    ];
    final colour = RegExp(r'\bColor\(0x|\bColors\.(?!transparent\b)\w+|AppColors\.');

    final offenders = <String>[];
    for (final file in Directory('lib').listSync(recursive: true).whereType<File>()) {
      final path = file.path.replaceAll(r'\', '/');
      if (!path.endsWith('.dart') || allowed.any((pattern) => pattern.hasMatch(path))) continue;
      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        if (lines[i].trimLeft().startsWith('//')) continue;
        if (colour.hasMatch(lines[i])) offenders.add('$path:${i + 1}: ${lines[i].trim()}');
      }
    }
    expect(offenders, isEmpty, reason: 'Use context.palette instead:\n${offenders.join('\n')}');
  });
}
