import 'package:baobao/app/router.dart';
import 'package:baobao/app/theme/app_palette.dart';
import 'package:baobao/app/theme/tokens.dart';
import 'package:baobao/core/database/app_database.dart';
import 'package:baobao/core/providers.dart';
import 'package:baobao/core/security/app_lock.dart';
import 'package:baobao/core/settings/app_settings.dart';
import 'package:baobao/core/widgets/app_button.dart';
import 'package:baobao/core/widgets/app_icon.dart';
import 'package:baobao/core/widgets/bamboo_dialog.dart';
import 'package:baobao/core/widgets/panel.dart';
import 'package:baobao/core/widgets/screen_scaffold.dart';
import 'package:baobao/features/profiles/data/profile_repository.dart';
import 'package:baobao/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Shown on the About and licences pages. Keep in step with `pubspec.yaml`.
const appVersion = '0.5.0';

final _profilesProvider = StreamProvider<List<Profile>>(
  (ref) => ref.watch(profileRepositoryProvider).watchAll(),
);

final _lockAvailableProvider = FutureProvider<bool>(
  (ref) => ref.watch(deviceAuthenticatorProvider).isAvailable(),
);

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(settingsProvider);
    final controller = ref.read(settingsProvider.notifier);
    final lockAvailable = ref.watch(_lockAvailableProvider).value ?? false;
    final profiles = ref.watch(_profilesProvider).value ?? const <Profile>[];
    final active = ref.watch(activeProfileProvider).value;

    return ScreenScaffold(
      title: l10n.settingsTitle,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(Space.l, Space.xs, Space.l, Space.xl),
        children: [
          // Help comes first so it is never buried.
          AppButton(
            label: l10n.settingsGetHelp,
            icon: Glyph.help,
            expand: true,
            onPressed: () => context.push(Routes.resources),
          ),
          _Section(
            title: l10n.settingsSound,
            children: [
              _VolumeRow(
                label: l10n.settingsMusicVolume,
                value: settings.musicVolume,
                onChanged: controller.setMusicVolume,
              ),
              _VolumeRow(
                label: l10n.settingsSfxVolume,
                value: settings.sfxVolume,
                onChanged: controller.setSfxVolume,
              ),
              _VolumeRow(
                label: l10n.settingsVoiceVolume,
                value: settings.voiceVolume,
                onChanged: settings.voiceEnabled ? controller.setVoiceVolume : null,
              ),
              SwitchListTile(
                value: settings.voiceEnabled,
                onChanged: controller.setVoiceEnabled,
                title: Text(l10n.settingsVoiceEnabled),
                subtitle: Text(l10n.settingsVoiceEnabledHint),
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
          _Section(
            title: l10n.settingsAppearance,
            children: [
              for (final (mode, label) in [
                (ThemeMode.system, l10n.settingsThemeSystem),
                (ThemeMode.light, l10n.settingsThemeLight),
                (ThemeMode.dark, l10n.settingsThemeDark),
              ])
                _ChoiceRow(
                  label: label,
                  selected: settings.themeMode == mode,
                  onTap: () => controller.setThemeMode(mode),
                ),
            ],
          ),
          _Section(
            title: l10n.settingsAccessibility,
            children: [
              SwitchListTile(
                value: settings.reducedMotion,
                onChanged: controller.setReducedMotion,
                title: Text(l10n.settingsReducedMotion),
                subtitle: Text(l10n.settingsReducedMotionHint),
                contentPadding: EdgeInsets.zero,
              ),
              SwitchListTile(
                value: settings.clawTapMode,
                onChanged: controller.setClawTapMode,
                title: Text(l10n.settingsClawTapMode),
                subtitle: Text(l10n.settingsClawTapModeHint),
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
          _Section(
            title: l10n.settingsProfile,
            children: [
              _ActionRow(
                glyph: Glyph.person,
                title: active?.displayName ?? '',
                subtitle: l10n.settingsRename,
                trailing: Glyph.edit,
                onTap: active == null ? null : () => _rename(context, ref, active),
              ),
              for (final profile in profiles)
                if (profile.id != active?.id)
                  _ActionRow(
                    glyph: Glyph.swap,
                    title: l10n.settingsSwitchTo(profile.displayName),
                    onTap: () => controller.setActiveProfile(profile.id),
                  ),
              _ActionRow(
                glyph: Glyph.add,
                title: l10n.settingsAddProfile,
                onTap: () => _addProfile(context, ref),
              ),
            ],
          ),
          _Section(
            title: l10n.settingsPrivacy,
            children: [
              Text(l10n.onboardingPromisePrivacy),
              if (lockAvailable)
                SwitchListTile(
                  value: settings.appLockEnabled,
                  onChanged: (value) => _setLock(context, ref, value),
                  title: Text(l10n.settingsAppLock),
                  subtitle: Text(l10n.settingsAppLockHint),
                  contentPadding: EdgeInsets.zero,
                ),
              const SizedBox(height: Space.s),
              AppButton(
                label: l10n.settingsDeleteData,
                icon: Glyph.delete,
                kind: ButtonKind.secondary,
                expand: true,
                onPressed: active == null ? null : () => _deleteData(context, ref, active),
              ),
            ],
          ),
          _Section(
            title: l10n.settingsAbout,
            children: [
              _ActionRow(
                glyph: Glyph.tour,
                title: l10n.settingsReplayTutorial,
                onTap: () => context.push(Routes.tutorial),
              ),
              _ActionRow(
                glyph: Glyph.info,
                title: l10n.settingsNotMedical,
                subtitle: l10n.onboardingPromiseCompanion,
              ),
              _ActionRow(
                glyph: Glyph.document,
                title: l10n.settingsLicences,
                subtitle: l10n.settingsVersion(appVersion),
                onTap: () => showLicensePage(
                  context: context,
                  applicationName: l10n.appName,
                  applicationVersion: appVersion,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Future<String?> _askName(BuildContext context, String title, String initial) {
    final l10n = AppLocalizations.of(context);
    final field = TextEditingController(text: initial);
    return showBambooDialog<String>(
      context: context,
      title: title,
      content: TextField(
        controller: field,
        autofocus: true,
        maxLength: ProfileRepository.maxNameLength,
        textCapitalization: TextCapitalization.words,
        decoration: InputDecoration(labelText: l10n.onboardingNameHint),
        onSubmitted: (value) => Navigator.of(context).pop(value),
      ),
      actions: [
        AppButton(
          label: l10n.actionCancel,
          onPressed: () => Navigator.of(context).pop(),
          kind: ButtonKind.quiet,
        ),
        AppButton(label: l10n.actionSave, onPressed: () => Navigator.of(context).pop(field.text)),
      ],
    );
  }

  static Future<void> _rename(BuildContext context, WidgetRef ref, Profile profile) async {
    final l10n = AppLocalizations.of(context);
    final name = await _askName(context, l10n.settingsRename, profile.displayName);
    if (name != null) await ref.read(profileRepositoryProvider).rename(profile.id, name);
  }

  static Future<void> _addProfile(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final name = await _askName(context, l10n.settingsAddProfile, '');
    if (name == null) return;
    final profile = await ref
        .read(profileRepositoryProvider)
        .create(name, ref.read(clockProvider).now());
    await ref.read(settingsProvider.notifier).setActiveProfile(profile.id);
  }

  /// Turning the lock on or off both need the device to confirm, so nobody
  /// else holding the phone can switch it off.
  static Future<void> _setLock(BuildContext context, WidgetRef ref, bool enable) async {
    final l10n = AppLocalizations.of(context);
    final ok = await ref
        .read(deviceAuthenticatorProvider)
        .authenticate(enable ? l10n.onboardingLockReason : l10n.settingsAppLockOffReason);
    if (ok) await ref.read(settingsProvider.notifier).setAppLockEnabled(enable);
  }

  static Future<void> _deleteData(BuildContext context, WidgetRef ref, Profile profile) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showBambooDialog<bool>(
      context: context,
      title: l10n.settingsDeleteTitle,
      content: Text(l10n.settingsDeleteBody(profile.displayName), textAlign: TextAlign.center),
      actions: [
        AppButton(
          label: l10n.actionCancel,
          onPressed: () => Navigator.of(context).pop(false),
          kind: ButtonKind.quiet,
        ),
        AppButton(
          label: l10n.settingsDeleteConfirm,
          onPressed: () => Navigator.of(context).pop(true),
          kind: ButtonKind.secondary,
        ),
      ],
    );
    if (confirmed != true) return;

    final profiles = ref.read(profileRepositoryProvider);
    final settings = ref.read(settingsProvider.notifier);
    await profiles.delete(profile.id);
    final remaining = await profiles.all();
    if (remaining.isEmpty) {
      // Nobody left: forget consent too, and start again from the welcome.
      await settings.resetPersonalState();
    } else {
      await settings.setActiveProfile(remaining.first.id);
      if (context.mounted) context.go(Routes.home);
    }
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: Space.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: Space.xs, bottom: Space.s),
            child: Semantics(
              header: true,
              child: Text(title, style: Theme.of(context).textTheme.titleLarge),
            ),
          ),
          Panel(
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
          ),
        ],
      ),
    );
  }
}

/// A tappable row with a leading icon, a title, and optional detail.
class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.glyph,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  final Glyph glyph;
  final String title;
  final String? subtitle;
  final Glyph? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: Corners.small,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: Sizes.touch + 4),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: Space.s),
          child: Row(
            children: [
              AppIcon(glyph, color: p.primary),
              const SizedBox(width: Space.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.titleMedium),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: theme.textTheme.bodyMedium?.copyWith(color: p.inkSoft),
                      ),
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: Space.s),
                AppIcon(trailing!, color: p.inkSoft),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// One choice out of several, marked with a tick when chosen.
class _ChoiceRow extends StatelessWidget {
  const _ChoiceRow({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Semantics(
      inMutuallyExclusiveGroup: true,
      selected: selected,
      button: true,
      label: label,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: Corners.small,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: Sizes.touch),
          child: Row(
            children: [
              Expanded(child: Text(label, style: Theme.of(context).textTheme.bodyLarge)),
              if (selected) AppIcon(Glyph.check, color: p.primary),
            ],
          ),
        ),
      ),
    );
  }
}

class _VolumeRow extends StatelessWidget {
  const _VolumeRow({required this.label, required this.value, required this.onChanged});

  final String label;
  final double value;
  final ValueChanged<double>? onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ExcludeSemantics(
          child: Row(
            children: [
              Expanded(child: Text(label, style: theme.textTheme.bodyLarge)),
              Text('${(value * 100).round()}%', style: theme.textTheme.titleMedium),
            ],
          ),
        ),
        Semantics(
          label: label,
          child: Slider(
            value: value,
            divisions: 20,
            label: '${(value * 100).round()}%',
            semanticFormatterCallback: (v) => '${(v * 100).round()}%',
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
