import 'package:flutter_test/flutter_test.dart';
import 'package:gymder/domain/models/plan.dart';

import '../../support/fixtures.dart';

void main() {
  late Fixture f;
  setUp(() => f = Fixture());

  group('MockPlanRepository', () {
    test('Carlos y Ana tienen los tres niveles activos', () async {
      for (final coachId in [carlosCoach, anaCoach]) {
        final plans = await f.plans.getCoachPlans(coachId);
        expect(plans.map((p) => p.tier), [
          PlanTier.start,
          PlanTier.plus,
          PlanTier.pro,
        ]);
        expect(plans.every((p) => p.isActive), isTrue);
        expect(plans.every((p) => p.coachId == coachId), isTrue);
      }
    });

    test('los planes inactivos de Diego no se listan', () async {
      expect(await f.plans.getCoachPlans(diegoCoach), isEmpty);
    });
  });
}
