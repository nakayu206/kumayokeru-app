import 'package:kumayokeru_app/domain/entities/member_location.dart';
import 'package:kumayokeru_app/domain/entities/share_group.dart';

/// kumayokeru-backendの位置情報共有(POST投稿 + ポーリング取得)を抽象化するリポジトリ。
/// 全メソッドはログイン済み(JWT保持)である必要がある。
abstract interface class LocationSharingRepository {
  Future<List<ShareGroup>> listGroups();

  Future<ShareGroup> createGroup(String name);

  Future<void> inviteMember(String groupId, String email);

  Future<void> postLocation({required double lat, required double lng});

  /// groupIdで指定したグループの各メンバーの直近1件の位置情報を取得する(ポーリング用)。
  Future<List<MemberLocation>> pollLocations(String groupId);
}
