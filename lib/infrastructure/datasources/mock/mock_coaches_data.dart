import '../../../domain/models/coach.dart';

final List<Coach> kMockCoaches = [
  const Coach(
    id: 'coach_1',
    name: 'Carlos Mendoza',
    age: 29,
    bio: 'Especialista en hipertrofia y recomposición corporal. Más de 6 años transformando físicos universitarios sin dietas imposibles.',
    photos: [
      'https://images.unsplash.com/photo-1567013127542-490d757e51fc?w=800',
      'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=800',
    ],
    specialties: ['Hipertrofia', 'Fuerza', 'Nutrición Deportiva'],
    rating: 4.9,
    reviewsCount: 38,
    monthlyPrice: 150.0,
    location: 'Gym Central & Online',
    isAvailable: true,
  ),
  const Coach(
    id: 'coach_2',
    name: 'Valeria Rios',
    age: 26,
    bio: 'Certificada en Calistenia y Yoga funcional. Te enseño a dominar tu propio peso corporal y mejorar tu postura para el estudio.',
    photos: [
      'https://images.unsplash.com/photo-1517838277536-f5f99be501cd?w=800',
      'https://images.unsplash.com/photo-1518611012118-696072aa579a?w=800',
    ],
    specialties: ['Calistenia', 'Flexibilidad', 'Pérdida de Grasa'],
    rating: 4.8,
    reviewsCount: 24,
    monthlyPrice: 120.0,
    location: 'Zona Sur & Parques',
    isAvailable: true,
  ),
  const Coach(
    id: 'coach_3',
    name: 'Mateo Fernández',
    age: 32,
    bio: 'Ex-atleta de Powerlifting. Enfoque científico basado en biomecánica para levantar pesado sin lesionarte la espalda.',
    photos: [
      'https://images.unsplash.com/photo-1583454110551-21f2fa2afe61?w=800',
      'https://images.unsplash.com/photo-1574680096145-d05b474e2155?w=800',
    ],
    specialties: ['Powerlifting', 'Biomecánica', 'Fuerza'],
    rating: 5.0,
    reviewsCount: 52,
    monthlyPrice: 180.0,
    location: 'Iron Gym & Asesoría Online',
    isAvailable: true,
  ),
];