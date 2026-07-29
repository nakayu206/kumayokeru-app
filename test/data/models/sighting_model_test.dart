import 'package:flutter_test/flutter_test.dart';

import 'package:kumayokeru_app/data/models/sighting_model.dart';
import 'package:kumayokeru_app/domain/entities/sighting.dart';

void main() {
  group('SightingPostModel.fromJson', () {
    test('kumayokeru-backendのレスポンス形式を正しくパースする', () {
      final json = {
        'id': 'seed-001',
        'lat': 35.7897,
        'lng': 139.0197,
        'sightedAt': '2026-07-25T06:30:00+09:00',
        'description': '林道脇で単独個体を目撃',
        'areaName': '奥多摩・雲取山周辺',
        'sourceType': 'official',
      };

      final model = SightingPostModel.fromJson(json);

      expect(model.id, 'seed-001');
      expect(model.lat, 35.7897);
      expect(model.lng, 139.0197);
      expect(model.description, '林道脇で単独個体を目撃');
      expect(model.areaName, '奥多摩・雲取山周辺');
      expect(model.sourceType, SightingSourceType.official);
    });

    test('sourceTypeが"user"ならSightingSourceType.userになる', () {
      final json = {
        'id': 'user-1',
        'lat': 35.0,
        'lng': 139.0,
        'sightedAt': '2026-07-25T06:30:00+09:00',
        'sourceType': 'user',
      };

      final model = SightingPostModel.fromJson(json);

      expect(model.sourceType, SightingSourceType.user);
      expect(model.description, '');
      expect(model.areaName, '');
    });

    test('toEntity()でSightingPostに変換できる', () {
      final model = SightingPostModel.fromJson({
        'id': 'seed-001',
        'lat': 35.7897,
        'lng': 139.0197,
        'sightedAt': '2026-07-25T06:30:00+09:00',
        'sourceType': 'official',
      });

      final entity = model.toEntity();

      expect(entity, isA<SightingPost>());
      expect(entity.id, model.id);
      expect(entity.lat, model.lat);
    });
  });
}
