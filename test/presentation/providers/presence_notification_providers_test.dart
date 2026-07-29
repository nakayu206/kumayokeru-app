import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kumayokeru_app/domain/entities/notification_settings.dart';
import 'package:kumayokeru_app/infrastructure/notification_sound_player.dart';
import 'package:kumayokeru_app/presentation/providers/presence_notification_providers.dart';

class _FakeSoundPlayer implements NotificationSoundPlayer {
  int playCount = 0;
  NotificationSoundType? lastSoundType;
  double? lastVolume;

  @override
  Future<void> playOnce(NotificationSoundType soundType, double volume) async {
    playCount++;
    lastSoundType = soundType;
    lastVolume = volume;
  }

  @override
  Future<void> dispose() async {}
}

void main() {
  group('PresenceNotificationNotifier', () {
    test('start()前はidle状態', () {
      final notifier = PresenceNotificationNotifier(
        _FakeSoundPlayer(),
        const NotificationSettings(),
      );
      addTearDown(notifier.dispose);

      expect(notifier.state.isNotifying, false);
      expect(notifier.state.secondsUntilNextPlay, 0);
    });

    test('start()でnotifying状態になり、intervalSec秒後に自動再生する', () {
      fakeAsync((async) {
        final player = _FakeSoundPlayer();
        final notifier = PresenceNotificationNotifier(
          player,
          const NotificationSettings(intervalSec: 30),
        );
        addTearDown(notifier.dispose);

        notifier.start();
        expect(notifier.state.isNotifying, true);
        expect(notifier.state.secondsUntilNextPlay, 30);

        async.elapse(const Duration(seconds: 29));
        expect(player.playCount, 0);
        expect(notifier.state.secondsUntilNextPlay, 1);

        async.elapse(const Duration(seconds: 1));
        expect(player.playCount, 1);
        expect(notifier.state.secondsUntilNextPlay, 30);
      });
    });

    test('stop()でidle状態に戻り、タイマーが止まる', () {
      fakeAsync((async) {
        final player = _FakeSoundPlayer();
        final notifier = PresenceNotificationNotifier(
          player,
          const NotificationSettings(intervalSec: 10),
        );
        addTearDown(notifier.dispose);

        notifier.start();
        async.elapse(const Duration(seconds: 5));
        notifier.stop();

        expect(notifier.state.isNotifying, false);
        expect(notifier.state.secondsUntilNextPlay, 0);

        async.elapse(const Duration(seconds: 30));
        expect(player.playCount, 0);
      });
    });

    test('playNow()は現在の設定(音源・音量)でただちに1回再生する', () async {
      final player = _FakeSoundPlayer();
      final notifier = PresenceNotificationNotifier(
        player,
        const NotificationSettings(
          soundType: NotificationSoundType.voice,
          volume: 0.8,
        ),
      );
      addTearDown(notifier.dispose);

      await notifier.playNow();

      expect(player.playCount, 1);
      expect(player.lastSoundType, NotificationSoundType.voice);
      expect(player.lastVolume, 0.8);
    });

    test('updateSettings()で以後の再生間隔が変わる', () {
      fakeAsync((async) {
        final player = _FakeSoundPlayer();
        final notifier = PresenceNotificationNotifier(
          player,
          const NotificationSettings(intervalSec: 30),
        );
        addTearDown(notifier.dispose);

        notifier.start();
        notifier.updateSettings(const NotificationSettings(intervalSec: 5));

        // 現在のカウントダウンは変更されないが、次回以降の間隔には反映される。
        async.elapse(const Duration(seconds: 30));
        expect(player.playCount, 1);
        expect(notifier.state.secondsUntilNextPlay, 5);
      });
    });
  });
}
