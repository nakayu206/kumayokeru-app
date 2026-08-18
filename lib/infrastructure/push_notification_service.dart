import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// プッシュ通知(FCM)の権限リクエスト・トークン取得・フォアグラウンド表示を抽象化する
/// (テストでは実際のFirebaseに繋がずフェイク実装に差し替える)。
abstract interface class PushNotificationService {
  /// 通知権限をリクエストし、取得できたFCMトークンを[onToken]に渡す。
  /// トークンが更新された場合(onTokenRefresh)も同じコールバックが呼ばれる。
  /// また、フォアグラウンド受信時にOS標準の通知として表示する処理も開始する。
  Future<void> initialize({required Future<void> Function(String token) onToken});
}

/// firebase_messagingによる実装。
///
/// フォアグラウンド中に受信したプッシュ通知は、OSの仕様上デフォルトでは
/// 通知欄に表示されない(バックグラウンド/終了中はOSが自動表示する)ため、
/// flutter_local_notificationsで手動表示する。
class FirebaseCloudMessagingService implements PushNotificationService {
  FirebaseCloudMessagingService({
    FirebaseMessaging? messaging,
    FlutterLocalNotificationsPlugin? localNotificationsPlugin,
  }) : _messaging = messaging ?? FirebaseMessaging.instance,
       _localNotificationsPlugin =
           localNotificationsPlugin ?? FlutterLocalNotificationsPlugin();

  static const _channelId = 'com.kumayokeru.app.channel.push';

  final FirebaseMessaging _messaging;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin;

  @override
  Future<void> initialize({
    required Future<void> Function(String token) onToken,
  }) async {
    await _messaging.requestPermission();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinSettings = DarwinInitializationSettings();
    await _localNotificationsPlugin.initialize(
      settings: const InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
      ),
    );

    final token = await _messaging.getToken();
    if (token != null) {
      await onToken(token);
    }
    _messaging.onTokenRefresh.listen(onToken);

    FirebaseMessaging.onMessage.listen(_showForegroundNotification);
  }

  Future<void> _showForegroundNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    await _localNotificationsPlugin.show(
      id: message.hashCode,
      title: notification.title,
      body: notification.body,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          'プッシュ通知',
          channelDescription: '緊急連絡(SOS)などのプッシュ通知',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }
}
