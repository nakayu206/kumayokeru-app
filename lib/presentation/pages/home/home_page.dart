import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kumayokeru_app/core/constants/app_colors.dart';
import 'package:kumayokeru_app/core/constants/app_sizes.dart';
import 'package:kumayokeru_app/core/constants/app_spacing.dart';
import 'package:kumayokeru_app/domain/entities/hiking_session.dart';
import 'package:kumayokeru_app/presentation/providers/hiking_session_providers.dart';
import 'package:kumayokeru_app/presentation/providers/presence_notification_providers.dart';

/// ホーム画面(仕様書セクション12 ①)。
///
/// 存在通知音の再生(#10)はjust_audioで実装済み(フォアグラウンドのみ。
/// バックグラウンド継続はPhase 0での実機検証待ち、infrastructure/notification_sound_player.dart参照)。
/// TODO(#11): 出没情報アラートを実データと結合する。
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationState = ref.watch(presenceNotificationProvider);
    final notifier = ref.read(presenceNotificationProvider.notifier);
    final hikingSession = ref.watch(hikingSessionProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'クマヨケール',
                style: TextStyle(
                  fontSize: AppSizes.fontXl,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                '登山のお守り',
                style: TextStyle(
                  fontSize: AppSizes.fontMd,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              _CurrentLocationCard(),
              const SizedBox(height: AppSpacing.lg),
              _NotificationCard(
                state: notificationState,
                onToggle: (value) => value ? notifier.start() : notifier.stop(),
                onPlayNow: notifier.playNow,
              ),
              const SizedBox(height: AppSpacing.lg),
              const _SightingAlertBanner(),
              const SizedBox(height: AppSpacing.lg),
              _HikingSummaryCard(session: hikingSession),
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
            Icon(
              Icons.location_on,
              color: AppColors.primary,
              size: AppSizes.iconMd,
            ),
            const SizedBox(width: AppSpacing.sm),
            Text('現在地: ●●山 登山道', style: TextStyle(fontSize: AppSizes.fontLg)),
          ],
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.state,
    required this.onToggle,
    required this.onPlayNow,
  });

  final PresenceNotificationState state;
  final ValueChanged<bool> onToggle;
  final VoidCallback onPlayNow;

  @override
  Widget build(BuildContext context) {
    final isNotifying = state.isNotifying;

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
                    Icon(
                      Icons.notifications_active,
                      color: AppColors.primaryDark,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      '存在通知: ${isNotifying ? "ON" : "OFF"}',
                      style: TextStyle(
                        fontSize: AppSizes.fontLg,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Switch(
                  value: isNotifying,
                  onChanged: onToggle,
                  activeTrackColor: AppColors.primary,
                ),
              ],
            ),
            if (isNotifying) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                '次回再生まで: ${state.secondsUntilNextPlay}秒',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ],
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              width: double.infinity,
              height: AppSizes.buttonHeight,
              child: ElevatedButton(
                onPressed: onPlayNow,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  ),
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

class _HikingSummaryCard extends StatelessWidget {
  const _HikingSummaryCard({required this.session});

  final HikingSession session;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '登山情報',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: AppSizes.fontMd,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _SummaryStat(
                  icon: Icons.timer_outlined,
                  label: '経過時間',
                  value: _formatElapsed(session.elapsedSeconds),
                ),
                _SummaryStat(
                  icon: Icons.route_outlined,
                  label: '歩いた距離',
                  value:
                      '${(session.distanceMeters / 1000).toStringAsFixed(1)}km',
                ),
                _SummaryStat(
                  icon: Icons.terrain_outlined,
                  label: '高度',
                  value: session.altitudeMeters == null
                      ? '--m'
                      : '${session.altitudeMeters!.round()}m',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatElapsed(int totalSeconds) {
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    return '$hours時間${minutes.toString().padLeft(2, '0')}分';
  }
}

class _SummaryStat extends StatelessWidget {
  const _SummaryStat({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: AppSizes.iconMd),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: AppSizes.fontLg,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: AppSizes.fontXs,
          ),
        ),
      ],
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
            child: Text(
              'この付近で3日前に目撃情報',
              style: TextStyle(color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
