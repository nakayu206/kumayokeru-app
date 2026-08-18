import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:kumayokeru_app/core/constants/app_colors.dart';
import 'package:kumayokeru_app/core/constants/app_sizes.dart';
import 'package:kumayokeru_app/core/constants/app_spacing.dart';
import 'package:kumayokeru_app/domain/entities/member_location.dart';
import 'package:kumayokeru_app/presentation/pages/auth/login_page.dart';
import 'package:kumayokeru_app/presentation/pages/settings/privacy_settings_page.dart';
import 'package:kumayokeru_app/presentation/providers/auth_providers.dart';
import 'package:kumayokeru_app/presentation/providers/location_sharing_providers.dart';
import 'package:kumayokeru_app/presentation/providers/settings_providers.dart';
import 'package:kumayokeru_app/presentation/widgets/common/error_dialog.dart';

/// 仲間・家族への位置情報共有画面(仕様書セクション12 ③)。
///
/// kumayokeru-backend(POST /locations + ポーリング取得、#12)と結合済み。
class LocationSharingPage extends ConsumerWidget {
  const LocationSharingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    if (!authState.isAuthenticated) {
      return _buildLoginPrompt(context);
    }

    return _AuthenticatedLocationSharingView();
  }

  Widget _buildLoginPrompt(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('位置情報共有')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.lock_outline,
                size: AppSizes.iconLg,
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                '仲間との位置情報共有にはログインが必要です',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.lg),
              ElevatedButton(
                onPressed: () => Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const LoginPage())),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('ログイン / 新規登録'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AuthenticatedLocationSharingView extends ConsumerStatefulWidget {
  @override
  ConsumerState<_AuthenticatedLocationSharingView> createState() =>
      _AuthenticatedLocationSharingViewState();
}

class _AuthenticatedLocationSharingViewState
    extends ConsumerState<_AuthenticatedLocationSharingView> {
  final _groupNameController = TextEditingController();

  @override
  void dispose() {
    _groupNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(locationSharingProvider);
    final notifier = ref.read(locationSharingProvider.notifier);

    ref.listen<LocationSharingState>(locationSharingProvider, (previous, next) {
      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage) {
        showErrorDialog(context, next.errorMessage!);
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('位置情報共有')),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _PoorSignalNotice(),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: state.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : state.group == null
                  ? _buildCreateGroupView(notifier)
                  : _buildGroupView(context, state, notifier),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateGroupView(LocationSharingNotifier notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'まだ共有グループがありません',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: AppSizes.fontMd,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'グループを作成すると、仲間・家族と位置情報を共有できます',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.lg),
        TextField(
          controller: _groupNameController,
          decoration: const InputDecoration(
            labelText: 'グループ名',
            hintText: '例: 家族グループ',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          width: double.infinity,
          height: AppSizes.buttonHeight,
          child: ElevatedButton(
            onPressed: () {
              final name = _groupNameController.text.trim();
              if (name.isEmpty) return;
              notifier.createGroup(name);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
            ),
            child: const Text('グループを作成'),
          ),
        ),
      ],
    );
  }

  Widget _buildGroupView(
    BuildContext context,
    LocationSharingState state,
    LocationSharingNotifier notifier,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              state.group!.name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: AppSizes.fontMd,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: notifier.refreshLocations,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Expanded(
          child: state.memberLocations.isEmpty
              ? Center(
                  child: Text(
                    'まだ共有された位置情報がありません',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                )
              : ListView(
                  children: [
                    for (final location in state.memberLocations)
                      _MemberLocationTile(location: location),
                  ],
                ),
        ),
        OutlinedButton.icon(
          onPressed: () => _showInviteDialog(context, notifier),
          icon: const Icon(Icons.person_add_alt),
          label: const Text('共有相手を追加'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(AppSizes.buttonHeight),
            foregroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        OutlinedButton.icon(
          onPressed: () => _shareCurrentLocation(notifier),
          icon: const Icon(Icons.my_location),
          label: const Text('現在地を共有する'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(AppSizes.buttonHeight),
            foregroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        SizedBox(
          width: double.infinity,
          height: AppSizes.buttonHeight,
          child: ElevatedButton.icon(
            onPressed: () => _showEmergencyDialog(context, notifier),
            icon: const Icon(Icons.sos),
            label: const Text('緊急連絡'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showInviteDialog(
    BuildContext context,
    LocationSharingNotifier notifier,
  ) async {
    final emailController = TextEditingController();
    final email = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('共有相手を追加'),
        content: TextField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(labelText: 'メールアドレス'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () =>
                Navigator.of(context).pop(emailController.text.trim()),
            child: const Text('追加'),
          ),
        ],
      ),
    );

    if (email != null && email.isNotEmpty) {
      await notifier.inviteMember(email);
    }
  }

  Future<void> _showEmergencyDialog(
    BuildContext context,
    LocationSharingNotifier notifier,
  ) async {
    final phoneNumber = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('緊急連絡'),
        content: const Text('選択した番号に電話をかけると同時に、現在地を仲間に共有します。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop('110'),
            child: const Text('警察(110)'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.of(dialogContext).pop('119'),
            child: const Text('消防・救急(119)'),
          ),
        ],
      ),
    );

    if (phoneNumber == null) return;

    // 電話発信は通信状況に関わらず必ず試みるため、位置共有(失敗しうる)とは
    // 独立して扱う。位置共有側のエラーは_shareCurrentLocation内で表示済み。
    await _shareCurrentLocation(notifier);

    final uri = Uri(scheme: 'tel', path: phoneNumber);
    final canLaunch = await canLaunchUrl(uri);
    if (!context.mounted) return;

    if (canLaunch) {
      await launchUrl(uri);
    } else {
      await showErrorDialog(context, '電話アプリを起動できませんでした');
    }
  }

  Future<void> _shareCurrentLocation(LocationSharingNotifier notifier) async {
    final consentGiven = ref.read(
      privacySettingsProvider.select((s) => s.locationSharingConsentGiven),
    );
    if (!consentGiven) {
      await _showConsentRequiredDialog();
      return;
    }

    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (mounted) {
          showErrorDialog(context, '位置情報の権限が許可されていません');
        }
        return;
      }

      final position = await Geolocator.getCurrentPosition();
      await notifier.shareCurrentLocation(
        position.latitude,
        position.longitude,
      );
    } on Exception catch (e) {
      if (mounted) showErrorDialog(context, '現在地の取得に失敗しました: $e');
    }
  }

  Future<void> _showConsentRequiredDialog() async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('位置情報の共有が許可されていません'),
        content: const Text(
          '「現在地を共有する」を使うには、設定の「プライバシー設定」で位置情報共有を'
          '許可してください。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('閉じる'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const PrivacySettingsPage(),
                ),
              );
            },
            child: const Text('プライバシー設定を開く'),
          ),
        ],
      ),
    );
  }
}

/// 山では電波が届きにくく、この機能が期待通りに動かないことがある旨の注意書き。
class _PoorSignalNotice extends StatelessWidget {
  const _PoorSignalNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.warning),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            color: AppColors.warning,
            size: AppSizes.iconSm,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              '山では電波状況が悪いため、位置情報の共有が遅れたり反映されないことがあります',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: AppSizes.fontSm,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MemberLocationTile extends StatelessWidget {
  const _MemberLocationTile({required this.location});

  final MemberLocation location;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.person, color: AppColors.primary),
        title: Text(location.email),
        subtitle: Text('最終更新 ${_formatTime(location.recordedAt)}'),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inMinutes < 1) return 'たった今';
    if (diff.inHours < 1) return '${diff.inMinutes}分前';
    if (diff.inDays < 1) return '${diff.inHours}時間前';
    return '${diff.inDays}日前';
  }
}
