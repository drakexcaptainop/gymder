/// Reseña de un estudiante a un coach (tabla reviews). Una por (estudiante, coach).
class Review {
  final String id;
  final String coachId;
  final String studentId;
  final String studentName; // profiles.full_name del autor (para mostrarlo)
  final int rating; // 1..5
  final String? comment;
  final DateTime createdAt;

  const Review({
    required this.id,
    required this.coachId,
    required this.studentId,
    required this.studentName,
    required this.rating,
    this.comment,
    required this.createdAt,
  });
}
