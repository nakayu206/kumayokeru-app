import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kumayokeru_app/core/constants/app_colors.dart';
import 'package:kumayokeru_app/core/constants/app_sizes.dart';
import 'package:kumayokeru_app/core/constants/app_spacing.dart';
import 'package:kumayokeru_app/domain/entities/notification_settings.dart';
import 'package:kumayokeru_app/presentation/pages/auth/login_page.dart';
import 'package:kumayokeru_app/presentation/pages/settings/disclaimer_page.dart';
import 'package:kumayokeru_app/presentation/pages/settings/map_data_management_page.dart';
import 'package:kumayokeru_app/presentation/pages/settings/privacy_settings_page.dart';
import 'package:kumayokeru_app/presentation/providers/auth_providers.dart';
import 'package:kumayokeru_app/presentation/providers/settings_providers.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(audioSettingsProvider);
    final notifier = ref.read(audioSettingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('設定')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Text(
            '存在通知機能',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: AppSizes.fontMd,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('再生間隔'),
            trailing: DropdownButton<int>(
              value: settings.intervalSec,
              items: const [15, 30, 60, 120]
                  .map(
                    (sec) => DropdownMenuItem(value: sec, child: Text('$sec秒')),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) notifier.setIntervalSec(value);
              },
            ),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('音源選択'),
            trailing: SegmentedButton<NotificationSoundType>(
              segments: const [
                ButtonSegment(
                  value: NotificationSoundType.bell,
                  label: Text('鈴音'),
                ),
                ButtonSegment(
                  value: NotificationSoundType.voice,
                  label: Text('声'),
                ),
                ButtonSegment(
                  value: NotificationSoundType.mixed,
                  label: Text('混合'),
                ),
              ],
              selected: {settings.soundType},
              onSelectionChanged: (selection) =>
                  notifier.setSoundType(selection.first),
            ),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('音量'),
            subtitle: Slider(
              value: settings.volume,
              onChanged: notifier.setVolume,
              activeColor: AppColors.primary,
            ),
          ),
          const Divider(height: AppSpacing.x3l),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('省電力モード'),
            value: settings.powerSavingMode,
            onChanged: notifier.setPowerSavingMode,
            activeTrackColor: AppColors.primary,
          ),
          const Divider(height: AppSpacing.x3l),
          Builder(
            builder: (context) {
              final authState = ref.watch(authProvider);
              if (authState.isAuthenticated) {
                final user = authState.user!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.account_circle),
                      title: Text(user.name),
                      subtitle: Text(user.email),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit),
                        tooltip: '表示名を変更',
                        onPressed: () =>
                            _showEditNameDialog(context, ref, user.name),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () =>
                            ref.read(authProvider.notifier).logout(),
                        child: const Text('ログアウト'),
                      ),
                    ),
                  ],
                );
              }
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.account_circle_outlined),
                title: const Text('アカウント(仲間との共有に必要)'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const LoginPage())),
              );
            },
          ),
          const Divider(height: AppSpacing.x3l),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('地図データ管理'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const MapDataManagementPage()),
            ),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('プライバシー設定'),
            subtitle: const Text('位置情報共有のON/OFFを管理'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const PrivacySettingsPage()),
            ),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('免責事項を確認する'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const DisclaimerPage())),
          ),
        ],
      ),
    );
  }
}

Future<void> _showEditNameDialog(
  BuildContext context,
  WidgetRef ref,
  String currentName,
) async {
  final nameController = TextEditingController(text: currentName);
  final newName = await showDialog<String>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('表示名を変更'),
      content: TextField(
        controller: nameController,
        decoration: const InputDecoration(labelText: '表示名'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: const Text('キャンセル'),
        ),
        TextButton(
          onPressed: () =>
              Navigator.of(dialogContext).pop(nameController.text.trim()),
          child: const Text('変更'),
        ),
      ],
    ),
  );

  if (newName != null && newName.isNotEmpty && newName != currentName) {
    await ref.read(authProvider.notifier).updateName(newName);
  }
}
