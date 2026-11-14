import 'package:flutter/foundation.dart';
import 'core_data.dart';

class Filters {
  List<String> esp;
  String mod;
  Filters([List<String>? esp, this.mod = 'Todas']) : esp = esp ?? [];
  int get count => esp.length + (mod != 'Todas' ? 1 : 0);
  Filters copy() => Filters([...esp], mod);
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
        tags: [esp], servicios: ['Entrenamiento de $esp'], precioOrientativo: 'A convenir por chat',
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

  List<Coach> get deck => coaches
      .where((c) =>
          !_seen.contains(c.id) &&
          (me == null || requestBetween(me!.id, c.id) == null) &&
          (filters.esp.isEmpty || filters.esp.contains(c.especialidad)) &&
          (filters.mod == 'Todas' || c.modalidad == filters.mod))
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

  // ── Solicitudes
  /// Swipe a la derecha / botón "Enviar solicitud". Devuelve false si ya existía.
  bool sendRequest(String coachId) {
    final u = me;
    if (u == null || requestBetween(u.id, coachId) != null) return false;
    requests.insert(0, ContactRequest(id: 'r${_seq++}', userId: u.id, coachId: coachId, createdAt: DateTime.now()));
    _seen.add(coachId);
    notifyListeners();
    return true;
  }

  /// Solicitudes visibles para la sesión actual (enviadas si es usuario, recibidas si es coach).
  List<ContactRequest> get myRequests => requests.where((r) => isCoach ? r.coachId == session?.profileId : r.userId == session?.profileId).toList();
  List<ContactRequest> get myChats => myRequests.where((r) => r.status == ContactStatus.accepted).toList();
  int get pendingCount => myRequests.where((r) => r.status == ContactStatus.pending).length;

  void respond(String requestId, bool accept) {
    final r = requests.firstWhere((x) => x.id == requestId);
    if (!isCoach || r.status != ContactStatus.pending) return;
    r.status = accept ? ContactStatus.accepted : ContactStatus.rejected;
    if (accept) {
      r.messages.add(ChatMessage(AppRole.coach, '¡Hola ${userById(r.userId).nombre.split(' ').first}! Acepté tu solicitud. Conversemos sobre tu objetivo, el plan, la mensualidad y las condiciones.', nowHm()));
    }
    notifyListeners();
  }

  // ── Chat
  void sendMessage(String requestId, String text) {
    final r = requests.firstWhere((x) => x.id == requestId);
    if (session == null || r.status != ContactStatus.accepted || text.trim().isEmpty) return;
    r.messages.add(ChatMessage(session!.role, text.trim(), nowHm()));
    notifyListeners();
  }
}

final app = AppState();
