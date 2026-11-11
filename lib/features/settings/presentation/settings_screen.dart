import 'package:baobao/app/router.dart';
import 'package:baobao/app/theme/app_colors.dart';
import 'package:baobao/core/database/app_database.dart';
import 'package:baobao/core/providers.dart';
import 'package:baobao/core/security/app_lock.dart';
import 'package:baobao/core/settings/app_settings.dart';
import 'package:baobao/core/widgets/bamboo_button.dart';
import 'package:baobao/core/widgets/bamboo_dialog.dart';
import 'package:baobao/core/widgets/bamboo_frame.dart';
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
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          // Help comes first so it is never buried.
          BambooButton(
            label: l10n.settingsGetHelp,
            icon: Icons.support_rounded,
            tone: BambooButtonTone.tan,
            expand: true,
            onPressed: () => context.push(Routes.resources),
          ),
          _Section(
            title: l10n.settingsSound,
            children: [
              _VolumeSlider(
                label: l10n.settingsMusicVolume,
                value: settings.musicVolume,
                onChanged: controller.setMusicVolume,
              ),
              _VolumeSlider(
                label: l10n.settingsSfxVolume,
                value: settings.sfxVolume,
                onChanged: controller.setSfxVolume,
              ),
              _VolumeSlider(
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
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.person_rounded, color: AppColors.ink),
                title: Text(active?.displayName ?? ''),
                subtitle: Text(l10n.settingsRename),
                trailing: const Icon(Icons.edit_rounded, color: AppColors.ink),
                onTap: active == null ? null : () => _rename(context, ref, active),
              ),
              for (final profile in profiles)
                if (profile.id != active?.id)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.swap_horiz_rounded, color: AppColors.ink),
                    title: Text(l10n.settingsSwitchTo(profile.displayName)),
                    onTap: () => controller.setActiveProfile(profile.id),
                  ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.person_add_rounded, color: AppColors.ink),
                title: Text(l10n.settingsAddProfile),
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
              const SizedBox(height: 8),
              BambooButton(
                label: l10n.settingsDeleteData,
                icon: Icons.delete_forever_rounded,
                tone: BambooButtonTone.cream,
                expand: true,
                onPressed: active == null ? null : () => _deleteData(context, ref, active),
              ),
            ],
          ),
          _Section(
            title: l10n.settingsAbout,
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.school_rounded, color: AppColors.ink),
                title: Text(l10n.settingsReplayTutorial),
                onTap: () => context.push(Routes.tutorial),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.info_rounded, color: AppColors.ink),
                title: Text(l10n.settingsNotMedical),
                subtitle: Text(l10n.onboardingPromiseCompanion),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.description_rounded, color: AppColors.ink),
                title: Text(l10n.settingsLicences),
                subtitle: Text(l10n.settingsVersion(appVersion)),
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
        BambooButton(
          label: l10n.actionCancel,
          tone: BambooButtonTone.cream,
          onPressed: () => Navigator.of(context).pop(),
        ),
        BambooButton(
          label: l10n.actionSave,
          onPressed: () => Navigator.of(context).pop(field.text),
        ),
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
        BambooButton(label: l10n.actionCancel, onPressed: () => Navigator.of(context).pop(false)),
        BambooButton(
          label: l10n.settingsDeleteConfirm,
          tone: BambooButtonTone.cream,
          onPressed: () => Navigator.of(context).pop(true),
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
      padding: const EdgeInsets.only(top: 16),
      child: BambooFrame(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              header: true,
              child: Text(title, style: Theme.of(context).textTheme.titleLarge),
            ),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _VolumeSlider extends StatelessWidget {
  const _VolumeSlider({required this.label, required this.value, required this.onChanged});

  final String label;
  final double value;
  final ValueChanged<double>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ExcludeSemantics(child: Text(label)),
        Semantics(
          label: label,
          child: Slider(
            value: value,
            divisions: 20,
            label: '${(value * 100).round()}%',
            semanticFormatterCallback: (v) => '${(v * 100).round()}%',
            activeColor: AppColors.deepGreen,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
