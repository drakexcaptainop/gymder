import 'package:flutter/material.dart';
import '../core_data.dart';
import '../state.dart';
import '../ui.dart';
import 'mensajes.dart';

// ───────────────────────── Reservar (usuario) ─────────────────────────
/// Hoja para elegir día y hora libres de un entrenador y reservar.
void openBookingSheet(BuildContext context, String coachId, {required bool prueba}) =>
    showSheet(context, (_) => _BookingSheet(coachId: coachId, prueba: prueba));

class _BookingSheet extends StatefulWidget {
  final String coachId;
  final bool prueba;
  const _BookingSheet({required this.coachId, required this.prueba});
  @override
  State<_BookingSheet> createState() => _BookingSheetState();
}

class _BookingSheetState extends State<_BookingSheet> {
  int dia = 0; // índice en freeSlots
  String? hora;

  @override
  Widget build(BuildContext context) {
    final c = coachById(widget.coachId);
    final slots = app.freeSlots(widget.coachId);
    final day = slots.isEmpty ? null : slots[dia.clamp(0, slots.length - 1)];
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        sheetHandle(),
        Text(widget.prueba ? 'CLASE DE PRUEBA' : 'RESERVAR SESIÓN', style: hd(30, italic: true)),
        const SizedBox(height: 4),
        Text(widget.prueba ? 'Con ${c.nombre} · ${c.pruebaPrecio == 0 ? 'gratis' : '¤ ${c.pruebaPrecio}'}' : 'Con ${c.nombre}', style: ts(13, c: muted)),
        if (slots.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 28),
            child: Text('Este entrenador no tiene horarios libres en los próximos días. Escríbele por chat para coordinar.', style: ts(14, c: muted, h: 1.45)),
          )
        else ...[
          label('Día'),
          SizedBox(
            height: 40,
            child: ListView(scrollDirection: Axis.horizontal, children: [
              for (final (i, s) in slots.indexed)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Pill('${diasSemana[s.$1.weekday - 1]} ${s.$1.day}', i == dia, () => setState(() {
                        dia = i;
                        hora = null;
                      })),
                ),
            ]),
          ),
          label('Hora'),
          Wrap(spacing: 8, runSpacing: 8, children: [for (final h in day!.$2) Pill(h, hora == h, () => setState(() => hora = h))]),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            child: Btn('Confirmar reserva', hora == null
                ? null
                : () {
                    final b = app.book(widget.coachId, day.$1, hora!, prueba: widget.prueba);
                    Navigator.pop(context);
                    toast(context, b == null ? 'Ese horario ya no está disponible' : 'Reserva enviada. ${c.nombre.split(' ').first} debe confirmarla');
                  }, icon: Icons.event_available),
          ),
        ],
        const SizedBox(height: 6),
        Text('Se abre un chat con el entrenador para coordinar detalles.', style: ts(12, c: muted)),
      ]),
    );
  }
}

// ───────────────────────── Pestaña Agenda ─────────────────────────
class AgendaTab extends StatefulWidget {
  const AgendaTab({super.key});
  @override
  State<AgendaTab> createState() => _AgendaTabState();
}

