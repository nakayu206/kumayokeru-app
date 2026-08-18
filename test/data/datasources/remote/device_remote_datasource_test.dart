import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:kumayokeru_app/data/datasources/remote/device_remote_datasource.dart';

http.Response _jsonResponse(Object body, int statusCode) {
  return http.Response(
    jsonEncode(body),
    statusCode,
    headers: {'content-type': 'application/json; charset=utf-8'},
  );
}

void main() {
  group('DeviceRemoteDataSource', () {
    test('registerToken()はAuthorizationヘッダーを付与してPOST /devicesを叩く', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.path, '/devices');
        expect(request.headers['authorization'], 'Bearer fake-token');
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['token'], 'fcm-token');
        expect(body['platform'], 'android');
        return _jsonResponse({'id': 'device-1'}, 201);
      });

      final dataSource = DeviceRemoteDataSource(client: mockClient);

      await dataSource.registerToken(
        'fake-token',
        deviceToken: 'fcm-token',
        platform: 'android',
      );
    });

    test('201以外の応答はDeviceApiExceptionを投げる', () async {
      final mockClient = MockClient((request) async {
        return _jsonResponse({'error': 'platform は "android" か "ios" で指定してください'}, 400);
      });

      final dataSource = DeviceRemoteDataSource(client: mockClient);

      expect(
        () => dataSource.registerToken(
          'fake-token',
          deviceToken: 'fcm-token',
          platform: 'invalid',
        ),
        throwsA(isA<DeviceApiException>()),
      );
    });
  });
}
