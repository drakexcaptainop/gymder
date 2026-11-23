import 'package:flutter_test/flutter_test.dart';
import 'package:gymder/application/coach/coach_use_cases.dart';

import '../../support/fixtures.dart';

void main() {
  late Fixture f;
  setUp(() => f = Fixture());

  group('GetDiscoveryCoaches', () {
    test('devuelve solo coaches activos (Carlos y Ana, no Diego)', () async {
      final coaches = await GetDiscoveryCoaches(f.coaches)();
      expect(coaches.map((c) => c.id), [carlosCoach, anaCoach]);
    });
  });

  group('GetCoachDetail', () {
    test('devuelve el coach con rating derivado de las reseñas', () async {
      final coach = await GetCoachDetail(f.coaches)(carlosCoach);
      expect(coach, isNotNull);
      expect(coach!.name, 'Carlos Mendoza');
      expect(coach.rating, 5.0);
      expect(coach.reviewsCount, 1);
    });

    test('devuelve null si el coach no existe', () async {
      expect(await GetCoachDetail(f.coaches)('no-existe'), isNull);
    });
  });

  group('GetCoachesBySpecialty', () {
    test(
      'filtra sin distinguir mayúsculas y con coincidencia parcial',
      () async {
        final result = await GetCoachesBySpecialty(f.coaches)('YOGA');
        expect(result.map((c) => c.id), [anaCoach]);
      },
    );

    test('ignora espacios alrededor del texto', () async {
      final result = await GetCoachesBySpecialty(f.coaches)('  fuerza  ');
      expect(result.map((c) => c.id), [carlosCoach]);
    });

    test('devuelve lista vacía si nadie coincide', () async {
      expect(await GetCoachesBySpecialty(f.coaches)('natación'), isEmpty);
    });

    test('no incluye coaches inactivos aunque coincidan', () async {
      expect(await GetCoachesBySpecialty(f.coaches)('crossfit'), isEmpty);
    });
  });
}