class _AgendaTabState extends State<AgendaTab> {
  int sub = 0; // coach: 0 Reservas · 1 Horarios

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: app,
        builder: (context, _) {
          final coach = app.isCoach;
          final list = app.myBookings;
          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            ScreenHeader(coach ? 'Tus alumnos' : 'Tus sesiones', 'Agenda'),
            if (coach)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                child: Seg([(0, 'Reservas (${list.where((b) => b.status == BookingStatus.pendiente).length})'), (1, 'Mis horarios')], sub, (v) => setState(() => sub = v)),
              ),
            Expanded(child: coach && sub == 1 ? _horarios() : _reservas(context, list, coach)),
          ]);
        },
      );

  Widget _reservas(BuildContext context, List<Booking> all, bool coach) {
    final pend = all.where((b) => b.status == BookingStatus.pendiente).toList();
    final conf = all.where((b) => b.status == BookingStatus.confirmada).toList();
    final otras = all.where((b) => !b.activa).toList();
    if (all.isEmpty) {
      return coach
          ? EmptyState(Icons.event_available, 'Sin reservas', 'Cuando un usuario reserve una clase de prueba o una sesión, la verás aquí para confirmarla.', action: Btn('Definir mis horarios', () => setState(() => sub = 1), icon: Icons.schedule))
          : EmptyState(Icons.event_available, 'Sin sesiones', 'Reserva una clase de prueba con un entrenador y aparecerá aquí.', action: Btn('Buscar coaches', () => app.setTab(0), icon: Icons.style));
    }
    var i = 0;
    return ListView(padding: const EdgeInsets.fromLTRB(16, 4, 16, 20), children: [
      if (pend.isNotEmpty) ...[label(coach ? 'Por confirmar' : 'Esperando confirmación'), for (final b in pend) Reveal(i++, _BookingCard(b, coach))],
      if (conf.isNotEmpty) ...[label('Próximas sesiones'), for (final b in conf) Reveal(i++, _BookingCard(b, coach))],
      if (otras.isNotEmpty) ...[label('Canceladas o rechazadas'), for (final b in otras) _BookingCard(b, coach)],
    ]);
  }

  Widget _horarios() {
    final c = app.meCoach!;
    return ListView(padding: const EdgeInsets.fromLTRB(16, 4, 16, 20), children: [
      Text('Marca los horarios en los que atiendes cada semana. Los usuarios solo podrán reservar en estos espacios.', style: ts(13, c: muted, h: 1.45)),
      const SizedBox(height: 14),
      Row(children: [
        const SizedBox(width: 46),
        for (final d in diasSemana) Expanded(child: Center(child: Text(d.toUpperCase(), style: ts(10.5, c: muted, w: FontWeight.w800, ls: .6)))),
      ]),
      const SizedBox(height: 6),
      for (final h in horasDia)
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(children: [
            SizedBox(width: 46, child: Text(h, style: ts(11.5, c: muted, w: FontWeight.w600))),
            for (final d in diasSemana)
              Expanded(
                child: Tap(
                  scale: .9,
                  onTap: () => app.toggleHorario('$d $h'),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    height: 36,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(color: c.horarios.contains('$d $h') ? lime : surface, borderRadius: BorderRadius.circular(r8), border: Border.all(color: c.horarios.contains('$d $h') ? lime : line)),
                    child: c.horarios.contains('$d $h') ? const Icon(Icons.check, size: 16, color: ink) : null,
                  ),
                ),
              ),
          ]),
        ),
      const SizedBox(height: 10),
      Text('${c.horarios.length} ${c.horarios.length == 1 ? 'horario' : 'horarios'} por semana', style: ts(13, c: muted, w: FontWeight.w600)),
    ]);
  }
}

class _BookingCard extends StatelessWidget {
  final Booking b;
  final bool coach;
  const _BookingCard(this.b, this.coach);

  @override
  Widget build(BuildContext context) {
    final name = coach ? app.userById(b.userId).nombre : coachById(b.coachId).nombre;
    final chat = app.requestBetween(b.userId, b.coachId);
    final dim = !b.activa;
    final tag = switch (b.status) {
      BookingStatus.pendiente => const Tag('Pendiente', bg: cyan, fg: ink, icon: Icons.schedule),
      BookingStatus.confirmada => const Tag('Confirmada', bg: lime, fg: ink, icon: Icons.check_circle),
      BookingStatus.rechazada => const Tag('Rechazada', icon: Icons.block),
      BookingStatus.cancelada => const Tag('Cancelada', icon: Icons.close),
    };
    return Opacity(
      opacity: dim ? .6 : 1,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: box(),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              width: 56,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(color: surface2, borderRadius: BorderRadius.circular(r12)),
              child: Column(children: [
                Text(diasSemana[b.fecha.weekday - 1].toUpperCase(), style: ts(10, c: lime, w: FontWeight.w800, ls: 1)),
                Text('${b.fecha.day}', style: hd(28, italic: true)),
              ]),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(name, style: ts(15.5, w: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text('${b.hora} · ${b.detalle}', style: ts(13, c: muted)),
                const SizedBox(height: 8),
                Wrap(spacing: 6, runSpacing: 6, children: [tag, if (b.prueba) Tag('Prueba', bg: limeTint, fg: lime)]),
              ]),
            ),
          ]),
          if (coach && b.status == BookingStatus.pendiente) ...[
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: Btn('Rechazar', () => app.respondBooking(b.id, false), outlined: true, height: 42)),
              const SizedBox(width: 10),
              Expanded(flex: 2, child: Btn('Confirmar', () {
                app.respondBooking(b.id, true);
                toast(context, 'Reserva confirmada');
              }, height: 42, icon: Icons.check)),
            ]),
          ] else if (b.activa) ...[
            const SizedBox(height: 10),
            Row(children: [
              if (chat != null) TextButton.icon(onPressed: () => openChat(context, chat.id), icon: const Icon(Icons.chat_bubble_outline, size: 16), label: const Text('Chat')),
              const Spacer(),
              TextButton(
                onPressed: () {
                  app.cancelBooking(b.id);
                  toast(context, 'Reserva cancelada');
                },
                child: Text('Cancelar', style: ts(13, c: danger, w: FontWeight.w700)),
              ),
            ]),
          ],
        ]),
      ),
    );
  }
}

