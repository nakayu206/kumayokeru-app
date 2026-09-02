/// アプリの実行環境。
enum Flavor { dev, stg, prod }

/// main_dev/stg/prod.dartが起動時にsetFlavor()で確定させる。
class AppConfig {
  AppConfig._();

  static Flavor? _flavor;

  static Flavor get flavor {
    final flavor = _flavor;
    assert(flavor != null, 'AppConfig.setFlavor() が呼ばれていません');
    return flavor ?? Flavor.dev;
  }

  static void setFlavor(Flavor flavor) => _flavor = flavor;

  static String get appName {
    switch (flavor) {
      case Flavor.dev:
        return 'クマヨケール(dev)';
      case Flavor.stg:
        return 'クマヨケール(stg)';
      case Flavor.prod:
        return 'クマヨケール';
    }
  }

  /// kumayokeru-backendの接続先。dev/stgは本番DBを汚さないよう別インスタンス
  /// (同じEC2上、ポート3001でnginxが別プロセスにリバースプロキシ)に向ける
  /// (docs/AWSデプロイ手順.md参照)。
  static String get backendBaseUrl {
    switch (flavor) {
      case Flavor.dev:
      case Flavor.stg:
        return 'https://57-182-248-130.sslip.io:3001';
      case Flavor.prod:
        return 'https://57-182-248-130.sslip.io';
    }
  }
}
