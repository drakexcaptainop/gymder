/// Favorito. En la migración la llave es compuesta (profile_id, coach_id),
/// por eso no tiene `id` propio.
class Favorite {
  final String studentId; // favorites.profile_id
  final String coachId;
  final DateTime createdAt;

  const Favorite({
    required this.studentId,
    required this.coachId,
    required this.createdAt,
  });

  Favorite copyWith({String? studentId, String? coachId, DateTime? createdAt}) {
    return Favorite(
      studentId: studentId ?? this.studentId,
      coachId: coachId ?? this.coachId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
