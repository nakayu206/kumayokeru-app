/// 位置情報共有グループのメンバー(`GET /groups/:groupId/members`)。
///
/// [MemberLocation]と違い、まだ一度も位置情報を送信していないメンバー
/// (招待直後など)も含めた「招待済み全員」を表す。
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
