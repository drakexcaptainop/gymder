import 'dart:async';
import 'package:flutter/material.dart';
import '../data.dart';
import '../state.dart';
import '../ui.dart';
import 'flows.dart';

class DescubrirTab extends StatefulWidget {
  const DescubrirTab({super.key});
  @override
  State<DescubrirTab> createState() => _DescubrirTabState();
}

class _DescubrirTabState extends State<DescubrirTab> {
  double dx = 0, dy = 0;
  bool dragging = false;
  String? fly;

  void swipe(String dir) {
    final top = app.deck.firstOrNull;
    if (top == null || fly != null) return;
    setState(() {
      dragging = false;
      fly = dir;
      dx = dir == 'right' ? 520 : -520;
      dy = 40;
    });
    Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      app.markSeen(top.id, fav: dir == 'right');
      setState(() {
        dx = 0;
        dy = 0;
        fly = null;
      });
      if (dir == 'right') toast(context, '${top.nombre} guardado en favoritos');
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
    final dk = app.deck;
    final top = dk.firstOrNull;
    final f = app.filters;
    final p = (dx.abs() / 120).clamp(0.0, 1.0);
    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 16, 8),
        child: Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Encuentra a tu coach', style: ts(13, c: slate, w: FontWeight.w500)),
              Text('Descubrir', style: ts(30, w: FontWeight.w600)),
            ]),
          ),
          Stack(clipBehavior: Clip.none, children: [
            RoundBtn(Icons.tune, () => _filters(context)),
            if (f.count > 0) Positioned(right: -4, top: -4, child: _badge('${f.count}', cyan)),
          ]),
          const SizedBox(width: 8),
          Stack(clipBehavior: Clip.none, children: [
            RoundBtn(Icons.favorite_border, () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const FavoritosScreen()))),
            if (app.favs.isNotEmpty) Positioned(right: -4, top: -4, child: _badge('${app.favs.length}', lime)),
          ]),
        ]),
      ),
      if (f.count > 0)
        SizedBox(
          height: 36,
          child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16), children: [
            for (final l in [...f.esp, if (f.mod != 'Todas') f.mod]) Padding(padding: const EdgeInsets.only(right: 8), child: Pill(l, true, () {})),
            TextButton(onPressed: () => app.applyFilters(Filters()), child: const Text('Limpiar')),
          ]),
        ),
      Expanded(
        child: top == null
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.style_outlined, size: 48, color: slate),
                    const SizedBox(height: 12),
                    Text('Ya viste a todos los coaches', style: ts(18, w: FontWeight.w600)),
                    const SizedBox(height: 6),
                    Text('Ajusta los filtros o vuelve a empezar.', style: ts(14, c: slate)),
                    const SizedBox(height: 16),
                    Btn('Volver a empezar', () {
                      app.seen.clear();
                      app.notify();
                    }, bg: lime, fg: navy),
                    if (f.count > 0) TextButton(onPressed: () => app.applyFilters(Filters()), child: const Text('Quitar filtros')),
                  ]),
                ),
              )
            : Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: Stack(children: [
                  for (final (i, c) in dk.skip(1).take(2).toList().indexed.toList().reversed)
                    Positioned.fill(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 90),
                        child: AnimatedContainer(
                          duration: dragging ? Duration.zero : const Duration(milliseconds: 300),
                          transform: Matrix4.translationValues(0, (i + 1 - p) * 14, 0)
                            ..multiply(Matrix4.diagonal3Values(1 - (i + 1 - p) * .05, 1 - (i + 1 - p) * .05, 1)),
                          transformAlignment: Alignment.center,
                          child: _CoachCard(c),
                        ),
                      ),
                    ),
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 90),
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
                          transform: Matrix4.translationValues(dx, dy, 0)
                            ..rotateZ(dx / 18 * 3.1416 / 180),
                          transformAlignment: Alignment.center,
                          child: Stack(children: [
                            _CoachCard(top),
                            Positioned(top: 24, left: 20, child: _stamp('GUARDAR', lime, (dx / 90).clamp(0.0, 1.0))),
                            Positioned(top: 24, right: 20, child: _stamp('PASAR', slate, (-dx / 90).clamp(0.0, 1.0))),
                            Positioned(top: 24, left: 0, right: 0, child: Center(child: _stamp('VER PERFIL', cyan, dx.abs() < 60 ? (-dy / 90).clamp(0.0, 1.0) : 0))),
                          ]),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 12,
                    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      _circle(Icons.close, white, navy, () => swipe('left'), border: true),
                      const SizedBox(width: 20),
                      _circle(Icons.arrow_upward, cyan, navy, () => openProfile(top), size: 52),
                      const SizedBox(width: 20),
                      _circle(Icons.favorite, lime, navy, () => swipe('right')),
                    ]),
                  ),
                ]),
              ),
      ),
    ]);
  }

  Widget _badge(String t, Color bg) => Container(
        width: 20,
        height: 20,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
        child: Text(t, style: ts(11, w: FontWeight.w700)),
      );

  Widget _circle(IconData i, Color bg, Color fg, VoidCallback t, {double size = 64, bool border = false}) => GestureDetector(
        onTap: t,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(color: bg, shape: BoxShape.circle, border: border ? Border.all(color: soft, width: 2) : null, boxShadow: [BoxShadow(color: navy.withValues(alpha: .12), blurRadius: 12, offset: const Offset(0, 4))]),
          child: Icon(i, size: 28, color: fg),
        ),
      );

  Widget _stamp(String t, Color c, double o) => Opacity(
        opacity: o,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(10)),
          child: Text(t, style: ts(14, w: FontWeight.w700, c: c == slate ? white : navy)),
        ),
      );

  void _filters(BuildContext context) => showSheet(context, (_) => const _FilterSheet());
}

