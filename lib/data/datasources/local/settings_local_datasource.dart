import 'package:shared_preferences/shared_preferences.dart';

import 'package:kumayokeru_app/domain/entities/notification_settings.dart';
import 'package:kumayokeru_app/domain/entities/privacy_settings.dart';

/// 設定値をshared_preferencesに保存・読み込みするデータソース。
class SettingsLocalDataSource {
  static const _keyIntervalSec = 'notification_interval_sec';
  static const _keySoundType = 'notification_sound_type';
  static const _keyVolume = 'notification_volume';
  static const _keyPowerSavingMode = 'power_saving_mode';
  static const _keyLocationSharingConsent = 'location_sharing_consent_given';

  Future<NotificationSettings> load() async {
    final prefs = await SharedPreferences.getInstance();

    return NotificationSettings(
      intervalSec:
          prefs.getInt(_keyIntervalSec) ??
          const NotificationSettings().intervalSec,
      soundType: _soundTypeFromName(prefs.getString(_keySoundType)),
      volume:
          prefs.getDouble(_keyVolume) ?? const NotificationSettings().volume,
      powerSavingMode: prefs.getBool(_keyPowerSavingMode) ?? false,
    );
  }

  Future<void> save(NotificationSettings settings) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt(_keyIntervalSec, settings.intervalSec);
    await prefs.setString(_keySoundType, settings.soundType.name);
    await prefs.setDouble(_keyVolume, settings.volume);
    await prefs.setBool(_keyPowerSavingMode, settings.powerSavingMode);
  }

  NotificationSoundType _soundTypeFromName(String? name) {
    return NotificationSoundType.values.firstWhere(
      (type) => type.name == name,
      orElse: () => const NotificationSettings().soundType,
    );
  }

  Future<PrivacySettings> loadPrivacy() async {
    final prefs = await SharedPreferences.getInstance();

    return PrivacySettings(
      locationSharingConsentGiven:
          prefs.getBool(_keyLocationSharingConsent) ?? false,
    );
  }

  Future<void> savePrivacy(PrivacySettings settings) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(
      _keyLocationSharingConsent,
      settings.locationSharingConsentGiven,
    );
  }
}
