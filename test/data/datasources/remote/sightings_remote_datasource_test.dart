import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:kumayokeru_app/data/datasources/remote/sightings_remote_datasource.dart';

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
}
