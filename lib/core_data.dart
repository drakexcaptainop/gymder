enum AppRole { user, coach }
enum ContactStatus { pending, accepted, rejected }

class Plan {
  final String id;
  String nombre, descripcion;
  int precio; // por mes
  Plan({required this.id, required this.nombre, required this.precio, this.descripcion = ''});
  String get precioTxt => '¤ $precio / mes';
}

class Coach {
  final String id, nombre, ini, especialidad, modalidad, lugar, resumen, bio, enfoque;
  final int exp;
  final bool disponible; // acepta alumnos nuevos ahora
  final List<String> tags, servicios;
  final List<Plan> planes; // planes y precios que el entrenador publica en su perfil
  int tone; // avatar elegido (índice en avatarTones)

  // Confianza y agenda
  bool verificado = false; // credenciales revisadas
  final List<String> certificados = []; // credenciales que el entrenador declara
  int? pruebaPrecio; // clase de prueba: null = no ofrece, 0 = gratis, n = precio en ¤
  final Set<String> horarios = {}; // plantilla semanal, p. ej. 'Lun 18:00'

  String get pruebaTxt => pruebaPrecio == null ? '' : (pruebaPrecio == 0 ? 'Prueba gratis' : 'Prueba ¤ $pruebaPrecio');

  Coach({
    required this.id, required this.nombre, required this.ini, required this.especialidad,
    required this.modalidad, required this.exp, required this.lugar, required this.resumen,
    required this.bio, required this.enfoque, required this.tags, required this.servicios,
    List<Plan>? planes,
    this.tone = 0,
    this.disponible = true,
  }) : planes = planes ?? [];

  int? get precioDesde => planes.isEmpty ? null : planes.map((p) => p.precio).reduce((a, b) => a < b ? a : b);
}

