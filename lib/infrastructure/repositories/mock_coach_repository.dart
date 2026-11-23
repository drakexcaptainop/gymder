import '../../domain/models/coach.dart';
import '../../domain/repositories/coach_repository.dart';
import '../datasources/mock/mock_coaches_data.dart';

class MockCoachRepository implements CoachRepository {
  // Simulamos la base de datos en memoria RAM
  final List<Coach> _coaches = List.from(kMockCoaches);

  @override
  Future<List<Coach>> getDiscoveryCoaches() async {
    // Simulamos 400 milisegundos de latencia de red
    await Future.delayed(const Duration(milliseconds: 400));
    return List.unmodifiable(_coaches);
  }

  @override
  Future<Coach?> getCoachById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _coaches.firstWhere((coach) => coach.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Coach>> getCoachBySpeciality(String speciality) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _coaches
        .where((coach) => coach.specialties
            .any((s) => s.toLowerCase() == speciality.toLowerCase()))
        .toList();
  }
}