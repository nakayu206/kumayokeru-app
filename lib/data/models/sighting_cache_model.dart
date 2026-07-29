import 'package:isar/isar.dart';

import 'package:kumayokeru_app/domain/entities/sighting.dart';

part 'sighting_cache_model.g.dart';

/// 出没情報のIsarキャッシュ(オフライン閲覧用)。
@collection
class SightingCacheModel {
  SightingCacheModel();

  Id id = Isar.autoIncrement;

  late String sightingId;
  late double lat;
  late double lng;
  late DateTime sightedAt;
  late String description;
  late String areaName;

  @enumerated
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
