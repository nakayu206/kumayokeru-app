import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:kumayokeru_app/infrastructure/offline_map_service.dart';

void main() {
  group('FileOfflineMapService', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('offline_map_test');
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('未キャッシュのタイルはネットワークから取得して保存する', () async {
      var requestCount = 0;
      final client = MockClient((request) async {
        requestCount++;
        return http.Response.bytes([1, 2, 3], 200);
      });
      final service = FileOfflineMapService(
        httpClient: client,
        baseDirectory: tempDir,
      );

      final bytes = await service.loadTile(
        z: 5,
        x: 10,
        y: 12,
        url: 'https://example.com/5/10/12.png',
      );

      expect(bytes, [1, 2, 3]);
      expect(requestCount, 1);
      expect(await service.cachedTileCount(), 1);
    });

    test('キャッシュ済みのタイルはネットワークにアクセスしない', () async {
      var requestCount = 0;
      final client = MockClient((request) async {
        requestCount++;
        return http.Response.bytes([9, 9, 9], 200);
      });
      final service = FileOfflineMapService(
        httpClient: client,
        baseDirectory: tempDir,
      );

      await service.loadTile(z: 1, x: 1, y: 1, url: 'https://example.com/x');
      await service.loadTile(z: 1, x: 1, y: 1, url: 'https://example.com/x');

      expect(requestCount, 1);
    });

    test('HTTPエラー時はOfflineMapExceptionを投げる', () async {
      final client = MockClient((request) async => http.Response('', 500));
      final service = FileOfflineMapService(
        httpClient: client,
        baseDirectory: tempDir,
      );

      expect(
        () => service.loadTile(z: 1, x: 1, y: 1, url: 'https://example.com/x'),
        throwsA(isA<OfflineMapException>()),
      );
    });

    test('downloadRegionは範囲内のタイルを全てダウンロードし進捗を通知する', () async {
      final client = MockClient((request) async {
        return http.Response.bytes([1], 200);
      });
      final service = FileOfflineMapService(
        httpClient: client,
        baseDirectory: tempDir,
      );

      final progresses = await service
          .downloadRegion(
            urlTemplate: 'https://example.com/{z}/{x}/{y}.png',
            centerLat: 35.0,
            centerLng: 139.0,
            radiusKm: 1,
            minZoom: 14,
            maxZoom: 14,
          )
          .toList();

      expect(progresses.last.isDone, isTrue);
      expect(await service.cachedTileCount(), progresses.last.total);
      expect(progresses.last.total, greaterThan(0));
    });

    test('clearCacheでキャッシュが空になる', () async {
      final client = MockClient(
        (request) async => http.Response.bytes([1], 200),
      );
      final service = FileOfflineMapService(
        httpClient: client,
        baseDirectory: tempDir,
      );

      await service.loadTile(z: 1, x: 1, y: 1, url: 'https://example.com/x');
      expect(await service.cachedTileCount(), 1);

      await service.clearCache();
      expect(await service.cachedTileCount(), 0);
      expect(await service.cachedSizeBytes(), 0);
    });
  });
}
