import 'package:flutter/material.dart';
import '../data.dart';
import '../state.dart';
import '../ui.dart';
import 'flows.dart' show startRenew;
import 'rutinas.dart' show ExerciseDetail;

Widget _marker(EvTipo t) => tipoMarker(t.name);

class InicioTab extends StatelessWidget {
  const InicioTab({super.key});
  @override
  Widget build(BuildContext context) => ListenableBuilder(listenable: app, builder: (c, _) => _body(c));

  Widget _body(BuildContext context) {
    final vm = app.viewMonth;
    final first = weekdayIdx(DateTime(vm.year, vm.month, 1));
    final nd = DateTime(vm.year, vm.month + 1, 0).day;
    final cellCount = ((first + nd + 6) ~/ 7) * 7;
    final selEvs = app.filteredEvents(app.selDate);
    final filterName = app.evFilter == null ? '' : ' · ${tipoLabel[app.evFilter]}';

    return Scaffold(
      backgroundColor: white,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: navy,
        foregroundColor: white,
        onPressed: () => showSheet(context, (_) => EventSheet(initialDate: app.selDate, initialTipo: app.evFilter ?? EvTipo.ejercicio)),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo evento'),
      ),
      body: ListView(padding: const EdgeInsets.only(bottom: 100), children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Tu calendario', style: ts(13, c: slate, w: FontWeight.w500)),
                Text('Inicio', style: ts(30, w: FontWeight.w600)),
              ]),
            ),
            RoundBtn(Icons.chevron_left, () => app.shiftMonth(-1)),
            SizedBox(width: 118, child: Center(child: Text('${cap(monthNames[vm.month - 1])} ${vm.year}', style: ts(15, w: FontWeight.w600)))),
            RoundBtn(Icons.chevron_right, () => app.shiftMonth(1)),
          ]),
        ),
        if (app.nearEnd) _RenewBanner(),
        SizedBox(
          height: 36,
          child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16), children: [
            for (final f in <EvTipo?>[null, ...EvTipo.values])
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Pill(f == null ? 'Todos' : tipoLabel[f]!, app.evFilter == f, () {
                  app.evFilter = f;
                  app.notify();
                }, leading: f == null ? null : _marker(f)),
              ),
          ]),
        ),
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.fromLTRB(8, 12, 8, 12),
          decoration: box(),
          child: Column(children: [
            Row(children: [
              for (final d in dayInitials) Expanded(child: Center(child: Text(d, style: ts(12, w: FontWeight.w500, c: slate)))),
            ]),
            const SizedBox(height: 6),
            GridView.count(
              crossAxisCount: 7,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisExtent: 48,
              childAspectRatio: 1,
              children: [
                for (var i = 0; i < cellCount; i++)
                  if (i < first || i - first >= nd) const SizedBox() else _DayCell(DateTime(vm.year, vm.month, i - first + 1)),
              ],
            ),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Wrap(spacing: 16, runSpacing: 6, children: [
            for (final t in EvTipo.values) Row(mainAxisSize: MainAxisSize.min, children: [_marker(t), const SizedBox(width: 6), Text(tipoLabel[t]!, style: ts(12, c: slate))]),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 10),
          child: Row(children: [
            Expanded(child: Text('${cap(dayLong[weekdayIdx(app.selDate)])} ${app.selDate.day} de ${monthNames[app.selDate.month - 1]}', style: ts(18, w: FontWeight.w600))),
            Text('${selEvs.length} ${selEvs.length == 1 ? 'evento' : 'eventos'}$filterName', style: ts(12, c: slate)),
          ]),
        ),
        if (selEvs.isEmpty)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(24),
            decoration: box(),
            child: Center(child: Text('No hay eventos para este día.', style: ts(14, c: slate))),
          )
        else
          for (final e in selEvs) _AgendaCard(e),
      ]),
    );
  }
}

