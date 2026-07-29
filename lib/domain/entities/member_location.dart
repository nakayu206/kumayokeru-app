/// グループメンバーの直近の位置情報(ポーリング取得結果)。
class MemberLocation {
  const MemberLocation({
    required this.userId,
    required this.email,
    required this.lat,
    required this.lng,
    required this.recordedAt,
  });

  final String userId;
  final String email;
  final double lat;
  final double lng;
  final DateTime recordedAt;
}
