import '../application/chat/chat_use_cases.dart';
import '../application/coach/coach_use_cases.dart';
import '../application/favorites/favorite_use_cases.dart';
import '../domain/repositories/chat_repository.dart';
import '../domain/repositories/coach_repository.dart';
import '../domain/repositories/favorite_repository.dart';
import '../infrastructure/repositories/mock_chat_repository.dart';
import '../infrastructure/repositories/mock_coach_repository.dart';
import '../infrastructure/repositories/mock_favorite_repository.dart';

/// Contenedor de Inyección de Dependencias (Service Locator / Composition Root)
///
/// Centraliza la instanciación de adaptadores y casos de uso.
/// Cuando el backend real esté listo, solo se reemplazan los MockRepository
/// por los repositorios reales (ej: Firebase o REST API) en este único archivo.
class AppDependencies {
  // Patrón Singleton para mantener una única instancia del contenedor en memoria
  static final AppDependencies _instance = AppDependencies._internal();
  factory AppDependencies() => _instance;

  // Repositorios (Adaptadores de Infraestructura)
  late final CoachRepository coachRepository;
  late final FavoriteRepository favoriteRepository;
  late final ChatRepository chatRepository;

  // Casos de Uso (Capa de Aplicación)
  late final GetDiscoveryCoaches getDiscoveryCoaches;
  late final GetCoachDetail getCoachDetail;

  late final ToggleFavorite toggleFavorite;
  late final GetFavoriteCoaches getFavoriteCoaches;

  late final SendChatMessage sendChatMessage;
  late final WatchChatMessages watchChatMessages;

  // ID del estudiante actual en sesión (simulado)
  final String currentStudentId = 'student_me';

  AppDependencies._internal() {
    // 1. Instanciamos la infraestructura (Mock o Real)
    coachRepository = MockCoachRepository();
    favoriteRepository = MockFavoriteRepository();
    chatRepository = MockChatRepository();

    // 2. Inyectamos los repositorios dentro de cada caso de uso
    getDiscoveryCoaches = GetDiscoveryCoaches(coachRepository);
    getCoachDetail = GetCoachDetail(coachRepository);

    toggleFavorite = ToggleFavorite(favoriteRepository);
    getFavoriteCoaches = GetFavoriteCoaches(favoriteRepository);

    sendChatMessage = SendChatMessage(chatRepository);
    watchChatMessages = WatchChatMessages(chatRepository);
  }
}
