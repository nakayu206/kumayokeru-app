import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kumayokeru_app/domain/entities/auth_user.dart';
import 'package:kumayokeru_app/domain/entities/group_member.dart';
import 'package:kumayokeru_app/domain/entities/member_location.dart';
import 'package:kumayokeru_app/domain/entities/share_group.dart';
import 'package:kumayokeru_app/domain/repositories/auth_repository.dart';
import 'package:kumayokeru_app/domain/repositories/device_repository.dart';
import 'package:kumayokeru_app/domain/repositories/location_sharing_repository.dart';
import 'package:kumayokeru_app/infrastructure/push_notification_service.dart';
import 'package:kumayokeru_app/infrastructure/push_notification_setup.dart';
import 'package:kumayokeru_app/presentation/providers/auth_providers.dart';
import 'package:kumayokeru_app/presentation/providers/location_sharing_providers.dart';
import 'package:kumayokeru_app/presentation/providers/push_notification_providers.dart';

// locationSharingProviderはログインユーザーIDを監視するため、authProvider関連の
// 依存(Firebase等に触れる)をダミーに差し替える必要がある。
class _FakeAuthRepository implements AuthRepository {
  @override
  Future<AuthUser> signUp(String email, String password) async =>
      throw UnimplementedError();

  @override
  Future<AuthUser> login(String email, String password) async =>
      throw UnimplementedError();

  @override
  Future<AuthUser> updateName(String name) async => throw UnimplementedError();

  @override
  Future<void> logout() async {}

  @override
  Future<AuthUser?> currentUser() async =>
      const AuthUser(id: 'user-1', email: 'owner@example.com', name: 'owner');

  @override
  Future<String?> currentToken() async => 'fake-jwt-token';
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
  @override
  Future<void> registerToken(String deviceToken, String platform) async {}

  @override
  Future<void> unregisterToken(String deviceToken) async {}

  @override
  Future<void> retryPendingUnregister() async {}
}

final _noopPushNotificationSetup = PushNotificationSetup(
  _NoopPushNotificationService(),
  _NoopDeviceRepository(),
  isAndroid: () => false,
);

final _authProviderOverrides = [
  authRepositoryProvider.overrideWithValue(_FakeAuthRepository()),
  pushNotificationSetupProvider.overrideWithValue(_noopPushNotificationSetup),
];

class _FakeLocationSharingRepository implements LocationSharingRepository {
  List<ShareGroup> groups = [];
  List<GroupMember> members = [];
  List<MemberLocation> memberLocations = [];
  String? removedGroupId;
  String? removedUserId;
  String? sosGroupId;
  double? sosLat;
  double? sosLng;

  @override
  Future<List<ShareGroup>> listGroups() async => groups;

  @override
  Future<ShareGroup> createGroup(String name) async {
    throw UnimplementedError();
  }

  @override
  Future<void> inviteMember(String groupId, String email) async {
    throw UnimplementedError();
  }

  @override
  Future<void> postLocation({required double lat, required double lng}) async {
    throw UnimplementedError();
  }

  @override
  Future<void> sendSos({
    required String groupId,
    required double lat,
    required double lng,
  }) async {
    sosGroupId = groupId;
    sosLat = lat;
    sosLng = lng;
  }

  @override
  Future<List<MemberLocation>> pollLocations(String groupId) async =>
      memberLocations;

  @override
  Future<List<GroupMember>> listMembers(String groupId) async => members;

  @override
  Future<void> removeMember(String groupId, String userId) async {
    removedGroupId = groupId;
    removedUserId = userId;
    members = members.where((member) => member.userId != userId).toList();
    memberLocations = memberLocations
        .where((location) => location.userId != userId)
        .toList();
  }
}

