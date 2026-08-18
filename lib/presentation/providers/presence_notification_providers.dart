import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kumayokeru_app/domain/entities/notification_settings.dart';
import 'package:kumayokeru_app/infrastructure/presence_notification_audio_handler.dart';
import 'package:kumayokeru_app/presentation/providers/settings_providers.dart';

/// main_*.dartでAudioService.init()により生成した実体を
/// overrideWithValue()すること前提のプレースホルダー。
final presenceNotificationControllerProvider =
    Provider<PresenceNotificationController>((ref) {
      throw UnimplementedError(
        'main()でpresenceNotificationControllerProvider.overrideWithValue()してください',
      );
    });

class PresenceNotificationState {
  const PresenceNotificationState({
    this.isNotifying = false,
    this.secondsUntilNextPlay = 0,
  });

  final bool isNotifying;
  final int secondsUntilNextPlay;

  PresenceNotificationState copyWith({
    bool? isNotifying,
    int? secondsUntilNextPlay,
  }) {
    return PresenceNotificationState(
      isNotifying: isNotifying ?? this.isNotifying,
      secondsUntilNextPlay: secondsUntilNextPlay ?? this.secondsUntilNextPlay,
    );
  }
}

/// コントローラを購読しUIへ橋渡しするアダプタ。状態はコントローラ側が保持する。
class PresenceNotificationNotifier
    extends StateNotifier<PresenceNotificationState> {
  PresenceNotificationNotifier(this._controller, NotificationSettings settings)
    : super(const PresenceNotificationState()) {
    _controller.updateSettings(settings);
    _isNotifyingSubscription = _controller.isNotifyingStream.listen((
      isNotifying,
    ) {
      state = state.copyWith(isNotifying: isNotifying);
    });
    _secondsSubscription = _controller.secondsUntilNextPlayStream.listen((
      seconds,
    ) {
      state = state.copyWith(secondsUntilNextPlay: seconds);
    });
  }

  final PresenceNotificationController _controller;
  late final StreamSubscription<bool> _isNotifyingSubscription;
  late final StreamSubscription<int> _secondsSubscription;

  /// 設定変更(再生間隔・音源・音量)を反映する。
  void updateSettings(NotificationSettings settings) {
    _controller.updateSettings(settings);
  }

  void start() {
    unawaited(_controller.start());
  }

  void stop() {
    unawaited(_controller.stop());
  }

  Future<void> playNow() => _controller.playNow();

  @override
  void dispose() {
    unawaited(_isNotifyingSubscription.cancel());
    unawaited(_secondsSubscription.cancel());
    super.dispose();
  }
}

final presenceNotificationProvider =
    StateNotifierProvider<
      PresenceNotificationNotifier,
      PresenceNotificationState
    >((ref) {
      final notifier = PresenceNotificationNotifier(
        ref.watch(presenceNotificationControllerProvider),
        ref.read(audioSettingsProvider),
      );
      ref.listen(audioSettingsProvider, (_, next) {
        notifier.updateSettings(next);
      });
      return notifier;
    });