class _RenewBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = app.activeCoach!, p = app.activePkg!;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(16),
      decoration: box(bg: navy, bd: null),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const IconTile(Icons.calendar_today_outlined, bg: lime, fg: navy),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Tu paquete está por terminar', style: ts(16, w: FontWeight.w600, c: white)),
            const SizedBox(height: 4),
            Text('Te quedan ${app.sessionsLeft} sesiones de ${p.nombre} con ${c.nombre}. La renovación es manual y no genera cobros automáticos.',
                style: ts(13, c: soft, h: 1.45)),
            const SizedBox(height: 10),
            Btn('Renovar', () => startRenew(context), bg: lime, fg: navy, height: 40),
          ]),
        ),
      ]),
    );
  }
}

class _DayCell extends StatelessWidget {
  final DateTime d;
  const _DayCell(this.d);
  @override
  Widget build(BuildContext context) {
    final sel = dateOnly(d) == dateOnly(app.selDate);
    final isToday = dateOnly(d) == today;
    final types = EvTipo.values.where((t) => app.filteredEvents(d).any((e) => e.tipo == t)).toList();
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        app.selDate = d;
        app.notify();
      },
      child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
        const SizedBox(height: 2),
        Container(
          width: 34,
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: sel ? navy : isToday ? lime : Colors.transparent,
            shape: BoxShape.circle,
            boxShadow: sel && isToday ? [const BoxShadow(color: lime, spreadRadius: 2)] : null,
          ),
          child: Text('${d.day}', style: ts(14, w: sel || isToday ? FontWeight.w600 : FontWeight.w400, c: sel ? white : navy)),
        ),
        const SizedBox(height: 3),
        SizedBox(height: 8, child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [for (final t in types) Padding(padding: const EdgeInsets.symmetric(horizontal: 1.5), child: _marker(t))])),
      ]),
    );
  }
}

class _AgendaCard extends StatelessWidget {
  final Ev e;
  const _AgendaCard(this.e);
  @override
  Widget build(BuildContext context) {
    final isNew = e.id == app.newEvId;
    final (icon, bg, fg) = switch (e.tipo) {
      EvTipo.ejercicio => (Icons.fitness_center, navy, white),
      EvTipo.comida => (Icons.restaurant_outlined, lime, navy),
      EvTipo.sesion => (Icons.person_outline, cyanTint, navy),
    };
    final cfg = e.cfg;
    return GestureDetector(
      onTap: cfg == null ? null : () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ExerciseDetail(exId: cfg.exId, cfg: cfg))),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
        padding: const EdgeInsets.all(14),
        decoration: box(bd: isNew ? cyan : soft, bw: isNew ? 2 : 1),
        child: Row(children: [
          IconTile(icon, bg: bg, fg: fg, size: 44, border: e.tipo == EvTipo.sesion ? cyan : null),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text(e.hora, style: ts(12, w: FontWeight.w600, c: slate)),
                const SizedBox(width: 8),
                Text(tipoLabel[e.tipo]!.toUpperCase(), style: ts(11, w: FontWeight.w600, c: slate)),
                if (isNew) ...[const SizedBox(width: 8), const Tag('Nuevo', bg: cyan)],
              ]),
              const SizedBox(height: 2),
              Text(e.titulo, style: ts(15, w: FontWeight.w600)),
              Text(e.detalle, style: ts(13, c: slate)),
              if (cfg != null && cfg.alts.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text('${cfg.alts.length} ${cfg.alts.length == 1 ? 'alternativa' : 'alternativas'} de equipo', style: ts(12, c: slate, w: FontWeight.w500)),
                ),
            ]),
          ),
          if (cfg != null) const Icon(Icons.chevron_right, color: slate),
        ]),
      ),
    );
  }
}

// ───────────────────────── Create-event sheet ─────────────────────────
class EventSheet extends StatefulWidget {
  final DateTime initialDate;
  final EvTipo initialTipo;
  const EventSheet({super.key, required this.initialDate, required this.initialTipo});
  @override
  State<EventSheet> createState() => _EventSheetState();
}

class _EventSheetState extends State<EventSheet> {
  late EvTipo tipo = widget.initialTipo;
  late DateTime date = widget.initialDate;
  String hora = '18:00', fmt = 'ambos';
  final titulo = TextEditingController();
  final q = TextEditingController();
  Ex? ex;
  String? principal;
  List<String> alts = [];
  int series = 3, reps = 12, descanso = 60;

