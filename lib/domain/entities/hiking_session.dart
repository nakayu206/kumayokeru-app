/// 現在の登山セッションの簡易サマリ(経過時間・歩いた距離・高度)。
class HikingSession {
  const HikingSession({
    this.elapsedSeconds = 0,
    this.distanceMeters = 0,
    this.altitudeMeters,
  });

  final int elapsedSeconds;
  final double distanceMeters;

  /// GPSから高度を取得できていない場合はnull。
  final double? altitudeMeters;

  HikingSession copyWith({
    int? elapsedSeconds,
    double? distanceMeters,
    double? altitudeMeters,
  }) {
    return HikingSession(
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      altitudeMeters: altitudeMeters ?? this.altitudeMeters,
    );
  }
}
