import 'package:flutter_test/flutter_test.dart';

import '../../support/fixtures.dart';

void main() {
  late Fixture f;
  setUp(() => f = Fixture());

  group('MockCoachRepository', () {
    test('discovery excluye coaches inactivos', () async {
      final list = await f.coaches.getDiscoveryCoaches();
      expect(list.every((c) => c.isAvailable), isTrue);
      expect(list.any((c) => c.id == diegoCoach), isFalse);
    });

    test('getCoachById también encuentra coaches inactivos', () async {
      final diego = await f.coaches.getCoachById(diegoCoach);
      expect(diego, isNotNull);
      expect(diego!.isAvailable, isFalse);
    });

    test('getCoachById devuelve null si no existe', () async {
      expect(await f.coaches.getCoachById('no-existe'), isNull);
    });

    test('rating y reviewsCount se derivan de las reseñas', () async {
      final before = await f.coaches.getCoachById(anaCoach);
      expect(before!.rating, 0);
      expect(before.reviewsCount, 0);

      f.chat.openConversation(laura, anaCoach);
      await f.reviews.createReview(
        studentId: laura,
        coachId: anaCoach,
        rating: 4,
      );

      final after = await f.coaches.getCoachById(anaCoach);
      expect(after!.rating, 4.0);
      expect(after.reviewsCount, 1);
    });

    test(
      'getCoachesBySpecialty busca por coincidencia parcial sin mayúsculas',
      () async {
        final result = await f.coaches.getCoachesBySpecialty('hiper');
        expect(result.map((c) => c.id), [carlosCoach]);
      },
    );
  });
}
