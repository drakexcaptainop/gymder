-- Gymder: mock data for the SQLite implementation.
-- Run after the migrations. Notifications and the accepted-request conversation are created
-- by triggers where the schema defines them; conversations for already-accepted requests are
-- inserted explicitly because those requests are inserted in their final state.
-- Timestamps use the ISO format YYYY-MM-DDTHH:MM:SS.sssZ (UTC).

PRAGMA foreign_keys = ON;

-- ---------------------------------------------------------------------------
-- Profiles (1 admin, 3 coaches, 3 students)
-- ---------------------------------------------------------------------------
INSERT INTO profiles (id, full_name, role, avatar_path, created_at, updated_at) VALUES
  ('10000000-0000-4000-8000-000000000001', 'Admin Gymder',   'student', NULL,                             '2026-10-01T12:00:00.000Z', '2026-10-01T12:00:00.000Z'),
  ('10000000-0000-4000-8000-000000000002', 'Carlos Mendoza', 'coach',   'avatars/carlos-mendoza.jpg',      '2026-10-02T12:00:00.000Z', '2026-10-02T12:00:00.000Z'),
  ('10000000-0000-4000-8000-000000000003', 'Ana Rojas',      'coach',   'avatars/ana-rojas.jpg',           '2026-10-03T12:00:00.000Z', '2026-10-03T12:00:00.000Z'),
  ('10000000-0000-4000-8000-000000000004', 'Diego Vargas',   'coach',   NULL,                              '2026-10-04T12:00:00.000Z', '2026-10-04T12:00:00.000Z'),
  ('10000000-0000-4000-8000-000000000005', 'Jorge Barahona', 'student', 'avatars/jorge-barahona.jpg',      '2026-10-05T12:00:00.000Z', '2026-10-05T12:00:00.000Z'),
  ('10000000-0000-4000-8000-000000000006', 'Laura Camacho',  'student', NULL,                              '2026-10-06T12:00:00.000Z', '2026-10-06T12:00:00.000Z'),
  ('10000000-0000-4000-8000-000000000007', 'Mateo Quispe',   'student', NULL,                              '2026-10-07T12:00:00.000Z', '2026-10-07T12:00:00.000Z');

-- ---------------------------------------------------------------------------
-- Coaches (Carlos verified, Ana verified, Diego pending verification and inactive)
-- ---------------------------------------------------------------------------
INSERT INTO coaches (id, profile_id, specialty, bio, city, modality, starting_price, trial_class_available,
                     trial_class_price, currency_code, status, is_verified, verified_at, verified_by,
                     created_at, updated_at) VALUES
  ('20000000-0000-4000-8000-000000000001', '10000000-0000-4000-8000-000000000002',
   'Fuerza e hipertrofia', 'Entrenador personal con 8 años de experiencia en fuerza y ganancia muscular.',
   'La Paz', 'in_person', 150.00, 1, 50.00, 'BOB', 'active', 1,
   '2026-10-10T12:00:00.000Z', '10000000-0000-4000-8000-000000000001',
   '2026-10-02T13:00:00.000Z', '2026-10-10T12:00:00.000Z'),
  ('20000000-0000-4000-8000-000000000002', '10000000-0000-4000-8000-000000000003',
   'Yoga y movilidad', 'Instructora de yoga y movilidad. Sesiones en línea para todos los niveles.',
   'Cochabamba', 'online', 120.00, 1, 40.00, 'BOB', 'active', 1,
   '2026-10-11T12:00:00.000Z', '10000000-0000-4000-8000-000000000001',
   '2026-10-03T13:00:00.000Z', '2026-10-11T12:00:00.000Z'),
  ('20000000-0000-4000-8000-000000000003', '10000000-0000-4000-8000-000000000004',
   'Funcional y CrossFit', 'Entrenamiento funcional, presencial y en línea.',
   'Santa Cruz', 'hybrid', 180.00, 0, NULL, 'BOB', 'inactive', 0,
   NULL, NULL,
   '2026-10-04T13:00:00.000Z', '2026-10-04T13:00:00.000Z');

