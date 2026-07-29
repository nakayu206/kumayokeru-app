import 'package:flutter/material.dart';

import 'package:kumayokeru_app/core/constants/app_colors.dart';
import 'package:kumayokeru_app/core/constants/app_sizes.dart';
import 'package:kumayokeru_app/core/constants/app_spacing.dart';
import 'package:kumayokeru_app/core/constants/map_constants.dart';

/// ホーム画面(仕様書セクション12 ①)。
///
/// TODO(#10): 存在通知ON/OFF・再生カウントダウンをRiverpod Providerと結合する。
/// TODO(#11): 出没情報アラートを実データと結合する。
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isNotifying = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'クマヨケール',
                style: TextStyle(fontSize: AppSizes.fontXl, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text('登山のお守り', style: TextStyle(fontSize: AppSizes.fontMd, color: AppColors.textSecondary)),
              const SizedBox(height: AppSpacing.lg),
              _CurrentLocationCard(),
              const SizedBox(height: AppSpacing.lg),
              _NotificationCard(
                isNotifying: _isNotifying,
                onToggle: (value) => setState(() => _isNotifying = value),
              ),
              const SizedBox(height: AppSpacing.lg),
              const _SightingAlertBanner(),
            ],
          ),
        ),
      ),
    );
  }
}

class _CurrentLocationCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Icon(Icons.location_on, color: AppColors.primary, size: AppSizes.iconMd),
            const SizedBox(width: AppSpacing.sm),
            Text('現在地: ●●山 登山道', style: TextStyle(fontSize: AppSizes.fontLg)),
          ],
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.isNotifying, required this.onToggle});

  final bool isNotifying;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.primaryLight,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.notifications_active, color: AppColors.primaryDark),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      '存在通知: ${isNotifying ? "ON" : "OFF"}',
                      style: TextStyle(fontSize: AppSizes.fontLg, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Switch(value: isNotifying, onChanged: onToggle, activeTrackColor: AppColors.primary),
              ],
            ),
            if (isNotifying) ...[
              const SizedBox(height: AppSpacing.sm),
              Text('次回再生まで: ${AudioConstants.defaultIntervalSec}秒', style: TextStyle(color: AppColors.textSecondary)),
            ],
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              height: AppSizes.buttonHeight,
              child: ElevatedButton(
                onPressed: isNotifying ? () {} : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusMd)),
                ),
                child: const Text('今すぐ鳴らす'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SightingAlertBanner extends StatelessWidget {
  const _SightingAlertBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.warning),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: AppColors.warning),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text('この付近で3日前に目撃情報', style: TextStyle(color: AppColors.textPrimary)),
          ),
        ],
      ),
    );
  }
}
