import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';

import 'package:kumayokeru_app/infrastructure/location_service.dart';
import 'package:kumayokeru_app/presentation/providers/hiking_session_providers.dart';

Position _position({
  required double lat,
  required double lng,
  double altitude = 1000,
}) {
  return Position(
    latitude: lat,
    longitude: lng,
    timestamp: DateTime(2026, 7, 25),
    altitude: altitude,
    accuracy: 1,
    altitudeAccuracy: 1,
    heading: 0,
    headingAccuracy: 1,
    speed: 0,
    speedAccuracy: 1,
  );
}

class _FakeLocationService implements LocationService {
  _FakeLocationService({this.permissionGranted = true});

  final bool permissionGranted;
  final _controller = StreamController<Position>.broadcast();

  void emit(Position position) => _controller.add(position);

  @override
  Future<bool> ensurePermission() async => permissionGranted;

  @override
  Stream<Position> positionStream() => _controller.stream;

  @override
  Future<Position> getCurrentPosition() => positionStream().first;
}

void main() {
  group('HikingSessionNotifier', () {
    test('1秒ごとにelapsedSecondsが増える', () {
      fakeAsync((async) {
        final notifier = HikingSessionNotifier(_FakeLocationService());
        addTearDown(notifier.dispose);

        async.elapse(const Duration(seconds: 3));

        expect(notifier.state.elapsedSeconds, 3);
      });
    });

    test('位置情報の更新で距離・高度が積算される', () {
      fakeAsync((async) {
        final locationService = _FakeLocationService();
        final notifier = HikingSessionNotifier(locationService);
        addTearDown(notifier.dispose);

        // 許可確認(ensurePermission)の非同期処理を先に完了させる。
        async.flushMicrotasks();

        locationService.emit(_position(lat: 35.0, lng: 139.0, altitude: 1000));
        async.flushMicrotasks();
        expect(notifier.state.distanceMeters, 0);
        expect(notifier.state.altitudeMeters, 1000);

        // 緯度をわずかに変えて2点目を送る(約111mの移動に相当)。
        locationService.emit(
          _position(lat: 35.001, lng: 139.0, altitude: 1010),
        );
        async.flushMicrotasks();

        expect(notifier.state.distanceMeters, greaterThan(0));
        expect(notifier.state.altitudeMeters, 1010);
      });
    });

    test('位置情報の権限が無ければ距離は更新されない', () {
      fakeAsync((async) {
        final locationService = _FakeLocationService(permissionGranted: false);
        final notifier = HikingSessionNotifier(locationService);
        addTearDown(notifier.dispose);

        async.flushMicrotasks();
        locationService.emit(_position(lat: 35.0, lng: 139.0));
        async.flushMicrotasks();

        expect(notifier.state.distanceMeters, 0);
        expect(notifier.state.altitudeMeters, isNull);
      });
    });
  });
}
