import 'dart:async';

import '../../domain/models/chat_message.dart';
import '../../domain/models/conversation.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/mock/mock_catalog_data.dart';
import '../datasources/mock/mock_coaches_data.dart';

class MockChatRepository implements ChatRepository {
  final List<Conversation> _conversations = List.of(kMockConversations);
  final List<ChatMessage> _messages = List.of(kMockMessages);

  // Emite el id de la conversación que cambió.
  final StreamController<String> _changes =
      StreamController<String>.broadcast();

  /// Lo usa MockContactRequestRepository cuando el coach "acepta" (como el trigger
  /// contact_requests_open_conversation de la migración). Reutiliza si ya existe.
  Conversation openConversation(String studentId, String coachId) {
    for (final c in _conversations) {
      if (c.studentId == studentId && c.coachId == coachId) return c;
    }
    final conversation = Conversation(
      id: 'conv_${DateTime.now().microsecondsSinceEpoch}',
      studentId: studentId,
      coachId: coachId,
      createdAt: DateTime.now().toUtc(),
    );
    _conversations.add(conversation);
    return conversation;
  }

  @override
  Future<List<Conversation>> getConversations(String studentId) async {
    await Future.delayed(const Duration(milliseconds: 250));
    return _conversations.where((c) => c.studentId == studentId).toList();
  }

  @override
  Future<List<ConversationSummary>> getConversationSummaries(
    String profileId,
  ) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final summaries = <ConversationSummary>[];
    for (final conversation in _conversations) {
      final coach = kMockCoaches.firstWhere(
        (c) => c.id == conversation.coachId,
      );
      final isStudent = conversation.studentId == profileId;
      final isCoach = coach.profileId == profileId;
      if (!isStudent && !isCoach) continue;

      final otherProfileId = isStudent
          ? coach.profileId
          : conversation.studentId;
      final messages = _forConversation(conversation.id);
      final lastMessage = messages.isEmpty ? null : messages.last;
      summaries.add(
        ConversationSummary(
          conversationId: conversation.id,
          otherProfileId: otherProfileId,
          otherDisplayName: kMockProfileNames[otherProfileId] ?? 'Usuario',
          otherAvatarPath: kMockProfileAvatars[otherProfileId],
          lastMessage: lastMessage,
          unreadCount: messages
              .where((m) => m.senderId != profileId && m.readAt == null)
              .length,
          updatedAt: lastMessage?.sentAt ?? conversation.createdAt,
        ),
      );
    }
    summaries.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return summaries;
  }

  @override
  Future<List<ChatMessage>> getMessages(String conversationId) async {
    await Future.delayed(const Duration(milliseconds: 250));
    return _forConversation(conversationId);
  }

  @override
  Future<ChatMessage> sendMessage({
    required String conversationId,
    required String senderId,
    required String text,
  }) async {
    await Future.delayed(const Duration(milliseconds: 150));

    final body = text.trim();
    if (body.isEmpty) {
      throw ArgumentError('El mensaje no puede estar vacío');
    }
    if (!_isParticipant(conversationId, senderId)) {
      throw StateError('El remitente no pertenece a esta conversación');
    }

    final message = ChatMessage(
      id: 'msg_${DateTime.now().microsecondsSinceEpoch}',
      conversationId: conversationId,
      senderId: senderId,
      text: body,
      sentAt: DateTime.now().toUtc(),
    );
    _messages.add(message);
    _changes.add(conversationId);
    return message;
  }

  @override
  Future<int> markMessagesAsRead({
    required String conversationId,
    required String readerId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (!_isParticipant(conversationId, readerId)) {
      throw StateError('El lector no pertenece a esta conversación');
    }

    final readAt = DateTime.now().toUtc();
    var count = 0;
    for (var i = 0; i < _messages.length; i++) {
      final message = _messages[i];
      if (message.conversationId == conversationId &&
          message.senderId != readerId &&
          message.readAt == null) {
        _messages[i] = message.copyWith(readAt: readAt);
        count++;
      }
    }
    if (count > 0) _changes.add(conversationId);
    return count;
  }

  @override
  Stream<List<ChatMessage>> watchMessages(String conversationId) {
    return Stream.multi((controller) {
      controller.add(_forConversation(conversationId));
      final subscription = _changes.stream
          .where((changedId) => changedId == conversationId)
          .listen((_) => controller.add(_forConversation(conversationId)));
      controller.onCancel = subscription.cancel;
    });
  }

  List<ChatMessage> _forConversation(String conversationId) {
    final list = _messages
        .where((m) => m.conversationId == conversationId)
        .toList();
    list.sort((a, b) => a.sentAt.compareTo(b.sentAt));
    return list;
  }

  // Remitente válido: el estudiante o el perfil del coach de la conversación
  // (regla del trigger messages_sender_in_conversation).
  bool _isParticipant(String conversationId, String senderId) {
    for (final c in _conversations) {
      if (c.id != conversationId) continue;
      if (c.studentId == senderId) return true;
      for (final coach in kMockCoaches) {
        if (coach.id == c.coachId && coach.profileId == senderId) return true;
      }
    }
    return false;
  }
}
