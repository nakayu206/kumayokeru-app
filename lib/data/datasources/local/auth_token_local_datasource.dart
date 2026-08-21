import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// kumayokeru-backendが発行したJWTを安全に保存・読み込みするデータソース。
class AuthTokenLocalDataSource {
  AuthTokenLocalDataSource({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const _tokenKey = 'kumayokeru_auth_token';
  // JWTには表示名を含めない(変更が反映されるまで最大7日ステイルになるため)方針のため、
  // ログイン時・変更時にここへ別途キャッシュする。
  static const _nameKey = 'kumayokeru_auth_name';

  final FlutterSecureStorage _storage;

  Future<void> saveToken(String token) {
    return _storage.write(key: _tokenKey, value: token);
  }

  Future<String?> readToken() {
    return _storage.read(key: _tokenKey);
  }

  Future<void> clearToken() {
    return _storage.delete(key: _tokenKey);
  }

  Future<void> saveName(String name) {
    return _storage.write(key: _nameKey, value: name);
  }

  Future<String?> readName() {
    return _storage.read(key: _nameKey);
  }

  Future<void> clearName() {
    return _storage.delete(key: _nameKey);
  }
}
