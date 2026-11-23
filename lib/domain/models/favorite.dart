class Favorite{
    final String id;
    final String studentId;
    final String coachId;
    final DateTime createdAt;

    const Favorite({
        required this.id,
        required this.studentId,
        required this.coachId,
        required this.createdAt,
    });

    Favorite copyWith({
        String? id,
        String? studentId,
        String? coachId,
        DateTime? createdAt,
    }){
        return Favorite(
            id: id ?? this.id,
            stuendId: studentId ?? this.studentId,
            coachId: coachId ?? this.coachId,
            createdAt: createdAt ?? this.createdAt,
        );
    }

}