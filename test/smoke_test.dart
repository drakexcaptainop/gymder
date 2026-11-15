import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymder/core_data.dart';
import 'package:gymder/main.dart';
import 'package:gymder/screens/descubrir.dart';
import 'package:gymder/state.dart';
import 'package:gymder/ui.dart';

/// Busca un Text por su contenido sin distinguir mayúsculas (los títulos del diseño van en mayúsculas).
Finder txt(String s) => find.byWidgetPredicate((w) => w is Text && (w.data ?? "").toLowerCase() == s.toLowerCase(), description: "Text \"$s\"");

void ignoreOverflow() {
  // La fuente de prueba (Ahem) es más ancha que la real: ignoramos solo los overflows de layout.
  final prev = FlutterError.onError;
  FlutterError.onError = (d) {
    if (d.exceptionAsString().contains('overflowed')) return;
    prev?.call(d);
  };
}

Future<void> login(WidgetTester t, String email) async {
  await t.tap(txt('Iniciar sesión'));
  await t.pumpAndSettle();
  await t.tap(txt(email));
  await t.pumpAndSettle();
}

Future<void> logout(WidgetTester t) async {
  await t.pump(const Duration(seconds: 3)); // deja que se cierre cualquier aviso (toast) que tape el botón
  await t.pump(const Duration(seconds: 1));
  await t.tap(txt('Cuenta').last);
  await t.pumpAndSettle();
  await reveal(t, txt('Cerrar sesión'));
  await t.tap(txt('Cerrar sesión'));
  await t.pumpAndSettle();
}

Future<void> send(WidgetTester t, String text) async {
  await t.enterText(find.byType(TextField), text);
  await t.pump();
  await t.tap(find.byIcon(Icons.arrow_upward_rounded));
  await t.pumpAndSettle();
}

