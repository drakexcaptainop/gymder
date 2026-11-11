import 'package:flutter/foundation.dart';
import 'data.dart';

class Active {
  final String coachId, pkgId;
  const Active(this.coachId, this.pkgId);
}

class Receipt {
  final String coachId, pkgId, num;
  const Receipt(this.coachId, this.pkgId, this.num);
}

class Filters {
  List<String> esp;
  String mod;
  Filters([List<String>? esp, this.mod = 'Todas']) : esp = esp ?? [];
  int get count => esp.length + (mod != 'Todas' ? 1 : 0);
  Filters copy() => Filters([...esp], mod);
}

String dateKey(DateTime d) => '${d.year}-${d.month}-${d.day}';

class AppState extends ChangeNotifier {
  int tab = 3; // descubrir
  bool paid = false;
  Active? active;
  int sessionsLeft = 0;

  // Inicio
  DateTime viewMonth = DateTime(today.year, today.month);
  DateTime selDate = today;
  EvTipo? evFilter;
  final Map<String, List<Ev>> userEvents = {};
  String? newEvId;
  final List<Ex> customEx = [];

  // Comidas
  int week = 0, mDay = 3;
  Map<int, List<List<List<PlanItem>>>> plan = genPlan();
  final Set<String> expanded = {};
  final Set<String> shopChecked = {};
  String? justMeal;

  // Rutinas
  String muscle = 'Todos';
  List<ExCfg> routineList = routine();

  // Descubrir
  final List<String> seen = [];
  final List<String> favs = [];
  Filters filters = Filters();

  // Paquetes / pago
  String coachId = 'c1';
  List<Pkg> pkgs = initialPkgs();
  String? selPkg;
  bool renew = false;
  Receipt receipt = const Receipt('c1', 'p1b', 'SIM-2026-0041');
  int rcount = 0;

  // Chat
  List<Msg> msgs = initialMsgs();

  Coach? get activeCoach => active == null ? null : coachById(active!.coachId);
  Pkg? get activePkg => active == null ? null : pkgs.firstWhere((p) => p.id == active!.pkgId);
  bool get nearEnd => paid && sessionsLeft <= 3;

  void notify() => notifyListeners();

  // ── tabs
  void setTab(int t) {
    tab = t;
    notifyListeners();
  }

  // ── Inicio
  List<Ev> eventsFor(DateTime d) =>
      [...baseEvents(d, paid, activeCoach), ...(userEvents[dateKey(d)] ?? [])];
  List<Ev> filteredEvents(DateTime d) =>
      eventsFor(d).where((e) => evFilter == null || e.tipo == evFilter).toList()..sort((a, b) => a.hora.compareTo(b.hora));

  void shiftMonth(int dir) {
    viewMonth = DateTime(viewMonth.year, viewMonth.month + dir);
    selDate = (viewMonth.year == today.year && viewMonth.month == today.month) ? today : viewMonth;
    notifyListeners();
  }

  void addEvent(DateTime date, Ev ev) {
    userEvents.putIfAbsent(dateKey(date), () => []).add(ev);
    selDate = date;
    viewMonth = DateTime(date.year, date.month);
    newEvId = ev.id;
    if (evFilter != null && evFilter != ev.tipo) evFilter = null;
    notifyListeners();
  }

  // ── Comidas
  void addToPlan(int w, int d, int slot, PlanItem it) {
    plan[w]![d][slot].add(it);
    mDay = d;
    justMeal = it.uid;
    notifyListeners();
  }

  // ── Descubrir
  List<Coach> get deck => coaches
      .where((c) =>
          !seen.contains(c.id) &&
          (filters.esp.isEmpty || filters.esp.contains(c.especialidad)) &&
          (filters.mod == 'Todas' || c.modalidad == filters.mod))
      .toList();

  void markSeen(String id, {bool fav = false}) {
    seen.add(id);
    if (fav && !favs.contains(id)) favs.add(id);
    notifyListeners();
  }

  void toggleFav(String id) {
    favs.contains(id) ? favs.remove(id) : favs.add(id);
    notifyListeners();
  }

  void applyFilters(Filters f) {
    filters = f.copy();
    seen.clear();
    notifyListeners();
  }

  // ── Pago
  void completePayment() {
    final pkg = pkgs.firstWhere((p) => p.id == selPkg);
    final n = rcount + 42;
    active = Active(coachId, pkg.id);
    sessionsLeft = pkg.sesiones;
    if (!paid) msgs = initialMsgs();
    paid = true;
    renew = false;
    receipt = Receipt(coachId, pkg.id, 'SIM-2026-${n.toString().padLeft(4, '0')}');
    rcount++;
    notifyListeners();
  }

  // ── Chat
  void sendMsg(String t) {
    if (!paid || t.trim().isEmpty) return;
    msgs = [...msgs, Msg(true, t.trim(), 'Ahora')];
    notifyListeners();
    Future.delayed(const Duration(milliseconds: 1400), () {
      msgs = [...msgs, Msg(false, 'Recibido. Lo revisamos en nuestra próxima sesión.', 'Ahora')];
      notifyListeners();
    });
  }

  // ── Paquetes (editor del coach)
  void savePkg(Pkg p) {
    final i = pkgs.indexWhere((x) => x.id == p.id);
    i >= 0 ? pkgs[i] = p : pkgs.add(p);
    notifyListeners();
  }

  Ex? exGet(String id) {
    for (final e in [...exercises, ...customEx]) {
      if (e.id == id) return e;
    }
    return null;
  }
}

final app = AppState();
