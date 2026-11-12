import 'dart:async';
import 'dart:math';

import 'package:baobao/core/audio/audio_director.dart';
import 'package:baobao/core/content/app_content.dart';
import 'package:baobao/core/content/content_models.dart';
import 'package:baobao/features/claw_machine/data/claw_repository.dart';
import 'package:baobao/features/claw_machine/domain/claw_game.dart';
import 'package:baobao/features/claw_machine/domain/claw_tries.dart';
import 'package:clock/clock.dart';
import 'package:flutter/foundation.dart';

/// Something the screen should tell the player that BaoBao has no voiced line for.
enum ClawNotice { noTries, boughtTry, dailyLimit, notEnoughStars }

/// Connects the [ClawGame] rules to tries, payouts, voice and the screen.
///
/// Time only moves when [advance] is called, so the whole round can be driven
/// by a ticker in the app and by plain numbers in tests.
class ClawController extends ChangeNotifier {
  ClawController({
    required this.profileId,
    required this._repository,
    required this._audio,
    required this._content,
    required this._clock,
    Random? random,
    ClawGame? game,
  }) : game = game ?? ClawGame(random: random) {
    _say(ClawLine.intro);
  }

  /// How long the result stays on screen before the next round begins.
  static const resultPause = Duration(milliseconds: 1800);

  final int profileId;
  final ClawGame game;
  final ClawRepository _repository;
  final AudioDirector _audio;
  final AppContent _content;
  final Clock _clock;

  /// What BaoBao is saying.
  VoicedLine? line;

  /// A message with no voiced line, shown instead of [line] until the next one.
  ClawNotice? notice;

  /// The outcome of the round that just ended, while it is on screen.
  ClawResult? shownResult;

  bool _starting = false;
  bool _dropRequested = false;
  bool _resultHandled = false;
  Duration _sinceFinished = Duration.zero;
  bool _disposed = false;

  bool get canStart => game.phase == ClawPhase.idle && !_starting;

  /// Press: spend a try and start the claw sweeping.
  Future<void> press() async {
    if (!canStart) return;
    _starting = true;
    _dropRequested = false;
    final tries = await _repository.consumeTry(profileId, _clock.now());
    _starting = false;
    if (_disposed) return;
    if (tries == null) {
      _notify(ClawNotice.noTries);
      return;
    }
    game.startMoving();
    _say(ClawLine.aim);
    // The finger may already have lifted while the try was being spent.
    if (_dropRequested) game.drop();
    notifyListeners();
  }

  /// Release: drop the claw where it is.
  void release() {
    if (_starting) {
      _dropRequested = true;
    } else {
      game.drop();
    }
    notifyListeners();
  }

  /// One-touch control: starts the claw, or drops it if it is already moving.
  Future<void> tap() async {
    if (game.phase == ClawPhase.moving) {
      release();
    } else {
      await press();
    }
  }

  /// Moves the game forward by [dt].
  void advance(Duration dt) {
    if (game.phase == ClawPhase.idle) return;
    game.tick(dt);

    if (game.phase == ClawPhase.finished) {
      if (!_resultHandled) {
        _resultHandled = true;
        _sinceFinished = Duration.zero;
        final result = game.result ?? const ClawResult.miss();
        shownResult = result;
        unawaited(_audio.effect(result.won ? AudioDirector.winAsset : AudioDirector.missAsset));
        _say(result.won ? ClawLine.win : ClawLine.miss);
        unawaited(_repository.recordResult(profileId, result, _clock.now()));
      } else {
        _sinceFinished += dt;
        if (_sinceFinished >= resultPause) {
          game.nextRound();
          _resultHandled = false;
          shownResult = null;
        }
      }
    }
    notifyListeners();
  }

  /// Buys one extra try with ✷.
  Future<void> buyTry() async {
    final result = await _repository.buyTry(profileId, _clock.now());
    if (_disposed) return;
    _notify(switch (result) {
      BuyTryResult.bought => ClawNotice.boughtTry,
      BuyTryResult.dailyLimitReached => ClawNotice.dailyLimit,
      BuyTryResult.insufficientFunds => ClawNotice.notEnoughStars,
    });
  }

  void _say(ClawLine which) {
    final next = _content.scripts.clawMachine[which]!;
    line = next;
    notice = null;
    final voice = next.voice;
    if (voice != null) unawaited(_audio.speak(_content.voiceAsset(voice)));
  }

  void _notify(ClawNotice value) {
    notice = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
