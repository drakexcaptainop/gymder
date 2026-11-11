import 'package:flutter/material.dart';
import '../data.dart';
import '../state.dart';
import '../ui.dart';
import 'flows.dart';

class MiCoachTab extends StatelessWidget {
  const MiCoachTab({super.key});
  @override
  Widget build(BuildContext context) => ListenableBuilder(listenable: app, builder: (c, _) => _body(c));

  Widget _body(BuildContext context) {
    if (!app.paid) return _empty(context);
    final c = app.activeCoach!, p = app.activePkg!;
    final left = app.sessionsLeft;
    final endDt = addDays(today, p.dias);
    const weights = [72.4, 72.1, 71.9, 71.6, 71.4, 71.2];

    return ListView(padding: const EdgeInsets.only(bottom: 24), children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Tu seguimiento', style: ts(13, c: slate, w: FontWeight.w500)),
          Text('Mi coach', style: ts(30, w: FontWeight.w600)),
        ]),
      ),
      Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: box(bg: navy, bd: null),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Avatar(c.ini, size: 52),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(c.nombre, style: ts(18, w: FontWeight.w600, c: white)),
                Text('${c.especialidad} · ${c.modalidad}', style: ts(13, c: soft)),
              ]),
            ),
            Tag(p.nombre, bg: lime),
          ]),
          const SizedBox(height: 16),
          Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('$left', style: ts(40, w: FontWeight.w600, c: white)),
            const SizedBox(width: 8),
            Padding(padding: const EdgeInsets.only(bottom: 8), child: Text('de ${p.sesiones} sesiones', style: ts(13, c: soft))),
          ]),
          const SizedBox(height: 6),
          ClipRRect(borderRadius: BorderRadius.circular(6), child: LinearProgressIndicator(value: left / p.sesiones, minHeight: 8, color: lime, backgroundColor: Colors.white24)),
          const SizedBox(height: 8),
          Text('${p.sesiones - left} completadas · Vigente hasta el ${fmtDate(endDt)}', style: ts(12, c: soft)),
          Text('${p.dias} días de duración', style: ts(12, c: soft)),
          if (app.nearEnd) ...[
            const SizedBox(height: 12),
            Btn('Renovar paquete', () => startRenew(context), bg: lime, fg: navy, height: 44),
          ],
        ]),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: GestureDetector(
          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ChatScreen())),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: box(),
            child: Row(children: [
              const IconTile(Icons.chat_bubble_outline),
              const SizedBox(width: 12),
              Expanded(child: Text('Chat con ${c.nombre.split(' ').first}', style: ts(15, w: FontWeight.w600))),
              const Icon(Icons.chevron_right, color: slate),
            ]),
          ),
        ),
      ),
      Padding(padding: const EdgeInsets.fromLTRB(20, 22, 20, 10), child: Text('Progreso', style: ts(18, w: FontWeight.w600))),
      Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: box(),
        child: Row(children: [
          SizedBox(
            width: 88,
            height: 88,
            child: Stack(alignment: Alignment.center, children: [
              const SizedBox(width: 88, height: 88, child: CircularProgressIndicator(value: .78, strokeWidth: 9, color: lime, backgroundColor: soft, strokeCap: StrokeCap.round)),
              Text('78%', style: ts(18, w: FontWeight.w700)),
            ]),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Cumplimiento del plan', style: ts(15, w: FontWeight.w600)),
              const SizedBox(height: 4),
              Text('Esta semana', style: ts(12, c: slate)),
              const SizedBox(height: 10),
              Row(children: [
                for (var i = 0; i < 7; i++)
                  Expanded(
                    child: Column(children: [
                      Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: i <= 2 ? lime : i >= 5 ? white : soft,
                          shape: BoxShape.circle,
                          border: i == 3 ? Border.all(color: cyan, width: 2) : Border.all(color: i >= 5 ? slate : Colors.transparent),
                        ),
                        child: i <= 2 ? const Icon(Icons.check, size: 14, color: navy) : null,
                      ),
                      const SizedBox(height: 2),
                      Text(dayInitials[i], style: ts(10, c: slate)),
                    ]),
                  ),
              ]),
            ]),
          ),
        ]),
      ),
      Container(
        margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        padding: const EdgeInsets.all(16),
        decoration: box(),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Peso (kg) · últimas 6 semanas', style: ts(15, w: FontWeight.w600)),
          const SizedBox(height: 14),
          SizedBox(
            height: 110,
            child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
              for (final (i, v) in weights.indexed)
                Expanded(
                  child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                    Text(v.toString().replaceAll('.', ','), style: ts(10, c: slate)),
                    const SizedBox(height: 4),
                    Container(margin: const EdgeInsets.symmetric(horizontal: 6), height: (30 + (v - 71) * 45).roundToDouble(), decoration: BoxDecoration(color: i == 5 ? lime : soft, borderRadius: BorderRadius.circular(6))),
                    const SizedBox(height: 4),
                    Text('S${i + 1}', style: ts(10, c: slate)),
                  ]),
                ),
            ]),
          ),
        ]),
      ),
      Padding(padding: const EdgeInsets.fromLTRB(20, 22, 20, 10), child: Text('Notas del coach', style: ts(18, w: FontWeight.w600))),
      for (final n in coachNotes)
        Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
          padding: const EdgeInsets.all(14),
          decoration: box(),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(n.$1, style: ts(12, c: slate, w: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(n.$2, style: ts(14, h: 1.45)),
          ]),
        ),
      Center(
        child: TextButton(
          onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const EditorScreen())),
          child: const Text('Editor de paquetes (modo coach)'),
        ),
      ),
      Center(
        child: TextButton(
          onPressed: () {
            app.sessionsLeft = 2;
            app.notify();
            toast(context, 'Quedan 2 sesiones en el paquete');
          },
          child: const Text('Simular que quedan 2 sesiones'),
        ),
      ),
    ]);
  }

  Widget _empty(BuildContext context) => ListView(padding: const EdgeInsets.all(16), children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 12, 4, 16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Tu seguimiento', style: ts(13, c: slate, w: FontWeight.w500)),
            Text('Mi coach', style: ts(30, w: FontWeight.w600)),
          ]),
        ),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: box(),
          child: Column(children: [
            const IconTile(Icons.person_outline, size: 56),
            const SizedBox(height: 14),
            Text('Aún no tienes un coach', style: ts(18, w: FontWeight.w600)),
            const SizedBox(height: 6),
            Text('Explora coaches, elige un paquete y desbloquea tu rutina, el seguimiento y el chat.', style: ts(14, c: slate, h: 1.45), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            Btn('Explorar coaches', () => app.setTab(3), bg: lime, fg: navy),
          ]),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ChatScreen())),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: box(bg: soft.withValues(alpha: .5)),
            child: Row(children: [
              const Icon(Icons.lock_outline, color: slate),
              const SizedBox(width: 12),
              Expanded(child: Text('Chat bloqueado hasta contratar un paquete', style: ts(14, c: slate))),
            ]),
          ),
        ),
        Center(
          child: TextButton(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const EditorScreen())),
            child: const Text('Editor de paquetes (modo coach)'),
          ),
        ),
      ]);
}
