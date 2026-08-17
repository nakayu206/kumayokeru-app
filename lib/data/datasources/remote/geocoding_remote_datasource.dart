import 'dart:convert';

import 'package:http/http.dart' as http;

/// Nominatim(OpenStreetMap)への通信に失敗した場合の例外。
class GeocodingApiException implements Exception {
  GeocodingApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// OpenStreetMapのNominatim逆ジオコーディングAPIを呼び出すデータソース。
/// APIキー不要・無料。https://nominatim.org/release-docs/latest/api/Reverse/
///
/// 利用ポリシー上、User-Agentの明示とリクエスト頻度(1秒に1回程度まで)の
/// 節度が求められるため、頻繁な連続呼び出しはしないこと。
class GeocodingRemoteDataSource {
  GeocodingRemoteDataSource({http.Client? client, Uri? baseUrl})
    : _client = client ?? http.Client(),
      _baseUrl = baseUrl ?? Uri.parse('https://nominatim.openstreetmap.org');

  final http.Client _client;
  final Uri _baseUrl;

  /// 緯度経度から地名(登山道・地区名等、市区町村程度の粒度)を求める。
  Future<String> reverseGeocode({
    required double lat,
    required double lng,
  }) async {
    final uri = _baseUrl.replace(
      path: '/reverse',
      queryParameters: {
        'lat': lat.toString(),
        'lon': lng.toString(),
        'format': 'json',
        'accept-language': 'ja',
        'zoom': '17',
      },
    );

    final http.Response response;
    try {
      response = await _client.get(
        uri,
        headers: {'User-Agent': 'kumayokeru-app/1.0 (kumayokeru-app)'},
      );
    } on Exception catch (e) {
      throw GeocodingApiException('現在地の取得に失敗しました(通信エラー: $e)');
    }

    if (response.statusCode != 200) {
      throw GeocodingApiException(
        '現在地の取得に失敗しました(status: ${response.statusCode})',
      );
    }

    final body =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    final address = body['address'] as Map<String, dynamic>?;
    if (address == null) {
      throw GeocodingApiException('現在地の取得に失敗しました(住所情報がありません)');
    }

    return _buildLabel(address);
  }

  String _buildLabel(Map<String, dynamic> address) {
    final area =
        address['city'] as String? ??
        address['town'] as String? ??
        address['village'] as String? ??
        address['county'] as String?;
    final detail =
        address['road'] as String? ??
        address['neighbourhood'] as String? ??
        address['suburb'] as String? ??
        address['quarter'] as String?;

    if (area != null && detail != null) return '$area $detail';
    return area ?? detail ?? '現在地';
  }
}
