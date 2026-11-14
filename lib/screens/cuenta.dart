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
                Tag(coach ? 'Coach' : 'Usuario', bg: lime),
              ]),
            ),
            const SizedBox(height: 12),
            _item(Icons.person_outline, coach ? 'Mi perfil de coach' : 'Mi perfil', () => coach ? openCoachProfile(context, s.profileId) : openUserProfile(context, s.profileId)),
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
          field(notas, 'Notas para tu coach', maxLen: 120),
        ]),
      );
}
