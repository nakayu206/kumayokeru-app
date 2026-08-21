import 'package:flutter/material.dart';

import 'package:kumayokeru_app/core/constants/app_spacing.dart';

class DisclaimerPage extends StatelessWidget {
  const DisclaimerPage({super.key});

  static const _items = [
    '本アプリが提供するクマ出没情報(自治体データ・ユーザー投稿を含む)は、その正確性・'
        '最新性・完全性を保証するものではありません。実際の登山・行動の判断は、必ずご自身'
        'の責任で行ってください。',
    '位置情報共有機能・緊急連絡(SOS)機能は、電波状況や端末の状態等により、遅延・不達・'
        '誤動作が発生する場合があります。これらの機能が正常に作動することを保証するもので'
        'はありません。',
    '本アプリの利用によりクマとの遭遇その他の事故が回避されることを保証するものではあり'
        'ません。',
    'システムメンテナンスや障害等により、予告なくサービスの全部または一部を停止する場合'
        'があります。',
    '当社(開発者)は、本アプリの利用により生じた損害について、当社に故意または重過失が'
        'ある場合を除き、責任を負わないものとします。',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('免責事項')),
      body: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.lg),
        itemCount: _items.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
        itemBuilder: (context, index) => Text(
          '${index + 1}. ${_items[index]}',
          style: const TextStyle(height: 1.6),
        ),
      ),
    );
  }
}
