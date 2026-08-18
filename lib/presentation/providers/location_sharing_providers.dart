import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kumayokeru_app/data/repositories/location_sharing_repository_impl.dart';
import 'package:kumayokeru_app/domain/entities/group_member.dart';
import 'package:kumayokeru_app/domain/entities/member_location.dart';
import 'package:kumayokeru_app/domain/entities/share_group.dart';
import 'package:kumayokeru_app/domain/repositories/location_sharing_repository.dart';

final locationSharingRepositoryProvider = Provider<LocationSharingRepository>(
  (ref) => LocationSharingRepositoryImpl(),
);

/// 位置情報共有画面の状態。groupがnullなら「共有グループ未作成」を表す。
class LocationSharingState {
  const LocationSharingState({
    this.isLoading = false,
    this.group,
    this.members = const [],
    this.memberLocations = const [],
    this.errorMessage,
  });

  final bool isLoading;
  final ShareGroup? group;

  /// 招待済み全メンバー(位置情報を一度も送っていないメンバーも含む)。
  final List<GroupMember> members;

  /// 直近の位置情報を送信済みのメンバーのみ(表示上の「最終更新」に使う)。
  final List<MemberLocation> memberLocations;
  final String? errorMessage;

  LocationSharingState copyWith({
    bool? isLoading,
    ShareGroup? group,
    List<GroupMember>? members,
    List<MemberLocation>? memberLocations,
    String? errorMessage,
  }) {
    return LocationSharingState(
      isLoading: isLoading ?? this.isLoading,
      group: group ?? this.group,
      members: members ?? this.members,
      memberLocations: memberLocations ?? this.memberLocations,
      errorMessage: errorMessage,
    );
  }
}

class LocationSharingNotifier extends StateNotifier<LocationSharingState> {
  LocationSharingNotifier(this._repository)
    : super(const LocationSharingState()) {
    _loadGroup();
  }

  final LocationSharingRepository _repository;

  Future<void> _loadGroup() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final groups = await _repository.listGroups();
      if (groups.isEmpty) {
        state = state.copyWith(isLoading: false);
        return;
      }
      state = state.copyWith(isLoading: false, group: groups.first);
      await refreshLocations();
    } on Exception catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> createGroup(String name) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final group = await _repository.createGroup(name);
      state = state.copyWith(isLoading: false, group: group);
      await refreshLocations();
    } on Exception catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> inviteMember(String email) async {
    final group = state.group;
    if (group == null) return;
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _repository.inviteMember(group.id, email);
      state = state.copyWith(isLoading: false);
      await refreshLocations();
    } on Exception catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> shareCurrentLocation(double lat, double lng) async {
    state = state.copyWith(errorMessage: null);
    try {
      await _repository.postLocation(lat: lat, lng: lng);
      await refreshLocations();
    } on Exception catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  /// メンバー一覧(招待済み全員)と、各メンバーの直近の位置情報を両方取得し直す。
  Future<void> refreshLocations() async {
    final group = state.group;
    if (group == null) return;
    try {
      final results = await Future.wait([
        _repository.listMembers(group.id),
        _repository.pollLocations(group.id),
      ]);
      state = state.copyWith(
        members: results[0] as List<GroupMember>,
        memberLocations: results[1] as List<MemberLocation>,
      );
    } on Exception catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  /// 他のメンバーをグループから削除する(オーナーのみ実行可能。詳細はバックエンド側で判定)。
  Future<void> removeMember(String userId) async {
    final group = state.group;
    if (group == null) return;
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _repository.removeMember(group.id, userId);
      state = state.copyWith(isLoading: false);
      await refreshLocations();
    } on Exception catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  /// 自分自身をグループから脱退させる。成功したら「グループ未参加」状態に戻す
  /// (オーナー自身はバックエンド側で脱退不可としているため、この操作はオーナー以外向け)。
  Future<void> leaveGroup(String selfUserId) async {
    final group = state.group;
    if (group == null) return;
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _repository.removeMember(group.id, selfUserId);
      state = const LocationSharingState();
    } on Exception catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }
}

final locationSharingProvider =
    StateNotifierProvider<LocationSharingNotifier, LocationSharingState>((ref) {
      return LocationSharingNotifier(
        ref.watch(locationSharingRepositoryProvider),
      );
    });
