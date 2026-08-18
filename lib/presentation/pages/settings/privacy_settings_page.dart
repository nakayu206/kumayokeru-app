import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kumayokeru_app/core/constants/app_colors.dart';
import 'package:kumayokeru_app/core/constants/app_sizes.dart';
import 'package:kumayokeru_app/core/constants/app_spacing.dart';
import 'package:kumayokeru_app/presentation/providers/settings_providers.dart';

/// 位置情報共有のオプトイン同意・管理画面(仕様書セクション6 セキュリティ・プライバシー)。
///
/// ここでの同意(location_sharing_consent_given)がfalseの間は、
/// LocationSharingPageで「現在地を共有する」を押しても送信されない
/// (SOS/緊急連絡は、その場で押した本人の明示的な意思表示のため対象外)。
class PrivacySettingsPage extends ConsumerWidget {
  const PrivacySettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final privacySettings = ref.watch(privacySettingsProvider);
    final notifier = ref.read(privacySettingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('プライバシー設定')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Text(
            '位置情報共有',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: AppSizes.fontMd,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
            child: const Text(
              'この機能をONにすると、「仲間」タブでグループに招待した相手に、あなたが'
              '「現在地を共有する」を押したタイミングの位置情報が送信されます。'
              'OFFの間は、グループに参加していても位置情報は一切送信されません。\n\n'
              '緊急連絡(SOS)ボタンは、押した場合に限りこの設定に関わらず現在地を送信します'
              '(緊急時にすぐ助けを呼べるようにするためです)。',
              style: TextStyle(height: 1.5),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('位置情報の共有を許可する'),
            subtitle: Text(
              privacySettings.locationSharingConsentGiven ? '許可中' : '許可していません',
            ),
            value: privacySettings.locationSharingConsentGiven,
            onChanged: notifier.setLocationSharingConsentGiven,
            activeTrackColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}