void main() {
  DescubrirTab.skeletonMs = 0; // sin pantalla de carga en los tests
  testWidgets('contacto directo → el coach responde → chat entre ambos roles', (t) async {
    ignoreOverflow();
    t.view.physicalSize = const Size(900, 1800);
    t.view.devicePixelRatio = 2;
    addTearDown(t.view.reset);
    await t.pumpWidget(const GymderApp());

    // 1) Usuario (Camila): derecha escribe al coach al instante, izquierda descarta, arriba abre el perfil.
    expect(txt('Gymder'), findsOneWidget);
    await login(t, 'camila@demo.com');
    final first = app.deck.first;
    await t.tap(find.byIcon(Icons.send_rounded));
    await t.pump(const Duration(milliseconds: 400));
    final req = app.requestBetween('u1', first.id)!;
    expect(req.status, ContactStatus.accepted, reason: 'no queda pendiente: el chat se abre al instante');
    expect(req.messages.single.author, AppRole.user);
    expect(req.messages.single.text, AppState.preguntaPlanes);

    final second = app.deck.first;
    await t.tap(find.byIcon(Icons.close_rounded));
    await t.pump(const Duration(milliseconds: 400));
    expect(app.requestBetween('u1', second.id), isNull);

    await t.tap(txt(app.deck.first.nombre)); // tocar la tarjeta abre el perfil
    await t.pumpAndSettle();
    expect(find.textContaining('Planes ('), findsOneWidget);
    await t.tap(find.byIcon(Icons.chevron_left));
    await t.pumpAndSettle();

    // El chat ya existe en Mensajes y la pregunta está esperando respuesta.
    await t.tap(txt('Mensajes').last);
    await t.pumpAndSettle();
    expect(txt('Valeria Ríos'), findsOneWidget);
    expect(txt('Pendiente'), findsOneWidget);
    await logout(t);

    // 2) El entrenador (Valeria, c1) ve la pregunta de Camila y la responde con sus planes.
    expect(first.id, 'c1');
    await login(t, 'valeria@demo.com');
    expect(txt('Descubrir'), findsNothing);
    await t.tap(txt('Mensajes').last);
    await t.pumpAndSettle();
    expect(txt('Camila Torres'), findsOneWidget);
    expect(txt('Por responder'), findsNWidgets(2)); // Camila y Diego
    await t.tap(txt('Camila Torres'));
    await t.pumpAndSettle();
    // Desde el chat el entrenador puede ver el perfil de quien le escribió.
    await t.tap(find.byIcon(Icons.person_outline));
    await t.pumpAndSettle();
    expect(txt('Perfil del usuario'), findsOneWidget);
    await t.tap(find.byIcon(Icons.chevron_left));
    await t.pumpAndSettle();
    await t.tap(txt('Responder con mis planes'));
    await t.pump();
    await t.tap(find.byIcon(Icons.arrow_upward_rounded));
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
    await t.tap(txt('Mensajes').last);
    await t.pumpAndSettle();
    await t.tap(txt('Valeria Ríos'));
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
    await t.tap(txt('Crear cuenta'));
    await t.pumpAndSettle();
    await t.tap(txt('Soy entrenador'));
    await t.pumpAndSettle();
    final f = find.byType(TextField);
    await t.enterText(f.at(0), 'Nuevo Entrenador');
    await t.enterText(f.at(1), 'nuevo@coach.com');
    await t.enterText(f.at(2), 'secreto1');
    await t.drag(find.byType(Scrollable).first, const Offset(0, -600)); // el botón queda debajo del formulario
    await t.pumpAndSettle();
    await t.tap(txt('Crear cuenta').last);
    await t.pumpAndSettle();
    expect(app.isCoach, isTrue);
    expect(txt('Mensajes'), findsWidgets);
    expect(txt('Solicitudes'), findsNothing);
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
    await t.tap(txt('Cuenta').last);
    await t.pumpAndSettle();
    await reveal(t, txt('Mis planes y precios'));
    await t.tap(txt('Mis planes y precios'));
    await t.pumpAndSettle();
    await t.tap(txt('Nuevo plan'));
    await t.pumpAndSettle();
    final f = find.byType(TextField);
    await t.enterText(f.at(0), 'Plan Premium');
    await t.enterText(f.at(1), '250');
    await t.enterText(f.at(2), 'Seguimiento diario');
    await t.pump();
    await t.tap(txt('Guardar'));
    await t.pumpAndSettle();
    expect(txt('Plan Premium'), findsOneWidget);
    expect(txt('¤ 250 / mes'), findsOneWidget);
    expect(coachById('c2').planes.any((p) => p.nombre == 'Plan Premium' && p.precio == 250), isTrue);
    await t.tap(find.byIcon(Icons.chevron_left));
    await t.pumpAndSettle();
    await reveal(t, txt('Mi perfil de entrenador'));
    await t.tap(txt('Mi perfil de entrenador'));
    await t.pumpAndSettle();
    await t.tap(find.textContaining('Planes ('));
    await t.pumpAndSettle();
    expect(txt('Plan Premium'), findsOneWidget);
  });

  testWidgets('cambiar contraseña desde Cuenta', (t) async {
    ignoreOverflow();
    t.view.physicalSize = const Size(900, 1800);
    t.view.devicePixelRatio = 2;
    addTearDown(t.view.reset);
    app.logout();
    app.register(role: AppRole.user, nombre: 'Prueba Clave', email: 'clave@test.com', password: 'actual1');
    await t.pumpWidget(const GymderApp());
    await t.tap(txt('Cuenta').last);
    await t.pumpAndSettle();
    await reveal(t, txt('Cambiar contraseña'));
    await t.tap(txt('Cambiar contraseña'));
    await t.pumpAndSettle();
    final f = find.byType(TextField);
    await t.enterText(f.at(0), 'incorrecta');
    await t.enterText(f.at(1), 'nueva123');
    await t.enterText(f.at(2), 'nueva123');
    await t.pump();
    await t.tap(txt('Guardar contraseña'));
    await t.pumpAndSettle();
    expect(txt('La contraseña actual no coincide'), findsOneWidget);
    await t.enterText(f.at(0), 'actual1');
    await t.pump();
    await t.tap(txt('Guardar contraseña'));
    await t.pumpAndSettle();
    expect(app.session!.password, 'nueva123');
  });

  testWidgets('recuperar contraseña con código', (t) async {
    ignoreOverflow();
    t.view.physicalSize = const Size(900, 1800);
    t.view.devicePixelRatio = 2;
    addTearDown(t.view.reset);
    app.logout();
    app.register(role: AppRole.user, nombre: 'Prueba Olvido', email: 'olvido@test.com', password: 'vieja11');
    app.logout();
    await t.pumpWidget(const GymderApp());
    await t.tap(txt('Iniciar sesión'));
    await t.pumpAndSettle();
    await t.tap(txt('¿Olvidaste tu contraseña?'));
    await t.pumpAndSettle();
    await t.enterText(find.byType(TextField), 'olvido@test.com');
    await t.pump();
    await t.tap(txt('Enviar código'));
    await t.pumpAndSettle();
    final f = find.byType(TextField);
    await t.enterText(f.at(1), AppState.recoveryCode);
    await t.enterText(f.at(2), 'brandnew1');
    await t.pump();
    await reveal(t, txt('Cambiar contraseña'));
    await t.tap(txt('Cambiar contraseña'));
    await t.pumpAndSettle();
    expect(app.login('olvido@test.com', 'brandnew1'), isNull);
  });

  testWidgets('elegir foto de perfil (avatar)', (t) async {
    ignoreOverflow();
    t.view.physicalSize = const Size(900, 1800);
    t.view.devicePixelRatio = 2;
    addTearDown(t.view.reset);
    app.logout();
    app.register(role: AppRole.user, nombre: 'Prueba Foto', email: 'foto@test.com', password: 'foto123');
    await t.pumpWidget(const GymderApp());
    await t.tap(txt('Cuenta').last);
    await t.pumpAndSettle();
    await reveal(t, txt('Foto de perfil'));
    await t.tap(txt('Foto de perfil'));
    await t.pumpAndSettle();
    await t.tap(find.byType(Avatar).at(3)); // el 1º es la vista previa grande; el 4º es el tono 2
    await t.pumpAndSettle();
    expect(app.myTone, 2);
  });

  testWidgets('notificaciones: el entrenador las ve y las marca como leídas', (t) async {
    ignoreOverflow();
    t.view.physicalSize = const Size(900, 1800);
    t.view.devicePixelRatio = 2;
    addTearDown(t.view.reset);
    app.logout();
    await t.pumpWidget(const GymderApp());
    await login(t, 'valeria@demo.com');
    expect(app.unreadCount, greaterThan(0));
    await t.tap(find.byIcon(Icons.notifications_active));
    await t.pumpAndSettle();
    expect(txt('Diego Paredes te escribió'), findsOneWidget);
    await t.tap(find.byIcon(Icons.done_all));
    await t.pumpAndSettle();
    expect(app.unreadCount, 0);
  });

  testWidgets('agenda: el entrenador confirma una reserva pendiente', (t) async {
    ignoreOverflow();
    t.view.physicalSize = const Size(900, 1800);
    t.view.devicePixelRatio = 2;
    addTearDown(t.view.reset);
    app.logout();
    await t.pumpWidget(const GymderApp());
    await login(t, 'valeria@demo.com');
    await t.tap(txt('Agenda').last);
    await t.pumpAndSettle();
    expect(txt('Diego Paredes'), findsOneWidget);
    await t.tap(txt('Confirmar'));
    await t.pumpAndSettle();
    expect(app.bookings.firstWhere((b) => b.id == 'b2').status, BookingStatus.confirmada);
  });

  test('reservas: una prueba por entrenador, el coach confirma y se puede cancelar', () {
    app.logout();
    expect(app.login('camila@demo.com', 'demo123'), isNull);
    final free = app.freeSlots('c1');
    expect(free, isNotEmpty);
    final (dia, horas) = free.first;
    final b = app.book('c1', dia, horas.first, prueba: true)!;
    expect(b.status, BookingStatus.pendiente);
    expect(app.slotTaken('c1', dia, horas.first), isTrue);
    expect(app.book('c1', dia, horas.first, prueba: false), isNull, reason: 'horario ocupado');
    expect(app.trialUsed('c1'), isTrue);
    app.logout();
    expect(app.login('valeria@demo.com', 'demo123'), isNull);
    app.respondBooking(b.id, true);
    expect(b.status, BookingStatus.confirmada);
    app.logout();
    expect(app.login('camila@demo.com', 'demo123'), isNull);
    app.cancelBooking(b.id);
    expect(b.status, BookingStatus.cancelada);
    expect(app.slotTaken('c1', dia, horas.first), isFalse, reason: 'el horario vuelve a quedar libre');
    expect(app.trialUsed('c1'), isFalse);
    app.logout();
  });

  test('verificación: pide certificado y los filtros dejan solo verificados / con prueba', () {
    app.logout();
    expect(app.register(role: AppRole.coach, nombre: 'Coach Nuevo', email: 'verif@test.com', password: 'secreto1'), isNull);
    expect(app.meCoach!.verificado, isFalse);
    expect(app.requestVerification(), isNotNull);
    app.addCertificado('Instructor NSCA');
    expect(app.requestVerification(), isNull);
    expect(app.meCoach!.verificado, isTrue);
    app.removeCertificado(0);
    expect(app.meCoach!.verificado, isFalse);
    expect(coaches.where(Filters([], 'Todas', true, false).matches).every((c) => c.verificado), isTrue);
    expect(coaches.where(Filters([], 'Todas', false, true).matches).every((c) => c.pruebaPrecio != null), isTrue);
    app.logout();
  });

  test('reseñas: solo quien conversó puede reseñar y el promedio se actualiza', () {
    app.logout();
    expect(app.login('diego@demo.com', 'demo123'), isNull);
    expect(app.canReview('c2'), isTrue); // Diego ya conversó con Mateo
    expect(app.canReview('c6'), isFalse);
    final antes = app.reviewsOf('c2').length;
    app.addReview('c2', 3, 'Está bien');
    expect(app.reviewsOf('c2').length, antes + 1);
    app.addReview('c2', 5, 'Mejoró mucho'); // reemplaza su reseña anterior
    expect(app.reviewsOf('c2').length, antes + 1);
    expect(app.myReview('c2')!.estrellas, 5);
    expect(app.ratingOf('c2'), closeTo(5.0, .001));
    app.logout();
  });
}
/// Desplaza la pantalla actual hasta que el widget quede tocable (hacia abajo y, si no, hacia arriba).
Future<void> reveal(WidgetTester t, Finder f) async {
  final list = find.byType(Scrollable).first;
  for (final dy in [-240.0, 240.0]) {
    for (var i = 0; i < 10 && f.hitTestable().evaluate().isEmpty; i++) {
      await t.drag(list, Offset(0, dy));
      await t.pump();
    }
    if (f.hitTestable().evaluate().isNotEmpty) return;
  }
}
