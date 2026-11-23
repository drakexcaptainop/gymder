import 'package:flutter_test/flutter_test.dart';
import 'package:gymder/core/dependencies.dart';
import 'package:gymder/domain/models/plan.dart';
import 'package:gymder/infrastructure/datasources/mock/mock_coaches_data.dart';

void main() {
  group('AppDependencies', () {
    test('es un singleton', () {
      expect(identical(AppDependencies(), AppDependencies()), isTrue);
    });

    test('el estudiante en sesión es el del seed', () {
      expect(AppDependencies().currentStudentId, kMockStudentId);
    });

    test('expone identidades mock para desarrollar ambos roles', () {
      final deps = AppDependencies();
      expect(deps.currentStudentId, isNotEmpty);
      expect(deps.currentCoachId, isNotEmpty);
      expect(deps.currentCoachProfileId, isNotEmpty);
    });

    test(
      'los casos de uso quedan conectados a los mocks (flujo de lectura)',
      () async {
        final deps = AppDependencies();

        final coaches = await deps.getDiscoveryCoaches();
        expect(coaches, isNotEmpty);

        final detail = await deps.getCoachDetail(coaches.first.id);
        expect(detail?.id, coaches.first.id);

        final plans = await deps.getCoachPlans(coaches.first.id);
        expect(plans.map((p) => p.tier), [
          PlanTier.start,
          PlanTier.plus,
          PlanTier.pro,
        ]);

        final favorites = await deps.getFavoriteCoaches(deps.currentStudentId);
        expect(favorites, isNotEmpty);

        final conversations = await deps.getConversations(
          deps.currentStudentId,
        );
        expect(conversations, isNotEmpty);
        final messages = await deps.getChatMessages(conversations.first.id);
        expect(messages, isNotEmpty);

        expect(
          await deps.getUnreadNotificationCount(deps.currentStudentId),
          greaterThan(0),
        );
        expect(
          await deps.getMyContactRequests(deps.currentStudentId),
          isNotEmpty,
        );

        final coachRequests = await deps.getCoachContactRequests(
          deps.currentCoachId,
        );
        expect(coachRequests, isNotEmpty);
        final coachChats = await deps.getConversationSummaries(
          deps.currentCoachProfileId,
        );
        expect(coachChats, isNotEmpty);
      },
    );

    test(
      'CreateReview respeta la regla de una reseña por estudiante y coach',
      () async {
        final deps = AppDependencies();
        // Jorge ya reseñó a Carlos (seed): el caso de uso debe rechazarlo.
        expect(
          deps.createReview(
            studentId: deps.currentStudentId,
            coachId: '20000000-0000-4000-8000-000000000001',
            rating: 4,
          ),
          throwsA(isA<StateError>()),
        );
      },
    );
  });
}
