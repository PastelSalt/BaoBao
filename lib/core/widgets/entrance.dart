import 'package:baobao/core/widgets/motion.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Fades and slides [child] into place when it first appears. Several of these
/// with growing [delay]s make a screen arrive piece by piece.
///
/// With reduced motion the child is simply there. Uses one animation with an
/// interval for the delay, so no timers are left running.
class Entrance extends ConsumerStatefulWidget {
  const Entrance({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 380),
    this.offset = const Offset(0, 0.06),
  });

  final Widget child;
  final Duration delay;
  final Duration duration;

  /// Where it starts, as a fraction of its own size.
  final Offset offset;

  @override
  ConsumerState<Entrance> createState() => _EntranceState();
}

class _EntranceState extends ConsumerState<Entrance> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.delay + widget.duration,
  );
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (reduceMotion(context, ref)) {
      _controller.value = 1;
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final total = (widget.delay + widget.duration).inMicroseconds;
    final curved = CurvedAnimation(
      parent: _controller,
      curve: Interval(widget.delay.inMicroseconds / total, 1, curve: Curves.easeOutCubic),
    );
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(begin: widget.offset, end: Offset.zero).animate(curved),
        child: widget.child,
      ),
    );
  }
}