// ───────────────────────── Entrenador: clase de prueba ─────────────────────────
void openPruebaSheet(BuildContext context) => showSheet(context, (_) => const _PruebaSheet());

class _PruebaSheet extends StatelessWidget {
  const _PruebaSheet();
  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: app,
        builder: (context, _) {
          final c = app.meCoach!;
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              sheetHandle(),
              Text('CLASE DE PRUEBA', style: hd(30, italic: true)),
              const SizedBox(height: 4),
              Text('Una primera sesión gratis o a bajo costo baja el riesgo del usuario y te trae alumnos nuevos.', style: ts(13, c: muted, h: 1.45)),
              label('Precio'),
              Wrap(spacing: 8, runSpacing: 8, children: [
                for (final (v, l) in <(int?, String)>[(null, 'No ofrezco'), (0, 'Gratis'), (10, '¤ 10'), (20, '¤ 20'), (30, '¤ 30')]) Pill(l, c.pruebaPrecio == v, () => app.setPrueba(v)),
              ]),
              const SizedBox(height: 18),
              SizedBox(width: double.infinity, child: Btn('Listo', () => Navigator.pop(context))),
            ]),
          );
        },
      );
}

// ───────────────────────── Entrenador: verificación y credenciales ─────────────────────────
class CredencialesScreen extends StatefulWidget {
  const CredencialesScreen({super.key});
  @override
  State<CredencialesScreen> createState() => _CredencialesScreenState();
}

class _CredencialesScreenState extends State<CredencialesScreen> {
  final cert = TextEditingController();

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: app,
        builder: (context, _) {
          final c = app.meCoach!;
          return SubScreen(
            title: 'Verificación',
            subtitle: 'Credenciales',
            bottom: SizedBox(
              width: double.infinity,
              child: Btn(c.verificado ? 'Perfil verificado' : 'Solicitar verificación', c.verificado
                  ? null
                  : () {
                      final err = app.requestVerification();
                      toast(context, err ?? 'Listo. Tu perfil ya tiene el sello Verificado (demo)');
                    }, icon: Icons.verified),
            ),
            child: ListView(padding: const EdgeInsets.all(16), children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: box(bg: c.verificado ? limeTint : surface2, bd: c.verificado ? lime.withValues(alpha: .5) : line),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Icon(c.verificado ? Icons.verified : Icons.shield_outlined, color: c.verificado ? lime : muted, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(c.verificado ? 'VERIFICADO' : 'SIN VERIFICAR', style: hd(24, italic: true, c: c.verificado ? lime : text)),
                      const SizedBox(height: 4),
                      Text(c.verificado ? 'Los usuarios ven el sello en tu tarjeta y tu perfil, y puedes aparecer en el filtro "Solo verificados".' : 'Agrega tus certificados o títulos y solicita la verificación. Los perfiles verificados generan más confianza y más mensajes.', style: ts(13, c: muted, h: 1.45)),
                    ]),
                  ),
                ]),
              ),
              label('Mis certificados'),
              if (c.certificados.isEmpty) Text('Aún no agregaste ninguno.', style: ts(14, c: muted)),
              for (final (i, t) in c.certificados.indexed)
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.fromLTRB(14, 6, 6, 6),
                  decoration: box(),
                  child: Row(children: [
                    const Icon(Icons.workspace_premium_outlined, size: 20, color: lime),
                    const SizedBox(width: 10),
                    Expanded(child: Text(t, style: ts(14, w: FontWeight.w600))),
                    IconButton(onPressed: () => app.removeCertificado(i), icon: const Icon(Icons.close, size: 18, color: muted)),
                  ]),
                ),
              label('Agregar certificado'),
              Row(children: [
                Expanded(child: field(cert, 'Ej. Instructor NSCA-CPT', maxLen: 60)),
                const SizedBox(width: 8),
                RoundBtn(Icons.add, () {
                  app.addCertificado(cert.text);
                  cert.clear();
                }, size: 52, bg: lime, fg: ink),
              ]),
              const SizedBox(height: 14),
              Text('En esta demo la verificación es automática. En una versión real, el equipo de Gymder revisaría los documentos.', style: ts(12, c: muted, h: 1.4)),
            ]),
          );
        },
      );
}
