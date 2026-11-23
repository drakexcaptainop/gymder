import '../../domain/models/plan.dart';
import '../../domain/repositories/plan_repository.dart';
import '../datasources/mock/mock_catalog_data.dart';

class MockPlanRepository implements PlanRepository {
  @override
  Future<List<Plan>> getCoachPlans(String coachId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final plans = kMockPlans
        .where((p) => p.coachId == coachId && p.isActive)
        .toList();
    plans.sort((a, b) => a.tier.index.compareTo(b.tier.index));
    return plans;
  }
}
