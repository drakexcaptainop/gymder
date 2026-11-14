import 'package:flutter/material.dart';
import '../core_data.dart';
import '../state.dart';
import '../ui.dart';
import 'cuenta.dart';
import 'mensajes.dart';

void openCoachProfile(BuildContext c, String id) =>
    Navigator.of(c).push(MaterialPageRoute(builder: (_) => PerfilCoachScreen(coachId: id)));

void openUserProfile(BuildContext c, String id, {String? requestId}) =>
    Navigator.of(c).push(MaterialPageRoute(builder: (_) => PerfilUsuarioScreen(userId: id, requestId: requestId)));

/// Etiqueta de la conversación: indica quién debe responder (no hay estado "pendiente de aprobación").
Widget replyTag(ContactRequest r) {
  if (!app.awaitingCoach(r)) return const Tag('Respondida', bg: lime);
  return Tag(app.isCoach ? 'Por responder' : 'Esperando respuesta', bg: cyanTint);
}

Widget _rows(List<(String, String)> rows) => Container(
      decoration: box(),
      child: Column(children: [
        for (final (i, r) in rows.indexed)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(border: i < rows.length - 1 ? const Border(bottom: BorderSide(color: soft)) : null),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SizedBox(width: 110, child: Text(r.$1, style: ts(13, c: slate))),
              Expanded(child: Text(r.$2.isEmpty ? '—' : r.$2, style: ts(14, w: FontWeight.w500))),
            ]),
          ),
      ]),
    );

// ───────────────────────── Perfil del coach ─────────────────────────
class PerfilCoachScreen extends StatelessWidget {
  final String coachId;
  const PerfilCoachScreen({super.key, required this.coachId});
  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: app,
        builder: (context, _) {
          final c = coachById(coachId);
          final u = app.me;
          final req = u == null ? null : app.requestBetween(u.id, c.id);
          Widget? bottom;
          if (app.meCoach?.id == c.id) {
            bottom = SizedBox(width: double.infinity, child: Btn('Editar mis planes y precios', () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PlanesEditorScreen())), bg: lime, fg: navy, icon: Icons.edit_outlined));
          } else if (u != null) {
            bottom = SizedBox(
              width: double.infinity,
              child: req == null
                  ? Btn('Preguntar por sus planes', () {
                      final r = app.contact(c.id)!;
                      openChat(context, r.id);
                    }, bg: lime, fg: navy, icon: Icons.send)
                  : Btn('Abrir chat', () => openChat(context, req.id), bg: lime, fg: navy, icon: Icons.chat_bubble_outline),
            );
          }
          return SubScreen(
            title: c.nombre,
            subtitle: app.meCoach?.id == c.id ? 'Tu perfil de entrenador' : 'Perfil del entrenador',
            bottom: bottom,
            child: ListView(padding: const EdgeInsets.fromLTRB(16, 4, 16, 24), children: [
              Row(children: [
                Avatar(c.ini, size: 72),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(c.nombre, style: ts(22, w: FontWeight.w600)),
                    Text('${c.especialidad} · ${c.modalidad}', style: ts(13, c: slate)),
                  ]),
                ),
              ]),
              const SizedBox(height: 16),
              Text(c.bio, style: ts(15, h: 1.5)),
              label('Datos'),
              _rows([('Especialidad', c.especialidad), ('Experiencia', '${c.exp} años'), ('Modalidad', c.modalidad), ('Lugar', c.lugar)]),
              label('Enfoque'),
              Text(c.enfoque, style: ts(14, h: 1.5)),
              label('Temas'),
              Wrap(spacing: 6, runSpacing: 6, children: [for (final t in c.tags) Tag(t)]),
              label('Planes y precios'),
              if (c.planes.isEmpty)
                Text(app.meCoach?.id == c.id ? 'Aún no publicaste planes. Agrégalos desde "Mis planes y precios".' : 'Este entrenador aún no publicó planes. Pregúntale por chat.', style: ts(14, c: slate, h: 1.4))
              else
                for (final p in c.planes)
                  Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: box(),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(p.nombre, style: ts(16, w: FontWeight.w600)),
                          if (p.descripcion.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 2), child: Text(p.descripcion, style: ts(13, c: slate, h: 1.4))),
                        ]),
                      ),
                      const SizedBox(width: 12),
                      Text(p.precioTxt, style: ts(15, w: FontWeight.w700)),
                    ]),
                  ),
              label('Servicios'),
              for (final s in c.servicios)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(children: [const Icon(Icons.check_circle_outline, size: 20), const SizedBox(width: 10), Expanded(child: Text(s, style: ts(14)))]),
                ),
              const SizedBox(height: 8),
              Text('Escríbele cuando quieras: el plan, la mensualidad y las condiciones se acuerdan por chat.', style: ts(12, c: slate, h: 1.4)),
            ]),
          );
        },
      );
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
            bottom = SizedBox(width: double.infinity, child: Btn(app.awaitingCoach(req) ? 'Responder en el chat' : 'Abrir chat', () => openChat(context, req.id), bg: lime, fg: navy, icon: Icons.chat_bubble_outline));
          }
          return SubScreen(
            title: u.nombre,
            subtitle: app.me?.id == u.id ? 'Tu perfil' : 'Perfil del usuario',
            bottom: bottom,
            child: ListView(padding: const EdgeInsets.fromLTRB(16, 4, 16, 24), children: [
              Row(children: [
                Avatar(u.ini, size: 72),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(u.nombre, style: ts(22, w: FontWeight.w600)),
                    Text('Nivel ${u.nivel.toLowerCase()}', style: ts(13, c: slate)),
                  ]),
                ),
                if (req != null) replyTag(req),
              ]),
              label('Objetivo'),
              Text(u.objetivo.isEmpty ? '—' : u.objetivo, style: ts(15, h: 1.5)),
              label('Datos'),
              _rows([('Nivel', u.nivel), ('Disponibilidad', u.disponibilidad), ('Notas', u.notas)]),
            ]),
          );
        },
      );
}
