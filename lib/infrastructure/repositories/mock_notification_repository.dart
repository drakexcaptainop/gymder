import '../../domain/models/app_notification.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/mock/mock_catalog_data.dart';

class MockNotificationRepository implements NotificationRepository {
  final List<AppNotification> _notifications = List.of(kMockNotifications);

  /// Lo usan los otros mocks para simular los triggers de la base
  /// (solicitud creada, solicitud resuelta, reseña creada).
  void add({
    required String recipientId,
    required NotificationType type,
    String? contactRequestId,
    String? reviewId,
  }) {
    _notifications.add(
      AppNotification(
        id: 'notif_${DateTime.now().microsecondsSinceEpoch}',
        recipientId: recipientId,
        type: type,
        contactRequestId: contactRequestId,
        reviewId: reviewId,
        createdAt: DateTime.now().toUtc(),
      ),
    );
  }

  @override
  Future<List<AppNotification>> getNotifications(String recipientId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final mine = _notifications
        .where((n) => n.recipientId == recipientId)
        .toList();
    mine.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return mine;
  }

  @override
  Future<int> getUnreadCount(String recipientId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _notifications
        .where((n) => n.recipientId == recipientId && !n.isRead)
        .length;
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index == -1) return;
    if (_notifications[index].isRead) return; // read_at se fija una sola vez
    _notifications[index] = _notifications[index].copyWith(
      readAt: DateTime.now().toUtc(),
    );
  }
}
