import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kumayokeru_app/infrastructure/offline_map_service.dart';

final offlineMapServiceProvider = Provider<OfflineMapService>((ref) {
  return FileOfflineMapService();
});

/// 「地図データ管理」画面でのキャッシュ状況表示用。
final offlineMapCacheStatsProvider = FutureProvider.autoDispose((ref) async {
  final service = ref.watch(offlineMapServiceProvider);
  final count = await service.cachedTileCount();
  final sizeBytes = await service.cachedSizeBytes();
  return (tileCount: count, sizeBytes: sizeBytes);
});
