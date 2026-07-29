import 'dart:convert';

import 'package:http/http.dart' as http;

/// kumayokeru-backendの認証APIへの通信に失敗した場合の例外。
class AuthApiException implements Exception {
  AuthApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// kumayokeru-backendの認証API(`POST /auth/signup`, `POST /auth/login`)を呼び出すデータソース。
/// API仕様: https://github.com/nakayu206/kumayokeru-backend の routes/auth.js を参照。
class AuthRemoteDataSource {
  AuthRemoteDataSource({http.Client? client, Uri? baseUrl})
    : _client = client ?? http.Client(),
      _baseUrl = baseUrl ?? Uri.parse('https://57-182-248-130.sslip.io');

  final http.Client _client;
  final Uri _baseUrl;

  /// 成功時は`{id, email}`を返す。email形式不正・パスワード短すぎ(400)、
  /// email重複(409)の場合はAuthApiExceptionを投げる。
  Future<Map<String, dynamic>> signUp(String email, String password) async {
    final response = await _post('/auth/signup', {
      'email': email,
      'password': password,
    });

    if (response.statusCode != 201) {
      throw AuthApiException(_errorMessage(response, '新規登録に失敗しました'));
    }

    return jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
  }

  /// 成功時はJWTトークンを返す。email/password不一致(401)の場合はAuthApiExceptionを投げる。
  Future<String> login(String email, String password) async {
    final response = await _post('/auth/login', {
      'email': email,
      'password': password,
    });

    if (response.statusCode != 200) {
      throw AuthApiException(_errorMessage(response, 'ログインに失敗しました'));
    }

    final body =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    return body['token'] as String;
  }

  Future<http.Response> _post(String path, Map<String, dynamic> body) async {
    try {
      return await _client.post(
        _baseUrl.replace(path: path),
        headers: {'content-type': 'application/json'},
        body: jsonEncode(body),
      );
    } on Exception catch (e) {
      throw AuthApiException('通信エラーが発生しました: $e');
    }
  }

  String _errorMessage(http.Response response, String fallback) {
    try {
      final body =
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return body['error'] as String? ?? fallback;
    } on FormatException {
      return fallback;
    }
  }
}
