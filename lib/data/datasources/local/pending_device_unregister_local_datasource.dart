import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// デバイストークンの登録解除(DELETE /devices)が失敗した場合に、再試行用の
/// デバイストークン・登録ID・JWTを保存しておくデータソース。ログアウトで本来の
/// JWTが消える前に退避しておくことで、ログアウト後でも解除を再試行できるようにする。
class PendingDeviceUnregisterLocalDataSource {
  PendingDeviceUnregisterLocalDataSource({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const _deviceTokenKey = 'kumayokeru_pending_unregister_device_token';
  static const _registrationIdKey =
      'kumayokeru_pending_unregister_registration_id';
  static const _authTokenKey = 'kumayokeru_pending_unregister_auth_token';

  final FlutterSecureStorage _storage;

  Future<void> save({
    required String deviceToken,
    required String registrationId,
    required String authToken,
  }) async {
    await _storage.write(key: _deviceTokenKey, value: deviceToken);
    await _storage.write(key: _registrationIdKey, value: registrationId);
    await _storage.write(key: _authTokenKey, value: authToken);
  }

  Future<PendingDeviceUnregister?> read() async {
    final deviceToken = await _storage.read(key: _deviceTokenKey);
    final registrationId = await _storage.read(key: _registrationIdKey);
    final authToken = await _storage.read(key: _authTokenKey);
    if (deviceToken == null || registrationId == null || authToken == null) {
      return null;
    }
    return PendingDeviceUnregister(
      deviceToken: deviceToken,
      registrationId: registrationId,
      authToken: authToken,
    );
  }

  Future<void> clear() async {
    await _storage.delete(key: _deviceTokenKey);
    await _storage.delete(key: _registrationIdKey);
    await _storage.delete(key: _authTokenKey);
  }
}

class PendingDeviceUnregister {
  const PendingDeviceUnregister({
    required this.deviceToken,
    required this.registrationId,
    required this.authToken,
  });

  final String deviceToken;
  final String registrationId;
  final String authToken;
}
