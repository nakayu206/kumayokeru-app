import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kumayokeru_app/core/constants/map_constants.dart';
import 'package:kumayokeru_app/domain/entities/notification_settings.dart';
import 'package:kumayokeru_app/infrastructure/notification_sound_player.dart';
import 'package:kumayokeru_app/infrastructure/presence_notification_audio_handler.dart';
import 'package:kumayokeru_app/infrastructure/self_check_notification_service.dart';

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

/// startKeepAliveLoop()がハング(無限に完了しない)する不具合を再現するフェイク。
/// (実機でjust_audioの初回play()呼び出しが稀に完了しないケースがあり、
/// これに再生ループ全体が引きずられてはならないことをテストする)
class _HangingKeepAliveSoundPlayer implements NotificationSoundPlayer {
  @override
  Future<void> playOnce(NotificationSoundType soundType, double volume) async {}

  @override
  Future<void> startKeepAliveLoop() => Completer<void>().future;

  @override
  Future<void> stopKeepAliveLoop() async {}

  @override
  Future<void> dispose() async {}
}

class _FakeSelfCheckNotificationService
    implements SelfCheckNotificationService {
  final scheduledDelays = <Duration>[];
  int cancelCount = 0;

  @override
  Future<void> initialize() async {}

  @override
  Future<void> scheduleCheck(Duration delay) async {
    scheduledDelays.add(delay);
  }

  @override
  Future<void> cancelCheck() async {
    cancelCount++;
  }
}

void main() {
  group('PresenceNotificationAudioHandler', () {
    test('play()前はplaying=false', () {
      final handler = PresenceNotificationAudioHandler(
        _FakeSoundPlayer(),
        _FakeSelfCheckNotificationService(),
      );
      addTearDown(handler.disposeHandler);

      expect(handler.playbackState.value.playing, false);
    });

    test('play()でplaying=trueになり、無音ループを開始し、intervalSec秒後に自動再生する', () {
      fakeAsync((async) {
        final player = _FakeSoundPlayer();
        final selfCheck = _FakeSelfCheckNotificationService();
        final handler = PresenceNotificationAudioHandler(player, selfCheck);
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
        final handler = PresenceNotificationAudioHandler(
          player,
          _FakeSelfCheckNotificationService(),
        );
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
        final handler = PresenceNotificationAudioHandler(
          player,
          _FakeSelfCheckNotificationService(),
        );
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
      final handler = PresenceNotificationAudioHandler(
        player,
        _FakeSelfCheckNotificationService(),
      );
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
        final handler = PresenceNotificationAudioHandler(
          player,
          _FakeSelfCheckNotificationService(),
        );
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

    test('play()とtickのたびにセルフチェック通知を(再生間隔+猶予)で予約する', () {
      fakeAsync((async) {
        final selfCheck = _FakeSelfCheckNotificationService();
        final handler = PresenceNotificationAudioHandler(
          _FakeSoundPlayer(),
          selfCheck,
        );
        handler.updateSettings(const NotificationSettings(intervalSec: 30));
        addTearDown(handler.disposeHandler);

        unawaited(handler.play());
        async.flushMicrotasks();

        expect(selfCheck.scheduledDelays.length, 1);
        expect(
          selfCheck.scheduledDelays.last,
          const Duration(seconds: 30 + AudioConstants.selfCheckMarginSec),
        );

        async.elapse(const Duration(seconds: 30));

        expect(selfCheck.scheduledDelays.length, 2);
      });
    });

    test('startKeepAliveLoop()がハングしてもタイマーとセルフチェック予約は継続する', () {
      fakeAsync((async) {
        final selfCheck = _FakeSelfCheckNotificationService();
        final handler = PresenceNotificationAudioHandler(
          _HangingKeepAliveSoundPlayer(),
          selfCheck,
        );
        handler.updateSettings(const NotificationSettings(intervalSec: 30));
        addTearDown(handler.disposeHandler);

        unawaited(handler.play());
        // startKeepAliveLoop()のタイムアウト猶予を経過させる。
        async.elapse(const Duration(seconds: 5));

        expect(handler.playbackState.value.playing, true);
        expect(selfCheck.scheduledDelays.length, 1);
      });
    });

    test('stop()でセルフチェック通知の予約をキャンセルする', () {
      fakeAsync((async) {
        final selfCheck = _FakeSelfCheckNotificationService();
        final handler = PresenceNotificationAudioHandler(
          _FakeSoundPlayer(),
          selfCheck,
        );
        addTearDown(handler.disposeHandler);

        unawaited(handler.play());
        async.flushMicrotasks();
        unawaited(handler.stop());
        async.flushMicrotasks();

        expect(selfCheck.cancelCount, 1);
      });
    });
  });
}
