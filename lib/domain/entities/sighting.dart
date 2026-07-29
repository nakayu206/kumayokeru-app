/// 出没情報の発信元。official=自治体公式データ、user=アプリ利用者の投稿。
enum SightingSourceType { official, user }

/// クマの目撃・出没情報。
class SightingPost {
  const SightingPost({
    required this.id,
    required this.lat,
    required this.lng,
    required this.sightedAt,
    required this.description,
    required this.areaName,
    required this.sourceType,
  });

  final String id;
  final double lat;
  final double lng;
  final DateTime sightedAt;
  final String description;
  final String areaName;
  final SightingSourceType sourceType;
}
