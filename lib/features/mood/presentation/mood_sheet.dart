import 'package:baobao/app/theme/app_palette.dart';
import 'package:baobao/app/theme/tokens.dart';
import 'package:baobao/core/widgets/panel.dart';
import 'package:baobao/features/mood/domain/mood.dart';
import 'package:baobao/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// The name shown for each mood.
String moodLabel(AppLocalizations l10n, Mood mood) => switch (mood) {
  Mood.happy => l10n.moodHappy,
  Mood.okay => l10n.moodOkay,
  Mood.sad => l10n.moodSad,
  Mood.anxious => l10n.moodAnxious,
  Mood.tired => l10n.moodTired,
};

String moodAsset(Mood mood) => 'assets/images/moods/${mood.name}.webp';

/// Asks "How are you feeling?" and returns the mood picked, or null if the
/// sheet was dismissed.
Future<Mood?> showMoodSheet(BuildContext context) {
  return showModalBottomSheet<Mood>(
    context: context,
    isScrollControlled: true,
    builder: (context) => const _MoodSheet(),
  );
}

class _MoodSheet extends StatelessWidget {
  const _MoodSheet();

  // From brightest to heaviest, a natural scale that carries no judgement.
  static const _order = [Mood.happy, Mood.okay, Mood.tired, Mood.sad, Mood.anxious];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scale = MediaQuery.textScalerOf(context).scale(1);
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(Space.l, 0, Space.l, Space.l),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Semantics(
              header: true,
              child: Text(
                l10n.moodSheetTitle,
                style: theme.textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: Space.xs),
            Text(
              l10n.moodSheetHint,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: Space.l),
            LayoutBuilder(
              builder: (context, box) {
                // Two or three to a row, so every name fits on one line.
                final columns = scale > 1.3 || box.maxWidth < 330 ? 2 : 3;
                const gap = Space.m;
                final width = (box.maxWidth - gap * (columns - 1)) / columns;
                return Wrap(
                  alignment: WrapAlignment.center,
                  spacing: gap,
                  runSpacing: gap,
                  children: [
                    for (final mood in _order)
                      SizedBox(
                        width: width - 0.5,
                        child: _MoodTile(
                          mood: mood,
                          label: moodLabel(l10n, mood),
                          onTap: () => Navigator.of(context).pop(mood),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _MoodTile extends StatelessWidget {
  const _MoodTile({required this.mood, required this.label, required this.onTap});

  final Mood mood;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: Corners.medium,
        child: Panel(
          padding: const EdgeInsets.symmetric(horizontal: Space.s, vertical: Space.m),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(moodAsset(mood), width: 64, height: 64),
              const SizedBox(height: Space.s),
              Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(color: context.palette.ink),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
