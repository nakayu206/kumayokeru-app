import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kumayokeru_app/core/config/flavor.dart';
import 'package:kumayokeru_app/core/constants/app_colors.dart';
import 'package:kumayokeru_app/presentation/pages/root/root_page.dart';
import 'package:kumayokeru_app/presentation/providers/auth_providers.dart';
import 'package:kumayokeru_app/presentation/providers/push_notification_providers.dart';

/// アプリのルートWidget。
class KumaYokeruApp extends ConsumerWidget {
  const KumaYokeruApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ログイン(起動時のセッション復元を含む)を検知したら、プッシュ通知の初期化
    // (権限リクエスト・デバイストークン登録)を行う。ログインが必要なAPIのため。
    ref.listen<bool>(authProvider.select((s) => s.isAuthenticated), (
      previous,
      isAuthenticated,
    ) {
      if (isAuthenticated && previous != true) {
        ref.read(pushNotificationSetupProvider).start();
      }
    });

    return MaterialApp(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        scaffoldBackgroundColor: AppColors.background,
        useMaterial3: true,
      ),
      home: const RootPage(),
    );
  }
}
