enum AdEventType { impression, click }

/// Anuncio (tabla ads).
class Ad {
  final String id;
  final String advertiserName;
  final String title;
  final String? imageUrl;
  final String destinationUrl;
  final bool isActive; // ads.status == 'active'
  final DateTime? startsAt;
  final DateTime? endsAt;

  const Ad({
    required this.id,
    required this.advertiserName,
    required this.title,
    this.imageUrl,
    required this.destinationUrl,
    this.isActive = true,
    this.startsAt,
    this.endsAt,
  });

  /// Activo y dentro de su ventana de fechas (sin fecha = sin límite).
  bool isRunningAt(DateTime now) {
    if (!isActive) return false;
    if (startsAt != null && now.isBefore(startsAt!)) return false;
    if (endsAt != null && now.isAfter(endsAt!)) return false;
    return true;
  }
}

/// Impresión o clic sobre un anuncio (tabla ad_events, solo se agrega, nunca se edita).
class AdEvent {
  final String id;
  final String adId;
  final String? profileId; // null si el perfil fue borrado o es anónimo
  final AdEventType type;
  final DateTime createdAt;

  const AdEvent({
    required this.id,
    required this.adId,
    this.profileId,
    required this.type,
    required this.createdAt,
  });
}
