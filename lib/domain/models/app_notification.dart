/// Tipos de aviso (notifications.notification_type).
enum NotificationType {
  contactRequestCreated, // para el coach: le llegó una solicitud
  contactRequestResolved, // para el estudiante: su solicitud fue aceptada o rechazada
  reviewCreated, // para el coach: recibió una reseña
}

/// Aviso para un usuario (tabla notifications). Se llama AppNotification para no
/// chocar con la clase Notification de Flutter.
class AppNotification {
  final String id;
  final String recipientId; // profiles.id
  final NotificationType type;
  final String? contactRequestId; // según el tipo, uno de los dos viene lleno
  final String? reviewId;
  final DateTime createdAt;
  final DateTime? readAt;

  const AppNotification({
    required this.id,
    required this.recipientId,
    required this.type,
    this.contactRequestId,
    this.reviewId,
    required this.createdAt,
    this.readAt,
  });

  bool get isRead => readAt != null;

  AppNotification copyWith({DateTime? readAt}) {
    return AppNotification(
      id: id,
      recipientId: recipientId,
      type: type,
      contactRequestId: contactRequestId,
      reviewId: reviewId,
      createdAt: createdAt,
      readAt: readAt ?? this.readAt,
    );
  }
}
