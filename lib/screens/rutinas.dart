import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../data.dart';
import '../state.dart';
import '../ui.dart';

class RutinasTab extends StatelessWidget {
  const RutinasTab({super.key});
  @override
  Widget build(BuildContext context) => ListenableBuilder(listenable: app, builder: (c, _) => _body(c));

  Widget _body(BuildContext context) {
    final list = exercises.where((e) => app.muscle == 'Todos' || e.grupo == app.muscle).toList();
    void open(ExCfg? cfg, String id) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ExerciseDetail(exId: id, cfg: cfg)));
    return ListView(padding: const EdgeInsets.only(bottom: 24), children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(app.activeCoach == null ? 'Biblioteca' : 'Asignada por ${app.activeCoach!.nombre}', style: ts(13, c: slate, w: FontWeight.w500)),
          Text('Rutinas', style: ts(30, w: FontWeight.w600)),
        ]),
      ),
      if (app.paid) ...[
        Padding(padding: const EdgeInsets.fromLTRB(20, 0, 20, 8), child: Text('Tu rutina', style: ts(18, w: FontWeight.w600))),
        for (final cfg in app.routineList)
          Builder(builder: (_) {
            final e = app.exGet(cfg.exId)!;
            final pv = e.vars.firstWhere((v) => v.id == cfg.principal);
            return GestureDetector(
              onTap: () => open(cfg, cfg.exId),
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                padding: const EdgeInsets.all(14),
                decoration: box(),
                child: Row(children: [
                  IconTile(eqIcon(pv.eq)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(pv.nombre, style: ts(15, w: FontWeight.w600)),
                      Text('${cfg.series} × ${cfg.reps}${cfg.unit == 's' ? ' s' : ''}', style: ts(13, c: slate)),
                    ]),
                  ),
                  const Icon(Icons.chevron_right, color: slate),
                ]),
              ),
            );
          }),
      ] else
        Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          padding: const EdgeInsets.all(16),
          decoration: box(bg: soft.withValues(alpha: .5)),
          child: Row(children: [
            const Icon(Icons.lock_outline, color: slate),
            const SizedBox(width: 12),
            Expanded(child: Text('Tu rutina asignada aparecerá aquí cuando contrates un paquete con un coach.', style: ts(13, c: slate, h: 1.4))),
            TextButton(onPressed: () => app.setTab(3), child: const Text('Explorar')),
          ]),
        ),
      Padding(padding: const EdgeInsets.fromLTRB(20, 12, 20, 8), child: Text('Biblioteca de ejercicios', style: ts(18, w: FontWeight.w600))),
      SizedBox(
        height: 36,
        child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16), children: [
          for (final m in muscles)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Pill(m, app.muscle == m, () {
                app.muscle = m;
                app.notify();
              }),
            ),
        ]),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
        child: Text('${list.length} ${list.length == 1 ? 'ejercicio' : 'ejercicios'}${app.muscle == 'Todos' ? '' : ' · ${app.muscle}'}', style: ts(12, c: slate)),
      ),
      for (final e in list)
        GestureDetector(
          onTap: () => open(null, e.id),
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            padding: const EdgeInsets.all(14),
            decoration: box(),
            child: Row(children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(e.nombre, style: ts(15, w: FontWeight.w600)),
                  Text('${e.grupo} · ${e.vars.length} ${e.vars.length == 1 ? 'variante' : 'variantes'}', style: ts(12, c: slate)),
                ]),
              ),
              if (e.video) const Tag('Video'),
              const SizedBox(width: 4),
              if (e.d3) const Tag('3D'),
            ]),
          ),
        ),
    ]);
  }
}

// ───────────────────────── Exercise detail ─────────────────────────
class ExerciseDetail extends StatefulWidget {
  final String exId;
  final ExCfg? cfg;
  const ExerciseDetail({super.key, required this.exId, this.cfg});
  @override
  State<ExerciseDetail> createState() => _ExerciseDetailState();
}

class _ExerciseDetailState extends State<ExerciseDetail> {
  late final Ex ex = app.exGet(widget.exId)!;
  late String curVar = widget.cfg?.principal ?? ex.vars.first.id;
  late String mode;
  bool altOpen = false, playing = false;
  double vidT = 0, ry = -32, rx = -18, zoom = 1;
  Timer? timer;

  String get fmt => widget.cfg?.fmt ?? 'ambos';
  bool get allowV => ex.video && (fmt == 'video' || fmt == 'ambos');
  bool get allow3 => ex.d3 && (fmt == '3d' || fmt == 'ambos');
  String get prId => widget.cfg?.principal ?? ex.vars.first.id;
  List<String> get altIds => widget.cfg?.alts ?? ex.vars.skip(1).map((v) => v.id).toList();

