/// Mensaje (tabla messages). El receptor no se guarda: se deduce de la conversación.
class ChatMessage {
  final String id;
  final String conversationId;
  final String senderId; // profiles.id de quien envía
  final String text; // messages.body
  final DateTime sentAt; // messages.created_at
  final DateTime? readAt; // messages.read_at (null = no leído)

  const ChatMessage({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.text,
    required this.sentAt,
    this.readAt,
  });

  bool get isRead => readAt != null;

  ChatMessage copyWith({
    String? id,
    String? conversationId,
    String? senderId,
    String? text,
    DateTime? sentAt,
    DateTime? readAt,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      text: text ?? this.text,
      sentAt: sentAt ?? this.sentAt,
      readAt: readAt ?? this.readAt,
    );
  }
}
