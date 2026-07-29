import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:kumayokeru_app/data/models/sighting_model.dart';

/// kumayokeru-backend(https://57-182-248-130.sslip.io)への通信に失敗した場合の例外。
class SightingsApiException implements Exception {
  SightingsApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// kumayokeru-backendの出没情報API(`GET/POST /sightings`)を呼び出すデータソース。
/// API仕様: https://github.com/nakayu206/kumayokeru-backend (Swagger UI: /documentation)
class SightingsRemoteDataSource {
  SightingsRemoteDataSource({http.Client? client, Uri? baseUrl})
    : _client = client ?? http.Client(),
      _baseUrl = baseUrl ?? Uri.parse('https://57-182-248-130.sslip.io');

  final http.Client _client;
  final Uri _baseUrl;

  Future<List<SightingPostModel>> fetchSightings() async {
    final http.Response response;
    try {
      response = await _client.get(_baseUrl.replace(path: '/sightings'));
    } on Exception catch (e) {
      throw SightingsApiException('出没情報の取得に失敗しました(通信エラー: $e)');
    }

    if (response.statusCode != 200) {
      throw SightingsApiException(
        '出没情報の取得に失敗しました(status: ${response.statusCode})',
      );
    }

    final body = jsonDecode(utf8.decode(response.bodyBytes)) as List<dynamic>;
    return body
        .map((e) => SightingPostModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// 目撃情報を投稿する。認証不要(誰でも投稿可能。sourceTypeは常に"user"として記録される)。
  Future<SightingPostModel> postSighting({
    required double lat,
    required double lng,
    String? description,
    String? areaName,
  }) async {
    final http.Response response;
    try {
      response = await _client.post(
        _baseUrl.replace(path: '/sightings'),
        headers: {'content-type': 'application/json'},
        body: jsonEncode({
          'lat': lat,
          'lng': lng,
          'description': ?description,
          'areaName': ?areaName,
        }),
      );
    } on Exception catch (e) {
      throw SightingsApiException('目撃情報の投稿に失敗しました(通信エラー: $e)');
    }

    if (response.statusCode != 201) {
      throw SightingsApiException(
        '目撃情報の投稿に失敗しました(status: ${response.statusCode})',
      );
    }

    final body =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    return SightingPostModel.fromJson(body);
  }
}
