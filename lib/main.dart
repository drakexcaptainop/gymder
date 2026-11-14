import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/auth.dart';
import 'screens/cuenta.dart';
import 'screens/descubrir.dart';
import 'screens/mensajes.dart';
import 'screens/solicitudes.dart';
import 'state.dart';
import 'ui.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
  runApp(const GymderApp());
}

class GymderApp extends StatelessWidget {
  const GymderApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Gymder',
        debugShowCheckedModeBanner: false,
        theme: buildTheme(),
        // La raíz cambia sola entre Bienvenida y Shell según la sesión.
        home: ListenableBuilder(listenable: app, builder: (_, _) => app.loggedIn ? const Shell() : const WelcomeScreen()),
      );
}

class Shell extends StatelessWidget {
  const Shell({super.key});

  // Usuario: Descubrir · Solicitudes · Mensajes · Cuenta. Coach: Solicitudes · Mensajes · Cuenta.
  static const _descubrir = ('Descubrir', Icons.style_outlined);
  static const _solicitudes = ('Solicitudes', Icons.inbox_outlined);
  static const _mensajes = ('Mensajes', Icons.chat_bubble_outline);
  static const _cuenta = ('Cuenta', Icons.person_outline);

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: app,
        builder: (context, _) {
          final coach = app.isCoach;
          final tabs = [if (!coach) _descubrir, _solicitudes, _mensajes, _cuenta];
          final pages = [if (!coach) const DescubrirTab(), const SolicitudesTab(), const MensajesTab(), const CuentaTab()];
          final cur = app.tab.clamp(0, tabs.length - 1);
          return Scaffold(
            body: SafeArea(bottom: false, child: IndexedStack(index: cur, children: pages)),
            bottomNavigationBar: Container(
              decoration: const BoxDecoration(color: white, border: Border(top: BorderSide(color: soft))),
              padding: EdgeInsets.fromLTRB(8, 8, 8, 8 + MediaQuery.of(context).padding.bottom),
              child: Row(children: [
                for (var i = 0; i < tabs.length; i++)
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => app.setTab(i),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(color: cur == i ? lime : Colors.transparent, borderRadius: BorderRadius.circular(14)),
                        child: Column(mainAxisSize: MainAxisSize.min, children: [
                          Stack(clipBehavior: Clip.none, children: [
                            Icon(tabs[i].$2, size: 22, color: cur == i ? navy : slate),
                            if (tabs[i] == _solicitudes && app.pendingCount > 0 && coach)
                              Positioned(right: -6, top: -4, child: Container(width: 10, height: 10, decoration: const BoxDecoration(color: cyan, shape: BoxShape.circle))),
                          ]),
                          const SizedBox(height: 2),
                          Text(tabs[i].$1, style: ts(11, w: cur == i ? FontWeight.w600 : FontWeight.w500, c: cur == i ? navy : slate)),
                        ]),
                      ),
                    ),
                  ),
              ]),
            ),
          );
        },
      );
}
