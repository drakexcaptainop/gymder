enum ContactRequestStatus { pending, accepted, declined, cancelled }

/// Solicitud de contacto (tabla contact_requests): el "match" de Gymder.
/// El estudiante la envía; si el coach la acepta se abre la conversación.
class ContactRequest {
  final String id;
  final String studentId;
  final String coachId;
  final String? studentName;
  final String? studentAvatarPath;
  final String? coachName;
  final String? coachAvatarPath;
  final String? message;
  final ContactRequestStatus status;
  final DateTime createdAt;
  final DateTime? resolvedAt; // solo cuando status != pending

  const ContactRequest({
    required this.id,
    required this.studentId,
    required this.coachId,
    this.studentName,
    this.studentAvatarPath,
    this.coachName,
    this.coachAvatarPath,
    this.message,
    this.status = ContactRequestStatus.pending,
    required this.createdAt,
    this.resolvedAt,
  });

  ContactRequest copyWith({
    ContactRequestStatus? status,
    DateTime? resolvedAt,
  }) {
    return ContactRequest(
      id: id,
      studentId: studentId,
      coachId: coachId,
      studentName: studentName,
      studentAvatarPath: studentAvatarPath,
      coachName: coachName,
      coachAvatarPath: coachAvatarPath,
      message: message,
      status: status ?? this.status,
      createdAt: createdAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
    );
  }
}
