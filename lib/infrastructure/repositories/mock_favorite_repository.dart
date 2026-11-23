import '../../domain/models/coach.dart';
import '../../domain/models/favorite.dart';
import '../../domain/repositories/favorite_repository.dart';
import '../datasources/mock/mock_coaches_data.dart';

class MockFavoriteRepository implements FavoriteRepository {
  final List<Favorite> _favorites = [];

  @override
  Future<void> addFavorite({
    required String studentId,
    required String coachId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final alreadyExists = _favorites.any(
      (f) => f.studentId == studentId && f.coachId == coachId,
    );

    if (!alreadyExists) {
      _favorites.add(
        Favorite(
          id: 'fav_${DateTime.now().millisecondsSinceEpoch}',
          studentId: studentId,
          coachId: coachId,
          createdAt: DateTime.now(),
        ),
      );
    }
  }

  @override
  Future<void> removeFavorite({
    required String studentId,
    required String coachId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _favorites.removeWhere(
      (f) => f.studentId == studentId && f.coachId == coachId,
    );
  }

  @override
  Future<bool> isFavorite({
    required String studentId,
    required String coachId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _favorites.any(
      (f) => f.studentId == studentId && f.coachId == coachId,
    );
  }

  @override
  Future<List<Coach>> getFavoriteCoaches(String studentId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final coachIds = _favorites
        .where((f) => f.studentId == studentId)
        .map((f) => f.coachId)
        .toSet();

    return kMockCoaches.where((c) => coachIds.contains(c.id)).toList();
  }
}
