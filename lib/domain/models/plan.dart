/// Nivel del plan (plans.tier). Cada coach tiene como máximo uno por nivel.
enum PlanTier { start, plus, pro }

/// Plan de entrenamiento de un coach (tabla plans).
class Plan {
  final String id;
  final String coachId;
  final PlanTier tier;
  final String title;
  final String? description;
  final double price;
  final String currencyCode; // 'BOB', 'USD'...
  final bool isActive; // plans.status == 'active'

  const Plan({
    required this.id,
    required this.coachId,
    required this.tier,
    required this.title,
    this.description,
    required this.price,
    required this.currencyCode,
    this.isActive = true,
  });

  Plan copyWith({
    PlanTier? tier,
    String? title,
    String? description,
    double? price,
    String? currencyCode,
    bool? isActive,
  }) {
    return Plan(
      id: id,
      coachId: coachId,
      tier: tier ?? this.tier,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      currencyCode: currencyCode ?? this.currencyCode,
      isActive: isActive ?? this.isActive,
    );
  }
}
