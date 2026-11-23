import '../../domain/models/review.dart';
import '../../domain/models/app_notification.dart';
import '../../domain/repositories/review_repository.dart';
import '../datasources/mock/mock_catalog_data.dart';
import '../datasources/mock/mock_coaches_data.dart';
import 'mock_chat_repository.dart';
import 'mock_notification_repository.dart';

class MockReviewRepository implements ReviewRepository {
  final MockChatRepository _chat;
  final MockNotificationRepository _notifications;
  final List<Review> _reviews = List.of(kMockReviews);

  MockReviewRepository(this._chat, this._notifications);

  /// Rating y cantidad derivados (equivale a la vista coach_stats).
  ({double rating, int count}) statsFor(String coachId) {
    final list = _reviews.where((r) => r.coachId == coachId).toList();
    if (list.isEmpty) return (rating: 0.0, count: 0);
    final sum = list.fold<int>(0, (acc, r) => acc + r.rating);
    final avg = (sum / list.length * 10).round() / 10;
    return (rating: avg, count: list.length);
  }

  @override
  Future<List<Review>> getCoachReviews(String coachId) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final list = _reviews.where((r) => r.coachId == coachId).toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  @override
  Future<Review> createReview({
    required String studentId,
    required String coachId,
    required int rating,
    String? comment,
  }) async {
    await Future.delayed(const Duration(milliseconds: 250));

    if (rating < 1 || rating > 5) {
      throw ArgumentError('La calificación debe estar entre 1 y 5');
    }

    // Regla de la base: solo reseña quien tiene conversación con el coach.
    final conversations = await _chat.getConversations(studentId);
    if (!conversations.any((c) => c.coachId == coachId)) {
      throw StateError(
        'Solo puedes reseñar a un coach con el que tengas una conversación',
      );
    }
    if (_reviews.any((r) => r.studentId == studentId && r.coachId == coachId)) {
      throw StateError('Ya reseñaste a este coach');
    }

    final trimmed = comment?.trim();
    final review = Review(
      id: 'review_${DateTime.now().microsecondsSinceEpoch}',
      coachId: coachId,
      studentId: studentId,
      studentName: kMockProfileNames[studentId] ?? 'Estudiante',
      rating: rating,
      comment: (trimmed == null || trimmed.isEmpty) ? null : trimmed,
      createdAt: DateTime.now().toUtc(),
    );
    _reviews.add(review);

    // Trigger reviews_notify_created: avisa al coach.
    for (final coach in kMockCoaches) {
      if (coach.id == coachId) {
        _notifications.add(
          recipientId: coach.profileId,
          type: NotificationType.reviewCreated,
          reviewId: review.id,
        );
      }
    }
    return review;
  }
}
