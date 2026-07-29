import 'package:geolocator/geolocator.dart';

/// geolocatorのラッパー(テストではフェイク実装に差し替える)。
abstract interface class LocationService {
  /// 位置情報の利用許可を確認し、必要なら要求する。許可されればtrue。
  Future<bool> ensurePermission();

  Stream<Position> positionStream();
}

class GeolocatorLocationService implements LocationService {
  @override
  Future<bool> ensurePermission() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  @override
  Stream<Position> positionStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        // 5m以上動いたら更新(山行中のバッテリー消費を抑制)
        distanceFilter: 5,
      ),
    );
  }
}
