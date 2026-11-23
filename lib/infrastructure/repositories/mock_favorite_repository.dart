import '../../domain/models/coach.dart';
import '../../domain/models/favorite.dart';
import '../../domain/repositories/favorite_repository.dart';
import '../datasources/mock/mock_coaches_data.dart';
import 'mock_review_repository.dart';

class MockFavoriteRepository implements FavoriteRepository {
  final MockReviewRepository _reviews;
  final List<Favorite> _favorites = List.of(kMockFavorites);

  MockFavoriteRepository(this._reviews);

  @override
  Future<void> addFavorite({
    required String studentId,
    required String coachId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (!kMockCoaches.any((coach) => coach.id == coachId)) {
      throw StateError('Coach no encontrado');
    }
    final exists = _favorites.any(
      (f) => f.studentId == studentId && f.coachId == coachId,
    );
    if (!exists) {
      _favorites.add(
        Favorite(
          studentId: studentId,
          coachId: coachId,
          createdAt: DateTime.now().toUtc(),
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
    final mine = _favorites.where((f) => f.studentId == studentId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final result = <Coach>[];
    for (final fav in mine) {
      for (final coach in kMockCoaches) {
        if (coach.id == fav.coachId) {
          final stats = _reviews.statsFor(coach.id);
          result.add(
            coach.copyWith(rating: stats.rating, reviewsCount: stats.count),
          );
        }
      }
    }
    return result;
  }
}
