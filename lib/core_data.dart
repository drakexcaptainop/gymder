enum AppRole { user, coach }
enum ContactStatus { pending, accepted, rejected }

class Coach {
  final String id, nombre, ini, especialidad, modalidad, lugar, resumen, bio, enfoque, precioOrientativo;
  final int exp;
  final List<String> tags, servicios;

  const Coach({
    required this.id, required this.nombre, required this.ini, required this.especialidad,
    required this.modalidad, required this.exp, required this.lugar, required this.resumen,
    required this.bio, required this.enfoque, required this.tags, required this.servicios,
    required this.precioOrientativo,
  });
}

final coaches = <Coach>[
  Coach(id: 'c1', nombre: 'Valeria Ríos', ini: 'VR', especialidad: 'Fuerza', modalidad: 'Presencial', exp: 8, lugar: 'Gimnasio Central', resumen: 'Fuerza con técnica limpia y progresión medible.', bio: 'Acompaño a personas que empiezan o vuelven a entrenar a ganar fuerza con técnica limpia.', enfoque: 'Sesiones de 60 minutos: calentamiento, bloque principal y movilidad final.', tags: ['Fuerza', 'Técnica', 'Principiantes'], servicios: ['Entrenamiento de fuerza', 'Revisión de técnica', 'Movilidad'], precioOrientativo: '¤ 35-55 por sesión'),
  Coach(id: 'c2', nombre: 'Mateo Salas', ini: 'MS', especialidad: 'Hipertrofia', modalidad: 'Presencial', exp: 6, lugar: 'Gimnasio Norte', resumen: 'Planes de volumen muscular con revisión semanal.', bio: 'Diseño bloques de hipertrofia con cargas y volumen controlados.', enfoque: 'Bloques de 4 semanas con revisión semanal de cargas y técnica.', tags: ['Hipertrofia', 'Pesas', 'Técnica'], servicios: ['Hipertrofia', 'Revisión semanal', 'Asesoría de técnica'], precioOrientativo: '¤ 30-50 por sesión'),
  Coach(id: 'c3', nombre: 'Lucía Andrade', ini: 'LA', especialidad: 'Movilidad', modalidad: 'Online', exp: 10, lugar: 'Sesiones online', resumen: 'Movilidad, postura y control corporal.', bio: 'Trabajo movilidad, postura y control del core para que entrenes y te muevas con más comodidad.', enfoque: 'Sesiones de 45 minutos con progresiones suaves.', tags: ['Movilidad', 'Postura', 'Core'], servicios: ['Movilidad guiada', 'Postura', 'Control del core'], precioOrientativo: '¤ 25-40 por sesión'),
  Coach(id: 'c4', nombre: 'Daniel Okafor', ini: 'DO', especialidad: 'Funcional', modalidad: 'Presencial', exp: 7, lugar: 'Gimnasio Central', resumen: 'Entrenamiento funcional y acondicionamiento.', bio: 'Combino fuerza, resistencia y coordinación en circuitos funcionales.', enfoque: 'Circuitos de intensidad progresiva con descansos programados.', tags: ['Funcional', 'Circuitos', 'Resistencia'], servicios: ['Acondicionamiento', 'Circuitos funcionales', 'Fuerza general'], precioOrientativo: '¤ 30-50 por sesión'),
  Coach(id: 'c5', nombre: 'Sofía Méndez', ini: 'SM', especialidad: 'Running', modalidad: 'Online', exp: 5, lugar: 'Pista local y online', resumen: 'Planes de carrera desde 5K hasta media maratón.', bio: 'Preparo planes de carrera por objetivos con fuerza complementaria.', enfoque: 'Plan semanal con rodajes, series y una sesión de fuerza.', tags: ['Running', 'Resistencia'], servicios: ['Preparación 5K', 'Plan de carrera', 'Fuerza complementaria'], precioOrientativo: '¤ 25-45 por sesión'),
  Coach(id: 'c6', nombre: 'Andrés Lima', ini: 'AL', especialidad: 'Hipertrofia', modalidad: 'Online', exp: 4, lugar: 'Plan online', resumen: 'Ganancia muscular con rutinas claras.', bio: 'Rutinas de hipertrofia con progresiones y revisión de técnica por video.', enfoque: 'Cuatro sesiones por semana con progresión de cargas.', tags: ['Hipertrofia', 'Rutinas en casa'], servicios: ['Plan de hipertrofia', 'Revisión por video', 'Progresión de cargas'], precioOrientativo: '¤ 25-40 por sesión'),
];

