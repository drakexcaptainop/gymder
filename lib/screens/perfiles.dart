import 'package:flutter/material.dart';
import '../core_data.dart';
import '../state.dart';
import '../ui.dart';
import 'agenda.dart';
import 'cuenta.dart';
import 'mensajes.dart';
import 'resenas.dart';

void openCoachProfile(BuildContext c, String id) =>
    Navigator.of(c).push(MaterialPageRoute(builder: (_) => PerfilCoachScreen(coachId: id)));

void openUserProfile(BuildContext c, String id, {String? requestId}) =>
    Navigator.of(c).push(MaterialPageRoute(builder: (_) => PerfilUsuarioScreen(userId: id, requestId: requestId)));

/// Etiqueta de estado de la conversación: Pendiente · Activo · Plan acordado (o "Por responder" para el coach).
Widget replyTag(ContactRequest r) {
  switch (app.chatState(r)) {
    case ChatState.acordado:
      return const Tag('Plan acordado', bg: lime, fg: ink, icon: Icons.check_circle);
    case ChatState.pendiente:
      return Tag(app.isCoach ? 'Por responder' : 'Pendiente', bg: cyan, fg: ink, icon: Icons.schedule);
    case ChatState.activo:
      return app.isCoach && app.awaitingCoach(r) ? const Tag('Por responder', bg: cyan, fg: ink, icon: Icons.schedule) : const Tag('Activo', bg: surface2, fg: lime, icon: Icons.bolt);
  }
}

Widget _rows(List<(String, String)> rows) => Container(
      decoration: box(),
      child: Column(children: [
        for (final (i, r) in rows.indexed)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(border: i < rows.length - 1 ? const Border(bottom: BorderSide(color: line)) : null),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SizedBox(width: 110, child: Text(r.$1, style: ts(13, c: muted))),
              Expanded(child: Text(r.$2.isEmpty ? '—' : r.$2, style: ts(14, w: FontWeight.w600))),
            ]),
          ),
      ]),
    );

// ───────────────────────── Perfil del coach ─────────────────────────
class PerfilCoachScreen extends StatefulWidget {
  final String coachId;
  const PerfilCoachScreen({super.key, required this.coachId});
  @override
  State<PerfilCoachScreen> createState() => _PerfilCoachScreenState();
}

