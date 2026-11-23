import '../../domain/models/coach.dart';
import '../../domain/repositories/coach_repository.dart';

/// Caso de uso: Obtener coaches para swipear en la pantalla principal estilo Tinder
class GetDiscoveryCoaches {
  final CoachRepository _repository;

  const GetDiscoveryCoaches(this._repository);

  Future<List<Coach>> call() async {
    return await _repository.getDiscoveryCoaches();
  }
}

/// Caso de uso: Obtener el detalle completo de un coach seleccionado
class GetCoachDetail {
  final CoachRepository _repository;

  const GetCoachDetail(this._repository);

  Future<Coach?> call(String coachId) async {
    return await _repository.getCoachById(coachId);
  }
}
