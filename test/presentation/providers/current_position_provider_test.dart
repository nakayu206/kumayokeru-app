import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';

import 'package:kumayokeru_app/infrastructure/location_service.dart';
import 'package:kumayokeru_app/presentation/providers/current_position_provider.dart';
import 'package:kumayokeru_app/presentation/providers/hiking_session_providers.dart';

Position _position() {
  return Position(
    latitude: 35.0,
    longitude: 139.0,
    timestamp: DateTime(2026, 7, 25),
    altitude: 100,
    accuracy: 1,
    altitudeAccuracy: 1,
    heading: 0,
    headingAccuracy: 1,
    speed: 0,
    speedAccuracy: 1,
  );
}

class _FakeLocationService implements LocationService {
  _FakeLocationService({
    this.permissionGranted = true,
    this.throwOnFetch = false,
  });

  final bool permissionGranted;
  final bool throwOnFetch;

  @override
  Future<bool> ensurePermission() async => permissionGranted;

  @override
  Stream<Position> positionStream() => const Stream.empty();

  @override
  Future<Position> getCurrentPosition() async {
    if (throwOnFetch) throw Exception('location unavailable');
    return _position();
  }
}

void main() {
  group('currentPositionProvider', () {
    test('権限があれば現在地を返す', () async {
      final container = ProviderContainer(
        overrides: [
          locationServiceProvider.overrideWithValue(_FakeLocationService()),
        ],
      );
      addTearDown(container.dispose);

      final position = await container.read(currentPositionProvider.future);

      expect(position, isNotNull);
      expect(position!.latitude, 35.0);
    });

    test('権限がなければnullを返す', () async {
      final container = ProviderContainer(
        overrides: [
          locationServiceProvider.overrideWithValue(
            _FakeLocationService(permissionGranted: false),
          ),
        ],
      );
      addTearDown(container.dispose);

      final position = await container.read(currentPositionProvider.future);

      expect(position, isNull);
    });

    test('取得に失敗したらnullを返す', () async {
      final container = ProviderContainer(
        overrides: [
          locationServiceProvider.overrideWithValue(
            _FakeLocationService(throwOnFetch: true),
          ),
        ],
      );
      addTearDown(container.dispose);

      final position = await container.read(currentPositionProvider.future);

      expect(position, isNull);
    });
  });
}
