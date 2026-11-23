import '../../domain/models/ad.dart';
import '../../domain/repositories/ad_repository.dart';
import '../datasources/mock/mock_catalog_data.dart';

class MockAdRepository implements AdRepository {
  final List<Ad> _ads = List.of(kMockAds);
  final List<AdEvent> _events = List.of(kMockAdEvents);

  @override
  Future<List<Ad>> getActiveAds() async {
    await Future.delayed(const Duration(milliseconds: 200));
    final now = DateTime.now().toUtc();
    return _ads.where((a) => a.isRunningAt(now)).toList();
  }

  @override
  Future<void> trackEvent({
    required String adId,
    String? profileId,
    required AdEventType type,
  }) async {
    if (!_ads.any((a) => a.id == adId)) {
      throw StateError('Anuncio no encontrado');
    }
    _events.add(
      AdEvent(
        id: 'adevt_${DateTime.now().microsecondsSinceEpoch}',
        adId: adId,
        profileId: profileId,
        type: type,
        createdAt: DateTime.now().toUtc(),
      ),
    );
  }
}
