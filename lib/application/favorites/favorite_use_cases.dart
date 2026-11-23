import '../../domain/models/coach.dart';
import '../../domain/repositories/favorite_repository.dart';

/// Caso de uso: Dar Like / Guardar en Favoritos
class ToggleFavorite {
  final FavoriteRepository _repository;

  const ToggleFavorite(this._repository);

  Future<bool> call({
    required String studentId,
    required String coachId,
  }) async {
    final isAlreadyFavorite = await _repository.isFavorite(
      studentId: studentId,
      coachId: coachId,
    );

    if (isAlreadyFavorite) {
      await _repository.removeFavorite(studentId: studentId, coachId: coachId);
      return false; // Ya no es favorito
    } else {
      await _repository.addFavorite(studentId: studentId, coachId: coachId);
      return true; // Ahora es favorito
    }
  }
}

/// Caso de uso: Listar todos los coaches guardados en favoritos
class GetFavoriteCoaches {
  final FavoriteRepository _repository;

  const GetFavoriteCoaches(this._repository);

  Future<List<Coach>> call(String studentId) async {
    return await _repository.getFavoriteCoaches(studentId);
  }
}
