import 'dart:async';

import 'package:baobao/core/audio/audio_channel.dart';

/// The volumes and switches that shape playback.
class AudioLevels {
  const AudioLevels({this.music = 0.7, this.sfx = 0.8, this.voice = 0.8, this.voiceEnabled = true});

  final double music;
  final double sfx;
  final double voice;
  final bool voiceEnabled;
}

/// Coordinates the three audio channels.
///
/// - Music loops and follows the current screen.
/// - A new voice line replaces the one playing, and music ducks underneath it.
/// - Everything goes quiet when the app is in the background.
///
/// Sound is never essential here, so playback failures are reported through
/// [onError] and otherwise ignored rather than surfaced to the person.
class AudioDirector {
  AudioDirector({
    required this._music,
    required this._voice,
    required this._sfx,
    this._levels = const AudioLevels(),
    this.onError,
  }) {
    _voiceDone = _voice.onComplete.listen((_) => _setSpeaking(false));
  }

  /// A director that makes no sound.
  factory AudioDirector.silent() =>
      AudioDirector(music: SilentChannel(), voice: SilentChannel(), sfx: SilentChannel());

  /// How much of its volume music keeps while BaoBao is speaking.
  static const duckFactor = 0.35;

  static const clickAsset = 'assets/audio/sfx/click.m4a';
  static const winAsset = 'assets/audio/sfx/win.m4a';
  static const missAsset = 'assets/audio/sfx/miss.m4a';

  final AudioChannel _music;
  final AudioChannel _voice;
  final AudioChannel _sfx;
  final void Function(Object error, StackTrace stack)? onError;
  late final StreamSubscription<void> _voiceDone;

  AudioLevels _levels;
  String? _musicAsset;
  bool _speaking = false;
  bool _suspended = false;

  /// The music asset that is playing, or would be if the app were in front.
  String? get currentMusic => _musicAsset;
  bool get isSpeaking => _speaking;

  double get _musicVolume => _levels.music * (_speaking ? duckFactor : 1);

  /// Applies volumes once at startup.
  Future<void> init() => _guard(() async {
    await _music.setVolume(_musicVolume);
    await _voice.setVolume(_levels.voice);
    await _sfx.setVolume(_levels.sfx);
  });

  /// Loops [asset]. Does nothing if it is already the current music.
  Future<void> playMusic(String asset) => _guard(() async {
    if (_musicAsset == asset) return;
    _musicAsset = asset;
    if (_suspended) return;
    await _music.play(asset, loop: true);
  });

  Future<void> stopMusic() => _guard(() async {
    _musicAsset = null;
    await _music.stop();
  });

  /// Plays a voice clip, cutting off any line still being spoken.
  Future<void> speak(String asset) => _guard(() async {
    if (!_levels.voiceEnabled || _levels.voice <= 0 || _suspended) return;
    await _setSpeaking(true);
    try {
      await _voice.play(asset);
    } catch (_) {
      await _setSpeaking(false);
      rethrow;
    }
  });

  Future<void> stopVoice() => _guard(() async {
    await _voice.stop();
    await _setSpeaking(false);
  });

  /// The tap sound for buttons.
  Future<void> click() => _guard(() async {
    if (_levels.sfx <= 0 || _suspended) return;
    await _sfx.play(clickAsset);
  });

  /// A short sound effect, such as the claw machine's win chime.
  Future<void> effect(String asset) => _guard(() async {
    if (_levels.sfx <= 0 || _suspended) return;
    await _sfx.play(asset);
  });

  Future<void> updateLevels(AudioLevels levels) => _guard(() async {
    final voiceTurnedOff = _levels.voiceEnabled && !levels.voiceEnabled;
    _levels = levels;
    await _music.setVolume(_musicVolume);
    await _voice.setVolume(levels.voice);
    await _sfx.setVolume(levels.sfx);
    if (voiceTurnedOff) {
      await _voice.stop();
      await _setSpeaking(false);
    }
  });

  /// Call when the app leaves the foreground.
  Future<void> suspend() => _guard(() async {
    if (_suspended) return;
    _suspended = true;
    await _voice.stop();
    await _setSpeaking(false);
    await _music.pause();
  });

  /// Call when the app returns to the foreground.
  Future<void> resume() => _guard(() async {
    if (!_suspended) return;
    _suspended = false;
    if (_musicAsset != null) await _music.resume();
  });

  Future<void> dispose() async {
    await _voiceDone.cancel();
    await _music.dispose();
    await _voice.dispose();
    await _sfx.dispose();
  }

  Future<void> _setSpeaking(bool speaking) async {
    if (_speaking == speaking) return;
    _speaking = speaking;
    await _music.setVolume(_musicVolume);
  }

  Future<void> _guard(Future<void> Function() action) async {
    try {
      await action();
    } catch (error, stack) {
      onError?.call(error, stack);
    }
  }
}
