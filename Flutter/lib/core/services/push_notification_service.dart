import 'package:flutter_riverpod/flutter_riverpod.dart';

class PushNotificationService {
  // TODO: Implementar con Firebase Cloud Messaging
  Future<void> initialize() async {
    // Placeholder para configuración FCM
  }

  Future<void> requestPermission() async {
    // Placeholder para solicitar permisos de notificación
  }
}

final pushNotificationServiceProvider = Provider<PushNotificationService>((ref) {
  return PushNotificationService();
});
