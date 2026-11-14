import 'package:flutter/material.dart';
import '../core_data.dart';
import '../state.dart';
import '../ui.dart';
import 'ajustes.dart';
import 'perfiles.dart';

void openChat(BuildContext c, String requestId) =>
    Navigator.of(c).push(MaterialPageRoute(builder: (_) => ChatScreen(requestId: requestId)));

/// Nombre e iniciales de la otra persona de la conversación, según el rol en sesión.
(String, String, int) counterpart(ContactRequest r) {
  if (app.isCoach) {
    final u = app.userById(r.userId);
    return (u.nombre, u.ini, u.tone);
  }
  final c = coachById(r.coachId);
  return (c.nombre, c.ini, c.tone);
}

// ───────────────────────── Pestaña Mensajes ─────────────────────────
class MensajesTab extends StatelessWidget {
  const MensajesTab({super.key});
  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: app,
        builder: (context, _) {
          final chats = app.myChats;
          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              child: Row(children: [
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Conversaciones', style: ts(13, c: slate, w: FontWeight.w500)),
                    Text('Mensajes', style: ts(30, w: FontWeight.w600)),
                  ]),
                ),
                Stack(clipBehavior: Clip.none, children: [
                  RoundBtn(Icons.notifications_none, () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NotificacionesScreen()))),
                  if (app.unreadCount > 0)
                    Positioned(
                      right: -4,
                      top: -4,
                      child: Container(width: 20, height: 20, alignment: Alignment.center, decoration: const BoxDecoration(color: cyan, shape: BoxShape.circle), child: Text('${app.unreadCount}', style: ts(11, w: FontWeight.w700))),
                    ),
                ]),
              ]),
            ),
            Expanded(
              child: chats.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(mainAxisSize: MainAxisSize.min, children: [
                          const Icon(Icons.chat_bubble_outline, size: 44, color: slate),
                          const SizedBox(height: 12),
                          Text('Aún no tienes chats', style: ts(18, w: FontWeight.w600)),
                          const SizedBox(height: 6),
                          Text(app.isCoach ? 'Cuando un usuario te escriba aparecerá aquí para que le respondas.' : 'Desliza a la derecha en Descubrir para preguntarle a un entrenador por sus planes.', style: ts(14, c: slate, h: 1.4), textAlign: TextAlign.center),
                        ]),
                      ),
                    )
                  : ListView(padding: const EdgeInsets.symmetric(horizontal: 16), children: [
                      for (final r in chats)
                        GestureDetector(
                          onTap: () => openChat(context, r.id),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(14),
                            decoration: box(),
                            child: Row(children: [
                              Avatar(counterpart(r).$2, size: 48, tone: counterpart(r).$3),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Text(counterpart(r).$1, style: ts(16, w: FontWeight.w600)),
                                  Text(r.messages.isEmpty ? 'Sin mensajes todavía' : r.messages.last.text, maxLines: 1, overflow: TextOverflow.ellipsis, style: ts(13, c: slate)),
                                ]),
                              ),
                              const SizedBox(width: 8),
                              replyTag(r),
                            ]),
                          ),
                        ),
                    ]),
            ),
          ]);
        },
      );
}

// ───────────────────────── Chat ─────────────────────────
class ChatScreen extends StatefulWidget {
  final String requestId;
  const ChatScreen({super.key, required this.requestId});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final c = TextEditingController();
  final sc = ScrollController();

  void send() {
    app.sendMessage(widget.requestId, c.text);
    c.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: app,
        builder: (context, _) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (sc.hasClients) sc.jumpTo(sc.position.maxScrollExtent);
          });
          final r = app.requests.firstWhere((x) => x.id == widget.requestId);
          final other = counterpart(r);
          final mine = app.role;
          return SubScreen(
            title: other.$1,
            subtitle: 'Chat · ${app.isCoach ? 'usuario' : 'entrenador'}',
            actions: [
              RoundBtn(Icons.person_outline, () => app.isCoach ? openUserProfile(context, r.userId, requestId: r.id) : openCoachProfile(context, r.coachId)),
            ],
            child: Column(children: [
              Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                padding: const EdgeInsets.all(12),
                decoration: box(bg: cyanFaint, bd: cyanTint),
                child: Text('Acuerden aquí el plan, la mensualidad y las condiciones.', style: ts(12, c: slate, h: 1.4)),
              ),
              Expanded(
                child: ListView(controller: sc, padding: const EdgeInsets.all(16), children: [
                  for (final m in r.messages)
                    Align(
                      alignment: m.author == mine ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * .75),
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: m.author == mine ? navy : soft,
                          borderRadius: BorderRadius.only(topLeft: const Radius.circular(16), topRight: const Radius.circular(16), bottomLeft: Radius.circular(m.author == mine ? 16 : 4), bottomRight: Radius.circular(m.author == mine ? 4 : 16)),
                        ),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(m.text, style: ts(14, c: m.author == mine ? white : navy, h: 1.4)),
                          const SizedBox(height: 2),
                          Text(m.time, style: ts(10, c: m.author == mine ? soft : slate)),
                        ]),
                      ),
                    ),
                ]),
              ),
              if (app.isCoach && app.awaitingCoach(r))
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Pill('Responder con mis planes', false, () => setState(() {
                          final co = app.meCoach!;
                          final planes = co.planes.isEmpty ? 'estoy armando mis planes, te cuento por aquí' : co.planes.map((p) => '${p.nombre} (${p.precioTxt})').join(', ');
                          c.text = 'Estos son mis planes: $planes. ¿Qué objetivo y disponibilidad tienes?';
                          c.selection = TextSelection.collapsed(offset: c.text.length);
                        }), leading: const Icon(Icons.bolt, size: 16, color: slate)),
                  ),
                ),
              Container(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                decoration: const BoxDecoration(border: Border(top: BorderSide(color: soft))),
                child: Row(children: [
                  Expanded(child: TextField(controller: c, onChanged: (_) => setState(() {}), onSubmitted: (_) => send(), decoration: InputDecoration(hintText: 'Escribe un mensaje', border: OutlineInputBorder(borderRadius: BorderRadius.circular(22), borderSide: const BorderSide(color: soft)), contentPadding: const EdgeInsets.symmetric(horizontal: 16)))),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: c.text.trim().isEmpty ? null : send,
                    child: Container(width: 44, height: 44, decoration: BoxDecoration(color: c.text.trim().isEmpty ? soft : lime, shape: BoxShape.circle), child: Icon(Icons.send, size: 20, color: c.text.trim().isEmpty ? slate : navy)),
                  ),
                ]),
              ),
            ]),
          );
        },
      );
}