class _CoachCard extends StatelessWidget {
  final Coach c;
  const _CoachCard(this.c);
  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: soft),
          boxShadow: [BoxShadow(color: navy.withValues(alpha: .10), blurRadius: 24, offset: const Offset(0, 10))],
        ),
        child: Column(children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(color: navy, borderRadius: BorderRadius.vertical(top: Radius.circular(23))),
              child: Center(child: Container(width: 120, height: 120, alignment: Alignment.center, decoration: BoxDecoration(color: lime, borderRadius: BorderRadius.circular(40)), child: Text(c.ini, style: ts(44, w: FontWeight.w700)))),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(c.nombre, style: ts(22, w: FontWeight.w600)),
              const SizedBox(height: 4),
              Text('${c.especialidad} · ${c.modalidad} · ${c.exp} años de experiencia', style: ts(13, c: slate, w: FontWeight.w500)),
              const SizedBox(height: 8),
              Text(c.resumen, style: ts(14, h: 1.4)),
              const SizedBox(height: 10),
              Wrap(spacing: 6, runSpacing: 6, children: [for (final t in c.tags) Tag(t)]),
            ]),
          ),
        ]),
      );
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
    final n = coaches.where((c) => (d.esp.isEmpty || d.esp.contains(c.especialidad)) && (d.mod == 'Todas' || c.modalidad == d.mod)).length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        sheetHandle(),
        Row(children: [
          Expanded(child: Text('Filtros', style: ts(20, w: FontWeight.w600))),
          TextButton(onPressed: () => setState(() => d = Filters()), child: const Text('Limpiar')),
        ]),
        label('Especialidad'),
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final e in especialidades)
            Pill(e, d.esp.contains(e), () => setState(() => d.esp.contains(e) ? d.esp.remove(e) : d.esp.add(e))),
        ]),
        label('Modalidad'),
        Seg([for (final m in ['Todas', 'Presencial', 'Online']) (m, m)], d.mod, (v) => setState(() => d.mod = v)),
        const SizedBox(height: 10),
        Text('$n ${n == 1 ? 'coach coincide' : 'coaches coinciden'}', style: ts(13, c: slate)),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: Btn('Aplicar filtros', () {
            app.applyFilters(d);
            Navigator.pop(context);
            toast(context, 'Filtros aplicados');
          }, bg: lime, fg: navy),
        ),
      ]),
    );
  }
}