class _PerfilCoachScreenState extends State<PerfilCoachScreen> {
  int tab = 0; // 0 Sobre mí · 1 Planes · 2 Reseñas

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: app,
        builder: (context, _) {
          final c = coachById(widget.coachId);
          final u = app.me;
          final mine = app.meCoach?.id == c.id;
          final req = u == null ? null : app.requestBetween(u.id, c.id);
          final (_, accent) = sportColors(c.especialidad);
          final rating = app.ratingOf(c.id);
          final nRes = app.reviewsOf(c.id).length;

          Widget? action;
          if (mine) {
            action = Btn('Editar mis planes', () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PlanesEditorScreen())), icon: Icons.edit_outlined);
          } else if (u != null) {
            final trial = c.pruebaPrecio != null;
            final ask = req == null
                ? Btn(trial ? 'Preguntar' : 'Preguntar por planes', () => openChat(context, app.contact(c.id)!.id), icon: Icons.send_rounded)
                : Btn('Abrir chat', () => openChat(context, req.id), icon: Icons.chat_bubble_outline);
            action = !trial
                ? ask
                : Row(children: [
                    Expanded(child: Btn(app.trialUsed(c.id) ? 'Prueba reservada' : 'Reservar prueba', app.trialUsed(c.id) ? null : () => openBookingSheet(context, c.id, prueba: true), outlined: true, icon: Icons.event_available)),
                    const SizedBox(width: 10),
                    Expanded(child: ask),
                  ]);
          }

          return Scaffold(
            backgroundColor: bg,
            body: Column(children: [
              Expanded(
                child: ListView(padding: EdgeInsets.zero, children: [
                  // ── Hero
                  HeroBg(
                    c.especialidad,
                    height: 300,
                    child: SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Row(children: [
                            RoundBtn(Icons.chevron_left, () => Navigator.of(context).maybePop(), bg: Colors.black.withValues(alpha: .35)),
                            const Spacer(),
                            if (!mine && u != null) RoundBtn(app.isSaved(c.id) ? Icons.bookmark : Icons.bookmark_border, () => app.toggleSave(c.id), bg: Colors.black.withValues(alpha: .35), fg: amber),
                          ]),
                          const Spacer(),
                          Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                            Container(padding: const EdgeInsets.all(3), decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: accent.withValues(alpha: .6), width: 2)), child: Avatar(c.ini, size: 76, tone: c.tone)),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Wrap(spacing: 6, runSpacing: 6, children: [
                                  if (c.verificado) const Tag('Verificado', bg: cyan, fg: ink, icon: Icons.verified),
                                  Tag(c.especialidad, bg: accent.withValues(alpha: .25), fg: accent, icon: sportIcon(c.especialidad)),
                                  if (c.disponible) const Tag('Disponible', bg: lime, fg: ink) else const Tag('Lista de espera'),
                                ]),
                                const SizedBox(height: 8),
                                Text(c.nombre.toUpperCase(), style: hd(38, italic: true)),
                              ]),
                            ),
                          ]),
                        ]),
                      ),
                    ),
                  ),
                  // ── Métricas
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Row(children: [
                      Expanded(child: StatTile('${c.exp}', 'años de experiencia', Icons.military_tech_outlined)),
                      const SizedBox(width: 10),
                      Expanded(child: StatTile(rating == null ? '—' : rating.toStringAsFixed(1), '$nRes ${nRes == 1 ? 'reseña' : 'reseñas'}', Icons.star_rounded, accent: amber)),
                      const SizedBox(width: 10),
                      Expanded(child: StatTile(c.precioDesde == null ? '—' : '¤ ${c.precioDesde}', 'desde / mes', Icons.sell_outlined, accent: cyan)),
                    ]),
                  ),
                  // ── Pestañas
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                    child: Seg([(0, 'Sobre mí'), (1, 'Planes (${c.planes.length})'), (2, 'Reseñas ($nRes)')], tab, (v) => setState(() => tab = v)),
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    child: Padding(
                      key: ValueKey(tab),
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      child: switch (tab) {
                        0 => _about(c),
                        1 => _plans(c, mine, accent),
                        _ => _reviews(context, c),
                      },
                    ),
                  ),
                ]),
              ),
              if (action != null)
                Container(
                  padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + MediaQuery.of(context).padding.bottom),
                  decoration: const BoxDecoration(color: surface, border: Border(top: BorderSide(color: line))),
                  child: Row(children: [
                    if (c.precioDesde != null && !mine && c.pruebaPrecio == null)
                      Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                          Text('DESDE', style: ts(9.5, c: muted, w: FontWeight.w800, ls: 1)),
                          Text('¤ ${c.precioDesde}/mes', style: hd(26, c: lime, italic: true)),
                        ]),
                      ),
                    Expanded(child: action),
                  ]),
                ),
            ]),
          );
        },
      );

  Widget _about(Coach c) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        label('Sobre mí'),
        Text(c.bio, style: ts(15, h: 1.5)),
        label('Datos'),
        _rows([('Especialidad', c.especialidad), ('Experiencia', '${c.exp} años'), ('Modalidad', c.modalidad), ('Lugar', c.lugar)]),
        label('Enfoque'),
        Text(c.enfoque, style: ts(14, h: 1.5, c: muted)),
        label('Temas'),
        Wrap(spacing: 6, runSpacing: 6, children: [for (final t in c.tags) Tag(t)]),
        label('Credenciales'),
        if (c.certificados.isEmpty)
          Text('Este entrenador aún no declaró certificados.', style: ts(14, c: muted))
        else ...[
          for (final t in c.certificados)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(children: [const Icon(Icons.workspace_premium_outlined, size: 20, color: cyan), const SizedBox(width: 10), Expanded(child: Text(t, style: ts(14, w: FontWeight.w500)))]),
            ),
          if (c.verificado) Tag('Credenciales verificadas por Gymder', bg: cyanTint, fg: cyan, icon: Icons.verified),
        ],
        label('Servicios'),
        for (final s in c.servicios)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(children: [const Icon(Icons.check_circle, size: 20, color: lime), const SizedBox(width: 10), Expanded(child: Text(s, style: ts(14, w: FontWeight.w500)))]),
          ),
      ]);

  Widget _plans(Coach c, bool mine, Color accent) {
    if (c.planes.isEmpty) {
      return Padding(padding: const EdgeInsets.only(top: 24), child: Text(mine ? 'Aún no publicaste planes. Agrégalos desde "Mis planes y precios".' : 'Este entrenador aún no publicó planes. Pregúntale por chat.', style: ts(14, c: muted, h: 1.4)));
    }
    final star = c.planes.length > 1 ? 1 : -1; // destaca el plan intermedio como recomendado
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (c.pruebaPrecio != null) ...[
        label('Empieza con una prueba'),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: box(bg: surface2, bd: lime.withValues(alpha: .5)),
          child: Row(children: [
            const IconTile(Icons.local_activity_outlined, bg: Color(0x33C8FF3D), size: 46),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('CLASE DE PRUEBA', style: hd(22, italic: true)),
                Text('Una sesión para conocerse, sin compromiso.', style: ts(12.5, c: muted, h: 1.35)),
              ]),
            ),
            Text(c.pruebaPrecio == 0 ? 'GRATIS' : '¤ ${c.pruebaPrecio}', style: hd(30, c: lime, italic: true)),
          ]),
        ),
      ],
      label('Elige tu plan'),
      for (final (i, p) in c.planes.indexed)
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: i == star ? limeTint : surface, borderRadius: BorderRadius.circular(r20), border: Border.all(color: i == star ? lime : line, width: i == star ? 1.6 : 1)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (i == star) const Padding(padding: EdgeInsets.only(bottom: 10), child: Tag('Recomendado', bg: lime, fg: ink, icon: Icons.bolt)),
            Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Expanded(child: Text(p.nombre.toUpperCase(), style: hd(24, italic: true))),
              Text('¤ ${p.precio}', style: hd(34, c: lime, italic: true)),
              Text(' /mes', style: ts(12, c: muted, w: FontWeight.w600)),
            ]),
            if (p.descripcion.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 8), child: Text(p.descripcion, style: ts(13.5, c: muted, h: 1.4))),
          ]),
        ),
      Text('El plan, la mensualidad y las condiciones se acuerdan por chat.', style: ts(12, c: muted, h: 1.4)),
    ]);
  }

  Widget _reviews(BuildContext context, Coach c) {
    final list = app.reviewsOf(c.id);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SizedBox(height: 16),
      if (list.isEmpty) Padding(padding: const EdgeInsets.only(top: 8, bottom: 12), child: Text('Aún no hay reseñas.', style: ts(14, c: muted))),
      for (final r in list.take(3)) ResenaCard(r),
      const SizedBox(height: 4),
      SizedBox(width: double.infinity, child: Btn(app.canReview(c.id) && app.myReview(c.id) == null ? 'Escribir reseña' : 'Ver todas las reseñas', () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ResenasScreen(coachId: c.id))), outlined: true, height: 46)),
    ]);
  }
}

