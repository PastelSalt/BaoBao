import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

/// Saves each screenshot the journey takes into `build/device_screenshots/`.
Future<void> main() async {
  await integrationDriver(
    onScreenshot: (name, bytes, [args]) async {
      final file = File('build/device_screenshots/$name.png')..createSync(recursive: true);
      file.writeAsBytesSync(bytes);
      return true;
    },
  );
}
