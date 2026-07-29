import 'package:kumayokeru_app/data/datasources/remote/sightings_remote_datasource.dart';
import 'package:kumayokeru_app/domain/entities/sighting.dart';
import 'package:kumayokeru_app/domain/repositories/sighting_repository.dart';

/// SightingRepositoryのkumayokeru-backend API実装。
///
/// TODO(#11): Isarへのキャッシュ(オフライン閲覧用)を追加する。
class SightingRepositoryImpl implements SightingRepository {
  SightingRepositoryImpl({SightingsRemoteDataSource? remoteDataSource})
    : _remoteDataSource = remoteDataSource ?? SightingsRemoteDataSource();

  final SightingsRemoteDataSource _remoteDataSource;

  @override
  Future<List<SightingPost>> fetchSightings() async {
    final models = await _remoteDataSource.fetchSightings();
    return models.map((model) => model.toEntity()).toList();
  }
}
