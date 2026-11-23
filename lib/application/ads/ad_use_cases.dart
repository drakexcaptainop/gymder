import '../../domain/models/ad.dart';
import '../../domain/repositories/ad_repository.dart';

/// Anuncios vigentes para mostrar en la app.
class GetActiveAds {
  final AdRepository _repository;

  const GetActiveAds(this._repository);

  Future<List<Ad>> call() => _repository.getActiveAds();
}

/// Registra que un anuncio se mostró (impression) o se tocó (click).
class TrackAdEvent {
  final AdRepository _repository;

  const TrackAdEvent(this._repository);

  Future<void> call({
    required String adId,
    String? profileId,
    required AdEventType type,
  }) => _repository.trackEvent(adId: adId, profileId: profileId, type: type);
}
