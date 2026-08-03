import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

/// タイルの一括ダウンロード進捗。
class TileDownloadProgress {
  const TileDownloadProgress({required this.completed, required this.total});

  final int completed;
  final int total;

  double get ratio => total == 0 ? 0 : completed / total;
  bool get isDone => total != 0 && completed >= total;
}

class OfflineMapException implements Exception {
  OfflineMapException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// 地図タイルのローカルキャッシュを扱うサービス。
///
/// flutter_map_tile_caching(GPL v3)を使わず自前実装したもの。
/// タイルはズームレベル(z)・タイルX・タイルYごとにファイルとして保存し、
/// キャッシュに無ければネットワークから取得して保存する。
abstract interface class OfflineMapService {
  /// 1タイルを取得する。キャッシュにあればそれを返し、無ければ[url]から取得してキャッシュする。
  Future<Uint8List> loadTile({
    required int z,
    required int x,
    required int y,
    required String url,
  });

  /// 指定した中心座標から半径[radiusKm]以内のタイルを[minZoom]〜[maxZoom]の範囲で
  /// 事前ダウンロードする。進捗を[TileDownloadProgress]として順次流す。
  Stream<TileDownloadProgress> downloadRegion({
    required String urlTemplate,
    required double centerLat,
    required double centerLng,
    required double radiusKm,
    required int minZoom,
    required int maxZoom,
  });

  /// キャッシュ済みタイル数。
  Future<int> cachedTileCount();

  /// キャッシュの合計サイズ(バイト)。
  Future<int> cachedSizeBytes();

  /// キャッシュを全て削除する。
  Future<void> clearCache();
}

class FileOfflineMapService implements OfflineMapService {
  /// [baseDirectory]を指定すると、そのディレクトリ配下にタイルを保存する
  /// (テストで一時ディレクトリに差し替えるために使用)。省略時はpath_providerの
  /// アプリケーションサポートディレクトリを使う。
  FileOfflineMapService({http.Client? httpClient, Directory? baseDirectory})
    : _httpClient = httpClient ?? http.Client(),
      _baseDirectory = baseDirectory;

  final http.Client _httpClient;
  final Directory? _baseDirectory;

  Future<Directory> _tileDir() async {
    final dir = _baseDirectory ?? await getApplicationSupportDirectory();
    return Directory('${dir.path}/offline_tiles');
  }

  File _tileFile(Directory dir, int z, int x, int y) =>
      File('${dir.path}/$z/$x/$y.png');

  @override
  Future<Uint8List> loadTile({
    required int z,
    required int x,
    required int y,
    required String url,
  }) async {
    final dir = await _tileDir();
    final file = _tileFile(dir, z, x, y);
    if (await file.exists()) {
      return file.readAsBytes();
    }

    final response = await _httpClient.get(Uri.parse(url));
    if (response.statusCode != 200) {
      throw OfflineMapException(
        'タイルの取得に失敗しました(status: ${response.statusCode})',
      );
    }

    final bytes = response.bodyBytes;
    await file.parent.create(recursive: true);
    await file.writeAsBytes(bytes);
    return bytes;
  }

  @override
  Stream<TileDownloadProgress> downloadRegion({
    required String urlTemplate,
    required double centerLat,
    required double centerLng,
    required double radiusKm,
    required int minZoom,
    required int maxZoom,
  }) async* {
    final tiles = <(int z, int x, int y)>[
      for (var z = minZoom; z <= maxZoom; z++)
        ..._tilesInRadius(centerLat, centerLng, radiusKm, z),
    ];

    yield TileDownloadProgress(completed: 0, total: tiles.length);
    var completed = 0;
    for (final (z, x, y) in tiles) {
      try {
        final url = urlTemplate
            .replaceAll('{z}', '$z')
            .replaceAll('{x}', '$x')
            .replaceAll('{y}', '$y');
        await loadTile(z: z, x: x, y: y, url: url);
      } on Exception {
        // 1タイルの失敗で全体を止めない(電波不良の山中を想定)。
      }
      completed++;
      yield TileDownloadProgress(completed: completed, total: tiles.length);
    }
  }

  List<(int, int, int)> _tilesInRadius(
    double centerLat,
    double centerLng,
    double radiusKm,
    int z,
  ) {
    final latDelta = radiusKm / 111.0;
    final lngDelta = radiusKm / (111.0 * math.cos(centerLat * math.pi / 180));

    final topLeft = _latLngToTile(
      centerLat + latDelta,
      centerLng - lngDelta,
      z,
    );
    final bottomRight = _latLngToTile(
      centerLat - latDelta,
      centerLng + lngDelta,
      z,
    );

    return [
      for (var x = topLeft.$1; x <= bottomRight.$1; x++)
        for (var y = topLeft.$2; y <= bottomRight.$2; y++) (z, x, y),
    ];
  }

  /// 緯度経度からスリッピーマップのタイル座標(x, y)を求める。
  (int, int) _latLngToTile(double lat, double lng, int z) {
    final n = math.pow(2, z).toDouble();
    final clampedLat = lat.clamp(-85.05112878, 85.05112878);
    final latRad = clampedLat * math.pi / 180.0;

    final x = ((lng + 180.0) / 360.0 * n).floor().clamp(0, n.toInt() - 1);
    final y =
        ((1 - math.log(math.tan(latRad) + 1 / math.cos(latRad)) / math.pi) /
                2 *
                n)
            .floor()
            .clamp(0, n.toInt() - 1);
    return (x, y);
  }

  @override
  Future<int> cachedTileCount() async {
    final dir = await _tileDir();
    if (!await dir.exists()) return 0;
    var count = 0;
    await for (final entity in dir.list(recursive: true)) {
      if (entity is File) count++;
    }
    return count;
  }

  @override
  Future<int> cachedSizeBytes() async {
    final dir = await _tileDir();
    if (!await dir.exists()) return 0;
    var size = 0;
    await for (final entity in dir.list(recursive: true)) {
      if (entity is File) size += await entity.length();
    }
    return size;
  }

  @override
  Future<void> clearCache() async {
    final dir = await _tileDir();
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  }
}
