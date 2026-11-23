import '../models/coach.dart';

abstract class FavoriteRepository {
  Future<void> addFavorite({
    required String studentId,
    required String coachId,
  });

  Future<void> removeFavorite({
    required String studentId,
    required String coachId,
  });

  Future<bool> isFavorite({required String studentId, required String coachId});

  /// Más reciente primero.
  Future<List<Coach>> getFavoriteCoaches(String studentId);
}
