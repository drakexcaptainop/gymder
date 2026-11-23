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
CREATE TRIGGER contact_requests_valid_participants
BEFORE INSERT ON contact_requests
FOR EACH ROW
BEGIN
  SELECT RAISE(ABORT, 'Contact requests require a student and an active coach')
  WHERE NOT EXISTS (
    SELECT 1 FROM profiles WHERE id = NEW.student_id AND role = 'student'
  ) OR NOT EXISTS (
    SELECT 1 FROM coaches WHERE id = NEW.coach_id AND status = 'active'
  );
END;

-- A new contact request notifies the coach.
CREATE TRIGGER contact_requests_notify_created
AFTER INSERT ON contact_requests
FOR EACH ROW
BEGIN
  INSERT INTO notifications (
    recipient_id, notification_type, contact_request_id, created_at, updated_at
  )
  SELECT c.profile_id, 'contact_request_created', NEW.id, NEW.created_at, NEW.created_at
  FROM coaches c
  WHERE c.id = NEW.coach_id;
END;

-- Favorites belong to students; the foreign key already validates the coach.
CREATE TRIGGER favorites_student_only
BEFORE INSERT ON favorites
FOR EACH ROW
BEGIN
  SELECT RAISE(ABORT, 'Only students can favorite coaches')
  WHERE NOT EXISTS (
    SELECT 1 FROM profiles WHERE id = NEW.profile_id AND role = 'student'
  );
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

-- Resolving a request notifies the student.
CREATE TRIGGER contact_requests_notify_resolved
AFTER UPDATE OF status ON contact_requests
FOR EACH ROW
WHEN OLD.status = 'pending' AND NEW.status IN ('accepted', 'declined')
BEGIN
  INSERT INTO notifications (
    recipient_id, notification_type, contact_request_id, created_at, updated_at
  )
  VALUES (
    NEW.student_id, 'contact_request_resolved', NEW.id, NEW.resolved_at, NEW.resolved_at
  );
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
-- reviews
-- ---------------------------------------------------------------------------
-- Only a student with a conversation with the coach can review them.
CREATE TRIGGER reviews_requires_conversation
BEFORE INSERT ON reviews
FOR EACH ROW
BEGIN
  SELECT RAISE(ABORT, 'Only students with a conversation with this coach can review them')
  WHERE NOT EXISTS (
    SELECT 1 FROM conversations
    WHERE student_id = NEW.student_id AND coach_id = NEW.coach_id
  );
END;

CREATE TRIGGER reviews_identity_immutable
BEFORE UPDATE OF coach_id, student_id ON reviews
FOR EACH ROW
WHEN NEW.coach_id IS NOT OLD.coach_id OR NEW.student_id IS NOT OLD.student_id
BEGIN
  SELECT RAISE(ABORT, 'A review cannot change its author or its coach');
END;

-- A new review notifies the coach.
CREATE TRIGGER reviews_notify_created
AFTER INSERT ON reviews
FOR EACH ROW
BEGIN
  INSERT INTO notifications (
    recipient_id, notification_type, review_id, created_at, updated_at
  )
  SELECT c.profile_id, 'review_created', NEW.id, NEW.created_at, NEW.created_at
  FROM coaches c
  WHERE c.id = NEW.coach_id;
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