// ───────────────────────── Perfil del usuario ─────────────────────────
class PerfilUsuarioScreen extends StatelessWidget {
  final String userId;
  final String? requestId;
  const PerfilUsuarioScreen({super.key, required this.userId, this.requestId});
  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: app,
        builder: (context, _) {
          final u = app.userById(userId);
          final req = requestId == null ? null : app.requests.where((r) => r.id == requestId).firstOrNull;
          Widget? bottom;
          if (app.isCoach && req != null) {
            bottom = SizedBox(width: double.infinity, child: Btn(app.awaitingCoach(req) ? 'Responder en el chat' : 'Abrir chat', () => openChat(context, req.id), icon: Icons.chat_bubble_outline));
          }
          return SubScreen(
            title: u.nombre,
            subtitle: app.me?.id == u.id ? 'Tu perfil' : 'Perfil del usuario',
            bottom: bottom,
            child: ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 24), children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: box(bg: surface2),
                child: Row(children: [
                  Avatar(u.ini, size: 72, tone: u.tone),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(u.nombre.toUpperCase(), style: hd(28, italic: true)),
                      const SizedBox(height: 6),
                      Wrap(spacing: 6, runSpacing: 6, children: [Tag('Nivel ${u.nivel}', bg: limeTint, fg: lime, icon: Icons.trending_up), if (req != null) replyTag(req)]),
                    ]),
                  ),
                ]),
              ),
              label('Objetivo'),
              Container(width: double.infinity, padding: const EdgeInsets.all(14), decoration: box(), child: Text(u.objetivo.isEmpty ? '—' : u.objetivo, style: ts(15, h: 1.5))),
              label('Datos'),
              _rows([('Nivel', u.nivel), ('Disponibilidad', u.disponibilidad), ('Notas', u.notas)]),
            ]),
          );
        },
      );
}
