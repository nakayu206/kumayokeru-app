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
  // すると(呼び出し側が待ちきれず諦めた後でも)ログアウト済みのアカウントに通知
  // 登録が残ってしまう。保存済みの登録ID(古い世代)がある場合でも、再登録が
  // 進行中であれば同じ問題が起きる(古い世代だけを解除し、新しい世代を取り逃す)。
  //
  // 「待って直列化する」方式ではなく、イベント駆動で解決する: 進行中の登録
  // 操作をFuture単位で覚えておき、その操作が完了した時点で得られる登録IDを
  // 使って解除する(その操作に直接ぶら下げるだけで即座に返るので、呼び出し側の
  // 待機時間=ログアウトのタイムアウトをブロックしない)。
  //
  // deviceTokenをキーにした単純なフラグ/トークンの保存だと、ログアウト時点で
  // 進行中だった操作とは無関係な「次のログイン時の登録」まで誤って解除して
  // しまう恐れがあるため、必ず「その時点で進行中だった特定の操作」自体
  // (Futureのインスタンス)に結び付ける。
  final Map<String, Future<String>> _inFlightRegistrations = {};

  // 同じdeviceTokenに対するregisterToken()呼び出しを直列化するためのチェーン。
  // これが無いと同じトークンへの複数の登録が並行して走り得て、
  // _inFlightRegistrationsのMap代入が上書きされてしまい、unregisterToken()は
  // 最後に呼ばれたものしか追跡できない。その間に先行する登録がサーバー側で
  // 後から確定すると、その登録が解除されずに残ってしまう。1トークンにつき
  // 常に1件しか実行中にならないよう、ここで順番待ちさせる。
  final Map<String, Future<void>> _registrationChainTails = {};

  @override
  Future<void> registerToken(String deviceToken, String platform) async {
    final attempt = _enqueueRegistration(deviceToken, platform);
    try {
      await attempt;
    } finally {
      // 自分より後に新しい登録操作が始まっていた場合は、そちらを消さない。
      if (_inFlightRegistrations[deviceToken] == attempt) {
        _inFlightRegistrations.remove(deviceToken);
      }
    }
  }

  Future<String> _enqueueRegistration(String deviceToken, String platform) {
    final previous = _registrationChainTails[deviceToken] ?? Future.value();
    final done = Completer<void>();
    _registrationChainTails[deviceToken] = done.future;

    final attempt = previous
        // 前の登録の成否はここでは関係ない(順番を守るためだけに待つ)。
        .catchError((_) {})
        .then((_) => _registerAndSave(deviceToken, platform));
    attempt.then((_) => done.complete(), onError: (_) => done.complete());

    _inFlightRegistrations[deviceToken] = attempt;
    return attempt;
  }

  Future<String> _registerAndSave(String deviceToken, String platform) async {
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
    return registrationId;
  }

  @override
  Future<void> unregisterToken(String deviceToken) async {
    final authToken = await _tokenLocalDataSource.readToken();
    if (authToken == null) {
      throw DeviceApiException('ログインが必要です');
    }

    final inFlightRegistration = _inFlightRegistrations[deviceToken];
    if (inFlightRegistration != null) {
      // ログアウト要求時点で進行中だった、まさにこの登録操作の結果を使って
      // 解除する(保存済みの古い登録IDではなく)。この操作に限定して結び付けて
      // いるため、後で始まる無関係な登録(次回ログイン等)には影響しない。
      unawaited(
        inFlightRegistration
            .then(
              (registrationId) => _performUnregister(
                deviceToken: deviceToken,
                registrationId: registrationId,
                authToken: authToken,
              ),
            )
            .catchError((_) async {
              // 進行中だった登録(再登録)自体が失敗しても、それ以前から登録
              // 済みだった世代が残っている可能性があるため、現在保存されている
              // 登録ID(あれば)を解除する。「登録が無い」と言えるのは最初の
              // 登録がまだ一度も成功していない場合だけ。
              final existingRegistrationId = await _registrationLocalDataSource
                  .readRegistrationId(deviceToken);
              if (existingRegistrationId != null) {
                await _performUnregister(
                  deviceToken: deviceToken,
                  registrationId: existingRegistrationId,
                  authToken: authToken,
                );
              }
            }),
      );
      return;
    }

    final registrationId = await _registrationLocalDataSource
        .readRegistrationId(deviceToken);
    if (registrationId == null) {
      // 登録記録が無く、進行中の登録も無いため、解除する対象がない。
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
