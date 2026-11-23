import '../models/coach.dart';
import '../models/favorite.dart';

abstract class FavoriteRepository{
    Future<void> addFavorite({
        required String studentId,
        required String coachId,
    });

    Future<void> removeFavorite({
        required String studentId,
        required String coachId, 
    });

    Future<bool> isFavorite({
        required String studentId,
        required String coachId,
    });

    Future<List<Coach>>getFavoriteCoaches(String studentId);
}