import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:kumayokeru_app/data/datasources/local/auth_token_local_datasource.dart';
import 'package:kumayokeru_app/data/repositories/auth_repository_impl.dart';

class _FakeTokenLocalDataSource extends AuthTokenLocalDataSource {
  String? token;
  String? name;
  bool cleared = false;

  @override
  Future<String?> readToken() async => token;

  @override
  Future<String?> readName() async => name;

  @override
  Future<void> clearToken() async {
    token = null;
    cleared = true;
  }

  @override
  Future<void> clearName() async {
    name = null;
  }
}

/// 署名検証は行わない実装(decodeJwtPayload)向けの、テスト用JWT組み立て。
String _buildJwt(Map<String, dynamic> payload) {
  String encodeSegment(Object value) =>
      base64Url.encode(utf8.encode(jsonEncode(value))).replaceAll('=', '');
  final header = encodeSegment({'alg': 'none', 'typ': 'JWT'});
  final body = encodeSegment(payload);
  return '$header.$body.signature';
}

void main() {
  group('AuthRepositoryImpl.currentUser', () {
    test('有効期限内のトークンならAuthUserを返す', () async {
      final futureExp =
          DateTime.now().add(const Duration(days: 1)).millisecondsSinceEpoch ~/
          1000;
      final tokenSource = _FakeTokenLocalDataSource()
        ..token = _buildJwt({
          'sub': 'user-1',
          'email': 'taro@example.com',
          'exp': futureExp,
        })
        ..name = 'たろう';
      final repository = AuthRepositoryImpl(
        tokenLocalDataSource: tokenSource,
      );

      final user = await repository.currentUser();

      expect(user?.id, 'user-1');
      expect(user?.email, 'taro@example.com');
      expect(user?.name, 'たろう');
      expect(tokenSource.cleared, isFalse);
    });

    test('期限切れトークンはログイン済みとして復元せず、保存情報をクリアする', () async {
      final pastExp =
          DateTime.now()
              .subtract(const Duration(days: 1))
              .millisecondsSinceEpoch ~/
          1000;
      final tokenSource = _FakeTokenLocalDataSource()
        ..token = _buildJwt({
          'sub': 'user-1',
          'email': 'taro@example.com',
          'exp': pastExp,
        });
      final repository = AuthRepositoryImpl(
        tokenLocalDataSource: tokenSource,
      );

      final user = await repository.currentUser();

      expect(user, isNull);
      expect(tokenSource.cleared, isTrue);
    });

    test('壊れた保存トークンは例外にせず、ログアウト状態として扱う', () async {
      final tokenSource = _FakeTokenLocalDataSource()
        ..token = 'not-a-valid-jwt';
      final repository = AuthRepositoryImpl(
        tokenLocalDataSource: tokenSource,
      );

      final user = await repository.currentUser();

      expect(user, isNull);
      expect(tokenSource.cleared, isTrue);
    });

    test('トークン未保存ならnullを返す', () async {
      final repository = AuthRepositoryImpl(
        tokenLocalDataSource: _FakeTokenLocalDataSource(),
      );

      expect(await repository.currentUser(), isNull);
    });
  });
}
