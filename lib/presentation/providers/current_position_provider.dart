import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import 'package:kumayokeru_app/presentation/providers/hiking_session_providers.dart';

/// 現在地を1回だけ取得するProvider。権限が無い/取得失敗時はnullを返す
/// (呼び出し側はデフォルト座標へのフォールバック等で対応する)。
final currentPositionProvider = FutureProvider<Position?>((ref) async {
  final locationService = ref.watch(locationServiceProvider);
  final granted = await locationService.ensurePermission();
  if (!granted) return null;

  try {
    return await locationService.getCurrentPosition();
  } on Exception {
    return null;
  }
});
