import 'package:kumayokeru_app/core/constants/map_constants.dart';

/// 存在通知機能の音源。
enum NotificationSoundType { bell, voice, mixed }

class NotificationSettings {
  const NotificationSettings({
    this.intervalSec = AudioConstants.defaultIntervalSec,
    this.soundType = NotificationSoundType.bell,
    this.volume = AudioConstants.defaultVolume,
    this.powerSavingMode = false,
  });

  final int intervalSec;
  final NotificationSoundType soundType;
  final double volume;
  final bool powerSavingMode;

  NotificationSettings copyWith({
    int? intervalSec,
    NotificationSoundType? soundType,
    double? volume,
    bool? powerSavingMode,
  }) {
    return NotificationSettings(
      intervalSec: intervalSec ?? this.intervalSec,
      soundType: soundType ?? this.soundType,
      volume: volume ?? this.volume,
      powerSavingMode: powerSavingMode ?? this.powerSavingMode,
    );
  }
}
