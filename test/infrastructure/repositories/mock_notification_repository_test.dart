import 'package:flutter_test/flutter_test.dart';
import 'package:gymder/domain/models/app_notification.dart';

import '../../support/fixtures.dart';

void main() {
  late Fixture f;
  setUp(() => f = Fixture());

  group('MockNotificationRepository', () {
    test('add crea un aviso sin leer para el destinatario', () async {
      f.notifications.add(
        recipientId: laura,
        type: NotificationType.contactRequestResolved,
        contactRequestId: 'r1',
      );

      final list = await f.notifications.getNotifications(laura);
      expect(list, hasLength(1));
      expect(list.first.isRead, isFalse);
      expect(list.first.contactRequestId, 'r1');
      expect(await f.notifications.getUnreadCount(laura), 1);
    });

    test('los avisos salen ordenados del más nuevo al más viejo', () async {
      f.notifications.add(
        recipientId: laura,
        type: NotificationType.contactRequestResolved,
        contactRequestId: 'r1',
      );
      await Future.delayed(const Duration(milliseconds: 5));
      f.notifications.add(
        recipientId: laura,
        type: NotificationType.contactRequestResolved,
        contactRequestId: 'r2',
      );

      final list = await f.notifications.getNotifications(laura);
      expect(list.map((n) => n.contactRequestId), ['r2', 'r1']);
    });

    test('markAsRead baja el contador de no leídos', () async {
      f.notifications.add(
        recipientId: laura,
        type: NotificationType.reviewCreated,
        reviewId: 'rv1',
      );
      final id = (await f.notifications.getNotifications(laura)).first.id;

      await f.notifications.markAsRead(id);

      expect(await f.notifications.getUnreadCount(laura), 0);
      expect(
        (await f.notifications.getNotifications(laura)).first.isRead,
        isTrue,
      );
    });

    test('los avisos no se mezclan entre usuarios', () async {
      f.notifications.add(
        recipientId: laura,
        type: NotificationType.reviewCreated,
        reviewId: 'rv1',
      );
      expect(
        await f.notifications.getNotifications('perfil-sin-avisos'),
        isEmpty,
      );
    });
  });
}
