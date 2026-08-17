import 'package:kumayokeru_app/data/datasources/remote/weather_remote_datasource.dart';
import 'package:kumayokeru_app/domain/entities/current_weather.dart';
import 'package:kumayokeru_app/domain/repositories/weather_repository.dart';

class WeatherRepositoryImpl implements WeatherRepository {
  WeatherRepositoryImpl(this._remoteDataSource);

  final WeatherRemoteDataSource _remoteDataSource;

  @override
  Future<CurrentWeather> fetchCurrentWeather({
    required double lat,
    required double lng,
  }) async {
    final model = await _remoteDataSource.fetchCurrentWeather(
      lat: lat,
      lng: lng,
    );
    return model.toEntity();
  }
}
