import 'package:flutter/material.dart';
import '../core_data.dart';
import '../state.dart';
import '../ui.dart';
import 'perfiles.dart';

class CuentaTab extends StatelessWidget {
  const CuentaTab({super.key});
  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: app,
        builder: (context, _) {
          final s = app.session!;
          final coach = app.isCoach;
          final name = app.myName;
          final ini = coach ? app.meCoach!.ini : app.me!.ini;
          return ListView(padding: const EdgeInsets.fromLTRB(16, 12, 16, 24), children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 0, 4, 16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Tu información', style: ts(13, c: slate, w: FontWeight.w500)),
                Text('Cuenta', style: ts(30, w: FontWeight.w600)),
              ]),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: box(bg: navy, bd: null),
              child: Row(children: [
                Avatar(ini, size: 56),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(name, style: ts(18, w: FontWeight.w600, c: white)),
                    Text(s.email, style: ts(13, c: soft)),
                  ]),
                ),
                Tag(coach ? 'Entrenador' : 'Usuario', bg: lime),
              ]),
            ),
            const SizedBox(height: 12),
            _item(Icons.person_outline, coach ? 'Mi perfil de entrenador' : 'Mi perfil', () => coach ? openCoachProfile(context, s.profileId) : openUserProfile(context, s.profileId)),
            if (coach) _item(Icons.sell_outlined, 'Mis planes y precios', () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PlanesEditorScreen()))),
            if (!coach) _item(Icons.edit_outlined, 'Editar perfil', () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const EditarPerfilScreen()))),
            const SizedBox(height: 12),
            Btn('Cerrar sesión', app.logout, outlined: true, icon: Icons.logout),
          ]);
        },
      );

  Widget _item(IconData i, String t, VoidCallback f) => GestureDetector(
        onTap: f,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: box(),
          child: Row(children: [
            IconTile(i),
            const SizedBox(width: 12),
            Expanded(child: Text(t, style: ts(15, w: FontWeight.w600))),
            const Icon(Icons.chevron_right, color: slate),
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
          }, bg: lime, fg: navy),
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
                Expanded(flex: 2, child: Btn('Guardar', save, bg: lime, fg: navy)),
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
            bottom: SizedBox(width: double.infinity, child: Btn('Nuevo plan', () => setState(() => load(null)), bg: lime, fg: navy, icon: Icons.add)),
            child: c.planes.isEmpty
                ? Center(child: Padding(padding: const EdgeInsets.all(32), child: Text('Aún no tienes planes. Agrega uno para que los usuarios vean tus precios.', style: ts(14, c: slate, h: 1.4), textAlign: TextAlign.center)))
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
                                if (p.descripcion.isNotEmpty) Text(p.descripcion, style: ts(13, c: slate)),
                              ]),
                            ),
                            const SizedBox(width: 12),
                            Text(p.precioTxt, style: ts(15, w: FontWeight.w700)),
                            const Icon(Icons.chevron_right, color: slate),
                          ]),
                        ),
                      ),
                  ]),
          );
        },
      );
}