void main() {
  group('LocationSharingNotifier', () {
    final group = ShareGroup(
      id: 'group-1',
      name: '家族グループ',
      ownerUserId: 'user-1',
      createdAt: DateTime(2026, 7, 25),
    );
    final ownerLocation = MemberLocation(
      userId: 'user-1',
      name: 'owner',
      lat: 35.0,
      lng: 139.0,
      recordedAt: DateTime(2026, 7, 25),
    );
    final memberLocation = MemberLocation(
      userId: 'user-2',
      name: 'member',
      lat: 35.1,
      lng: 139.1,
      recordedAt: DateTime(2026, 7, 25),
    );
    final ownerMember = GroupMember(
      userId: 'user-1',
      name: 'owner',
      joinedAt: DateTime(2026, 7, 25),
    );
    final invitedMember = GroupMember(
      userId: 'user-2',
      name: 'member',
      joinedAt: DateTime(2026, 7, 25),
    );

    test('sendSos()でリポジトリのsendSosが呼ばれ、一覧が更新される', () async {
      final fakeRepository = _FakeLocationSharingRepository()
        ..groups = [group]
        ..members = [ownerMember]
        ..memberLocations = [ownerLocation];
      final container = ProviderContainer(
        overrides: [
          locationSharingRepositoryProvider.overrideWithValue(fakeRepository),
          ..._authProviderOverrides,
        ],
      );
      addTearDown(container.dispose);
      // 先にauth復元を完了させてから読むことで、ユーザーID確定によるlocationSharingProvider
      // の作り直し(と、その際の二重_loadGroup()実行)を避ける。
      container.read(authProvider);
      await pumpEventQueue();
      container.read(locationSharingProvider);
      await pumpEventQueue();

      await container
          .read(locationSharingProvider.notifier)
          .sendSos(35.5, 139.5);

      expect(fakeRepository.sosGroupId, 'group-1');
      expect(fakeRepository.sosLat, 35.5);
      expect(fakeRepository.sosLng, 139.5);
    });

    test('refreshLocations()はメンバー一覧と位置情報の両方を取得する(位置未共有のメンバーも含む)', () async {
      final fakeRepository = _FakeLocationSharingRepository()
        ..groups = [group]
        ..members = [ownerMember, invitedMember]
        // user-2はまだ位置情報を共有していない想定(memberLocationsには含めない)。
        ..memberLocations = [ownerLocation];
      final container = ProviderContainer(
        overrides: [
          locationSharingRepositoryProvider.overrideWithValue(fakeRepository),
          ..._authProviderOverrides,
        ],
      );
      addTearDown(container.dispose);
      // 先にauth復元を完了させてから読むことで、ユーザーID確定によるlocationSharingProvider
      // の作り直し(と、その際の二重_loadGroup()実行)を避ける。
      container.read(authProvider);
      await pumpEventQueue();
      container.read(locationSharingProvider);
      await pumpEventQueue();

      final state = container.read(locationSharingProvider);
      expect(state.members, [ownerMember, invitedMember]);
      expect(state.memberLocations, [ownerLocation]);
    });

    test('removeMember()でメンバーが削除され、一覧が更新される', () async {
      final fakeRepository = _FakeLocationSharingRepository()
        ..groups = [group]
        ..members = [ownerMember, invitedMember]
        ..memberLocations = [ownerLocation, memberLocation];
      final container = ProviderContainer(
        overrides: [
          locationSharingRepositoryProvider.overrideWithValue(fakeRepository),
          ..._authProviderOverrides,
        ],
      );
      addTearDown(container.dispose);
      // 先にauth復元を完了させてから読むことで、ユーザーID確定によるlocationSharingProvider
      // の作り直し(と、その際の二重_loadGroup()実行)を避ける。
      container.read(authProvider);
      await pumpEventQueue();
      container.read(locationSharingProvider);
      await pumpEventQueue();

      await container
          .read(locationSharingProvider.notifier)
          .removeMember('user-2');

      expect(fakeRepository.removedGroupId, 'group-1');
      expect(fakeRepository.removedUserId, 'user-2');
      final state = container.read(locationSharingProvider);
      expect(state.members, [ownerMember]);
      expect(state.memberLocations, [ownerLocation]);
    });

    test('leaveGroup()で自分自身を削除し、グループ未参加の状態に戻る', () async {
      final fakeRepository = _FakeLocationSharingRepository()
        ..groups = [group]
        ..members = [ownerMember, invitedMember]
        ..memberLocations = [ownerLocation, memberLocation];
      final container = ProviderContainer(
        overrides: [
          locationSharingRepositoryProvider.overrideWithValue(fakeRepository),
          ..._authProviderOverrides,
        ],
      );
      addTearDown(container.dispose);
      // 先にauth復元を完了させてから読むことで、ユーザーID確定によるlocationSharingProvider
      // の作り直し(と、その際の二重_loadGroup()実行)を避ける。
      container.read(authProvider);
      await pumpEventQueue();
      container.read(locationSharingProvider);
      await pumpEventQueue();

      await container
          .read(locationSharingProvider.notifier)
          .leaveGroup('user-2');

      expect(fakeRepository.removedGroupId, 'group-1');
      expect(fakeRepository.removedUserId, 'user-2');
      final state = container.read(locationSharingProvider);
      expect(state.group, isNull);
      expect(state.members, isEmpty);
      expect(state.memberLocations, isEmpty);
    });
  });
}
