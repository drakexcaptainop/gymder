import '../application/ads/ad_use_cases.dart';
import '../application/chat/chat_use_cases.dart';
import '../application/coach/coach_use_cases.dart';
import '../application/contact/contact_use_cases.dart';
import '../application/favorites/favorite_use_cases.dart';
import '../application/notifications/notification_use_cases.dart';
import '../application/plans/plan_use_cases.dart';
import '../application/reviews/review_use_cases.dart';
import '../domain/repositories/ad_repository.dart';
import '../domain/repositories/chat_repository.dart';
import '../domain/repositories/coach_repository.dart';
import '../domain/repositories/contact_request_repository.dart';
import '../domain/repositories/favorite_repository.dart';
import '../domain/repositories/notification_repository.dart';
import '../domain/repositories/plan_repository.dart';
import '../domain/repositories/review_repository.dart';
import '../infrastructure/datasources/mock/mock_coaches_data.dart';
import '../infrastructure/repositories/mock_ad_repository.dart';
import '../infrastructure/repositories/mock_chat_repository.dart';
import '../infrastructure/repositories/mock_coach_repository.dart';
import '../infrastructure/repositories/mock_contact_request_repository.dart';
import '../infrastructure/repositories/mock_favorite_repository.dart';
import '../infrastructure/repositories/mock_notification_repository.dart';
import '../infrastructure/repositories/mock_plan_repository.dart';
import '../infrastructure/repositories/mock_review_repository.dart';

/// Composition root: el ÚNICO lugar que decide Mock o real.
class AppDependencies {
  static final AppDependencies _instance = AppDependencies._internal();
  factory AppDependencies() => _instance;

  // Repositorios (puertos)
  late final CoachRepository coachRepository;
  late final FavoriteRepository favoriteRepository;
  late final ChatRepository chatRepository;
  late final ContactRequestRepository contactRequestRepository;
  late final PlanRepository planRepository;
  late final ReviewRepository reviewRepository;
  late final NotificationRepository notificationRepository;
  late final AdRepository adRepository;

  // Casos de uso
  late final GetDiscoveryCoaches getDiscoveryCoaches;
  late final GetCoachDetail getCoachDetail;
  late final GetCoachesBySpecialty getCoachesBySpecialty;

  late final ToggleFavorite toggleFavorite;
  late final GetFavoriteCoaches getFavoriteCoaches;

  late final RequestContact requestContact;
  late final GetMyContactRequests getMyContactRequests;
  late final GetCoachContactRequests getCoachContactRequests;
  late final ResolveContactRequest resolveContactRequest;
  late final CancelContactRequest cancelContactRequest;

  late final GetConversations getConversations;
  late final GetConversationSummaries getConversationSummaries;
  late final GetChatMessages getChatMessages;
  late final SendChatMessage sendChatMessage;
  late final MarkChatMessagesRead markChatMessagesRead;
  late final WatchChatMessages watchChatMessages;

  late final GetCoachPlans getCoachPlans;

  late final GetCoachReviews getCoachReviews;
  late final CreateReview createReview;

  late final GetNotifications getNotifications;
  late final GetUnreadNotificationCount getUnreadNotificationCount;
  late final MarkNotificationRead markNotificationRead;

  late final GetActiveAds getActiveAds;
  late final TrackAdEvent trackAdEvent;

  // Estudiante en sesión (simulado: Jorge Barahona del seed). Luego vendrá del login.
  final String currentStudentId = kMockStudentId;
  // Coach simulado para desarrollar las pantallas del segundo rol.
  final String currentCoachId = '20000000-0000-4000-8000-000000000001';
  final String currentCoachProfileId = '10000000-0000-4000-8000-000000000002';

  AppDependencies._internal() {
    // Los mocks comparten estado entre sí para imitar los triggers de la base.
    final chat = MockChatRepository();
    final notifications = MockNotificationRepository();
    final reviews = MockReviewRepository(chat, notifications);

    coachRepository = MockCoachRepository(reviews);
    favoriteRepository = MockFavoriteRepository(reviews);
    chatRepository = chat;
    contactRequestRepository = MockContactRequestRepository(
      chat,
      notifications,
    );
    planRepository = MockPlanRepository();
    reviewRepository = reviews;
    notificationRepository = notifications;
    adRepository = MockAdRepository();

    getDiscoveryCoaches = GetDiscoveryCoaches(coachRepository);
    getCoachDetail = GetCoachDetail(coachRepository);
    getCoachesBySpecialty = GetCoachesBySpecialty(coachRepository);

    toggleFavorite = ToggleFavorite(favoriteRepository);
    getFavoriteCoaches = GetFavoriteCoaches(favoriteRepository);

    requestContact = RequestContact(contactRequestRepository);
    getMyContactRequests = GetMyContactRequests(contactRequestRepository);
    getCoachContactRequests = GetCoachContactRequests(contactRequestRepository);
    resolveContactRequest = ResolveContactRequest(contactRequestRepository);
    cancelContactRequest = CancelContactRequest(contactRequestRepository);

    getConversations = GetConversations(chatRepository);
    getConversationSummaries = GetConversationSummaries(chatRepository);
    getChatMessages = GetChatMessages(chatRepository);
    sendChatMessage = SendChatMessage(chatRepository);
    markChatMessagesRead = MarkChatMessagesRead(chatRepository);
    watchChatMessages = WatchChatMessages(chatRepository);

    getCoachPlans = GetCoachPlans(planRepository);

    getCoachReviews = GetCoachReviews(reviewRepository);
    createReview = CreateReview(reviewRepository);

    getNotifications = GetNotifications(notificationRepository);
    getUnreadNotificationCount = GetUnreadNotificationCount(
      notificationRepository,
    );
    markNotificationRead = MarkNotificationRead(notificationRepository);

    getActiveAds = GetActiveAds(adRepository);
    trackAdEvent = TrackAdEvent(adRepository);
  }
}
