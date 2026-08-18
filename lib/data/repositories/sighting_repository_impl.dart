import 'dart:async';

import 'package:kumayokeru_app/data/datasources/local/sighting_local_datasource.dart';
import 'package:kumayokeru_app/data/datasources/remote/sightings_remote_datasource.dart';
import 'package:kumayokeru_app/data/models/sighting_cache_model.dart';
import 'package:kumayokeru_app/domain/entities/sighting.dart';
import 'package:kumayokeru_app/domain/repositories/sighting_repository.dart';

/// 取得失敗時は直近のIsarキャッシュを返す(オフライン閲覧対応)。
class SightingRepositoryImpl implements SightingRepository {
  SightingRepositoryImpl({
    SightingsRemoteDataSource? remoteDataSource,
    SightingLocalDataSource? localDataSource,
  }) : _remoteDataSource = remoteDataSource ?? SightingsRemoteDataSource(),
       _localDataSource = localDataSource ?? SightingLocalDataSource();

  final SightingsRemoteDataSource _remoteDataSource;
  final SightingLocalDataSource _localDataSource;

  @override
  Future<List<SightingPost>> fetchSightings() async {
    try {
      final models = await _remoteDataSource.fetchSightings();
      final entities = models.map((model) => model.toEntity()).toList();
      unawaited(
        _localDataSource.cacheAll(
          entities.map(SightingCacheModel.fromEntity).toList(),
        ),
      );
      return entities;
    } on SightingsApiException {
      final cached = await _localDataSource.loadCached();
      if (cached.isEmpty) rethrow;
      return cached.map((model) => model.toEntity()).toList();
    }
  }

  @override
  Future<SightingPost> postSighting({
    required double lat,
    required double lng,
    String? description,
    String? areaName,
  }) async {
    final model = await _remoteDataSource.postSighting(
      lat: lat,
      lng: lng,
      description: description,
      areaName: areaName,
    );
    return model.toEntity();
  }
}
