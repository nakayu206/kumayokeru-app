import 'package:kumayokeru_app/data/datasources/local/settings_local_datasource.dart';
import 'package:kumayokeru_app/domain/entities/notification_settings.dart';
import 'package:kumayokeru_app/domain/entities/privacy_settings.dart';
import 'package:kumayokeru_app/domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl({SettingsLocalDataSource? localDataSource})
    : _localDataSource = localDataSource ?? SettingsLocalDataSource();

  final SettingsLocalDataSource _localDataSource;

  @override
  Future<NotificationSettings> loadNotificationSettings() {
    return _localDataSource.load();
  }

  @override
  Future<void> saveNotificationSettings(NotificationSettings settings) {
    return _localDataSource.save(settings);
  }

  @override
  Future<PrivacySettings> loadPrivacySettings() {
    return _localDataSource.loadPrivacy();
  }

  @override
  Future<void> savePrivacySettings(PrivacySettings settings) {
    return _localDataSource.savePrivacy(settings);
  }
}
