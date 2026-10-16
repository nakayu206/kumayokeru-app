import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kumayokeru_app/data/datasources/remote/auth_remote_datasource.dart';
import 'package:kumayokeru_app/domain/entities/auth_user.dart';
import 'package:kumayokeru_app/domain/repositories/auth_repository.dart';
import 'package:kumayokeru_app/domain/repositories/device_repository.dart';
import 'package:kumayokeru_app/infrastructure/push_notification_service.dart';
import 'package:kumayokeru_app/infrastructure/push_notification_setup.dart';
import 'package:kumayokeru_app/presentation/providers/auth_providers.dart';
import 'package:kumayokeru_app/presentation/providers/push_notification_providers.dart';

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
    final user = AuthUser(id: 'user-1', email: email, name: email.split('@').first);
    loggedInUser = user;
    return user;
  }

  @override
  Future<AuthUser> updateName(String name) async {
    if (nextErrorMessage != null) {
      throw AuthApiException(nextErrorMessage!);
    }
    final current = loggedInUser!;
    final user = AuthUser(id: current.id, email: current.email, name: name);
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

class _NoopPushNotificationService implements PushNotificationService {
  @override
  Future<void> initialize({
    required Future<void> Function(String token) onToken,
  }) async {}

  @override
  Future<String?> getCurrentToken() async => null;
}

class _NoopDeviceRepository implements DeviceRepository {
  void Function(String deviceToken)? onUnregisterToken;

  @override
  Future<void> registerToken(String deviceToken, String platform) async {}

  @override
  Future<void> unregisterToken(String deviceToken) async {
    onUnregisterToken?.call(deviceToken);
  }

  @override
  Future<void> retryPendingUnregister() async {}
}

class _TokenPushNotificationService implements PushNotificationService {
  _TokenPushNotificationService(this._token);

  final String _token;

  @override
  Future<void> initialize({
    required Future<void> Function(String token) onToken,
  }) async {}

  @override
  Future<String?> getCurrentToken() async => _token;
}

// isAndroid: () => false によりunregisterCurrentDevice()は常に即returnするため、
// 中身はダミーでよい(authProviderが内部でpushNotificationSetupProviderを
// 参照するため、テストでも何かしら渡す必要がある)。
final _noopPushNotificationSetup = PushNotificationSetup(
  _NoopPushNotificationService(),
  _NoopDeviceRepository(),
  isAndroid: () => false,
);

void main() {
  group('AuthNotifier', () {
    test('login()成功でstate.userが設定される', () async {
      final fakeRepository = _FakeAuthRepository();
      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(fakeRepository),
          pushNotificationSetupProvider.overrideWithValue(_noopPushNotificationSetup),
        ],
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
        overrides: [
          authRepositoryProvider.overrideWithValue(fakeRepository),
          pushNotificationSetupProvider.overrideWithValue(_noopPushNotificationSetup),
        ],
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

    test('updateName()成功でstate.user.nameが更新される', () async {
      final fakeRepository = _FakeAuthRepository();
      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(fakeRepository),
          pushNotificationSetupProvider.overrideWithValue(_noopPushNotificationSetup),
        ],
      );
      addTearDown(container.dispose);
      container.read(authProvider);
      await pumpEventQueue();

      await container
          .read(authProvider.notifier)
          .login('a@example.com', 'password123');
      await container.read(authProvider.notifier).updateName('新しい名前');

      final state = container.read(authProvider);
      expect(state.isAuthenticated, true);
      expect(state.user!.name, '新しい名前');
    });

    test('logout()でstate.userがクリアされる', () async {
      final fakeRepository = _FakeAuthRepository();
      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(fakeRepository),
          pushNotificationSetupProvider.overrideWithValue(_noopPushNotificationSetup),
        ],
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

    test('logout()は、JWTを破棄する前にデバイストークンの登録解除を試みる', () async {
      final fakeRepository = _FakeAuthRepository();
      final unregisterCalls = <String>[];
      final deviceRepository = _NoopDeviceRepository()
        ..onUnregisterToken = unregisterCalls.add;
      final pushNotificationSetup = PushNotificationSetup(
        _TokenPushNotificationService('fake-fcm-token'),
        deviceRepository,
        isAndroid: () => true,
      );
      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(fakeRepository),
          pushNotificationSetupProvider.overrideWithValue(
            pushNotificationSetup,
          ),
        ],
      );
      addTearDown(container.dispose);
      container.read(authProvider);
      await pumpEventQueue();

      await container
          .read(authProvider.notifier)
          .login('a@example.com', 'password123');
      await container.read(authProvider.notifier).logout();

      expect(unregisterCalls, ['fake-fcm-token']);
    });
  });
}