final coaches = <Coach>[
  Coach(id: 'c1', nombre: 'Valeria Ríos', ini: 'VR', especialidad: 'Fuerza', modalidad: 'Presencial', exp: 8, lugar: 'Gimnasio Central', resumen: 'Fuerza con técnica limpia y progresión medible.', bio: 'Acompaño a personas que empiezan o vuelven a entrenar a ganar fuerza con técnica limpia.', enfoque: 'Sesiones de 60 minutos: calentamiento, bloque principal y movilidad final.', tags: ['Fuerza', 'Técnica', 'Principiantes'], servicios: ['Entrenamiento de fuerza', 'Revisión de técnica', 'Movilidad']),
  Coach(id: 'c2', nombre: 'Mateo Salas', ini: 'MS', especialidad: 'Hipertrofia', modalidad: 'Presencial', exp: 6, lugar: 'Gimnasio Norte', resumen: 'Planes de volumen muscular con revisión semanal.', bio: 'Diseño bloques de hipertrofia con cargas y volumen controlados.', enfoque: 'Bloques de 4 semanas con revisión semanal de cargas y técnica.', tags: ['Hipertrofia', 'Pesas', 'Técnica'], servicios: ['Hipertrofia', 'Revisión semanal', 'Asesoría de técnica']),
  Coach(id: 'c3', nombre: 'Lucía Andrade', ini: 'LA', especialidad: 'Movilidad', modalidad: 'Online', exp: 10, lugar: 'Sesiones online', resumen: 'Movilidad, postura y control corporal.', bio: 'Trabajo movilidad, postura y control del core para que entrenes y te muevas con más comodidad.', enfoque: 'Sesiones de 45 minutos con progresiones suaves.', tags: ['Movilidad', 'Postura', 'Core'], servicios: ['Movilidad guiada', 'Postura', 'Control del core']),
  Coach(id: 'c4', nombre: 'Daniel Okafor', ini: 'DO', especialidad: 'Funcional', modalidad: 'Presencial', exp: 7, lugar: 'Gimnasio Central', resumen: 'Entrenamiento funcional y acondicionamiento.', bio: 'Combino fuerza, resistencia y coordinación en circuitos funcionales.', enfoque: 'Circuitos de intensidad progresiva con descansos programados.', tags: ['Funcional', 'Circuitos', 'Resistencia'], servicios: ['Acondicionamiento', 'Circuitos funcionales', 'Fuerza general'], disponible: false),
  Coach(id: 'c5', nombre: 'Sofía Méndez', ini: 'SM', especialidad: 'Running', modalidad: 'Online', exp: 5, lugar: 'Pista local y online', resumen: 'Planes de carrera desde 5K hasta media maratón.', bio: 'Preparo planes de carrera por objetivos con fuerza complementaria.', enfoque: 'Plan semanal con rodajes, series y una sesión de fuerza.', tags: ['Running', 'Resistencia'], servicios: ['Preparación 5K', 'Plan de carrera', 'Fuerza complementaria']),
  Coach(id: 'c6', nombre: 'Andrés Lima', ini: 'AL', especialidad: 'Hipertrofia', modalidad: 'Online', exp: 4, lugar: 'Plan online', resumen: 'Ganancia muscular con rutinas claras.', bio: 'Rutinas de hipertrofia con progresiones y revisión de técnica por video.', enfoque: 'Cuatro sesiones por semana con progresión de cargas.', tags: ['Hipertrofia', 'Rutinas en casa'], servicios: ['Plan de hipertrofia', 'Revisión por video', 'Progresión de cargas']),
  Coach(id: 'c7', nombre: 'Rodrigo Vargas', ini: 'RV', especialidad: 'Fuerza', modalidad: 'Online', exp: 9, lugar: 'Plan online', resumen: 'Powerlifting y fuerza básica con programación clara.', bio: 'Preparo programas de sentadilla, banca y peso muerto para quienes quieren levantar más y mejor.', enfoque: 'Ciclos de 6 semanas con revisión de videos de tus series.', tags: ['Fuerza', 'Powerlifting', 'Técnica'], servicios: ['Programación de fuerza', 'Revisión por video', 'Preparación de competencia']),
  Coach(id: 'c8', nombre: 'Paola Quiroga', ini: 'PQ', especialidad: 'Funcional', modalidad: 'Presencial', exp: 5, lugar: 'Gimnasio Sur', resumen: 'Circuitos dinámicos para ganar energía y resistencia.', bio: 'Entrenamientos grupales y personalizados que mezclan fuerza, cardio y coordinación.', enfoque: 'Sesiones de 50 minutos con calentamiento, circuito y vuelta a la calma.', tags: ['Funcional', 'HIIT', 'Cardio'], servicios: ['Circuitos HIIT', 'Entrenamiento personalizado', 'Acondicionamiento']),
  Coach(id: 'c9', nombre: 'Iván Cortez', ini: 'IC', especialidad: 'Running', modalidad: 'Presencial', exp: 11, lugar: 'Parque Central', resumen: 'Técnica de carrera y planes de 10K a maratón.', bio: 'Ex corredor de fondo. Te ayudo a correr más rápido y sin lesionarte.', enfoque: 'Entrenos grupales por la mañana y plan semanal individual.', tags: ['Running', 'Maratón', 'Técnica'], servicios: ['Plan 10K y 21K', 'Análisis de pisada', 'Entrenos grupales'], disponible: false),
  Coach(id: 'c10', nombre: 'Natalia Roca', ini: 'NR', especialidad: 'Movilidad', modalidad: 'Presencial', exp: 6, lugar: 'Estudio Roca', resumen: 'Movilidad y recuperación para deportistas y oficinistas.', bio: 'Combino estiramiento activo, respiración y trabajo de core para recuperar rango de movimiento.', enfoque: 'Sesiones de 45 minutos en grupos pequeños.', tags: ['Movilidad', 'Recuperación', 'Core'], servicios: ['Movilidad activa', 'Recuperación', 'Trabajo de core']),
  Coach(id: 'c11', nombre: 'Gabriel Soto', ini: 'GS', especialidad: 'Hipertrofia', modalidad: 'Presencial', exp: 8, lugar: 'Gimnasio Norte', resumen: 'Volumen muscular con enfoque en ejecución y progresión.', bio: 'Rutinas por grupos musculares con progresión de cargas y control del descanso.', enfoque: 'Plan de 5 días con seguimiento semanal de medidas y cargas.', tags: ['Hipertrofia', 'Volumen', 'Pesas'], servicios: ['Rutina de hipertrofia', 'Seguimiento de medidas', 'Revisión de técnica']),
  Coach(id: 'c12', nombre: 'Renata Arce', ini: 'RA', especialidad: 'Funcional', modalidad: 'Online', exp: 3, lugar: 'Plan online', resumen: 'Rutinas funcionales para casa, sin equipo.', bio: 'Rutinas de 30 minutos que puedes hacer en casa con poco o ningún equipo.', enfoque: 'Plan semanal con videos guiados y chat de dudas.', tags: ['Funcional', 'Rutinas en casa', 'Principiantes'], servicios: ['Rutinas en casa', 'Videos guiados', 'Soporte por chat']),
]..forEach((c) {
    c.planes.addAll(seedPlanes(c.id));
    seedExtras(c);
  });

