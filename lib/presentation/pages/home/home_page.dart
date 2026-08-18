import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kumayokeru_app/core/constants/app_colors.dart';
import 'package:kumayokeru_app/core/constants/app_sizes.dart';
import 'package:kumayokeru_app/core/constants/app_spacing.dart';
import 'package:kumayokeru_app/domain/entities/current_weather.dart';
import 'package:kumayokeru_app/domain/entities/hiking_session.dart';
import 'package:kumayokeru_app/presentation/providers/geocoding_providers.dart';
import 'package:kumayokeru_app/presentation/providers/hiking_session_providers.dart';
import 'package:kumayokeru_app/presentation/providers/presence_notification_providers.dart';
import 'package:kumayokeru_app/presentation/providers/sighting_providers.dart';
import 'package:kumayokeru_app/presentation/providers/weather_providers.dart';

/// ホーム画面(仕様書セクション12 ①)。
///
/// 存在通知音の再生(#10)はjust_audioで実装済み。バックグラウンド継続は
/// PresenceNotificationAudioHandler(audio_service)がAndroidのフォアグラウンド
/// サービス化・iOSのバックグラウンド音声再生モードを担う(実機での複数機種検証は
/// Phase 0で別途行う。infrastructure/presence_notification_audio_handler.dart参照)。
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
              const _CurrentLocationCard(),
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
              const SizedBox(height: AppSpacing.lg),
              const _WeatherCard(),
            ],
          ),
        ),
      ),
    );
  }
}

class _CurrentLocationCard extends ConsumerWidget {
  const _CurrentLocationCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final labelAsync = ref.watch(currentLocationLabelProvider);

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
            Expanded(
              child: Text(
                '現在地: ${labelAsync.when(loading: () => '取得中...', error: (error, _) => '取得できませんでした', data: (label) => label)}',
                style: TextStyle(fontSize: AppSizes.fontLg),
                overflow: TextOverflow.ellipsis,
              ),
            ),
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

String _formatDaysAgo(DateTime sightedAt) {
  final days = DateTime.now().difference(sightedAt).inDays;
  if (days <= 0) return '今日';
  return '$days日前';
}

class _WeatherCard extends ConsumerWidget {
  const _WeatherCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherAsync = ref.watch(currentWeatherProvider);
    final weather = weatherAsync.valueOrNull;
    final backgroundColor = weather == null
        ? AppColors.surface
        : Color.lerp(
            AppColors.surface,
            _weatherCondition(weather.weatherCode).color,
            0.12,
          )!;

    return Card(
      color: backgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '現在地の天気',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: AppSizes.fontMd,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            weatherAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Text(
                '天気情報を取得できませんでした',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              data: (weather) => _WeatherContent(weather: weather),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeatherContent extends StatelessWidget {
  const _WeatherContent({required this.weather});

  final CurrentWeather weather;

  @override
  Widget build(BuildContext context) {
    final condition = _weatherCondition(weather.weatherCode);

    return Row(
      children: [
        _WeatherIcon(condition: condition, size: AppSizes.iconLg),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${weather.temperatureCelsius.round()}℃ ${condition.label}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: AppSizes.fontLg,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                '湿度 ${weather.humidityPercent}% / 風速 ${weather.windSpeedKmh.round()}km/h'
                '${weather.precipitationMm > 0 ? ' / 降水 ${weather.precipitationMm.toStringAsFixed(1)}mm' : ''}',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: AppSizes.fontSm,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 天気アイコンの表示。「晴れ時々曇り」(Icons.wb_cloudy)は雲の形しか描かれず
/// 太陽が見えないため、実際に「晴れ+曇り」に見えるよう太陽アイコンを
/// 後ろに重ねて表示する。それ以外の天気は単一アイコンをそのまま表示する。
class _WeatherIcon extends StatelessWidget {
  const _WeatherIcon({required this.condition, required this.size});

  final _WeatherCondition condition;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (condition.icon != Icons.wb_cloudy) {
      return Icon(condition.icon, color: condition.color, size: size);
    }

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 0,
            right: 0,
            child: Icon(
              Icons.wb_sunny,
              color: const Color(0xFFF57C00),
              size: size * 0.55,
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            child: Icon(
              condition.icon,
              color: condition.color,
              size: size * 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

class _WeatherCondition {
  const _WeatherCondition(this.label, this.icon, this.color);

  final String label;
  final IconData icon;
  final Color color;
}

/// WMO Weather interpretation code(Open-Meteoの天気コード)を日本語表示に変換する。
/// https://open-meteo.com/en/docs で定義されているコード一覧に基づく。
/// 色は天気が一目で分かるよう、それぞれの天気を連想させる配色にしている
/// (アプリ共通のブランドカラーではなく、この天気カード限定の配色)。
_WeatherCondition _weatherCondition(int code) {
  return switch (code) {
    0 => const _WeatherCondition(
      '快晴',
      Icons.wb_sunny,
      Color(0xFFF57C00), // オレンジ
    ),
    1 || 2 => const _WeatherCondition(
      '晴れ時々曇り',
      Icons.wb_cloudy,
      // 雲の形のアイコンなので、オレンジ(黄色っぽく見える)ではなくグレー系にする。
      Color(0xFF78909C),
    ),
    3 => const _WeatherCondition(
      '曇り',
      Icons.cloud,
      Color(0xFF90A4AE), // グレー(雲)
    ),
    45 || 48 => const _WeatherCondition(
      '霧',
      Icons.foggy,
      Color(0xFFB0BEC5), // 薄いグレー
    ),
    51 || 53 || 55 || 56 || 57 => const _WeatherCondition(
      '霧雨',
      // Icons.grainは実際には写真のノイズ質感(フィルムグレイン)のアイコンで
      // 雨と無関係のため、雨と同じ水滴系のIcons.opacityを使う。
      Icons.opacity,
      Color(0xFF5C6BC0), // 淡い青
    ),
    61 || 63 || 65 || 66 || 67 || 80 || 81 || 82 => const _WeatherCondition(
      '雨',
      Icons.water_drop,
      Color(0xFF1A3A6B), // 黒みがかった青
    ),
    71 || 73 || 75 || 77 || 85 || 86 => const _WeatherCondition(
      '雪',
      Icons.ac_unit,
      Color(0xFF4FC3F7), // 水色
    ),
    95 || 96 || 99 => const _WeatherCondition(
      '雷雨',
      Icons.thunderstorm,
      Color(0xFF4A148C), // 濃い紫
    ),
    _ => const _WeatherCondition('不明', Icons.help_outline, Color(0xFF9E9E9E)),
  };
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

class _SightingAlertBanner extends ConsumerWidget {
  const _SightingAlertBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nearbySighting = ref.watch(nearbySightingAlertProvider);
    final sighting = nearbySighting.valueOrNull;

    // 現在地不明・取得失敗・付近に目撃情報なし、のいずれの場合もバナー自体を出さない
    // (無関係な地域の情報で不安を煽らないため)。
    if (sighting == null) return const SizedBox.shrink();

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
              'この付近で${_formatDaysAgo(sighting.sightedAt)}に目撃情報',
              style: TextStyle(color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
