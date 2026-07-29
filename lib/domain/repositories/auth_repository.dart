import 'package:kumayokeru_app/domain/entities/auth_user.dart';

/// kumayokeru-backendの認証(JWT + bcrypt)を抽象化するリポジトリ。
abstract interface class AuthRepository {
  /// 新規登録し、続けてログインまで行う(kumayokeru-backendはsignup時にトークンを
  /// 発行しないため、登録直後に自動でログインしてトークンを取得する)。
  Future<AuthUser> signUp(String email, String password);

  Future<AuthUser> login(String email, String password);

  Future<void> logout();

  /// 保存済みトークンからユーザー情報を復元する(未ログインならnull)。
  Future<AuthUser?> currentUser();

  Future<String?> currentToken();
}
