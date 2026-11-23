import 'package:flutter_test/flutter_test.dart';
import 'package:gymder/domain/models/app_notification.dart';

import '../../support/fixtures.dart';

void main() {
  late Fixture f;
  setUp(() => f = Fixture());

  group('MockReviewRepository', () {
    test('statsFor sin reseñas es 0 y 0', () {
      final stats = f.reviews.statsFor(diegoCoach);
      expect(stats.rating, 0);
      expect(stats.count, 0);
    });

    test('statsFor promedia con un decimal', () async {
      f.chat.openConversation(laura, anaCoach);
      f.chat.openConversation(mateo, anaCoach);
      await f.reviews.createReview(
        studentId: laura,
        coachId: anaCoach,
        rating: 4,
      );
      await f.reviews.createReview(
        studentId: mateo,
        coachId: anaCoach,
        rating: 5,
      );

      final stats = f.reviews.statsFor(anaCoach);
      expect(stats.rating, 4.5);
      expect(stats.count, 2);
    });

    test('getCoachReviews devuelve la más reciente primero', () async {
      f.chat.openConversation(laura, anaCoach);
      f.chat.openConversation(mateo, anaCoach);
      await f.reviews.createReview(
        studentId: laura,
        coachId: anaCoach,
        rating: 4,
      );
      await Future.delayed(const Duration(milliseconds: 5));
      await f.reviews.createReview(
        studentId: mateo,
        coachId: anaCoach,
        rating: 5,
      );

      final list = await f.reviews.getCoachReviews(anaCoach);
      expect(list.map((r) => r.studentId), [mateo, laura]);
    });

    test(
      'crear una reseña avisa al coach (trigger reviews_notify_created)',
      () async {
        f.chat.openConversation(laura, anaCoach);
        final review = await f.reviews.createReview(
          studentId: laura,
          coachId: anaCoach,
          rating: 5,
        );

        final notices = await f.notifications.getNotifications(anaProfile);
        final notice = notices.firstWhere(
          (item) => item.type == NotificationType.reviewCreated,
        );
        expect(notice.reviewId, review.id);
      },
    );

    test('una reseña rechazada no avisa a nadie', () async {
      await expectLater(
        f.reviews.createReview(studentId: laura, coachId: anaCoach, rating: 5),
        throwsA(isA<StateError>()),
      );
      expect(await f.notifications.getNotifications(anaProfile), hasLength(1));
    });

    test('un estudiante desconocido usa el nombre genérico', () async {
      f.chat.openConversation('estudiante-x', anaCoach);
      final review = await f.reviews.createReview(
        studentId: 'estudiante-x',
        coachId: anaCoach,
        rating: 3,
      );
      expect(review.studentName, 'Estudiante');
    });
  });
}
