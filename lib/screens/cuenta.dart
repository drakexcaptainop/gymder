import 'package:flutter/material.dart';
import '../core_data.dart';
import '../state.dart';
import '../ui.dart';
import 'agenda.dart';
import 'ajustes.dart';
import 'perfiles.dart';

class CuentaTab extends StatelessWidget {
  const CuentaTab({super.key});

  /// Avance del perfil: (porcentaje 0..1, pasos pendientes, acción al tocar).
  (double, List<String>, VoidCallback) _progress(BuildContext context) {
    bool ok(String s) => s.trim().isNotEmpty && s != 'Por definir';
    if (app.isCoach) {
      final c = app.meCoach!;
      final steps = <(String, bool)>[
        ('Bio', !c.bio.startsWith('Completa')),
        ('Lugar', ok(c.lugar)),
        ('Enfoque', c.enfoque != 'Por definir con cada alumno.'),
        ('Planes y precios', c.planes.isNotEmpty),
        ('Horarios', c.horarios.isNotEmpty),
        ('Verificación', c.verificado),
      ];
      final done = steps.where((s) => s.$2).length;
      return (done / steps.length, [for (final s in steps) if (!s.$2) s.$1], () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PlanesEditorScreen())));
    }
    final u = app.me!;
    final steps = <(String, bool)>[('Objetivo', ok(u.objetivo)), ('Disponibilidad', ok(u.disponibilidad)), ('Notas', ok(u.notas))];
    final done = steps.where((s) => s.$2).length;
    return (done / steps.length, [for (final s in steps) if (!s.$2) s.$1], () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const EditarPerfilScreen())));
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: app,
        builder: (context, _) {
          final s = app.session!;
          final coach = app.isCoach;
          final name = app.myName;
          final ini = coach ? app.meCoach!.ini : app.me!.ini;
          final (pct, missing, goProgress) = _progress(context);
          final myChats = app.myChats;
          final rating = coach ? app.ratingOf(s.profileId) : null;
          return ListView(padding: const EdgeInsets.fromLTRB(16, 0, 16, 24), children: [
            const ScreenHeader('Tu información', 'Cuenta'),
            // ── Tarjeta de perfil
            Reveal(
              0,
              Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(r28), border: Border.all(color: line)),
                child: HeroBg(
                  coach ? app.meCoach!.especialidad : '',
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Row(children: [
                      Container(padding: const EdgeInsets.all(3), decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: lime.withValues(alpha: .6), width: 2)), child: Avatar(ini, size: 68, tone: app.myTone)),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(name.toUpperCase(), style: hd(30, italic: true), maxLines: 1, overflow: TextOverflow.ellipsis),
                          Text(s.email, style: ts(12.5, c: text.withValues(alpha: .75)), maxLines: 1, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 8),
                          Wrap(spacing: 6, runSpacing: 6, children: [
                            Tag(coach ? 'Entrenador' : 'Usuario', bg: lime, fg: ink),
                            if (coach) Tag(app.meCoach!.especialidad, bg: Colors.black.withValues(alpha: .35), icon: sportIcon(app.meCoach!.especialidad)) else Tag(app.me!.nivel, bg: Colors.black.withValues(alpha: .35), icon: Icons.trending_up),
                          ]),
                        ]),
                      ),
                    ]),
                  ),
                ),
              ),
            ),
            // ── Progreso del perfil
            if (pct < 1) ...[
              const SizedBox(height: 12),
              Reveal(
                1,
                Tap(
                  scale: .98,
                  onTap: goProgress,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: box(bg: limeTint, bd: lime.withValues(alpha: .4)),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Expanded(child: Text('COMPLETA TU PERFIL', style: hd(22, italic: true))),
                        Text('${(pct * 100).round()}%', style: hd(24, c: lime, italic: true)),
                      ]),
                      const SizedBox(height: 10),
                      ClipRRect(borderRadius: BorderRadius.circular(6), child: LinearProgressIndicator(value: pct, minHeight: 8, backgroundColor: surface2, color: lime)),
                      const SizedBox(height: 10),
                      Row(children: [
                        Expanded(child: Text('Falta: ${missing.join(', ')}', style: ts(12.5, c: muted))),
                        const Icon(Icons.arrow_forward_rounded, size: 18, color: lime),
                      ]),
                    ]),
                  ),
                ),
              ),
            ],
            // ── Resumen
            const SizedBox(height: 12),
            Reveal(
              2,
              Row(children: [
                if (coach) ...[
                  Expanded(child: StatTile('${app.pendingCount}', 'por responder', Icons.mark_chat_unread_outlined, accent: cyan)),
                  const SizedBox(width: 10),
                  Expanded(child: StatTile(rating == null ? '—' : rating.toStringAsFixed(1), '${app.reviewsOf(s.profileId).length} reseñas', Icons.star_rounded, accent: amber)),
                  const SizedBox(width: 10),
                  Expanded(child: StatTile('${app.meCoach!.planes.length}', 'planes activos', Icons.sell_outlined)),
                ] else ...[
                  Expanded(child: StatTile('${myChats.length}', 'chats', Icons.chat_bubble_outline, accent: cyan)),
                  const SizedBox(width: 10),
                  Expanded(child: StatTile('${app.saved.length}', 'guardados', Icons.bookmark_outline, accent: amber)),
                  const SizedBox(width: 10),
                  Expanded(child: StatTile('${myChats.where((r) => r.agreed).length}', 'planes acordados', Icons.verified_outlined)),
                ],
              ]),
            ),
            // ── Perfil
            label('Perfil'),
            _group([
              _item(Icons.person_outline, coach ? 'Mi perfil de entrenador' : 'Mi perfil', () => coach ? openCoachProfile(context, s.profileId) : openUserProfile(context, s.profileId)),
              if (coach) _item(Icons.sell_outlined, 'Mis planes y precios', () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PlanesEditorScreen()))),
              if (coach) _item(Icons.local_activity_outlined, app.meCoach!.pruebaPrecio == null ? 'Clase de prueba (desactivada)' : 'Clase de prueba (${app.meCoach!.pruebaTxt})', () => openPruebaSheet(context)),
              if (coach) _item(Icons.verified_outlined, app.meCoach!.verificado ? 'Verificación (verificado)' : 'Verificación y credenciales', () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CredencialesScreen()))),
              if (!coach) _item(Icons.edit_outlined, 'Editar perfil', () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const EditarPerfilScreen()))),
              _item(Icons.palette_outlined, 'Foto de perfil', () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const FotoPerfilScreen()))),
            ]),
            // ── Ajustes y ayuda
            label('Ajustes y ayuda'),
            _group([
              _item(Icons.lock_outline, 'Cambiar contraseña', () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CambiarPasswordScreen()))),
              _item(Icons.help_outline, 'Cómo funciona Gymder', () => _help(context)),
            ]),
            const SizedBox(height: 20),
            Btn('Cerrar sesión', app.logout, outlined: true, icon: Icons.logout),
          ]);
        },
      );

  void _help(BuildContext context) => showSheet(
        context,
        (_) => Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            sheetHandle(),
            Text('CÓMO FUNCIONA', style: hd(30, italic: true)),
            const SizedBox(height: 14),
            for (final (i, t) in (app.isCoach
                    ? [('Publica tu perfil', 'Completa tu bio, tus planes y tus precios.'), ('Responde a los usuarios', 'Cuando alguien pregunte por tus planes te llega un chat.'), ('Cierra el plan', 'Acuerden mensualidad y condiciones y márcalo como acordado.')]
                    : [('Desliza', 'Descubre entrenadores y guarda los que te interesen.'), ('Pregunta por planes', 'Un swipe a la derecha abre el chat al instante.'), ('Acuerda y entrena', 'Cierren el plan por chat y deja tu reseña al final.')])
                .indexed)
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(width: 34, height: 34, alignment: Alignment.center, decoration: const BoxDecoration(color: lime, shape: BoxShape.circle), child: Text('${i + 1}', style: hd(20, c: ink, italic: true))),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(t.$1, style: ts(15, w: FontWeight.w700)), const SizedBox(height: 2), Text(t.$2, style: ts(13, c: muted, h: 1.4))])),
                ]),
              ),
          ]),
        ),
      );

  Widget _group(List<Widget> items) => Container(
        clipBehavior: Clip.antiAlias,
        decoration: box(),
        child: Column(children: [
          for (final (i, w) in items.indexed) ...[if (i > 0) const Divider(height: 1, color: line), w],
        ]),
      );

  Widget _item(IconData i, String t, VoidCallback f) => Tap(
        scale: .99,
        onTap: f,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(children: [
            IconTile(i),
            const SizedBox(width: 12),
            Expanded(child: Text(t, style: ts(15, w: FontWeight.w600))),
            const Icon(Icons.chevron_right, color: muted),
          ]),
        ),
      );
}

