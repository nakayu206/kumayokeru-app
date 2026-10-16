/// kumayokeru-backendへのプッシュ通知用デバイストークン登録を抽象化するリポジトリ。
/// ログイン済み(JWT保持)である必要がある。
abstract interface class DeviceRepository {
  /// platformは"android"か"ios"。
  Future<void> registerToken(String deviceToken, String platform);

  /// ログアウト時にこの端末へのプッシュ通知を止めるために呼ぶ。失敗した場合は
  /// 端末内に保存し、retryPendingUnregister()で再試行できるようにする。
  Future<void> unregisterToken(String deviceToken);

  /// 前回unregisterToken()が失敗して保存されたトークンがあれば再試行する。
  /// 保存時のJWTを使うため、現在ログアウトしていても呼んでよい。
  Future<void> retryPendingUnregister();
}
