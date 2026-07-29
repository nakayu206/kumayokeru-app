import 'package:kumayokeru_app/domain/entities/share_group.dart';

/// kumayokeru-backendの`groupResponseSchema`に対応するモデル。
/// スキーマはroutes/groups.jsを参照。
class ShareGroupModel {
  const ShareGroupModel({
    required this.id,
    required this.name,
    required this.ownerUserId,
    required this.createdAt,
  });

  factory ShareGroupModel.fromJson(Map<String, dynamic> json) {
    return ShareGroupModel(
      id: json['id'] as String,
      name: json['name'] as String,
      ownerUserId: json['ownerUserId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  final String id;
  final String name;
  final String ownerUserId;
  final DateTime createdAt;

  ShareGroup toEntity() {
    return ShareGroup(
      id: id,
      name: name,
      ownerUserId: ownerUserId,
      createdAt: createdAt,
    );
  }
}
