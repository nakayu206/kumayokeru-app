/// 現在地の天気(Open-Meteo APIから取得)。
class CurrentWeather {
  const CurrentWeather({
    required this.temperatureCelsius,
    required this.humidityPercent,
    required this.precipitationMm,
    required this.windSpeedKmh,
    required this.weatherCode,
    required this.observedAt,
  });

  final double temperatureCelsius;
  final int humidityPercent;
  final double precipitationMm;
  final double windSpeedKmh;

  /// WMO Weather interpretation code(Open-Meteoの天気コード)。
  final int weatherCode;
  final DateTime observedAt;
}
