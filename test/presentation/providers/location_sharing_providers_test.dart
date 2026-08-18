import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kumayokeru_app/domain/entities/group_member.dart';
import 'package:kumayokeru_app/domain/entities/member_location.dart';
import 'package:kumayokeru_app/domain/entities/share_group.dart';
import 'package:kumayokeru_app/domain/repositories/location_sharing_repository.dart';
import 'package:kumayokeru_app/presentation/providers/location_sharing_providers.dart';

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
      email: 'owner@example.com',
      lat: 35.0,
      lng: 139.0,
      recordedAt: DateTime(2026, 7, 25),
    );
    final memberLocation = MemberLocation(
      userId: 'user-2',
      email: 'member@example.com',
      lat: 35.1,
      lng: 139.1,
      recordedAt: DateTime(2026, 7, 25),
    );
    final ownerMember = GroupMember(
      userId: 'user-1',
      email: 'owner@example.com',
      joinedAt: DateTime(2026, 7, 25),
    );
    final invitedMember = GroupMember(
      userId: 'user-2',
      email: 'member@example.com',
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
        ],
      );
      addTearDown(container.dispose);
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
        ],
      );
      addTearDown(container.dispose);
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
        ],
      );
      addTearDown(container.dispose);
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
        ],
      );
      addTearDown(container.dispose);
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
