/// Modalidad de entrenamiento (coaches.modality en la migración).
enum CoachModality { online, inPerson, hybrid }

/// Entrenador. Une las tablas: coaches + profiles (nombre) + coach_media (fotos)
/// + reviews (rating y reviewsCount, que son derivados, no se guardan).
class Coach {
  final String id; // coaches.id
  final String profileId; // coaches.profile_id (el "senderId" de sus mensajes)
  final String name; // profiles.full_name
  final String? specialty; // coaches.specialty
  final String? bio;
  final String? city;
  final CoachModality? modality;
  final double? startingPrice;
  final String? currencyCode; // 'BOB', 'USD'...
  final bool trialClassAvailable;
  final double? trialClassPrice;
  final bool isVerified;
  final bool isAvailable; // coaches.status == 'active'
  final List<String> photos; // coach_media ordenado por sort_order
  final double rating; // promedio de reviews (0 si no hay)
  final int reviewsCount;

  const Coach({
    required this.id,
    required this.profileId,
    required this.name,
    this.specialty,
    this.bio,
    this.city,
    this.modality,
    this.startingPrice,
    this.currencyCode,
    this.trialClassAvailable = false,
    this.trialClassPrice,
    this.isVerified = false,
    this.isAvailable = true,
    this.photos = const [],
    this.rating = 0,
    this.reviewsCount = 0,
  });

  Coach copyWith({
    String? id,
    String? profileId,
    String? name,
    String? specialty,
    String? bio,
    String? city,
    CoachModality? modality,
    double? startingPrice,
    String? currencyCode,
    bool? trialClassAvailable,
    double? trialClassPrice,
    bool? isVerified,
    bool? isAvailable,
    List<String>? photos,
    double? rating,
    int? reviewsCount,
  }) {
    return Coach(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      name: name ?? this.name,
      specialty: specialty ?? this.specialty,
      bio: bio ?? this.bio,
      city: city ?? this.city,
      modality: modality ?? this.modality,
      startingPrice: startingPrice ?? this.startingPrice,
      currencyCode: currencyCode ?? this.currencyCode,
      trialClassAvailable: trialClassAvailable ?? this.trialClassAvailable,
      trialClassPrice: trialClassPrice ?? this.trialClassPrice,
      isVerified: isVerified ?? this.isVerified,
      isAvailable: isAvailable ?? this.isAvailable,
      photos: photos ?? this.photos,
      rating: rating ?? this.rating,
      reviewsCount: reviewsCount ?? this.reviewsCount,
    );
  }
}
