import 'package:flutter/foundation.dart';
import 'core_data.dart';

class Filters {
  List<String> esp;
  String mod;
  bool verificados; // solo entrenadores verificados
  bool prueba; // solo quienes ofrecen clase de prueba
  Filters([List<String>? esp, this.mod = 'Todas', this.verificados = false, this.prueba = false]) : esp = esp ?? [];
  int get count => esp.length + (mod != 'Todas' ? 1 : 0) + (verificados ? 1 : 0) + (prueba ? 1 : 0);
  Filters copy() => Filters([...esp], mod, verificados, prueba);
  bool matches(Coach c) =>
      (esp.isEmpty || esp.contains(c.especialidad)) && (mod == 'Todas' || c.modalidad == mod) && (!verificados || c.verificado) && (!prueba || c.pruebaPrecio != null);
}

String two(int n) => n.toString().padLeft(2, '0');
String nowHm() {
  final d = DateTime.now();
  return '${two(d.hour)}:${two(d.minute)}';
}

class AppState extends ChangeNotifier {
  final List<Account> accounts = seedAccounts();
  final List<UserProfile> users = seedUsers();
  final List<ContactRequest> requests = seedRequests();
  final List<Review> reviews = seedReviews();
  final List<AppNotification> notifications = seedNotifications();
  final List<Booking> bookings = seedBookings();

  Account? session;
  int tab = 0;
  int _seq = 10;

  // Descubrir (coaches ya descartados, por usuario)
  final Map<String, Set<String>> seenBy = {};
  Filters filters = Filters();

  // ── Sesión
  bool get loggedIn => session != null;
  AppRole? get role => session?.role;
  bool get isCoach => role == AppRole.coach;
  UserProfile? get me => session?.role == AppRole.user ? userById(session!.profileId) : null;
  Coach? get meCoach => session?.role == AppRole.coach ? coachById(session!.profileId) : null;
  String get myName => isCoach ? meCoach!.nombre : (me?.nombre ?? '');

  UserProfile userById(String id) => users.firstWhere((u) => u.id == id);

  /// Devuelve null si todo va bien, o el mensaje de error.
  String? login(String email, String password) {
    final e = email.trim().toLowerCase();
    final a = accounts.where((x) => x.email == e).firstOrNull;
    if (a == null || a.password != password) return 'Correo o contraseña incorrectos';
    session = a;
    tab = 0;
    notifyListeners();
    return null;
  }

  void logout() {
    session = null;
    tab = 0;
    filters = Filters();
    notifyListeners();
  }

  String? register({required AppRole role, required String nombre, required String email, required String password, String? especialidad, String? modalidad}) {
    final e = email.trim().toLowerCase();
    if (nombre.trim().isEmpty || !e.contains('@') || password.length < 6) return 'Completa nombre, un correo válido y una contraseña de 6+ caracteres';
    if (accounts.any((a) => a.email == e)) return 'Ya existe una cuenta con ese correo';
    final id = '${role == AppRole.coach ? 'c' : 'u'}${_seq++}';
    final ini = initialsOf(nombre);
    if (role == AppRole.coach) {
      final esp = especialidad ?? especialidades.first;
      coaches.add(Coach(
        id: id, nombre: nombre.trim(), ini: ini, especialidad: esp, modalidad: modalidad ?? 'Online', exp: 1, lugar: 'Por definir',
        resumen: 'Coach de $esp.', bio: 'Completa tu bio para que los usuarios te conozcan mejor.', enfoque: 'Por definir con cada alumno.',
        tags: [esp], servicios: ['Entrenamiento de $esp'],
      ));
    } else {
      users.add(UserProfile(id: id, nombre: nombre.trim(), ini: ini, objetivo: 'Por definir', nivel: niveles.first, disponibilidad: 'Por definir', notas: ''));
    }
    session = Account(id: 'a${_seq++}', email: e, password: password, role: role, profileId: id);
    accounts.add(session!);
    tab = 0;
    notifyListeners();
    return null;
  }

  void saveUser({required String nombre, required String objetivo, required String nivel, required String disponibilidad, required String notas}) {
    final u = me;
    if (u == null) return;
    u.nombre = nombre.trim().isEmpty ? u.nombre : nombre.trim();
    u.ini = initialsOf(u.nombre);
    u.objetivo = objetivo.trim();
    u.nivel = nivel;
    u.disponibilidad = disponibilidad.trim();
    u.notas = notas.trim();
    notifyListeners();
  }

