import '../../../domain/models/chat_message.dart';
import '../../../domain/models/coach.dart';
import '../../../domain/models/contact_request.dart';
import '../../../domain/models/conversation.dart';
import '../../../domain/models/favorite.dart';

// Datos alineados con seed/seed.sql (mismos ids y valores).

const String kMockStudentId =
    '10000000-0000-4000-8000-000000000005'; // Jorge Barahona

const kMockCoaches = <Coach>[
  Coach(
    id: '20000000-0000-4000-8000-000000000001',
    profileId: '10000000-0000-4000-8000-000000000002',
    name: 'Carlos Mendoza',
    specialty: 'Fuerza e hipertrofia',
    bio:
        'Entrenador personal con 8 años de experiencia en fuerza y ganancia muscular.',
    city: 'La Paz',
    modality: CoachModality.inPerson,
    startingPrice: 150.0,
    currencyCode: 'BOB',
    trialClassAvailable: true,
    trialClassPrice: 50.0,
    isVerified: true,
    isAvailable: true,
    photos: [
      'https://images.unsplash.com/photo-1567013127542-490d757e51fc?w=800',
      'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=800',
    ],
    rating: 5.0,
    reviewsCount: 1,
  ),
  Coach(
    id: '20000000-0000-4000-8000-000000000002',
    profileId: '10000000-0000-4000-8000-000000000003',
    name: 'Ana Rojas',
    specialty: 'Yoga y movilidad',
    bio:
        'Instructora de yoga y movilidad. Sesiones en línea para todos los niveles.',
    city: 'Cochabamba',
    modality: CoachModality.online,
    startingPrice: 120.0,
    currencyCode: 'BOB',
    trialClassAvailable: true,
    trialClassPrice: 40.0,
    isVerified: true,
    isAvailable: true,
    photos: [
      'https://images.unsplash.com/photo-1518611012118-696072aa579a?w=800',
    ],
  ),
  // Inactivo y sin verificar: NO debe aparecer en discovery.
  Coach(
    id: '20000000-0000-4000-8000-000000000003',
    profileId: '10000000-0000-4000-8000-000000000004',
    name: 'Diego Vargas',
    specialty: 'Funcional y CrossFit',
    bio: 'Entrenamiento funcional, presencial y en línea.',
    city: 'Santa Cruz',
    modality: CoachModality.hybrid,
    startingPrice: 180.0,
    currencyCode: 'BOB',
    isVerified: false,
    isAvailable: false,
  ),
];

final List<Favorite> kMockFavorites = [
  Favorite(
    studentId: kMockStudentId,
    coachId: '20000000-0000-4000-8000-000000000001',
    createdAt: DateTime.utc(2026, 11, 1, 10, 0),
  ),
  Favorite(
    studentId: kMockStudentId,
    coachId: '20000000-0000-4000-8000-000000000002',
    createdAt: DateTime.utc(2026, 11, 1, 10, 5),
  ),
  Favorite(
    studentId: '10000000-0000-4000-8000-000000000006',
    coachId: '20000000-0000-4000-8000-000000000002',
    createdAt: DateTime.utc(2026, 11, 2, 9),
  ),
];

final List<ContactRequest> kMockContactRequests = [
  ContactRequest(
    id: '50000000-0000-4000-8000-000000000001',
    studentId: kMockStudentId,
    coachId: '20000000-0000-4000-8000-000000000001',
    studentName: 'Jorge Barahona',
    studentAvatarPath: 'avatars/jorge-barahona.jpg',
    coachName: 'Carlos Mendoza',
    coachAvatarPath: 'avatars/carlos-mendoza.jpg',
    message:
        'Hola, quiero empezar a entrenar fuerza. ¿Tienes disponibilidad por las tardes?',
    status: ContactRequestStatus.accepted,
    createdAt: DateTime.utc(2026, 11, 3, 14, 0),
    resolvedAt: DateTime.utc(2026, 11, 3, 16, 0),
  ),
  ContactRequest(
    id: '50000000-0000-4000-8000-000000000002',
    studentId: '10000000-0000-4000-8000-000000000006',
    coachId: '20000000-0000-4000-8000-000000000002',
    studentName: 'Laura Camacho',
    coachName: 'Ana Rojas',
    coachAvatarPath: 'avatars/ana-rojas.jpg',
    message: 'Me interesa el yoga en línea para principiantes.',
    createdAt: DateTime.utc(2026, 11, 18, 9, 30),
  ),
  ContactRequest(
    id: '50000000-0000-4000-8000-000000000003',
    studentId: '10000000-0000-4000-8000-000000000007',
    coachId: '20000000-0000-4000-8000-000000000001',
    studentName: 'Mateo Quispe',
    coachName: 'Carlos Mendoza',
    coachAvatarPath: 'avatars/carlos-mendoza.jpg',
    message: '¿Haces planes para ganar masa muscular?',
    status: ContactRequestStatus.declined,
    createdAt: DateTime.utc(2026, 11, 5, 11),
    resolvedAt: DateTime.utc(2026, 11, 5, 18),
  ),
];

final List<Conversation> kMockConversations = [
  Conversation(
    id: '60000000-0000-4000-8000-000000000001',
    studentId: kMockStudentId,
    coachId: '20000000-0000-4000-8000-000000000001',
    createdAt: DateTime.utc(2026, 11, 3, 16, 0),
  ),
];

final List<ChatMessage> kMockMessages = [
  ChatMessage(
    id: '70000000-0000-4000-8000-000000000001',
    conversationId: '60000000-0000-4000-8000-000000000001',
    senderId: '10000000-0000-4000-8000-000000000002', // Carlos
    text: 'Hola Jorge, claro. Tengo cupo martes y jueves a las 18:00.',
    sentAt: DateTime.utc(2026, 11, 3, 16, 5),
    readAt: DateTime.utc(2026, 11, 3, 16, 20),
  ),
  ChatMessage(
    id: '70000000-0000-4000-8000-000000000002',
    conversationId: '60000000-0000-4000-8000-000000000001',
    senderId: kMockStudentId,
    text: 'Perfecto, reservo una clase de prueba el martes.',
    sentAt: DateTime.utc(2026, 11, 3, 16, 22),
    readAt: DateTime.utc(2026, 11, 3, 16, 30),
  ),
  ChatMessage(
    id: '70000000-0000-4000-8000-000000000003',
    conversationId: '60000000-0000-4000-8000-000000000001',
    senderId: '10000000-0000-4000-8000-000000000002', // Carlos
    text: '¡Genial! Trae ropa cómoda y una botella de agua.',
    sentAt: DateTime.utc(2026, 11, 3, 16, 31),
  ),
];
