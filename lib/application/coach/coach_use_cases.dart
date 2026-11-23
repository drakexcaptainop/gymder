import '../../domain/models/coach.dart';
import '../../domain/repositories/coach_repository.dart';

/// Coaches para swipear en la pantalla principal.
class GetDiscoveryCoaches {
  final CoachRepository _repository;

  const GetDiscoveryCoaches(this._repository);

  Future<List<Coach>> call() => _repository.getDiscoveryCoaches();
}

/// Detalle completo de un coach.
class GetCoachDetail {
  final CoachRepository _repository;

  const GetCoachDetail(this._repository);

  Future<Coach?> call(String coachId) => _repository.getCoachById(coachId);
}

/// Filtro por especialidad.
class GetCoachesBySpecialty {
  final CoachRepository _repository;

  const GetCoachesBySpecialty(this._repository);

  Future<List<Coach>> call(String specialty) =>
      _repository.getCoachesBySpecialty(specialty.trim());
}
