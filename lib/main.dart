import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/agenda.dart';
import 'screens/auth.dart';
import 'screens/cuenta.dart';
import 'screens/descubrir.dart';
import 'screens/mensajes.dart';
import 'core_data.dart';
import 'state.dart';
import 'ui.dart';

const phoneMaxWidth = 412.0;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
  runApp(const GymderApp());
}

class GymderApp extends StatelessWidget {
  const GymderApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Gymder',
        debugShowCheckedModeBanner: false,
        theme: buildTheme(),
        // App móvil: en pantallas anchas (navegador/escritorio) se muestra siempre en un marco
        // de teléfono centrado; en un móvil real ocupa toda la pantalla.
        builder: (context, child) {
          final mq = MediaQuery.of(context);
          if (mq.size.width <= phoneMaxWidth) return child!;
          final h = mq.size.height > 900 ? 900.0 : mq.size.height;
          final framed = mq.size.height > 760;
          return Container(
            color: const Color(0xFF03060C),
            alignment: Alignment.center,
            child: Container(
              width: phoneMaxWidth,
              height: framed ? h - 32 : h,
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(framed ? 32 : 0),
                border: framed ? Border.all(color: line, width: 1.5) : null,
                boxShadow: [BoxShadow(color: lime.withValues(alpha: .06), blurRadius: 60, spreadRadius: 2)],
              ),
              clipBehavior: Clip.antiAlias,
              child: MediaQuery(data: mq.copyWith(size: Size(phoneMaxWidth, framed ? h - 32 : h)), child: child!),
            ),
          );
        },
        // La raíz cambia sola entre Bienvenida y Shell según la sesión.
        home: ListenableBuilder(listenable: app, builder: (_, _) => app.loggedIn ? const Shell() : const WelcomeScreen()),
      );
}

class Shell extends StatelessWidget {
  const Shell({super.key});

  // Usuario: Descubrir · Mensajes · Cuenta. Entrenador: Mensajes · Cuenta.
  // (etiqueta, icono, icono activo)
  static const _descubrir = ('Descubrir', Icons.style_outlined, Icons.style);
  static const _mensajes = ('Mensajes', Icons.chat_bubble_outline, Icons.chat_bubble);
  static const _cuenta = ('Cuenta', Icons.person_outline, Icons.person);
  static const _agenda = ('Agenda', Icons.event_outlined, Icons.event);

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: app,
        builder: (context, _) {
          final coach = app.isCoach;
          final tabs = [if (!coach) _descubrir, _mensajes, _agenda, _cuenta];
          final pages = [if (!coach) const DescubrirTab(), const MensajesTab(), const AgendaTab(), const CuentaTab()];
          final cur = app.tab.clamp(0, tabs.length - 1);
          return Scaffold(
            body: SafeArea(
              bottom: false,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 260),
                switchInCurve: Curves.easeOutCubic,
                transitionBuilder: (child, a) => FadeTransition(
                  opacity: a,
                  child: SlideTransition(position: Tween(begin: const Offset(0, .02), end: Offset.zero).animate(a), child: child),
                ),
                child: KeyedSubtree(key: ValueKey('${coach}_$cur'), child: pages[cur]),
              ),
            ),
            bottomNavigationBar: Container(
              decoration: const BoxDecoration(color: surface, border: Border(top: BorderSide(color: line))),
              padding: EdgeInsets.fromLTRB(8, 0, 8, 6 + MediaQuery.of(context).padding.bottom),
              child: Row(children: [
                for (var i = 0; i < tabs.length; i++)
                  Expanded(
                    child: Tap(
                      scale: .92,
                      onTap: () => app.setTab(i),
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        // Barra superior de acento en la pestaña activa
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          height: 3,
                          width: cur == i ? 36 : 0,
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(color: lime, borderRadius: const BorderRadius.vertical(bottom: Radius.circular(3)), boxShadow: [BoxShadow(color: lime.withValues(alpha: .6), blurRadius: 10)]),
                        ),
                        Stack(clipBehavior: Clip.none, children: [
                          Icon(cur == i ? tabs[i].$3 : tabs[i].$2, size: 24, color: cur == i ? lime : muted),
                          if (tabs[i] == _mensajes && app.pendingCount > 0 && coach) Positioned(right: -10, top: -6, child: countBadge(app.pendingCount)),
                          if (tabs[i] == _agenda && app.myBookings.where((b) => b.status == BookingStatus.pendiente).isNotEmpty && coach)
                            Positioned(right: -10, top: -6, child: countBadge(app.myBookings.where((b) => b.status == BookingStatus.pendiente).length)),
                        ]),
                        const SizedBox(height: 3),
                        Text(tabs[i].$1.toUpperCase(), style: ts(10, w: FontWeight.w800, c: cur == i ? lime : muted, ls: .8)),
                        const SizedBox(height: 6),
                      ]),
                    ),
                  ),
              ]),
            ),
          );
        },
      );
}
