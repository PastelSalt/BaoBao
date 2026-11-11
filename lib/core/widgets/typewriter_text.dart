import 'package:baobao/core/widgets/motion.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Reveals [text] one character at a time, the way BaoBao "speaks".
///
/// - The widget takes its final size immediately, so nothing below it jumps.
/// - Tapping shows the rest at once.
/// - Screen readers get the whole line straight away.
/// - With reduced motion the text simply appears.
class TypewriterText extends ConsumerStatefulWidget {
  const TypewriterText(
    this.text, {
    super.key,
    this.style,
    this.textAlign = TextAlign.center,
    this.perCharacter = const Duration(milliseconds: 28),
    this.onFinished,
  });

  final String text;
  final TextStyle? style;
  final TextAlign textAlign;
  final Duration perCharacter;

  /// Called once each time a line has been fully revealed.
  final VoidCallback? onFinished;

  @override
  ConsumerState<TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends ConsumerState<TypewriterText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this)
    ..addStatusListener((status) {
      if (status == AnimationStatus.completed) _announceFinished();
    });

  // Grapheme clusters, so an emoji is never shown half-drawn.
  late List<String> _characters = widget.text.characters.toList();
  bool _started = false;

  /// Whether [TypewriterText.onFinished] has been called for the current line.
  bool _announced = false;

  void _announceFinished() {
    if (_announced || !mounted) return;
    _announced = true;
    widget.onFinished?.call();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_started) {
      _started = true;
      _restart();
    }
  }

  @override
  void didUpdateWidget(TypewriterText old) {
    super.didUpdateWidget(old);
    if (old.text != widget.text) {
      _characters = widget.text.characters.toList();
      _restart();
    }
  }

  void _restart() {
    _controller.duration = widget.perCharacter * _characters.length;
    final skip = _characters.isEmpty || reduceMotion(context, ref);
    if (skip) {
      // This runs while the tree is building, so the callback has to wait
      // for the frame to end. Marking it announced keeps the status listener
      // from calling it early.
      _announced = true;
      _controller.value = 1;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _announced = false;
        _announceFinished();
      });
    } else {
      _announced = false;
      _controller.forward(from: 0);
    }
  }

  void _finish() {
    if (_controller.isAnimating) _controller.value = 1;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final style = widget.style ?? Theme.of(context).textTheme.bodyLarge!;
    return Semantics(
      label: widget.text,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _finish,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final shown = (_controller.value * _characters.length).floor();
            return Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: _characters.take(shown).join()),
                  TextSpan(
                    text: _characters.skip(shown).join(),
                    style: const TextStyle(color: Color(0x00000000)),
                  ),
                ],
              ),
              style: style,
              textAlign: widget.textAlign,
            );
          },
        ),
      ),
    );
  }
}