-- ---------------------------------------------------------------------------
-- Plans (tiers: start, plus, pro)
-- ---------------------------------------------------------------------------
INSERT INTO plans (id, coach_id, tier, title, description, price, currency_code, status, created_at, updated_at) VALUES
  ('30000000-0000-4000-8000-000000000001', '20000000-0000-4000-8000-000000000001', 'start', 'Start',  '4 sesiones al mes con rutina base.',                            250.00, 'BOB', 'active',   '2026-10-12T12:00:00.000Z', '2026-10-12T12:00:00.000Z'),
  ('30000000-0000-4000-8000-000000000002', '20000000-0000-4000-8000-000000000001', 'plus',  'Plus',   '8 sesiones al mes con rutina personalizada y seguimiento.',     450.00, 'BOB', 'active',   '2026-10-12T12:05:00.000Z', '2026-10-12T12:05:00.000Z'),
  ('30000000-0000-4000-8000-000000000003', '20000000-0000-4000-8000-000000000001', 'pro',   'Pro',    '12 sesiones al mes, rutina personalizada y plan de nutrición.', 600.00, 'BOB', 'active',   '2026-10-12T12:10:00.000Z', '2026-10-12T12:10:00.000Z'),
  ('30000000-0000-4000-8000-000000000004', '20000000-0000-4000-8000-000000000002', 'start', 'Start',  '4 clases de yoga en vivo por videollamada.',                    120.00, 'BOB', 'active',   '2026-10-12T12:15:00.000Z', '2026-10-12T12:15:00.000Z'),
  ('30000000-0000-4000-8000-000000000005', '20000000-0000-4000-8000-000000000002', 'plus',  'Plus',   '8 clases en vivo y rutina de movilidad.',                       220.00, 'BOB', 'active',   '2026-10-12T12:20:00.000Z', '2026-10-12T12:20:00.000Z'),
  ('30000000-0000-4000-8000-000000000006', '20000000-0000-4000-8000-000000000002', 'pro',   'Pro',    '12 clases en vivo, movilidad y seguimiento semanal.',           300.00, 'BOB', 'active',   '2026-10-12T12:25:00.000Z', '2026-10-12T12:25:00.000Z'),
  ('30000000-0000-4000-8000-000000000007', '20000000-0000-4000-8000-000000000003', 'start', 'Start',  'Entrenamiento funcional mensual.',                              180.00, 'BOB', 'inactive', '2026-10-12T12:30:00.000Z', '2026-10-12T12:30:00.000Z'),
  ('30000000-0000-4000-8000-000000000008', '20000000-0000-4000-8000-000000000003', 'pro',   'Pro',    'Plan funcional trimestral.',                                   1500.00, 'BOB', 'inactive', '2026-10-12T12:35:00.000Z', '2026-10-12T12:35:00.000Z');

-- ---------------------------------------------------------------------------
-- Coach gallery
-- ---------------------------------------------------------------------------
INSERT INTO coach_media (id, coach_id, image_url, sort_order, created_at, updated_at) VALUES
  ('40000000-0000-4000-8000-000000000001', '20000000-0000-4000-8000-000000000001', 'https://images.unsplash.com/photo-1567013127542-490d757e51fc?w=800', 0, '2026-10-13T12:00:00.000Z', '2026-10-13T12:00:00.000Z'),
  ('40000000-0000-4000-8000-000000000002', '20000000-0000-4000-8000-000000000001', 'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=800', 1, '2026-10-13T12:01:00.000Z', '2026-10-13T12:01:00.000Z'),
  ('40000000-0000-4000-8000-000000000003', '20000000-0000-4000-8000-000000000002', 'https://images.unsplash.com/photo-1518611012118-696072aa579a?w=800', 0, '2026-10-13T12:02:00.000Z', '2026-10-13T12:02:00.000Z');

-- ---------------------------------------------------------------------------
-- Favorites
-- ---------------------------------------------------------------------------
INSERT INTO favorites (profile_id, coach_id, created_at) VALUES
  ('10000000-0000-4000-8000-000000000005', '20000000-0000-4000-8000-000000000001', '2026-11-01T10:00:00.000Z'),
  ('10000000-0000-4000-8000-000000000005', '20000000-0000-4000-8000-000000000002', '2026-11-01T10:05:00.000Z'),
  ('10000000-0000-4000-8000-000000000006', '20000000-0000-4000-8000-000000000002', '2026-11-02T09:00:00.000Z');

-- ---------------------------------------------------------------------------
-- Contact requests (inserting fires the coach notification trigger)
--   Jorge -> Carlos: accepted     Laura -> Ana: pending     Mateo -> Carlos: declined
-- ---------------------------------------------------------------------------
INSERT INTO contact_requests (id, student_id, coach_id, message, status, created_at, updated_at, resolved_at) VALUES
  ('50000000-0000-4000-8000-000000000001', '10000000-0000-4000-8000-000000000005', '20000000-0000-4000-8000-000000000001',
   'Hola, quiero empezar a entrenar fuerza. ¿Tienes disponibilidad por las tardes?', 'accepted',
   '2026-11-03T14:00:00.000Z', '2026-11-03T16:00:00.000Z', '2026-11-03T16:00:00.000Z'),
  ('50000000-0000-4000-8000-000000000002', '10000000-0000-4000-8000-000000000006', '20000000-0000-4000-8000-000000000002',
   'Me interesa el yoga en línea para principiantes.', 'pending',
   '2026-11-18T09:30:00.000Z', '2026-11-18T09:30:00.000Z', NULL),
  ('50000000-0000-4000-8000-000000000003', '10000000-0000-4000-8000-000000000007', '20000000-0000-4000-8000-000000000001',
   '¿Haces planes para ganar masa muscular?', 'declined',
   '2026-11-05T11:00:00.000Z', '2026-11-05T18:00:00.000Z', '2026-11-05T18:00:00.000Z');

