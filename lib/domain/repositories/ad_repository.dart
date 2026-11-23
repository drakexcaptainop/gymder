import '../models/ad.dart';

abstract class AdRepository {
  /// Anuncios activos y dentro de su ventana de fechas.
  Future<List<Ad>> getActiveAds();

  /// Registra una impresión o un clic (append-only).
  Future<void> trackEvent({
    required String adId,
    String? profileId,
    required AdEventType type,
  });
}
