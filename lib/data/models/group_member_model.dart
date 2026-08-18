import 'package:kumayokeru_app/domain/entities/group_member.dart';

/// kumayokeru-backendの`GET /groups/:groupId/members`レスポンスに対応するモデル。
/// スキーマはroutes/groups.tsを参照。
class GroupMemberModel {
  const GroupMemberModel({
    required this.userId,
    required this.email,
    required this.joinedAt,
  });

  factory GroupMemberModel.fromJson(Map<String, dynamic> json) {
    return GroupMemberModel(
      userId: json['userId'] as String,
      email: json['email'] as String,
      joinedAt: DateTime.parse(json['joinedAt'] as String),
    );
  }

  final String userId;
  final String email;
  final DateTime joinedAt;

  GroupMember toEntity() {
    return GroupMember(userId: userId, email: email, joinedAt: joinedAt);
  }
}
