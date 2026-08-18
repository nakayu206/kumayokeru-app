import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kumayokeru_app/data/repositories/settings_repository_impl.dart';
import 'package:kumayokeru_app/domain/entities/notification_settings.dart';
import 'package:kumayokeru_app/domain/entities/privacy_settings.dart';
import 'package:kumayokeru_app/domain/repositories/settings_repository.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepositoryImpl();
});

/// 存在通知機能の設定値。アプリ起動時にshared_preferencesから復元し、
/// 変更のたびに保存する。
class AudioSettingsNotifier extends StateNotifier<NotificationSettings> {
  AudioSettingsNotifier(this._repository)
    : super(const NotificationSettings()) {
    _loadInitial();
  }

  final SettingsRepository _repository;

  Future<void> _loadInitial() async {
    state = await _repository.loadNotificationSettings();
  }

  Future<void> setIntervalSec(int intervalSec) =>
      _update(state.copyWith(intervalSec: intervalSec));

  Future<void> setSoundType(NotificationSoundType soundType) =>
      _update(state.copyWith(soundType: soundType));

  Future<void> setVolume(double volume) =>
      _update(state.copyWith(volume: volume));

  Future<void> setPowerSavingMode(bool powerSavingMode) =>
      _update(state.copyWith(powerSavingMode: powerSavingMode));

  Future<void> _update(NotificationSettings next) async {
    state = next;
    await _repository.saveNotificationSettings(next);
  }
}

final audioSettingsProvider =
    StateNotifierProvider<AudioSettingsNotifier, NotificationSettings>((ref) {
      return AudioSettingsNotifier(ref.watch(settingsRepositoryProvider));
    });

/// プライバシー関連の同意状態。アプリ起動時にshared_preferencesから復元し、
/// 変更のたびに保存する。
class PrivacySettingsNotifier extends StateNotifier<PrivacySettings> {
  PrivacySettingsNotifier(this._repository) : super(const PrivacySettings()) {
    _loadInitial();
  }

  final SettingsRepository _repository;

  Future<void> _loadInitial() async {
    state = await _repository.loadPrivacySettings();
  }

  Future<void> setLocationSharingConsentGiven(bool consentGiven) async {
    state = state.copyWith(locationSharingConsentGiven: consentGiven);
    await _repository.savePrivacySettings(state);
  }
}

final privacySettingsProvider =
    StateNotifierProvider<PrivacySettingsNotifier, PrivacySettings>((ref) {
      return PrivacySettingsNotifier(ref.watch(settingsRepositoryProvider));
    });
