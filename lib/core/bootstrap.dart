import 'package:audio_service/audio_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import 'package:kumayokeru_app/infrastructure/notification_sound_player.dart';
import 'package:kumayokeru_app/infrastructure/presence_notification_audio_handler.dart';
import 'package:kumayokeru_app/infrastructure/self_check_notification_service.dart';

/// runApp()より前に呼び出し、結果をpresenceNotificationControllerProviderへoverrideWithValue()すること。
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

/// 失敗してもアプリ本体は動かしたいので例外を吸収する。
Future<void> initFirebase() async {
  try {
    await Firebase.initializeApp();
  } on Exception catch (e) {
    debugPrint('Firebase初期化に失敗しました(プッシュ通知は利用できません): $e');
  }
}
