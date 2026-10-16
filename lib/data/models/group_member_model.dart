import 'package:kumayokeru_app/domain/entities/group_member.dart';

/// kumayokeru-backendの`GET /groups/:groupId/members`レスポンスに対応するモデル。
/// スキーマはroutes/groups.tsを参照。
class GroupMemberModel {
  const GroupMemberModel({
    required this.userId,
    required this.name,
    required this.joinedAt,
  });

  factory GroupMemberModel.fromJson(Map<String, dynamic> json) {
    return GroupMemberModel(
      userId: json['userId'] as String,
      name: json['name'] as String,
      joinedAt: DateTime.parse(json['joinedAt'] as String),
    );
  }

  final String userId;
  final String name;
  final DateTime joinedAt;

  GroupMember toEntity() {
    return GroupMember(userId: userId, name: name, joinedAt: joinedAt);
  }
}
