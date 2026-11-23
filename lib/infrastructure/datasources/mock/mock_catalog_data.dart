import '../../../domain/models/ad.dart';
import '../../../domain/models/app_notification.dart';
import '../../../domain/models/plan.dart';
import '../../../domain/models/review.dart';

// Datos alineados con seed/seed.sql (planes, reseñas, avisos y anuncios).

const Map<String, String> kMockProfileNames = {
  '10000000-0000-4000-8000-000000000002': 'Carlos Mendoza',
  '10000000-0000-4000-8000-000000000003': 'Ana Rojas',
  '10000000-0000-4000-8000-000000000004': 'Diego Vargas',
  '10000000-0000-4000-8000-000000000005': 'Jorge Barahona',
  '10000000-0000-4000-8000-000000000006': 'Laura Camacho',
  '10000000-0000-4000-8000-000000000007': 'Mateo Quispe',
};

const Map<String, String> kMockProfileAvatars = {
  '10000000-0000-4000-8000-000000000002': 'avatars/carlos-mendoza.jpg',
  '10000000-0000-4000-8000-000000000003': 'avatars/ana-rojas.jpg',
  '10000000-0000-4000-8000-000000000005': 'avatars/jorge-barahona.jpg',
};

const kMockPlans = <Plan>[
  // Carlos
  Plan(
    id: '30000000-0000-4000-8000-000000000001',
    coachId: '20000000-0000-4000-8000-000000000001',
    tier: PlanTier.start,
    title: 'Start',
    description: '4 sesiones al mes con rutina base.',
    price: 250,
    currencyCode: 'BOB',
  ),
  Plan(
    id: '30000000-0000-4000-8000-000000000002',
    coachId: '20000000-0000-4000-8000-000000000001',
    tier: PlanTier.plus,
    title: 'Plus',
    description: '8 sesiones al mes con rutina personalizada y seguimiento.',
    price: 450,
    currencyCode: 'BOB',
  ),
  Plan(
    id: '30000000-0000-4000-8000-000000000003',
    coachId: '20000000-0000-4000-8000-000000000001',
    tier: PlanTier.pro,
    title: 'Pro',
    description:
        '12 sesiones al mes, rutina personalizada y plan de nutrición.',
    price: 600,
    currencyCode: 'BOB',
  ),
  // Ana
  Plan(
    id: '30000000-0000-4000-8000-000000000004',
    coachId: '20000000-0000-4000-8000-000000000002',
    tier: PlanTier.start,
    title: 'Start',
    description: '4 clases de yoga en vivo por videollamada.',
    price: 120,
    currencyCode: 'BOB',
  ),
  Plan(
    id: '30000000-0000-4000-8000-000000000005',
    coachId: '20000000-0000-4000-8000-000000000002',
    tier: PlanTier.plus,
    title: 'Plus',
    description: '8 clases en vivo y rutina de movilidad.',
    price: 220,
    currencyCode: 'BOB',
  ),
  Plan(
    id: '30000000-0000-4000-8000-000000000006',
    coachId: '20000000-0000-4000-8000-000000000002',
    tier: PlanTier.pro,
    title: 'Pro',
    description: '12 clases en vivo, movilidad y seguimiento semanal.',
    price: 300,
    currencyCode: 'BOB',
  ),
  // Diego (inactivo)
  Plan(
    id: '30000000-0000-4000-8000-000000000007',
    coachId: '20000000-0000-4000-8000-000000000003',
    tier: PlanTier.start,
    title: 'Start',
    description: 'Entrenamiento funcional mensual.',
    price: 180,
    currencyCode: 'BOB',
    isActive: false,
  ),
  Plan(
    id: '30000000-0000-4000-8000-000000000008',
    coachId: '20000000-0000-4000-8000-000000000003',
    tier: PlanTier.pro,
    title: 'Pro',
    description: 'Plan funcional trimestral.',
    price: 1500,
    currencyCode: 'BOB',
    isActive: false,
  ),
];