  void setTab(int t) {
    tab = t;
    notifyListeners();
  }

  // ── Descubrir
  Set<String> get _seen => seenBy.putIfAbsent(session?.profileId ?? '', () => {});

  ContactRequest? requestBetween(String userId, String coachId) =>
      requests.where((r) => r.userId == userId && r.coachId == coachId).firstOrNull;

  // Guardados (por usuario)
  final Map<String, Set<String>> savedBy = {};
  Set<String> get _saved => savedBy.putIfAbsent(session?.profileId ?? '', () => {});
  bool isSaved(String coachId) => _saved.contains(coachId);
  List<Coach> get saved => coaches.where((c) => _saved.contains(c.id)).toList();

  /// Guarda (o quita de guardados) a un entrenador sin contactarlo.
  void toggleSave(String coachId) {
    _saved.contains(coachId) ? _saved.remove(coachId) : _saved.add(coachId);
    notifyListeners();
  }

  List<Coach> get deck => coaches
      .where((c) =>
          !_seen.contains(c.id) &&
          !_saved.contains(c.id) &&
          (me == null || requestBetween(me!.id, c.id) == null) &&
          filters.matches(c))
      .toList();

  void discard(String coachId) {
    _seen.add(coachId);
    notifyListeners();
  }

  void resetDeck() {
    _seen.clear();
    notifyListeners();
  }

  void applyFilters(Filters f) {
    filters = f.copy();
    _seen.clear();
    notifyListeners();
  }

  // ── Contacto
  static const preguntaPlanes = '¡Hola! ¿Qué planes tienes disponibles y cuánto cuestan?';

  /// Swipe a la derecha / "Preguntar por sus planes": abre el chat al instante con la
  /// pregunta por los planes. No hay aprobación previa. Devuelve la conversación.
  ContactRequest? contact(String coachId) {
    final u = me;
    if (u == null) return null;
    var r = requestBetween(u.id, coachId);
    if (r == null) {
      r = ContactRequest(id: 'r${_seq++}', userId: u.id, coachId: coachId, createdAt: DateTime.now(), status: ContactStatus.accepted)
        ..messages.add(ChatMessage(AppRole.user, preguntaPlanes, nowHm()));
      requests.insert(0, r);
      _notify(coachId, '${u.nombre} quiere conocer tus planes', preguntaPlanes, r.id);
    }
    _seen.add(coachId);
    notifyListeners();
    return r;
  }

  /// Conversaciones de la sesión actual (con el coach si es usuario, con usuarios si es coach).
  List<ContactRequest> get myRequests => requests.where((r) => isCoach ? r.coachId == session?.profileId : r.userId == session?.profileId).toList();
  List<ContactRequest> get myChats => myRequests;

  /// Conversaciones en las que el último mensaje es del usuario, es decir, el coach debe responder.
  bool awaitingCoach(ContactRequest r) => r.messages.isNotEmpty && r.messages.last.author == AppRole.user;
  int get pendingCount => myRequests.where(awaitingCoach).length;

  /// Estado visible: pendiente (el entrenador aún no responde), activo o plan acordado.
  ChatState chatState(ContactRequest r) {
    if (r.agreed) return ChatState.acordado;
    if (!r.messages.any((m) => m.author == AppRole.coach && !m.system)) return ChatState.pendiente;
    return ChatState.activo;
  }

  /// Marca el plan como acordado y deja un aviso del sistema en el chat.
  void agreePlan(String requestId, String resumen) {
    final r = requests.firstWhere((x) => x.id == requestId);
    if (r.agreed || session == null) return;
    r.agreed = true;
    r.messages.add(ChatMessage(session!.role, 'Plan acordado: $resumen', nowHm(), system: true));
    _notify(isCoach ? r.userId : r.coachId, 'Plan acordado con $myName', resumen, r.id);
    notifyListeners();
  }
  // ── Notificaciones
  void _notify(String profileId, String titulo, String cuerpo, [String? requestId]) {
    notifications.insert(0, AppNotification(id: 'n${_seq++}', profileId: profileId, titulo: titulo, cuerpo: cuerpo, hora: nowHm(), requestId: requestId));
  }

  List<AppNotification> get myNotifications => notifications.where((n) => n.profileId == session?.profileId).toList();
  int get unreadCount => myNotifications.where((n) => !n.leida).length;

  void markRead(String id) {
    notifications.firstWhere((n) => n.id == id).leida = true;
    notifyListeners();
  }

