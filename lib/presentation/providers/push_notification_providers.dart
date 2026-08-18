import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kumayokeru_app/data/repositories/device_repository_impl.dart';
import 'package:kumayokeru_app/domain/repositories/device_repository.dart';
import 'package:kumayokeru_app/infrastructure/push_notification_service.dart';
import 'package:kumayokeru_app/infrastructure/push_notification_setup.dart';

final deviceRepositoryProvider = Provider<DeviceRepository>((ref) {
  return DeviceRepositoryImpl();
});

final pushNotificationServiceProvider = Provider<PushNotificationService>((
  ref,
) {
  return FirebaseCloudMessagingService();
});

final pushNotificationSetupProvider = Provider<PushNotificationSetup>((ref) {
  return PushNotificationSetup(
    ref.watch(pushNotificationServiceProvider),
    ref.watch(deviceRepositoryProvider),
  );
});
