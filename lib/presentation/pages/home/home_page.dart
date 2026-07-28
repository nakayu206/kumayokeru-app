import 'package:flutter/material.dart';

import 'package:kumayokeru_app/core/config/flavor.dart';

/// ホーム画面。
///
/// TODO(Phase1): 存在通知トグル・出没情報アラート・ボトムナビ(仕様書セクション12 ①)を実装する。
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppConfig.appName)),
      body: const Center(child: Text('登山のお守り')),
    );
  }
}
