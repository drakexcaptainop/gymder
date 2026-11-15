import 'dart:async';
import 'package:flutter/material.dart';
import '../core_data.dart';
import '../state.dart';
import '../ui.dart';
import 'ajustes.dart';
import 'mensajes.dart';
import 'perfiles.dart';
import 'resenas.dart';

class DescubrirTab extends StatefulWidget {
  const DescubrirTab({super.key});
  /// Duración del skeleton de la primera carga (0 = sin skeleton; los tests lo desactivan).
  static int skeletonMs = 900;
  @override
  State<DescubrirTab> createState() => _DescubrirTabState();
}

class _DescubrirTabState extends State<DescubrirTab> {
  static bool _loadedOnce = false; // el skeleton solo se ve la primera vez
  double dx = 0, dy = 0;
  bool dragging = false;
  bool loading = !_loadedOnce && DescubrirTab.skeletonMs > 0;
  int sub = 0; // 0 = Descubrir, 1 = Guardados
  String? fly;

  @override
  void initState() {
    super.initState();
    if (loading) {
      Timer(Duration(milliseconds: DescubrirTab.skeletonMs), () {
        _loadedOnce = true;
        if (mounted) setState(() => loading = false);
      });
    }
  }

  void swipe(String dir) {
    final top = app.deck.firstOrNull;
    if (top == null || fly != null) return;
    setState(() {
      dragging = false;
      fly = dir;
      dx = dir == 'right' ? 520 : dir == 'left' ? -520 : 0;
      dy = dir == 'up' ? -620 : 40;
    });
    Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      if (dir == 'right') {
        app.contact(top.id);
      } else if (dir == 'up') {
        app.toggleSave(top.id);
      } else {
        app.discard(top.id);
      }
      setState(() {
        dx = 0;
        dy = 0;
        fly = null;
      });
      if (dir == 'right') toast(context, 'Le preguntaste a ${top.nombre} por sus planes. Revisa Mensajes');
      if (dir == 'up') toast(context, '${top.nombre} guardado en tu lista');
    });
  }

  void openProfile(Coach c) {
    setState(() {
      dx = 0;
      dy = 0;
      dragging = false;
    });
    openCoachProfile(context, c.id);
  }

  void onEnd() {
    final top = app.deck.firstOrNull;
    if (dx.abs() < 6 && dy.abs() < 6) {
      if (top != null) openProfile(top);
      return;
    }
    if (dx > 110) return swipe('right');
    if (dx < -110) return swipe('left');
    if (dy < -110 && top != null) return openProfile(top);
    setState(() {
      dragging = false;
      dx = 0;
      dy = 0;
    });
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(listenable: app, builder: (c, _) => _body(c));

  Widget _body(BuildContext context) {
    final f = app.filters;
    final first = (app.me?.nombre ?? '').split(' ').first;
    return Column(children: [
      ScreenHeader(first.isEmpty ? 'Encuentra a tu entrenador' : 'Hola, $first', 'Descubrir', actions: [
        Stack(clipBehavior: Clip.none, children: [
          RoundBtn(Icons.tune, () => showSheet(context, (_) => const _FilterSheet())),
          if (f.mod != 'Todas' || f.verificados || f.prueba) Positioned(right: -3, top: -3, child: Container(width: 12, height: 12, decoration: BoxDecoration(color: lime, shape: BoxShape.circle, border: Border.all(color: bg, width: 2)))),
        ]),
        const BellBtn(),
      ]),
      // Pestañas internas
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
        child: Seg([(0, 'Coaches'), (1, 'Guardados (${app.saved.length})')], sub, (v) => setState(() => sub = v)),
      ),
      if (sub == 0) ...[
        // Chips rápidos por especialidad
        SizedBox(
          height: 40,
          child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 20), children: [
            for (final e in especialidades)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Pill(e, f.esp.contains(e), () {
                  final n = f.copy();
                  n.esp.contains(e) ? n.esp.remove(e) : n.esp.add(e);
                  app.applyFilters(n);
                }, leading: Icon(sportIcon(e), size: 15, color: f.esp.contains(e) ? ink : sportColors(e).$2)),
              ),
          ]),
        ),
        Expanded(child: loading ? const _Skeleton() : _deck(context)),
      ] else
        Expanded(child: _saved(context)),
    ]);
  }

  Widget _deck(BuildContext context) {
    final dk = app.deck;
    final top = dk.firstOrNull;
    final f = app.filters;
    final p = (dx.abs() / 120).clamp(0.0, 1.0);
    if (top == null) {
      return EmptyState(
        Icons.style,
        'Viste a todos',
        app.saved.isEmpty ? 'Ajusta los filtros o vuelve a empezar para ver de nuevo a los coaches.' : 'Ya viste a todos. Revisa tus guardados o prueba otro filtro.',
        action: Column(mainAxisSize: MainAxisSize.min, children: [
          Btn('Volver a empezar', app.resetDeck, icon: Icons.refresh),
          const SizedBox(height: 14),
          Wrap(spacing: 8, runSpacing: 8, alignment: WrapAlignment.center, children: [
            if (f.mod != 'Online') Pill('Prueba Online', false, () => app.applyFilters(Filters([], 'Online')), leading: const Icon(Icons.wifi, size: 15, color: cyan)),
            if (app.saved.isNotEmpty) Pill('Ver guardados', false, () => setState(() => sub = 1), leading: const Icon(Icons.bookmark, size: 15, color: amber)),
            if (f.count > 0) Pill('Quitar filtros', false, () => app.applyFilters(Filters())),
          ]),
        ]),
      );
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      child: Stack(children: [
        for (final (i, c) in dk.skip(1).take(2).toList().indexed.toList().reversed)
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 92),
              child: AnimatedContainer(
                duration: dragging ? Duration.zero : const Duration(milliseconds: 300),
                transform: Matrix4.translationValues(0, (i + 1 - p) * 14, 0)..multiply(Matrix4.diagonal3Values(1 - (i + 1 - p) * .05, 1 - (i + 1 - p) * .05, 1)),
                transformAlignment: Alignment.center,
                child: _CoachCard(c),
              ),
            ),
          ),
        Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 92),
            child: GestureDetector(
              onPanStart: (_) {
                if (fly == null) setState(() => dragging = true);
              },
              onPanUpdate: (d) {
                if (fly == null) {
                  setState(() {
                    dx += d.delta.dx;
                    dy += d.delta.dy;
                  });
                }
              },
              onPanEnd: (_) => onEnd(),
              onTap: () => openProfile(top),
              child: AnimatedContainer(
                duration: dragging ? Duration.zero : const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                transform: Matrix4.translationValues(dx, dy, 0)..rotateZ(dx / 18 * 3.1416 / 180),
                transformAlignment: Alignment.center,
                child: Stack(children: [
                  _CoachCard(top),
                  Positioned(top: 26, left: 20, child: Transform.rotate(angle: -.2, child: _stamp('ESCRIBIR', lime, ink, (dx / 90).clamp(0.0, 1.0)))),
                  Positioned(top: 26, right: 20, child: Transform.rotate(angle: .2, child: _stamp('PASAR', danger, ink, (-dx / 90).clamp(0.0, 1.0)))),
                  Positioned(top: 26, left: 0, right: 0, child: Center(child: _stamp('VER PERFIL', cyan, ink, dx.abs() < 60 ? (-dy / 90).clamp(0.0, 1.0) : 0))),
                ]),
              ),
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 14,
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            _circle(Icons.close_rounded, surface, danger, () => swipe('left'), border: true),
            const SizedBox(width: 18),
            _circle(Icons.bookmark_rounded, surface, amber, () => swipe('up'), size: 52, border: true),
            const SizedBox(width: 18),
            _circle(Icons.send_rounded, lime, ink, () => swipe('right'), size: 72, glow: true),
          ]),
        ),
      ]),
    );
  }

  Widget _saved(BuildContext context) {
    final list = app.saved;
    if (list.isEmpty) {
      return EmptyState(Icons.bookmark_border, 'Sin guardados', 'Toca el marcador en una tarjeta para guardar un coach y decidir después.', action: Btn('Explorar coaches', () => setState(() => sub = 0), icon: Icons.style));
    }
    return ListView(padding: const EdgeInsets.fromLTRB(20, 4, 20, 20), children: [
      for (final (i, c) in list.indexed)
        Reveal(
          i,
          Tap(
            scale: .98,
            onTap: () => openCoachProfile(context, c.id),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              clipBehavior: Clip.antiAlias,
              decoration: box(),
              child: Column(children: [
                HeroBg(c.especialidad, height: 74),
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Expanded(child: Text(c.nombre.toUpperCase(), style: hd(24, italic: true))),
                      if (c.precioDesde != null) Text('¤ ${c.precioDesde}', style: hd(24, c: lime, italic: true)),
                    ]),
                    const SizedBox(height: 4),
                    Row(children: [Text('${c.especialidad} · ${c.modalidad}', style: ts(13, c: muted, w: FontWeight.w600)), const SizedBox(width: 10), ratingSummary(c.id, size: 13)]),
                    const SizedBox(height: 12),
                    Row(children: [
                      Expanded(child: Btn('Preguntar planes', () => openChat(context, app.contact(c.id)!.id), icon: Icons.send_rounded, height: 44)),
                      const SizedBox(width: 10),
                      RoundBtn(Icons.bookmark_remove_outlined, () => app.toggleSave(c.id), size: 44, fg: amber),
                    ]),
                  ]),
                ),
              ]),
            ),
          ),
        ),
    ]);
  }

  Widget _circle(IconData i, Color bg, Color fg, VoidCallback t, {double size = 60, bool border = false, bool glow = false}) => Tap(
        onTap: t,
        scale: .88,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: bg,
            shape: BoxShape.circle,
            border: border ? Border.all(color: line, width: 1.5) : null,
            boxShadow: [BoxShadow(color: (glow ? lime : Colors.black).withValues(alpha: glow ? .4 : .35), blurRadius: glow ? 22 : 14, offset: const Offset(0, 6))],
          ),
          child: Icon(i, size: size * .46, color: fg),
        ),
      );

  Widget _stamp(String t, Color c, Color fg, double o) => Opacity(
        opacity: o,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(r8)),
          child: Text(t, style: hd(22, c: fg, italic: true, ls: 1)),
        ),
      );
}

