import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kumayokeru_app/domain/entities/member_location.dart';
import 'package:kumayokeru_app/domain/entities/share_group.dart';
import 'package:kumayokeru_app/domain/repositories/location_sharing_repository.dart';
import 'package:kumayokeru_app/presentation/providers/location_sharing_providers.dart';

class _FakeLocationSharingRepository implements LocationSharingRepository {
  List<ShareGroup> groups = [];
  List<MemberLocation> memberLocations = [];
  String? removedGroupId;
  String? removedUserId;

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
  Future<List<MemberLocation>> pollLocations(String groupId) async =>
      memberLocations;

  @override
  Future<void> removeMember(String groupId, String userId) async {
    removedGroupId = groupId;
    removedUserId = userId;
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

    test('removeMember()でメンバーが削除され、一覧が更新される', () async {
      final fakeRepository = _FakeLocationSharingRepository()
        ..groups = [group]
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
      expect(
        container.read(locationSharingProvider).memberLocations,
        [ownerLocation],
      );
    });

    test('leaveGroup()で自分自身を削除し、グループ未参加の状態に戻る', () async {
      final fakeRepository = _FakeLocationSharingRepository()
        ..groups = [group]
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
      expect(state.memberLocations, isEmpty);
    });
  });
}
