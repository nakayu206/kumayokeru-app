import 'package:just_audio/just_audio.dart';

import 'package:kumayokeru_app/domain/entities/notification_settings.dart';

/// 存在通知音の再生を抽象化する(テストではフェイク実装に差し替える)。
abstract interface class NotificationSoundPlayer {
  Future<void> playOnce(NotificationSoundType soundType, double volume);

  Future<void> dispose();
}

/// just_audioによる実装。
///
/// 「混合」モードで鈴+声を両方鳴らし、声は男声/女声を交互に切り替える。
/// 同じ音の単調な繰り返しはクマの馴化(音への慣れ)を招くとの調査結果を踏まえた設計
/// (assets/audio/README.md参照)。
///
/// TODO(#1): iOS(AVAudioSession .playback)・Android(フォアグラウンドサービス)での
/// バックグラウンド再生継続は、audio_serviceパッケージのAudioHandler実装と実機での
/// 複数機種検証が必要(Phase 0)。現時点ではアプリがフォアグラウンドの間のみ再生する。
class JustAudioNotificationSoundPlayer implements NotificationSoundPlayer {
  final _bellPlayer = AudioPlayer();
  final _voicePlayer = AudioPlayer();
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
  Future<void> dispose() async {
    await _bellPlayer.dispose();
    await _voicePlayer.dispose();
  }
}