/// Marcador de carga con la forma de la tarjeta.
class _Skeleton extends StatelessWidget {
  const _Skeleton();
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 92),
        child: Column(children: [
          const Expanded(child: Pulse(width: double.infinity, radius: r28)),
          const SizedBox(height: 14),
          Row(children: const [Expanded(child: Pulse(height: 18)), SizedBox(width: 60), Pulse(width: 60, height: 18)]),
        ]),
      );
}

class _CoachCard extends StatelessWidget {
  final Coach c;
  const _CoachCard(this.c);
  @override
  Widget build(BuildContext context) {
    final (_, accent) = sportColors(c.especialidad);
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(r28), border: Border.all(color: line), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .4), blurRadius: 24, offset: const Offset(0, 10))]),
      child: Stack(children: [
        Positioned.fill(child: HeroBg(c.especialidad)),
        // Etiquetas superiores
        Positioned(
          top: 18,
          left: 18,
          right: 18,
          child: Wrap(spacing: 6, runSpacing: 6, children: [
            if (c.verificado) const Tag('Verificado', bg: cyan, fg: ink, icon: Icons.verified),
            if (c.disponible) const Tag('Disponible', bg: lime, fg: ink, icon: Icons.circle) else const Tag('Lista de espera', icon: Icons.schedule),
            Tag(c.modalidad, bg: Colors.black.withValues(alpha: .35), icon: c.modalidad == 'Online' ? Icons.wifi : Icons.place),
          ]),
        ),
        // Avatar
        Positioned(top: 64, left: 0, right: 0, child: Center(child: Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: accent.withValues(alpha: .5), width: 2)), child: Avatar(c.ini, size: 92, tone: c.tone)))),
        // Información
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 56, 20, 20),
            decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [bg.withValues(alpha: 0), bg.withValues(alpha: .92), bg])),
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [Icon(sportIcon(c.especialidad), size: 15, color: accent), const SizedBox(width: 6), Text('${c.especialidad} · ${c.exp} años'.toUpperCase(), style: ts(11, c: accent, w: FontWeight.w800, ls: 1))]),
              const SizedBox(height: 6),
              Text(c.nombre.toUpperCase(), style: hd(40, italic: true)),
              const SizedBox(height: 8),
              Text(c.resumen, style: ts(13.5, c: text.withValues(alpha: .85), h: 1.4), maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 12),
              Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Expanded(child: ratingSummary(c.id)),
                if (c.precioDesde != null)
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Text('DESDE', style: ts(9.5, c: muted, w: FontWeight.w800, ls: 1)),
                    Text.rich(TextSpan(children: [TextSpan(text: '¤ ${c.precioDesde}', style: hd(30, c: lime, italic: true)), TextSpan(text: ' /mes', style: ts(11, c: muted, w: FontWeight.w600))])),
                  ]),
              ]),
              const SizedBox(height: 12),
              Wrap(spacing: 6, runSpacing: 6, children: [
                if (c.pruebaPrecio != null) Tag(c.pruebaTxt, bg: limeTint, fg: lime, icon: Icons.local_activity_outlined),
                for (final t in c.tags.take(c.pruebaPrecio != null ? 2 : 3)) Tag(t, bg: Colors.white.withValues(alpha: .08)),
              ]),
            ]),
          ),
        ),
      ]),
    );
  }
}

