import 'dart:async';

import 'package:audio_service/audio_service.dart';

import 'package:kumayokeru_app/core/constants/map_constants.dart';
import 'package:kumayokeru_app/domain/entities/notification_settings.dart';
import 'package:kumayokeru_app/infrastructure/notification_sound_player.dart';
import 'package:kumayokeru_app/infrastructure/self_check_notification_service.dart';

/// テストダブルに差し替えられるよう、audio_service非依存で切り出したインターフェース。
abstract interface class PresenceNotificationController {
  Stream<bool> get isNotifyingStream;
  Stream<int> get secondsUntilNextPlayStream;

  void updateSettings(NotificationSettings settings);

  Future<void> start();
  Future<void> stop();
  Future<void> playNow();
}

/// バックグラウンドでも再生を継続させるため、周期実行はUI側でなくここに置く。
class PresenceNotificationAudioHandler extends BaseAudioHandler
    implements PresenceNotificationController {
  PresenceNotificationAudioHandler(this._player, this._selfCheck);

  final NotificationSoundPlayer _player;
  final SelfCheckNotificationService _selfCheck;
  NotificationSettings _settings = const NotificationSettings();
  Timer? _timer;

  final _secondsUntilNextPlayController = StreamController<int>.broadcast();
  int _secondsUntilNextPlay = 0;

  @override
  Stream<bool> get isNotifyingStream =>
      playbackState.map((state) => state.playing).distinct();

  @override
  Stream<int> get secondsUntilNextPlayStream =>
      _secondsUntilNextPlayController.stream;

  @override
  void updateSettings(NotificationSettings settings) {
    _settings = settings;
  }

  @override
  Future<void> start() => play();

  @override
  Future<void> play() async {
    if (playbackState.value.playing) return;

    _secondsUntilNextPlay = _settings.intervalSec;
    _secondsUntilNextPlayController.add(_secondsUntilNextPlay);

    mediaItem.add(
      const MediaItem(
        id: 'presence_notification',
        album: 'クマヨケール',
        title: '存在通知機能: 作動中',
      ),
    );
    playbackState.add(
      playbackState.value.copyWith(
        playing: true,
        controls: [MediaControl.stop],
        processingState: AudioProcessingState.ready,
      ),
    );

    await _startKeepAliveLoopBestEffort();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    unawaited(_scheduleSelfCheck());
  }

  Future<void> _startKeepAliveLoopBestEffort() async {
    try {
      await _player.startKeepAliveLoop().timeout(const Duration(seconds: 5));
    } catch (_) {
      // 失敗しても再生ループ自体は継続する。
    }
  }

  @override
  Future<void> stop() async {
    _timer?.cancel();
    _timer = null;
    _secondsUntilNextPlay = 0;
    _secondsUntilNextPlayController.add(0);

    try {
      await _player.stopKeepAliveLoop().timeout(const Duration(seconds: 5));
    } catch (_) {
      // 失敗しても停止処理自体は継続する。
    }
    await _selfCheck.cancelCheck();
    playbackState.add(
      playbackState.value.copyWith(playing: false, controls: []),
    );
    await super.stop();
  }

  @override
  Future<void> playNow() {
    return _player.playOnce(_settings.soundType, _settings.volume);
  }

  void _tick() {
    final remaining = _secondsUntilNextPlay - 1;
    if (remaining <= 0) {
      unawaited(playNow());
      _secondsUntilNextPlay = _settings.intervalSec;
      unawaited(_scheduleSelfCheck());
    } else {
      _secondsUntilNextPlay = remaining;
    }
    _secondsUntilNextPlayController.add(_secondsUntilNextPlay);
  }

  /// 再生ループが止まった場合だけ、予約済みの通知がそのまま発火する。
  Future<void> _scheduleSelfCheck() {
    return _selfCheck.scheduleCheck(
      Duration(
        seconds: _settings.intervalSec + AudioConstants.selfCheckMarginSec,
      ),
    );
  }

  Future<void> disposeHandler() async {
    _timer?.cancel();
    await _secondsUntilNextPlayController.close();
    await _player.dispose();
  }
}
