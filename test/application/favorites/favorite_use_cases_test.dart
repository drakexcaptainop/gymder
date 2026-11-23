import 'package:flutter_test/flutter_test.dart';
import 'package:gymder/application/favorites/favorite_use_cases.dart';

import '../../support/fixtures.dart';

void main() {
  late Fixture f;
  setUp(() => f = Fixture());

  group('ToggleFavorite', () {
    test('quita un favorito existente y devuelve false', () async {
      final toggle = ToggleFavorite(f.favorites);
      final result = await toggle(studentId: jorge, coachId: carlosCoach);

      expect(result, isFalse);
      expect(
        await f.favorites.isFavorite(studentId: jorge, coachId: carlosCoach),
        isFalse,
      );
    });

    test('agrega un favorito nuevo y devuelve true', () async {
      final toggle = ToggleFavorite(f.favorites);
      final result = await toggle(studentId: mateo, coachId: anaCoach);

      expect(result, isTrue);
      expect(
        await f.favorites.isFavorite(studentId: mateo, coachId: anaCoach),
        isTrue,
      );
    });

    test('dos toggles seguidos dejan todo como estaba', () async {
      final toggle = ToggleFavorite(f.favorites);
      await toggle(studentId: mateo, coachId: anaCoach);
      await toggle(studentId: mateo, coachId: anaCoach);

      expect(await GetFavoriteCoaches(f.favorites)(mateo), isEmpty);
    });
  });

  group('GetFavoriteCoaches', () {
    test('lista los favoritos de Jorge, el más reciente primero', () async {
      final coaches = await GetFavoriteCoaches(f.favorites)(jorge);
      expect(coaches.map((c) => c.id), [anaCoach, carlosCoach]);
    });

    test('un estudiante sin favoritos recibe lista vacía', () async {
      expect(await GetFavoriteCoaches(f.favorites)(mateo), isEmpty);
    });
  });
}
