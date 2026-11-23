import '../../domain/models/plan.dart';
import '../../domain/repositories/plan_repository.dart';

/// Planes (Start, Plus, Pro) de un coach.
class GetCoachPlans {
  final PlanRepository _repository;

  const GetCoachPlans(this._repository);

  Future<List<Plan>> call(String coachId) => _repository.getCoachPlans(coachId);
}
