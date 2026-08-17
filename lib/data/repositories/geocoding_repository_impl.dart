import 'package:kumayokeru_app/data/datasources/remote/geocoding_remote_datasource.dart';
import 'package:kumayokeru_app/domain/repositories/geocoding_repository.dart';

class GeocodingRepositoryImpl implements GeocodingRepository {
  GeocodingRepositoryImpl(this._remoteDataSource);

  final GeocodingRemoteDataSource _remoteDataSource;

  @override
  Future<String> reverseGeocode({required double lat, required double lng}) {
    return _remoteDataSource.reverseGeocode(lat: lat, lng: lng);
  }
}
