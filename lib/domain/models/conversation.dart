import 'chat_message.dart';

/// Conversación entre un estudiante y un coach (tabla conversations).
/// Se crea cuando el coach acepta una solicitud de contacto.
class Conversation {
  final String id;
  final String studentId; // profiles.id del estudiante
  final String coachId; // coaches.id
  final DateTime createdAt;

  const Conversation({
    required this.id,
    required this.studentId,
    required this.coachId,
    required this.createdAt,
  });
}

/// Proyección lista para pintar una fila de chat para cualquier rol.
class ConversationSummary {
  final String conversationId;
  final String otherProfileId;
  final String otherDisplayName;
  final String? otherAvatarPath;
  final ChatMessage? lastMessage;
  final int unreadCount;
  final DateTime updatedAt;

  const ConversationSummary({
    required this.conversationId,
    required this.otherProfileId,
    required this.otherDisplayName,
    this.otherAvatarPath,
    this.lastMessage,
    required this.unreadCount,
    required this.updatedAt,
  });
}
