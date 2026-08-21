import 'package:kumayokeru_app/core/utils/jwt_decoder.dart';
import 'package:kumayokeru_app/data/datasources/local/auth_token_local_datasource.dart';
import 'package:kumayokeru_app/data/datasources/remote/auth_remote_datasource.dart';
import 'package:kumayokeru_app/domain/entities/auth_user.dart';
import 'package:kumayokeru_app/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    AuthRemoteDataSource? remoteDataSource,
    AuthTokenLocalDataSource? tokenLocalDataSource,
  }) : _remoteDataSource = remoteDataSource ?? AuthRemoteDataSource(),
       _tokenLocalDataSource =
           tokenLocalDataSource ?? AuthTokenLocalDataSource();

  final AuthRemoteDataSource _remoteDataSource;
  final AuthTokenLocalDataSource _tokenLocalDataSource;

  @override
  Future<AuthUser> signUp(String email, String password) async {
    await _remoteDataSource.signUp(email, password);
    // kumayokeru-backendはsignup時にトークンを発行しないため、続けてログインする。
    return login(email, password);
  }

  @override
  Future<AuthUser> login(String email, String password) async {
    final body = await _remoteDataSource.login(email, password);
    final token = body['token'] as String;
    final name = body['name'] as String;
    await _tokenLocalDataSource.saveToken(token);
    await _tokenLocalDataSource.saveName(name);
    return _userFromToken(token, name);
  }

  @override
  Future<AuthUser> updateName(String name) async {
    final token = await _tokenLocalDataSource.readToken();
    if (token == null) {
      throw AuthApiException('ログインが必要です');
    }
    final body = await _remoteDataSource.updateName(token, name);
    final updatedName = body['name'] as String;
    await _tokenLocalDataSource.saveName(updatedName);
    return _userFromToken(token, updatedName);
  }

  @override
  Future<void> logout() async {
    await _tokenLocalDataSource.clearToken();
    await _tokenLocalDataSource.clearName();
  }

  @override
  Future<AuthUser?> currentUser() async {
    final token = await _tokenLocalDataSource.readToken();
    if (token == null) return null;
    final payload = decodeJwtPayload(token);
    final email = payload['email'] as String;
    // 名前未キャッシュ(旧バージョンからの引き継ぎ等)はemailのローカル部で暫定表示する。
    final name = await _tokenLocalDataSource.readName() ?? email.split('@').first;
    return _userFromToken(token, name);
  }

  @override
  Future<String?> currentToken() {
    return _tokenLocalDataSource.readToken();
  }

  AuthUser _userFromToken(String token, String name) {
    final payload = decodeJwtPayload(token);
    return AuthUser(
      id: payload['sub'] as String,
      email: payload['email'] as String,
      name: name,
    );
  }
}
