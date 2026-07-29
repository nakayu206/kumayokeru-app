import 'package:flutter/material.dart';

import 'package:kumayokeru_app/core/constants/app_colors.dart';
import 'package:kumayokeru_app/core/constants/app_sizes.dart';
import 'package:kumayokeru_app/core/constants/app_spacing.dart';
import 'package:kumayokeru_app/core/constants/map_constants.dart';
import 'package:kumayokeru_app/presentation/pages/auth/login_page.dart';

enum _SoundType { bell, voice, mixed }

/// 設定画面(仕様書セクション12 ④)。
///
/// TODO(#13): 各設定値の永続化(Isar/shared_preferences)と結合する。
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  int _intervalSec = AudioConstants.defaultIntervalSec;
  _SoundType _soundType = _SoundType.bell;
  double _volume = AudioConstants.defaultVolume;
  bool _powerSavingMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('設定')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Text('存在通知機能', style: TextStyle(fontWeight: FontWeight.bold, fontSize: AppSizes.fontMd)),
          const SizedBox(height: AppSpacing.sm),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('再生間隔'),
            trailing: DropdownButton<int>(
              value: _intervalSec,
              items: const [15, 30, 60, 120]
                  .map((sec) => DropdownMenuItem(value: sec, child: Text('$sec秒')))
                  .toList(),
              onChanged: (value) => setState(() => _intervalSec = value ?? _intervalSec),
            ),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('音源選択'),
            trailing: SegmentedButton<_SoundType>(
              segments: const [
                ButtonSegment(value: _SoundType.bell, label: Text('鈴音')),
                ButtonSegment(value: _SoundType.voice, label: Text('声')),
                ButtonSegment(value: _SoundType.mixed, label: Text('混合')),
              ],
              selected: {_soundType},
              onSelectionChanged: (selection) => setState(() => _soundType = selection.first),
            ),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('音量'),
            subtitle: Slider(
              value: _volume,
              onChanged: (value) => setState(() => _volume = value),
              activeColor: AppColors.primary,
            ),
          ),
          const Divider(height: AppSpacing.x3l),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('省電力モード'),
            value: _powerSavingMode,
            onChanged: (value) => setState(() => _powerSavingMode = value),
            activeTrackColor: AppColors.primary,
          ),
          const Divider(height: AppSpacing.x3l),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.account_circle_outlined),
            title: const Text('アカウント(仲間との共有に必要)'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LoginPage())),
          ),
          const Divider(height: AppSpacing.x3l),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('地図データ管理'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('プライバシー設定'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('免責事項を確認する'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
