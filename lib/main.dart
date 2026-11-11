import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/comidas.dart';
import 'screens/descubrir.dart';
import 'screens/inicio.dart';
import 'screens/micoach.dart';
import 'screens/rutinas.dart';
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
        home: const Shell(),
      );
}

class Shell extends StatelessWidget {
  const Shell({super.key});
  static const tabs = [
    ('Inicio', Icons.home_outlined),
    ('Comidas', Icons.restaurant_outlined),
    ('Rutinas', Icons.fitness_center),
    ('Descubrir', Icons.style_outlined),
    ('Mi coach', Icons.person_outline),
  ];

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: app,
        builder: (context, _) => Scaffold(
          body: SafeArea(
            bottom: false,
            child: IndexedStack(index: app.tab, children: const [
              InicioTab(),
              ComidasTab(),
              RutinasTab(),
              DescubrirTab(),
              MiCoachTab(),
            ]),
          ),
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
                      decoration: BoxDecoration(color: app.tab == i ? lime : Colors.transparent, borderRadius: BorderRadius.circular(14)),
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Icon(tabs[i].$2, size: 22, color: app.tab == i ? navy : slate),
                        const SizedBox(height: 2),
                        Text(tabs[i].$1, style: ts(11, w: app.tab == i ? FontWeight.w600 : FontWeight.w500, c: app.tab == i ? navy : slate)),
                      ]),
                    ),
                  ),
                ),
            ]),
          ),
        ),
      );
}
