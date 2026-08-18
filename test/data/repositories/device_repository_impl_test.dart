import 'package:flutter_test/flutter_test.dart';

import 'package:kumayokeru_app/data/datasources/local/auth_token_local_datasource.dart';
import 'package:kumayokeru_app/data/datasources/remote/device_remote_datasource.dart';
import 'package:kumayokeru_app/data/repositories/device_repository_impl.dart';

class _FakeTokenLocalDataSource extends AuthTokenLocalDataSource {
  String? token;

  @override
  Future<String?> readToken() async => token;
}

class _FakeRemoteDataSource extends DeviceRemoteDataSource {
  String? capturedAuthToken;
  String? capturedDeviceToken;
  String? capturedPlatform;

  @override
  Future<void> registerToken(
    String authToken, {
    required String deviceToken,
    required String platform,
  }) async {
    capturedAuthToken = authToken;
    capturedDeviceToken = deviceToken;
    capturedPlatform = platform;
  }
}

void main() {
  group('DeviceRepositoryImpl', () {
    test('未ログイン(トークンなし)の場合はDeviceApiExceptionを投げる', () async {
      final repository = DeviceRepositoryImpl(
        remoteDataSource: _FakeRemoteDataSource(),
        tokenLocalDataSource: _FakeTokenLocalDataSource(),
      );

      expect(
        () => repository.registerToken('fcm-token', 'android'),
        throwsA(isA<DeviceApiException>()),
      );
    });

    test('ログイン済みならトークンを付けてリモートのregisterTokenを呼び出す', () async {
      final remote = _FakeRemoteDataSource();
      final repository = DeviceRepositoryImpl(
        remoteDataSource: remote,
        tokenLocalDataSource: _FakeTokenLocalDataSource()..token = 'fake-token',
      );

      await repository.registerToken('fcm-token', 'android');

      expect(remote.capturedAuthToken, 'fake-token');
      expect(remote.capturedDeviceToken, 'fcm-token');
      expect(remote.capturedPlatform, 'android');
    });
  });
}
