import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import 'package:kumayokeru_app/domain/entities/hiking_session.dart';
import 'package:kumayokeru_app/infrastructure/location_service.dart';

final locationServiceProvider = Provider<LocationService>((ref) {
  return GeolocatorLocationService();
});

/// 現在の登山セッションの経過時間・歩いた距離・高度を追跡するNotifier。
/// アプリ起動時(ホーム画面表示時)から計測を開始する。
class HikingSessionNotifier extends StateNotifier<HikingSession> {
  HikingSessionNotifier(this._locationService) : super(const HikingSession()) {
    _startElapsedTimer();
    unawaited(_subscribeToLocation());
  }

  final LocationService _locationService;
  Timer? _elapsedTimer;
  StreamSubscription<Position>? _positionSubscription;
  Position? _lastPosition;

  void _startElapsedTimer() {
    _elapsedTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      state = state.copyWith(elapsedSeconds: state.elapsedSeconds + 1);
    });
  }

  Future<void> _subscribeToLocation() async {
    final granted = await _locationService.ensurePermission();
    if (!granted) return;

    _positionSubscription = _locationService.positionStream().listen(
      _onPosition,
      // 位置情報取得の失敗はサマリ表示を更新しないだけで致命的ではないため握りつぶす。
      onError: (_) {},
    );
  }

  void _onPosition(Position position) {
    final previous = _lastPosition;
    var addedDistance = 0.0;
    if (previous != null) {
      addedDistance = Geolocator.distanceBetween(
        previous.latitude,
        previous.longitude,
        position.latitude,
        position.longitude,
      );
    }
    _lastPosition = position;
    state = state.copyWith(
      distanceMeters: state.distanceMeters + addedDistance,
      altitudeMeters: position.altitude,
    );
  }

  @override
  void dispose() {
    _elapsedTimer?.cancel();
    unawaited(_positionSubscription?.cancel());
    super.dispose();
  }
}

final hikingSessionProvider =
    StateNotifierProvider<HikingSessionNotifier, HikingSession>((ref) {
      return HikingSessionNotifier(ref.watch(locationServiceProvider));
    });
