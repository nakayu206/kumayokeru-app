import 'dart:convert';

import 'package:http/http.dart' as http;

/// kumayokeru-backendの位置情報共有API(`/groups`, `/locations`)への通信に
/// 失敗した場合の例外。
class LocationSharingApiException implements Exception {
  LocationSharingApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// kumayokeru-backendの位置情報共有API(認証必須、`Authorization: Bearer <token>`)を
/// 呼び出すデータソース。API仕様: routes/groups.js, routes/locations.js を参照。
class LocationSharingRemoteDataSource {
  LocationSharingRemoteDataSource({http.Client? client, Uri? baseUrl})
    : _client = client ?? http.Client(),
      _baseUrl = baseUrl ?? Uri.parse('https://57-182-248-130.sslip.io');

  final http.Client _client;
  final Uri _baseUrl;

  Future<List<Map<String, dynamic>>> listGroups(String token) async {
    final response = await _send('GET', '/groups', token: token);
    return _decodeList(response, '共有グループの取得に失敗しました');
  }

  Future<Map<String, dynamic>> createGroup(String token, String name) async {
    final response = await _send(
      'POST',
      '/groups',
      token: token,
      body: {'name': name},
    );
    return _decodeMap(response, 201, 'グループの作成に失敗しました');
  }

  Future<void> inviteMember(String token, String groupId, String email) async {
    final response = await _send(
      'POST',
      '/groups/$groupId/members',
      token: token,
      body: {'email': email},
    );
    if (response.statusCode != 201) {
      throw LocationSharingApiException(
        _errorMessage(response, 'メンバーの招待に失敗しました'),
      );
    }
  }

  Future<Map<String, dynamic>> postLocation(
    String token, {
    required double lat,
    required double lng,
  }) async {
    final response = await _send(
      'POST',
      '/locations',
      token: token,
      body: {'lat': lat, 'lng': lng},
    );
    return _decodeMap(response, 201, '位置情報の送信に失敗しました');
  }

  Future<List<Map<String, dynamic>>> pollLocations(
    String token,
    String groupId,
  ) async {
    final response = await _send(
      'GET',
      '/locations',
      token: token,
      queryParameters: {'groupId': groupId},
    );
    return _decodeList(response, 'メンバーの位置情報取得に失敗しました');
  }

  /// userIdに自分自身を指定するとグループから脱退、オーナーが他人を指定すると
  /// そのメンバーを削除する(routes/groups.tsの`DELETE /groups/:groupId/members/:userId`参照)。
  Future<void> removeMember(
    String token,
    String groupId,
    String userId,
  ) async {
    final response = await _send(
      'DELETE',
      '/groups/$groupId/members/$userId',
      token: token,
    );
    if (response.statusCode != 204) {
      throw LocationSharingApiException(
        _errorMessage(response, 'メンバーの削除に失敗しました'),
      );
    }
  }

  Future<http.Response> _send(
    String method,
    String path, {
    required String token,
    Map<String, dynamic>? body,
    Map<String, String>? queryParameters,
  }) async {
    final uri = _baseUrl.replace(path: path, queryParameters: queryParameters);
    final headers = {
      'authorization': 'Bearer $token',
      'content-type': 'application/json',
    };

    try {
      switch (method) {
        case 'GET':
          return await _client.get(uri, headers: headers);
        case 'POST':
          return await _client.post(
            uri,
            headers: headers,
            body: body == null ? null : jsonEncode(body),
          );
        case 'DELETE':
          return await _client.delete(uri, headers: headers);
        default:
          throw ArgumentError('未対応のHTTPメソッドです: $method');
      }
    } on Exception catch (e) {
      throw LocationSharingApiException('通信エラーが発生しました: $e');
    }
  }

  List<Map<String, dynamic>> _decodeList(
    http.Response response,
    String fallback,
  ) {
    if (response.statusCode != 200) {
      throw LocationSharingApiException(_errorMessage(response, fallback));
    }
    final body = jsonDecode(utf8.decode(response.bodyBytes)) as List<dynamic>;
    return body.cast<Map<String, dynamic>>();
  }

  Map<String, dynamic> _decodeMap(
    http.Response response,
    int expectedStatus,
    String fallback,
  ) {
    if (response.statusCode != expectedStatus) {
      throw LocationSharingApiException(_errorMessage(response, fallback));
    }
    return jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
  }

  String _errorMessage(http.Response response, String fallback) {
    try {
      final body =
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return body['error'] as String? ?? fallback;
    } on FormatException {
      return fallback;
    }
  }
}
