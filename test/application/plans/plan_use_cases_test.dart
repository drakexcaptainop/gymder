import 'package:flutter_test/flutter_test.dart';
import 'package:gymder/application/plans/plan_use_cases.dart';
import 'package:gymder/domain/models/plan.dart';

import '../../support/fixtures.dart';

void main() {
  late Fixture f;
  setUp(() => f = Fixture());

  group('GetCoachPlans', () {
    test('devuelve Start, Plus y Pro en ese orden', () async {
      final plans = await GetCoachPlans(f.plans)(carlosCoach);
      expect(plans.map((p) => p.tier), [
        PlanTier.start,
        PlanTier.plus,
        PlanTier.pro,
      ]);
    });

    test('el precio crece con el nivel', () async {
      final plans = await GetCoachPlans(f.plans)(anaCoach);
      expect(plans[0].price, lessThan(plans[1].price));
      expect(plans[1].price, lessThan(plans[2].price));
    });

    test('no incluye planes inactivos', () async {
      expect(await GetCoachPlans(f.plans)(diegoCoach), isEmpty);
    });

    test('un coach desconocido no tiene planes', () async {
      expect(await GetCoachPlans(f.plans)('no-existe'), isEmpty);
    });
  });
}
