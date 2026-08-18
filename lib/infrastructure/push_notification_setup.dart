import 'dart:io';

import 'package:flutter/foundation.dart';

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

  /// プッシュ通知はあくまで付加機能(存在通知・オフライン地図等のコア機能とは無関係)
  /// のため、権限拒否・Firebase未設定(dev/stg flavor向けgoogle-services.json未登録等)・
  /// 通信エラーなど、ここで起きうるどんな失敗も外へ伝播させず、ログにだけ残して
  /// 静かに諦める(呼び出し元のログイン処理自体を壊さないため)。
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
}
