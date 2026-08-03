import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kumayokeru_app/domain/entities/notification_settings.dart';
import 'package:kumayokeru_app/infrastructure/notification_sound_player.dart';
import 'package:kumayokeru_app/infrastructure/presence_notification_audio_handler.dart';

class _FakeSoundPlayer implements NotificationSoundPlayer {
  int playCount = 0;
  NotificationSoundType? lastSoundType;
  double? lastVolume;
  int keepAliveStartCount = 0;
  int keepAliveStopCount = 0;

  @override
  Future<void> playOnce(NotificationSoundType soundType, double volume) async {
    playCount++;
    lastSoundType = soundType;
    lastVolume = volume;
  }

  @override
  Future<void> startKeepAliveLoop() async {
    keepAliveStartCount++;
  }

  @override
  Future<void> stopKeepAliveLoop() async {
    keepAliveStopCount++;
  }

  @override
  Future<void> dispose() async {}
}

void main() {
  group('PresenceNotificationAudioHandler', () {
    test('play()前はplaying=false', () {
      final handler = PresenceNotificationAudioHandler(_FakeSoundPlayer());
      addTearDown(handler.disposeHandler);

      expect(handler.playbackState.value.playing, false);
    });

    test('play()でplaying=trueになり、無音ループを開始し、intervalSec秒後に自動再生する', () {
      fakeAsync((async) {
        final player = _FakeSoundPlayer();
        final handler = PresenceNotificationAudioHandler(player);
        handler.updateSettings(const NotificationSettings(intervalSec: 30));
        addTearDown(handler.disposeHandler);

        final seconds = <int>[];
        handler.secondsUntilNextPlayStream.listen(seconds.add);

        unawaited(handler.play());
        async.flushMicrotasks();

        expect(handler.playbackState.value.playing, true);
        expect(player.keepAliveStartCount, 1);
        expect(seconds.last, 30);

        async.elapse(const Duration(seconds: 29));
        expect(player.playCount, 0);
        expect(seconds.last, 1);

        async.elapse(const Duration(seconds: 1));
        expect(player.playCount, 1);
        expect(seconds.last, 30);
      });
    });

    test('play()を連続で呼んでも二重起動しない', () {
      fakeAsync((async) {
        final player = _FakeSoundPlayer();
        final handler = PresenceNotificationAudioHandler(player);
        addTearDown(handler.disposeHandler);

        unawaited(handler.play());
        async.flushMicrotasks();
        unawaited(handler.play());
        async.flushMicrotasks();

        expect(player.keepAliveStartCount, 1);
      });
    });

    test('stop()でplaying=falseに戻り、タイマーと無音ループが止まる', () {
      fakeAsync((async) {
        final player = _FakeSoundPlayer();
        final handler = PresenceNotificationAudioHandler(player);
        handler.updateSettings(const NotificationSettings(intervalSec: 10));
        addTearDown(handler.disposeHandler);

        unawaited(handler.play());
        async.flushMicrotasks();
        async.elapse(const Duration(seconds: 5));

        unawaited(handler.stop());
        async.flushMicrotasks();

        expect(handler.playbackState.value.playing, false);
        expect(player.keepAliveStopCount, 1);

        async.elapse(const Duration(seconds: 30));
        expect(player.playCount, 0);
      });
    });

    test('playNow()は現在の設定(音源・音量)でただちに1回再生する', () async {
      final player = _FakeSoundPlayer();
      final handler = PresenceNotificationAudioHandler(player);
      handler.updateSettings(
        const NotificationSettings(
          soundType: NotificationSoundType.voice,
          volume: 0.8,
        ),
      );
      addTearDown(handler.disposeHandler);

      await handler.playNow();

      expect(player.playCount, 1);
      expect(player.lastSoundType, NotificationSoundType.voice);
      expect(player.lastVolume, 0.8);
    });

    test('updateSettings()で以後の再生間隔が変わる', () {
      fakeAsync((async) {
        final player = _FakeSoundPlayer();
        final handler = PresenceNotificationAudioHandler(player);
        handler.updateSettings(const NotificationSettings(intervalSec: 30));
        addTearDown(handler.disposeHandler);

        final seconds = <int>[];
        handler.secondsUntilNextPlayStream.listen(seconds.add);

        unawaited(handler.play());
        async.flushMicrotasks();
        handler.updateSettings(const NotificationSettings(intervalSec: 5));

        async.elapse(const Duration(seconds: 30));
        expect(player.playCount, 1);
        expect(seconds.last, 5);
      });
    });
  });
}
