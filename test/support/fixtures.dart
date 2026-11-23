import 'package:gymder/infrastructure/repositories/mock_ad_repository.dart';
import 'package:gymder/infrastructure/repositories/mock_chat_repository.dart';
import 'package:gymder/infrastructure/repositories/mock_coach_repository.dart';
import 'package:gymder/infrastructure/repositories/mock_contact_request_repository.dart';
import 'package:gymder/infrastructure/repositories/mock_favorite_repository.dart';
import 'package:gymder/infrastructure/repositories/mock_notification_repository.dart';
import 'package:gymder/infrastructure/repositories/mock_plan_repository.dart';
import 'package:gymder/infrastructure/repositories/mock_review_repository.dart';

// Ids del seed (seed/seed.sql), compartidos por todos los tests.
const jorge = '10000000-0000-4000-8000-000000000005'; // estudiante con datos
const laura =
    '10000000-0000-4000-8000-000000000006'; // estudiante sin conversaciones
const mateo = '10000000-0000-4000-8000-000000000007';

const carlosCoach = '20000000-0000-4000-8000-000000000001';
const anaCoach = '20000000-0000-4000-8000-000000000002';
const diegoCoach = '20000000-0000-4000-8000-000000000003'; // inactivo

const carlosProfile = '10000000-0000-4000-8000-000000000002';
const anaProfile = '10000000-0000-4000-8000-000000000003';

const convJorgeCarlos = '60000000-0000-4000-8000-000000000001';

/// Un juego de mocks nuevo (estado limpio) por test, conectados entre sí
/// igual que en AppDependencies.
class Fixture {
  final MockChatRepository chat = MockChatRepository();
  final MockNotificationRepository notifications = MockNotificationRepository();
  late final MockReviewRepository reviews = MockReviewRepository(
    chat,
    notifications,
  );
  late final MockCoachRepository coaches = MockCoachRepository(reviews);
  late final MockFavoriteRepository favorites = MockFavoriteRepository(reviews);
  final MockPlanRepository plans = MockPlanRepository();
  final MockAdRepository ads = MockAdRepository();
  late final MockContactRequestRepository contacts;

  Fixture() {
    contacts = MockContactRequestRepository(chat, notifications);
  }
}
