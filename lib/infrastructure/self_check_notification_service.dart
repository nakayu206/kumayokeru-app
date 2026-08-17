import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// 存在通知機能が停止していないかのセルフチェック通知を扱うサービス。
///
/// [scheduleCheck]で「delay後に警告通知を出す」予約を行い、再生ループが
/// 正常に動いている間は([PresenceNotificationAudioHandler]が)tickのたびに
/// 予約をキャンセル→再予約し続けることで、通知が実際に出ないようにする。
/// アプリのプロセスが(OSに強制終了される等で)死んでも、この予約はOS側の
/// アラームとして残るため、再生が止まったことにユーザーが気づける
/// (いわゆるデッドマンスイッチ)。
abstract interface class SelfCheckNotificationService {
  Future<void> initialize();

  Future<void> scheduleCheck(Duration delay);

  Future<void> cancelCheck();
}

class FlutterLocalSelfCheckNotificationService
    implements SelfCheckNotificationService {
  FlutterLocalSelfCheckNotificationService({
    FlutterLocalNotificationsPlugin? plugin,
  }) : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  static const _notificationId = 1001;
  static const _channelId = 'com.kumayokeru.app.channel.self_check';

  final FlutterLocalNotificationsPlugin _plugin;

  @override
  Future<void> initialize() async {
    tz_data.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const darwinSettings = DarwinInitializationSettings();
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
      ),
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  @override
  Future<void> scheduleCheck(Duration delay) async {
    await _plugin.zonedSchedule(
      id: _notificationId,
      scheduledDate: tz.TZDateTime.now(tz.local).add(delay),
      title: '存在通知が停止している可能性があります',
      body: 'クマヨケールを開いて、存在通知機能が作動しているか確認してください',
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          'セルフチェック通知',
          channelDescription: '存在通知機能が停止していないかを確認する通知',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  @override
  Future<void> cancelCheck() async {
    await _plugin.cancel(id: _notificationId);
  }
}
