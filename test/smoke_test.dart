import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymder/core_data.dart';
import 'package:gymder/main.dart';
import 'package:gymder/state.dart';

Future<void> login(WidgetTester t, String email) async {
  await t.tap(find.text('Iniciar sesión'));
  await t.pumpAndSettle();
  await t.tap(find.text(email));
  await t.pumpAndSettle();
}

Future<void> logout(WidgetTester t) async {
  await t.tap(find.text('Cuenta').last);
  await t.pumpAndSettle();
  await t.tap(find.text('Cerrar sesión'));
  await t.pumpAndSettle();
}

void ignoreOverflow() {
  final prev = FlutterError.onError;
  FlutterError.onError = (d) {
    if (d.exceptionAsString().contains('overflowed')) return;
    prev?.call(d);
  };
}

void main() {
  // La fuente de prueba (Ahem) es más ancha que la real: ignoramos solo los overflows de layout.
  testWidgets('solicitud → aceptación → chat entre usuario y coach', (t) async {
    ignoreOverflow();
    t.view.physicalSize = const Size(900, 1800);
    t.view.devicePixelRatio = 2;
    addTearDown(t.view.reset);
    await t.pumpWidget(const GymderApp());

    // 1) Usuario (Camila) descubre coaches y envía una solicitud con el botón de swipe a la derecha.
    expect(find.text('Gymder'), findsOneWidget);
    await login(t, 'camila@demo.com');
    expect(find.text('Descubrir'), findsWidgets);
    final first = app.deck.first;
    await t.tap(find.byIcon(Icons.send_rounded));
    await t.pump(const Duration(milliseconds: 400));
    final req = app.requestBetween('u1', first.id)!;
    expect(req.status, ContactStatus.pending);

    // Izquierda descarta (no crea solicitud).
    final second = app.deck.first;
    await t.tap(find.byIcon(Icons.close));
    await t.pump(const Duration(milliseconds: 400));
    expect(app.requestBetween('u1', second.id), isNull);

    // Arriba abre el perfil completo del coach.
    await t.tap(find.byIcon(Icons.arrow_upward));
    await t.pumpAndSettle();
    expect(find.text('Perfil del coach'), findsOneWidget);
    await t.tap(find.byIcon(Icons.chevron_left));
    await t.pumpAndSettle();

    // Solicitudes: queda pendiente y el chat sigue bloqueado.
    await t.tap(find.text('Solicitudes').last);
    await t.pumpAndSettle();
    expect(find.text('Pendiente'), findsOneWidget);
    await t.tap(find.text('Mensajes').last);
    await t.pumpAndSettle();
    expect(find.text('Aún no tienes chats'), findsOneWidget);
    await logout(t);

    // 2) El coach (Valeria, c1) recibe la solicitud de Camila y la acepta.
    expect(first.id, 'c1', reason: 'el primer coach del mazo es el de la cuenta demo');
    await login(t, 'valeria@demo.com');
    expect(find.text('Descubrir'), findsNothing);
    await t.tap(find.text('Solicitudes').last);
    await t.pumpAndSettle();
    expect(find.text('Camila Torres'), findsOneWidget);
    await t.tap(find.text('Camila Torres'));
    await t.pumpAndSettle();
    expect(find.text('Perfil del usuario'), findsOneWidget);
    await t.tap(find.text('Aceptar'));
    await t.pumpAndSettle();
    expect(req.status, ContactStatus.accepted);
    await t.tap(find.text('Abrir chat'));
    await t.pumpAndSettle();
    await t.enterText(find.byType(TextField), 'Te propongo plan mensual de 12 sesiones');
    await t.pump();
    await t.tap(find.byIcon(Icons.send));
    await t.pumpAndSettle();
    expect(req.messages.last.text, 'Te propongo plan mensual de 12 sesiones');
    await t.tap(find.byIcon(Icons.chevron_left));
    await t.pumpAndSettle();
    await t.tap(find.byIcon(Icons.chevron_left));
    await t.pumpAndSettle();
    await logout(t);

    // 3) Camila ve la solicitud aceptada, abre el chat y responde.
    await login(t, 'camila@demo.com');
    await t.tap(find.text('Mensajes').last);
    await t.pumpAndSettle();
    await t.tap(find.text('Valeria Ríos'));
    await t.pumpAndSettle();
    expect(find.text('Te propongo plan mensual de 12 sesiones'), findsOneWidget);
    await t.enterText(find.byType(TextField), 'Acepto, ¿cuánto sería la mensualidad?');
    await t.pump();
    await t.tap(find.byIcon(Icons.send));
    await t.pumpAndSettle();
    expect(req.messages.last.author, AppRole.user);
    expect(req.messages.length, 3); // saludo automático + coach + usuario
  });

  testWidgets('registro de usuario y de coach', (t) async {
    ignoreOverflow();
    t.view.physicalSize = const Size(900, 1800);
    t.view.devicePixelRatio = 2;
    addTearDown(t.view.reset);
    app.logout();
    await t.pumpWidget(const GymderApp());
    await t.tap(find.text('Crear cuenta'));
    await t.pumpAndSettle();
    await t.tap(find.text('Coach'));
    await t.pumpAndSettle();
    final f = find.byType(TextField);
    await t.enterText(f.at(0), 'Nuevo Coach');
    await t.enterText(f.at(1), 'nuevo@coach.com');
    await t.enterText(f.at(2), 'secreto1');
    await t.tap(find.text('Crear cuenta').last);
    await t.pumpAndSettle();
    expect(app.isCoach, isTrue);
    expect(find.text('Solicitudes'), findsWidgets);
    expect(coaches.any((c) => c.nombre == 'Nuevo Coach'), isTrue);
  });
}
