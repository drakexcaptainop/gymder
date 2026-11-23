import 'package:flutter_test/flutter_test.dart';
import 'package:gymder/domain/models/contact_request.dart';

void main() {
  group('ContactRequest', () {
    final createdAt = DateTime.utc(2026, 11, 18, 9, 30);

    ContactRequest build() => ContactRequest(
      id: 'r1',
      studentId: 's1',
      coachId: 'c1',
      studentName: 'Laura',
      coachName: 'Ana',
      message: 'Hola',
      createdAt: createdAt,
    );

    test('nace pendiente y sin fecha de resolución', () {
      final request = build();
      expect(request.status, ContactRequestStatus.pending);
      expect(request.studentName, 'Laura');
      expect(request.coachName, 'Ana');
      expect(request.resolvedAt, isNull);
    });

    test('copyWith resuelve la solicitud sin tocar el resto', () {
      final resolvedAt = DateTime.utc(2026, 11, 18, 10);
      final accepted = build().copyWith(
        status: ContactRequestStatus.accepted,
        resolvedAt: resolvedAt,
      );

      expect(accepted.status, ContactRequestStatus.accepted);
      expect(accepted.resolvedAt, resolvedAt);
      expect(accepted.id, 'r1');
      expect(accepted.studentId, 's1');
      expect(accepted.coachId, 'c1');
      expect(accepted.studentName, 'Laura');
      expect(accepted.coachName, 'Ana');
      expect(accepted.message, 'Hola');
      expect(accepted.createdAt, createdAt);
    });

    test('los estados coinciden con la migración', () {
      expect(ContactRequestStatus.values.map((s) => s.name), [
        'pending',
        'accepted',
        'declined',
        'cancelled',
      ]);
    });
  });
}
