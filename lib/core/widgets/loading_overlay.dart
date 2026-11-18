import 'package:baobao/app/theme/app_palette.dart';
import 'package:baobao/app/theme/tokens.dart';
import 'package:baobao/core/widgets/bamboo_frame.dart';
import 'package:flutter/material.dart';

/// Covers [child] with a loading card while [loading] is true. Show it only
/// while real work is running; there are no fake delays.
class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({
    super.key,
    required this.loading,
    required this.label,
    required this.child,
  });

  final bool loading;

  /// Announced to screen readers and shown under the spinner.
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (loading)
          Positioned.fill(
            child: AbsorbPointer(
              child: ColoredBox(
                color: context.palette.scrim,
                child: Center(
                  child: Semantics(
                    liveRegion: true,
                    label: label,
                    child: BambooFrame(
                      padding: const EdgeInsets.all(Space.xl),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            'assets/images/brand/loading.webp',
                            width: 96,
                            height: 96,
                            excludeFromSemantics: true,
                          ),
                          const SizedBox(height: Space.l),
                          const SizedBox.square(
                            dimension: 28,
                            child: CircularProgressIndicator(strokeWidth: 3),
                          ),
                          const SizedBox(height: Space.m),
                          ExcludeSemantics(
                            child: Text(label, style: Theme.of(context).textTheme.titleMedium),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
