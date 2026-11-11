import 'package:baobao/core/providers.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Whether to skip non-essential animation: true if the person asked for
/// reduced motion in the app or in their device settings.
bool reduceMotion(BuildContext context, WidgetRef ref) =>
    ref.watch(reducedMotionProvider) || MediaQuery.disableAnimationsOf(context);
