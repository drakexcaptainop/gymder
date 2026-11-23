import 'package:flutter_test/flutter_test.dart';
import 'package:gymder/domain/models/ad.dart';

void main() {
  group('Ad.isRunningAt', () {
    final start = DateTime.utc(2026, 11, 1);
    final end = DateTime.utc(2026, 12, 31);

    Ad build({bool isActive = true, DateTime? startsAt, DateTime? endsAt}) =>
        Ad(
          id: 'a1',
          advertiserName: 'ProteinMax',
          title: 'Descuento',
          destinationUrl: 'https://example.com',
          isActive: isActive,
          startsAt: startsAt,
          endsAt: endsAt,
        );

    test('un anuncio inactivo nunca corre', () {
      expect(
        build(isActive: false).isRunningAt(DateTime.utc(2026, 11, 15)),
        isFalse,
      );
    });

    test('sin fechas corre siempre que esté activo', () {
      expect(build().isRunningAt(DateTime.utc(2030)), isTrue);
    });

    test('no corre antes de startsAt', () {
      final ad = build(startsAt: start, endsAt: end);
      expect(ad.isRunningAt(DateTime.utc(2026, 10, 31)), isFalse);
    });

    test('corre dentro de la ventana', () {
      final ad = build(startsAt: start, endsAt: end);
      expect(ad.isRunningAt(DateTime.utc(2026, 11, 15)), isTrue);
    });

    test('no corre después de endsAt', () {
      final ad = build(startsAt: start, endsAt: end);
      expect(ad.isRunningAt(DateTime.utc(2027, 1, 1)), isFalse);
    });

    test('solo con inicio o solo con fin respeta el límite que existe', () {
      expect(
        build(startsAt: start).isRunningAt(DateTime.utc(2026, 10, 1)),
        isFalse,
      );
      expect(build(startsAt: start).isRunningAt(DateTime.utc(2030)), isTrue);
      expect(build(endsAt: end).isRunningAt(DateTime.utc(2020)), isTrue);
      expect(build(endsAt: end).isRunningAt(DateTime.utc(2030)), isFalse);
    });
  });

  group('AdEvent', () {
    test('guarda anuncio, tipo y perfil opcional', () {
      final event = AdEvent(
        id: 'e1',
        adId: 'a1',
        type: AdEventType.click,
        createdAt: DateTime.utc(2026, 11, 15),
      );

      expect(event.adId, 'a1');
      expect(event.type, AdEventType.click);
      expect(event.profileId, isNull);
    });

    test('los tipos son impression y click', () {
      expect(AdEventType.values.map((t) => t.name), ['impression', 'click']);
    });
  });
}
