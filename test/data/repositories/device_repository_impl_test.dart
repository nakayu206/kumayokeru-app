import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:kumayokeru_app/data/datasources/local/auth_token_local_datasource.dart';
import 'package:kumayokeru_app/data/datasources/local/device_registration_local_datasource.dart';
import 'package:kumayokeru_app/data/datasources/local/pending_device_unregister_local_datasource.dart';
import 'package:kumayokeru_app/data/datasources/remote/device_remote_datasource.dart';
import 'package:kumayokeru_app/data/repositories/device_repository_impl.dart';

class _FakeTokenLocalDataSource extends AuthTokenLocalDataSource {
  String? token;

  @override
  Future<String?> readToken() async => token;
}

class _FakeRegistrationLocalDataSource
    extends DeviceRegistrationLocalDataSource {
  String? deviceToken;
  String? registrationId;

  @override
  Future<void> save({
    required String deviceToken,
    required String registrationId,
  }) async {
    this.deviceToken = deviceToken;
    this.registrationId = registrationId;
  }

  @override
  Future<String?> readRegistrationId(String deviceToken) async {
    if (this.deviceToken != deviceToken) return null;
    return registrationId;
  }
}

class _FakePendingUnregisterLocalDataSource
    extends PendingDeviceUnregisterLocalDataSource {
  PendingDeviceUnregister? pending;

  @override
  Future<void> save({
    required String deviceToken,
    required String registrationId,
    required String authToken,
  }) async {
    pending = PendingDeviceUnregister(
      deviceToken: deviceToken,
      registrationId: registrationId,
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

/// サーバー側のdevice_tokensテーブルを簡易的に模す。登録のたびに登録IDを更新し、
/// 解除はそのIDが現在の登録と一致する場合のみ成功させる(routes/devices.tsの
/// 世代チェックと同じ挙動)。
class _FakeRemoteDataSource extends DeviceRemoteDataSource {
  String? capturedAuthToken;
  String? capturedDeviceToken;
  String? capturedPlatform;
  bool shouldThrowOnUnregister = false;
  Completer<void>? hangingUnregisterCompleter;
  Completer<void>? hangingRegisterCompleter;
  String nextRegistrationId = 'reg-1';

  final Map<String, String> serverRegistrations = {};
  final List<String> unregisterAttempts = [];

  @override
  Future<String> registerToken(
    String authToken, {
    required String deviceToken,
    required String platform,
  }) async {
    if (hangingRegisterCompleter != null) {
      // 登録の応答が遅延している状況(例: 通信待ちの間にログアウトされる)を模す。
      await hangingRegisterCompleter!.future;
    }
    capturedAuthToken = authToken;
    capturedDeviceToken = deviceToken;
    capturedPlatform = platform;
    serverRegistrations[deviceToken] = nextRegistrationId;
    return nextRegistrationId;
  }

  @override
  Future<void> unregisterToken(
    String authToken, {
    required String deviceToken,
    required String registrationId,
  }) async {
    if (hangingUnregisterCompleter != null) {
      // 通信が完了する前にrepository側の退避処理が済んでいるかを検証するため、
      // テストから明示的にcomplete()するまで待たせる。完了後は実際の通信と同様に
      // (遅延していた)このリクエストがサーバーに届いたものとして処理を続ける。
      await hangingUnregisterCompleter!.future;
    }
    if (shouldThrowOnUnregister) {
      throw DeviceApiException('解除に失敗しました(テスト用)');
    }
    capturedAuthToken = authToken;
    capturedDeviceToken = deviceToken;
    unregisterAttempts.add(registrationId);
    // 世代チェック: サーバー側の現在の登録IDと一致しない場合は何もしない
    // (実際のAPIは404を返すが、例外は投げない=解決済みとして扱う)。
    if (serverRegistrations[deviceToken] == registrationId) {
      serverRegistrations.remove(deviceToken);
    }
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
  final exp = DateTime.now().add(offsetFromNow).millisecondsSinceEpoch ~/ 1000;
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

    test('ログイン済みならトークンを付けてリモートのregisterTokenを呼び出し、登録IDを保存する', () async {
      final remote = _FakeRemoteDataSource()..nextRegistrationId = 'reg-1';
      final registrationStore = _FakeRegistrationLocalDataSource();
      final repository = DeviceRepositoryImpl(
        remoteDataSource: remote,
        tokenLocalDataSource: _FakeTokenLocalDataSource()..token = 'fake-token',
        registrationLocalDataSource: registrationStore,
      );

      await repository.registerToken('fcm-token', 'android');

      expect(remote.capturedAuthToken, 'fake-token');
      expect(remote.capturedDeviceToken, 'fcm-token');
      expect(remote.capturedPlatform, 'android');
      expect(registrationStore.deviceToken, 'fcm-token');
      expect(registrationStore.registrationId, 'reg-1');
    });

    test('unregisterToken()は保存済みの登録IDを付けてリモートのunregisterTokenを呼び出す', () async {
      final remote = _FakeRemoteDataSource();
      final repository = DeviceRepositoryImpl(
        remoteDataSource: remote,
        tokenLocalDataSource: _FakeTokenLocalDataSource()..token = 'fake-token',
        registrationLocalDataSource: _FakeRegistrationLocalDataSource()
          ..deviceToken = 'fcm-token'
          ..registrationId = 'reg-1',
        pendingUnregisterLocalDataSource:
            _FakePendingUnregisterLocalDataSource(),
      );

      await repository.unregisterToken('fcm-token');

      expect(remote.capturedAuthToken, 'fake-token');
      expect(remote.capturedDeviceToken, 'fcm-token');
      expect(remote.unregisterAttempts, ['reg-1']);
    });

    test('unregisterToken()はこの端末で登録した記録が無ければ何もしない(通信しない)', () async {
      final remote = _FakeRemoteDataSource();
      final repository = DeviceRepositoryImpl(
        remoteDataSource: remote,
        tokenLocalDataSource: _FakeTokenLocalDataSource()..token = 'fake-token',
        registrationLocalDataSource: _FakeRegistrationLocalDataSource(),
      );

      await repository.unregisterToken('fcm-token');

      expect(remote.capturedDeviceToken, isNull);
    });

    test('unregisterToken()が失敗すると、再試行用に登録ID付きで保存してから例外を投げる', () async {
      final remote = _FakeRemoteDataSource()..shouldThrowOnUnregister = true;
      final pendingStore = _FakePendingUnregisterLocalDataSource();
      final repository = DeviceRepositoryImpl(
        remoteDataSource: remote,
        tokenLocalDataSource: _FakeTokenLocalDataSource()..token = 'fake-token',
        registrationLocalDataSource: _FakeRegistrationLocalDataSource()
          ..deviceToken = 'fcm-token'
          ..registrationId = 'reg-1',
        pendingUnregisterLocalDataSource: pendingStore,
      );

      await expectLater(
        () => repository.unregisterToken('fcm-token'),
        throwsA(isA<DeviceApiException>()),
      );

      expect(pendingStore.pending?.deviceToken, 'fcm-token');
      expect(pendingStore.pending?.registrationId, 'reg-1');
      expect(pendingStore.pending?.authToken, 'fake-token');
    });

    test('unregisterToken()は通信が完了するより先に退避済みになっている(タイムアウトで取り逃さないため)', () async {
      final hangingCompleter = Completer<void>();
      final remote = _FakeRemoteDataSource()
        ..hangingUnregisterCompleter = hangingCompleter;
      final pendingStore = _FakePendingUnregisterLocalDataSource();
      final repository = DeviceRepositoryImpl(
        remoteDataSource: remote,
        tokenLocalDataSource: _FakeTokenLocalDataSource()..token = 'fake-token',
        registrationLocalDataSource: _FakeRegistrationLocalDataSource()
          ..deviceToken = 'fcm-token'
          ..registrationId = 'reg-1',
        pendingUnregisterLocalDataSource: pendingStore,
      );

      final future = repository.unregisterToken('fcm-token');
      await pumpEventQueue();

      // 通信がまだ終わっていなくても、呼び出し側のタイムアウトやアプリ終了で
      // 待てなくなった場合に備えて、退避は既に完了していなければならない。
      expect(pendingStore.pending?.deviceToken, 'fcm-token');
      expect(pendingStore.pending?.registrationId, 'reg-1');

      hangingCompleter.complete();
      await future;

      // 無事成功したので退避は消える。
      expect(pendingStore.pending, isNull);
    });

    test('解除が遅延している間に同じトークンが再登録されても、古い登録IDでの解除は'
        '新しい登録を消さない(世代チェック)。再試行後も新しい登録は残る', () async {
      final remote = _FakeRemoteDataSource()..nextRegistrationId = 'reg-1';
      final registrationStore = _FakeRegistrationLocalDataSource();
      final pendingStore = _FakePendingUnregisterLocalDataSource();
      final repository = DeviceRepositoryImpl(
        remoteDataSource: remote,
        tokenLocalDataSource: _FakeTokenLocalDataSource()..token = 'fake-token',
        registrationLocalDataSource: registrationStore,
        pendingUnregisterLocalDataSource: pendingStore,
        // 直列化キューが前の操作(ここでは解除)の完了を待ちすぎないよう、
        // テストでは待機上限を短くする(実時間で5秒待たせないため)。
        operationQueueTimeout: const Duration(milliseconds: 10),
      );

      // 1. 最初の登録(reg-1)。
      await repository.registerToken('fcm-token', 'android');

      // 2. 解除がタイムアウトする状況を模す(退避だけ完了し、通信は未解決のまま)。
      final hangingCompleter = Completer<void>();
      remote.hangingUnregisterCompleter = hangingCompleter;
      final unregisterFuture = repository.unregisterToken('fcm-token');
      await pumpEventQueue();

      // 3. タイムアウト後、起動処理が進んで同じトークンが再登録される(reg-2)。
      // (直列化キューは、前の解除がまだ終わっていなくても上の待機上限で
      // 先に進む。これにより、サーバー側の世代チェックだけが安全網として残る
      // 状況を意図的に作っている。)
      remote.hangingUnregisterCompleter = null;
      remote.nextRegistrationId = 'reg-2';
      await repository.registerToken('fcm-token', 'android');
      expect(remote.serverRegistrations['fcm-token'], 'reg-2');

      // 4. 遅延していた古い解除(reg-1宛て)がようやく完了する。
      hangingCompleter.complete();
      await unregisterFuture;

      // 新しい登録(reg-2)は消えずに残っている。
      expect(remote.serverRegistrations['fcm-token'], 'reg-2');
      expect(remote.unregisterAttempts, ['reg-1']);

      // 5. 念のため再試行(pending)も実行してみるが、古い世代は既に無効なので
      // 新しい登録には影響しない。
      await repository.retryPendingUnregister();
      expect(remote.serverRegistrations['fcm-token'], 'reg-2');
    });

    test('登録応答が遅延している間にログアウト(解除)が呼ばれても、登録完了後に'
        '解除が正しく実行され、ログアウト済みアカウントに通知登録が残らない', () async {
      final remote = _FakeRemoteDataSource()..nextRegistrationId = 'reg-1';
      final registrationStore = _FakeRegistrationLocalDataSource();
      final pendingStore = _FakePendingUnregisterLocalDataSource();
      final repository = DeviceRepositoryImpl(
        remoteDataSource: remote,
        tokenLocalDataSource: _FakeTokenLocalDataSource()..token = 'fake-token',
        registrationLocalDataSource: registrationStore,
        pendingUnregisterLocalDataSource: pendingStore,
      );

      // 1. 登録(POST)がまだサーバーから応答を受け取っていない状態を作る。
      final hangingRegister = Completer<void>();
      remote.hangingRegisterCompleter = hangingRegister;
      final registerFuture = repository.registerToken('fcm-token', 'android');
      await pumpEventQueue();

      // 2. その間にログアウトが解除を試みる。登録が完了するまでは、この端末で
      // 登録した記録がまだ無い(保存前)ため、ここでは即座には完了しない
      // (register側の処理が終わるまでキューで待つ)。
      final unregisterFuture = repository.unregisterToken('fcm-token');
      await pumpEventQueue();
      expect(remote.capturedDeviceToken, isNull);
      expect(registrationStore.registrationId, isNull);

      // 3. 登録の応答がようやく到着する。
      hangingRegister.complete();
      await registerFuture;
      expect(registrationStore.registrationId, 'reg-1');
      expect(remote.serverRegistrations['fcm-token'], 'reg-1');

      // 4. キューで待っていた解除が、今保存されたばかりの登録IDで実行される。
      await unregisterFuture;

      // ログアウト済みのアカウントに通知登録が残っていない。
      expect(remote.serverRegistrations['fcm-token'], isNull);
      expect(remote.unregisterAttempts, ['reg-1']);
    });

    test('retryPendingUnregister()は保存されたトークンが無ければ何もしない', () async {
      final remote = _FakeRemoteDataSource();
      final repository = DeviceRepositoryImpl(
        remoteDataSource: remote,
        tokenLocalDataSource: _FakeTokenLocalDataSource(),
        pendingUnregisterLocalDataSource:
            _FakePendingUnregisterLocalDataSource(),
      );

      await repository.retryPendingUnregister();

      expect(remote.capturedDeviceToken, isNull);
    });

    test('retryPendingUnregister()は保存されたJWTが有効なら解除を再試行し、成功したら保存を消す', () async {
      final remote = _FakeRemoteDataSource();
      final pendingStore = _FakePendingUnregisterLocalDataSource()
        ..pending = PendingDeviceUnregister(
          deviceToken: 'fcm-token',
          registrationId: 'reg-1',
          authToken: _jwtWithExp(const Duration(days: 1)),
        );
      final repository = DeviceRepositoryImpl(
        remoteDataSource: remote,
        tokenLocalDataSource: _FakeTokenLocalDataSource(),
        pendingUnregisterLocalDataSource: pendingStore,
      );

      await repository.retryPendingUnregister();

      expect(remote.capturedDeviceToken, 'fcm-token');
      expect(remote.unregisterAttempts, ['reg-1']);
      expect(pendingStore.pending, isNull);
    });

    test(
      'retryPendingUnregister()は保存されたJWTが期限切れでも、現在ログイン中の有効なJWTで再試行する',
      () async {
        final remote = _FakeRemoteDataSource();
        final pendingStore = _FakePendingUnregisterLocalDataSource()
          ..pending = PendingDeviceUnregister(
            deviceToken: 'fcm-token',
            registrationId: 'reg-1',
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
            registrationId: 'reg-1',
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
