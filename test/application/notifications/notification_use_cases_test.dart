import 'package:flutter_test/flutter_test.dart';
import 'package:gymder/application/notifications/notification_use_cases.dart';
import 'package:gymder/domain/models/app_notification.dart';

import '../../support/fixtures.dart';

void main() {
  late Fixture f;
  setUp(() => f = Fixture());

  group('GetNotifications', () {
    test('devuelve los avisos del estudiante', () async {
      final list = await GetNotifications(f.notifications)(jorge);
      expect(list, hasLength(1));
      expect(list.first.type, NotificationType.contactRequestResolved);
    });

    test(
      'los avisos del coach llegan del más reciente al más antiguo',
      () async {
        final list = await GetNotifications(f.notifications)(carlosProfile);
        expect(list.map((n) => n.type), [
          NotificationType.reviewCreated,
          NotificationType.contactRequestCreated,
          NotificationType.contactRequestCreated,
        ]);
      },
    );

    test('un usuario sin avisos recibe lista vacía', () async {
      expect(
        await GetNotifications(f.notifications)('perfil-sin-avisos'),
        isEmpty,
      );
    });
  });

  group('GetUnreadNotificationCount', () {
    test('cuenta solo los no leídos', () async {
      final count = GetUnreadNotificationCount(f.notifications);
      expect(await count(jorge), 1);
      // Carlos tiene 3 avisos; la primera solicitud ya estaba leída.
      expect(await count(carlosProfile), 2);
      expect(await count(mateo), 1);
    });
  });

  group('MarkNotificationRead', () {
    test('marca el aviso como leído', () async {
      await MarkNotificationRead(f.notifications)('notif_1');
      expect(await GetUnreadNotificationCount(f.notifications)(jorge), 0);
    });

    test('read_at se fija una sola vez', () async {
      final mark = MarkNotificationRead(f.notifications);
      await mark('notif_1');
      final first = (await GetNotifications(f.notifications)(
        jorge,
      )).first.readAt;

      await Future.delayed(const Duration(milliseconds: 20));
      await mark('notif_1');
      final second = (await GetNotifications(f.notifications)(
        jorge,
      )).first.readAt;

      expect(second, first);
    });

    test('un id desconocido no lanza error', () async {
      await MarkNotificationRead(f.notifications)('no-existe');
    });
  });
}
