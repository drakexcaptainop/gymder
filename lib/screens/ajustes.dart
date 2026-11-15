import 'package:flutter/material.dart';
import '../state.dart';
import '../ui.dart';
import 'mensajes.dart';

// ───────────────────────── Cambiar contraseña ─────────────────────────
class CambiarPasswordScreen extends StatefulWidget {
  const CambiarPasswordScreen({super.key});
  @override
  State<CambiarPasswordScreen> createState() => _CambiarPasswordScreenState();
}

class _CambiarPasswordScreenState extends State<CambiarPasswordScreen> {
  final actual = TextEditingController(), nueva = TextEditingController(), repetir = TextEditingController();
  String? error;

  void submit() {
    if (nueva.text != repetir.text) return setState(() => error = 'Las contraseñas nuevas no coinciden');
    final err = app.changePassword(actual.text, nueva.text);
    if (err != null) return setState(() => error = err);
    Navigator.of(context).pop();
    toast(context, 'Contraseña actualizada');
  }

  @override
  Widget build(BuildContext context) => SubScreen(
        title: 'Cambiar contraseña',
        subtitle: 'Seguridad',
        bottom: SizedBox(width: double.infinity, child: Btn('Guardar contraseña', submit, fg: ink)),
        child: ListView(padding: const EdgeInsets.all(16), children: [
          label('Contraseña actual'),
          field(actual, 'Tu contraseña actual', obscure: true, icon: Icons.lock_outline, onChanged: (_) => setState(() => error = null)),
          label('Nueva contraseña'),
          field(nueva, 'Mínimo 6 caracteres', obscure: true, icon: Icons.lock_reset, onChanged: (_) => setState(() => error = null)),
          label('Repite la nueva contraseña'),
          field(repetir, 'Repítela', obscure: true, icon: Icons.lock_reset, onChanged: (_) => setState(() => error = null)),
          if (error != null) Padding(padding: const EdgeInsets.only(top: 12), child: Text(error!, style: ts(13, c: danger, w: FontWeight.w500))),
        ]),
      );
}

// ───────────────────────── Foto de perfil ─────────────────────────
class FotoPerfilScreen extends StatelessWidget {
  const FotoPerfilScreen({super.key});
  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: app,
        builder: (context, _) {
          final ini = app.isCoach ? app.meCoach!.ini : app.me!.ini;
          return SubScreen(
            title: 'Foto de perfil',
            subtitle: 'Elige tu avatar',
            bottom: SizedBox(
              width: double.infinity,
              child: Btn('Listo', () {
                Navigator.of(context).pop();
                toast(context, 'Foto de perfil actualizada');
              }, fg: ink),
            ),
            child: ListView(padding: const EdgeInsets.all(16), children: [
              Center(child: Avatar(ini, size: 120, tone: app.myTone)),
              const SizedBox(height: 8),
              Center(child: Text(app.myName, style: ts(16, w: FontWeight.w600))),
              label('Colores'),
              Wrap(spacing: 14, runSpacing: 14, children: [
                for (var i = 0; i < avatarTones.length; i++)
                  GestureDetector(
                    onTap: () => app.setTone(i),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(22), border: Border.all(color: app.myTone == i ? lime : Colors.transparent, width: 2)),
                      child: Avatar(ini, size: 56, tone: i),
                    ),
                  ),
              ]),
              const SizedBox(height: 16),
              Text('Por ahora el avatar usa tus iniciales y el color que elijas.', style: ts(12, c: muted, h: 1.4)),
            ]),
          );
        },
      );
}

// ───────────────────────── Notificaciones ─────────────────────────
class NotificacionesScreen extends StatelessWidget {
  const NotificacionesScreen({super.key});
  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: app,
        builder: (context, _) {
          final list = app.myNotifications;
          return SubScreen(
            title: 'Notificaciones',
            subtitle: app.unreadCount == 0 ? 'Todo al día' : '${app.unreadCount} sin leer',
            actions: [if (app.unreadCount > 0) RoundBtn(Icons.done_all, app.markAllRead)],
            child: list.isEmpty
                ? const EmptyState(Icons.notifications_none, 'Todo al día', 'Aquí verás mensajes, planes acordados y reseñas nuevas.')
                : ListView(padding: const EdgeInsets.all(16), children: [
                    for (final n in list)
                      GestureDetector(
                        onTap: () {
                          app.markRead(n.id);
                          if (n.requestId != null) openChat(context, n.requestId!);
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: box(bg: n.leida ? surface : cyanTint, bd: n.leida ? line : cyanTint),
                          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 5, right: 10),
                              child: Container(width: 8, height: 8, decoration: BoxDecoration(color: n.leida ? Colors.transparent : lime, shape: BoxShape.circle)),
                            ),
                            Expanded(
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(n.titulo, style: ts(14, w: n.leida ? FontWeight.w500 : FontWeight.w700)),
                                const SizedBox(height: 2),
                                Text(n.cuerpo, maxLines: 2, overflow: TextOverflow.ellipsis, style: ts(13, c: muted, h: 1.35)),
                              ]),
                            ),
                            const SizedBox(width: 8),
                            Text(n.hora, style: ts(11, c: muted)),
                          ]),
                        ),
                      ),
                  ]),
          );
        },
      );
}

/// Campana con contador de no leídas: abre las notificaciones.
class BellBtn extends StatelessWidget {
  const BellBtn({super.key});
  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: app,
        builder: (context, _) => Stack(clipBehavior: Clip.none, children: [
          RoundBtn(app.unreadCount > 0 ? Icons.notifications_active : Icons.notifications_none, () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NotificacionesScreen())), fg: app.unreadCount > 0 ? lime : text),
          if (app.unreadCount > 0) Positioned(right: -6, top: -6, child: countBadge(app.unreadCount)),
        ]),
      );
}
