import '../models/coach.dart';

abstract class CoachRepository{
    Future<List<Coach>> getDiscoveryCoaches();

    Future<Coach?>getCoachById(String id);

    Future<List<Coach>>getCoachBySpeciality(String speciality);
}