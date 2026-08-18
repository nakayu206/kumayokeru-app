import 'package:just_audio/just_audio.dart';

import 'package:kumayokeru_app/domain/entities/notification_settings.dart';

/// 存在通知音の再生を抽象化する(テストではフェイク実装に差し替える)。
abstract interface class NotificationSoundPlayer {
  Future<void> playOnce(NotificationSoundType soundType, double volume);

  /// iOSがバックグラウンドでアプリを終了させないよう無音ループを再生する。
  Future<void> startKeepAliveLoop();

  Future<void> stopKeepAliveLoop();

  Future<void> dispose();
}

/// 「混合」モードは鈴+声を両方鳴らし、声は男女交互に切り替える。
class JustAudioNotificationSoundPlayer implements NotificationSoundPlayer {
  final _bellPlayer = AudioPlayer();
  final _voicePlayer = AudioPlayer();
  final _keepAlivePlayer = AudioPlayer();
  bool _nextVoiceIsMale = true;

  @override
  Future<void> playOnce(NotificationSoundType soundType, double volume) async {
    switch (soundType) {
      case NotificationSoundType.bell:
        await _play(_bellPlayer, 'assets/audio/bell.mp3', volume);
      case NotificationSoundType.voice:
        await _playVoice(volume);
      case NotificationSoundType.mixed:
        await _play(_bellPlayer, 'assets/audio/bell.mp3', volume);
        await _playVoice(volume);
    }
  }

  Future<void> _playVoice(double volume) async {
    final asset = _nextVoiceIsMale
        ? 'assets/audio/voice_male.mp3'
        : 'assets/audio/voice_female.mp3';
    _nextVoiceIsMale = !_nextVoiceIsMale;
    await _play(_voicePlayer, asset, volume);
  }

  Future<void> _play(AudioPlayer player, String asset, double volume) async {
    await player.setAsset(asset);
    await player.setVolume(volume);
    await player.play();
  }

  @override
  Future<void> startKeepAliveLoop() async {
    await _keepAlivePlayer.setAsset('assets/audio/silence.wav');
    await _keepAlivePlayer.setLoopMode(LoopMode.all);
    await _keepAlivePlayer.play();
  }

  @override
  Future<void> stopKeepAliveLoop() async {
    await _keepAlivePlayer.stop();
  }

  @override
  Future<void> dispose() async {
    await _bellPlayer.dispose();
    await _voicePlayer.dispose();
    await _keepAlivePlayer.dispose();
  }
}
