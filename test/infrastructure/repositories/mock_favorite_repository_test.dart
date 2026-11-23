import 'package:flutter_test/flutter_test.dart';

import '../../support/fixtures.dart';

void main() {
  late Fixture f;
  setUp(() => f = Fixture());

  group('MockFavoriteRepository', () {
    test('arranca con los favoritos del seed', () async {
      expect(await f.favorites.getFavoriteCoaches(jorge), hasLength(2));
    });

    test('addFavorite es idempotente', () async {
      await f.favorites.addFavorite(studentId: jorge, coachId: carlosCoach);
      await f.favorites.addFavorite(studentId: jorge, coachId: carlosCoach);
      expect(await f.favorites.getFavoriteCoaches(jorge), hasLength(2));
    });

    test(
      'addFavorite agrega uno nuevo y queda primero (más reciente)',
      () async {
        await f.favorites.addFavorite(studentId: mateo, coachId: carlosCoach);
        await Future.delayed(const Duration(milliseconds: 5));
        await f.favorites.addFavorite(studentId: mateo, coachId: anaCoach);

        final list = await f.favorites.getFavoriteCoaches(mateo);
        expect(list.map((c) => c.id), [anaCoach, carlosCoach]);
      },
    );

    test('removeFavorite elimina y es idempotente', () async {
      await f.favorites.removeFavorite(studentId: jorge, coachId: carlosCoach);
      await f.favorites.removeFavorite(studentId: jorge, coachId: carlosCoach);

      expect(
        await f.favorites.isFavorite(studentId: jorge, coachId: carlosCoach),
        isFalse,
      );
      expect(await f.favorites.getFavoriteCoaches(jorge), hasLength(1));
    });

    test('los favoritos de un estudiante no afectan a otro', () async {
      await f.favorites.removeFavorite(studentId: jorge, coachId: carlosCoach);
      await f.favorites.addFavorite(studentId: mateo, coachId: carlosCoach);

      expect(
        await f.favorites.isFavorite(studentId: jorge, coachId: carlosCoach),
        isFalse,
      );
      expect(
        await f.favorites.isFavorite(studentId: mateo, coachId: carlosCoach),
        isTrue,
      );
    });

    test('rechaza un coach inexistente como lo hace la clave foránea', () {
      expect(
        f.favorites.addFavorite(studentId: jorge, coachId: 'no-existe'),
        throwsA(isA<StateError>()),
      );
    });

    test(
      'devuelve rating y cantidad derivados de las reseñas actuales',
      () async {
        f.chat.openConversation(mateo, anaCoach);
        await f.reviews.createReview(
          studentId: mateo,
          coachId: anaCoach,
          rating: 4,
        );
        await f.favorites.addFavorite(studentId: mateo, coachId: anaCoach);

        final ana = (await f.favorites.getFavoriteCoaches(
          mateo,
        )).firstWhere((coach) => coach.id == anaCoach);
        expect(ana.rating, 4);
        expect(ana.reviewsCount, 1);
      },
    );
  });
}
