import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kumayokeru_app/app.dart';
import 'package:kumayokeru_app/core/config/flavor.dart';

/// prod(リリース)環境のエントリーポイント
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  AppConfig.setFlavor(Flavor.prod);
  runApp(const ProviderScope(child: KumaYokeruApp()));
}
