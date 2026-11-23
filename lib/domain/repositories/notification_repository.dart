import '../models/app_notification.dart';

abstract class NotificationRepository {
  /// Más recientes primero.
  Future<List<AppNotification>> getNotifications(String recipientId);

  Future<int> getUnreadCount(String recipientId);

  /// Marca como leído (solo se fija una vez).
  Future<void> markAsRead(String notificationId);
}
