import 'package:baobao/app/theme/app_palette.dart';
import 'package:baobao/app/theme/tokens.dart';
import 'package:baobao/core/providers.dart';
import 'package:baobao/core/settings/app_settings.dart';
import 'package:baobao/core/widgets/app_button.dart';
import 'package:baobao/core/widgets/bao_stage.dart';
import 'package:baobao/core/widgets/character_view.dart';
import 'package:baobao/features/economy/domain/catalog.dart';
import 'package:baobao/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A short tour of the app, told by BaoBao. Shown once after onboarding and
/// replayable from Settings. It can be skipped at any point.
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
    final p = context.palette;
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
                padding: const EdgeInsets.fromLTRB(Space.l, Space.xs, Space.l, Space.l),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            l10n.onboardingStep(_index + 1, steps.length),
                            style: theme.textTheme.labelLarge,
                          ),
                        ),
                        if (!isLast)
                          AppButton(
                            label: l10n.tutorialSkip,
                            kind: ButtonKind.quiet,
                            onPressed: _close,
                          ),
                      ],
                    ),
                    Semantics(
                      header: true,
                      child: Text(
                        step.title,
                        style: theme.textTheme.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: Space.s),
                    Expanded(
                      child: BaoStage(
                        text: step.body,
                        lineId: _index,
                        pose: CharacterPose.parse(step.emotion),
                        outfitAsset: outfit.asset,
                        characterLabel: l10n.characterLabel,
                      ),
                    ),
                    const SizedBox(height: Space.m),
                    ExcludeSemantics(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          for (var i = 0; i < steps.length; i++)
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: i == _index ? 18 : 8,
                              height: 8,
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              decoration: BoxDecoration(
                                color: i == _index ? p.primary : p.border,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: Space.m),
                    Row(
                      children: [
                        if (_index > 0) ...[
                          Expanded(
                            child: AppButton(
                              label: l10n.actionBack,
                              kind: ButtonKind.secondary,
                              expand: true,
                              onPressed: () => setState(() => _index--),
                            ),
                          ),
                          const SizedBox(width: Space.s),
                        ],
                        Expanded(
                          flex: 2,
                          child: AppButton(
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
