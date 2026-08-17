import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kumayokeru_app/core/constants/map_constants.dart';
import 'package:kumayokeru_app/data/datasources/remote/weather_remote_datasource.dart';
import 'package:kumayokeru_app/data/repositories/weather_repository_impl.dart';
import 'package:kumayokeru_app/domain/entities/current_weather.dart';
import 'package:kumayokeru_app/domain/repositories/weather_repository.dart';
import 'package:kumayokeru_app/presentation/providers/current_position_provider.dart';

final weatherRepositoryProvider = Provider<WeatherRepository>((ref) {
  return WeatherRepositoryImpl(WeatherRemoteDataSource());
});

/// 現在地の天気(Open-Meteo)。位置情報が取得できない場合はデフォルト座標を使う。
final currentWeatherProvider = FutureProvider<CurrentWeather>((ref) async {
  final position = await ref.watch(currentPositionProvider.future);
  final lat = position?.latitude ?? MapConstants.defaultLat;
  final lng = position?.longitude ?? MapConstants.defaultLng;

  return ref
      .watch(weatherRepositoryProvider)
      .fetchCurrentWeather(lat: lat, lng: lng);
});