const diasSemana = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom']; // índice = DateTime.weekday - 1
const horasDia = ['06:00', '07:00', '08:00', '10:00', '16:00', '17:00', '18:00', '19:00', '20:00'];

/// Verificación, certificados, clase de prueba y horarios de ejemplo.
void seedExtras(Coach c) {
  const ver = {
    'c1': ['Instructora de Fuerza y Acondicionamiento (NSCA-CPT)', 'Primeros auxilios y RCP'],
    'c2': ['Licenciatura en Ciencias del Deporte', 'Especialista en Hipertrofia (ISSA)'],
    'c3': ['Instructora de Movilidad (FMS nivel 2)', 'Certificación de Yoga terapéutico'],
    'c7': ['Coach de Powerlifting (IPF nivel 1)', 'Licenciatura en Educación Física'],
    'c9': ['Entrenador de Atletismo (nivel 2)', 'Análisis de pisada y biomecánica'],
    'c10': ['Fisioterapeuta deportiva', 'Instructora de Pilates matwork'],
  };
  c.certificados.addAll(ver[c.id] ?? const []);
  c.verificado = ver.containsKey(c.id);
  c.pruebaPrecio = const {'c1': 0, 'c2': 20, 'c3': 0, 'c5': 10, 'c7': 15, 'c8': 0, 'c10': 25}[c.id];
  final dias = switch (c.id) {
    'c1' || 'c4' || 'c8' => ['Lun', 'Mié', 'Vie'],
    'c2' || 'c11' => ['Mar', 'Jue', 'Sáb'],
    'c3' || 'c10' => ['Lun', 'Mar', 'Jue'],
    _ => ['Mié', 'Vie', 'Sáb'],
  };
  final horas = c.modalidad == 'Online' ? ['07:00', '19:00'] : ['08:00', '18:00', '19:00'];
  for (final d in dias) {
    for (final h in horas) {
      c.horarios.add('$d $h');
    }
  }
}

enum BookingStatus { pendiente, confirmada, rechazada, cancelada }

/// Reserva de una sesión (clase de prueba o sesión de un plan) en un horario del entrenador.
class Booking {
  final String id, userId, coachId, hora, detalle;
  final DateTime fecha; // solo día
  final bool prueba;
  BookingStatus status;
  Booking({required this.id, required this.userId, required this.coachId, required this.fecha, required this.hora, required this.detalle, this.prueba = false, this.status = BookingStatus.pendiente});

