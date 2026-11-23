import '../models/chat_message.dart';
import '../models/conversation.dart';

abstract class ChatRepository {
  /// Conversaciones abiertas del estudiante (las que salen de solicitudes aceptadas).
  Future<List<Conversation>> getConversations(String studentId);

  /// Resúmenes para la bandeja de chats de un estudiante o coach (profiles.id).
  Future<List<ConversationSummary>> getConversationSummaries(String profileId);

  /// Historial ascendente por fecha.
  Future<List<ChatMessage>> getMessages(String conversationId);

  /// Devuelve el mensaje ya guardado (con id y fecha definitivos).
  Future<ChatMessage> sendMessage({
    required String conversationId,
    required String senderId,
    required String text,
  });

  /// Marca como leídos los mensajes enviados por la contraparte.
  Future<int> markMessagesAsRead({
    required String conversationId,
    required String readerId,
  });

  /// Emite la lista completa al conectar y de nuevo en cada cambio.
  Stream<List<ChatMessage>> watchMessages(String conversationId);
}
