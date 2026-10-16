import 'package:shared_preferences/shared_preferences.dart';

/// 直近に登録したデバイストークンと、サーバー側の登録ID(世代番号)を保存する。
/// 解除リクエストにこのIDを含めることで、解除が遅延している間に同じトークンが
/// 再登録されていた場合、古い解除が新しい登録を誤って削除しないようにする
/// (routes/devices.tsの世代チェック参照)。
class DeviceRegistrationLocalDataSource {
  static const _tokenKey = 'kumayokeru_device_registration_token';
  static const _idKey = 'kumayokeru_device_registration_id';

  Future<void> save({
    required String deviceToken,
    required String registrationId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, deviceToken);
    await prefs.setString(_idKey, registrationId);
  }

  /// deviceTokenが保存時と一致する場合のみ登録IDを返す(トークンが変わっていれば
  /// 古い登録IDを誤って使わないようnullを返す)。
  Future<String?> readRegistrationId(String deviceToken) async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString(_tokenKey) != deviceToken) return null;
    return prefs.getString(_idKey);
  }
}
