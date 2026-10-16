import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kumayokeru_app/app.dart';
import 'package:kumayokeru_app/core/bootstrap.dart';
import 'package:kumayokeru_app/core/config/flavor.dart';
import 'package:kumayokeru_app/presentation/providers/presence_notification_providers.dart';

/// prod(リリース)環境のエントリーポイント
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppConfig.setFlavor(Flavor.prod);
  await initFirebase();
  // ログイン後の新規デバイストークン登録と競合しないよう、ここで完了させる。
  await retryPendingDeviceUnregister();
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
