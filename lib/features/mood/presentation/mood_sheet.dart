import 'package:baobao/app/theme/app_colors.dart';
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
    backgroundColor: AppColors.offWhite,
    showDragHandle: true,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (context) => const _MoodSheet(),
  );
}

class _MoodSheet extends StatelessWidget {
  const _MoodSheet();

  // Shown from brightest to heaviest, so the order itself carries no judgement
  // beyond a natural scale.
  static const _order = [Mood.happy, Mood.okay, Mood.tired, Mood.sad, Mood.anxious];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Semantics(
              header: true,
              child: Text(l10n.moodSheetTitle, style: theme.textTheme.headlineSmall),
            ),
            const SizedBox(height: 4),
            Text(l10n.moodSheetHint, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final mood in _order)
                  _MoodTile(
                    mood: mood,
                    label: moodLabel(l10n, mood),
                    onTap: () => Navigator.of(context).pop(mood),
                  ),
              ],
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
      child: Material(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: 104,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.green, width: 2),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(moodAsset(mood), width: 72, height: 72),
                const SizedBox(height: 6),
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelLarge,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
