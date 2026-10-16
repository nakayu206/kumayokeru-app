import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kumayokeru_app/data/datasources/remote/device_remote_datasource.dart';
import 'package:kumayokeru_app/domain/repositories/device_repository.dart';
import 'package:kumayokeru_app/infrastructure/push_notification_service.dart';
import 'package:kumayokeru_app/infrastructure/push_notification_setup.dart';

class _FakePushNotificationService implements PushNotificationService {
  Future<void> Function(String token)? capturedOnToken;
  String? currentToken;

  @override
  Future<void> initialize({
    required Future<void> Function(String token) onToken,
  }) async {
    capturedOnToken = onToken;
  }

  @override
  Future<String?> getCurrentToken() async => currentToken;
}

class _FakeDeviceRepository implements DeviceRepository {
  String? registeredToken;
  String? registeredPlatform;
  String? unregisteredToken;
  bool shouldThrow = false;
  bool shouldThrowOnUnregister = false;
  bool shouldHangOnUnregister = false;
  bool retryPendingUnregisterCalled = false;

  @override
  Future<void> registerToken(String deviceToken, String platform) async {
    if (shouldThrow) {
      throw DeviceApiException('登録に失敗しました(テスト用)');
    }
    registeredToken = deviceToken;
    registeredPlatform = platform;
  }

  @override
  Future<void> unregisterToken(String deviceToken) async {
    if (shouldHangOnUnregister) {
      // 通信がタイムアウトする状況を模すため、永遠に完了しないFutureを返す。
      return Completer<void>().future;
    }
    if (shouldThrowOnUnregister) {
      throw DeviceApiException('解除に失敗しました(テスト用)');
    }
    unregisteredToken = deviceToken;
  }

  @override
  Future<void> retryPendingUnregister() async {
    retryPendingUnregisterCalled = true;
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

    test('unregisterCurrentDevice()はAndroidなら現在のトークンをリポジトリから解除する', () async {
      final service = _FakePushNotificationService()
        ..currentToken = 'fake-fcm-token';
      final repository = _FakeDeviceRepository();
      final setup = PushNotificationSetup(
        service,
        repository,
        isAndroid: () => true,
      );

      await setup.unregisterCurrentDevice();

      expect(repository.unregisteredToken, 'fake-fcm-token');
    });

    test('unregisterCurrentDevice()はAndroid以外では何もしない', () async {
      final service = _FakePushNotificationService()
        ..currentToken = 'fake-fcm-token';
      final repository = _FakeDeviceRepository();
      final setup = PushNotificationSetup(
        service,
        repository,
        isAndroid: () => false,
      );

      await setup.unregisterCurrentDevice();

      expect(repository.unregisteredToken, isNull);
    });

    test('unregisterCurrentDevice()は解除に失敗しても例外を外に投げない', () async {
      final service = _FakePushNotificationService()
        ..currentToken = 'fake-fcm-token';
      final repository = _FakeDeviceRepository()
        ..shouldThrowOnUnregister = true;
      final setup = PushNotificationSetup(
        service,
        repository,
        isAndroid: () => true,
      );

      await setup.unregisterCurrentDevice();
    });

    test('unregisterCurrentDevice()は通信が長引いてもタイムアウトしてログアウトをブロックしない', () {
      fakeAsync((async) {
        final service = _FakePushNotificationService()
          ..currentToken = 'fake-fcm-token';
        final repository = _FakeDeviceRepository()
          ..shouldHangOnUnregister = true;
        final setup = PushNotificationSetup(
          service,
          repository,
          isAndroid: () => true,
        );

        var completed = false;
        unawaited(setup.unregisterCurrentDevice().then((_) => completed = true));

        async.elapse(const Duration(seconds: 10));

        expect(completed, isTrue);
      });
    });

    test('retryPendingUnregister()はAndroidならリポジトリの再試行を呼び出す', () async {
      final service = _FakePushNotificationService();
      final repository = _FakeDeviceRepository();
      final setup = PushNotificationSetup(
        service,
        repository,
        isAndroid: () => true,
      );

      await setup.retryPendingUnregister();

      expect(repository.retryPendingUnregisterCalled, isTrue);
    });

    test('retryPendingUnregister()はAndroid以外では何もしない', () async {
      final service = _FakePushNotificationService();
      final repository = _FakeDeviceRepository();
      final setup = PushNotificationSetup(
        service,
        repository,
        isAndroid: () => false,
      );

      await setup.retryPendingUnregister();

      expect(repository.retryPendingUnregisterCalled, isFalse);
    });
  });
}
