import 'package:flutter_test/flutter_test.dart';
import 'package:gymder/application/reviews/review_use_cases.dart';

import '../../support/fixtures.dart';

void main() {
  late Fixture f;
  setUp(() => f = Fixture());

  group('GetCoachReviews', () {
    test('devuelve la reseña del seed para Carlos', () async {
      final reviews = await GetCoachReviews(f.reviews)(carlosCoach);
      expect(reviews, hasLength(1));
      expect(reviews.first.rating, 5);
      expect(reviews.first.studentName, 'Jorge Barahona');
    });

    test('un coach sin reseñas devuelve lista vacía', () async {
      expect(await GetCoachReviews(f.reviews)(anaCoach), isEmpty);
    });
  });

  group('CreateReview', () {
    test('un estudiante con conversación puede reseñar', () async {
      f.chat.openConversation(laura, anaCoach);

      final review = await CreateReview(f.reviews)(
        studentId: laura,
        coachId: anaCoach,
        rating: 4,
        comment: '  Muy buena clase  ',
      );

      expect(review.rating, 4);
      expect(review.comment, 'Muy buena clase');
      expect(review.studentName, 'Laura Camacho');
      expect(await GetCoachReviews(f.reviews)(anaCoach), hasLength(1));
    });

    test('un comentario en blanco se guarda como null', () async {
      f.chat.openConversation(laura, anaCoach);
      final review = await CreateReview(f.reviews)(
        studentId: laura,
        coachId: anaCoach,
        rating: 5,
        comment: '   ',
      );
      expect(review.comment, isNull);
    });

    test('sin conversación con el coach no se puede reseñar', () {
      expect(
        CreateReview(f.reviews)(studentId: laura, coachId: anaCoach, rating: 5),
        throwsA(isA<StateError>()),
      );
    });

    test('no se puede reseñar dos veces al mismo coach', () {
      // Jorge ya reseñó a Carlos en el seed.
      expect(
        CreateReview(f.reviews)(
          studentId: jorge,
          coachId: carlosCoach,
          rating: 3,
        ),
        throwsA(isA<StateError>()),
      );
    });

    test('la calificación debe estar entre 1 y 5', () {
      final create = CreateReview(f.reviews);
      expect(
        create(studentId: jorge, coachId: carlosCoach, rating: 0),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        create(studentId: jorge, coachId: carlosCoach, rating: 6),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
