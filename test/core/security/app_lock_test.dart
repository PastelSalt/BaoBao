import 'package:baobao/core/security/app_lock.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeAuthenticator implements DeviceAuthenticator {
  FakeAuthenticator({this.succeeds = true});
  bool succeeds;
  final reasons = <String>[];

  @override
  Future<bool> isAvailable() async => true;

  @override
  Future<bool> authenticate(String reason) async {
    reasons.add(reason);
    return succeeds;
  }
}

void main() {
  final noon = DateTime(2026, 11, 11, 12);
  late FakeAuthenticator auth;
  late ProviderContainer container;
  AppLockController controller() => container.read(appLockProvider.notifier);
  bool locked() => container.read(appLockProvider);

  setUp(() {
    auth = FakeAuthenticator();
    container = ProviderContainer(overrides: [deviceAuthenticatorProvider.overrideWithValue(auth)]);
    addTearDown(container.dispose);
  });

  test('starts unlocked', () => expect(locked(), isFalse));

  test('unlocks only when the device confirms', () async {
    controller().lock();
    auth.succeeds = false;
    expect(await controller().unlock('why'), isFalse);
    expect(locked(), isTrue);

    auth.succeeds = true;
    expect(await controller().unlock('why'), isTrue);
    expect(locked(), isFalse);
    expect(auth.reasons, ['why', 'why']);
  });

  test('a short trip to another app does not re-lock', () {
    controller().onBackgrounded(noon);
    controller().onForegrounded(noon.add(const Duration(seconds: 59)), enabled: true);
    expect(locked(), isFalse);
  });

  test('a longer absence re-locks', () {
    controller().onBackgrounded(noon);
    controller().onForegrounded(noon.add(AppLockController.gracePeriod), enabled: true);
    expect(locked(), isTrue);
  });

  test('never locks when the app lock is off', () {
    controller().onBackgrounded(noon);
    controller().onForegrounded(noon.add(const Duration(hours: 5)), enabled: false);
    expect(locked(), isFalse);
  });

  test('the absence is measured from the first time the app was hidden', () {
    controller().onBackgrounded(noon);
    controller().onBackgrounded(noon.add(const Duration(seconds: 50)));
    controller().onForegrounded(noon.add(const Duration(seconds: 70)), enabled: true);
    expect(locked(), isTrue);
  });

  test('with no lock support, nothing can be unlocked', () async {
    const none = NoDeviceAuthenticator();
    expect(await none.isAvailable(), isFalse);
    expect(await none.authenticate('why'), isFalse);
  });
}
