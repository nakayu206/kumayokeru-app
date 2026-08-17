import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:kumayokeru_app/data/models/weather_model.dart';

/// Open-Meteo(https://open-meteo.com)への通信に失敗した場合の例外。
class WeatherApiException implements Exception {
  WeatherApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Open-Meteoの天気API(`GET /v1/forecast`)を呼び出すデータソース。
/// APIキー不要・非商用利用無料。https://open-meteo.com/en/docs
class WeatherRemoteDataSource {
  WeatherRemoteDataSource({http.Client? client, Uri? baseUrl})
    : _client = client ?? http.Client(),
      _baseUrl = baseUrl ?? Uri.parse('https://api.open-meteo.com');

  final http.Client _client;
  final Uri _baseUrl;

  Future<CurrentWeatherModel> fetchCurrentWeather({
    required double lat,
    required double lng,
  }) async {
    final uri = _baseUrl.replace(
      path: '/v1/forecast',
      queryParameters: {
        'latitude': lat.toString(),
        'longitude': lng.toString(),
        'current':
            'temperature_2m,relative_humidity_2m,precipitation,weather_code,wind_speed_10m',
        'timezone': 'Asia/Tokyo',
      },
    );

    final http.Response response;
    try {
      response = await _client.get(uri);
    } on Exception catch (e) {
      throw WeatherApiException('天気情報の取得に失敗しました(通信エラー: $e)');
    }

    if (response.statusCode != 200) {
      throw WeatherApiException(
        '天気情報の取得に失敗しました(status: ${response.statusCode})',
      );
    }

    final body =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    return CurrentWeatherModel.fromJson(body);
  }
}
