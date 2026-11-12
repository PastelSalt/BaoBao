import 'dart:async';

import 'package:baobao/core/providers.dart';
import 'package:baobao/features/claw_machine/domain/claw_tries.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The active profile's tries as of now. Re-evaluated every second so the
/// refill countdown stays live without writing to the database.
final clawTriesProvider = StreamProvider<ClawTries>((ref) {
  final id = ref.watch(activeProfileIdProvider);
  if (id == null) return const Stream.empty();
  final clock = ref.watch(clockProvider);
  final stored = ref.watch(clawRepositoryProvider).watchTries(id);

  final controller = StreamController<ClawTries>();
  ClawTries? latest;
  void emit() {
    final value = latest;
    if (value != null && !controller.isClosed) controller.add(value.refreshed(clock.now()));
  }

  final subscription = stored.listen((value) {
    latest = value;
    emit();
  }, onError: controller.addError);
  final timer = Timer.periodic(const Duration(seconds: 1), (_) => emit());
  ref.onDispose(() {
    timer.cancel();
    unawaited(subscription.cancel());
    unawaited(controller.close());
  });
  return controller.stream;
});
