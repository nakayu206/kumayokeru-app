import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kumayokeru_app/core/config/flavor.dart';
import 'package:kumayokeru_app/core/constants/app_colors.dart';
import 'package:kumayokeru_app/presentation/pages/home/home_page.dart';

/// アプリのルートWidget。
class KumaYokeruApp extends ConsumerWidget {
  const KumaYokeruApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        scaffoldBackgroundColor: AppColors.background,
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}