  @override
  void initState() {
    super.initState();
    mode = allowV ? 'video' : allow3 ? '3d' : 'none';
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void stop() {
    timer?.cancel();
    playing = false;
  }

  void toggle() {
    if (playing) return setState(stop);
    setState(() {
      playing = true;
      if (vidT >= 45) vidT = 0;
    });
    timer = Timer.periodic(const Duration(milliseconds: 250), (_) {
      setState(() {
        vidT += .25;
        if (vidT >= 45) {
          vidT = 45;
          stop();
        }
      });
    });
  }

  void pickVar(String id) => setState(() {
        stop();
        curVar = id;
        vidT = 0;
        ry = -32;
        rx = -18;
        zoom = 1;
      });

  @override
  Widget build(BuildContext context) {
    final cur = ex.vars.firstWhere((v) => v.id == curVar);
    final cfg = widget.cfg;
    final isVideo = mode == 'video' && allowV, is3d = mode == '3d' && allow3;
    final rows = [prId, ...altIds].map((id) => ex.vars.where((v) => v.id == id).firstOrNull).whereType<ExVar>().toList();
    final fmtLabel = fmt == 'video' ? 'Video' : fmt == '3d' ? '3D' : fmt == 'ninguno' ? 'Sin demostración' : [if (ex.video) 'Video', if (ex.d3) '3D'].join(' y ');
    final vt = vidT.floor();

    return SubScreen(
      title: cur.nombre,
      subtitle: '${ex.grupo} · ${eqNames[cur.eq]}',
      child: ListView(padding: const EdgeInsets.fromLTRB(16, 4, 16, 24), children: [
        Seg<String>([('video', 'Video'), ('3d', '3D')], mode, (v) => setState(() {
              stop();
              mode = v;
            }), enabled: (m) => m == 'video' ? allowV : allow3),
        const SizedBox(height: 12),
        if (isVideo) _video(cur, vt) else if (is3d) _viewer3d(cur) else
          Container(
            height: 180,
            alignment: Alignment.center,
            decoration: box(bg: soft.withValues(alpha: .5)),
            child: Text('Este ejercicio no tiene demostración asignada.', style: ts(14, c: slate)),
          ),
        const SizedBox(height: 6),
        Text('Formato: $fmtLabel', style: ts(12, c: slate)),
        if (cfg != null) ...[
          label('Tu plan'),
          Container(
            decoration: box(),
            child: Column(children: [
              for (final (i, r) in [('Series y repeticiones', '${cfg.series} × ${cfg.reps}${cfg.unit == 's' ? ' s' : ''}'), ('Descanso', '${cfg.descanso} s')].indexed)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(border: i == 0 ? const Border(bottom: BorderSide(color: soft)) : null),
                  child: Row(children: [Expanded(child: Text(r.$1, style: ts(14, c: slate))), Text(r.$2, style: ts(15, w: FontWeight.w600))]),
                ),
            ]),
          ),
        ],
        label('Equipo'),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: box(bd: cyan, bw: 2),
          child: Row(children: [
            IconTile(eqIcon(cur.eq)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(cur.nombre, style: ts(15, w: FontWeight.w600)),
                Text(eqNames[cur.eq]!, style: ts(12, c: slate)),
              ]),
            ),
            Tag(cur.id == prId ? 'Variante principal' : 'Alternativa en uso', bg: cur.id == prId ? lime : cyanTint),
          ]),
        ),
        if (cur.id != prId) TextButton(onPressed: () => pickVar(prId), child: const Text('Volver a la variante principal')),
        if (altIds.isNotEmpty) ...[
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () => setState(() => altOpen = !altOpen),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: box(),
              child: Row(children: [
                const Icon(Icons.swap_horiz, size: 20),
                const SizedBox(width: 10),
                Expanded(child: Text('${altIds.length} ${altIds.length == 1 ? 'alternativa' : 'alternativas'} de equipo', style: ts(15, w: FontWeight.w600))),
                Icon(altOpen ? Icons.expand_less : Icons.expand_more, color: slate),
              ]),
            ),
          ),
          if (altOpen)
            for (final v in rows)
              GestureDetector(
                onTap: () => pickVar(v.id),
                child: Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: box(bg: v.id == curVar ? cyanFaint : white, bd: v.id == curVar ? cyan : soft, bw: v.id == curVar ? 2 : 1, r: 14),
                  child: Row(children: [
                    Icon(eqIcon(v.eq), size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(v.nombre, style: ts(14, w: FontWeight.w600)),
                        Text('Equipo: ${eqNames[v.eq]}', style: ts(12, c: slate)),
                      ]),
                    ),
                    Tag(v.id == prId ? 'Principal' : 'Alternativa', bg: v.id == prId ? lime : cyanTint),
                  ]),
                ),
              ),
        ],
        label('Cómo hacerlo'),
        for (final (i, t) in exSteps.indexed)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(width: 26, height: 26, alignment: Alignment.center, decoration: const BoxDecoration(color: lime, shape: BoxShape.circle), child: Text('${i + 1}', style: ts(13, w: FontWeight.w600))),
              const SizedBox(width: 12),
              Expanded(child: Text(t, style: ts(14, h: 1.45))),
            ]),
          ),
      ]),
    );
  }

  Widget _video(ExVar cur, int vt) => Container(
        height: 220,
        decoration: BoxDecoration(color: navy, borderRadius: BorderRadius.circular(16)),
        child: Column(children: [
          Expanded(
            child: GestureDetector(
              onTap: toggle,
              child: Stack(alignment: Alignment.center, children: [
                Positioned(top: 12, left: 14, right: 14, child: Text('VIDEO · ${cur.nombre.toUpperCase()}', style: ts(11, w: FontWeight.w600, c: soft), maxLines: 1, overflow: TextOverflow.ellipsis)),
                Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(color: lime, shape: BoxShape.circle),
                  child: Icon(playing ? Icons.pause : Icons.play_arrow, size: 30, color: navy),
                ),
              ]),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
            child: Row(children: [
              Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: vidT / 45, minHeight: 4, color: lime, backgroundColor: Colors.white24))),
              const SizedBox(width: 10),
              Text('0:${vt.toString().padLeft(2, '0')} / 0:45', style: ts(12, c: soft)),
            ]),
          ),
        ]),
      );

  Widget _viewer3d(ExVar cur) => Column(children: [
        GestureDetector(
          onPanUpdate: (d) => setState(() {
            ry += d.delta.dx * .6;
            rx = (rx - d.delta.dy * .4).clamp(-70, 20).toDouble();
          }),
          child: Container(
            height: 240,
            width: double.infinity,
            decoration: BoxDecoration(color: navy, borderRadius: BorderRadius.circular(16)),
            child: Stack(children: [
              Positioned.fill(child: CustomPaint(painter: _CubePainter(rx, ry, zoom))),
              Positioned(top: 12, left: 14, child: Text(eqNames[cur.eq]!.toUpperCase(), style: ts(11, w: FontWeight.w600, c: soft))),
              Positioned(bottom: 10, left: 14, child: Text('Arrastra para girar', style: ts(11, c: soft))),
            ]),
          ),
        ),
        const SizedBox(height: 10),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          RoundBtn(Icons.rotate_left, () => setState(() => ry -= 45)),
          const SizedBox(width: 8),
          RoundBtn(Icons.rotate_right, () => setState(() => ry += 45)),
          const SizedBox(width: 8),
          RoundBtn(Icons.remove, () => setState(() => zoom = math.max(.6, zoom - .15))),
          const SizedBox(width: 8),
          RoundBtn(Icons.add, () => setState(() => zoom = math.min(1.6, zoom + .15))),
          const SizedBox(width: 8),
          RoundBtn(Icons.refresh, () => setState(() {
                ry = -32;
                rx = -18;
                zoom = 1;
              })),
        ]),
      ]);
}

