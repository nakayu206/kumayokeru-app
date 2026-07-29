import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:kumayokeru_app/core/utils/jwt_decoder.dart';

String _buildFakeJwt(Map<String, dynamic> payload) {
  String encodeSegment(Object value) {
    final bytes = utf8.encode(jsonEncode(value));
    return base64Url.encode(bytes).replaceAll('=', '');
  }

  final header = encodeSegment({'alg': 'HS256', 'typ': 'JWT'});
  final body = encodeSegment(payload);
  return '$header.$body.fake-signature';
}

void main() {
  group('decodeJwtPayload', () {
    test('sub, emailを含むペイロードをデコードできる', () {
      final token = _buildFakeJwt({
        'sub': 'user-123',
        'email': 'user@example.com',
      });

      final payload = decodeJwtPayload(token);

      expect(payload['sub'], 'user-123');
      expect(payload['email'], 'user@example.com');
    });

    test('セグメントが3つでない場合はFormatExceptionを投げる', () {
      expect(() => decodeJwtPayload('invalid-token'), throwsFormatException);
    });
  });
}
