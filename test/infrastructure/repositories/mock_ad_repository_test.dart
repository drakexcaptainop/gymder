import 'package:flutter_test/flutter_test.dart';
import 'package:gymder/domain/models/ad.dart';

import '../../support/fixtures.dart';

void main() {
  late Fixture f;
  setUp(() => f = Fixture());

  group('MockAdRepository', () {
    test('getActiveAds filtra inactivos y fuera de fecha', () async {
      final now = DateTime.now().toUtc();
      final ads = await f.ads.getActiveAds();

      expect(ads.every((a) => a.isActive), isTrue);
      expect(ads.every((a) => a.isRunningAt(now)), isTrue);
    });

    test('trackEvent acepta impresiones anónimas y clics con perfil', () async {
      const adId = 'a0000000-0000-4000-8000-000000000001';
      await f.ads.trackEvent(adId: adId, type: AdEventType.impression);
      await f.ads.trackEvent(
        adId: adId,
        profileId: jorge,
        type: AdEventType.click,
      );
    });

    test('trackEvent falla con un anuncio inexistente', () {
      expect(
        f.ads.trackEvent(adId: 'no-existe', type: AdEventType.click),
        throwsA(isA<StateError>()),
      );
    });
  });
}
