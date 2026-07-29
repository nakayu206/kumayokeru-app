import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import 'package:kumayokeru_app/core/constants/app_colors.dart';
import 'package:kumayokeru_app/core/constants/app_sizes.dart';
import 'package:kumayokeru_app/core/constants/app_spacing.dart';
import 'package:kumayokeru_app/core/constants/map_constants.dart';
import 'package:kumayokeru_app/domain/entities/sighting.dart';
import 'package:kumayokeru_app/presentation/providers/sighting_providers.dart';
import 'package:kumayokeru_app/presentation/widgets/common/error_text.dart';

/// 出没情報マップ画面(仕様書セクション12 ②)。
///
/// kumayokeru-backend(https://57-182-248-130.sslip.io)の`GET /sightings`から取得した実データを表示する。
/// TODO(#11): Isarへのキャッシュ(オフライン閲覧用)、距離絞り込みと結合する。
/// TODO(#12): 「目撃情報を投稿する」ボタンから`POST /sightings`への投稿を実装する。
class SightingMapPage extends ConsumerWidget {
  const SightingMapPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sightingsAsync = ref.watch(sightingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('出没情報マップ')),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: FlutterMap(
              options: const MapOptions(
                initialCenter: LatLng(
                  MapConstants.defaultLat,
                  MapConstants.defaultLng,
                ),
                initialZoom: MapConstants.defaultZoom,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.kumayokeru.app',
                ),
                MarkerLayer(
                  markers: [
                    const Marker(
                      point: LatLng(
                        MapConstants.defaultLat,
                        MapConstants.defaultLng,
                      ),
                      child: Icon(Icons.my_location, color: AppColors.primary),
                    ),
                    ...sightingsAsync.maybeWhen(
                      data: (sightings) => sightings.map(
                        (sighting) => Marker(
                          point: LatLng(sighting.lat, sighting.lng),
                          child: Icon(
                            Icons.pets,
                            color:
                                sighting.sourceType ==
                                    SightingSourceType.official
                                ? AppColors.primaryDark
                                : AppColors.warning,
                          ),
                        ),
                      ),
                      orElse: () => const <Marker>[],
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: SizedBox(
              width: double.infinity,
              height: AppSizes.buttonHeight,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add_location_alt_outlined),
                label: const Text('目撃情報を投稿する'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: sightingsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(
                  child: ErrorText(
                    '出没情報の取得に失敗しました\n$error',
                    textAlign: TextAlign.center,
                  ),
                ),
                data: (sightings) => ListView(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.sm,
                      ),
                      child: Text(
                        '最新の目撃情報',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: AppSizes.fontMd,
                        ),
                      ),
                    ),
                    for (final sighting in sightings)
                      _SightingTile(sighting: sighting),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SightingTile extends StatelessWidget {
  const _SightingTile({required this.sighting});

  final SightingPost sighting;

  @override
  Widget build(BuildContext context) {
    final isOfficial = sighting.sourceType == SightingSourceType.official;
    final date =
        '${sighting.sightedAt.year}/${sighting.sightedAt.month.toString().padLeft(2, '0')}/${sighting.sightedAt.day.toString().padLeft(2, '0')}';

    return ListTile(
      leading: const Text('🐾', style: TextStyle(fontSize: AppSizes.fontXl)),
      title: Text('$date ${sighting.areaName}'),
      subtitle: sighting.description.isEmpty
          ? null
          : Text(sighting.description),
      trailing: Chip(
        label: Text(isOfficial ? '自治体' : '投稿'),
        backgroundColor: isOfficial
            ? AppColors.primaryLight
            : AppColors.warning.withValues(alpha: 0.15),
      ),
    );
  }
}
