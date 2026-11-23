class Coach {
    final String id;
    final String name;
    final int age;
    final String bio;
    final List<String> photos;
    final List<String> specialities;
    final double rating;
    final int reviewsCount;
    final double monthlyPrice;
    final String location;
    final bool isAvailable;

    const Coach({
        required this.id,
        required this.name,
        required this.age,
        required this.bio,
        required this.photos,
        required this.specialities,
        required this.rating,
        required this.reviewsCount,
        required this.monthlyPrice,
        required this.location,
        this.isAvailable = true,
    });

    Coach copyWith({
        String? id,
        String? name,
        int? age,
        String? bio,
        List<String>? photos,
        List<String>? specialities,
        double? rating,
        int? reviewsCount,
        double? monthlyPrice,
        String? location,
        bool? isAvailable,
    }){
        return Coach(
            id: id ?? this.id,
            name: name ?? this.name,
            age: age ?? this.age,
            bio: bio ?? this.bio,
            photos: photos ?? this.photos,
            specialities: specialities ?? this.specialities,
            rating: rating ?? this.rating,
            reviewsCount: reviewsCount ?? this.reviewsCount,
            monthlyPrice: monthlyPrice ?? this.monthlyPrice,
            location: location ?? this.location,
            isAvailable: isAvailable ?? this.isAvailable,
        )
    }
}