class _FilterSheet extends StatefulWidget {
  const _FilterSheet();
  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late Filters d = app.filters.copy();
  @override
  Widget build(BuildContext context) {
    final n = coaches.where(d.matches).length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        sheetHandle(),
        Row(children: [
          Expanded(child: Text('FILTROS', style: hd(28, italic: true))),
          TextButton(onPressed: () => setState(() => d = Filters()), child: const Text('Limpiar')),
        ]),
        label('Especialidad'),
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final e in especialidades)
            Pill(e, d.esp.contains(e), () => setState(() => d.esp.contains(e) ? d.esp.remove(e) : d.esp.add(e)), leading: Icon(sportIcon(e), size: 15, color: d.esp.contains(e) ? ink : sportColors(e).$2)),
        ]),
        label('Modalidad'),
        Seg([for (final m in ['Todas', 'Presencial', 'Online']) (m, m)], d.mod, (v) => setState(() => d.mod = v)),
        label('Confianza'),
        Wrap(spacing: 8, runSpacing: 8, children: [
          Pill('Solo verificados', d.verificados, () => setState(() => d.verificados = !d.verificados), leading: Icon(Icons.verified, size: 15, color: d.verificados ? ink : cyan)),
          Pill('Con clase de prueba', d.prueba, () => setState(() => d.prueba = !d.prueba), leading: Icon(Icons.local_activity_outlined, size: 15, color: d.prueba ? ink : lime)),
        ]),
        const SizedBox(height: 12),
        Text('$n ${n == 1 ? 'coach coincide' : 'coaches coinciden'}', style: ts(13, c: muted)),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: Btn('Aplicar filtros', () {
            app.applyFilters(d);
            Navigator.pop(context);
            toast(context, 'Filtros aplicados');
          }),
        ),
      ]),
    );
  }
}
