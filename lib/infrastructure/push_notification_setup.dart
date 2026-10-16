import 'dart:io';

import 'package:flutter/foundation.dart';

import 'package:kumayokeru_app/domain/repositories/device_repository.dart';
import 'package:kumayokeru_app/infrastructure/push_notification_service.dart';

/// ログイン後にプッシュ通知を初期化する。iOSはFCM未対応のため何もしない。
class PushNotificationSetup {
  PushNotificationSetup(
    this._service,
    this._deviceRepository, {
    bool Function()? isAndroid,
  }) : _isAndroid = isAndroid ?? (() => Platform.isAndroid);

  final PushNotificationService _service;
  final DeviceRepository _deviceRepository;
  final bool Function() _isAndroid;

  /// 失敗してもログイン処理を壊さないよう外へは伝播させない。
  Future<void> start() async {
    if (!_isAndroid()) return;

    try {
      await _service.initialize(
        onToken: (token) async {
          try {
            await _deviceRepository.registerToken(token, 'android');
          } on Exception catch (e) {
            debugPrint('デバイストークンの登録に失敗しました(次回起動時に再試行): $e');
          }
        },
      );
    } on Exception catch (e) {
      debugPrint('プッシュ通知の初期化に失敗しました(プッシュ通知は利用できません): $e');
    }
  }

  /// ログアウト時にこの端末へのプッシュ通知を止める。失敗してもログアウト処理は
  /// 続行する(トークンの有効期限切れ等で認証前に呼ばれる可能性があるため)。
  Future<void> unregisterCurrentDevice() async {
    if (!_isAndroid()) return;

    try {
      final token = await _service.getCurrentToken();
      if (token == null) return;
      await _deviceRepository.unregisterToken(token);
    } on Exception catch (e) {
      debugPrint('デバイストークンの登録解除に失敗しました: $e');
    }
  }
}
