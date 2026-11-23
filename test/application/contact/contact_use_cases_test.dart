import 'package:flutter_test/flutter_test.dart';
import 'package:gymder/application/contact/contact_use_cases.dart';
import 'package:gymder/domain/models/contact_request.dart';

import '../../support/fixtures.dart';

void main() {
  late Fixture f;
  setUp(() => f = Fixture());

  group('RequestContact', () {
    test('crea una solicitud pendiente', () async {
      final request = await RequestContact(f.contacts)(
        studentId: jorge,
        coachId: anaCoach,
        message: '  Quiero yoga  ',
      );

      expect(request.status, ContactRequestStatus.pending);
      expect(request.message, 'Quiero yoga');
      expect(request.resolvedAt, isNull);
    });

    test('un mensaje en blanco se guarda como null', () async {
      final request = await RequestContact(f.contacts)(
        studentId: jorge,
        coachId: anaCoach,
        message: '   ',
      );
      expect(request.message, isNull);
    });

    test('no permite dos solicitudes pendientes con el mismo coach', () async {
      final request = RequestContact(f.contacts);
      await request(studentId: jorge, coachId: anaCoach);

      expect(
        request(studentId: jorge, coachId: anaCoach),
        throwsA(isA<StateError>()),
      );
    });

    test('permite otra solicitud si la anterior ya fue resuelta', () async {
      // En el seed Jorge ya tiene una solicitud aceptada con Carlos.
      final request = await RequestContact(f.contacts)(
        studentId: jorge,
        coachId: carlosCoach,
      );
      expect(request.status, ContactRequestStatus.pending);
    });

    test('rechaza coaches inactivos o inexistentes', () async {
      final request = RequestContact(f.contacts);
      expect(
        request(studentId: jorge, coachId: diegoCoach),
        throwsA(isA<StateError>()),
      );
      expect(
        request(studentId: jorge, coachId: 'no-existe'),
        throwsA(isA<StateError>()),
      );
    });
  });

  group('GetMyContactRequests', () {
    test('devuelve las del estudiante, la más reciente primero', () async {
      final created = await RequestContact(f.contacts)(
        studentId: jorge,
        coachId: anaCoach,
      );

      final list = await GetMyContactRequests(f.contacts)(jorge);
      expect(list, hasLength(2));
      expect(list.first.id, created.id);
    });

    test('no mezcla solicitudes de otros estudiantes', () async {
      final requests = await GetMyContactRequests(f.contacts)(laura);
      expect(requests, hasLength(1));
      expect(requests.single.studentId, laura);
    });
  });

  group('flujo del coach', () {
    test('lista y acepta una solicitud recibida', () async {
      final received = await GetCoachContactRequests(f.contacts)(anaCoach);
      expect(received, hasLength(1));
      expect(received.single.studentName, 'Laura Camacho');
      expect(received.single.coachName, 'Ana Rojas');

      final accepted = await ResolveContactRequest(f.contacts)(
        requestId: received.single.id,
        coachId: anaCoach,
        status: ContactRequestStatus.accepted,
      );
      expect(accepted.status, ContactRequestStatus.accepted);
      expect(
        (await f.chat.getConversations(
          laura,
        )).any((conversation) => conversation.coachId == anaCoach),
        isTrue,
      );
    });

    test('solo acepta estados accepted o declined', () {
      expect(
        ResolveContactRequest(f.contacts)(
          requestId: '50000000-0000-4000-8000-000000000002',
          coachId: anaCoach,
          status: ContactRequestStatus.cancelled,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  group('CancelContactRequest', () {
    test('cancela una solicitud pendiente y fija resolvedAt', () async {
      final created = await RequestContact(f.contacts)(
        studentId: jorge,
        coachId: anaCoach,
      );

      final cancelled = await CancelContactRequest(f.contacts)(created.id);
      expect(cancelled.status, ContactRequestStatus.cancelled);
      expect(cancelled.resolvedAt, isNotNull);
    });

    test('no se puede cancelar dos veces', () async {
      final created = await RequestContact(f.contacts)(
        studentId: jorge,
        coachId: anaCoach,
      );
      final cancel = CancelContactRequest(f.contacts);
      await cancel(created.id);

      expect(cancel(created.id), throwsA(isA<StateError>()));
    });

    test('no se puede cancelar una solicitud ya aceptada', () {
      expect(
        CancelContactRequest(f.contacts)(
          '50000000-0000-4000-8000-000000000001',
        ),
        throwsA(isA<StateError>()),
      );
    });

    test('una solicitud inexistente lanza StateError', () {
      expect(
        CancelContactRequest(f.contacts)('no-existe'),
        throwsA(isA<StateError>()),
      );
    });
  });
}
