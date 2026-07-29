import 'package:kumayokeru_app/domain/entities/member_location.dart';

/// kumayokeru-backendの`locationResponseSchema`に対応するモデル。
/// スキーマはroutes/locations.jsを参照。
class MemberLocationModel {
  const MemberLocationModel({
    required this.userId,
    required this.email,
    required this.lat,
    required this.lng,
    required this.recordedAt,
  });

  factory MemberLocationModel.fromJson(Map<String, dynamic> json) {
    return MemberLocationModel(
      userId: json['userId'] as String,
      email: json['email'] as String,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      recordedAt: DateTime.parse(json['recordedAt'] as String),
    );
  }

  final String userId;
  final String email;
  final double lat;
  final double lng;
  final DateTime recordedAt;

  MemberLocation toEntity() {
    return MemberLocation(
      userId: userId,
      email: email,
      lat: lat,
      lng: lng,
      recordedAt: recordedAt,
    );
  }
}