  bool get activa => status == BookingStatus.pendiente || status == BookingStatus.confirmada;
  String get cuando => '${diasSemana[fecha.weekday - 1]} ${fecha.day} ${_meses[fecha.month - 1]} · $hora';
  DateTime get inicio => DateTime(fecha.year, fecha.month, fecha.day, int.parse(hora.substring(0, 2)));
}

const _meses = ['ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago', 'sep', 'oct', 'nov', 'dic'];

/// Reservas de ejemplo (relativas a hoy para que siempre haya "próximas").
List<Booking> seedBookings() {
  final hoy = DateTime.now();
  DateTime en(int dias) => DateTime(hoy.year, hoy.month, hoy.day).add(Duration(days: dias));
  return [
    Booking(id: 'b1', userId: 'u1', coachId: 'c4', fecha: en(2), hora: '18:00', detalle: 'Circuitos', status: BookingStatus.confirmada),
    Booking(id: 'b2', userId: 'u2', coachId: 'c1', fecha: en(3), hora: '18:00', detalle: 'Clase de prueba', prueba: true),
  ];
}

List<Plan> seedPlanes(String id) => switch (id) {
      'c1' => [Plan(id: 'p1', nombre: 'Esencial', precio: 120, descripcion: '8 sesiones de fuerza al mes'), Plan(id: 'p2', nombre: 'Plus', precio: 200, descripcion: '12 sesiones + seguimiento por chat')],
      'c2' => [Plan(id: 'p1', nombre: 'Bloque 4 semanas', precio: 150, descripcion: 'Rutina de hipertrofia con revisión semanal')],
      'c3' => [Plan(id: 'p1', nombre: 'Movilidad online', precio: 90, descripcion: '8 sesiones guiadas de 45 minutos')],
      'c4' => [Plan(id: 'p1', nombre: 'Circuitos', precio: 130, descripcion: '3 sesiones funcionales por semana')],
      'c5' => [Plan(id: 'p1', nombre: 'Plan 5K', precio: 80, descripcion: 'Plan de carrera + una sesión de fuerza')],
      'c7' => [Plan(id: 'p1', nombre: 'Programa de fuerza', precio: 140, descripcion: 'Ciclo de 6 semanas + revisión de videos'), Plan(id: 'p2', nombre: 'Competencia', precio: 220, descripcion: 'Programa + coaching el día del torneo')],
      'c8' => [Plan(id: 'p1', nombre: 'HIIT 3x', precio: 110, descripcion: '3 circuitos por semana'), Plan(id: 'p2', nombre: 'Personalizado', precio: 190, descripcion: '2 sesiones 1 a 1 + plan de comidas base')],
      'c9' => [Plan(id: 'p1', nombre: 'Plan 10K', precio: 95, descripcion: 'Plan semanal + entreno grupal'), Plan(id: 'p2', nombre: 'Maratón', precio: 170, descripcion: 'Plan de 16 semanas + análisis de pisada')],
      'c10' => [Plan(id: 'p1', nombre: 'Movilidad grupal', precio: 100, descripcion: '8 sesiones de 45 minutos')],
      'c11' => [Plan(id: 'p1', nombre: 'Volumen 5 días', precio: 160, descripcion: 'Rutina de 5 días + seguimiento semanal'), Plan(id: 'p2', nombre: 'Volumen Pro', precio: 240, descripcion: 'Rutina + 4 sesiones guiadas al mes')],
      'c12' => [Plan(id: 'p1', nombre: 'En casa', precio: 60, descripcion: 'Videos guiados + soporte por chat')],
      _ => [Plan(id: 'p1', nombre: 'Plan mensual', precio: 85, descripcion: 'Rutina con progresión y revisión por video')],
    };

const especialidades = ['Fuerza', 'Hipertrofia', 'Movilidad', 'Funcional', 'Running'];
Coach coachById(String id) => coaches.firstWhere((coach) => coach.id == id);


