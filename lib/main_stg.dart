import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kumayokeru_app/app.dart';
import 'package:kumayokeru_app/core/config/flavor.dart';

/// stg(テスト)環境のエントリーポイント
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  AppConfig.setFlavor(Flavor.stg);
  runApp(const ProviderScope(child: KumaYokeruApp()));
}
