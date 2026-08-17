import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:kumayokeru_app/data/datasources/remote/geocoding_remote_datasource.dart';

void main() {
  group('GeocodingRemoteDataSource.reverseGeocode', () {
    test('道路名(登山道)と市区町村があれば両方を組み合わせて返す', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.url.path, '/reverse');
        expect(request.headers['User-Agent'], isNotNull);

        return http.Response(
          jsonEncode({
            'address': {'road': '稲荷山線歩道', 'city': '八王子市'},
          }),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });

      final dataSource = GeocodingRemoteDataSource(client: mockClient);
      final result = await dataSource.reverseGeocode(lat: 35.6, lng: 139.2);

      expect(result, '八王子市 稲荷山線歩道');
    });

    test('市区町村しか無ければ市区町村のみを返す', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'address': {'city': '新宿区'},
          }),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });

      final dataSource = GeocodingRemoteDataSource(client: mockClient);
      final result = await dataSource.reverseGeocode(lat: 35.6, lng: 139.2);

      expect(result, '新宿区');
    });

    test('200以外の応答はGeocodingApiExceptionを投げる', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Internal Server Error', 500);
      });

      final dataSource = GeocodingRemoteDataSource(client: mockClient);

      expect(
        () => dataSource.reverseGeocode(lat: 0, lng: 0),
        throwsA(isA<GeocodingApiException>()),
      );
    });

    test('住所情報が無い応答はGeocodingApiExceptionを投げる', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode(<String, dynamic>{}),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });

      final dataSource = GeocodingRemoteDataSource(client: mockClient);

      expect(
        () => dataSource.reverseGeocode(lat: 0, lng: 0),
        throwsA(isA<GeocodingApiException>()),
      );
    });
  });
}
