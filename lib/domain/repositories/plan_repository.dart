import '../models/plan.dart';

abstract class PlanRepository {
  /// Planes activos del coach, ordenados start, plus, pro.
  Future<List<Plan>> getCoachPlans(String coachId);
}