  String _defFmt(Ex e) => e.video && e.d3 ? 'ambos' : e.video ? 'video' : e.d3 ? '3d' : 'ninguno';
  bool _fmtAvail(String f) => ex != null && (f == 'video' ? ex!.video : f == '3d' ? ex!.d3 : (ex!.video && ex!.d3));

  bool get canSave => tipo == EvTipo.ejercicio ? ex != null : titulo.text.trim().isNotEmpty;

  void save() {
    if (!canSave) return;
    final id = 'ue${DateTime.now().microsecondsSinceEpoch}';
    Ev ev;
    if (tipo == EvTipo.ejercicio) {
      final pv = ex!.vars.firstWhere((v) => v.id == principal, orElse: () => ex!.vars.first);
      final cfg = ExCfg(ex!.id, fmt, pv.id, [...alts], series, reps, descanso);
      ev = Ev(id, tipo, pv.nombre, hora, '$series × $reps · $descanso s de descanso · ${eqNames[pv.eq]}', cfg: cfg);
    } else {
      ev = Ev(id, tipo, titulo.text.trim(), hora, 'Evento creado por ti');
    }
    app.addEvent(date, ev);
    Navigator.pop(context);
    toast(context, 'Evento guardado');
  }

  @override
  Widget build(BuildContext context) {
    final qn = norm(q.text.trim());
    final lib = [...exercises, ...app.customEx];
    final matches = qn.isEmpty
        ? <Ex>[]
        : lib.where((e) => norm(e.nombre).contains(qn) || norm(e.grupo).contains(qn) || e.vars.any((v) => norm(v.nombre).contains(qn))).take(6).toList();
    String nVar(Ex e) => '${e.vars.length} ${e.vars.length == 1 ? 'variante' : 'variantes'}';

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        sheetHandle(),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 12, 0),
          child: Row(children: [
            Expanded(child: Text('Nuevo evento', style: ts(20, w: FontWeight.w600))),
            IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
          ]),
        ),
        Flexible(
          child: ListView(padding: const EdgeInsets.fromLTRB(20, 0, 20, 12), shrinkWrap: true, children: [
            label('Tipo'),
            Seg([for (final t in EvTipo.values) (t, tipoLabel[t]!)], tipo, (v) => setState(() => tipo = v)),
            label('Fecha'),
            Row(children: [
              RoundBtn(Icons.chevron_left, () => setState(() => date = addDays(date, -1))),
              Expanded(child: Center(child: Text('${cap(dayLong[weekdayIdx(date)])} ${date.day} de ${monthNames[date.month - 1]}', style: ts(15, w: FontWeight.w600)))),
              RoundBtn(Icons.chevron_right, () => setState(() => date = addDays(date, 1))),
            ]),
            label('Hora'),
            Wrap(spacing: 8, runSpacing: 8, children: [for (final h in horas) Pill(h, hora == h, () => setState(() => hora = h))]),
            if (tipo != EvTipo.ejercicio) ...[
              label('Título'),
              field(titulo, tipo == EvTipo.sesion ? 'Ej. Revisión de técnica' : 'Ej. Cena con amigos', onChanged: (_) => setState(() {}), maxLen: 40),
            ] else ...[
              label('Ejercicio'),
              if (ex == null) ...[
                field(q, 'Buscar ejercicio, músculo o equipo', onChanged: (_) => setState(() {}), maxLen: 40, icon: Icons.search),
                const SizedBox(height: 8),
                if (qn.isEmpty) Text('Escribe para buscar en la biblioteca, p. ej. “sent” o “remo”.', style: ts(13, c: slate)),
                for (final e in matches)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(e.nombre, style: ts(15, w: FontWeight.w600)),
                    subtitle: Text('${e.grupo} · ${nVar(e)}', style: ts(12, c: slate)),
                    trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                      if (e.video) const Tag('Video'),
                      const SizedBox(width: 4),
                      if (e.d3) const Tag('3D'),
                    ]),
                    onTap: () => setState(() {
                      ex = e;
                      fmt = _defFmt(e);
                      principal = e.vars.first.id;
                      alts = [];
                    }),
                  ),
                if (qn.isNotEmpty && matches.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Btn('Crear “${q.text.trim()}”', () {
                      final nm = cap(q.text.trim());
                      final id = 'cx${DateTime.now().millisecondsSinceEpoch}';
                      final e = Ex(id, nm, 'Personalizado', false, false, [['libre', nm]], custom: true);
                      app.customEx.add(e);
                      setState(() {
                        ex = e;
                        fmt = 'ninguno';
                        principal = e.vars.first.id;
                        alts = [];
                      });
                    }, outlined: true, icon: Icons.add),
                  ),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: box(),
                  child: Row(children: [
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(ex!.nombre, style: ts(16, w: FontWeight.w600)),
                        Text('${ex!.grupo} · ${nVar(ex!)}', style: ts(12, c: slate)),
                      ]),
                    ),
                    TextButton(onPressed: () => setState(() => ex = null), child: const Text('Cambiar')),
                  ]),
                ),
                label('Formato de demostración'),
                Seg([for (final f in fmts) (f[0], f[1])], fmt, (v) => setState(() => fmt = v), enabled: _fmtAvail),
                const SizedBox(height: 6),
                Text(
                  fmt == 'ninguno'
                      ? 'Este ejercicio personalizado no tiene demostración en la biblioteca.'
                      : fmt == 'video'
                          ? 'El alumno verá el video en el detalle del ejercicio.'
                          : fmt == '3d'
                              ? 'El alumno verá el modelo 3D en el detalle del ejercicio.'
                              : 'El alumno podrá alternar entre video y modelo 3D.',
                  style: ts(12, c: slate),
                ),
                label('Variante principal y alternativas de equipo'),
                for (final v in ex!.vars) _varRow(v),
                label('Series, repeticiones y descanso'),
                StepperRow('Series', '$series', () => setState(() => series = (series - 1).clamp(1, 10)), () => setState(() => series = (series + 1).clamp(1, 10))),
                const SizedBox(height: 8),
                StepperRow('Repeticiones', '$reps', () => setState(() => reps = (reps - 1).clamp(1, 30)), () => setState(() => reps = (reps + 1).clamp(1, 30))),
                const SizedBox(height: 8),
                StepperRow('Descanso', '$descanso s', () => setState(() => descanso = (descanso - 15).clamp(0, 300)), () => setState(() => descanso = (descanso + 15).clamp(0, 300))),
                const SizedBox(height: 8),
                Text(alts.isEmpty ? 'Sin alternativas' : '${alts.length} ${alts.length == 1 ? 'alternativa' : 'alternativas'}', style: ts(12, c: slate)),
              ],
            ],
          ]),
        ),
        Padding(padding: const EdgeInsets.fromLTRB(20, 8, 20, 16), child: SizedBox(width: double.infinity, child: Btn('Guardar evento', canSave ? save : null))),
      ]),
    );
  }

  Widget _varRow(ExVar v) {
    final pr = principal == v.id, al = alts.contains(v.id);
    return GestureDetector(
      onTap: () => setState(() {
        if (pr) return;
        al ? alts.remove(v.id) : alts.add(v.id);
      }),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: box(bg: pr ? lime.withValues(alpha: .12) : al ? cyanFaint : white, bd: pr ? lime : al ? cyan : soft, bw: pr ? 2 : 1.5),
        child: Row(children: [
          Icon(eqIcon(v.eq), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(v.nombre, style: ts(14, w: FontWeight.w600)),
              Text(eqNames[v.eq]!, style: ts(12, c: slate)),
            ]),
          ),
          if (pr) const Tag('Principal', bg: lime) else ...[
            TextButton(
              onPressed: () => setState(() {
                principal = v.id;
                alts.remove(v.id);
              }),
              child: const Text('Hacer principal'),
            ),
            Icon(al ? Icons.check_box : Icons.check_box_outline_blank, color: al ? cyan : slate),
          ],
        ]),
      ),
    );
  }
}
