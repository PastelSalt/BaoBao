import 'package:baobao/app/theme/app_palette.dart';
import 'package:flutter/material.dart';

/// The bubble BaoBao's words appear in, with a tail pointing down to the
/// character.
///
/// With [maxContentHeight] the content scrolls inside the bubble instead of
/// growing without limit, so a long line never pushes BaoBao off the screen.
class SpeechBubble extends StatefulWidget {
  const SpeechBubble({super.key, required this.child, this.maxContentHeight, this.controller});

  static const tail = 12.0;
  static const _padding = EdgeInsets.fromLTRB(18, 12, 18, 12 + tail);

  /// Vertical space the bubble uses besides its content.
  static double get chrome => _padding.vertical;

  final Widget child;

  /// The tallest the content may be before it scrolls. Null means unlimited.
  final double? maxContentHeight;

  /// Scrolls the content; needed when [maxContentHeight] is set.
  final ScrollController? controller;

  @override
  State<SpeechBubble> createState() => _SpeechBubbleState();
}

class _SpeechBubbleState extends State<SpeechBubble> {
  bool _moreBelow = false;

  @override
  void initState() {
    super.initState();
    widget.controller?.addListener(_update);
    WidgetsBinding.instance.addPostFrameCallback((_) => _update());
  }

  @override
  void didUpdateWidget(SpeechBubble old) {
    super.didUpdateWidget(old);
    if (old.controller != widget.controller) {
      old.controller?.removeListener(_update);
      widget.controller?.addListener(_update);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _update());
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_update);
    super.dispose();
  }

  void _update() {
    final scroll = widget.controller;
    if (!mounted || scroll == null || !scroll.hasClients) return;
    final more = scroll.position.maxScrollExtent - scroll.position.pixels > 2;
    if (more != _moreBelow) setState(() => _moreBelow = more);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    Widget content = widget.child;
    if (widget.maxContentHeight != null) {
      content = ConstrainedBox(
        constraints: BoxConstraints(maxHeight: widget.maxContentHeight!),
        child: ShaderMask(
          // Text that runs on below fades out, which says "scroll for more".
          shaderCallback: (rect) => LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [p.ink, p.ink, _moreBelow ? Colors.transparent : p.ink],
            stops: const [0, 0.82, 1],
          ).createShader(rect),
          blendMode: BlendMode.dstIn,
          child: Scrollbar(
            controller: widget.controller,
            child: SingleChildScrollView(controller: widget.controller, child: widget.child),
          ),
        ),
      );
    }
    return CustomPaint(
      painter: _BubblePainter(fill: p.bubble, border: p.bubbleBorder),
      child: Padding(padding: SpeechBubble._padding, child: content),
    );
  }
}

class _BubblePainter extends CustomPainter {
  const _BubblePainter({required this.fill, required this.border});

  final Color fill;
  final Color border;

  @override
  void paint(Canvas canvas, Size size) {
    const tail = SpeechBubble.tail;
    final body = RRect.fromRectAndRadius(
      Rect.fromLTWH(1, 1, size.width - 2, size.height - tail - 2),
      const Radius.circular(20),
    );
    final cx = size.width / 2;
    final bottom = size.height - tail - 1;
    final pointer = Path()
      ..moveTo(cx - tail, bottom)
      ..lineTo(cx, size.height - 1)
      ..lineTo(cx + tail, bottom)
      ..close();
    final outline = Path.combine(PathOperation.union, Path()..addRRect(body), pointer);

    canvas.drawPath(outline, Paint()..color = fill);
    canvas.drawPath(
      outline,
      Paint()
        ..color = border
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_BubblePainter old) => old.fill != fill || old.border != border;
}
