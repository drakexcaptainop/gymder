import 'package:flutter/material.dart';
import '../core_data.dart';
import '../state.dart';
import '../ui.dart';
import 'mensajes.dart';

void openCoachProfile(BuildContext c, String id) =>
    Navigator.of(c).push(MaterialPageRoute(builder: (_) => PerfilCoachScreen(coachId: id)));

void openUserProfile(BuildContext c, String id, {String? requestId}) =>
    Navigator.of(c).push(MaterialPageRoute(builder: (_) => PerfilUsuarioScreen(userId: id, requestId: requestId)));

String statusLabel(ContactStatus s) => switch (s) {
      ContactStatus.pending => 'Pendiente',
      ContactStatus.accepted => 'Aceptada',
      ContactStatus.rejected => 'Rechazada',
    };

Widget statusTag(ContactStatus s) => switch (s) {
      ContactStatus.pending => Tag('Pendiente', bg: cyanTint),
      ContactStatus.accepted => Tag('Aceptada', bg: lime),
      ContactStatus.rejected => Tag('Rechazada', bg: soft, fg: slate),
    };

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
          if (u != null) {
            bottom = SizedBox(
              width: double.infinity,
              child: req == null
                  ? Btn('Enviar solicitud de contacto', () {
                      app.sendRequest(c.id);
                      toast(context, 'Solicitud enviada a ${c.nombre}');
                    }, bg: lime, fg: navy, icon: Icons.send)
                  : req.status == ContactStatus.accepted
                      ? Btn('Abrir chat', () => openChat(context, req.id), bg: lime, fg: navy, icon: Icons.chat_bubble_outline)
                      : Btn('Solicitud ${statusLabel(req.status).toLowerCase()}', null),
            );
          }
          return SubScreen(
            title: c.nombre,
            subtitle: app.meCoach?.id == c.id ? 'Tu perfil de coach' : 'Perfil del coach',
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
              _rows([('Especialidad', c.especialidad), ('Experiencia', '${c.exp} años'), ('Modalidad', c.modalidad), ('Lugar', c.lugar), ('Precio orientativo', c.precioOrientativo)]),
              label('Enfoque'),
              Text(c.enfoque, style: ts(14, h: 1.5)),
              label('Temas'),
              Wrap(spacing: 6, runSpacing: 6, children: [for (final t in c.tags) Tag(t)]),
              label('Servicios'),
              for (final s in c.servicios)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(children: [const Icon(Icons.check_circle_outline, size: 20), const SizedBox(width: 10), Expanded(child: Text(s, style: ts(14)))]),
                ),
              const SizedBox(height: 8),
              Text('El plan, la mensualidad y las condiciones se acuerdan por chat una vez que el coach acepte tu solicitud.', style: ts(12, c: slate, h: 1.4)),
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
            if (req.status == ContactStatus.pending) {
              bottom = Row(children: [
                Expanded(child: Btn('Rechazar', () {
                  app.respond(req.id, false);
                  Navigator.of(context).pop();
                  toast(context, 'Solicitud rechazada');
                }, outlined: true)),
                const SizedBox(width: 10),
                Expanded(flex: 2, child: Btn('Aceptar', () {
                  app.respond(req.id, true);
                  toast(context, 'Solicitud aceptada. Ya pueden chatear');
                }, bg: lime, fg: navy)),
              ]);
            } else if (req.status == ContactStatus.accepted) {
              bottom = SizedBox(width: double.infinity, child: Btn('Abrir chat', () => openChat(context, req.id), bg: lime, fg: navy, icon: Icons.chat_bubble_outline));
            }
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
                if (req != null) statusTag(req.status),
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