  void markAllRead() {
    for (final n in myNotifications) {
      n.leida = true;
    }
    notifyListeners();
  }

  // ── Reseñas
  List<Review> reviewsOf(String coachId) => reviews.where((r) => r.coachId == coachId).toList();

  double? ratingOf(String coachId) {
    final l = reviewsOf(coachId);
    return l.isEmpty ? null : l.fold<int>(0, (a, r) => a + r.estrellas) / l.length;
  }

  /// Solo puede reseñar quien ya conversó con el entrenador.
  bool canReview(String coachId) => me != null && requestBetween(me!.id, coachId) != null;
  Review? myReview(String coachId) => reviews.where((r) => r.coachId == coachId && r.userId == me?.id).firstOrNull;

  void addReview(String coachId, int estrellas, String texto) {
    final u = me;
    if (u == null || estrellas < 1) return;
    reviews.removeWhere((r) => r.coachId == coachId && r.userId == u.id);
    reviews.insert(0, Review(id: 'rv${_seq++}', coachId: coachId, userId: u.id, autor: u.nombre, estrellas: estrellas, texto: texto.trim(), fecha: 'Hoy'));
    _notify(coachId, '${u.nombre} te dejó una reseña', '${'★' * estrellas} ${texto.trim()}');
    notifyListeners();
  }

  // ── Cuenta: contraseña y foto
  /// Devuelve null si todo va bien, o el mensaje de error.
  String? changePassword(String actual, String nueva) {
    final a = session;
    if (a == null) return 'Inicia sesión primero';
    if (a.password != actual) return 'La contraseña actual no coincide';
    if (nueva.length < 6) return 'La nueva contraseña debe tener al menos 6 caracteres';
    if (nueva == actual) return 'Elige una contraseña distinta a la actual';
    a.password = nueva;
    _notify(a.profileId, 'Contraseña actualizada', 'Cambiaste la contraseña de tu cuenta.');
    notifyListeners();
    return null;
  }

  /// Código de verificación de la demo (en una app real llegaría por correo).
  static const recoveryCode = '123456';
  bool emailExists(String email) => accounts.any((a) => a.email == email.trim().toLowerCase());

  String? resetPassword(String email, String code, String nueva) {
    final a = accounts.where((x) => x.email == email.trim().toLowerCase()).firstOrNull;
    if (a == null) return 'No encontramos una cuenta con ese correo';
    if (code.trim() != recoveryCode) return 'El código no es correcto';
    if (nueva.length < 6) return 'La nueva contraseña debe tener al menos 6 caracteres';
    a.password = nueva;
    notifyListeners();
    return null;
  }

  int get myTone => isCoach ? (meCoach?.tone ?? 0) : (me?.tone ?? 0);

  void setTone(int t) {
    if (isCoach) {
      meCoach?.tone = t;
    } else {
      me?.tone = t;
    }
    notifyListeners();
  }
  // ── Planes y precios del entrenador
  void savePlan(Plan p) {
    final c = meCoach;
    if (c == null) return;
    final i = c.planes.indexWhere((x) => x.id == p.id);
    i >= 0 ? c.planes[i] = p : c.planes.add(p);
    notifyListeners();
  }

