import 'dart:async';

import 'package:kumayokeru_app/core/utils/jwt_decoder.dart';
import 'package:kumayokeru_app/data/datasources/local/auth_token_local_datasource.dart';
import 'package:kumayokeru_app/data/datasources/local/device_registration_local_datasource.dart';
import 'package:kumayokeru_app/data/datasources/local/pending_device_unregister_local_datasource.dart';
import 'package:kumayokeru_app/data/datasources/remote/device_remote_datasource.dart';
import 'package:kumayokeru_app/domain/repositories/device_repository.dart';

class DeviceRepositoryImpl implements DeviceRepository {
  DeviceRepositoryImpl({
    DeviceRemoteDataSource? remoteDataSource,
    AuthTokenLocalDataSource? tokenLocalDataSource,
    DeviceRegistrationLocalDataSource? registrationLocalDataSource,
    PendingDeviceUnregisterLocalDataSource? pendingUnregisterLocalDataSource,
    Duration? operationQueueTimeout,
  }) : _remoteDataSource = remoteDataSource ?? DeviceRemoteDataSource(),
       _tokenLocalDataSource =
           tokenLocalDataSource ?? AuthTokenLocalDataSource(),
       _registrationLocalDataSource =
           registrationLocalDataSource ?? DeviceRegistrationLocalDataSource(),
       _pendingUnregisterLocalDataSource =
           pendingUnregisterLocalDataSource ??
           PendingDeviceUnregisterLocalDataSource(),
       _operationQueueTimeout =
           operationQueueTimeout ?? const Duration(seconds: 5);

  final DeviceRemoteDataSource _remoteDataSource;
  final AuthTokenLocalDataSource _tokenLocalDataSource;
  final DeviceRegistrationLocalDataSource _registrationLocalDataSource;
  final PendingDeviceUnregisterLocalDataSource
  _pendingUnregisterLocalDataSource;
  final Duration _operationQueueTimeout;

  // registerToken()とunregisterToken()を直列化するためのキュー。これが無いと、
  // 登録の通信が完了する前(登録IDをまだ保存していない間)にログアウトが解除を
  // 試みた場合、「登録した記録が無い」と判断して何もせず終わってしまい、その後
  // 登録が完了するとログアウト済みのアカウントに通知登録が残ってしまう。
  // 解除は直前の登録(またはその逆)が完了するのを待ってから、その時点で保存
  // されている最新の登録IDを見て動くようにする。
  Future<void> _operationQueue = Future.value();

  Future<T> _serialized<T>(Future<T> Function() operation) async {
    final previous = _operationQueue;
    final done = Completer<void>();
    _operationQueue = done.future;
    try {
      // 前の操作の完了を待つが、待ちすぎて後続の操作まで止めないよう上限を
      // 設ける。前の操作がこの後も裏で動き続けて遅れて完了しても、サーバー側の
      // 世代チェック(routes/devices.ts)が新しい登録を保護してくれる。
      await previous.timeout(_operationQueueTimeout);
    } catch (_) {
      // 前の操作の成否・タイムアウトはここでは関係ない(順序を保証するためだけ
      // に待つ)。
    }
    try {
      return await operation();
    } finally {
      done.complete();
    }
  }

  @override
  Future<void> registerToken(String deviceToken, String platform) {
    return _serialized(() => _registerToken(deviceToken, platform));
  }

  Future<void> _registerToken(String deviceToken, String platform) async {
    final authToken = await _tokenLocalDataSource.readToken();
    if (authToken == null) {
      throw DeviceApiException('ログインが必要です');
    }
    final registrationId = await _remoteDataSource.registerToken(
      authToken,
      deviceToken: deviceToken,
      platform: platform,
    );
    // 解除時の世代チェック用に、この登録のIDを覚えておく。
    await _registrationLocalDataSource.save(
      deviceToken: deviceToken,
      registrationId: registrationId,
    );
  }

  @override
  Future<void> unregisterToken(String deviceToken) {
    return _serialized(() => _unregisterToken(deviceToken));
  }

  Future<void> _unregisterToken(String deviceToken) async {
    final authToken = await _tokenLocalDataSource.readToken();
    if (authToken == null) {
      throw DeviceApiException('ログインが必要です');
    }

    final registrationId = await _registrationLocalDataSource
        .readRegistrationId(deviceToken);
    if (registrationId == null) {
      // この端末でこのトークンを登録した記録が無い(登録前にログアウトした等)ため、
      // サーバー側にも対応する登録は無いはずで、解除する対象がない。
      return;
    }

    // 通信を始める前に退避しておく(成功した場合のみ後で消す)。失敗時にだけ保存する
    // 形だと、呼び出し側のタイムアウトやアプリ終了で通信の完了を待てなかった場合に
    // 保存されず、再試行の手がかりを失ってしまう。
    await _pendingUnregisterLocalDataSource.save(
      deviceToken: deviceToken,
      registrationId: registrationId,
      authToken: authToken,
    );

    await _remoteDataSource.unregisterToken(
      authToken,
      deviceToken: deviceToken,
      registrationId: registrationId,
    );

    await _pendingUnregisterLocalDataSource.clear();
  }

  @override
  Future<void> retryPendingUnregister() {
    return _serialized(_retryPendingUnregister);
  }

  Future<void> _retryPendingUnregister() async {
    final pending = await _pendingUnregisterLocalDataSource.read();
    if (pending == null) return;

    var authToken = pending.authToken;
    if (_isExpired(authToken)) {
      // 退避したJWTが期限切れでも、同じ端末で同じアカウントに再ログインして
      // いれば(userId基準で解除できるので)現在のJWTで試す。
      final currentToken = await _tokenLocalDataSource.readToken();
      if (currentToken == null || _isExpired(currentToken)) {
        // 再ログインするまで再試行できないので、次回起動時にまた試す。
        return;
      }
      authToken = currentToken;
    }

    try {
      // registrationIdは退避した時点のものを使う(世代チェックにより、再登録済み
      // なら削除されないため、新しい登録を誤って消す心配はない)。
      await _remoteDataSource.unregisterToken(
        authToken,
        deviceToken: pending.deviceToken,
        registrationId: pending.registrationId,
      );
      await _pendingUnregisterLocalDataSource.clear();
    } on DeviceApiException {
      // ネットワーク不調や別アカウントでの再ログイン等でまだ失敗する場合は、
      // 次回起動時にまた再試行する。
    }
  }

  bool _isExpired(String token) {
    try {
      final exp = decodeJwtPayload(token)['exp'] as int?;
      if (exp == null) return false;
      return DateTime.now().isAfter(
        DateTime.fromMillisecondsSinceEpoch(exp * 1000),
      );
    } on FormatException {
      return true;
    }
  }
}
