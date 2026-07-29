import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:kumayokeru_app/data/datasources/remote/auth_remote_datasource.dart';

http.Response _jsonResponse(Object body, int statusCode) {
  return http.Response(
    jsonEncode(body),
    statusCode,
    headers: {'content-type': 'application/json; charset=utf-8'},
  );
}

void main() {
  group('AuthRemoteDataSource.signUp', () {
    test('201応答からid, emailを取得する', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, '/auth/signup');
        return _jsonResponse({'id': 'user-1', 'email': 'a@example.com'}, 201);
      });

      final dataSource = AuthRemoteDataSource(client: mockClient);
      final result = await dataSource.signUp('a@example.com', 'password123');

      expect(result['id'], 'user-1');
      expect(result['email'], 'a@example.com');
    });

    test('409応答(メール重複)はサーバーのエラーメッセージでAuthApiExceptionを投げる', () async {
      final mockClient = MockClient((request) async {
        return _jsonResponse({'error': 'このemailは既に登録されています'}, 409);
      });

      final dataSource = AuthRemoteDataSource(client: mockClient);

      expect(
        () => dataSource.signUp('a@example.com', 'password123'),
        throwsA(
          isA<AuthApiException>().having(
            (e) => e.message,
            'message',
            'このemailは既に登録されています',
          ),
        ),
      );
    });
  });

  group('AuthRemoteDataSource.login', () {
    test('200応答からtokenを取得する', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, '/auth/login');
        return _jsonResponse({'token': 'fake-jwt-token'}, 200);
      });

      final dataSource = AuthRemoteDataSource(client: mockClient);
      final token = await dataSource.login('a@example.com', 'password123');

      expect(token, 'fake-jwt-token');
    });

    test('401応答(認証失敗)はAuthApiExceptionを投げる', () async {
      final mockClient = MockClient((request) async {
        return _jsonResponse({'error': 'emailまたはpasswordが正しくありません'}, 401);
      });

      final dataSource = AuthRemoteDataSource(client: mockClient);

      expect(
        () => dataSource.login('a@example.com', 'wrong-password'),
        throwsA(isA<AuthApiException>()),
      );
    });
  });
}
