import 'dart:async';

import 'package:just_audio/just_audio.dart';

/// One independent stream of sound. The app has three: music, voice, effects.
abstract interface class AudioChannel {
  /// Starts [asset] from the beginning, replacing whatever was playing.
  Future<void> play(String asset, {bool loop = false});
  Future<void> stop();
  Future<void> pause();
  Future<void> resume();
  Future<void> setVolume(double volume);

  /// Fires each time a non-looping sound plays to its end.
  Stream<void> get onComplete;
  Future<void> dispose();
}

/// A channel that makes no sound. Used in tests and as a safe default.
class SilentChannel implements AudioChannel {
  @override
  Future<void> play(String asset, {bool loop = false}) async {}
  @override
  Future<void> stop() async {}
  @override
  Future<void> pause() async {}
  @override
  Future<void> resume() async {}
  @override
  Future<void> setVolume(double volume) async {}
  @override
  Stream<void> get onComplete => const Stream.empty();
  @override
  Future<void> dispose() async {}
}

/// An [AudioChannel] backed by a `just_audio` player.
class JustAudioChannel implements AudioChannel {
  /// Only the [primary] channel (music) claims the device's audio focus and
  /// reacts to interruptions such as phone calls. If every channel did, a
  /// voice line starting would count as an interruption and pause the music.
  JustAudioChannel({bool primary = false})
    : _player = AudioPlayer(
        handleInterruptions: primary,
        handleAudioSessionActivation: primary,
        androidApplyAudioAttributes: primary,
      );

  final AudioPlayer _player;
  String? _loaded;

  @override
  Future<void> play(String asset, {bool loop = false}) async {
    if (_loaded == asset) {
      await _player.seek(Duration.zero);
    } else {
      // Clear first so a failed load is not mistaken for a loaded asset.
      _loaded = null;
      await _player.setAsset(asset);
      _loaded = asset;
    }
    await _player.setLoopMode(loop ? LoopMode.one : LoopMode.off);
    // play() completes when playback ends, so it must not be awaited here.
    unawaited(_player.play());
  }

  @override
  Future<void> stop() => _player.stop();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> resume() async {
    if (_loaded != null) unawaited(_player.play());
  }

  @override
  Future<void> setVolume(double volume) => _player.setVolume(volume);

  @override
  Stream<void> get onComplete => _player.processingStateStream
      .where((state) => state == ProcessingState.completed)
      .map((_) {});

  @override
  Future<void> dispose() => _player.dispose();
}
