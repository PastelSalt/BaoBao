import 'package:baobao/core/widgets/motion.dart';
import 'package:baobao/features/mood/domain/mood.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The poses every outfit provides.
enum CharacterPose {
  hello,
  happy,
  sad,
  tired;

  /// The closest pose for a mood. There is no anxious or okay art yet.
  static CharacterPose forMood(Mood mood) => switch (mood) {
    Mood.happy => happy,
    Mood.okay => hello,
    Mood.sad || Mood.anxious => sad,
    Mood.tired => tired,
  };

  static CharacterPose parse(String name) =>
      values.firstWhere((pose) => pose.name == name, orElse: () => hello);
}

/// BaoBao, in an outfit and a pose, gently bobbing.
class CharacterView extends ConsumerStatefulWidget {
  const CharacterView({
    super.key,
    required this.outfitAsset,
    required this.semanticLabel,
    this.pose = CharacterPose.hello,
  });

  /// The outfit's asset folder, from the catalogue.
  final String outfitAsset;
  final CharacterPose pose;
  final String semanticLabel;

  static String assetFor(String outfitAsset, CharacterPose pose) =>
      '$outfitAsset/${pose.name}.webp';

  @override
  ConsumerState<CharacterView> createState() => _CharacterViewState();
}

class _CharacterViewState extends ConsumerState<CharacterView> with SingleTickerProviderStateMixin {
  late final AnimationController _bob = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  );

  @override
  void dispose() {
    _bob.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final still = reduceMotion(context, ref);
    if (still && _bob.isAnimating) {
      _bob.stop();
    } else if (!still && !_bob.isAnimating) {
      _bob.repeat(reverse: true);
    }

    final image = AnimatedSwitcher(
      duration: still ? Duration.zero : const Duration(milliseconds: 250),
      child: Image.asset(
        CharacterView.assetFor(widget.outfitAsset, widget.pose),
        key: ValueKey('${widget.outfitAsset}/${widget.pose.name}'),
        fit: BoxFit.contain,
        semanticLabel: widget.semanticLabel,
        gaplessPlayback: true,
      ),
    );

    return AnimatedBuilder(
      animation: _bob,
      child: image,
      builder: (context, child) => Transform.translate(
        offset: Offset(0, still ? 0 : -6 * Curves.easeInOut.transform(_bob.value)),
        child: child,
      ),
    );
  }
}
