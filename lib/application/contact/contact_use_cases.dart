import '../../domain/models/contact_request.dart';
import '../../domain/repositories/contact_request_repository.dart';

/// El estudiante pide contactar a un coach (el "match").
class RequestContact {
  final ContactRequestRepository _repository;

  const RequestContact(this._repository);

  Future<ContactRequest> call({
    required String studentId,
    required String coachId,
    String? message,
  }) => _repository.createRequest(
    studentId: studentId,
    coachId: coachId,
    message: message,
  );
}

/// Solicitudes enviadas por el estudiante, más recientes primero.
class GetMyContactRequests {
  final ContactRequestRepository _repository;

  const GetMyContactRequests(this._repository);

  Future<List<ContactRequest>> call(String studentId) =>
      _repository.getStudentRequests(studentId);
}

/// Solicitudes recibidas en la bandeja del coach.
class GetCoachContactRequests {
  final ContactRequestRepository _repository;

  const GetCoachContactRequests(this._repository);

  Future<List<ContactRequest>> call(String coachId) =>
      _repository.getCoachRequests(coachId);
}

/// Acepta o rechaza una solicitud pendiente desde la cuenta del coach.
class ResolveContactRequest {
  final ContactRequestRepository _repository;

  const ResolveContactRequest(this._repository);

  Future<ContactRequest> call({
    required String requestId,
    required String coachId,
    required ContactRequestStatus status,
  }) => _repository.resolveRequest(
    requestId: requestId,
    coachId: coachId,
    status: status,
  );
}

/// Cancela una solicitud pendiente.
class CancelContactRequest {
  final ContactRequestRepository _repository;

  const CancelContactRequest(this._repository);

  Future<ContactRequest> call(String requestId) =>
      _repository.cancelRequest(requestId);
}
