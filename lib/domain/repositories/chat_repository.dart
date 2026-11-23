import '../models/chat_message.dart';

abstract class ChatRepository{
    Future<void> sendMessage({
        required String senderId,
        required String receiverId,
        required String text,
    });

    Future<List<ChatMessage>>getMessages({
        required String userId1,
        required String userId2,
    });

    Stream<List<ChatMessage>> watchMessages({
        required String userId1,
        required String userId2,
    });
}