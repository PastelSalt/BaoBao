import 'dart:ui';

import 'package:baobao/app/theme/app_palette.dart';
import 'package:baobao/app/theme/tokens.dart';
import 'package:baobao/core/content/content_models.dart';
import 'package:baobao/core/links/link_opener.dart';
import 'package:baobao/core/providers.dart';
import 'package:baobao/core/settings/app_settings.dart';
import 'package:baobao/core/widgets/app_button.dart';
import 'package:baobao/core/widgets/app_icon.dart';
import 'package:baobao/core/widgets/bamboo_dialog.dart';
import 'package:baobao/core/widgets/panel.dart';
import 'package:baobao/core/widgets/screen_scaffold.dart';
import 'package:baobao/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The region whose helplines are shown: the one chosen in the app, or else
/// the device's.
final helpCountryProvider = Provider<String?>((ref) {
  final chosen = ref.watch(settingsProvider.select((s) => s.helpCountry));
  return chosen ?? PlatformDispatcher.instance.locale.countryCode;
});

/// Where to find real help. Always reachable from Settings, and offered by
/// BaoBao when check-ins have been low for a while.
class ResourcesScreen extends ConsumerWidget {
  const ResourcesScreen({super.key});

  /// Shown in the picker for "none of the listed countries".
  static const otherCountry = 'ZZ';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final directory = ref.watch(contentProvider).helplines;
    final country = ref.watch(helpCountryProvider)?.toUpperCase();
    final known = directory.countries.containsKey(country);
    final help = directory.helpFor(country);
    final language = Localizations.localeOf(context).languageCode;

    final p = context.palette;
    return ScreenScaffold(
      title: l10n.resourcesTitle,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(Space.l, Space.xs, Space.l, Space.xl),
        children: [
          Text(l10n.resourcesIntro, style: theme.textTheme.bodyLarge),
          const SizedBox(height: Space.l),
          Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    AppIcon(Glyph.alert, color: p.alert),
                    const SizedBox(width: Space.s),
                    Expanded(
                      child: Text(l10n.resourcesEmergencyTitle, style: theme.textTheme.titleMedium),
                    ),
                  ],
                ),
                const SizedBox(height: Space.s),
                Text(
                  help.emergencyNumber == null
                      ? l10n.resourcesEmergencyUnknown
                      : l10n.resourcesEmergencyKnown(help.emergencyNumber!),
                ),
                if (help.emergencyNumber != null) ...[
                  const SizedBox(height: Space.m),
                  AppButton(
                    label: l10n.resourcesCall(help.emergencyNumber!),
                    icon: Glyph.call,
                    expand: true,
                    onPressed: () => _open(
                      context,
                      ref,
                      HelplineAction(type: HelplineActionType.call, value: help.emergencyNumber!),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: Space.xl),
          Semantics(
            header: true,
            child: Text(l10n.resourcesRegion, style: theme.textTheme.titleMedium),
          ),
          const SizedBox(height: Space.s),
          InputDecorator(
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: Space.l, vertical: Space.xs),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: known ? country : otherCountry,
                borderRadius: Corners.medium,
                dropdownColor: p.panel,
                items: [
                  for (final code in directory.countries.keys)
                    DropdownMenuItem(value: code, child: Text(_countryName(l10n, code))),
                  DropdownMenuItem(value: otherCountry, child: Text(l10n.resourcesRegionOther)),
                ],
                onChanged: (code) {
                  if (code != null) {
                    ref.read(settingsProvider.notifier).setHelpCountry(code).ignore();
                  }
                },
              ),
            ),
          ),
          if (!known) ...[
            const SizedBox(height: Space.s),
            Text(l10n.resourcesRegionOtherNote, style: theme.textTheme.bodyMedium),
          ],
          const SizedBox(height: Space.l),
          for (final line in help.lines) ...[
            _HelplineCard(
              line: line,
              language: language,
              onAction: (action) => _open(context, ref, action),
            ),
            const SizedBox(height: Space.m),
          ],
          const SizedBox(height: Space.xs),
          Text(
            l10n.resourcesDisclaimer,
            style: theme.textTheme.bodyMedium?.copyWith(color: p.inkSoft),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  static String _countryName(AppLocalizations l10n, String code) => switch (code) {
    'US' => l10n.countryUS,
    _ => code,
  };

  /// Opens [action]. If the device cannot (a tablet without a dialler, say),
  /// shows the number or address so it can be used some other way.
  static Future<void> _open(BuildContext context, WidgetRef ref, HelplineAction action) async {
    final opened = await ref.read(linkOpenerProvider).open(action.uri);
    if (opened || !context.mounted) return;
    final l10n = AppLocalizations.of(context);
    await showBambooDialog<void>(
      context: context,
      title: l10n.resourcesCannotOpenTitle,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l10n.resourcesCannotOpenBody, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          SelectableText(
            action.body == null ? action.value : '${action.value}\n“${action.body}”',
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [AppButton(label: l10n.actionClose, onPressed: () => Navigator.of(context).pop())],
    );
  }
}

class _HelplineCard extends StatelessWidget {
  const _HelplineCard({required this.line, required this.language, required this.onAction});

  final Helpline line;
  final String language;
  final ValueChanged<HelplineAction> onAction;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            header: true,
            child: Text(line.nameFor(language), style: theme.textTheme.titleMedium),
          ),
          const SizedBox(height: Space.xs),
          Text(line.descriptionFor(language)),
          const SizedBox(height: Space.m),
          for (final (i, action) in line.actions.indexed) ...[
            if (i > 0) const SizedBox(height: Space.s),
            AppButton(
              label: switch (action.type) {
                HelplineActionType.call => l10n.resourcesCall(action.value),
                HelplineActionType.sms =>
                  action.body == null
                      ? l10n.resourcesText(action.value)
                      : l10n.resourcesTextWith(action.body!, action.value),
                HelplineActionType.web => l10n.resourcesOpenWebsite,
              },
              icon: switch (action.type) {
                HelplineActionType.call => Glyph.call,
                HelplineActionType.sms => Glyph.text,
                HelplineActionType.web => Glyph.web,
              },
              kind: ButtonKind.secondary,
              expand: true,
              onPressed: () => onAction(action),
            ),
          ],
        ],
      ),
    );
  }
}
