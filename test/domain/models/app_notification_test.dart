import 'package:flutter_test/flutter_test.dart';
import 'package:gymder/domain/models/app_notification.dart';

void main() {
  group('AppNotification', () {
    final createdAt = DateTime.utc(2026, 11, 3, 14);

    AppNotification build() => AppNotification(
      id: 'n1',
      recipientId: 'p1',
      type: NotificationType.contactRequestCreated,
      contactRequestId: 'r1',
      createdAt: createdAt,
    );

    test('nace sin leer', () {
      expect(build().isRead, isFalse);
      expect(build().readAt, isNull);
    });

    test('copyWith(readAt) la marca como leída y conserva el resto', () {
      final readAt = DateTime.utc(2026, 11, 3, 15);
      final read = build().copyWith(readAt: readAt);

      expect(read.isRead, isTrue);
      expect(read.readAt, readAt);
      expect(read.id, 'n1');
      expect(read.recipientId, 'p1');
      expect(read.type, NotificationType.contactRequestCreated);
      expect(read.contactRequestId, 'r1');
      expect(read.reviewId, isNull);
      expect(read.createdAt, createdAt);
    });

    test('hay tres tipos de aviso como en la migración', () {
      expect(NotificationType.values, hasLength(3));
    });
  });
}
