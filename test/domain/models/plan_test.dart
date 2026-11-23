import 'package:flutter_test/flutter_test.dart';
import 'package:gymder/domain/models/plan.dart';

void main() {
  group('Plan', () {
    const plan = Plan(
      id: 'p1',
      coachId: 'c1',
      tier: PlanTier.start,
      title: 'Start',
      price: 250,
      currencyCode: 'BOB',
    );

    test('está activo por defecto y la descripción es opcional', () {
      expect(plan.isActive, isTrue);
      expect(plan.description, isNull);
    });

    test('los niveles están en orden start, plus, pro', () {
      expect(PlanTier.values, [PlanTier.start, PlanTier.plus, PlanTier.pro]);
    });

    test('copyWith cambia solo lo indicado y conserva id y coach', () {
      final upgraded = plan.copyWith(tier: PlanTier.pro, price: 600);

      expect(upgraded.tier, PlanTier.pro);
      expect(upgraded.price, 600);
      expect(upgraded.id, 'p1');
      expect(upgraded.coachId, 'c1');
      expect(upgraded.title, 'Start');
      expect(upgraded.currencyCode, 'BOB');
    });

    test('copyWith puede desactivar el plan', () {
      expect(plan.copyWith(isActive: false).isActive, isFalse);
    });
  });
}