/// Minimal software-projected cube used as a placeholder 3D model.
class _CubePainter extends CustomPainter {
  final double rx, ry, zoom;
  _CubePainter(this.rx, this.ry, this.zoom);

  @override
  void paint(Canvas canvas, Size size) {
    final a = rx * math.pi / 180, b = ry * math.pi / 180;
    final s = 60.0 * zoom;
    final verts = <List<double>>[
      for (final x in [-1, 1]) for (final y in [-1, 1]) for (final z in [-1, 1]) [x.toDouble(), y.toDouble(), z.toDouble()],
    ];
    List<double> rot(List<double> v) {
      var x = v[0] * math.cos(b) + v[2] * math.sin(b);
      var z = -v[0] * math.sin(b) + v[2] * math.cos(b);
      final y = v[1] * math.cos(a) - z * math.sin(a);
      z = v[1] * math.sin(a) + z * math.cos(a);
      return [x, y, z];
    }

    final r = verts.map(rot).toList();
    Offset p(int i) => Offset(size.width / 2 + r[i][0] * s, size.height / 2 + r[i][1] * s);
    // vertex index = x*4 + y*2 + z (with -1→0, 1→1)
    const faces = [
      [0, 1, 3, 2], [4, 5, 7, 6], [0, 1, 5, 4], [2, 3, 7, 6], [0, 2, 6, 4], [1, 3, 7, 5],
    ];
    final order = List.generate(6, (i) => i)..sort((i, j) => _depth(r, faces[j]).compareTo(_depth(r, faces[i])));
    for (final i in order) {
      final f = faces[i];
      final path = Path()..moveTo(p(f[0]).dx, p(f[0]).dy);
      for (final k in f.skip(1)) {
        path.lineTo(p(k).dx, p(k).dy);
      }
      path.close();
      canvas.drawPath(path, Paint()..color = Color.lerp(cyan, lime, i / 5)!.withValues(alpha: .55));
      canvas.drawPath(path, Paint()..style = PaintingStyle.stroke..strokeWidth = 2..color = white);
    }
  }

  double _depth(List<List<double>> r, List<int> f) => f.map((i) => r[i][2]).reduce((a, b) => a + b) / 4;

  @override
  bool shouldRepaint(_CubePainter o) => o.rx != rx || o.ry != ry || o.zoom != zoom;
}
