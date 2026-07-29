import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'package:kumayokeru_app/core/constants/app_colors.dart';
import 'package:kumayokeru_app/core/constants/app_sizes.dart';
import 'package:kumayokeru_app/core/constants/app_spacing.dart';
import 'package:kumayokeru_app/core/constants/map_constants.dart';

class _DummySighting {
  const _DummySighting({required this.date, required this.place, required this.isOfficial});

  final String date;
  final String place;
  final bool isOfficial;
}

const _dummySightings = [
  _DummySighting(date: '2026/07/25', place: '●●林道付近', isOfficial: false),
  _DummySighting(date: '2026/07/23', place: '●●峠', isOfficial: true),
];

/// 出没情報マップ画面(仕様書セクション12 ②)。
///
/// TODO(#11): flutter_map上のピンとリストを実データ(Isar)と結合する。
class SightingMapPage extends StatelessWidget {
  const SightingMapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('出没情報マップ')),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: FlutterMap(
              options: const MapOptions(
                initialCenter: LatLng(MapConstants.defaultLat, MapConstants.defaultLng),
                initialZoom: MapConstants.defaultZoom,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.kumayokeru.app',
                ),
                const MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(MapConstants.defaultLat, MapConstants.defaultLng),
                      child: Icon(Icons.my_location, color: AppColors.primary),
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusMd)),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  child: Text('最新の目撃情報', style: TextStyle(fontWeight: FontWeight.bold, fontSize: AppSizes.fontMd)),
                ),
                for (final sighting in _dummySightings) _SightingTile(sighting: sighting),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SightingTile extends StatelessWidget {
  const _SightingTile({required this.sighting});

  final _DummySighting sighting;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Text('🐾', style: TextStyle(fontSize: AppSizes.fontXl)),
      title: Text('${sighting.date} ${sighting.place}'),
      trailing: Chip(
        label: Text(sighting.isOfficial ? '自治体' : '投稿'),
        backgroundColor: sighting.isOfficial ? AppColors.primaryLight : AppColors.warning.withValues(alpha: 0.15),
      ),
    );
  }
}
