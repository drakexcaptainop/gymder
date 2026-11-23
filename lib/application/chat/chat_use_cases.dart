import '../../domain/models/chat_message.dart';
import '../../domain/models/conversation.dart';
import '../../domain/repositories/chat_repository.dart';

/// Lista las conversaciones abiertas del estudiante.
class GetConversations {
  final ChatRepository _repository;

  const GetConversations(this._repository);

  Future<List<Conversation>> call(String studentId) =>
      _repository.getConversations(studentId);
}

/// Bandeja de conversaciones enriquecida para estudiante o coach.
class GetConversationSummaries {
  final ChatRepository _repository;

  const GetConversationSummaries(this._repository);

  Future<List<ConversationSummary>> call(String profileId) =>
      _repository.getConversationSummaries(profileId);
}

/// Historial de una conversación.
class GetChatMessages {
  final ChatRepository _repository;

  const GetChatMessages(this._repository);

  Future<List<ChatMessage>> call(String conversationId) =>
      _repository.getMessages(conversationId);
}

/// Envía un mensaje (valida que no esté vacío ni exceda 2000 caracteres).
class SendChatMessage {
  final ChatRepository _repository;

  const SendChatMessage(this._repository);

  Future<ChatMessage?> call({
    required String conversationId,
    required String senderId,
    required String text,
  }) async {
    final body = text.trim();
    if (body.isEmpty || body.length > 2000) return null;
    return _repository.sendMessage(
      conversationId: conversationId,
      senderId: senderId,
      text: body,
    );
  }
}

class MarkChatMessagesRead {
  final ChatRepository _repository;

  const MarkChatMessagesRead(this._repository);

  Future<int> call({
    required String conversationId,
    required String readerId,
  }) => _repository.markMessagesAsRead(
    conversationId: conversationId,
    readerId: readerId,
  );
}

/// Mensajes en tiempo real.
class WatchChatMessages {
  final ChatRepository _repository;

  const WatchChatMessages(this._repository);

  Stream<List<ChatMessage>> call(String conversationId) =>
      _repository.watchMessages(conversationId);
}
