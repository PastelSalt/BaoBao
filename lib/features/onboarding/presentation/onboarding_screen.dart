import 'dart:async';
import 'dart:math';

import 'package:baobao/core/content/content_models.dart';
import 'package:baobao/core/providers.dart';
import 'package:baobao/core/security/app_lock.dart';
import 'package:baobao/core/settings/app_settings.dart';
import 'package:baobao/core/widgets/bamboo_button.dart';
import 'package:baobao/core/widgets/bamboo_frame.dart';
import 'package:baobao/core/widgets/character_view.dart';
import 'package:baobao/core/widgets/loading_overlay.dart';
import 'package:baobao/core/widgets/speech_bubble.dart';
import 'package:baobao/core/widgets/typewriter_text.dart';
import 'package:baobao/features/economy/domain/catalog.dart';
import 'package:baobao/features/profiles/data/profile_repository.dart';
import 'package:baobao/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum _Step { welcome, promise, name, lock }

/// First-run flow: meet BaoBao, understand what it is and is not, choose a
/// name, and optionally switch on the app lock.
///
/// Nothing is saved until the last step, so backing out leaves no trace.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _name = TextEditingController();
  late final VoicedLine _welcome;

  var _step = _Step.welcome;
  bool _understands = false;
  bool _oldEnough = false;
  bool _lockAvailable = false;
  bool _lockFailed = false;
  bool _saving = false;
  bool _saveFailed = false;

  List<_Step> get _steps => [
    _Step.welcome,
    _Step.promise,
    _Step.name,
    if (_lockAvailable) _Step.lock,
  ];

  @override
  void initState() {
    super.initState();
    final content = ref.read(contentProvider);
    _welcome = content.scripts.welcome.pick(Random());
    final voice = _welcome.voice;
    if (voice != null) {
      unawaited(ref.read(audioDirectorProvider).speak(content.voiceAsset(voice)));
    }
    unawaited(_checkLock());
  }

  Future<void> _checkLock() async {
    final available = await ref.read(deviceAuthenticatorProvider).isAvailable();
    if (mounted) setState(() => _lockAvailable = available);
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _next() {
    final steps = _steps;
    final index = steps.indexOf(_step);
    if (index == steps.length - 1) {
      unawaited(_finish(enableLock: false));
    } else {
      setState(() => _step = steps[index + 1]);
    }
  }

  void _back() {
    final index = _steps.indexOf(_step);
    if (index > 0) setState(() => _step = _steps[index - 1]);
  }

  Future<void> _enableLock() async {
    final reason = AppLocalizations.of(context).onboardingLockReason;
    final ok = await ref.read(deviceAuthenticatorProvider).authenticate(reason);
    if (!mounted) return;
    if (ok) {
      await _finish(enableLock: true);
    } else {
      setState(() => _lockFailed = true);
    }
  }

  Future<void> _finish({required bool enableLock}) async {
    if (_saving) return;
    setState(() {
      _saving = true;
      _saveFailed = false;
    });
    try {
      final settings = ref.read(settingsProvider.notifier);
      final profile = await ref
          .read(profileRepositoryProvider)
          .create(_name.text, ref.read(clockProvider).now());
      await settings.setAppLockEnabled(enableLock);
      await settings.acceptConsent();
      // Last, because this is what the router waits for.
      await settings.setActiveProfile(profile.id);
    } catch (_) {
      if (mounted) {
        setState(() {
          _saving = false;
          _saveFailed = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final steps = _steps;
    final index = steps.indexOf(_step);

    return PopScope(
      canPop: index == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back();
      },
      child: Scaffold(
        body: LoadingOverlay(
          loading: _saving,
          label: l10n.onboardingFinishing,
          child: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          if (index > 0)
                            TextButton.icon(
                              onPressed: _back,
                              icon: const Icon(Icons.arrow_back_rounded),
                              label: Text(l10n.actionBack),
                            ),
                          const Spacer(),
                          Text(
                            l10n.onboardingStep(index + 1, steps.length),
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: switch (_step) {
                          _Step.welcome => _welcomeStep(l10n),
                          _Step.promise => _promiseStep(l10n),
                          _Step.name => _nameStep(l10n),
                          _Step.lock => _lockStep(l10n),
                        },
                      ),
                      if (_saveFailed) ...[
                        Semantics(
                          liveRegion: true,
                          child: Text(
                            l10n.onboardingFailed,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Theme.of(context).colorScheme.error),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      ..._actions(l10n, isLast: index == steps.length - 1),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _actions(AppLocalizations l10n, {required bool isLast}) {
    return switch (_step) {
      _Step.welcome => [BambooButton(label: l10n.actionStart, expand: true, onPressed: _next)],
      _Step.promise => [
        BambooButton(
          label: l10n.actionContinue,
          expand: true,
          onPressed: _understands && _oldEnough ? _next : null,
        ),
      ],
      _Step.name => [
        BambooButton(
          label: isLast ? l10n.actionStart : l10n.actionContinue,
          expand: true,
          onPressed: _next,
        ),
      ],
      _Step.lock => [
        BambooButton(
          label: l10n.onboardingLockEnable,
          icon: Icons.lock_rounded,
          expand: true,
          onPressed: _enableLock,
        ),
        const SizedBox(height: 8),
        BambooButton(
          label: l10n.actionSkip,
          tone: BambooButtonTone.cream,
          expand: true,
          onPressed: () => _finish(enableLock: false),
        ),
      ],
    };
  }

  Widget _welcomeStep(AppLocalizations l10n) {
    final outfit = ref.watch(catalogProvider).defaultFor(ItemSlot.outfit);
    return Column(
      children: [
        Semantics(
          header: true,
          child: Text(
            l10n.onboardingWelcomeTitle,
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 16),
        SpeechBubble(child: TypewriterText(_welcome.text)),
        Expanded(
          child: CharacterView(outfitAsset: outfit.asset, semanticLabel: l10n.characterLabel),
        ),
      ],
    );
  }

  Widget _promiseStep(AppLocalizations l10n) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            header: true,
            child: Text(
              l10n.onboardingPromiseTitle,
              style: theme.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          BambooFrame(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Point(icon: Icons.favorite_rounded, text: l10n.onboardingPromiseCompanion),
                const SizedBox(height: 12),
                _Point(icon: Icons.support_rounded, text: l10n.onboardingPromiseEmergency),
                const SizedBox(height: 12),
                _Point(icon: Icons.lock_rounded, text: l10n.onboardingPromisePrivacy),
              ],
            ),
          ),
          const SizedBox(height: 8),
          CheckboxListTile(
            value: _understands,
            onChanged: (value) => setState(() => _understands = value ?? false),
            title: Text(l10n.onboardingConfirmUnderstand),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          ),
          CheckboxListTile(
            value: _oldEnough,
            onChanged: (value) => setState(() => _oldEnough = value ?? false),
            title: Text(l10n.onboardingConfirmAge),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Widget _nameStep(AppLocalizations l10n) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            header: true,
            child: Text(
              l10n.onboardingNameTitle,
              style: theme.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _name,
            maxLength: ProfileRepository.maxNameLength,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.nickname],
            onSubmitted: (_) => _next(),
            decoration: InputDecoration(
              labelText: l10n.onboardingNameHint,
              helperText: l10n.onboardingNameHelp,
              helperMaxLines: 3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _lockStep(AppLocalizations l10n) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            header: true,
            child: Text(
              l10n.onboardingLockTitle,
              style: theme.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          Text(l10n.onboardingLockBody, textAlign: TextAlign.center),
          if (_lockFailed) ...[
            const SizedBox(height: 16),
            Semantics(
              liveRegion: true,
              child: Text(
                l10n.onboardingLockFailed,
                textAlign: TextAlign.center,
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Point extends StatelessWidget {
  const _Point({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ExcludeSemantics(child: Icon(icon, color: Theme.of(context).colorScheme.primary)),
        const SizedBox(width: 12),
        Expanded(child: Text(text)),
      ],
    );
  }
}
