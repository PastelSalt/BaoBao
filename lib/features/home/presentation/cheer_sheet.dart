import 'package:baobao/app/theme/app_palette.dart';
import 'package:baobao/app/theme/tokens.dart';
import 'package:baobao/core/widgets/app_icon.dart';
import 'package:baobao/core/widgets/panel.dart';
import 'package:baobao/features/home/application/home_controller.dart';
import 'package:baobao/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Asks what would help (a joke, a kind word, a self-care idea) and returns
/// the choice, or null if dismissed.
Future<QuickAction?> showCheerSheet(BuildContext context) {
  return showModalBottomSheet<QuickAction>(
    context: context,
    isScrollControlled: true,
    builder: (context) => const _CheerSheet(),
  );
}

class _CheerSheet extends StatelessWidget {
  const _CheerSheet();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final options = [
      (QuickAction.joke, l10n.cheerJoke, Glyph.sparkle),
      (QuickAction.affirmation, l10n.cheerAffirmation, Glyph.heart),
      (QuickAction.selfCare, l10n.cheerSelfCare, Glyph.cheer),
    ];
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(Space.l, 0, Space.l, Space.l),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              header: true,
              child: Text(
                l10n.cheerTitle,
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: Space.l),
            for (final (action, label, glyph) in options) ...[
              Semantics(
                button: true,
                label: label,
                excludeSemantics: true,
                child: InkWell(
                  borderRadius: Corners.medium,
                  onTap: () => Navigator.of(context).pop(action),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: Sizes.touch + 8),
                    child: Panel(
                      child: Row(
                        children: [
                          AppIcon(glyph, size: 26, color: context.palette.primary),
                          const SizedBox(width: Space.m),
                          Expanded(
                            child: Text(label, style: Theme.of(context).textTheme.titleMedium),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: Space.s),
            ],
          ],
        ),
      ),
    );
  }
}
