import 'package:flutter/material.dart';
import '../core_data.dart';
import '../state.dart';
import '../ui.dart';
import 'mensajes.dart';
import 'perfiles.dart';

class SolicitudesTab extends StatelessWidget {
  const SolicitudesTab({super.key});
  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: app,
        builder: (context, _) {
          final list = app.myRequests;
          final coach = app.isCoach;
          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(coach ? 'Usuarios que quieren entrenar contigo' : 'Coaches a los que escribiste', style: ts(13, c: slate, w: FontWeight.w500)),
                Text('Solicitudes', style: ts(30, w: FontWeight.w600)),
              ]),
            ),
            Expanded(
              child: list.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(mainAxisSize: MainAxisSize.min, children: [
                          const Icon(Icons.inbox_outlined, size: 44, color: slate),
                          const SizedBox(height: 12),
                          Text('Sin solicitudes', style: ts(18, w: FontWeight.w600)),
                          const SizedBox(height: 6),
                          Text(coach ? 'Cuando un usuario te envíe una solicitud aparecerá aquí.' : 'Desliza a la derecha en Descubrir para enviar una solicitud.', style: ts(14, c: slate, h: 1.4), textAlign: TextAlign.center),
                        ]),
                      ),
                    )
                  : ListView(padding: const EdgeInsets.symmetric(horizontal: 16), children: [for (final r in list) _RequestCard(r)]),
            ),
          ]);
        },
      );
}

class _RequestCard extends StatelessWidget {
  final ContactRequest r;
  const _RequestCard(this.r);
  @override
  Widget build(BuildContext context) {
    final coach = app.isCoach;
    final who = counterpart(r);
    final u = app.userById(r.userId);
    final c = coachById(r.coachId);
    final sub = coach ? 'Nivel ${u.nivel.toLowerCase()} · ${u.objetivo}' : '${c.especialidad} · ${c.modalidad}';
    return GestureDetector(
      onTap: () => coach ? openUserProfile(context, r.userId, requestId: r.id) : openCoachProfile(context, r.coachId),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: box(),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Avatar(who.$2, size: 48),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(who.$1, style: ts(16, w: FontWeight.w600)),
                Text(sub, maxLines: 2, overflow: TextOverflow.ellipsis, style: ts(12, c: slate)),
              ]),
            ),
            const SizedBox(width: 8),
            statusTag(r.status),
          ]),
          if (coach && r.status == ContactStatus.pending) ...[
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: Btn('Rechazar', () {
                app.respond(r.id, false);
                toast(context, 'Solicitud rechazada');
              }, outlined: true, height: 44)),
              const SizedBox(width: 10),
              Expanded(child: Btn('Aceptar', () {
                app.respond(r.id, true);
                toast(context, 'Aceptada. Ya pueden chatear');
              }, bg: lime, fg: navy, height: 44)),
            ]),
          ],
          if (r.status == ContactStatus.accepted) ...[
            const SizedBox(height: 12),
            SizedBox(width: double.infinity, child: Btn('Abrir chat', () => openChat(context, r.id), bg: lime, fg: navy, height: 44, icon: Icons.chat_bubble_outline)),
          ],
        ]),
      ),
    );
  }
}
