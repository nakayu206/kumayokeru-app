import 'package:kumayokeru_app/domain/entities/current_weather.dart';

abstract interface class WeatherRepository {
  Future<CurrentWeather> fetchCurrentWeather({
    required double lat,
    required double lng,
  });
}
