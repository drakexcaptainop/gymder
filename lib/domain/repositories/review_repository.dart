import '../models/review.dart';

abstract class ReviewRepository {
  /// Más recientes primero.
  Future<List<Review>> getCoachReviews(String coachId);

  /// Lanza StateError si el estudiante no tiene conversación con el coach
  /// o si ya lo reseñó; ArgumentError si la calificación no está entre 1 y 5.
  Future<Review> createReview({
    required String studentId,
    required String coachId,
    required int rating,
    String? comment,
  });
}
