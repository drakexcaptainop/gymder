-- Gymder: mock SQLite triggers. Source of truth: gymder.dbml.
-- Data-integrity rules only. Anything that depends on "who is the caller" (RLS in the original
-- design) is left to the backend, because SQLite has no users or policies.

-- ---------------------------------------------------------------------------
-- updated_at maintenance (SQLite has no BEFORE-trigger row rewriting, so this runs AFTER UPDATE)
-- ---------------------------------------------------------------------------
CREATE TRIGGER profiles_set_updated_at
AFTER UPDATE ON profiles
FOR EACH ROW
WHEN NEW.updated_at = OLD.updated_at
BEGIN
  UPDATE profiles SET updated_at = (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')) WHERE id = NEW.id;
END;

CREATE TRIGGER coaches_set_updated_at
AFTER UPDATE ON coaches
FOR EACH ROW
WHEN NEW.updated_at = OLD.updated_at
BEGIN
  UPDATE coaches SET updated_at = (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')) WHERE id = NEW.id;
END;

CREATE TRIGGER plans_set_updated_at
AFTER UPDATE ON plans
FOR EACH ROW
WHEN NEW.updated_at = OLD.updated_at
BEGIN
  UPDATE plans SET updated_at = (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')) WHERE id = NEW.id;
END;

CREATE TRIGGER coach_media_set_updated_at
AFTER UPDATE ON coach_media
FOR EACH ROW
WHEN NEW.updated_at = OLD.updated_at
BEGIN
  UPDATE coach_media SET updated_at = (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')) WHERE id = NEW.id;
END;

CREATE TRIGGER contact_requests_set_updated_at
AFTER UPDATE ON contact_requests
FOR EACH ROW
WHEN NEW.updated_at = OLD.updated_at
BEGIN
  UPDATE contact_requests SET updated_at = (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')) WHERE id = NEW.id;
END;

CREATE TRIGGER messages_set_updated_at
AFTER UPDATE ON messages
FOR EACH ROW
WHEN NEW.updated_at = OLD.updated_at
BEGIN
  UPDATE messages SET updated_at = (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')) WHERE id = NEW.id;
END;

CREATE TRIGGER bookings_set_updated_at
AFTER UPDATE ON bookings
FOR EACH ROW
WHEN NEW.updated_at = OLD.updated_at
BEGIN
  UPDATE bookings SET updated_at = (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')) WHERE id = NEW.id;
END;

CREATE TRIGGER reviews_set_updated_at
AFTER UPDATE ON reviews
FOR EACH ROW
WHEN NEW.updated_at = OLD.updated_at
BEGIN
  UPDATE reviews SET updated_at = (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')) WHERE id = NEW.id;
END;

CREATE TRIGGER notifications_set_updated_at
AFTER UPDATE ON notifications
FOR EACH ROW
WHEN NEW.updated_at = OLD.updated_at
BEGIN
  UPDATE notifications SET updated_at = (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')) WHERE id = NEW.id;
END;

CREATE TRIGGER ads_set_updated_at
AFTER UPDATE ON ads
FOR EACH ROW
WHEN NEW.updated_at = OLD.updated_at
BEGIN
  UPDATE ads SET updated_at = (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')) WHERE id = NEW.id;
END;

-- ---------------------------------------------------------------------------
-- contact_requests
-- ---------------------------------------------------------------------------
-- A new contact request notifies the coach.
CREATE TRIGGER contact_requests_notify_created
AFTER INSERT ON contact_requests
FOR EACH ROW
BEGIN
  INSERT INTO notifications (recipient_id, notification_type, contact_request_id)
  SELECT c.profile_id, 'contact_request_created', NEW.id
  FROM coaches c
  WHERE c.id = NEW.coach_id;
END;

-- Accepting a request creates or reuses the conversation for the pair.
CREATE TRIGGER contact_requests_open_conversation
AFTER UPDATE OF status ON contact_requests
FOR EACH ROW
WHEN OLD.status = 'pending' AND NEW.status = 'accepted'
BEGIN
  INSERT OR IGNORE INTO conversations (student_id, coach_id)
  VALUES (NEW.student_id, NEW.coach_id);
END;

-- A resolved request cannot be reopened.
CREATE TRIGGER contact_requests_no_reopen
BEFORE UPDATE OF status ON contact_requests
FOR EACH ROW
WHEN OLD.status <> 'pending' AND NEW.status <> OLD.status
BEGIN
  SELECT RAISE(ABORT, 'Contact request is already resolved');
END;

-- ---------------------------------------------------------------------------
-- messages
-- ---------------------------------------------------------------------------
-- Messages are immutable except read_at, and read_at is set once.
CREATE TRIGGER messages_immutable
BEFORE UPDATE ON messages
FOR EACH ROW
WHEN NEW.conversation_id IS NOT OLD.conversation_id
  OR NEW.sender_id IS NOT OLD.sender_id
  OR NEW.body IS NOT OLD.body
  OR NEW.created_at IS NOT OLD.created_at
  OR (OLD.read_at IS NOT NULL AND NEW.read_at IS NOT OLD.read_at)
BEGIN
  SELECT RAISE(ABORT, 'Messages are immutable except read_at, which is set once');
END;

-- The sender must be the student or the coach profile of the conversation.
CREATE TRIGGER messages_sender_in_conversation
BEFORE INSERT ON messages
FOR EACH ROW
BEGIN
  SELECT RAISE(ABORT, 'Sender is not part of this conversation')
  WHERE NOT EXISTS (
    SELECT 1
    FROM conversations cv
    JOIN coaches co ON co.id = cv.coach_id
    WHERE cv.id = NEW.conversation_id
      AND NEW.sender_id IN (cv.student_id, co.profile_id)
  );
END;

-- ---------------------------------------------------------------------------
-- bookings
-- ---------------------------------------------------------------------------
-- Trial bookings are only allowed when the coach offers trial classes.
CREATE TRIGGER bookings_trial_insert
BEFORE INSERT ON bookings
FOR EACH ROW
WHEN NEW.booking_type = 'trial_class'
BEGIN
  SELECT RAISE(ABORT, 'This coach does not offer trial classes')
  WHERE NOT EXISTS (SELECT 1 FROM coaches WHERE id = NEW.coach_id AND trial_class_available = 1);
END;

CREATE TRIGGER bookings_trial_update
BEFORE UPDATE OF booking_type, coach_id ON bookings
FOR EACH ROW
WHEN NEW.booking_type = 'trial_class'
BEGIN
  SELECT RAISE(ABORT, 'This coach does not offer trial classes')
  WHERE NOT EXISTS (SELECT 1 FROM coaches WHERE id = NEW.coach_id AND trial_class_available = 1);
END;

-- A coach cannot have two overlapping confirmed bookings (stands in for a Postgres exclusion constraint).
CREATE TRIGGER bookings_no_overlap_insert
BEFORE INSERT ON bookings
FOR EACH ROW
WHEN NEW.status = 'confirmed'
BEGIN
  SELECT RAISE(ABORT, 'Coach already has a confirmed booking in that time range')
  WHERE EXISTS (
    SELECT 1 FROM bookings b
    WHERE b.coach_id = NEW.coach_id
      AND b.status = 'confirmed'
      AND b.starts_at < NEW.ends_at
      AND b.ends_at > NEW.starts_at
  );
END;

CREATE TRIGGER bookings_no_overlap_update
BEFORE UPDATE OF status, starts_at, ends_at, coach_id ON bookings
FOR EACH ROW
WHEN NEW.status = 'confirmed'
BEGIN
  SELECT RAISE(ABORT, 'Coach already has a confirmed booking in that time range')
  WHERE EXISTS (
    SELECT 1 FROM bookings b
    WHERE b.id <> NEW.id
      AND b.coach_id = NEW.coach_id
      AND b.status = 'confirmed'
      AND b.starts_at < NEW.ends_at
      AND b.ends_at > NEW.starts_at
  );
END;

-- A new booking notifies the coach.
CREATE TRIGGER bookings_notify_created
AFTER INSERT ON bookings
FOR EACH ROW
BEGIN
  INSERT INTO notifications (recipient_id, notification_type, booking_id)
  SELECT c.profile_id, 'booking_created', NEW.id
  FROM coaches c
  WHERE c.id = NEW.coach_id;
END;

-- ---------------------------------------------------------------------------
-- reviews
-- ---------------------------------------------------------------------------
-- Only a completed booking can be reviewed (one review per booking is the UNIQUE on booking_id).
CREATE TRIGGER reviews_completed_booking_only
BEFORE INSERT ON reviews
FOR EACH ROW
BEGIN
  SELECT RAISE(ABORT, 'Only a completed booking can be reviewed')
  WHERE NOT EXISTS (SELECT 1 FROM bookings WHERE id = NEW.booking_id AND status = 'completed');
END;

CREATE TRIGGER reviews_booking_immutable
BEFORE UPDATE OF booking_id ON reviews
FOR EACH ROW
WHEN NEW.booking_id IS NOT OLD.booking_id
BEGIN
  SELECT RAISE(ABORT, 'A review cannot be moved to another booking');
END;

-- ---------------------------------------------------------------------------
-- ad_events: append-only
-- ---------------------------------------------------------------------------
-- Content is frozen. The only allowed change is profile_id -> NULL, which the
-- ON DELETE SET NULL foreign key performs when a profile is deleted.
CREATE TRIGGER ad_events_immutable
BEFORE UPDATE ON ad_events
FOR EACH ROW
WHEN NEW.ad_id IS NOT OLD.ad_id
  OR NEW.event_type IS NOT OLD.event_type
  OR NEW.created_at IS NOT OLD.created_at
  OR (NEW.profile_id IS NOT OLD.profile_id AND NEW.profile_id IS NOT NULL)
BEGIN
  SELECT RAISE(ABORT, 'Ad events are append-only');
END;
