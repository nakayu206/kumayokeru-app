import 'package:flutter/material.dart';

import 'package:kumayokeru_app/core/constants/app_colors.dart';
import 'package:kumayokeru_app/core/constants/app_sizes.dart';
import 'package:kumayokeru_app/core/constants/app_spacing.dart';

class _DummyMember {
  const _DummyMember({required this.name, required this.lastUpdated});

  final String name;
  final String lastUpdated;
}

const _dummyMembers = [
  _DummyMember(name: '田中さん', lastUpdated: '3分前'),
  _DummyMember(name: '家族グループ', lastUpdated: '1分前'),
];

/// 仲間・家族への位置情報共有画面(仕様書セクション12 ③)。
///
/// TODO(#12): 共有メンバー一覧・SOSを実データ(Firestore同期)と結合する。
class LocationSharingPage extends StatelessWidget {
  const LocationSharingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('位置情報共有')),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('共有中のメンバー', style: TextStyle(fontWeight: FontWeight.bold, fontSize: AppSizes.fontMd)),
            const SizedBox(height: AppSpacing.sm),
            for (final member in _dummyMembers)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.person, color: AppColors.primary),
                  title: Text(member.name),
                  subtitle: Text('最終更新 ${member.lastUpdated}'),
                ),
              ),
            const SizedBox(height: AppSpacing.md),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.person_add_alt),
              label: const Text('共有相手を追加'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(AppSizes.buttonHeight),
                foregroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusMd)),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Icon(Icons.info_outline, size: AppSizes.iconSm, color: AppColors.textSecondary),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    '電波のない場所では更新されません',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: AppSizes.fontSm),
                  ),
                ),
              ],
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: AppSizes.buttonHeight,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.sos),
                label: const Text('緊急連絡'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.danger,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusMd)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