-- Conversation for the accepted request (inserted in its final state, so the accept trigger did not run).
INSERT INTO conversations (id, student_id, coach_id, created_at) VALUES
  ('60000000-0000-4000-8000-000000000001', '10000000-0000-4000-8000-000000000005', '20000000-0000-4000-8000-000000000001', '2026-11-03T16:00:00.000Z');

-- ---------------------------------------------------------------------------
-- Messages
-- ---------------------------------------------------------------------------
INSERT INTO messages (id, conversation_id, sender_id, body, created_at, updated_at, read_at) VALUES
  ('70000000-0000-4000-8000-000000000001', '60000000-0000-4000-8000-000000000001', '10000000-0000-4000-8000-000000000002',
   'Hola Jorge, claro. Tengo cupo martes y jueves a las 18:00.', '2026-11-03T16:05:00.000Z', '2026-11-03T16:05:00.000Z', '2026-11-03T16:20:00.000Z'),
  ('70000000-0000-4000-8000-000000000002', '60000000-0000-4000-8000-000000000001', '10000000-0000-4000-8000-000000000005',
   'Perfecto, reservo una clase de prueba el martes.', '2026-11-03T16:22:00.000Z', '2026-11-03T16:22:00.000Z', '2026-11-03T16:30:00.000Z'),
  ('70000000-0000-4000-8000-000000000003', '60000000-0000-4000-8000-000000000001', '10000000-0000-4000-8000-000000000002',
   '¡Genial! Trae ropa cómoda y una botella de agua.', '2026-11-03T16:31:00.000Z', '2026-11-03T16:31:00.000Z', NULL);

-- ---------------------------------------------------------------------------
-- Reviews (inserting fires the coach notification trigger; needs an existing conversation)
-- ---------------------------------------------------------------------------
INSERT INTO reviews (id, coach_id, student_id, rating, comment, created_at, updated_at) VALUES
  ('90000000-0000-4000-8000-000000000001', '20000000-0000-4000-8000-000000000001', '10000000-0000-4000-8000-000000000005', 5,
   'Excelente atención y rutina clara desde la primera clase.', '2026-11-11T08:00:00.000Z', '2026-11-11T08:00:00.000Z');

-- ---------------------------------------------------------------------------
-- Notifications
-- Created by triggers: coach notices for the 3 requests and for the review.
-- Inserted explicitly: student notices for the already-resolved requests (their triggers
-- only run on UPDATE).
-- ---------------------------------------------------------------------------
INSERT INTO notifications (recipient_id, notification_type, contact_request_id, created_at, updated_at) VALUES
  ('10000000-0000-4000-8000-000000000005', 'contact_request_resolved', '50000000-0000-4000-8000-000000000001', '2026-11-03T16:00:00.000Z', '2026-11-03T16:00:00.000Z'),
  ('10000000-0000-4000-8000-000000000007', 'contact_request_resolved', '50000000-0000-4000-8000-000000000003', '2026-11-05T18:00:00.000Z', '2026-11-05T18:00:00.000Z');

-- One notification already read by its coach (the others stay unread).
UPDATE notifications
   SET read_at = '2026-11-03T14:30:00.000Z'
 WHERE recipient_id = '10000000-0000-4000-8000-000000000002'
   AND notification_type = 'contact_request_created'
   AND contact_request_id = '50000000-0000-4000-8000-000000000001';

-- ---------------------------------------------------------------------------
-- Ads and ad events
-- ---------------------------------------------------------------------------
INSERT INTO ads (id, advertiser_name, title, image_url, destination_url, status, starts_at, ends_at, created_at, updated_at) VALUES
  ('a0000000-0000-4000-8000-000000000001', 'ProteinMax', '20% de descuento en proteína',
   'https://example.com/ads/proteinmax.jpg', 'https://example.com/proteinmax', 'active',
   '2026-11-01T00:00:00.000Z', '2026-12-31T23:59:59.000Z', '2026-10-30T12:00:00.000Z', '2026-10-30T12:00:00.000Z'),
  ('a0000000-0000-4000-8000-000000000002', 'FitWear', 'Ropa deportiva de temporada',
   NULL, 'https://example.com/fitwear', 'inactive',
   NULL, NULL, '2026-10-30T12:05:00.000Z', '2026-10-30T12:05:00.000Z');

INSERT INTO ad_events (id, ad_id, profile_id, event_type, created_at) VALUES
  ('b0000000-0000-4000-8000-000000000001', 'a0000000-0000-4000-8000-000000000001', '10000000-0000-4000-8000-000000000005', 'impression', '2026-11-15T10:00:00.000Z'),
  ('b0000000-0000-4000-8000-000000000002', 'a0000000-0000-4000-8000-000000000001', '10000000-0000-4000-8000-000000000005', 'click',      '2026-11-15T10:00:07.000Z'),
  ('b0000000-0000-4000-8000-000000000003', 'a0000000-0000-4000-8000-000000000001', NULL,                                   'impression', '2026-11-16T09:00:00.000Z');
