import 'package:kumayokeru_app/domain/entities/notification_settings.dart';
import 'package:kumayokeru_app/domain/entities/privacy_settings.dart';

/// 設定値の永続化を抽象化するリポジトリ。
abstract interface class SettingsRepository {
  Future<NotificationSettings> loadNotificationSettings();

  Future<void> saveNotificationSettings(NotificationSettings settings);

  Future<PrivacySettings> loadPrivacySettings();

  Future<void> savePrivacySettings(PrivacySettings settings);
}
