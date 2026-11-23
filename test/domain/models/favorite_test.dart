import 'package:flutter_test/flutter_test.dart';
import 'package:gymder/domain/models/favorite.dart';

void main() {
  group('Favorite', () {
    final createdAt = DateTime.utc(2026, 11, 1);

    test('guarda sus campos', () {
      final fav = Favorite(
        studentId: 's1',
        coachId: 'c1',
        createdAt: createdAt,
      );
      expect(fav.studentId, 's1');
      expect(fav.coachId, 'c1');
      expect(fav.createdAt, createdAt);
    });

    test('copyWith cambia solo lo indicado', () {
      final fav = Favorite(
        studentId: 's1',
        coachId: 'c1',
        createdAt: createdAt,
      );
      final copy = fav.copyWith(coachId: 'c2');
      expect(copy.coachId, 'c2');
      expect(copy.studentId, 's1');
      expect(copy.createdAt, createdAt);
    });
  });
}
