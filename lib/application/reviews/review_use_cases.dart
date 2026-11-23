import '../../domain/models/review.dart';
import '../../domain/repositories/review_repository.dart';

/// Reseñas de un coach.
class GetCoachReviews {
  final ReviewRepository _repository;

  const GetCoachReviews(this._repository);

  Future<List<Review>> call(String coachId) =>
      _repository.getCoachReviews(coachId);
}

/// El estudiante reseña a un coach (1 a 5 estrellas + comentario opcional).
class CreateReview {
  final ReviewRepository _repository;

  const CreateReview(this._repository);

  Future<Review> call({
    required String studentId,
    required String coachId,
    required int rating,
    String? comment,
  }) {
    return _repository.createReview(
      studentId: studentId,
      coachId: coachId,
      rating: rating,
      comment: comment,
    );
  }
}