final List<Review> kMockReviews = [
  Review(
    id: '90000000-0000-4000-8000-000000000001',
    coachId: '20000000-0000-4000-8000-000000000001',
    studentId: '10000000-0000-4000-8000-000000000005',
    studentName: 'Jorge Barahona',
    rating: 5,
    comment: 'Excelente atención y rutina clara desde la primera clase.',
    createdAt: DateTime.utc(2026, 11, 11, 8, 0),
  ),
];

final List<AppNotification> kMockNotifications = [
  // Para el estudiante Jorge: su solicitud fue aceptada.
  AppNotification(
    id: 'notif_1',
    recipientId: '10000000-0000-4000-8000-000000000005',
    type: NotificationType.contactRequestResolved,
    contactRequestId: '50000000-0000-4000-8000-000000000001',
    createdAt: DateTime.utc(2026, 11, 3, 16, 0),
  ),
  // Para el coach Carlos (perfil ...02): solicitud recibida (ya leída) y reseña nueva.
  AppNotification(
    id: 'notif_2',
    recipientId: '10000000-0000-4000-8000-000000000002',
    type: NotificationType.contactRequestCreated,
    contactRequestId: '50000000-0000-4000-8000-000000000001',
    createdAt: DateTime.utc(2026, 11, 3, 14, 0),
    readAt: DateTime.utc(2026, 11, 3, 14, 30),
  ),
  AppNotification(
    id: 'notif_3',
    recipientId: '10000000-0000-4000-8000-000000000002',
    type: NotificationType.reviewCreated,
    reviewId: '90000000-0000-4000-8000-000000000001',
    createdAt: DateTime.utc(2026, 11, 11, 8, 0),
  ),
  AppNotification(
    id: 'notif_4',
    recipientId: '10000000-0000-4000-8000-000000000003',
    type: NotificationType.contactRequestCreated,
    contactRequestId: '50000000-0000-4000-8000-000000000002',
    createdAt: DateTime.utc(2026, 11, 18, 9, 30),
  ),
  AppNotification(
    id: 'notif_5',
    recipientId: '10000000-0000-4000-8000-000000000002',
    type: NotificationType.contactRequestCreated,
    contactRequestId: '50000000-0000-4000-8000-000000000003',
    createdAt: DateTime.utc(2026, 11, 5, 11),
  ),
  AppNotification(
    id: 'notif_6',
    recipientId: '10000000-0000-4000-8000-000000000007',
    type: NotificationType.contactRequestResolved,
    contactRequestId: '50000000-0000-4000-8000-000000000003',
    createdAt: DateTime.utc(2026, 11, 5, 18),
  ),
];

final List<Ad> kMockAds = [
  Ad(
    id: 'a0000000-0000-4000-8000-000000000001',
    advertiserName: 'ProteinMax',
    title: '20% de descuento en proteína',
    imageUrl: 'https://example.com/ads/proteinmax.jpg',
    destinationUrl: 'https://example.com/proteinmax',
    isActive: true,
    startsAt: DateTime.utc(2026, 11, 1),
    endsAt: DateTime.utc(2026, 12, 31, 23, 59, 59),
  ),
  // Inactivo: no debe mostrarse.
  const Ad(
    id: 'a0000000-0000-4000-8000-000000000002',
    advertiserName: 'FitWear',
    title: 'Ropa deportiva de temporada',
    destinationUrl: 'https://example.com/fitwear',
    isActive: false,
  ),
];

final List<AdEvent> kMockAdEvents = [
  AdEvent(
    id: 'b0000000-0000-4000-8000-000000000001',
    adId: 'a0000000-0000-4000-8000-000000000001',
    profileId: '10000000-0000-4000-8000-000000000005',
    type: AdEventType.impression,
    createdAt: DateTime.utc(2026, 11, 15, 10),
  ),
  AdEvent(
    id: 'b0000000-0000-4000-8000-000000000002',
    adId: 'a0000000-0000-4000-8000-000000000001',
    profileId: '10000000-0000-4000-8000-000000000005',
    type: AdEventType.click,
    createdAt: DateTime.utc(2026, 11, 15, 10, 0, 7),
  ),
  AdEvent(
    id: 'b0000000-0000-4000-8000-000000000003',
    adId: 'a0000000-0000-4000-8000-000000000001',
    type: AdEventType.impression,
    createdAt: DateTime.utc(2026, 11, 16, 9),
  ),
];
