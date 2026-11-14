import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymder/core_data.dart';
import 'package:gymder/main.dart';
import 'package:gymder/state.dart';

void ignoreOverflow() {
  // La fuente de prueba (Ahem) es más ancha que la real: ignoramos solo los overflows de layout.
  final prev = FlutterError.onError;
  FlutterError.onError = (d) {
    if (d.exceptionAsString().contains('overflowed')) return;
    prev?.call(d);
  };
}

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

Future<void> send(WidgetTester t, String text) async {
  await t.enterText(find.byType(TextField), text);
  await t.pump();
  await t.tap(find.byIcon(Icons.send));
  await t.pumpAndSettle();
}

void main() {
  testWidgets('contacto directo → el coach responde → chat entre ambos roles', (t) async {
    ignoreOverflow();
    t.view.physicalSize = const Size(900, 1800);
    t.view.devicePixelRatio = 2;
    addTearDown(t.view.reset);
    await t.pumpWidget(const GymderApp());

    // 1) Usuario (Camila): derecha escribe al coach al instante, izquierda descarta, arriba abre el perfil.
    expect(find.text('Gymder'), findsOneWidget);
    await login(t, 'camila@demo.com');
    final first = app.deck.first;
    await t.tap(find.byIcon(Icons.send_rounded));
    await t.pump(const Duration(milliseconds: 400));
    final req = app.requestBetween('u1', first.id)!;
    expect(req.status, ContactStatus.accepted, reason: 'no queda pendiente: el chat se abre al instante');
    expect(req.messages.single.author, AppRole.user);
    expect(req.messages.single.text, AppState.preguntaPlanes);

    final second = app.deck.first;
    await t.tap(find.byIcon(Icons.close));
    await t.pump(const Duration(milliseconds: 400));
    expect(app.requestBetween('u1', second.id), isNull);

    await t.tap(find.byIcon(Icons.arrow_upward));
    await t.pumpAndSettle();
    expect(find.text('Perfil del entrenador'), findsOneWidget);
    expect(find.text('Planes y precios'), findsOneWidget);
    await t.tap(find.byIcon(Icons.chevron_left));
    await t.pumpAndSettle();

    // El chat ya existe en Mensajes y la pregunta está esperando respuesta.
    await t.tap(find.text('Mensajes').last);
    await t.pumpAndSettle();
    expect(find.text('Valeria Ríos'), findsOneWidget);
    expect(find.text('Esperando respuesta'), findsOneWidget);
    await logout(t);

    // 2) El entrenador (Valeria, c1) ve la pregunta de Camila y la responde con sus planes.
    expect(first.id, 'c1');
    await login(t, 'valeria@demo.com');
    expect(find.text('Descubrir'), findsNothing);
    await t.tap(find.text('Mensajes').last);
    await t.pumpAndSettle();
    expect(find.text('Camila Torres'), findsOneWidget);
    expect(find.text('Por responder'), findsNWidgets(2)); // Camila y Diego
    await t.tap(find.text('Camila Torres'));
    await t.pumpAndSettle();
    // Desde el chat el entrenador puede ver el perfil de quien le escribió.
    await t.tap(find.byIcon(Icons.person_outline));
    await t.pumpAndSettle();
    expect(find.text('Perfil del usuario'), findsOneWidget);
    await t.tap(find.byIcon(Icons.chevron_left));
    await t.pumpAndSettle();
    await t.tap(find.text('Responder con mis planes'));
    await t.pump();
    await t.tap(find.byIcon(Icons.send));
    await t.pumpAndSettle();
    expect(req.messages.length, 2);
    expect(req.messages.last.author, AppRole.coach);
    expect(req.messages.last.text, contains('Estos son mis planes'));
    expect(req.messages.last.text, contains('¤ 120 / mes'));
    await t.tap(find.byIcon(Icons.chevron_left));
    await t.pumpAndSettle();
    await logout(t);

    // 3) Camila ve la respuesta del entrenador y sigue la conversación.
    await login(t, 'camila@demo.com');
    await t.tap(find.text('Mensajes').last);
    await t.pumpAndSettle();
    await t.tap(find.text('Valeria Ríos'));
    await t.pumpAndSettle();
    await send(t, 'Me interesa el plan de fuerza, ¿cuánto sería la mensualidad?');
    expect(req.messages.length, 3);
    expect(req.messages.last.author, AppRole.user);
  });

  testWidgets('registro de usuario y de entrenador', (t) async {
    ignoreOverflow();
    t.view.physicalSize = const Size(900, 1800);
    t.view.devicePixelRatio = 2;
    addTearDown(t.view.reset);
    app.logout();
    await t.pumpWidget(const GymderApp());
    await t.tap(find.text('Crear cuenta'));
    await t.pumpAndSettle();
    await t.tap(find.text('Entrenador'));
    await t.pumpAndSettle();
    final f = find.byType(TextField);
    await t.enterText(f.at(0), 'Nuevo Entrenador');
    await t.enterText(f.at(1), 'nuevo@coach.com');
    await t.enterText(f.at(2), 'secreto1');
    await t.tap(find.text('Crear cuenta').last);
    await t.pumpAndSettle();
    expect(app.isCoach, isTrue);
    expect(find.text('Mensajes'), findsWidgets);
    expect(find.text('Solicitudes'), findsNothing);
    expect(coaches.any((c) => c.nombre == 'Nuevo Entrenador'), isTrue);
  });

  testWidgets('en pantalla ancha se muestra en marco de teléfono', (t) async {
    ignoreOverflow();
    t.view.physicalSize = const Size(2400, 1400);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    app.logout();
    await t.pumpWidget(const GymderApp());
    final w = t.getSize(find.byType(Scaffold).first).width;
    expect(w, lessThanOrEqualTo(phoneMaxWidth));
  });

  testWidgets('el entrenador publica un plan con precio y se ve en su perfil', (t) async {
    ignoreOverflow();
    t.view.physicalSize = const Size(900, 1800);
    t.view.devicePixelRatio = 2;
    addTearDown(t.view.reset);
    app.logout();
    await t.pumpWidget(const GymderApp());
    await login(t, 'mateo@demo.com');
    await t.tap(find.text('Cuenta').last);
    await t.pumpAndSettle();
    await t.tap(find.text('Mis planes y precios'));
    await t.pumpAndSettle();
    await t.tap(find.text('Nuevo plan'));
    await t.pumpAndSettle();
    final f = find.byType(TextField);
    await t.enterText(f.at(0), 'Plan Premium');
    await t.enterText(f.at(1), '250');
    await t.enterText(f.at(2), 'Seguimiento diario');
    await t.pump();
    await t.tap(find.text('Guardar'));
    await t.pumpAndSettle();
    expect(find.text('Plan Premium'), findsOneWidget);
    expect(find.text('¤ 250 / mes'), findsOneWidget);
    expect(coachById('c2').planes.any((p) => p.nombre == 'Plan Premium' && p.precio == 250), isTrue);
    await t.tap(find.byIcon(Icons.chevron_left));
    await t.pumpAndSettle();
    await t.tap(find.text('Mi perfil de entrenador'));
    await t.pumpAndSettle();
    await t.scrollUntilVisible(find.text('Plan Premium'), 300);
    expect(find.text('Plan Premium'), findsOneWidget);
  });
}