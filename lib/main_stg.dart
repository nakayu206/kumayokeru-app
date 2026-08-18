import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kumayokeru_app/app.dart';
import 'package:kumayokeru_app/core/bootstrap.dart';
import 'package:kumayokeru_app/core/config/flavor.dart';
import 'package:kumayokeru_app/presentation/providers/presence_notification_providers.dart';

/// stg(テスト)環境のエントリーポイント
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppConfig.setFlavor(Flavor.stg);
  await initFirebase();
  final presenceNotificationHandler =
      await initPresenceNotificationAudioHandler();
  runApp(
    ProviderScope(
      overrides: [
        presenceNotificationControllerProvider.overrideWithValue(
          presenceNotificationHandler,
        ),
      ],
      child: const KumaYokeruApp(),
    ),
  );
}
