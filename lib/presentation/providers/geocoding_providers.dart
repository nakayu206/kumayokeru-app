import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kumayokeru_app/core/constants/map_constants.dart';
import 'package:kumayokeru_app/data/datasources/remote/geocoding_remote_datasource.dart';
import 'package:kumayokeru_app/data/repositories/geocoding_repository_impl.dart';
import 'package:kumayokeru_app/domain/repositories/geocoding_repository.dart';
import 'package:kumayokeru_app/presentation/providers/current_position_provider.dart';

final geocodingRepositoryProvider = Provider<GeocodingRepository>((ref) {
  return GeocodingRepositoryImpl(GeocodingRemoteDataSource());
});

/// 現在地の地名(市区町村+登山道・地区名程度の粒度)。
/// 位置情報が取得できない場合はデフォルト座標を使う。
final currentLocationLabelProvider = FutureProvider<String>((ref) async {
  final position = await ref.watch(currentPositionProvider.future);
  final lat = position?.latitude ?? MapConstants.defaultLat;
  final lng = position?.longitude ?? MapConstants.defaultLng;

  return ref
      .watch(geocodingRepositoryProvider)
      .reverseGeocode(lat: lat, lng: lng);
});
