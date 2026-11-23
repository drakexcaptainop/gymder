import 'dart:async';
import '../../domain/models/chat_message.dart';
import '../../domain/repositories/chat_repository.dart';

class MockChatRepository implements ChatRepository {
  final List<ChatMessage> _messages = [
    ChatMessage(
      id: 'msg_1',
      senderId: 'coach_1',
      receiverId: 'student_me',
      text: '¡Hola! Vi que te interesó mi perfil. ¿Cuál es tu objetivo actual en el gym?',
      sentAt: DateTime.now().subtract(const Duration(minutes: 15)),
      isRead: true,
    ),
  ];

  final StreamController<List<ChatMessage>> _messagesStreamController =
      StreamController<List<ChatMessage>>.broadcast();

  @override
  Future<void> sendMessage({
    required String senderId,
    required String receiverId,
    required String text,
  }) async {
    await Future.delayed(const Duration(milliseconds: 150));

    final newMessage = ChatMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      senderId: senderId,
      receiverId: receiverId,
      text: text,
      sentAt: DateTime.now(),
    );

    _messages.add(newMessage);
    _messagesStreamController.add(List.unmodifiable(_messages));

    _simulateCoachAutoReply(coachId: receiverId, studentId: senderId);
  }

  @override
  Future<List<ChatMessage>> getMessages({
    required String userId1,
    required String userId2,
  }) async {
    await Future.delayed(const Duration(milliseconds: 250));
    return List.unmodifiable(_filterConversation(userId1, userId2));
  }

  @override
  Stream<List<ChatMessage>> watchMessages({
    required String userId1,
    required String userId2,
  }) {
    scheduleMicrotask(() {
      _messagesStreamController.add(_filterConversation(userId1, userId2));
    });
    return _messagesStreamController.stream;
  }

  List<ChatMessage> _filterConversation(String u1, String u2) {
    return _messages.where((m) {
      return (m.senderId == u1 && m.receiverId == u2) ||
          (m.senderId == u2 && m.receiverId == u1);
    }).toList();
  }

  void _simulateCoachAutoReply({
    required String coachId,
    required String studentId,
  }) {
    Future.delayed(const Duration(seconds: 2), () {
      final autoReply = ChatMessage(
        id: 'msg_reply_${DateTime.now().millisecondsSinceEpoch}',
        senderId: coachId,
        receiverId: studentId,
        text: '¡Entendido! Con gusto te armo un plan adaptado a tus horarios de la universidad.',
        sentAt: DateTime.now(),
      );
      _messages.add(autoReply);
      _messagesStreamController.add(List.unmodifiable(_messages));
    });
  }
}
