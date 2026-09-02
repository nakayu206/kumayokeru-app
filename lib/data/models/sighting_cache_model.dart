import 'package:isar_plus/isar_plus.dart';

import 'package:kumayokeru_app/domain/entities/sighting.dart';

part 'sighting_cache_model.g.dart';

/// 出没情報のIsarキャッシュ(オフライン閲覧用)。
@collection
class SightingCacheModel {
  SightingCacheModel();

  @Id()
  String get id => sightingId;

  late String sightingId;
  late double lat;
  late double lng;
  late DateTime sightedAt;
  late String description;
  late String areaName;

  @enumValue
  late SightingSourceType sourceType;

  factory SightingCacheModel.fromEntity(SightingPost entity) {
    return SightingCacheModel()
      ..sightingId = entity.id
      ..lat = entity.lat
      ..lng = entity.lng
      ..sightedAt = entity.sightedAt
      ..description = entity.description
      ..areaName = entity.areaName
      ..sourceType = entity.sourceType;
  }

  SightingPost toEntity() {
    return SightingPost(
      id: sightingId,
      lat: lat,
      lng: lng,
      sightedAt: sightedAt,
      description: description,
      areaName: areaName,
      sourceType: sourceType,
    );
  }
}
