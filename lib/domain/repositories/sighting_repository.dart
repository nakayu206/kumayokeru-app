import 'package:kumayokeru_app/domain/entities/sighting.dart';

/// 出没情報の取得を抽象化するリポジトリ。dataではkumayokeru-backend APIを叩く実装を提供する。
abstract interface class SightingRepository {
  Future<List<SightingPost>> fetchSightings();

  /// 目撃情報を投稿する。認証不要。
  Future<SightingPost> postSighting({
    required double lat,
    required double lng,
    String? description,
    String? areaName,
  });
}
