import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kumayokeru_app/data/repositories/location_sharing_repository_impl.dart';
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
    this.memberLocations = const [],
    this.errorMessage,
  });

  final bool isLoading;
  final ShareGroup? group;
  final List<MemberLocation> memberLocations;
  final String? errorMessage;

  LocationSharingState copyWith({
    bool? isLoading,
    ShareGroup? group,
    List<MemberLocation>? memberLocations,
    String? errorMessage,
  }) {
    return LocationSharingState(
      isLoading: isLoading ?? this.isLoading,
      group: group ?? this.group,
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

  Future<void> refreshLocations() async {
    final group = state.group;
    if (group == null) return;
    try {
      final locations = await _repository.pollLocations(group.id);
      state = state.copyWith(memberLocations: locations);
    } on Exception catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }
}

final locationSharingProvider =
    StateNotifierProvider<LocationSharingNotifier, LocationSharingState>((ref) {
      return LocationSharingNotifier(
        ref.watch(locationSharingRepositoryProvider),
      );
    });
