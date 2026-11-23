import 'package:flutter_test/flutter_test.dart';
import 'package:gymder/domain/models/conversation.dart';
import 'package:gymder/domain/models/chat_message.dart';

void main() {
  test('Conversation guarda estudiante, coach y fecha', () {
    final createdAt = DateTime.utc(2026, 11, 3, 16);
    final conversation = Conversation(
      id: 'conv1',
      studentId: 's1',
      coachId: 'c1',
      createdAt: createdAt,
    );

    expect(conversation.id, 'conv1');
    expect(conversation.studentId, 's1');
    expect(conversation.coachId, 'c1');
    expect(conversation.createdAt, createdAt);
  });

  test('ConversationSummary expone datos listos para una fila de chat', () {
    final sentAt = DateTime.utc(2026, 11, 3, 16, 31);
    final message = ChatMessage(
      id: 'm1',
      conversationId: 'conv1',
      senderId: 'coach-profile',
      text: 'Hola',
      sentAt: sentAt,
    );
    final summary = ConversationSummary(
      conversationId: 'conv1',
      otherProfileId: 'coach-profile',
      otherDisplayName: 'Carlos',
      otherAvatarPath: 'avatar.jpg',
      lastMessage: message,
      unreadCount: 1,
      updatedAt: sentAt,
    );

    expect(summary.otherDisplayName, 'Carlos');
    expect(summary.lastMessage, same(message));
    expect(summary.unreadCount, 1);
  });
}
