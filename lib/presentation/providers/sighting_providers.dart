import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kumayokeru_app/data/repositories/sighting_repository_impl.dart';
import 'package:kumayokeru_app/domain/entities/sighting.dart';
import 'package:kumayokeru_app/domain/repositories/sighting_repository.dart';

final sightingRepositoryProvider = Provider<SightingRepository>((ref) {
  return SightingRepositoryImpl();
});

/// kumayokeru-backendから出没情報一覧を取得するProvider。
final sightingsProvider = FutureProvider<List<SightingPost>>((ref) {
  return ref.watch(sightingRepositoryProvider).fetchSightings();
});
