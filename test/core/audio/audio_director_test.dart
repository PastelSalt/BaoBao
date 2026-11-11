import 'dart:async';

import 'package:baobao/core/audio/audio_channel.dart';
import 'package:baobao/core/audio/audio_director.dart';
import 'package:flutter_test/flutter_test.dart';

/// Records what it is asked to do instead of making sound.
class FakeChannel implements AudioChannel {
  final log = <String>[];
  final _complete = StreamController<void>.broadcast(sync: true);
  double volume = 1;
  bool failNextPlay = false;

  void finish() => _complete.add(null);

  @override
  Future<void> play(String asset, {bool loop = false}) async {
    if (failNextPlay) {
      failNextPlay = false;
      throw StateError('cannot load $asset');
    }
    log.add('play $asset${loop ? ' loop' : ''}');
  }

  @override
  Future<void> stop() async => log.add('stop');
  @override
  Future<void> pause() async => log.add('pause');
  @override
  Future<void> resume() async => log.add('resume');
  @override
  Future<void> setVolume(double value) async => volume = value;
  @override
  Stream<void> get onComplete => _complete.stream;
  @override
  Future<void> dispose() => _complete.close();
}

void main() {
  late FakeChannel music, voice, sfx;
  late List<Object> errors;

  AudioDirector director([AudioLevels levels = const AudioLevels()]) => AudioDirector(
    music: music,
    voice: voice,
    sfx: sfx,
    levels: levels,
    onError: (error, _) => errors.add(error),
  );

  setUp(() {
    music = FakeChannel();
    voice = FakeChannel();
    sfx = FakeChannel();
    errors = [];
  });

  test('init applies the configured volumes', () async {
    await director(const AudioLevels(music: 0.5, sfx: 0.4, voice: 0.3)).init();
    expect((music.volume, sfx.volume, voice.volume), (0.5, 0.4, 0.3));
  });

  group('music', () {
    test('loops, and asking for the same track again does not restart it', () async {
      final d = director();
      await d.playMusic('a.mp3');
      await d.playMusic('a.mp3');
      expect(music.log, ['play a.mp3 loop']);
      expect(d.currentMusic, 'a.mp3');
    });

    test('switches track', () async {
      final d = director();
      await d.playMusic('a.mp3');
      await d.playMusic('b.mp3');
      expect(music.log, ['play a.mp3 loop', 'play b.mp3 loop']);
    });

    test('can be stopped and started again', () async {
      final d = director();
      await d.playMusic('a.mp3');
      await d.stopMusic();
      await d.playMusic('a.mp3');
      expect(music.log, ['play a.mp3 loop', 'stop', 'play a.mp3 loop']);
    });
  });

  group('voice', () {
    test('ducks the music while speaking and restores it afterwards', () async {
      final d = director(const AudioLevels(music: 0.8));
      await d.init();

      await d.speak('line.m4a');
      expect(d.isSpeaking, isTrue);
      expect(music.volume, closeTo(0.8 * AudioDirector.duckFactor, 1e-9));

      voice.finish();
      expect(d.isSpeaking, isFalse);
      expect(music.volume, 0.8);
    });

    test('a new line replaces the one playing', () async {
      final d = director();
      await d.speak('one.m4a');
      await d.speak('two.m4a');
      expect(voice.log, ['play one.m4a', 'play two.m4a']);
      expect(d.isSpeaking, isTrue);
    });

    test('says nothing when voice is switched off or muted', () async {
      await director(const AudioLevels(voiceEnabled: false)).speak('line.m4a');
      await director(const AudioLevels(voice: 0)).speak('line.m4a');
      expect(voice.log, isEmpty);
    });

    test('switching voice off mid-line stops it and restores the music', () async {
      final d = director(const AudioLevels(music: 0.6));
      await d.speak('line.m4a');
      await d.updateLevels(const AudioLevels(music: 0.6, voiceEnabled: false));
      expect(voice.log.last, 'stop');
      expect(music.volume, 0.6);
    });

    test('a clip that fails to load is reported and does not leave music ducked', () async {
      final d = director(const AudioLevels(music: 0.7));
      voice.failNextPlay = true;
      await d.speak('missing.m4a');
      expect(errors, hasLength(1));
      expect(d.isSpeaking, isFalse);
      expect(music.volume, 0.7);
    });
  });

  group('effects', () {
    test('the click plays unless effects are muted', () async {
      await director().click();
      expect(sfx.log, ['play ${AudioDirector.clickAsset}']);

      sfx.log.clear();
      await director(const AudioLevels(sfx: 0)).click();
      expect(sfx.log, isEmpty);
    });
  });

  group('backgrounding', () {
    test('pauses music and stops voice, then resumes music', () async {
      final d = director();
      await d.playMusic('a.mp3');
      await d.speak('line.m4a');

      await d.suspend();
      expect(music.log.last, 'pause');
      expect(voice.log.last, 'stop');
      expect(d.isSpeaking, isFalse);

      await d.resume();
      expect(music.log.last, 'resume');
    });

    test('nothing plays while in the background', () async {
      final d = director();
      await d.suspend();
      await d.speak('line.m4a');
      await d.click();
      await d.playMusic('a.mp3');
      expect(voice.log, ['stop']);
      expect(sfx.log, isEmpty);
      expect(music.log, ['pause']);

      // The track chosen while away starts on return.
      await d.resume();
      expect(music.log.last, 'resume');
      expect(d.currentMusic, 'a.mp3');
    });

    test('resume without suspend does nothing', () async {
      await director().resume();
      expect(music.log, isEmpty);
    });
  });
}
