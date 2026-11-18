import 'package:baobao/app/theme/app_palette.dart';
import 'package:baobao/core/widgets/character_view.dart';
import 'package:baobao/core/widgets/speech_bubble.dart';
import 'package:baobao/core/widgets/typewriter_text.dart';
import 'package:flutter/material.dart';

/// BaoBao and what BaoBao is saying: a speech bubble over the character.
///
/// Fills the space it is given. The bubble takes at most about half of it and
/// scrolls inside itself beyond that; the character gets the rest and shrinks
/// rather than disappearing. This is the one rule that keeps the words
/// readable on every screen size and at every text size.
class BaoStage extends StatefulWidget {
  const BaoStage({
    super.key,
    required this.text,
    required this.outfitAsset,
    required this.characterLabel,
    this.pose = CharacterPose.hello,
    this.lineId = 0,
    this.onCharacterTap,
    this.onLineFinished,
    this.badgeAsset,
  });

  final String text;
  final String outfitAsset;
  final String characterLabel;
  final CharacterPose pose;

  /// Changes whenever BaoBao says something new, even the same words again,
  /// so the typewriter starts over.
  final int lineId;
  final VoidCallback? onCharacterTap;
  final VoidCallback? onLineFinished;

  /// A small picture pinned to the character's shoulder, such as the face of
  /// the mood just chosen, for moods that have no pose of their own.
  final String? badgeAsset;

  @override
  State<BaoStage> createState() => _BaoStageState();
}

class _BaoStageState extends State<BaoStage> {
  final _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(BaoStage old) {
    super.didUpdateWidget(old);
    if (old.lineId != widget.lineId && _scroll.hasClients) _scroll.jumpTo(0);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        final bubbleMax = box.maxHeight * 0.52;
        final contentMax = (bubbleMax - SpeechBubble.chrome).clamp(48.0, 400.0);
        return Column(
          children: [
            SpeechBubble(
              maxContentHeight: contentMax,
              controller: _scroll,
              child: TypewriterText(
                widget.text,
                key: ValueKey('${widget.lineId}/${widget.text}'),
                follow: _scroll,
                onFinished: widget.onLineFinished,
              ),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, area) {
                  final badge = widget.badgeAsset;
                  final size = (area.biggest.shortestSide * 0.26).clamp(36.0, 72.0);
                  return Stack(
                    children: [
                      Positioned.fill(
                        child: Semantics(
                          button: widget.onCharacterTap != null,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: widget.onCharacterTap,
                            child: CharacterView(
                              outfitAsset: widget.outfitAsset,
                              pose: widget.pose,
                              semanticLabel: widget.characterLabel,
                            ),
                          ),
                        ),
                      ),
                      if (badge != null)
                        Positioned(
                          top: 0,
                          right: area.maxWidth * 0.08,
                          child: _Badge(asset: badge, size: size),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.asset, required this.size});

  final String asset;
  final double size;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * 0.08),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: p.panel,
        border: Border.all(color: p.bubbleBorder, width: 2),
      ),
      child: Image.asset(asset, fit: BoxFit.contain, excludeFromSemantics: true),
    );
  }
}
