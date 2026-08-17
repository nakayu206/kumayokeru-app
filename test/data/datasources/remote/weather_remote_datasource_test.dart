import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:kumayokeru_app/data/datasources/remote/weather_remote_datasource.dart';

void main() {
  group('WeatherRemoteDataSource.fetchCurrentWeather', () {
    test('緯度経度をクエリに含めてGETし、200応答をパースする', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.url.path, '/v1/forecast');
        expect(request.url.queryParameters['latitude'], '35.6895');
        expect(request.url.queryParameters['longitude'], '139.6917');

        return http.Response(
          jsonEncode({
            'current': {
              'time': '2026-08-17T16:00',
              'temperature_2m': 29.8,
              'relative_humidity_2m': 61,
              'precipitation': 0.0,
              'weather_code': 1,
              'wind_speed_10m': 6.4,
            },
          }),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });

      final dataSource = WeatherRemoteDataSource(client: mockClient);
      final result = await dataSource.fetchCurrentWeather(
        lat: 35.6895,
        lng: 139.6917,
      );

      expect(result.temperatureCelsius, 29.8);
      expect(result.humidityPercent, 61);
      expect(result.weatherCode, 1);
      expect(result.windSpeedKmh, 6.4);
    });

    test('200以外の応答はWeatherApiExceptionを投げる', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Internal Server Error', 500);
      });

      final dataSource = WeatherRemoteDataSource(client: mockClient);

      expect(
        () => dataSource.fetchCurrentWeather(lat: 0, lng: 0),
        throwsA(isA<WeatherApiException>()),
      );
    });
  });
}
