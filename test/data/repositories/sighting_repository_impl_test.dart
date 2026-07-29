import 'package:flutter_test/flutter_test.dart';

import 'package:kumayokeru_app/data/datasources/local/sighting_local_datasource.dart';
import 'package:kumayokeru_app/data/datasources/remote/sightings_remote_datasource.dart';
import 'package:kumayokeru_app/data/models/sighting_cache_model.dart';
import 'package:kumayokeru_app/data/models/sighting_model.dart';
import 'package:kumayokeru_app/data/repositories/sighting_repository_impl.dart';
import 'package:kumayokeru_app/domain/entities/sighting.dart';

class _FakeRemoteDataSource extends SightingsRemoteDataSource {
  _FakeRemoteDataSource({this.result, this.error});

  final List<SightingPostModel>? result;
  final Object? error;

  @override
  Future<List<SightingPostModel>> fetchSightings() async {
    if (error != null) throw error!;
    return result!;
  }
}

class _FakeLocalDataSource extends SightingLocalDataSource {
  List<SightingCacheModel> cached = [];

  @override
  Future<void> cacheAll(List<SightingCacheModel> models) async {
    cached = models;
  }

  @override
  Future<List<SightingCacheModel>> loadCached() async => cached;
}

SightingPostModel _model(String id) {
  return SightingPostModel(
    id: id,
    lat: 35.0,
    lng: 139.0,
    sightedAt: DateTime.parse('2026-07-25T06:30:00+09:00'),
    description: '',
    areaName: '',
    sourceType: SightingSourceType.official,
  );
}

void main() {
  group('SightingRepositoryImpl.fetchSightings', () {
    test('通信成功時はリモートの結果を返し、キャッシュに保存する', () async {
      final remote = _FakeRemoteDataSource(result: [_model('seed-001')]);
      final local = _FakeLocalDataSource();
      final repository = SightingRepositoryImpl(
        remoteDataSource: remote,
        localDataSource: local,
      );

      final result = await repository.fetchSightings();

      expect(result, hasLength(1));
      expect(result.first.id, 'seed-001');

      // cacheAll()はunawaitedで呼ばれるため、マイクロタスクの完了を待つ。
      await pumpEventQueue();
      expect(local.cached, hasLength(1));
      expect(local.cached.first.sightingId, 'seed-001');
    });

    test('通信失敗時にキャッシュがあればキャッシュを返す', () async {
      final remote = _FakeRemoteDataSource(
        error: SightingsApiException('network error'),
      );
      final local = _FakeLocalDataSource()
        ..cached = [
          SightingCacheModel.fromEntity(_model('cached-1').toEntity()),
        ];
      final repository = SightingRepositoryImpl(
        remoteDataSource: remote,
        localDataSource: local,
      );

      final result = await repository.fetchSightings();

      expect(result, hasLength(1));
      expect(result.first.id, 'cached-1');
    });

    test('通信失敗時にキャッシュも空なら例外を再送出する', () async {
      final remote = _FakeRemoteDataSource(
        error: SightingsApiException('network error'),
      );
      final local = _FakeLocalDataSource();
      final repository = SightingRepositoryImpl(
        remoteDataSource: remote,
        localDataSource: local,
      );

      expect(
        () => repository.fetchSightings(),
        throwsA(isA<SightingsApiException>()),
      );
    });
  });
}