class EditarPerfilScreen extends StatefulWidget {
  const EditarPerfilScreen({super.key});
  @override
  State<EditarPerfilScreen> createState() => _EditarPerfilScreenState();
}

class _EditarPerfilScreenState extends State<EditarPerfilScreen> {
  late final u = app.me!;
  late final nombre = TextEditingController(text: u.nombre);
  late final objetivo = TextEditingController(text: u.objetivo);
  late final disp = TextEditingController(text: u.disponibilidad);
  late final notas = TextEditingController(text: u.notas);
  late String nivel = u.nivel;

  @override
  Widget build(BuildContext context) => SubScreen(
        title: 'Editar perfil',
        subtitle: 'Perfil del usuario',
        bottom: SizedBox(
          width: double.infinity,
          child: Btn('Guardar', () {
            app.saveUser(nombre: nombre.text, objetivo: objetivo.text, nivel: nivel, disponibilidad: disp.text, notas: notas.text);
            Navigator.of(context).pop();
          }, fg: ink),
        ),
        child: ListView(padding: const EdgeInsets.all(16), children: [
          label('Nombre'),
          field(nombre, 'Tu nombre', maxLen: 40),
          label('Objetivo'),
          field(objetivo, 'Ej. Ganar fuerza', maxLen: 80),
          label('Nivel'),
          Seg([for (final n in niveles) (n, n)], nivel, (v) => setState(() => nivel = v)),
          label('Disponibilidad'),
          field(disp, 'Ej. Lun, mié y vie por la tarde', maxLen: 80),
          label('Notas (lesiones, preferencias)'),
          field(notas, 'Notas para tu entrenador', maxLen: 120),
        ]),
      );
}

