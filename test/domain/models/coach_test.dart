import 'package:flutter_test/flutter_test.dart';
import 'package:gymder/domain/models/coach.dart';

void main() {
  group('Coach', () {
    test('usa valores por defecto razonables', () {
      const coach = Coach(id: 'c1', profileId: 'p1', name: 'Carlos');

      expect(coach.isAvailable, isTrue);
      expect(coach.isVerified, isFalse);
      expect(coach.trialClassAvailable, isFalse);
      expect(coach.photos, isEmpty);
      expect(coach.rating, 0);
      expect(coach.reviewsCount, 0);
      expect(coach.specialty, isNull);
      expect(coach.modality, isNull);
    });

    test('copyWith cambia solo los campos indicados', () {
      const coach = Coach(
        id: 'c1',
        profileId: 'p1',
        name: 'Carlos',
        city: 'La Paz',
        startingPrice: 150,
        currencyCode: 'BOB',
        modality: CoachModality.inPerson,
      );

      final copy = coach.copyWith(city: 'Sucre', isAvailable: false);

      expect(copy.city, 'Sucre');
      expect(copy.isAvailable, isFalse);
      expect(copy.id, 'c1');
      expect(copy.name, 'Carlos');
      expect(copy.startingPrice, 150);
      expect(copy.currencyCode, 'BOB');
      expect(copy.modality, CoachModality.inPerson);
    });

    test('copyWith no modifica el objeto original (inmutabilidad)', () {
      const coach = Coach(id: 'c1', profileId: 'p1', name: 'Carlos');
      coach.copyWith(name: 'Otro');
      expect(coach.name, 'Carlos');
    });

    test('copyWith actualiza rating y reviewsCount', () {
      const coach = Coach(id: 'c1', profileId: 'p1', name: 'Carlos');
      final copy = coach.copyWith(rating: 4.5, reviewsCount: 2);
      expect(copy.rating, 4.5);
      expect(copy.reviewsCount, 2);
    });

    test('CoachModality tiene las tres modalidades de la migración', () {
      expect(CoachModality.values, hasLength(3));
    });
  });
}
