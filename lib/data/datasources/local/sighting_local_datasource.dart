import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'package:kumayokeru_app/data/models/sighting_cache_model.dart';

/// 出没情報のIsarキャッシュ(オフライン閲覧用)へのアクセスを行うデータソース。
class SightingLocalDataSource {
  Isar? _isar;

  Future<Isar> _getIsar() async {
    final existing = _isar;
    if (existing != null) return existing;

    final dir = await getApplicationDocumentsDirectory();
    final isar = await Isar.open([
      SightingCacheModelSchema,
    ], directory: dir.path);
    _isar = isar;
    return isar;
  }

  /// 既存キャッシュを全て置き換える(最新の一覧取得結果をそのまま保存する想定)。
  Future<void> cacheAll(List<SightingCacheModel> models) async {
    final isar = await _getIsar();
    await isar.writeTxn(() async {
      await isar.sightingCacheModels.clear();
      await isar.sightingCacheModels.putAll(models);
    });
  }

  Future<List<SightingCacheModel>> loadCached() async {
    final isar = await _getIsar();
    return isar.sightingCacheModels.where().findAll();
  }
}
