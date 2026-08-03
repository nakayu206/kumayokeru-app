import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kumayokeru_app/app.dart';
import 'package:kumayokeru_app/core/config/flavor.dart';
import 'package:kumayokeru_app/domain/entities/notification_settings.dart';
import 'package:kumayokeru_app/infrastructure/presence_notification_audio_handler.dart';
import 'package:kumayokeru_app/presentation/providers/presence_notification_providers.dart';

/// 実際はmain_*.dartでAudioService.init()の結果をoverrideWithValue()するが、
/// ウィジェットテストではプラットフォームチャンネルを使わないフェイクで代替する。
class _FakeController implements PresenceNotificationController {
  @override
  Stream<bool> get isNotifyingStream => const Stream.empty();

  @override
  Stream<int> get secondsUntilNextPlayStream => const Stream.empty();

  @override
  void updateSettings(NotificationSettings settings) {}

  @override
  Future<void> start() async {}

  @override
  Future<void> stop() async {}

  @override
  Future<void> playNow() async {}
}

void main() {
  testWidgets('ホーム画面がアプリ名を表示する', (WidgetTester tester) async {
    AppConfig.setFlavor(Flavor.dev);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          presenceNotificationControllerProvider.overrideWithValue(
            _FakeController(),
          ),
        ],
        child: const KumaYokeruApp(),
      ),
    );

    expect(find.text('登山のお守り'), findsOneWidget);
  });
}
