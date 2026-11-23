import '../../domain/models/chat_message.dart';
import '../../domain/repositories/chat_repository.dart';

/// Caso de uso: Enviar un mensaje de chat al coach
class SendChatMessage {
  final ChatRepository _repository;

  const SendChatMessage(this._repository);

  Future<void> call({
    required String senderId,
    required String receiverId,
    required String text,
  }) async {
    if (text.trim().isEmpty) return; // Validación de negocio: no enviar mensajes vacíos
    await _repository.sendMessage(
      senderId: senderId,
      receiverId: receiverId,
      text: text.trim(),
    );
  }
}

/// Caso de uso: Escuchar mensajes en tiempo real (Stream)
class WatchChatMessages {
  final ChatRepository _repository;

  const WatchChatMessages(this._repository);

  Stream<List<ChatMessage>> call({
    required String userId1,
    required String userId2,
  }) {
    return _repository.watchMessages(userId1: userId1, userId2: userId2);
  }
}
