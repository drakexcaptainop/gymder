import '../models/coach.dart';

abstract class CoachRepository {
  /// Coaches activos para la pila de swipe.
  Future<List<Coach>> getDiscoveryCoaches();

  Future<Coach?> getCoachById(String id);

  /// Filtra por coaches.specialty (sin distinguir mayúsculas, coincidencia parcial).
  Future<List<Coach>> getCoachesBySpecialty(String specialty);
}
