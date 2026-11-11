import 'package:baobao/app/theme/app_colors.dart';
import 'package:baobao/core/providers.dart';
import 'package:baobao/core/settings/app_settings.dart';
import 'package:baobao/core/widgets/bamboo_button.dart';
import 'package:baobao/core/widgets/bamboo_frame.dart';
import 'package:baobao/core/widgets/character_view.dart';
import 'package:baobao/features/economy/domain/catalog.dart';
import 'package:baobao/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A short tour of the app. Shown once after onboarding and replayable from
/// Settings. It can be skipped at any point.
class TutorialScreen extends ConsumerStatefulWidget {
  const TutorialScreen({super.key});

  @override
  ConsumerState<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends ConsumerState<TutorialScreen> {
  int _index = 0;

  Future<void> _close() async {
    await ref.read(settingsProvider.notifier).setTutorialSeen(true);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final steps = ref.watch(contentProvider).tutorial;
    final step = steps[_index];
    final isLast = _index == steps.length - 1;
    final outfit =
        ref.watch(selectionsProvider).value?[ItemSlot.outfit] ??
        ref.watch(catalogProvider).defaultFor(ItemSlot.outfit);

    return PopScope(
      // Leaving by the system back button counts as having seen the tour.
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) ref.read(settingsProvider.notifier).setTutorialSeen(true);
      },
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Text(
                          l10n.onboardingStep(_index + 1, steps.length),
                          style: theme.textTheme.labelLarge,
                        ),
                        const Spacer(),
                        if (!isLast) TextButton(onPressed: _close, child: Text(l10n.tutorialSkip)),
                      ],
                    ),
                    Expanded(
                      child: CharacterView(
                        outfitAsset: outfit.asset,
                        pose: CharacterPose.parse(step.emotion),
                        semanticLabel: l10n.characterLabel,
                      ),
                    ),
                    Semantics(
                      liveRegion: true,
                      child: BambooFrame(
                        fill: AppColors.white,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              step.title,
                              style: theme.textTheme.titleLarge,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(step.body, textAlign: TextAlign.center),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ExcludeSemantics(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          for (var i = 0; i < steps.length; i++)
                            Container(
                              width: i == _index ? 18 : 8,
                              height: 8,
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              decoration: BoxDecoration(
                                color: i == _index ? AppColors.deepGreen : AppColors.tan,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        if (_index > 0) ...[
                          Expanded(
                            child: BambooButton(
                              label: l10n.actionBack,
                              tone: BambooButtonTone.cream,
                              expand: true,
                              onPressed: () => setState(() => _index--),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Expanded(
                          flex: 2,
                          child: BambooButton(
                            label: isLast ? l10n.tutorialDone : l10n.actionNext,
                            expand: true,
                            onPressed: isLast ? _close : () => setState(() => _index++),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
