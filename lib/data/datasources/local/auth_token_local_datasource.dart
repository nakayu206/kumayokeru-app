import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// kumayokeru-backendが発行したJWTを安全に保存・読み込みするデータソース。
class AuthTokenLocalDataSource {
  AuthTokenLocalDataSource({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const _tokenKey = 'kumayokeru_auth_token';

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
}
