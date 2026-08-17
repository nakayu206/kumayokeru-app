import 'package:kumayokeru_app/domain/entities/current_weather.dart';

/// Open-Meteo(`GET /v1/forecast`)の`current`レスポンスに対応するモデル。
/// https://open-meteo.com/en/docs
class CurrentWeatherModel {
  const CurrentWeatherModel({
    required this.temperatureCelsius,
    required this.humidityPercent,
    required this.precipitationMm,
    required this.windSpeedKmh,
    required this.weatherCode,
    required this.observedAt,
  });

  factory CurrentWeatherModel.fromJson(Map<String, dynamic> json) {
    final current = json['current'] as Map<String, dynamic>;
    return CurrentWeatherModel(
      temperatureCelsius: (current['temperature_2m'] as num).toDouble(),
      humidityPercent: (current['relative_humidity_2m'] as num).round(),
      precipitationMm: (current['precipitation'] as num).toDouble(),
      windSpeedKmh: (current['wind_speed_10m'] as num).toDouble(),
      weatherCode: (current['weather_code'] as num).round(),
      observedAt: DateTime.parse(current['time'] as String),
    );
  }

  final double temperatureCelsius;
  final int humidityPercent;
  final double precipitationMm;
  final double windSpeedKmh;
  final int weatherCode;
  final DateTime observedAt;

  CurrentWeather toEntity() {
    return CurrentWeather(
      temperatureCelsius: temperatureCelsius,
      humidityPercent: humidityPercent,
      precipitationMm: precipitationMm,
      windSpeedKmh: windSpeedKmh,
      weatherCode: weatherCode,
      observedAt: observedAt,
    );
  }
}
