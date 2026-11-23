import 'package:flutter_test/flutter_test.dart';
import 'package:gymder/domain/models/chat_message.dart';

void main() {
  group('ChatMessage', () {
    final sentAt = DateTime.utc(2026, 11, 3, 16, 5);

    ChatMessage build({DateTime? readAt}) => ChatMessage(
      id: 'm1',
      conversationId: 'conv1',
      senderId: 'p1',
      text: 'hola',
      sentAt: sentAt,
      readAt: readAt,
    );

    test('isRead es false mientras readAt sea null', () {
      expect(build().isRead, isFalse);
    });

    test('isRead es true cuando tiene readAt', () {
      expect(build(readAt: DateTime.utc(2026, 11, 3, 17)).isRead, isTrue);
    });

    test('copyWith conserva los demás campos', () {
      final copy = build().copyWith(text: 'chau');
      expect(copy.text, 'chau');
      expect(copy.id, 'm1');
      expect(copy.conversationId, 'conv1');
      expect(copy.senderId, 'p1');
      expect(copy.sentAt, sentAt);
    });

    test('copyWith(readAt) marca el mensaje como leído', () {
      final read = build().copyWith(readAt: DateTime.utc(2026, 11, 3, 18));
      expect(read.isRead, isTrue);
    });
  });
}
