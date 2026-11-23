import '../models/contact_request.dart';

abstract class ContactRequestRepository {
  /// Envía una solicitud. Lanza StateError si ya hay una pendiente con ese coach
  /// o si el coach no existe / está inactivo.
  Future<ContactRequest> createRequest({
    required String studentId,
    required String coachId,
    String? message,
  });

  Future<List<ContactRequest>> getStudentRequests(String studentId);

  /// Solicitudes recibidas por un coach, más recientes primero.
  Future<List<ContactRequest>> getCoachRequests(String coachId);

  /// El coach acepta o rechaza una solicitud pendiente.
  Future<ContactRequest> resolveRequest({
    required String requestId,
    required String coachId,
    required ContactRequestStatus status,
  });

  /// Solo se puede cancelar una solicitud pendiente.
  Future<ContactRequest> cancelRequest(String requestId);
}
