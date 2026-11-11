import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymder/main.dart';
import 'package:gymder/state.dart';

void main() {
  testWidgets('tabs render and pay flow works', (t) async {
    tester(t);
    await t.pumpWidget(const GymderApp());
    for (final n in ['Inicio', 'Comidas', 'Rutinas', 'Mi coach', 'Descubrir']) {
      await t.tap(find.text(n).last);
      await t.pumpAndSettle();
    }
    // open profile -> paquetes -> pago
    await t.tap(find.byIcon(Icons.arrow_upward));
    await t.pumpAndSettle();
    await t.tap(find.text('Ver paquetes'));
    await t.pumpAndSettle();
    await t.tap(find.text('Progreso'));
    await t.pumpAndSettle();
    await t.tap(find.text('Continuar'));
    await t.pumpAndSettle();
    await t.tap(find.text('Rellenar demo'));
    await t.pumpAndSettle();
    await t.tap(find.textContaining('Pagar'));
    await t.pump(const Duration(seconds: 3));
    await t.pumpAndSettle();
    expect(app.paid, true);
    expect(find.text('¡Pago simulado exitoso!'), findsOneWidget);
    await t.tap(find.text('Ver mi rutina'));
    await t.pumpAndSettle();
    expect(find.text('Tu rutina'), findsOneWidget);
    await t.tap(find.text('Comidas').last);
    await t.pumpAndSettle();
    await t.tap(find.byIcon(Icons.add).first);
    await t.pumpAndSettle();
    expect(find.text('Agregar comida'), findsOneWidget);
  });
}

void tester(WidgetTester t) {
  t.view.physicalSize = const Size(1170, 2532);
  t.view.devicePixelRatio = 3;
}
