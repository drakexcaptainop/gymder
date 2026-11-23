import 'package:flutter_test/flutter_test.dart';
import 'package:gymder/application/chat/chat_use_cases.dart';

import '../../support/fixtures.dart';

void main() {
  late Fixture f;
  setUp(() => f = Fixture());

  group('GetConversations', () {
    test('devuelve la conversación abierta de Jorge', () async {
      final list = await GetConversations(f.chat)(jorge);
      expect(list.map((c) => c.id), [convJorgeCarlos]);
    });

    test(
      'un estudiante sin solicitudes aceptadas no tiene conversaciones',
      () async {
        expect(await GetConversations(f.chat)(laura), isEmpty);
      },
    );
  });

  group('GetConversationSummaries', () {
    test('crea una bandeja útil para el estudiante', () async {
      final summaries = await GetConversationSummaries(f.chat)(jorge);
      expect(summaries, hasLength(1));
      expect(summaries.single.otherProfileId, carlosProfile);
      expect(summaries.single.otherDisplayName, 'Carlos Mendoza');
      expect(summaries.single.lastMessage?.text, contains('botella'));
      expect(summaries.single.unreadCount, 1);
    });

    test('crea una bandeja útil para el coach', () async {
      final summaries = await GetConversationSummaries(f.chat)(carlosProfile);
      expect(summaries, hasLength(1));
      expect(summaries.single.otherProfileId, jorge);
      expect(summaries.single.otherDisplayName, 'Jorge Barahona');
      expect(summaries.single.otherAvatarPath, isNotNull);
    });
  });

  group('GetChatMessages', () {
    test('devuelve el historial en orden ascendente', () async {
      final messages = await GetChatMessages(f.chat)(convJorgeCarlos);
      expect(messages, hasLength(3));
      for (var i = 1; i < messages.length; i++) {
        expect(messages[i].sentAt.isAfter(messages[i - 1].sentAt), isTrue);
      }
    });

    test('una conversación inexistente no tiene mensajes', () async {
      expect(await GetChatMessages(f.chat)('no-existe'), isEmpty);
    });
  });

  group('SendChatMessage', () {
    test('envía el mensaje recortando espacios', () async {
      final sent = await SendChatMessage(f.chat)(
        conversationId: convJorgeCarlos,
        senderId: jorge,
        text: '  hola coach  ',
      );

      expect(sent, isNotNull);
      expect(sent!.text, 'hola coach');
      expect(sent.senderId, jorge);
      expect(sent.isRead, isFalse);
      expect(await GetChatMessages(f.chat)(convJorgeCarlos), hasLength(4));
    });

    test('ignora mensajes vacíos o solo espacios', () async {
      final result = await SendChatMessage(f.chat)(
        conversationId: convJorgeCarlos,
        senderId: jorge,
        text: '   ',
      );

      expect(result, isNull);
      expect(await GetChatMessages(f.chat)(convJorgeCarlos), hasLength(3));
    });

    test('rechaza mensajes de más de 2000 caracteres', () async {
      final result = await SendChatMessage(f.chat)(
        conversationId: convJorgeCarlos,
        senderId: jorge,
        text: 'a' * 2001,
      );
      expect(result, isNull);
    });

    test('acepta exactamente 2000 caracteres', () async {
      final result = await SendChatMessage(f.chat)(
        conversationId: convJorgeCarlos,
        senderId: jorge,
        text: 'a' * 2000,
      );
      expect(result, isNotNull);
    });

    test('el coach también puede escribir en su conversación', () async {
      final sent = await SendChatMessage(f.chat)(
        conversationId: convJorgeCarlos,
        senderId: carlosProfile,
        text: 'nos vemos el martes',
      );
      expect(sent, isNotNull);
    });

    test('alguien ajeno a la conversación no puede escribir', () async {
      expect(
        SendChatMessage(f.chat)(
          conversationId: convJorgeCarlos,
          senderId: laura,
          text: 'hola',
        ),
        throwsA(isA<StateError>()),
      );
    });
  });

  group('WatchChatMessages', () {
    test(
      'emite el historial al conectar y de nuevo al llegar un mensaje',
      () async {
        final emissions = WatchChatMessages(f.chat)(
          convJorgeCarlos,
        ).take(2).toList();

        await SendChatMessage(f.chat)(
          conversationId: convJorgeCarlos,
          senderId: jorge,
          text: 'nuevo mensaje',
        );

        final result = await emissions;
        expect(result[0], hasLength(3));
        expect(result[1], hasLength(4));
        expect(result[1].last.text, 'nuevo mensaje');
      },
    );
  });

  group('MarkChatMessagesRead', () {
    test('marca solamente los mensajes entrantes pendientes', () async {
      final count = await MarkChatMessagesRead(f.chat)(
        conversationId: convJorgeCarlos,
        readerId: jorge,
      );
      expect(count, 1);
      expect(
        (await GetConversationSummaries(f.chat)(jorge)).single.unreadCount,
        0,
      );
      expect(
        await MarkChatMessagesRead(f.chat)(
          conversationId: convJorgeCarlos,
          readerId: jorge,
        ),
        0,
      );
    });

    test('rechaza a quien no participa en la conversación', () {
      expect(
        MarkChatMessagesRead(f.chat)(
          conversationId: convJorgeCarlos,
          readerId: mateo,
        ),
        throwsA(isA<StateError>()),
      );
    });
  });
}
