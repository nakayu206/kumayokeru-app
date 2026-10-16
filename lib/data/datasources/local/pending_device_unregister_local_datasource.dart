import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// デバイストークンの登録解除(DELETE /devices)が失敗した場合に、再試行用の
/// デバイストークンとJWTを保存しておくデータソース。ログアウトで本来のJWTが
/// 消える前に退避しておくことで、ログアウト後でも解除を再試行できるようにする。
class PendingDeviceUnregisterLocalDataSource {
  PendingDeviceUnregisterLocalDataSource({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const _deviceTokenKey = 'kumayokeru_pending_unregister_device_token';
  static const _authTokenKey = 'kumayokeru_pending_unregister_auth_token';

  final FlutterSecureStorage _storage;

  Future<void> save({
    required String deviceToken,
    required String authToken,
  }) async {
    await _storage.write(key: _deviceTokenKey, value: deviceToken);
    await _storage.write(key: _authTokenKey, value: authToken);
  }

  Future<PendingDeviceUnregister?> read() async {
    final deviceToken = await _storage.read(key: _deviceTokenKey);
    final authToken = await _storage.read(key: _authTokenKey);
    if (deviceToken == null || authToken == null) return null;
    return PendingDeviceUnregister(deviceToken: deviceToken, authToken: authToken);
  }

  Future<void> clear() async {
    await _storage.delete(key: _deviceTokenKey);
    await _storage.delete(key: _authTokenKey);
  }
}

class PendingDeviceUnregister {
  const PendingDeviceUnregister({
    required this.deviceToken,
    required this.authToken,
  });

  final String deviceToken;
  final String authToken;
}