const especialidades = ['Fuerza', 'Hipertrofia', 'Movilidad', 'Funcional', 'Running'];
Coach coachById(String id) => coaches.firstWhere((coach) => coach.id == id);


class UserProfile {
  final String id;
  String nombre, ini, objetivo, nivel, disponibilidad, notas;
  UserProfile({required this.id, required this.nombre, required this.ini, required this.objetivo, required this.nivel, required this.disponibilidad, required this.notas});
}

class Account {
  final String id, email;
  final AppRole role;
  final String profileId; // UserProfile.id o Coach.id según el rol
  String password;
  Account({required this.id, required this.email, required this.password, required this.role, required this.profileId});
}

class ChatMessage {
  final AppRole author;
  final String text, time;
  const ChatMessage(this.author, this.text, this.time);
}

class ContactRequest {
  final String id, userId, coachId;
  final DateTime createdAt;
  ContactStatus status;
  final List<ChatMessage> messages = [];

  ContactRequest({required this.id, required this.userId, required this.coachId, required this.createdAt, this.status = ContactStatus.pending});
}

String initialsOf(String name) {
  final p = name.trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
  if (p.isEmpty) return '?';
  return (p.first[0] + (p.length > 1 ? p[1][0] : '')).toUpperCase();
}

const niveles = ['Principiante', 'Intermedio', 'Avanzado'];

List<UserProfile> seedUsers() => [
      UserProfile(id: 'u1', nombre: 'Camila Torres', ini: 'CT', objetivo: 'Ganar fuerza y volver a entrenar con constancia', nivel: 'Principiante', disponibilidad: 'Lun, mié y vie por la tarde', notas: 'Sin lesiones. Prefiero entrenar en gimnasio.'),
      UserProfile(id: 'u2', nombre: 'Diego Paredes', ini: 'DP', objetivo: 'Ganar masa muscular', nivel: 'Intermedio', disponibilidad: 'Mar y jue por la mañana, sábados', notas: 'Molestia leve en el hombro derecho.'),
    ];

List<Account> seedAccounts() => [
      Account(id: 'a1', email: 'camila@demo.com', password: 'demo123', role: AppRole.user, profileId: 'u1'),
      Account(id: 'a2', email: 'diego@demo.com', password: 'demo123', role: AppRole.user, profileId: 'u2'),
      Account(id: 'a3', email: 'valeria@demo.com', password: 'demo123', role: AppRole.coach, profileId: 'c1'),
      Account(id: 'a4', email: 'mateo@demo.com', password: 'demo123', role: AppRole.coach, profileId: 'c2'),
    ];

List<ContactRequest> seedRequests() {
  final now = DateTime.now();
  return [
    ContactRequest(id: 'r1', userId: 'u2', coachId: 'c1', createdAt: now.subtract(const Duration(hours: 5))),
    ContactRequest(id: 'r2', userId: 'u2', coachId: 'c2', createdAt: now.subtract(const Duration(days: 1)), status: ContactStatus.accepted)
      ..messages.addAll(const [
        ChatMessage(AppRole.coach, '¡Hola Diego! Acepté tu solicitud. Cuéntame cómo te gustaría entrenar.', '09:12'),
        ChatMessage(AppRole.user, 'Hola Mateo, busco un plan de hipertrofia 4 días por semana.', '09:20'),
      ]),
  ];
}