  void deletePlan(String id) {
    meCoach?.planes.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  String newPlanId() => 'p${_seq++}';

  // ── Agenda y reservas
  List<Booking> get myBookings =>
      bookings.where((b) => isCoach ? b.coachId == session?.profileId : b.userId == session?.profileId).toList()..sort((a, b) => a.inicio.compareTo(b.inicio));

  bool slotTaken(String coachId, DateTime fecha, String hora) => bookings.any((b) => b.coachId == coachId && b.activa && b.fecha == fecha && b.hora == hora);

  /// El usuario ya usó (o tiene en curso) su clase de prueba con este entrenador.
  bool trialUsed(String coachId) => bookings.any((b) => b.userId == me?.id && b.coachId == coachId && b.prueba && b.activa);

  /// Próximos días con horarios libres del entrenador: (día, horas libres).
  List<(DateTime, List<String>)> freeSlots(String coachId, {int days = 14}) {
    final c = coachById(coachId);
    final now = DateTime.now();
    final out = <(DateTime, List<String>)>[];
    for (var i = 0; i < days; i++) {
      final d = DateTime(now.year, now.month, now.day + i);
      final dia = diasSemana[d.weekday - 1];
      final horas = horasDia.where((h) => c.horarios.contains('$dia $h') && !slotTaken(coachId, d, h) && DateTime(d.year, d.month, d.day, int.parse(h.substring(0, 2))).isAfter(now)).toList();
      if (horas.isNotEmpty) out.add((d, horas));
    }
    return out;
  }

  ContactRequest _chatWith(String userId, String coachId) {
    var r = requestBetween(userId, coachId);
    if (r == null) {
      r = ContactRequest(id: 'r${_seq++}', userId: userId, coachId: coachId, createdAt: DateTime.now(), status: ContactStatus.accepted);
      requests.insert(0, r);
    }
    return r;
  }

  /// Reserva una sesión. Devuelve null si el horario ya no está libre o la prueba ya se usó.
  Booking? book(String coachId, DateTime fecha, String hora, {required bool prueba}) {
    final u = me;
    if (u == null || slotTaken(coachId, fecha, hora) || (prueba && trialUsed(coachId))) return null;
    final detalle = prueba ? 'Clase de prueba' : 'Sesión de entrenamiento';
    final b = Booking(id: 'b${_seq++}', userId: u.id, coachId: coachId, fecha: fecha, hora: hora, detalle: detalle, prueba: prueba);
    bookings.add(b);
    final r = _chatWith(u.id, coachId);
    r.messages.add(ChatMessage(AppRole.user, 'Reserva solicitada: $detalle · ${b.cuando}', nowHm(), system: true));
    _seen.add(coachId);
    _notify(coachId, '${u.nombre} reservó ${prueba ? 'una clase de prueba' : 'una sesión'}', b.cuando, r.id);
    notifyListeners();
    return b;
  }

  /// El entrenador confirma o rechaza una reserva pendiente.
  void respondBooking(String id, bool accept) {
    final b = bookings.firstWhere((x) => x.id == id);
    if (b.status != BookingStatus.pendiente) return;
    b.status = accept ? BookingStatus.confirmada : BookingStatus.rechazada;
    final r = _chatWith(b.userId, b.coachId);
    r.messages.add(ChatMessage(AppRole.coach, accept ? 'Reserva confirmada: ${b.detalle} · ${b.cuando}' : 'Reserva no disponible: ${b.detalle} · ${b.cuando}', nowHm(), system: true));
    _notify(b.userId, accept ? '$myName confirmó tu reserva' : '$myName no puede en ese horario', b.cuando, r.id);
    notifyListeners();
  }

  void cancelBooking(String id) {
    final b = bookings.firstWhere((x) => x.id == id);
    if (!b.activa || session == null) return;
    b.status = BookingStatus.cancelada;
    final r = _chatWith(b.userId, b.coachId);
    r.messages.add(ChatMessage(session!.role, 'Reserva cancelada: ${b.detalle} · ${b.cuando}', nowHm(), system: true));
    _notify(isCoach ? b.userId : b.coachId, '$myName canceló la reserva', b.cuando, r.id);
    notifyListeners();
  }

  // ── Entrenador: horarios, clase de prueba y credenciales
  void toggleHorario(String slot) {
    final c = meCoach;
    if (c == null) return;
    c.horarios.contains(slot) ? c.horarios.remove(slot) : c.horarios.add(slot);
    notifyListeners();
  }

  void setPrueba(int? precio) {
    meCoach?.pruebaPrecio = precio;
    notifyListeners();
  }

  void addCertificado(String t) {
    if (t.trim().isEmpty) return;
    meCoach?.certificados.add(t.trim());
    notifyListeners();
  }

  void removeCertificado(int i) {
    final c = meCoach;
    if (c == null) return;
    c.certificados.removeAt(i);
    if (c.certificados.isEmpty) c.verificado = false;
    notifyListeners();
  }

  /// Demo: se verifica al instante si hay al menos un certificado (en producción lo revisaría una persona).
  String? requestVerification() {
    final c = meCoach;
    if (c == null || c.certificados.isEmpty) return 'Agrega al menos un certificado o título';
    c.verificado = true;
    _notify(c.id, 'Tu perfil está verificado', 'Ahora aparece con el sello Verificado.');
    notifyListeners();
    return null;
  }

  // ── Chat
  void sendMessage(String requestId, String text) {
    final r = requests.firstWhere((x) => x.id == requestId);
    if (session == null || text.trim().isEmpty) return;
    r.messages.add(ChatMessage(session!.role, text.trim(), nowHm()));
    _notify(isCoach ? r.userId : r.coachId, isCoach ? '$myName te respondió' : '$myName te escribió', text.trim(), r.id);
    notifyListeners();
  }
}

final app = AppState();
