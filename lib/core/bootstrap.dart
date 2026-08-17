import 'package:audio_service/audio_service.dart';

import 'package:kumayokeru_app/infrastructure/notification_sound_player.dart';
import 'package:kumayokeru_app/infrastructure/presence_notification_audio_handler.dart';
import 'package:kumayokeru_app/infrastructure/self_check_notification_service.dart';

/// 存在通知機能用のAudioHandlerを初期化する。
///
/// AndroidではAudioServiceConfigによりフォアグラウンドサービスとして動作し、
/// アプリがバックグラウンドでも再生ループ(Timer)と通知音再生が継続する。
/// あわせてセルフチェック通知(再生が止まったらOS側のアラームで気づける仕組み)も
/// 初期化する。runApp()より前に呼び出し、結果をpresenceNotificationControllerProviderへ
/// overrideWithValue()すること。
Future<PresenceNotificationAudioHandler>
initPresenceNotificationAudioHandler() async {
  final selfCheck = FlutterLocalSelfCheckNotificationService();
  await selfCheck.initialize();

  return AudioService.init(
    builder: () => PresenceNotificationAudioHandler(
      JustAudioNotificationSoundPlayer(),
      selfCheck,
    ),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.kumayokeru.app.channel.presence',
      androidNotificationChannelName: '存在通知機能',
      androidNotificationChannelDescription: '登山中に存在通知音を再生していることを示す通知です',
    ),
  );
}
