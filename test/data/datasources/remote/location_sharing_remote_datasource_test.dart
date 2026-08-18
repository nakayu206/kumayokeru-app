import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:kumayokeru_app/data/datasources/remote/location_sharing_remote_datasource.dart';

http.Response _jsonResponse(Object body, int statusCode) {
  return http.Response(
    jsonEncode(body),
    statusCode,
    headers: {'content-type': 'application/json; charset=utf-8'},
  );
}

void main() {
  group('LocationSharingRemoteDataSource', () {
    test('listGroups()はAuthorizationヘッダーを付与してGET /groupsを叩く', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.url.path, '/groups');
        expect(request.headers['authorization'], 'Bearer fake-token');
        return _jsonResponse([
          {
            'id': 'group-1',
            'name': '家族グループ',
            'ownerUserId': 'user-1',
            'createdAt': '2026-07-25T06:30:00+09:00',
          },
        ], 200);
      });

      final dataSource = LocationSharingRemoteDataSource(client: mockClient);
      final result = await dataSource.listGroups('fake-token');

      expect(result, hasLength(1));
      expect(result.first['name'], '家族グループ');
    });

    test('postLocation()はlat/lngをbodyに含めてPOST /locationsを叩く', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.path, '/locations');
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['lat'], 35.0);
        expect(body['lng'], 139.0);
        return _jsonResponse({
          'userId': 'user-1',
          'email': 'a@example.com',
          'lat': 35.0,
          'lng': 139.0,
          'recordedAt': '2026-07-25T06:30:00+09:00',
        }, 201);
      });

      final dataSource = LocationSharingRemoteDataSource(client: mockClient);
      final result = await dataSource.postLocation(
        'fake-token',
        lat: 35.0,
        lng: 139.0,
      );

      expect(result['userId'], 'user-1');
    });

    test('pollLocations()はgroupIdをクエリに含めてGET /locationsを叩く', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, '/locations');
        expect(request.url.queryParameters['groupId'], 'group-1');
        return _jsonResponse([], 200);
      });

      final dataSource = LocationSharingRemoteDataSource(client: mockClient);
      final result = await dataSource.pollLocations('fake-token', 'group-1');

      expect(result, isEmpty);
    });

    test('removeMember()はDELETE /groups/:groupId/members/:userIdを叩く', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, 'DELETE');
        expect(request.url.path, '/groups/group-1/members/user-2');
        expect(request.headers['authorization'], 'Bearer fake-token');
        return http.Response('', 204);
      });

      final dataSource = LocationSharingRemoteDataSource(client: mockClient);

      await dataSource.removeMember('fake-token', 'group-1', 'user-2');
    });

    test('removeMember()は204以外の応答でLocationSharingApiExceptionを投げる', () async {
      final mockClient = MockClient((request) async {
        return _jsonResponse({
          'error': '他のメンバーを削除できるのはグループのオーナーのみです',
        }, 403);
      });

      final dataSource = LocationSharingRemoteDataSource(client: mockClient);

      expect(
        () => dataSource.removeMember('fake-token', 'group-1', 'user-2'),
        throwsA(isA<LocationSharingApiException>()),
      );
    });

    test('403応答はLocationSharingApiExceptionを投げる', () async {
      final mockClient = MockClient((request) async {
        return _jsonResponse({'error': 'このグループのメンバーではありません'}, 403);
      });

      final dataSource = LocationSharingRemoteDataSource(client: mockClient);

      expect(
        () => dataSource.pollLocations('fake-token', 'group-1'),
        throwsA(isA<LocationSharingApiException>()),
      );
    });
  });
}