class UserProfile {
  final String id;
  String nombre, ini, objetivo, nivel, disponibilidad, notas;
  int tone;
  UserProfile({this.tone = 0, required this.id, required this.nombre, required this.ini, required this.objetivo, required this.nivel, required this.disponibilidad, required this.notas});
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
  final bool system; // aviso del sistema ("Plan acordado"), no lo escribió nadie
  const ChatMessage(this.author, this.text, this.time, {this.system = false});
}

/// Estado visible de una conversación.
enum ChatState { pendiente, activo, acordado }

class ContactRequest {
  final String id, userId, coachId;
  final DateTime createdAt;
  ContactStatus status;
  bool agreed = false; // plan acordado entre usuario y entrenador
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
    ContactRequest(id: 'r1', userId: 'u2', coachId: 'c1', createdAt: now.subtract(const Duration(hours: 5)), status: ContactStatus.accepted)
      ..messages.add(const ChatMessage(AppRole.user, '¡Hola! ¿Qué planes tienes disponibles y cuánto cuestan?', '08:40')),
    ContactRequest(id: 'r2', userId: 'u2', coachId: 'c2', createdAt: now.subtract(const Duration(days: 1)), status: ContactStatus.accepted)
      ..messages.addAll(const [
        ChatMessage(AppRole.coach, '¡Hola Diego! Acepté tu solicitud. Cuéntame cómo te gustaría entrenar.', '09:12'),
        ChatMessage(AppRole.user, 'Hola Mateo, busco un plan de hipertrofia 4 días por semana.', '09:20'),
      ]),
    ContactRequest(id: 'r3', userId: 'u1', coachId: 'c3', createdAt: now.subtract(const Duration(hours: 3)), status: ContactStatus.accepted)
      ..messages.addAll(const [
        ChatMessage(AppRole.user, '¡Hola! ¿Qué planes tienes disponibles y cuánto cuestan?', '10:05'),
        ChatMessage(AppRole.coach, 'Hola Camila. Tengo el plan Movilidad online: 8 sesiones guiadas de 45 minutos por ¤ 90 al mes.', '10:22'),
        ChatMessage(AppRole.user, '¡Genial! ¿Hay horarios por la tarde?', '10:30'),
      ]),
    ContactRequest(id: 'r4', userId: 'u1', coachId: 'c4', createdAt: now.subtract(const Duration(days: 6)), status: ContactStatus.accepted)
      ..agreed = true
      ..messages.addAll(const [
        ChatMessage(AppRole.user, '¡Hola! ¿Qué planes tienes disponibles y cuánto cuestan?', 'Lun'),
        ChatMessage(AppRole.coach, 'Hola Camila, el plan Circuitos son 3 sesiones funcionales por semana por ¤ 130 al mes.', 'Lun'),
        ChatMessage(AppRole.user, 'Perfecto, me interesa. ¿Empezamos el lunes?', 'Lun'),
        ChatMessage(AppRole.coach, '¡Hecho! Te espero en el Gimnasio Central a las 18:00.', 'Lun'),
        ChatMessage(AppRole.coach, 'Plan acordado: Circuitos · ¤ 130 / mes', 'Lun', system: true),
      ]),
  ];
}

class Review {
  final String id, coachId, autor, texto, fecha;
  final String? userId; // null en reseñas de ejemplo
  final int estrellas;
  const Review({required this.id, required this.coachId, required this.autor, required this.estrellas, required this.texto, required this.fecha, this.userId});
}

