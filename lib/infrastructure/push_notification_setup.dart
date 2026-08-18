import 'dart:io';

import 'package:kumayokeru_app/domain/repositories/device_repository.dart';
import 'package:kumayokeru_app/infrastructure/push_notification_service.dart';

/// ログイン後にプッシュ通知の初期化(権限リクエスト・トークン取得・バックエンドへの登録)を
/// 行う。iOSはAPNs直接接続方針でFCM未対応(kumayokeru-backend#7参照)のため何もしない。
class PushNotificationSetup {
  PushNotificationSetup(
    this._service,
    this._deviceRepository, {
    bool Function()? isAndroid,
  }) : _isAndroid = isAndroid ?? (() => Platform.isAndroid);

  final PushNotificationService _service;
  final DeviceRepository _deviceRepository;
  final bool Function() _isAndroid;

  Future<void> start() async {
    if (!_isAndroid()) return;

    await _service.initialize(
      onToken: (token) async {
        try {
          await _deviceRepository.registerToken(token, 'android');
        } on Exception {
          // 登録に失敗しても致命的にはしない(次回起動時やトークン更新時に再試行される)。
        }
      },
    );
  }
}
