abstract interface class GeocodingRepository {
  /// 緯度経度から地名(市区町村+地区名程度の粒度)を取得する。
  Future<String> reverseGeocode({required double lat, required double lng});
}