List<Review> seedReviews() => [
      Review(id: 'rv1', coachId: 'c1', autor: 'Mariana G.', estrellas: 5, texto: 'Muy clara con la técnica y paciente. Subí mis cargas sin lesionarme.', fecha: 'Hace 2 semanas'),
      Review(id: 'rv2', coachId: 'c1', autor: 'Luis P.', estrellas: 4, texto: 'Buen seguimiento por chat y planes claros.', fecha: 'Hace 1 mes'),
      Review(id: 'rv3', coachId: 'c2', autor: 'Andrea R.', estrellas: 5, texto: 'La revisión semanal marca la diferencia. Recomendado.', fecha: 'Hace 3 semanas'),
      Review(id: 'rv4', coachId: 'c3', autor: 'Camilo V.', estrellas: 5, texto: 'Mi espalda lo agradece. Sesiones muy bien guiadas.', fecha: 'Hace 1 semana'),
      Review(id: 'rv5', coachId: 'c4', autor: 'Paula S.', estrellas: 4, texto: 'Circuitos exigentes pero bien dosificados.', fecha: 'Hace 1 mes'),
      Review(id: 'rv6', coachId: 'c5', autor: 'Jorge M.', estrellas: 5, texto: 'Logré mi primer 5K gracias al plan.', fecha: 'Hace 2 meses'),
      Review(id: 'rv7', coachId: 'c1', autor: 'Sofía L.', estrellas: 5, texto: 'Pasé de no poder hacer una sentadilla bien a cargar mi peso corporal.', fecha: 'Hace 2 meses'),
      Review(id: 'rv8', coachId: 'c3', autor: 'Pablo D.', estrellas: 4, texto: 'Muy buenas progresiones, las sesiones online son claras.', fecha: 'Hace 1 mes'),
      Review(id: 'rv9', coachId: 'c7', autor: 'Ricardo T.', estrellas: 5, texto: 'Subí 30 kg en mi peso muerto en 3 meses.', fecha: 'Hace 3 semanas'),
      Review(id: 'rv10', coachId: 'c8', autor: 'Valentina C.', estrellas: 5, texto: 'Las clases vuelan. Salgo agotada y con energía.', fecha: 'Hace 1 semana'),
      Review(id: 'rv11', coachId: 'c9', autor: 'Marco E.', estrellas: 5, texto: 'Bajé mi marca en 10K casi 6 minutos.', fecha: 'Hace 1 mes'),
      Review(id: 'rv12', coachId: 'c9', autor: 'Lorena B.', estrellas: 4, texto: 'Excelente técnica de carrera. Horarios algo tempranos.', fecha: 'Hace 2 meses'),
      Review(id: 'rv13', coachId: 'c10', autor: 'Esteban N.', estrellas: 5, texto: 'Me ayudó con la rigidez de espalda de tantas horas sentado.', fecha: 'Hace 2 semanas'),
      Review(id: 'rv14', coachId: 'c11', autor: 'Ximena O.', estrellas: 4, texto: 'Rutinas muy completas y buen seguimiento.', fecha: 'Hace 1 mes'),
    ];

class AppNotification {
  final String id, profileId, titulo, cuerpo, hora;
  final String? requestId; // al tocarla abre este chat
  bool leida;
  AppNotification({required this.id, required this.profileId, required this.titulo, required this.cuerpo, required this.hora, this.requestId, this.leida = false});
}

List<AppNotification> seedNotifications() => [
      AppNotification(id: 'n1', profileId: 'c1', titulo: 'Diego Paredes te escribió', cuerpo: '¡Hola! ¿Qué planes tienes disponibles y cuánto cuestan?', hora: '08:40', requestId: 'r1'),
      AppNotification(id: 'n2', profileId: 'u2', titulo: 'Mateo Salas respondió', cuerpo: 'Acepté tu solicitud. Cuéntame cómo te gustaría entrenar.', hora: 'Ayer', requestId: 'r2', leida: true),
      AppNotification(id: 'n3', profileId: 'u1', titulo: 'Lucía Andrade respondió', cuerpo: 'Tengo el plan Movilidad online: 8 sesiones guiadas por ¤ 90 al mes.', hora: '10:22', requestId: 'r3'),
      AppNotification(id: 'n4', profileId: 'u1', titulo: 'Plan acordado con Daniel Okafor', cuerpo: 'Circuitos · ¤ 130 / mes. ¡A entrenar!', hora: 'Lun', requestId: 'r4', leida: true),
    ];