import 'package:flutter_test/flutter_test.dart';
import 'package:gymder/domain/models/app_notification.dart';
import 'package:gymder/domain/models/contact_request.dart';

import '../../support/fixtures.dart';

void main() {
  group('MockContactRequestRepository', () {
    late Fixture f;
    setUp(() => f = Fixture());

    test('la solicitud sigue pendiente y no abre conversación', () async {
      final request = await f.contacts.createRequest(
        studentId: jorge,
        coachId: anaCoach,
      );
      await Future.delayed(const Duration(milliseconds: 100));

      final mine = await f.contacts.getStudentRequests(jorge);
      expect(
        mine.firstWhere((r) => r.id == request.id).status,
        ContactRequestStatus.pending,
      );
      expect(await f.chat.getConversations(jorge), hasLength(1)); // solo Carlos
    });

    test('al crear una solicitud se avisa al coach', () async {
      final request = await f.contacts.createRequest(
        studentId: jorge,
        coachId: anaCoach,
      );

      final notices = await f.notifications.getNotifications(anaProfile);
      expect(notices, hasLength(2));
      expect(notices.first.type, NotificationType.contactRequestCreated);
      expect(notices.first.contactRequestId, request.id);
      expect(notices.first.isRead, isFalse);
    });

    test(
      'cancelar no genera aviso al estudiante ni abre conversación',
      () async {
        final request = await f.contacts.createRequest(
          studentId: laura,
          coachId: carlosCoach,
        );
        await f.contacts.cancelRequest(request.id);

        expect(await f.notifications.getNotifications(laura), isEmpty);
        expect(await f.chat.getConversations(laura), isEmpty);
      },
    );
  });

  group('flujo del coach', () {
    late Fixture f;
    setUp(() => f = Fixture());

    test('el coach lista sus solicitudes y acepta una pendiente', () async {
      const requestId = '50000000-0000-4000-8000-000000000002';
      final received = await f.contacts.getCoachRequests(anaCoach);
      expect(received.map((request) => request.id), contains(requestId));

      final accepted = await f.contacts.resolveRequest(
        requestId: requestId,
        coachId: anaCoach,
        status: ContactRequestStatus.accepted,
      );
      expect(accepted.status, ContactRequestStatus.accepted);
      expect(accepted.resolvedAt, isNotNull);

      final conversations = await f.chat.getConversations(laura);
      expect(conversations.any((c) => c.coachId == anaCoach), isTrue);

      final notices = await f.notifications.getNotifications(laura);
      expect(
        notices.any(
          (n) =>
              n.type == NotificationType.contactRequestResolved &&
              n.contactRequestId == requestId,
        ),
        isTrue,
      );
    });

    test('el coach puede rechazar y no se abre conversación', () async {
      final request = await f.contacts.createRequest(
        studentId: jorge,
        coachId: anaCoach,
      );
      final declined = await f.contacts.resolveRequest(
        requestId: request.id,
        coachId: anaCoach,
        status: ContactRequestStatus.declined,
      );
      expect(declined.status, ContactRequestStatus.declined);
      expect(
        (await f.chat.getConversations(
          jorge,
        )).any((conversation) => conversation.coachId == anaCoach),
        isFalse,
      );
    });

    test('otro coach no puede resolver la solicitud', () {
      expect(
        f.contacts.resolveRequest(
          requestId: '50000000-0000-4000-8000-000000000002',
          coachId: carlosCoach,
          status: ContactRequestStatus.accepted,
        ),
        throwsA(isA<StateError>()),
      );
    });
  });
}
