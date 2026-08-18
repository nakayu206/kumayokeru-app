import 'package:flutter_test/flutter_test.dart';

import 'package:kumayokeru_app/data/datasources/local/auth_token_local_datasource.dart';
import 'package:kumayokeru_app/data/datasources/remote/location_sharing_remote_datasource.dart';
import 'package:kumayokeru_app/data/repositories/location_sharing_repository_impl.dart';

class _FakeTokenLocalDataSource extends AuthTokenLocalDataSource {
  String? token;

  @override
  Future<String?> readToken() async => token;
}

class _FakeRemoteDataSource extends LocationSharingRemoteDataSource {
  String? capturedToken;
  String? removedGroupId;
  String? removedUserId;
  String? sosGroupId;
  double? sosLat;
  double? sosLng;

  @override
  Future<List<Map<String, dynamic>>> listGroups(String token) async {
    capturedToken = token;
    return [
      {
        'id': 'group-1',
        'name': '家族グループ',
        'ownerUserId': 'user-1',
        'createdAt': '2026-07-25T06:30:00+09:00',
      },
    ];
  }

  @override
  Future<void> removeMember(
    String token,
    String groupId,
    String userId,
  ) async {
    capturedToken = token;
    removedGroupId = groupId;
    removedUserId = userId;
  }

  @override
  Future<void> sendSos(
    String token,
    String groupId, {
    required double lat,
    required double lng,
  }) async {
    capturedToken = token;
    sosGroupId = groupId;
    sosLat = lat;
    sosLng = lng;
  }

  @override
  Future<List<Map<String, dynamic>>> listMembers(
    String token,
    String groupId,
  ) async {
    capturedToken = token;
    return [
      {
        'userId': 'user-2',
        'email': 'invited@example.com',
        'joinedAt': '2026-07-25T06:30:00+09:00',
      },
    ];
  }
}

void main() {
  group('LocationSharingRepositoryImpl', () {
    test('未ログイン(トークンなし)の場合はLocationSharingApiExceptionを投げる', () async {
      final repository = LocationSharingRepositoryImpl(
        remoteDataSource: _FakeRemoteDataSource(),
        tokenLocalDataSource: _FakeTokenLocalDataSource(),
      );

      expect(
        () => repository.listGroups(),
        throwsA(isA<LocationSharingApiException>()),
      );
    });

    test('ログイン済みならトークンを付けてリモートを呼び出しentityへ変換する', () async {
      final remote = _FakeRemoteDataSource();
      final repository = LocationSharingRepositoryImpl(
        remoteDataSource: remote,
        tokenLocalDataSource: _FakeTokenLocalDataSource()..token = 'fake-token',
      );

      final groups = await repository.listGroups();

      expect(remote.capturedToken, 'fake-token');
      expect(groups, hasLength(1));
      expect(groups.first.name, '家族グループ');
    });

    test('sendSos()はトークンを付けてリモートのsendSosを呼び出す', () async {
      final remote = _FakeRemoteDataSource();
      final repository = LocationSharingRepositoryImpl(
        remoteDataSource: remote,
        tokenLocalDataSource: _FakeTokenLocalDataSource()..token = 'fake-token',
      );

      await repository.sendSos(groupId: 'group-1', lat: 35.0, lng: 139.0);

      expect(remote.capturedToken, 'fake-token');
      expect(remote.sosGroupId, 'group-1');
      expect(remote.sosLat, 35.0);
      expect(remote.sosLng, 139.0);
    });

    test('removeMember()はトークンを付けてリモートのremoveMemberを呼び出す', () async {
      final remote = _FakeRemoteDataSource();
      final repository = LocationSharingRepositoryImpl(
        remoteDataSource: remote,
        tokenLocalDataSource: _FakeTokenLocalDataSource()..token = 'fake-token',
      );

      await repository.removeMember('group-1', 'user-2');

      expect(remote.capturedToken, 'fake-token');
      expect(remote.removedGroupId, 'group-1');
      expect(remote.removedUserId, 'user-2');
    });

    test('listMembers()はトークンを付けてリモートのlistMembersをentityへ変換する', () async {
      final remote = _FakeRemoteDataSource();
      final repository = LocationSharingRepositoryImpl(
        remoteDataSource: remote,
        tokenLocalDataSource: _FakeTokenLocalDataSource()..token = 'fake-token',
      );

      final members = await repository.listMembers('group-1');

      expect(remote.capturedToken, 'fake-token');
      expect(members, hasLength(1));
      expect(members.first.email, 'invited@example.com');
    });
  });
}
