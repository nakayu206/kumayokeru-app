import 'package:kumayokeru_app/core/utils/jwt_decoder.dart';
import 'package:kumayokeru_app/data/datasources/local/auth_token_local_datasource.dart';
import 'package:kumayokeru_app/data/datasources/local/pending_device_unregister_local_datasource.dart';
import 'package:kumayokeru_app/data/datasources/remote/device_remote_datasource.dart';
import 'package:kumayokeru_app/domain/repositories/device_repository.dart';

class DeviceRepositoryImpl implements DeviceRepository {
  DeviceRepositoryImpl({
    DeviceRemoteDataSource? remoteDataSource,
    AuthTokenLocalDataSource? tokenLocalDataSource,
    PendingDeviceUnregisterLocalDataSource? pendingUnregisterLocalDataSource,
  }) : _remoteDataSource = remoteDataSource ?? DeviceRemoteDataSource(),
       _tokenLocalDataSource =
           tokenLocalDataSource ?? AuthTokenLocalDataSource(),
       _pendingUnregisterLocalDataSource =
           pendingUnregisterLocalDataSource ??
           PendingDeviceUnregisterLocalDataSource();

  final DeviceRemoteDataSource _remoteDataSource;
  final AuthTokenLocalDataSource _tokenLocalDataSource;
  final PendingDeviceUnregisterLocalDataSource
  _pendingUnregisterLocalDataSource;

  @override
  Future<void> registerToken(String deviceToken, String platform) async {
    final authToken = await _tokenLocalDataSource.readToken();
    if (authToken == null) {
      throw DeviceApiException('ログインが必要です');
    }
    await _remoteDataSource.registerToken(
      authToken,
      deviceToken: deviceToken,
      platform: platform,
    );
  }

  @override
  Future<void> unregisterToken(String deviceToken) async {
    final authToken = await _tokenLocalDataSource.readToken();
    if (authToken == null) {
      throw DeviceApiException('ログインが必要です');
    }

    // 通信を始める前に退避しておく(成功した場合のみ後で消す)。失敗時にだけ保存する
    // 形だと、呼び出し側のタイムアウトやアプリ終了で通信の完了を待てなかった場合に
    // 保存されず、再試行の手がかりを失ってしまう。
    await _pendingUnregisterLocalDataSource.save(
      deviceToken: deviceToken,
      authToken: authToken,
    );

    await _remoteDataSource.unregisterToken(
      authToken,
      deviceToken: deviceToken,
    );

    await _pendingUnregisterLocalDataSource.clear();
  }

  @override
  Future<void> retryPendingUnregister() async {
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
      await _remoteDataSource.unregisterToken(
        authToken,
        deviceToken: pending.deviceToken,
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
