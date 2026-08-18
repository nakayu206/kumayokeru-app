import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import 'package:kumayokeru_app/core/constants/map_constants.dart';
import 'package:kumayokeru_app/data/repositories/sighting_repository_impl.dart';
import 'package:kumayokeru_app/domain/entities/sighting.dart';
import 'package:kumayokeru_app/domain/repositories/sighting_repository.dart';
import 'package:kumayokeru_app/presentation/providers/current_position_provider.dart';

final sightingRepositoryProvider = Provider<SightingRepository>((ref) {
  return SightingRepositoryImpl();
});

/// kumayokeru-backendから出没情報一覧を取得するProvider。
final sightingsProvider = FutureProvider<List<SightingPost>>((ref) {
  return ref.watch(sightingRepositoryProvider).fetchSightings();
});

/// 現在地から半径[MapConstants.nearbySightingAlertRadiusMeters]以内で最も近い目撃情報。
final nearbySightingAlertProvider = FutureProvider<SightingPost?>((ref) async {
  final position = await ref.watch(currentPositionProvider.future);
  if (position == null) return null;

  final sightings = await ref.watch(sightingsProvider.future);

  SightingPost? nearest;
  var nearestDistance = double.infinity;
  for (final sighting in sightings) {
    final distance = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      sighting.lat,
      sighting.lng,
    );
    if (distance <= MapConstants.nearbySightingAlertRadiusMeters &&
        distance < nearestDistance) {
      nearest = sighting;
      nearestDistance = distance;
    }
  }
  return nearest;
});
