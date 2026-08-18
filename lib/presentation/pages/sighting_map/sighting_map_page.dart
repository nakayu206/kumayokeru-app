import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import 'package:kumayokeru_app/core/constants/app_colors.dart';
import 'package:kumayokeru_app/core/constants/app_sizes.dart';
import 'package:kumayokeru_app/core/constants/app_spacing.dart';
import 'package:kumayokeru_app/core/constants/map_constants.dart';
import 'package:kumayokeru_app/domain/entities/sighting.dart';
import 'package:kumayokeru_app/infrastructure/offline_tile_provider.dart';
import 'package:kumayokeru_app/presentation/providers/current_position_provider.dart';
import 'package:kumayokeru_app/presentation/providers/offline_map_providers.dart';
import 'package:kumayokeru_app/presentation/providers/sighting_providers.dart';
import 'package:kumayokeru_app/presentation/widgets/common/error_dialog.dart';
import 'package:kumayokeru_app/presentation/widgets/common/error_text.dart';

/// クマの足跡マークの色。自治体公式データは濃い茶色、ユーザー投稿は薄い茶色で
/// 区別する(デザイントークン: 出没情報ピンは自治体公式データとユーザー投稿を
/// 色・アイコンで明確に区別する方針)。
Color _sightingColor(SightingSourceType sourceType) {
  return sourceType == SightingSourceType.official
      ? const Color(0xFF6D4C29)
      : const Color(0xFFB08968);
}

/// 出没情報マップ画面(仕様書セクション12 ②)。
///
/// kumayokeru-backend(https://57-182-248-130.sslip.io)の`GET /sightings`から取得した実データを表示する。
/// 目撃情報の投稿(`POST /sightings`)は認証不要で誰でも可能。
/// 現在地はgeolocatorで取得でき次第、地図の中心とマーカーに反映する
/// (取得できるまで/失敗時はデフォルト座標を表示)。
/// 現在地が分かっている場合、一覧は現在地から近い順に並び替える。
/// 地域名・状況テキストでの検索、一覧タップでの地図フォーカスにも対応。
/// 地図右下の現在地ボタンで、最新の現在地を取り直して地図を戻せる。
class SightingMapPage extends ConsumerStatefulWidget {
  const SightingMapPage({super.key});

  @override
  ConsumerState<SightingMapPage> createState() => _SightingMapPageState();
}

class _SightingMapPageState extends ConsumerState<SightingMapPage> {
  final _mapController = MapController();
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _mapController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sightingsAsync = ref.watch(sightingsProvider);
    final currentPositionAsync = ref.watch(currentPositionProvider);
    final currentPosition = currentPositionAsync.valueOrNull;

    ref.listen(currentPositionProvider, (previous, next) {
      final position = next.valueOrNull;
      if (position != null) {
        _mapController.move(
          LatLng(position.latitude, position.longitude),
          MapConstants.defaultZoom,
        );
      }
    });

    final currentLatLng = currentPositionAsync.valueOrNull != null
        ? LatLng(
            currentPositionAsync.value!.latitude,
            currentPositionAsync.value!.longitude,
          )
        : const LatLng(MapConstants.defaultLat, MapConstants.defaultLng);

