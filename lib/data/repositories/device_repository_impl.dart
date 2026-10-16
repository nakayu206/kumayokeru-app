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
  }) : _remoteDataSource = remoteDataSource ?? DeviceRemoteDataSource(),
       _tokenLocalDataSource =
           tokenLocalDataSource ?? AuthTokenLocalDataSource(),
       _registrationLocalDataSource =
           registrationLocalDataSource ?? DeviceRegistrationLocalDataSource(),
       _pendingUnregisterLocalDataSource =
           pendingUnregisterLocalDataSource ??
           PendingDeviceUnregisterLocalDataSource();

  final DeviceRemoteDataSource _remoteDataSource;
  final AuthTokenLocalDataSource _tokenLocalDataSource;
  final DeviceRegistrationLocalDataSource _registrationLocalDataSource;
  final PendingDeviceUnregisterLocalDataSource
  _pendingUnregisterLocalDataSource;

  // registerToken()が通信中(まだ登録IDを保存していない)の間にunregisterToken()が
  // 呼ばれた場合、「登録した記録が無い」ために解除せず終わってしまい、登録が完了
  // すると(通信が5秒以上かかる等で呼び出し側が待ちきれず諦めた後でも)ログアウト
  // 済みのアカウントに通知登録が残ってしまう。
  //
  // これを「待って直列化する」方式ではなく、イベント駆動で解決する: その場では
  // 解除要求があったことと、解除に使うJWT(ログアウトで消える前の有効なもの)を
  // deviceToken単位で覚えておくだけにして即座に返り、登録が完了した時点で
  // registerToken()自身がこの解除要求を検知して後始末する。これなら呼び出し側の
  // 待機時間(ログアウトのタイムアウト)と、登録完了を待つ内部処理が完全に分離
  // される。
  final Map<String, String> _pendingLogoutAuthTokens = {};

  @override
  Future<void> registerToken(String deviceToken, String platform) async {
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

    // 登録の通信中にログアウトの解除要求が来ていた場合、ここで即座に後始末する
    // (ログアウト要求時点でまだ有効だったJWTを使う。今のJWTは既に失効・削除
    // 済みの可能性があるため)。
    final logoutAuthToken = _pendingLogoutAuthTokens.remove(deviceToken);
    if (logoutAuthToken != null) {
      await _performUnregister(
        deviceToken: deviceToken,
        registrationId: registrationId,
        authToken: logoutAuthToken,
      );
    }
  }

  @override
  Future<void> unregisterToken(String deviceToken) async {
    final authToken = await _tokenLocalDataSource.readToken();
    if (authToken == null) {
      throw DeviceApiException('ログインが必要です');
    }

    final registrationId = await _registrationLocalDataSource
        .readRegistrationId(deviceToken);
    if (registrationId == null) {
      // 登録の通信がまだ完了していない可能性があるため、「登録が無い」と断定
      // せず、解除要求とJWTを記録しておく。registerToken()が完了した時点で
      // 自動的に解除される。既にサーバー側にも本当に登録が無い場合は、
      // registerToken()が呼ばれない限り何も起きない(解除すべき対象も無い)。
      _pendingLogoutAuthTokens[deviceToken] = authToken;
      return;
    }

    await _performUnregister(
      deviceToken: deviceToken,
      registrationId: registrationId,
      authToken: authToken,
    );
  }

  Future<void> _performUnregister({
    required String deviceToken,
    required String registrationId,
    required String authToken,
  }) async {
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
