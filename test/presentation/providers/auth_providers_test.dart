import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kumayokeru_app/data/datasources/remote/auth_remote_datasource.dart';
import 'package:kumayokeru_app/domain/entities/auth_user.dart';
import 'package:kumayokeru_app/domain/repositories/auth_repository.dart';
import 'package:kumayokeru_app/presentation/providers/auth_providers.dart';

class _FakeAuthRepository implements AuthRepository {
  AuthUser? loggedInUser;
  String? nextErrorMessage;

  @override
  Future<AuthUser> signUp(String email, String password) =>
      login(email, password);

  @override
  Future<AuthUser> login(String email, String password) async {
    if (nextErrorMessage != null) {
      throw AuthApiException(nextErrorMessage!);
    }
    final user = AuthUser(id: 'user-1', email: email);
    loggedInUser = user;
    return user;
  }

  @override
  Future<void> logout() async {
    loggedInUser = null;
  }

  @override
  Future<AuthUser?> currentUser() async => loggedInUser;

  @override
  Future<String?> currentToken() async => null;
}

void main() {
  group('AuthNotifier', () {
    test('login()成功でstate.userが設定される', () async {
      final fakeRepository = _FakeAuthRepository();
      final container = ProviderContainer(
        overrides: [authRepositoryProvider.overrideWithValue(fakeRepository)],
      );
      addTearDown(container.dispose);
      container.read(authProvider);
      await pumpEventQueue();

      await container
          .read(authProvider.notifier)
          .login('a@example.com', 'password123');

      final state = container.read(authProvider);
      expect(state.isAuthenticated, true);
      expect(state.user!.email, 'a@example.com');
      expect(state.errorMessage, isNull);
    });

    test('login()失敗でerrorMessageが設定され、未認証のまま', () async {
      final fakeRepository = _FakeAuthRepository()
        ..nextErrorMessage = 'emailまたはpasswordが正しくありません';
      final container = ProviderContainer(
        overrides: [authRepositoryProvider.overrideWithValue(fakeRepository)],
      );
      addTearDown(container.dispose);
      container.read(authProvider);
      await pumpEventQueue();

      await container
          .read(authProvider.notifier)
          .login('a@example.com', 'wrong-password');

      final state = container.read(authProvider);
      expect(state.isAuthenticated, false);
      expect(state.errorMessage, 'emailまたはpasswordが正しくありません');
    });

    test('logout()でstate.userがクリアされる', () async {
      final fakeRepository = _FakeAuthRepository();
      final container = ProviderContainer(
        overrides: [authRepositoryProvider.overrideWithValue(fakeRepository)],
      );
      addTearDown(container.dispose);
      container.read(authProvider);
      await pumpEventQueue();

      await container
          .read(authProvider.notifier)
          .login('a@example.com', 'password123');
      await container.read(authProvider.notifier).logout();

      expect(container.read(authProvider).isAuthenticated, false);
    });
  });
}
