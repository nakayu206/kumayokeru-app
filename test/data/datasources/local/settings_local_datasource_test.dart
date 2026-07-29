import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:kumayokeru_app/core/constants/map_constants.dart';
import 'package:kumayokeru_app/data/datasources/local/settings_local_datasource.dart';
import 'package:kumayokeru_app/domain/entities/notification_settings.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('SettingsLocalDataSource', () {
    test('保存前はデフォルト値を返す', () async {
      final dataSource = SettingsLocalDataSource();

      final settings = await dataSource.load();

      expect(settings.intervalSec, AudioConstants.defaultIntervalSec);
      expect(settings.soundType, NotificationSoundType.bell);
      expect(settings.volume, AudioConstants.defaultVolume);
      expect(settings.powerSavingMode, false);
    });

    test('save()した値がload()で復元される', () async {
      final dataSource = SettingsLocalDataSource();
      const settings = NotificationSettings(
        intervalSec: 60,
        soundType: NotificationSoundType.voice,
        volume: 0.8,
        powerSavingMode: true,
      );

      await dataSource.save(settings);
      final loaded = await dataSource.load();

      expect(loaded.intervalSec, 60);
      expect(loaded.soundType, NotificationSoundType.voice);
      expect(loaded.volume, 0.8);
      expect(loaded.powerSavingMode, true);
    });
  });
}
