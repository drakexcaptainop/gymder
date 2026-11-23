import '../../domain/models/coach.dart';
import '../../domain/repositories/coach_repository.dart';
import '../datasources/mock/mock_coaches_data.dart';
import 'mock_review_repository.dart';

class MockCoachRepository implements CoachRepository {
  final MockReviewRepository _reviews;
  final List<Coach> _coaches = List.of(kMockCoaches);

  MockCoachRepository(this._reviews);

  // rating y reviewsCount se derivan de las reseñas (como la vista coach_stats).
  Coach _withStats(Coach coach) {
    final stats = _reviews.statsFor(coach.id);
    return coach.copyWith(rating: stats.rating, reviewsCount: stats.count);
  }

  @override
  Future<List<Coach>> getDiscoveryCoaches() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _coaches.where((c) => c.isAvailable).map(_withStats).toList();
  }

  @override
  Future<Coach?> getCoachById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    for (final coach in _coaches) {
      if (coach.id == id) return _withStats(coach);
    }
    return null;
  }

  @override
  Future<List<Coach>> getCoachesBySpecialty(String specialty) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final query = specialty.toLowerCase();
    return _coaches
        .where(
          (c) =>
              c.isAvailable &&
              (c.specialty ?? '').toLowerCase().contains(query),
        )
        .map(_withStats)
        .toList();
  }
}
