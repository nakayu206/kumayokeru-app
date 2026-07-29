/// 位置情報共有グループ(仲間・家族)。
class ShareGroup {
  const ShareGroup({
    required this.id,
    required this.name,
    required this.ownerUserId,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String ownerUserId;
  final DateTime createdAt;
}
