import 'package:flutter_test/flutter_test.dart';

import 'package:kumayokeru_app/data/datasources/remote/device_remote_datasource.dart';
import 'package:kumayokeru_app/domain/repositories/device_repository.dart';
import 'package:kumayokeru_app/infrastructure/push_notification_service.dart';
import 'package:kumayokeru_app/infrastructure/push_notification_setup.dart';

class _FakePushNotificationService implements PushNotificationService {
  Future<void> Function(String token)? capturedOnToken;

  @override
  Future<void> initialize({
    required Future<void> Function(String token) onToken,
  }) async {
    capturedOnToken = onToken;
  }
}

class _FakeDeviceRepository implements DeviceRepository {
  String? registeredToken;
  String? registeredPlatform;
  bool shouldThrow = false;

  @override
  Future<void> registerToken(String deviceToken, String platform) async {
    if (shouldThrow) {
      throw DeviceApiException('登録に失敗しました(テスト用)');
    }
    registeredToken = deviceToken;
    registeredPlatform = platform;
  }
}

void main() {
  group('PushNotificationSetup', () {
    test('Androidならサービスを初期化し、トークン受信時にリポジトリへ登録する', () async {
      final service = _FakePushNotificationService();
      final repository = _FakeDeviceRepository();
      final setup = PushNotificationSetup(
        service,
        repository,
        isAndroid: () => true,
      );

      await setup.start();
      await service.capturedOnToken!('fake-fcm-token');

      expect(repository.registeredToken, 'fake-fcm-token');
      expect(repository.registeredPlatform, 'android');
    });

    test('デバイストークンの登録に失敗しても例外を外に投げない', () async {
      final service = _FakePushNotificationService();
      final repository = _FakeDeviceRepository()..shouldThrow = true;
      final setup = PushNotificationSetup(
        service,
        repository,
        isAndroid: () => true,
      );

      await setup.start();

      await service.capturedOnToken!('fake-fcm-token');
    });

    test('Android以外では何も初期化しない(iOSはAPNs直接接続方針でFCM未対応)', () async {
      final service = _FakePushNotificationService();
      final repository = _FakeDeviceRepository();
      final setup = PushNotificationSetup(
        service,
        repository,
        isAndroid: () => false,
      );

      await setup.start();

      expect(service.capturedOnToken, isNull);
    });
  });
}
