import 'dart:async';
import 'dart:math';

import 'package:baobao/core/content/content_models.dart';
import 'package:baobao/core/providers.dart';
import 'package:baobao/core/widgets/character_view.dart';
import 'package:baobao/features/conversation/domain/conversation_models.dart';
import 'package:baobao/features/conversation/domain/conversation_session.dart';
import 'package:baobao/features/mood/domain/mood.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The little things BaoBao can offer at any time, free of charge.
enum QuickAction { joke, affirmation, selfCare }

/// What choosing a reply led to, so the screen knows whether to navigate.
enum ChoiceOutcome { continued, ended, openResources }

/// What BaoBao is saying and doing on the home screen right now.
class HomeState {
  const HomeState({
    required this.line,
    this.pose = CharacterPose.hello,
    this.session,
    this.lineId = 0,
  });

  /// The words in the speech bubble.
  final String line;
  final CharacterPose pose;

  /// The conversation in progress, or null when BaoBao is idle.
  final ConversationSession? session;

  /// Changes every time BaoBao says something, even the same words again.
  final int lineId;

  bool get inConversation => session != null;
  List<ConversationOption> get options => session?.current.options ?? const [];
  FeatureNudge? get nudge => session?.current.nudge;

  /// Whether the conversation in progress is the intervention.
  bool get isIntervention => session?.tree.id == ConversationTree.interventionId;
}

final homeControllerProvider = NotifierProvider<HomeController, HomeState>(HomeController.new);

/// Runs everything BaoBao says on the home screen: greetings, quick
/// pick-me-ups, and mood conversations including the intervention.
class HomeController extends Notifier<HomeState> {
  final _random = Random();

  @override
  HomeState build() {
    // A different profile starts with a fresh greeting.
    ref.watch(activeProfileIdProvider);
    final greeting = ref.read(contentProvider).scripts.greetingAt(ref.read(clockProvider).now());
    return HomeState(line: greeting.text);
  }

  int? get _profileId => ref.read(activeProfileIdProvider);

  /// Speaks the line currently shown. Called once when home first appears.
  void speakGreeting() {
    final content = ref.read(contentProvider);
    _speak(content.scripts.greetingAt(ref.read(clockProvider).now()).voice);
  }

  /// Records a mood check-in and starts the conversation it leads to.
  Future<void> checkIn(Mood mood) async {
    final profileId = _profileId;
    if (profileId == null) return;
    final content = ref.read(contentProvider);
    final outcome = await ref
        .read(moodRepositoryProvider)
        .recordCheckIn(profileId, mood, ref.read(clockProvider).now());

    final treeId = ConversationSession.treeIdFor(mood, intervene: outcome.intervene);
    final session = ConversationSession.start(content.trees[treeId]!);
    _show(session, CharacterPose.forMood(mood));
  }

  /// Follows the reply the person chose.
  Future<ChoiceOutcome> choose(ConversationOption option) async {
    final session = state.session;
    final profileId = _profileId;
    if (session == null || profileId == null) return ChoiceOutcome.ended;

    if (option.moodEffect != 0) {
      await ref.read(moodRepositoryProvider).applyEffect(profileId, option.moodEffect);
    }

    switch (session.choose(option)) {
      case ContinueStep(session: final next):
        _show(next, option.moodEffect > 0 ? CharacterPose.happy : state.pose);
        return ChoiceOutcome.continued;
      case ResourcesStep():
        // Stay on this line so the conversation is still there on return.
        return ChoiceOutcome.openResources;
      case EndStep(session: final last):
        await _finish(profileId, last);
        return ChoiceOutcome.ended;
    }
  }

  /// Ends the conversation early. Always allowed: the person is in control.
  Future<void> leaveConversation() async {
    final session = state.session;
    final profileId = _profileId;
    if (session == null || profileId == null) return;
    await _finish(profileId, session);
  }

  /// A joke, a kind word, or a self-care idea.
  void quick(QuickAction action) {
    final scripts = ref.read(contentProvider).scripts;
    final pool = switch (action) {
      QuickAction.joke => scripts.jokes,
      QuickAction.affirmation => scripts.affirmations,
      QuickAction.selfCare => scripts.selfCare,
    };
    _say(pool.pick(_random), CharacterPose.happy, session: state.session);
  }

  /// Picks a line for a quick action without changing what is on screen, for
  /// showing alongside a conversation.
  VoicedLine peek(QuickAction action) {
    final scripts = ref.read(contentProvider).scripts;
    final line = switch (action) {
      QuickAction.joke => scripts.jokes,
      QuickAction.affirmation => scripts.affirmations,
      QuickAction.selfCare => scripts.selfCare,
    }.pick(_random);
    _speak(line.voice);
    return line;
  }

  Future<void> _finish(int profileId, ConversationSession session) async {
    await ref
        .read(conversationRepositoryProvider)
        .save(profileId, session, ref.read(clockProvider).now());
    final goodbye = ref.read(contentProvider).scripts.goodbye.pick(_random);
    _say(goodbye, CharacterPose.hello);
  }

  void _show(ConversationSession session, CharacterPose pose) {
    final node = session.current;
    state = HomeState(line: node.line, pose: pose, session: session, lineId: state.lineId + 1);
    _speak(node.voice);
  }

  void _say(VoicedLine line, CharacterPose pose, {ConversationSession? session}) {
    state = HomeState(line: line.text, pose: pose, session: session, lineId: state.lineId + 1);
    _speak(line.voice);
  }

  void _speak(String? clip) {
    if (clip == null) return;
    final content = ref.read(contentProvider);
    unawaited(ref.read(audioDirectorProvider).speak(content.voiceAsset(clip)));
  }
}
