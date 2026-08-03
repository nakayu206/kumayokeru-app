import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:kumayokeru_app/domain/entities/notification_settings.dart';
import 'package:kumayokeru_app/infrastructure/presence_notification_audio_handler.dart';
import 'package:kumayokeru_app/presentation/providers/presence_notification_providers.dart';

/// 実際のバックグラウンド再生継続はPresenceNotificationAudioHandler側の責務
/// (test/infrastructure/presence_notification_audio_handler_test.dart参照)。
/// ここではNotifierがコントローラへ操作を委譲し、コントローラのストリームを
/// stateに反映するだけの薄いアダプタであることを検証する。
class _FakeController implements PresenceNotificationController {
  final _isNotifyingController = StreamController<bool>.broadcast();
  final _secondsController = StreamController<int>.broadcast();
  final updatedSettings = <NotificationSettings>[];
  int startCallCount = 0;
  int stopCallCount = 0;
  int playNowCallCount = 0;

  @override
  Stream<bool> get isNotifyingStream => _isNotifyingController.stream;

  @override
  Stream<int> get secondsUntilNextPlayStream => _secondsController.stream;

  @override
  void updateSettings(NotificationSettings settings) {
    updatedSettings.add(settings);
  }

  @override
  Future<void> start() async {
    startCallCount++;
  }

  @override
  Future<void> stop() async {
    stopCallCount++;
  }

  @override
  Future<void> playNow() async {
    playNowCallCount++;
  }

  void emitIsNotifying(bool value) => _isNotifyingController.add(value);
  void emitSeconds(int value) => _secondsController.add(value);

  Future<void> dispose() async {
    await _isNotifyingController.close();
    await _secondsController.close();
  }
}

void main() {
  group('PresenceNotificationNotifier', () {
    test('初期状態はidle', () {
      final controller = _FakeController();
      final notifier = PresenceNotificationNotifier(
        controller,
        const NotificationSettings(),
      );
      addTearDown(notifier.dispose);
      addTearDown(controller.dispose);

      expect(notifier.state.isNotifying, false);
      expect(notifier.state.secondsUntilNextPlay, 0);
    });

    test('コントローラのストリームの値をstateに反映する', () async {
      final controller = _FakeController();
      final notifier = PresenceNotificationNotifier(
        controller,
        const NotificationSettings(),
      );
      addTearDown(notifier.dispose);
      addTearDown(controller.dispose);

      controller.emitIsNotifying(true);
      controller.emitSeconds(30);
      await pumpEventQueue();

      expect(notifier.state.isNotifying, true);
      expect(notifier.state.secondsUntilNextPlay, 30);

      controller.emitIsNotifying(false);
      await pumpEventQueue();

      expect(notifier.state.isNotifying, false);
    });

    test('start()/stop()/playNow()はコントローラへ委譲される', () async {
      final controller = _FakeController();
      final notifier = PresenceNotificationNotifier(
        controller,
        const NotificationSettings(),
      );
      addTearDown(notifier.dispose);
      addTearDown(controller.dispose);

      notifier.start();
      expect(controller.startCallCount, 1);

      notifier.stop();
      expect(controller.stopCallCount, 1);

      await notifier.playNow();
      expect(controller.playNowCallCount, 1);
    });

    test('コンストラクタとupdateSettings()はコントローラへ設定を委譲する', () {
      final controller = _FakeController();
      const initialSettings = NotificationSettings(intervalSec: 30);
      final notifier = PresenceNotificationNotifier(
        controller,
        initialSettings,
      );
      addTearDown(notifier.dispose);
      addTearDown(controller.dispose);

      const updated = NotificationSettings(intervalSec: 5);
      notifier.updateSettings(updated);

      expect(controller.updatedSettings, [initialSettings, updated]);
    });
  });
}
