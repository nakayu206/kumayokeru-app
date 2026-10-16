import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:kumayokeru_app/core/config/flavor.dart';

/// kumayokeru-backendのデバイストークン登録API(`POST /devices`)への通信に
/// 失敗した場合の例外。
class DeviceApiException implements Exception {
  DeviceApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// kumayokeru-backendのプッシュ通知用デバイストークン登録API(認証必須)を
/// 呼び出すデータソース。API仕様: routes/devices.ts を参照。
class DeviceRemoteDataSource {
  DeviceRemoteDataSource({http.Client? client, Uri? baseUrl})
    : _client = client ?? http.Client(),
      _baseUrl = baseUrl ?? Uri.parse(AppConfig.backendBaseUrl);

  final http.Client _client;
  final Uri _baseUrl;

  /// 戻り値はサーバー側の登録ID(世代番号)。再登録のたびに新しい値になり、
  /// unregisterToken()の世代チェックに使う(routes/devices.ts参照)。
  Future<String> registerToken(
    String authToken, {
    required String deviceToken,
    required String platform,
  }) async {
    final uri = _baseUrl.replace(path: '/devices');

    http.Response response;
    try {
      response = await _client.post(
        uri,
        headers: {
          'authorization': 'Bearer $authToken',
          'content-type': 'application/json',
        },
        body: jsonEncode({'token': deviceToken, 'platform': platform}),
      );
    } on Exception catch (e) {
      throw DeviceApiException('通信エラーが発生しました: $e');
    }

    if (response.statusCode != 201) {
      throw DeviceApiException(_errorMessage(response));
    }

    final body =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    return body['id'] as String;
  }

  /// registrationIdはregisterToken()が返した登録IDを指定する。解除が遅延している
  /// 間に同じdeviceTokenが再登録されていた場合、サーバー側はこのIDが現在の登録と
  /// 一致しない限り削除しない(世代チェック)。その場合・既に未登録の場合は404を
  /// 返すが、いずれも「対象が無い=既に解決済み」とみなしてよいため例外にしない。
  Future<void> unregisterToken(
    String authToken, {
    required String deviceToken,
    required String registrationId,
  }) async {
    final uri = _baseUrl.replace(path: '/devices');

    http.Response response;
    try {
      response = await _client.delete(
        uri,
        headers: {
          'authorization': 'Bearer $authToken',
          'content-type': 'application/json',
        },
        body: jsonEncode({
          'token': deviceToken,
          'registrationId': registrationId,
        }),
      );
    } on Exception catch (e) {
      throw DeviceApiException('通信エラーが発生しました: $e');
    }

    if (response.statusCode == 204 || response.statusCode == 404) {
      return;
    }
    throw DeviceApiException(_errorMessage(response));
  }

  String _errorMessage(http.Response response) {
    try {
      final body =
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return body['error'] as String? ?? 'デバイストークンの登録に失敗しました';
    } on FormatException {
      return 'デバイストークンの登録に失敗しました';
    }
  }
}