    return Scaffold(
      appBar: AppBar(title: const Text('出没情報マップ')),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: currentLatLng,
                    initialZoom: MapConstants.defaultZoom,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: MapConstants.tileUrlTemplate,
                      userAgentPackageName: 'com.kumayokeru.app',
                      tileProvider: OfflineFirstTileProvider(
                        ref.watch(offlineMapServiceProvider),
                      ),
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: currentLatLng,
                          child: Icon(
                            Icons.my_location,
                            color: AppColors.primary,
                          ),
                        ),
                        ...sightingsAsync.maybeWhen(
                          data: (sightings) => sightings.map(
                            (sighting) => Marker(
                              point: LatLng(sighting.lat, sighting.lng),
                              child: Icon(
                                Icons.pets,
                                color: _sightingColor(sighting.sourceType),
                              ),
                            ),
                          ),
                          orElse: () => const <Marker>[],
                        ),
                      ],
                    ),
                  ],
                ),
                Positioned(
                  right: AppSpacing.md,
                  bottom: AppSpacing.md,
                  child: FloatingActionButton.small(
                    heroTag: 'sighting_map_recenter',
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    onPressed: () => _recenterToCurrentLocation(context),
                    child: const Icon(Icons.my_location),
                  ),
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
                onPressed: () => _showPostSightingDialog(context, ref),
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
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '地域名・状況で検索',
                prefixIcon: const Icon(Icons.search),
                isDense: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                ),
              ),
              onChanged: (value) => setState(() => _searchQuery = value.trim()),
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
                data: (sightings) {
                  final filtered = _filterAndSort(sightings, currentPosition);
                  if (filtered.isEmpty) {
                    return Center(
                      child: Text(
                        '該当する目撃情報がありません',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    );
                  }
                  return ListView(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.sm,
                        ),
                        child: Text(
                          currentPosition == null ? '最新の目撃情報' : '現在地に近い目撃情報',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: AppSizes.fontMd,
                          ),
                        ),
                      ),
                      for (final sighting in filtered)
                        _SightingTile(
                          sighting: sighting,
                          onTap: () => _focusOnSighting(sighting),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _focusOnSighting(SightingPost sighting) {
    _mapController.move(
      LatLng(sighting.lat, sighting.lng),
      MapConstants.detailZoom,
    );
  }

  /// ボタン押下時点の最新の現在地を取り直してから地図を移動する
  /// (initialCenterは初回表示時点の値のまま更新されないため)。
  Future<void> _recenterToCurrentLocation(BuildContext context) async {
    final position = await ref.refresh(currentPositionProvider.future);
    if (!context.mounted) return;

    if (position == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('現在地を取得できませんでした')),
      );
      return;
    }

    _mapController.move(
      LatLng(position.latitude, position.longitude),
      MapConstants.defaultZoom,
    );
  }

  List<SightingPost> _filterAndSort(
    List<SightingPost> sightings,
    Position? currentPosition,
  ) {
    var result = sightings;
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      result = result
          .where(
            (sighting) =>
                sighting.areaName.toLowerCase().contains(query) ||
                sighting.description.toLowerCase().contains(query),
          )
          .toList();
    }

    if (currentPosition != null) {
      result = [...result]
        ..sort((a, b) {
          final distanceA = Geolocator.distanceBetween(
            currentPosition.latitude,
            currentPosition.longitude,
            a.lat,
            a.lng,
          );
          final distanceB = Geolocator.distanceBetween(
            currentPosition.latitude,
            currentPosition.longitude,
            b.lat,
            b.lng,
          );
          return distanceA.compareTo(distanceB);
        });
    }

    return result;
  }

  Future<void> _showPostSightingDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final descriptionController = TextEditingController();
    var isSubmitting = false;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: const Text('目撃情報を投稿する'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: descriptionController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: '目撃状況(任意)',
                      hintText: '例: 林道脇で単独個体を目撃',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    '現在地を目撃場所として送信します',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: AppSizes.fontSm,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting
                      ? null
                      : () => Navigator.of(dialogContext).pop(),
                  child: const Text('キャンセル'),
                ),
                FilledButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          setDialogState(() => isSubmitting = true);
                          final error = await _submitSighting(
                            ref,
                            description: descriptionController.text.trim(),
                          );
                          if (!dialogContext.mounted) return;
                          Navigator.of(dialogContext).pop();
                          if (!context.mounted) return;
                          if (error != null) {
                            await showErrorDialog(context, error);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('目撃情報を投稿しました')),
                            );
                          }
                        },
                  child: isSubmitting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('投稿する'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<String?> _submitSighting(
    WidgetRef ref, {
    required String description,
  }) async {
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return '位置情報の権限が許可されていません';
      }

      final position = await Geolocator.getCurrentPosition();
      await ref
          .read(sightingRepositoryProvider)
          .postSighting(
            lat: position.latitude,
            lng: position.longitude,
            description: description.isEmpty ? null : description,
          );
      ref.invalidate(sightingsProvider);
      return null;
    } on Exception catch (e) {
      return '投稿に失敗しました: $e';
    }
  }
}

class _SightingTile extends StatelessWidget {
  const _SightingTile({required this.sighting, required this.onTap});

  final SightingPost sighting;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isOfficial = sighting.sourceType == SightingSourceType.official;
    final date =
        '${sighting.sightedAt.year}/${sighting.sightedAt.month.toString().padLeft(2, '0')}/${sighting.sightedAt.day.toString().padLeft(2, '0')}';

    return ListTile(
      onTap: onTap,
      leading: Icon(
        Icons.pets,
        color: _sightingColor(sighting.sourceType),
        size: AppSizes.fontXl,
      ),
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
