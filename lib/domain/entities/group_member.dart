/// [MemberLocation]と違い、位置未送信のメンバーも含む招待済み全員。
class GroupMember {
  const GroupMember({
    required this.userId,
    required this.email,
    required this.joinedAt,
  });

  final String userId;
  final String email;
  final DateTime joinedAt;
}
