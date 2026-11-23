import 'package:flutter_test/flutter_test.dart';
import 'package:gymder/domain/models/app_notification.dart';
import 'package:gymder/domain/models/plan.dart';
import 'package:gymder/infrastructure/datasources/mock/mock_catalog_data.dart';
import 'package:gymder/infrastructure/datasources/mock/mock_coaches_data.dart';

/// Comprueba que los datos mock respetan las reglas de las migraciones,
/// para que el día que se cambie por la base real nada se rompa.
void main() {
  group('datos mock de coaches', () {
    test('los ids son únicos', () {
      expect(
        kMockCoaches.map((c) => c.id).toSet(),
        hasLength(kMockCoaches.length),
      );
      expect(
        kMockCoaches.map((c) => c.profileId).toSet(),
        hasLength(kMockCoaches.length),
      );
    });

    test('Diego es el único inactivo y sin verificar', () {
      final inactive = kMockCoaches.where((c) => !c.isAvailable).toList();
      expect(inactive.map((c) => c.name), ['Diego Vargas']);
      expect(inactive.first.isVerified, isFalse);
    });

    test('si hay precio entonces hay moneda (ck_coaches_price_currency)', () {
      for (final c in kMockCoaches) {
        if (c.startingPrice != null || c.trialClassPrice != null) {
          expect(c.currencyCode, isNotNull, reason: c.name);
        }
      }
    });

    test('el precio de prueba solo existe si ofrece clase de prueba', () {
      for (final c in kMockCoaches) {
        if (c.trialClassPrice != null) {
          expect(c.trialClassAvailable, isTrue, reason: c.name);
        }
      }
    });

    test(
      'los perfiles de solicitudes y conversaciones existen en el catálogo',
      () {
        expect(
          kMockContactRequests.every(
            (request) => kMockProfileNames.containsKey(request.studentId),
          ),
          isTrue,
        );
        expect(
          kMockConversations.every((c) => c.studentId == kMockStudentId),
          isTrue,
        );
      },
    );
  });

  group('datos mock de conversaciones y mensajes', () {
    test('cada mensaje pertenece a una conversación existente', () {
      final ids = kMockConversations.map((c) => c.id).toSet();
      expect(
        kMockMessages.every((m) => ids.contains(m.conversationId)),
        isTrue,
      );
    });

    test('cada remitente es el estudiante o el perfil del coach', () {
      for (final m in kMockMessages) {
        final conv = kMockConversations.firstWhere(
          (c) => c.id == m.conversationId,
        );
        final coach = kMockCoaches.firstWhere((c) => c.id == conv.coachId);
        expect([conv.studentId, coach.profileId], contains(m.senderId));
      }
    });

    test('un mensaje leído no puede leerse antes de enviarse', () {
      for (final m in kMockMessages) {
        if (m.readAt != null) {
          expect(m.readAt!.isBefore(m.sentAt), isFalse);
        }
      }
    });

    test('las conversaciones vienen de solicitudes aceptadas', () {
      for (final conv in kMockConversations) {
        expect(
          kMockContactRequests.any(
            (r) =>
                r.studentId == conv.studentId &&
                r.coachId == conv.coachId &&
                r.status.name == 'accepted',
          ),
          isTrue,
        );
      }
    });
  });

  group('datos mock del catálogo', () {
    test('tiene las mismas cantidades que seed/seed.sql', () {
      expect(kMockFavorites, hasLength(3));
      expect(kMockContactRequests, hasLength(3));
      expect(kMockPlans, hasLength(8));
      expect(kMockReviews, hasLength(1));
      expect(kMockNotifications, hasLength(6));
      expect(kMockAds, hasLength(2));
      expect(kMockAdEvents, hasLength(3));
    });

    test('cada coach tiene como máximo un plan por nivel', () {
      final keys = kMockPlans.map((p) => '${p.coachId}-${p.tier.name}');
      expect(keys.toSet(), hasLength(kMockPlans.length));
    });

    test('Carlos y Ana tienen los tres niveles', () {
      for (final coachId in [kMockCoaches[0].id, kMockCoaches[1].id]) {
        final tiers = kMockPlans
            .where((p) => p.coachId == coachId)
            .map((p) => p.tier);
        expect(tiers.toSet(), PlanTier.values.toSet());
      }
    });

    test(
      'las reseñas son de estudiantes con conversación y únicas por par',
      () {
        final pairs = <String>{};
        for (final r in kMockReviews) {
          expect(r.rating, inInclusiveRange(1, 5));
          expect(
            kMockConversations.any(
              (c) => c.studentId == r.studentId && c.coachId == r.coachId,
            ),
            isTrue,
          );
          expect(pairs.add('${r.studentId}-${r.coachId}'), isTrue);
        }
      },
    );

    test('cada aviso tiene exactamente la referencia que exige su tipo', () {
      for (final n in kMockNotifications) {
        if (n.type == NotificationType.reviewCreated) {
          expect(n.reviewId, isNotNull);
          expect(n.contactRequestId, isNull);
        } else {
          expect(n.contactRequestId, isNotNull);
          expect(n.reviewId, isNull);
        }
      }
    });

    test(
      'un anuncio con fechas termina después de empezar (ck_ads_schedule)',
      () {
        for (final ad in kMockAds) {
          if (ad.startsAt != null && ad.endsAt != null) {
            expect(ad.startsAt!.isBefore(ad.endsAt!), isTrue);
          }
        }
      },
    );
  });
}
