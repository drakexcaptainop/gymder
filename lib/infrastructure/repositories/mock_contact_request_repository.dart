import 'dart:async';

import '../../domain/models/app_notification.dart';
import '../../domain/models/contact_request.dart';
import '../../domain/repositories/contact_request_repository.dart';
import '../datasources/mock/mock_catalog_data.dart';
import '../datasources/mock/mock_coaches_data.dart';
import 'mock_chat_repository.dart';
import 'mock_notification_repository.dart';

class MockContactRequestRepository implements ContactRequestRepository {
  final MockChatRepository _chat;
  final MockNotificationRepository _notifications;
  final List<ContactRequest> _requests = List.of(kMockContactRequests);

  MockContactRequestRepository(this._chat, this._notifications);

  @override
  Future<ContactRequest> createRequest({
    required String studentId,
    required String coachId,
    String? message,
  }) async {
    await Future.delayed(const Duration(milliseconds: 250));

    final coachMatches = kMockCoaches
        .where((c) => c.id == coachId && c.isAvailable)
        .toList();
    if (coachMatches.isEmpty) {
      throw StateError('El coach no existe o no está activo');
    }

    final hasPending = _requests.any(
      (r) =>
          r.studentId == studentId &&
          r.coachId == coachId &&
          r.status == ContactRequestStatus.pending,
    );
    if (hasPending) {
      throw StateError('Ya tienes una solicitud pendiente con este coach');
    }

    final trimmed = message?.trim();
    final request = ContactRequest(
      id: 'req_${DateTime.now().microsecondsSinceEpoch}',
      studentId: studentId,
      coachId: coachId,
      studentName: kMockProfileNames[studentId] ?? 'Estudiante',
      studentAvatarPath: kMockProfileAvatars[studentId],
      coachName: coachMatches.first.name,
      coachAvatarPath: kMockProfileAvatars[coachMatches.first.profileId],
      message: (trimmed == null || trimmed.isEmpty) ? null : trimmed,
      createdAt: DateTime.now().toUtc(),
    );
    _requests.add(request);

    // Trigger contact_requests_notify_created: avisa al coach.
    _notifications.add(
      recipientId: coachMatches.first.profileId,
      type: NotificationType.contactRequestCreated,
      contactRequestId: request.id,
    );

    return request;
  }

  @override
  Future<List<ContactRequest>> getStudentRequests(String studentId) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final mine = _requests.where((r) => r.studentId == studentId).toList();
    mine.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return mine;
  }

  @override
  Future<List<ContactRequest>> getCoachRequests(String coachId) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final received = _requests.where((r) => r.coachId == coachId).toList();
    received.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return received;
  }

  @override
  Future<ContactRequest> resolveRequest({
    required String requestId,
    required String coachId,
    required ContactRequestStatus status,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (status != ContactRequestStatus.accepted &&
        status != ContactRequestStatus.declined) {
      throw ArgumentError('El coach solo puede aceptar o rechazar solicitudes');
    }

    final index = _requests.indexWhere((r) => r.id == requestId);
    if (index == -1) throw StateError('Solicitud no encontrada');
    final current = _requests[index];
    if (current.coachId != coachId) {
      throw StateError('La solicitud no pertenece a este coach');
    }
    if (current.status != ContactRequestStatus.pending) {
      throw StateError('La solicitud ya fue resuelta');
    }

    final resolved = current.copyWith(
      status: status,
      resolvedAt: DateTime.now().toUtc(),
    );
    _requests[index] = resolved;
    if (status == ContactRequestStatus.accepted) {
      _chat.openConversation(resolved.studentId, resolved.coachId);
    }
    _notifications.add(
      recipientId: resolved.studentId,
      type: NotificationType.contactRequestResolved,
      contactRequestId: resolved.id,
    );
    return resolved;
  }

  @override
  Future<ContactRequest> cancelRequest(String requestId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _requests.indexWhere((r) => r.id == requestId);
    if (index == -1) throw StateError('Solicitud no encontrada');
    if (_requests[index].status != ContactRequestStatus.pending) {
      throw StateError('La solicitud ya fue resuelta');
    }
    final updated = _requests[index].copyWith(
      status: ContactRequestStatus.cancelled,
      resolvedAt: DateTime.now().toUtc(),
    );
    _requests[index] = updated;
    return updated;
  }
}
