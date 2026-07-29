import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kumayokeru_app/domain/entities/notification_settings.dart';
import 'package:kumayokeru_app/infrastructure/notification_sound_player.dart';
import 'package:kumayokeru_app/presentation/providers/settings_providers.dart';

final notificationSoundPlayerProvider = Provider<NotificationSoundPlayer>((
  ref,
) {
  final player = JustAudioNotificationSoundPlayer();
  ref.onDispose(() => unawaited(player.dispose()));
  return player;
});

/// 存在通知機能の再生状態(仕様書セクション8の状態遷移: idle/notifying)。
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

class PresenceNotificationNotifier
    extends StateNotifier<PresenceNotificationState> {
  PresenceNotificationNotifier(this._player, this._settings)
    : super(const PresenceNotificationState());

  final NotificationSoundPlayer _player;
  NotificationSettings _settings;
  Timer? _timer;

  /// 設定変更(再生間隔・音源・音量)を反映する。
  void updateSettings(NotificationSettings settings) {
    _settings = settings;
  }

  void start() {
    if (state.isNotifying) return;
    state = PresenceNotificationState(
      isNotifying: true,
      secondsUntilNextPlay: _settings.intervalSec,
    );
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    state = const PresenceNotificationState();
  }

  Future<void> playNow() {
    return _player.playOnce(_settings.soundType, _settings.volume);
  }

  void _tick() {
    final remaining = state.secondsUntilNextPlay - 1;
    if (remaining <= 0) {
      unawaited(playNow());
      state = state.copyWith(secondsUntilNextPlay: _settings.intervalSec);
    } else {
      state = state.copyWith(secondsUntilNextPlay: remaining);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final presenceNotificationProvider =
    StateNotifierProvider<
      PresenceNotificationNotifier,
      PresenceNotificationState
    >((ref) {
      final notifier = PresenceNotificationNotifier(
        ref.watch(notificationSoundPlayerProvider),
        ref.read(audioSettingsProvider),
      );
      ref.listen(audioSettingsProvider, (_, next) {
        notifier.updateSettings(next);
      });
      return notifier;
    });
