import 'package:flutter_test/flutter_test.dart';
import 'package:gymder/application/ads/ad_use_cases.dart';
import 'package:gymder/domain/models/ad.dart';

import '../../support/fixtures.dart';

void main() {
  late Fixture f;
  setUp(() => f = Fixture());

  group('GetActiveAds', () {
    test('solo devuelve anuncios vigentes y nunca el inactivo', () async {
      final ads = await GetActiveAds(f.ads)();
      final now = DateTime.now().toUtc();

      expect(ads.every((a) => a.isRunningAt(now)), isTrue);
      expect(
        ads.any((a) => a.id == 'a0000000-0000-4000-8000-000000000002'),
        isFalse,
      );
    });
  });

  group('TrackAdEvent', () {
    test('registra una impresión y un clic de un anuncio existente', () async {
      final track = TrackAdEvent(f.ads);
      const adId = 'a0000000-0000-4000-8000-000000000001';

      await track(adId: adId, profileId: jorge, type: AdEventType.impression);
      await track(adId: adId, type: AdEventType.click);
    });

    test('un anuncio inexistente lanza StateError', () {
      expect(
        TrackAdEvent(f.ads)(adId: 'no-existe', type: AdEventType.click),
        throwsA(isA<StateError>()),
      );
    });
  });
}
