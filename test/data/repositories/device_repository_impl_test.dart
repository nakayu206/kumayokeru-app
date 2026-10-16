import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:kumayokeru_app/data/datasources/local/auth_token_local_datasource.dart';
import 'package:kumayokeru_app/data/datasources/local/pending_device_unregister_local_datasource.dart';
import 'package:kumayokeru_app/data/datasources/remote/device_remote_datasource.dart';
import 'package:kumayokeru_app/data/repositories/device_repository_impl.dart';

class _FakeTokenLocalDataSource extends AuthTokenLocalDataSource {
  String? token;

  @override
  Future<String?> readToken() async => token;
}

class _FakePendingUnregisterLocalDataSource
    extends PendingDeviceUnregisterLocalDataSource {
  PendingDeviceUnregister? pending;

  @override
  Future<void> save({
    required String deviceToken,
    required String authToken,
  }) async {
    pending = PendingDeviceUnregister(
      deviceToken: deviceToken,
      authToken: authToken,
    );
  }

  @override
  Future<PendingDeviceUnregister?> read() async => pending;

  @override
  Future<void> clear() async {
    pending = null;
  }
}

class _FakeRemoteDataSource extends DeviceRemoteDataSource {
  String? capturedAuthToken;
  String? capturedDeviceToken;
  String? capturedPlatform;
  bool shouldThrowOnUnregister = false;

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

  @override
  Future<void> unregisterToken(
    String authToken, {
    required String deviceToken,
  }) async {
    if (shouldThrowOnUnregister) {
      throw DeviceApiException('解除に失敗しました(テスト用)');
    }
    capturedAuthToken = authToken;
    capturedDeviceToken = deviceToken;
  }
}

/// 署名検証は行わない実装(decodeJwtPayload)向けの、テスト用JWT組み立て。
String _buildJwt(Map<String, dynamic> payload) {
  String encodeSegment(Object value) =>
      base64Url.encode(utf8.encode(jsonEncode(value))).replaceAll('=', '');
  final header = encodeSegment({'alg': 'none', 'typ': 'JWT'});
  final body = encodeSegment(payload);
  return '$header.$body.signature';
}

String _jwtWithExp(Duration offsetFromNow) {
  final exp =
      DateTime.now().add(offsetFromNow).millisecondsSinceEpoch ~/ 1000;
  return _buildJwt({'sub': 'user-1', 'email': 'taro@example.com', 'exp': exp});
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

    test('unregisterToken()はトークンを付けてリモートのunregisterTokenを呼び出す', () async {
      final remote = _FakeRemoteDataSource();
      final repository = DeviceRepositoryImpl(
        remoteDataSource: remote,
        tokenLocalDataSource: _FakeTokenLocalDataSource()..token = 'fake-token',
      );

      await repository.unregisterToken('fcm-token');

      expect(remote.capturedAuthToken, 'fake-token');
      expect(remote.capturedDeviceToken, 'fcm-token');
    });

    test('unregisterToken()が失敗すると、再試行用にトークンを保存してから例外を投げる', () async {
      final remote = _FakeRemoteDataSource()..shouldThrowOnUnregister = true;
      final pendingStore = _FakePendingUnregisterLocalDataSource();
      final repository = DeviceRepositoryImpl(
        remoteDataSource: remote,
        tokenLocalDataSource: _FakeTokenLocalDataSource()..token = 'fake-token',
        pendingUnregisterLocalDataSource: pendingStore,
      );

      await expectLater(
        () => repository.unregisterToken('fcm-token'),
        throwsA(isA<DeviceApiException>()),
      );

      expect(pendingStore.pending?.deviceToken, 'fcm-token');
      expect(pendingStore.pending?.authToken, 'fake-token');
    });

    test('retryPendingUnregister()は保存されたトークンが無ければ何もしない', () async {
      final remote = _FakeRemoteDataSource();
      final repository = DeviceRepositoryImpl(
        remoteDataSource: remote,
        tokenLocalDataSource: _FakeTokenLocalDataSource(),
        pendingUnregisterLocalDataSource: _FakePendingUnregisterLocalDataSource(),
      );

      await repository.retryPendingUnregister();

      expect(remote.capturedDeviceToken, isNull);
    });

    test('retryPendingUnregister()は保存されたJWTが有効なら解除を再試行し、成功したら保存を消す', () async {
      final remote = _FakeRemoteDataSource();
      final pendingStore = _FakePendingUnregisterLocalDataSource()
        ..pending = PendingDeviceUnregister(
          deviceToken: 'fcm-token',
          authToken: _jwtWithExp(const Duration(days: 1)),
        );
      final repository = DeviceRepositoryImpl(
        remoteDataSource: remote,
        tokenLocalDataSource: _FakeTokenLocalDataSource(),
        pendingUnregisterLocalDataSource: pendingStore,
      );

      await repository.retryPendingUnregister();

      expect(remote.capturedDeviceToken, 'fcm-token');
      expect(pendingStore.pending, isNull);
    });

    test(
      'retryPendingUnregister()は保存されたJWTが期限切れでも、現在ログイン中の有効なJWTで再試行する',
      () async {
        final remote = _FakeRemoteDataSource();
        final pendingStore = _FakePendingUnregisterLocalDataSource()
          ..pending = PendingDeviceUnregister(
            deviceToken: 'fcm-token',
            authToken: _jwtWithExp(const Duration(days: -1)),
          );
        final currentToken = _jwtWithExp(const Duration(days: 1));
        final repository = DeviceRepositoryImpl(
          remoteDataSource: remote,
          tokenLocalDataSource: _FakeTokenLocalDataSource()
            ..token = currentToken,
          pendingUnregisterLocalDataSource: pendingStore,
        );

        await repository.retryPendingUnregister();

        expect(remote.capturedAuthToken, currentToken);
        expect(remote.capturedDeviceToken, 'fcm-token');
        expect(pendingStore.pending, isNull);
      },
    );

    test(
      'retryPendingUnregister()は保存JWTも現在のJWTも期限切れなら再試行せず、保存を残す(次回起動時に再試行)',
      () async {
        final remote = _FakeRemoteDataSource();
        final pendingStore = _FakePendingUnregisterLocalDataSource()
          ..pending = PendingDeviceUnregister(
            deviceToken: 'fcm-token',
            authToken: _jwtWithExp(const Duration(days: -1)),
          );
        final repository = DeviceRepositoryImpl(
          remoteDataSource: remote,
          tokenLocalDataSource: _FakeTokenLocalDataSource()
            ..token = _jwtWithExp(const Duration(days: -1)),
          pendingUnregisterLocalDataSource: pendingStore,
        );

        await repository.retryPendingUnregister();

        expect(remote.capturedDeviceToken, isNull);
        expect(pendingStore.pending, isNotNull);
      },
    );
  });
}
