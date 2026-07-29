import 'package:flutter_test/flutter_test.dart';

import 'package:kumayokeru_app/data/models/sighting_cache_model.dart';
import 'package:kumayokeru_app/domain/entities/sighting.dart';

void main() {
  group('SightingCacheModel', () {
    test('fromEntity()→toEntity()で元の値が復元される', () {
      final entity = SightingPost(
        id: 'seed-001',
        lat: 35.7897,
        lng: 139.0197,
        sightedAt: DateTime.parse('2026-07-25T06:30:00+09:00'),
        description: '林道脇で単独個体を目撃',
        areaName: '奥多摩・雲取山周辺',
        sourceType: SightingSourceType.official,
      );

      final cacheModel = SightingCacheModel.fromEntity(entity);
      final restored = cacheModel.toEntity();

      expect(restored.id, entity.id);
      expect(restored.lat, entity.lat);
      expect(restored.lng, entity.lng);
      expect(restored.sightedAt, entity.sightedAt);
      expect(restored.description, entity.description);
      expect(restored.areaName, entity.areaName);
      expect(restored.sourceType, entity.sourceType);
    });
  });
}
