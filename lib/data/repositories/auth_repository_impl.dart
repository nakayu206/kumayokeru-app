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
    final token = await _remoteDataSource.login(email, password);
    await _tokenLocalDataSource.saveToken(token);
    return _userFromToken(token);
  }

  @override
  Future<void> logout() {
    return _tokenLocalDataSource.clearToken();
  }

  @override
  Future<AuthUser?> currentUser() async {
    final token = await _tokenLocalDataSource.readToken();
    if (token == null) return null;
    return _userFromToken(token);
  }

  @override
  Future<String?> currentToken() {
    return _tokenLocalDataSource.readToken();
  }

  AuthUser _userFromToken(String token) {
    final payload = decodeJwtPayload(token);
    return AuthUser(
      id: payload['sub'] as String,
      email: payload['email'] as String,
    );
  }
}
