import 'dart:convert';

/// kumayokeru-backendが発行するJWTのペイロード(`{sub, email}`)を取り出す。
/// 署名検証は行わない(サーバー側で検証済みの前提で、表示用の情報取得のみに使う)。
Map<String, dynamic> decodeJwtPayload(String token) {
  final parts = token.split('.');
  if (parts.length != 3) {
    throw const FormatException('不正なJWT形式です');
  }

  final normalized = base64Url.normalize(parts[1]);
  final payload = utf8.decode(base64Url.decode(normalized));
  return jsonDecode(payload) as Map<String, dynamic>;
}
