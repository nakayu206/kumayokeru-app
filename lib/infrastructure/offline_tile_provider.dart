import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_map/flutter_map.dart';

import 'package:kumayokeru_app/infrastructure/offline_map_service.dart';

class OfflineFirstTileProvider extends TileProvider {
  OfflineFirstTileProvider(this._service, {super.headers});

  final OfflineMapService _service;

  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) {
    return _OfflineTileImage(
      service: _service,
      url: getTileUrl(coordinates, options),
      z: coordinates.z,
      x: coordinates.x,
      y: coordinates.y,
    );
  }
}

@immutable
class _OfflineTileImage extends ImageProvider<_OfflineTileImage> {
  const _OfflineTileImage({
    required this.service,
    required this.url,
    required this.z,
    required this.x,
    required this.y,
  });

  final OfflineMapService service;
  final String url;
  final int z;
  final int x;
  final int y;

  @override
  Future<_OfflineTileImage> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture(this);
  }

  @override
  ImageStreamCompleter loadImage(
    _OfflineTileImage key,
    ImageDecoderCallback decode,
  ) {
    return MultiFrameImageStreamCompleter(codec: _loadCodec(decode), scale: 1);
  }

  Future<ui.Codec> _loadCodec(ImageDecoderCallback decode) async {
    final bytes = await service.loadTile(z: z, x: x, y: y, url: url);
    final buffer = await ui.ImmutableBuffer.fromUint8List(bytes);
    return decode(buffer);
  }

  @override
  bool operator ==(Object other) {
    return other is _OfflineTileImage &&
        other.z == z &&
        other.x == x &&
        other.y == y &&
        other.url == url;
  }

  @override
  int get hashCode => Object.hash(url, z, x, y);
}
