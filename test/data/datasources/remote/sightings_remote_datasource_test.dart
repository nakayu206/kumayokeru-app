import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:kumayokeru_app/data/datasources/remote/sightings_remote_datasource.dart';
import 'package:kumayokeru_app/domain/entities/sighting.dart';

void main() {
  group('SightingsRemoteDataSource.fetchSightings', () {
    test('200応答をSightingPostModelのリストにパースする', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, '/sightings');
        return http.Response(
          jsonEncode([
            {
              'id': 'seed-001',
              'lat': 35.7897,
              'lng': 139.0197,
              'sightedAt': '2026-07-25T06:30:00+09:00',
              'description': '林道脇で単独個体を目撃',
              'areaName': '奥多摩・雲取山周辺',
              'sourceType': 'official',
            },
          ]),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });

      final dataSource = SightingsRemoteDataSource(client: mockClient);
      final result = await dataSource.fetchSightings();

      expect(result, hasLength(1));
      expect(result.first.id, 'seed-001');
      expect(result.first.areaName, '奥多摩・雲取山周辺');
    });

    test('200以外の応答はSightingsApiExceptionを投げる', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Internal Server Error', 500);
      });

      final dataSource = SightingsRemoteDataSource(client: mockClient);

      expect(
        () => dataSource.fetchSightings(),
        throwsA(isA<SightingsApiException>()),
      );
    });
  });

  group('SightingsRemoteDataSource.postSighting', () {
    test('lat/lng/descriptionをbodyに含めてPOSTし、201応答をパースする', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.path, '/sightings');
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['lat'], 35.0);
        expect(body['lng'], 139.0);
        expect(body['description'], '林道脇で単独個体を目撃');

        return http.Response(
          jsonEncode({
            'id': 'user-1',
            'lat': 35.0,
            'lng': 139.0,
            'sightedAt': '2026-07-29T06:30:00+09:00',
            'description': '林道脇で単独個体を目撃',
            'areaName': '',
            'sourceType': 'user',
          }),
          201,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });

      final dataSource = SightingsRemoteDataSource(client: mockClient);
      final result = await dataSource.postSighting(
        lat: 35.0,
        lng: 139.0,
        description: '林道脇で単独個体を目撃',
      );

      expect(result.id, 'user-1');
      expect(result.sourceType, SightingSourceType.user);
    });

    test('200以外の応答はSightingsApiExceptionを投げる', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({'error': 'lat, lng は必須です'}),
          400,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });

      final dataSource = SightingsRemoteDataSource(client: mockClient);

      expect(
        () => dataSource.postSighting(lat: 999, lng: 999),
        throwsA(isA<SightingsApiException>()),
      );
    });
  });
}
