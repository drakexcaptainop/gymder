import 'package:flutter_test/flutter_test.dart';

import '../../support/fixtures.dart';

void main() {
  late Fixture f;
  setUp(() => f = Fixture());

  group('MockChatRepository', () {
    test('openConversation reutiliza la conversación existente', () {
      final existing = f.chat.openConversation(jorge, carlosCoach);
      expect(existing.id, convJorgeCarlos);
    });

    test(
      'openConversation crea una nueva para un par sin conversación',
      () async {
        final created = f.chat.openConversation(laura, anaCoach);

        expect(created.studentId, laura);
        expect(created.coachId, anaCoach);
        expect(await f.chat.getConversations(laura), hasLength(1));
        // Llamarla otra vez no duplica.
        expect(f.chat.openConversation(laura, anaCoach).id, created.id);
        expect(await f.chat.getConversations(laura), hasLength(1));
      },
    );

    test('sendMessage devuelve el mensaje guardado con id y fecha', () async {
      final sent = await f.chat.sendMessage(
        conversationId: convJorgeCarlos,
        senderId: jorge,
        text: 'hola',
      );

      expect(sent.id, isNotEmpty);
      expect(sent.conversationId, convJorgeCarlos);
      expect(sent.readAt, isNull);
      final all = await f.chat.getMessages(convJorgeCarlos);
      expect(all.last.id, sent.id);
    });

    test('sendMessage rechaza texto vacío con ArgumentError', () {
      expect(
        f.chat.sendMessage(
          conversationId: convJorgeCarlos,
          senderId: jorge,
          text: '  ',
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('sendMessage rechaza remitentes que no son de la conversación', () {
      expect(
        f.chat.sendMessage(
          conversationId: convJorgeCarlos,
          senderId: mateo,
          text: 'hola',
        ),
        throwsA(isA<StateError>()),
      );
    });

    test('sendMessage rechaza conversaciones inexistentes', () {
      expect(
        f.chat.sendMessage(
          conversationId: 'no-existe',
          senderId: jorge,
          text: 'hola',
        ),
        throwsA(isA<StateError>()),
      );
    });

    test('los mensajes de una conversación no aparecen en otra', () async {
      final other = f.chat.openConversation(laura, anaCoach);
      await f.chat.sendMessage(
        conversationId: other.id,
        senderId: laura,
        text: 'hola Ana',
      );

      expect(await f.chat.getMessages(other.id), hasLength(1));
      expect(await f.chat.getMessages(convJorgeCarlos), hasLength(3));
    });

    test(
      'watchMessages no emite por cambios en otras conversaciones',
      () async {
        final other = f.chat.openConversation(laura, anaCoach);
        final emissions = <int>[];
        final sub = f.chat
            .watchMessages(convJorgeCarlos)
            .listen((messages) => emissions.add(messages.length));

        await Future.delayed(const Duration(milliseconds: 20));
        await f.chat.sendMessage(
          conversationId: other.id,
          senderId: laura,
          text: 'hola Ana',
        );
        await Future.delayed(const Duration(milliseconds: 20));
        await sub.cancel();

        expect(emissions, [3]); // solo la emisión inicial
      },
    );

    test('markMessagesAsRead notifica al stream de la conversación', () async {
      final emissions = f.chat.watchMessages(convJorgeCarlos).take(2).toList();
      await f.chat.markMessagesAsRead(
        conversationId: convJorgeCarlos,
        readerId: jorge,
      );

      final result = await emissions;
      expect(result.last.last.isRead, isTrue);
    });
  });
}
