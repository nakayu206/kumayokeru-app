import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kumayokeru_app/core/constants/app_colors.dart';
import 'package:kumayokeru_app/core/constants/app_sizes.dart';
import 'package:kumayokeru_app/core/constants/app_spacing.dart';
import 'package:kumayokeru_app/core/constants/map_constants.dart';
import 'package:kumayokeru_app/infrastructure/offline_map_service.dart';
import 'package:kumayokeru_app/presentation/providers/current_position_provider.dart';
import 'package:kumayokeru_app/presentation/providers/offline_map_providers.dart';
import 'package:kumayokeru_app/presentation/widgets/common/error_dialog.dart';

/// 地図データ管理画面。
///
/// 現在地周辺(半径[MapConstants.offlineDownloadRadiusKm]km)の地図タイルを
/// 事前ダウンロードし、電波の届かない山中でもオフライン閲覧できるようにする。
/// flutter_map_tile_caching(GPL v3)を使わず自前実装した[OfflineMapService]を利用する。
class MapDataManagementPage extends ConsumerStatefulWidget {
  const MapDataManagementPage({super.key});

  @override
  ConsumerState<MapDataManagementPage> createState() =>
      _MapDataManagementPageState();
}

class _MapDataManagementPageState extends ConsumerState<MapDataManagementPage> {
  TileDownloadProgress? _progress;
  StreamSubscription<TileDownloadProgress>? _subscription;

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(offlineMapCacheStatsProvider);
    final isDownloading = _progress != null && !(_progress!.isDone);

    return Scaffold(
      appBar: AppBar(title: const Text('地図データ管理')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Text(
            '現在地から半径${MapConstants.offlineDownloadRadiusKm.toStringAsFixed(0)}kmの地図をダウンロードすると、'
            '電波が届かない山中でも地図を表示できます。',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: AppSizes.fontSm,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          statsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Text('キャッシュ状況の取得に失敗しました: $error'),
            data: (stats) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.map_outlined),
              title: Text('保存済みタイル: ${stats.tileCount}枚'),
              subtitle: Text(
                '容量: ${(stats.sizeBytes / 1024 / 1024).toStringAsFixed(1)}MB',
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (_progress != null) ...[
            LinearProgressIndicator(value: _progress!.ratio),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '${_progress!.completed} / ${_progress!.total}タイル',
              style: TextStyle(fontSize: AppSizes.fontSm),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          SizedBox(
            width: double.infinity,
            height: AppSizes.buttonHeight,
            child: ElevatedButton.icon(
              onPressed: isDownloading ? null : _startDownload,
              icon: const Icon(Icons.download_outlined),
              label: Text(isDownloading ? 'ダウンロード中...' : '現在地周辺をダウンロード'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            width: double.infinity,
            height: AppSizes.buttonHeight,
            child: OutlinedButton.icon(
              onPressed: isDownloading ? null : _confirmClearCache,
              icon: const Icon(Icons.delete_outline),
              label: const Text('キャッシュを削除'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.danger,
                side: BorderSide(color: AppColors.danger),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _startDownload() async {
    final position = await ref.read(currentPositionProvider.future);
    final centerLat = position?.latitude ?? MapConstants.defaultLat;
    final centerLng = position?.longitude ?? MapConstants.defaultLng;

    final service = ref.read(offlineMapServiceProvider);
    setState(
      () => _progress = const TileDownloadProgress(completed: 0, total: 0),
    );

    await _subscription?.cancel();
    _subscription = service
        .downloadRegion(
          urlTemplate: MapConstants.tileUrlTemplate,
          centerLat: centerLat,
          centerLng: centerLng,
          radiusKm: MapConstants.offlineDownloadRadiusKm,
          minZoom: MapConstants.offlineDownloadMinZoom,
          maxZoom: MapConstants.offlineDownloadMaxZoom,
        )
        .listen(
          (progress) {
            if (!mounted) return;
            setState(() => _progress = progress);
            if (progress.isDone) {
              ref.invalidate(offlineMapCacheStatsProvider);
            }
          },
          onError: (Object error) async {
            if (!mounted) return;
            setState(() => _progress = null);
            await showErrorDialog(context, 'ダウンロードに失敗しました: $error');
          },
        );
  }

  Future<void> _confirmClearCache() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('キャッシュを削除しますか?'),
        content: const Text('ダウンロード済みの地図タイルを全て削除します。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('キャンセル'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('削除する'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await ref.read(offlineMapServiceProvider).clearCache();
    ref.invalidate(offlineMapCacheStatsProvider);
    setState(() => _progress = null);
  }
}
