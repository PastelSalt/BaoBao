import 'package:baobao/core/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// One gentle transition for every screen: a fade with a small rise. Off when
/// reduced motion is on, in the app or in the phone's settings.
class BaoPageTransitions extends PageTransitionsBuilder {
  const BaoPageTransitions();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (_reducedInApp(context) || MediaQuery.disableAnimationsOf(context)) return child;

    final curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    // The screen underneath dims slightly as the new one arrives.
    final behind = Tween<double>(
      begin: 1,
      end: 0.92,
    ).animate(CurvedAnimation(parent: secondaryAnimation, curve: Curves.easeOut));
    return FadeTransition(
      opacity: behind,
      child: FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, 0.035), end: Offset.zero).animate(curved),
          child: child,
        ),
      ),
    );
  }
}

/// The in-app reduced-motion setting. False where there is no provider scope,
/// such as the start-up error screen.
bool _reducedInApp(BuildContext context) {
  try {
    return ProviderScope.containerOf(context, listen: false).read(reducedMotionProvider);
  } catch (_) {
    return false;
  }
}

/// The transition builder for every platform.
const pageTransitions = PageTransitionsTheme(
  builders: {
    TargetPlatform.android: BaoPageTransitions(),
    TargetPlatform.iOS: BaoPageTransitions(),
    TargetPlatform.linux: BaoPageTransitions(),
    TargetPlatform.macOS: BaoPageTransitions(),
    TargetPlatform.windows: BaoPageTransitions(),
    TargetPlatform.fuchsia: BaoPageTransitions(),
  },
);
