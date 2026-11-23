import 'package:flutter_test/flutter_test.dart';
import 'package:gymder/domain/models/review.dart';

void main() {
  test('Review guarda autor, coach, calificación y comentario opcional', () {
    final createdAt = DateTime.utc(2026, 11, 11, 8);
    final review = Review(
      id: 'r1',
      coachId: 'c1',
      studentId: 's1',
      studentName: 'Jorge Barahona',
      rating: 5,
      createdAt: createdAt,
    );

    expect(review.coachId, 'c1');
    expect(review.studentId, 's1');
    expect(review.studentName, 'Jorge Barahona');
    expect(review.rating, 5);
    expect(review.comment, isNull);
    expect(review.createdAt, createdAt);
  });
}