// ───────────────────────── Planes y precios (entrenador) ─────────────────────────
class PlanesEditorScreen extends StatefulWidget {
  const PlanesEditorScreen({super.key});
  @override
  State<PlanesEditorScreen> createState() => _PlanesEditorScreenState();
}

class _PlanesEditorScreenState extends State<PlanesEditorScreen> {
  String? edId; // null = lista; 'new' = plan nuevo; otro = id en edición
  final nombre = TextEditingController(), precio = TextEditingController(), desc = TextEditingController();

  void load(Plan? p) {
    edId = p?.id ?? 'new';
    nombre.text = p?.nombre ?? '';
    precio.text = p == null ? '' : '${p.precio}';
    desc.text = p?.descripcion ?? '';
  }

  bool get valid => nombre.text.trim().isNotEmpty && int.tryParse(precio.text) != null;

  void save() {
    if (!valid) return toast(context, 'Ponle un nombre y un precio al plan');
    app.savePlan(Plan(id: edId == 'new' ? app.newPlanId() : edId!, nombre: nombre.text.trim(), precio: int.parse(precio.text), descripcion: desc.text.trim()));
    setState(() => edId = null);
    toast(context, 'Plan guardado. Ya se ve en tu perfil');
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: app,
        builder: (context, _) {
          final c = app.meCoach!;
          if (edId != null) {
            return SubScreen(
              title: edId == 'new' ? 'Nuevo plan' : 'Editar plan',
              subtitle: 'Planes y precios',
              bottom: Row(children: [
                if (edId != 'new')
                  Expanded(child: Btn('Eliminar', () {
                    app.deletePlan(edId!);
                    setState(() => edId = null);
                  }, outlined: true)),
                if (edId != 'new') const SizedBox(width: 10),
                Expanded(flex: 2, child: Btn('Guardar', save, fg: ink)),
              ]),
              child: ListView(padding: const EdgeInsets.all(16), children: [
                label('Nombre del plan'),
                field(nombre, 'Ej. Plan mensual', maxLen: 32, onChanged: (_) => setState(() {})),
                label('Precio por mes (¤)'),
                field(precio, '120', type: TextInputType.number, maxLen: 6, onChanged: (v) {
                  final d = v.replaceAll(RegExp(r'\D'), '');
                  if (d != v) precio.text = d;
                  setState(() {});
                }),
                label('Qué incluye'),
                field(desc, 'Ej. 8 sesiones + seguimiento por chat', maxLen: 80),
              ]),
            );
          }
          return SubScreen(
            title: 'Mis planes y precios',
            subtitle: 'Se muestran en tu perfil',
            bottom: SizedBox(width: double.infinity, child: Btn('Nuevo plan', () => setState(() => load(null)), fg: ink, icon: Icons.add)),
            child: c.planes.isEmpty
                ? Center(child: Padding(padding: const EdgeInsets.all(32), child: Text('Aún no tienes planes. Agrega uno para que los usuarios vean tus precios.', style: ts(14, c: muted, h: 1.4), textAlign: TextAlign.center)))
                : ListView(padding: const EdgeInsets.all(16), children: [
                    for (final p in c.planes)
                      GestureDetector(
                        onTap: () => setState(() => load(p)),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: box(),
                          child: Row(children: [
                            Expanded(
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(p.nombre, style: ts(16, w: FontWeight.w600)),
                                if (p.descripcion.isNotEmpty) Text(p.descripcion, style: ts(13, c: muted)),
                              ]),
                            ),
                            const SizedBox(width: 12),
                            Text(p.precioTxt, style: ts(15, w: FontWeight.w700)),
                            const Icon(Icons.chevron_right, color: muted),
                          ]),
                        ),
                      ),
                  ]),
          );
        },
      );
}