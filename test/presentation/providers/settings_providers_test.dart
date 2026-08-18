import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kumayokeru_app/domain/entities/notification_settings.dart';
import 'package:kumayokeru_app/domain/entities/privacy_settings.dart';
import 'package:kumayokeru_app/domain/repositories/settings_repository.dart';
import 'package:kumayokeru_app/presentation/providers/settings_providers.dart';

class _FakeSettingsRepository implements SettingsRepository {
  NotificationSettings stored = const NotificationSettings();
  int saveCallCount = 0;
  PrivacySettings storedPrivacy = const PrivacySettings();
  int savePrivacyCallCount = 0;

  @override
  Future<NotificationSettings> loadNotificationSettings() async => stored;

  @override
  Future<void> saveNotificationSettings(NotificationSettings settings) async {
    stored = settings;
    saveCallCount++;
  }

  @override
  Future<PrivacySettings> loadPrivacySettings() async => storedPrivacy;

  @override
  Future<void> savePrivacySettings(PrivacySettings settings) async {
    storedPrivacy = settings;
    savePrivacyCallCount++;
  }
}

void main() {
  group('AudioSettingsNotifier', () {
    test('起動時にリポジトリから設定を読み込む', () async {
      final fakeRepository = _FakeSettingsRepository()
        ..stored = const NotificationSettings(
          intervalSec: 60,
          powerSavingMode: true,
        );
      final container = ProviderContainer(
        overrides: [
          settingsRepositoryProvider.overrideWithValue(fakeRepository),
        ],
      );
      addTearDown(container.dispose);

      // readでNotifierを生成し、コンストラクタ内で開始した非同期読み込みの完了を待つ。
      container.read(audioSettingsProvider);
      await pumpEventQueue();

      final settings = container.read(audioSettingsProvider);
      expect(settings.intervalSec, 60);
      expect(settings.powerSavingMode, true);
    });

    test('setIntervalSec()でstateが更新され、リポジトリに保存される', () async {
      final fakeRepository = _FakeSettingsRepository();
      final container = ProviderContainer(
        overrides: [
          settingsRepositoryProvider.overrideWithValue(fakeRepository),
        ],
      );
      addTearDown(container.dispose);
      container.read(audioSettingsProvider);
      await pumpEventQueue();

      await container.read(audioSettingsProvider.notifier).setIntervalSec(120);

      expect(container.read(audioSettingsProvider).intervalSec, 120);
      expect(fakeRepository.stored.intervalSec, 120);
      expect(fakeRepository.saveCallCount, 1);
    });

    test('setSoundType()でstateが更新される', () async {
      final fakeRepository = _FakeSettingsRepository();
      final container = ProviderContainer(
        overrides: [
          settingsRepositoryProvider.overrideWithValue(fakeRepository),
        ],
      );
      addTearDown(container.dispose);
      container.read(audioSettingsProvider);
      await pumpEventQueue();

      await container
          .read(audioSettingsProvider.notifier)
          .setSoundType(NotificationSoundType.voice);

      expect(
        container.read(audioSettingsProvider).soundType,
        NotificationSoundType.voice,
      );
    });
  });

  group('PrivacySettingsNotifier', () {
    test('起動時はデフォルトで同意していない状態', () async {
      final fakeRepository = _FakeSettingsRepository();
      final container = ProviderContainer(
        overrides: [
          settingsRepositoryProvider.overrideWithValue(fakeRepository),
        ],
      );
      addTearDown(container.dispose);

      container.read(privacySettingsProvider);
      await pumpEventQueue();

      expect(
        container.read(privacySettingsProvider).locationSharingConsentGiven,
        false,
      );
    });

    test('起動時にリポジトリから同意状態を読み込む', () async {
      final fakeRepository = _FakeSettingsRepository()
        ..storedPrivacy = const PrivacySettings(
          locationSharingConsentGiven: true,
        );
      final container = ProviderContainer(
        overrides: [
          settingsRepositoryProvider.overrideWithValue(fakeRepository),
        ],
      );
      addTearDown(container.dispose);

      container.read(privacySettingsProvider);
      await pumpEventQueue();

      expect(
        container.read(privacySettingsProvider).locationSharingConsentGiven,
        true,
      );
    });

    test('setLocationSharingConsentGiven()でstateが更新され、リポジトリに保存される', () async {
      final fakeRepository = _FakeSettingsRepository();
      final container = ProviderContainer(
        overrides: [
          settingsRepositoryProvider.overrideWithValue(fakeRepository),
        ],
      );
      addTearDown(container.dispose);
      container.read(privacySettingsProvider);
      await pumpEventQueue();

      await container
          .read(privacySettingsProvider.notifier)
          .setLocationSharingConsentGiven(true);

      expect(
        container.read(privacySettingsProvider).locationSharingConsentGiven,
        true,
      );
      expect(fakeRepository.storedPrivacy.locationSharingConsentGiven, true);
      expect(fakeRepository.savePrivacyCallCount, 1);
    });
  });
}
