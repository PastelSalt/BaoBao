import 'package:baobao/app/router.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('before onboarding, everything leads to onboarding', () {
    for (final location in [Routes.home, Routes.unlock, '/shop']) {
      expect(guard(onboarded: false, locked: false, location: location), Routes.onboarding);
      expect(guard(onboarded: false, locked: true, location: location), Routes.onboarding);
    }
    expect(guard(onboarded: false, locked: true, location: Routes.onboarding), isNull);
  });

  test('while locked, everything leads to the unlock screen', () {
    for (final location in [Routes.home, Routes.onboarding, '/shop']) {
      expect(guard(onboarded: true, locked: true, location: location), Routes.unlock);
    }
    expect(guard(onboarded: true, locked: true, location: Routes.unlock), isNull);
  });

  test('once in, onboarding and unlock send you home and other screens stay put', () {
    expect(guard(onboarded: true, locked: false, location: Routes.onboarding), Routes.home);
    expect(guard(onboarded: true, locked: false, location: Routes.unlock), Routes.home);
    expect(guard(onboarded: true, locked: false, location: Routes.home), isNull);
    expect(guard(onboarded: true, locked: false, location: '/shop'), isNull);
  });
}
