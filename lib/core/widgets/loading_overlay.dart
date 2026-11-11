import 'package:baobao/app/theme/app_colors.dart';
import 'package:baobao/core/widgets/bamboo_frame.dart';
import 'package:flutter/material.dart';

/// Covers [child] with a loading card while [loading] is true.
///
/// Show it only while real work is running. The prototype's fixed fake
/// loading delays are gone on purpose.
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
                color: AppColors.ink.withValues(alpha: 0.35),
                child: Center(
                  child: Semantics(
                    liveRegion: true,
                    label: label,
                    child: BambooFrame(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            'assets/images/brand/loading.webp',
                            width: 96,
                            height: 96,
                            excludeFromSemantics: true,
                          ),
                          const SizedBox(height: 16),
                          const SizedBox.square(
                            dimension: 28,
                            child: CircularProgressIndicator(strokeWidth: 3),
                          ),
                          const SizedBox(height: 12),
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
