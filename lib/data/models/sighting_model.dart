import 'package:kumayokeru_app/domain/entities/sighting.dart';

/// kumayokeru-backendの`GET /sightings`レスポンス1件分に対応するモデル。
/// スキーマは https://github.com/nakayu206/kumayokeru-backend の routes/sightings.js を参照。
class SightingPostModel {
  const SightingPostModel({
    required this.id,
    required this.lat,
    required this.lng,
    required this.sightedAt,
    required this.description,
    required this.areaName,
    required this.sourceType,
  });

  factory SightingPostModel.fromJson(Map<String, dynamic> json) {
    return SightingPostModel(
      id: json['id'] as String,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      sightedAt: DateTime.parse(json['sightedAt'] as String),
      description: json['description'] as String? ?? '',
      areaName: json['areaName'] as String? ?? '',
      sourceType: json['sourceType'] == 'official'
          ? SightingSourceType.official
          : SightingSourceType.user,
    );
  }

  final String id;
  final double lat;
  final double lng;
  final DateTime sightedAt;
  final String description;
  final String areaName;
  final SightingSourceType sourceType;

  SightingPost toEntity() {
    return SightingPost(
      id: id,
      lat: lat,
      lng: lng,
      sightedAt: sightedAt,
      description: description,
      areaName: areaName,
      sourceType: sourceType,
    );
  }
}
