/// kumayokeru-backendへのプッシュ通知用デバイストークン登録を抽象化するリポジトリ。
/// ログイン済み(JWT保持)である必要がある。
abstract interface class DeviceRepository {
  /// platformは"android"か"ios"。
  Future<void> registerToken(String deviceToken, String platform);
}
