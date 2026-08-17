/// 地図関連の定数(仕様書セクション15)。
class MapConstants {
  MapConstants._();

  static const defaultZoom = 15.0;
  static const detailZoom = 17.0;
  static const overviewZoom = 13.0;

  /// GPS取得間隔(秒)。TekuShareの5秒より間隔を延ばし、山行中のバッテリー消費を抑制する。
  static const gpsIntervalSec = 10;

  /// 初期表示位置(東京)。実際の登山エリアに応じて変更する。
  static const defaultLat = 35.6895;
  static const defaultLng = 139.6917;

  static const tileUrlTemplate =
      'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

  /// オフライン地図の事前ダウンロード範囲(現在地からの半径・ズーム範囲)。
  static const offlineDownloadRadiusKm = 5.0;
  static const offlineDownloadMinZoom = 12;
  static const offlineDownloadMaxZoom = 16;

  /// ホーム画面の目撃情報アラートバナーで「付近」とみなす半径(メートル)。
  static const nearbySightingAlertRadiusMeters = 10000.0;
}

/// 存在通知音の再生に関する定数(仕様書セクション15)。
class AudioConstants {
  AudioConstants._();

  static const defaultIntervalSec = 30;
  static const minIntervalSec = 15;
  static const maxIntervalSec = 120;

  /// 最大音量ではなく控えめな初期値。
  static const defaultVolume = 0.6;

  /// セルフチェック通知(#再生停止検知)の猶予秒数。
  /// 「再生間隔 + この秒数」だけ次のtickが来なければ、再生が止まったとみなして通知する。
  static const selfCheckMarginSec = 30;
}
