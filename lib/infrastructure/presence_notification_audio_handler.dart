import 'dart:async';

import 'package:audio_service/audio_service.dart';

import 'package:kumayokeru_app/domain/entities/notification_settings.dart';
import 'package:kumayokeru_app/infrastructure/notification_sound_player.dart';

/// 存在通知機能のUI(Riverpod)側から見た操作インターフェース。
///
/// [PresenceNotificationAudioHandler]の実装をテストダブルに差し替えられるように、
/// audio_service非依存の薄いインターフェースとして切り出したもの。
abstract interface class PresenceNotificationController {
  Stream<bool> get isNotifyingStream;
  Stream<int> get secondsUntilNextPlayStream;

  void updateSettings(NotificationSettings settings);

  Future<void> start();
  Future<void> stop();
  Future<void> playNow();
}

/// 存在通知機能の再生ループ(Timer.periodic)を保持するAudioHandler。
///
/// Android/iOSでアプリがバックグラウンドに回っても再生を継続させるため、
/// 周期実行のロジックをUI(Riverpod)側ではなくこのハンドラ側に置く
/// (audio_serviceがAndroidのフォアグラウンドサービス化・iOSの
/// UIBackgroundModes(audio)有効化を担う)。UI側は[isNotifyingStream]/
/// [secondsUntilNextPlayStream]を購読するだけの薄いアダプタとする。
class PresenceNotificationAudioHandler extends BaseAudioHandler
    implements PresenceNotificationController {
  PresenceNotificationAudioHandler(this._player);

  final NotificationSoundPlayer _player;
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

    await _player.startKeepAliveLoop();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  @override
  Future<void> stop() async {
    _timer?.cancel();
    _timer = null;
    _secondsUntilNextPlay = 0;
    _secondsUntilNextPlayController.add(0);

    await _player.stopKeepAliveLoop();
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
    } else {
      _secondsUntilNextPlay = remaining;
    }
    _secondsUntilNextPlayController.add(_secondsUntilNextPlay);
  }

  Future<void> disposeHandler() async {
    _timer?.cancel();
    await _secondsUntilNextPlayController.close();
    await _player.dispose();
  }
}
