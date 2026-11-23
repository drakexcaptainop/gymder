import '../../domain/models/app_notification.dart';
import '../../domain/repositories/notification_repository.dart';

class GetNotifications {
  final NotificationRepository _repository;

  const GetNotifications(this._repository);

  Future<List<AppNotification>> call(String recipientId) =>
      _repository.getNotifications(recipientId);
}

/// Número para la campanita (avisos sin leer).
class GetUnreadNotificationCount {
  final NotificationRepository _repository;

  const GetUnreadNotificationCount(this._repository);

  Future<int> call(String recipientId) =>
      _repository.getUnreadCount(recipientId);
}

class MarkNotificationRead {
  final NotificationRepository _repository;

  const MarkNotificationRead(this._repository);

  Future<void> call(String notificationId) =>
      _repository.markAsRead(notificationId);
}
