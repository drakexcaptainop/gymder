import 'package:flutter/material.dart';
import '../core_data.dart';
import '../state.dart';
import '../ui.dart';
import 'agenda.dart';
import 'ajustes.dart';
import 'perfiles.dart';
import 'resenas.dart';

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

/// Segunda línea bajo el nombre: especialidad del coach, o nivel del usuario.
String counterpartSub(ContactRequest r) => app.isCoach ? 'Nivel ${app.userById(r.userId).nivel}' : coachById(r.coachId).especialidad;

// ───────────────────────── Pestaña Mensajes ─────────────────────────
class MensajesTab extends StatefulWidget {
  const MensajesTab({super.key});
  @override
  State<MensajesTab> createState() => _MensajesTabState();
}

class _MensajesTabState extends State<MensajesTab> {
  ChatState? filter; // null = todos

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: app,
        builder: (context, _) {
          final all = app.myChats;
          final chats = filter == null ? all : all.where((r) => app.chatState(r) == filter).toList();
          int n(ChatState s) => all.where((r) => app.chatState(r) == s).length;
          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const ScreenHeader('Conversaciones', 'Mensajes', actions: [BellBtn()]),
            if (all.isNotEmpty)
              SizedBox(
                height: 40,
                child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 20), children: [
                  for (final (s, l) in <(ChatState?, String)>[(null, 'Todos ${all.length}'), (ChatState.pendiente, 'Pendientes ${n(ChatState.pendiente)}'), (ChatState.activo, 'Activos ${n(ChatState.activo)}'), (ChatState.acordado, 'Acordados ${n(ChatState.acordado)}')])
                    Padding(padding: const EdgeInsets.only(right: 8), child: Pill(l, filter == s, () => setState(() => filter = s))),
                ]),
              ),
            Expanded(
              child: all.isEmpty
                  ? EmptyState(
                      Icons.chat_bubble_outline,
                      'Aún no hay chats',
                      app.isCoach ? 'Cuando un usuario te escriba aparecerá aquí para que le respondas.' : 'Desliza a la derecha en Descubrir para preguntarle a un entrenador por sus planes.',
                      action: app.isCoach ? null : Btn('Ir a Descubrir', () => app.setTab(0), icon: Icons.style),
                    )
                  : chats.isEmpty
                      ? const EmptyState(Icons.filter_list, 'Nada por aquí', 'No tienes conversaciones con este estado.')
                      : ListView(padding: const EdgeInsets.fromLTRB(16, 12, 16, 16), children: [
                          for (final (i, r) in chats.indexed) Reveal(i, _row(context, r)),
                        ]),
            ),
          ]);
        },
      );

  Widget _row(BuildContext context, ContactRequest r) {
    final cp = counterpart(r);
    final hot = app.isCoach && app.awaitingCoach(r); // el coach debe responder
    return Tap(
      scale: .98,
      onTap: () => openChat(context, r.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: box(bg: hot ? surface2 : surface, bd: hot ? lime.withValues(alpha: .5) : line),
        child: Row(children: [
          Stack(clipBehavior: Clip.none, children: [
            Avatar(cp.$2, size: 52, tone: cp.$3),
            if (hot) Positioned(right: -3, top: -3, child: Container(width: 14, height: 14, decoration: BoxDecoration(color: lime, shape: BoxShape.circle, border: Border.all(color: surface2, width: 2.5)))),
          ]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: Text(cp.$1, style: ts(15.5, w: hot ? FontWeight.w800 : FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis)),
                Text(r.messages.isEmpty ? '' : r.messages.last.time, style: ts(11, c: hot ? lime : muted, w: FontWeight.w600)),
              ]),
              const SizedBox(height: 2),
              Text(counterpartSub(r).toUpperCase(), style: ts(10, c: muted, w: FontWeight.w800, ls: .8)),
              const SizedBox(height: 4),
              Text(r.messages.isEmpty ? 'Sin mensajes todavía' : r.messages.last.text, maxLines: 1, overflow: TextOverflow.ellipsis, style: ts(13, c: hot ? text : muted)),
              const SizedBox(height: 8),
              replyTag(r),
            ]),
          ),
        ]),
      ),
    );
  }
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

  void fill(String t) => setState(() {
        c.text = t;
        c.selection = TextSelection.collapsed(offset: t.length);
      });

  /// Hoja para elegir con qué plan se cierra el acuerdo.
  void agree(BuildContext context, ContactRequest r) {
    final planes = coachById(r.coachId).planes;
    showSheet(context, (ctx) => Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            sheetHandle(),
            Text('PLAN ACORDADO', style: hd(28, italic: true)),
            const SizedBox(height: 4),
            Text('Elige el plan con el que quedaron. Se avisará en el chat.', style: ts(13, c: muted)),
            const SizedBox(height: 14),
            for (final p in planes)
              Tap(
                onTap: () {
                  Navigator.pop(ctx);
                  app.agreePlan(r.id, '${p.nombre} · ${p.precioTxt}');
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: box(bg: surface2),
                  child: Row(children: [
                    Expanded(child: Text(p.nombre, style: ts(15, w: FontWeight.w700))),
                    Text(p.precioTxt, style: hd(22, c: lime, italic: true)),
                  ]),
                ),
              ),
            Btn('Plan personalizado', () {
              Navigator.pop(ctx);
              app.agreePlan(r.id, 'Plan personalizado');
            }, outlined: true, height: 46),
          ]),
        ));
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
          final state = app.chatState(r);
          final empty = c.text.trim().isEmpty;
          final canAgree = !r.agreed && state == ChatState.activo;
          return SubScreen(
            title: other.$1,
            subtitle: switch (state) {
              ChatState.pendiente => 'Pendiente de respuesta',
              ChatState.activo => 'Conversación activa',
              ChatState.acordado => 'Plan acordado',
            },
            actions: [
              RoundBtn(Icons.person_outline, () => app.isCoach ? openUserProfile(context, r.userId, requestId: r.id) : openCoachProfile(context, r.coachId)),
            ],
            child: Column(children: [
              // Franja de contexto
              Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
                decoration: box(bg: r.agreed ? limeTint : cyanTint, bd: r.agreed ? lime.withValues(alpha: .4) : cyan.withValues(alpha: .3), r: r12),
                child: Row(children: [
                  Icon(r.agreed ? Icons.verified : Icons.handshake_outlined, size: 18, color: r.agreed ? lime : cyan),
                  const SizedBox(width: 10),
                  Expanded(child: Text(r.agreed ? 'Plan acordado. ¡A entrenar!' : 'Acuerden aquí el plan, la mensualidad y las condiciones.', style: ts(12, c: text, h: 1.35, w: FontWeight.w500))),
                  if (canAgree) TextButton(onPressed: () => agree(context, r), child: Text('Cerrar plan', style: ts(12, c: cyan, w: FontWeight.w800))),
                  if (r.agreed && !app.isCoach) TextButton(onPressed: () => openBookingSheet(context, r.coachId, prueba: false), child: Text('Reservar sesión', style: ts(12, c: lime, w: FontWeight.w800))),
                ]),
              ),
              Expanded(
                child: ListView(controller: sc, padding: const EdgeInsets.all(16), children: [
                  Center(child: Padding(padding: const EdgeInsets.only(bottom: 14), child: Tag('Hoy', bg: surface2, fg: muted))),
                  for (final m in r.messages) _bubble(context, m, mine),
                  if (r.agreed && !app.isCoach && app.myReview(r.coachId) == null)
                    Container(
                      margin: const EdgeInsets.only(top: 6),
                      padding: const EdgeInsets.all(14),
                      decoration: box(bg: surface2),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('¿CÓMO VA TODO?', style: hd(22, italic: true)),
                        const SizedBox(height: 4),
                        Text('Cuéntale a otros usuarios cómo es entrenar con ${other.$1.split(' ').first}.', style: ts(13, c: muted, h: 1.4)),
                        const SizedBox(height: 12),
                        Btn('Dejar reseña', () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ResenasScreen(coachId: r.coachId))), icon: Icons.star_rounded, height: 44),
                      ]),
                    ),
                ]),
              ),
              // Respuestas rápidas
              if (!r.agreed)
                SizedBox(
                  height: 44,
                  child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.fromLTRB(12, 8, 12, 0), children: [
                    if (app.isCoach) ...[
                      if (app.awaitingCoach(r))
                        _quick('Responder con mis planes', () {
                          final co = app.meCoach!;
                          final planes = co.planes.isEmpty ? 'estoy armando mis planes, te cuento por aquí' : co.planes.map((p) => '${p.nombre} (${p.precioTxt})').join(', ');
                          fill('Estos son mis planes: $planes. ¿Qué objetivo y disponibilidad tienes?');
                        }, icon: Icons.bolt),
                      _quick('Cuéntame tu objetivo', () => fill('¡Hola! Cuéntame tu objetivo y cuántos días a la semana puedes entrenar.')),
                      _quick('Disponibilidad', () => fill('Tengo cupos esta semana. ¿Qué horarios te acomodan?')),
                    ] else ...[
                      _quick('¿Qué incluye el plan?', () => fill('¿Qué incluye exactamente el plan?')),
                      _quick('¿Horarios?', () => fill('¿Qué horarios tienes disponibles?')),
                      _quick('¿Cómo se paga?', () => fill('¿Cómo se paga la mensualidad?')),
                    ],
                  ]),
                ),
              Container(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                child: Row(children: [
                  Expanded(
                    child: TextField(
                      controller: c,
                      onChanged: (_) => setState(() {}),
                      onSubmitted: (_) => send(),
                      style: ts(14.5),
                      decoration: InputDecoration(
                        hintText: 'Escribe un mensaje',
                        hintStyle: ts(14.5, c: muted),
                        filled: true,
                        fillColor: surface2,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Tap(
                    onTap: empty ? null : send,
                    scale: .88,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(color: empty ? surface2 : lime, shape: BoxShape.circle),
                      child: Icon(Icons.arrow_upward_rounded, size: 22, color: empty ? muted : ink),
                    ),
                  ),
                ]),
              ),
            ]),
          );
        },
      );

  Widget _quick(String label, VoidCallback onTap, {IconData? icon}) =>
      Padding(padding: const EdgeInsets.only(right: 8), child: Pill(label, false, onTap, leading: icon == null ? null : Icon(icon, size: 15, color: lime)));

  Widget _bubble(BuildContext context, ChatMessage m, AppRole? mine) {
    if (m.system) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: box(bg: limeTint, bd: lime.withValues(alpha: .4), r: r12),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.verified, size: 18, color: lime),
          const SizedBox(width: 8),
          Flexible(child: Text(m.text, textAlign: TextAlign.center, style: ts(13, w: FontWeight.w700, c: lime))),
        ]),
      );
    }
    final me = m.author == mine;
    return Align(
      alignment: me ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * .75),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: me ? lime : surface2,
          borderRadius: BorderRadius.only(topLeft: const Radius.circular(18), topRight: const Radius.circular(18), bottomLeft: Radius.circular(me ? 18 : 4), bottomRight: Radius.circular(me ? 4 : 18)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(m.text, style: ts(14, c: me ? ink : text, h: 1.4, w: FontWeight.w500)),
          const SizedBox(height: 3),
          Text(m.time, style: ts(10, c: me ? ink.withValues(alpha: .6) : muted)),
        ]),
      ),
    );
  }
}
