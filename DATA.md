# DATA.md — Backend Implementation Guide for Agents

Guide for an agent implementing the real Gymder backend: database schema, REST endpoints, and the Flutter repository implementations that replace the current mocks.

Gymder is a "Tinder for gym coaches": students swipe through coaches, favorite them, and chat with them.

> Read this whole file before writing code. Section 9 lists defects in the current Dart code that must be fixed first.

---

## 1. Current state (source of truth)

The app is Flutter with a hexagonal architecture. All data is in-memory mocks.

```
lib/
├── domain/
│   ├── models/          coach.dart, favorite.dart, chat_message.dart
│   └── repositories/    coach_repository.dart, favorite_repository.dart, chat_repository.dart   (ports)
├── application/         chat/, coach/, favorites/   (use cases; call only the ports)
├── infrastructure/
│   ├── datasources/mock/mock_coaches_data.dart   (3 seeded coaches)
│   └── repositories/    mock_*_repository.dart   (adapters, in-memory)
└── core/dependencies.dart   (composition root, the ONLY place that picks mock vs real)
```

**Rules for the implementation**

1. Do not change `domain/` ports unless this file says so. The backend adapts to the ports, not the reverse.
2. New adapters go in `lib/infrastructure/repositories/` (e.g. `api_coach_repository.dart`) and implement the same abstract classes.
3. Swap them in only inside `lib/core/dependencies.dart`.
4. The server lives in a new top-level `backend/` directory, outside `lib/`.
5. Domain models stay free of JSON code. Put `fromJson`/`toJson` in DTO/mapper classes under `lib/infrastructure/datasources/api/`.

`currentStudentId` is hardcoded to `'student_me'`. Once auth exists (section 6), take it from the session.

---

## 2. Domain entities

Field names below match the Dart models.

### Coach
| Field | Type | Notes |
|---|---|---|
| id | String | e.g. `coach_1` in mocks; UUID in production |
| name | String | |
| age | int | |
| bio | String | |
| photos | List<String> | URLs, ordered; first is the card cover |
| specialities | List<String> | See the naming defect in section 9 |
| rating | double | 0.0–5.0, derived from reviews |
| reviewsCount | int | derived |
| monthlyPrice | double | currency not defined yet (see open questions) |
| location | String | free text, e.g. `Gym Central & Online` |
| isAvailable | bool | default true; unavailable coaches should not appear in discovery |

### Favorite
`id`, `studentId`, `coachId`, `createdAt`. Unique per `(studentId, coachId)`.

### ChatMessage
`id`, `senderId`, `receiverId`, `text`, `sentAt`, `isRead` (default false).
Sender and receiver are user ids. A conversation is the unordered pair of two users.

### Implied but not modeled yet
There is no `Student` or `User` model, although `studentId`, `senderId` and `receiverId` reference one. The backend needs a `users` table (section 3). Add a matching Dart `User` model only when a screen needs it.

---

## 3. Database schema (PostgreSQL)

Use PostgreSQL 15+. Ids are UUIDs. Timestamps are `timestamptz` in UTC.

```sql
CREATE EXTENSION IF NOT EXISTS "pgcrypto";   -- gen_random_uuid()

CREATE TYPE user_role AS ENUM ('student', 'coach');

CREATE TABLE users (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  email         text NOT NULL UNIQUE,
  password_hash text NOT NULL,
  role          user_role NOT NULL,
  display_name  text NOT NULL,
  created_at    timestamptz NOT NULL DEFAULT now()
);

-- One row per coach user. The coach's id IS the user id, so chat ids
-- (users.id) and coach ids are the same value.
CREATE TABLE coaches (
  id             uuid PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
  age            int  NOT NULL CHECK (age BETWEEN 16 AND 100),
  bio            text NOT NULL DEFAULT '',
  monthly_price  numeric(10,2) NOT NULL CHECK (monthly_price >= 0),
  location       text NOT NULL DEFAULT '',
  is_available   boolean NOT NULL DEFAULT true,
  rating         numeric(2,1) NOT NULL DEFAULT 0 CHECK (rating BETWEEN 0 AND 5),
  reviews_count  int NOT NULL DEFAULT 0 CHECK (reviews_count >= 0)
);

CREATE TABLE coach_photos (
  id        uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  coach_id  uuid NOT NULL REFERENCES coaches(id) ON DELETE CASCADE,
  url       text NOT NULL,
  position  int  NOT NULL DEFAULT 0,
  UNIQUE (coach_id, position)
);

CREATE TABLE specialities (
  id    serial PRIMARY KEY,
  name  text NOT NULL UNIQUE          -- 'Hipertrofia', 'Calistenia', ...
);

CREATE TABLE coach_specialities (
  coach_id       uuid NOT NULL REFERENCES coaches(id) ON DELETE CASCADE,
  speciality_id  int  NOT NULL REFERENCES specialities(id) ON DELETE RESTRICT,
  PRIMARY KEY (coach_id, speciality_id)
);

CREATE TABLE favorites (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id  uuid NOT NULL REFERENCES users(id)   ON DELETE CASCADE,
  coach_id    uuid NOT NULL REFERENCES coaches(id) ON DELETE CASCADE,
  created_at  timestamptz NOT NULL DEFAULT now(),
  UNIQUE (student_id, coach_id)
);

CREATE TABLE chat_messages (
  id           uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  sender_id    uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  receiver_id  uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  text         text NOT NULL CHECK (length(btrim(text)) > 0),
  sent_at      timestamptz NOT NULL DEFAULT now(),
  is_read      boolean NOT NULL DEFAULT false,
  CHECK (sender_id <> receiver_id)
);

-- Conversation lookup: both directions, newest last.
CREATE INDEX idx_chat_pair_time ON chat_messages
  (LEAST(sender_id, receiver_id), GREATEST(sender_id, receiver_id), sent_at);
CREATE INDEX idx_favorites_student ON favorites (student_id, created_at DESC);
CREATE INDEX idx_coach_discovery   ON coaches (is_available) WHERE is_available;
```

**Notes**
- `coaches.rating` and `reviews_count` are stored for fast discovery queries. If a `reviews` table is added later, recompute them in a transaction when a review is written.
- `chat_messages` stays a flat table. No `conversations` table until the product needs unread counts or group chats.
- Lowercase-compare speciality names when filtering (the mock does `toLowerCase()`).
- Migrations: use one tool (suggested: `node-pg-migrate`, or the migration tool of the chosen framework). Put them in `backend/migrations/`, numbered, never edited after merge.

### Seed data
Port `kMockCoaches` from `lib/infrastructure/datasources/mock/mock_coaches_data.dart` into `backend/seeds/` (3 coaches: Carlos Mendoza, Valeria Rios, Mateo Fernández, with their photos, specialities, prices 150/120/180). Create one dev student, `student_me`, and keep the first chat message from `mock_chat_repository.dart` as seed.

---

## 4. REST API

Base path `/api/v1`. JSON only. Auth header `Authorization: Bearer <jwt>` on every route except `/auth/*` and `/health`.

### Conventions
- Ids are strings (UUIDs).
- Timestamps are ISO-8601 UTC strings.
- Field names are `camelCase` and match the Dart models.
- Errors use one shape:
  ```json
  { "error": { "code": "COACH_NOT_FOUND", "message": "Coach not found" } }
  ```
- Status codes: 200, 201, 204, 400 (validation), 401, 403, 404, 409, 500.

### Auth
| Method | Path | Body | Response |
|---|---|---|---|
| POST | `/auth/register` | `{email, password, displayName, role}` | 201 `{user, token}` |
| POST | `/auth/login` | `{email, password}` | 200 `{user, token}` |
| GET | `/auth/me` | — | 200 `{id, email, role, displayName}` |

### Coaches (port: `CoachRepository`)
| Method | Path | Maps to | Notes |
|---|---|---|---|
| GET | `/coaches/discovery` | `getDiscoveryCoaches()` | Available coaches only. Exclude coaches the student already favorited. Optional `?limit=20&cursor=`. |
| GET | `/coaches/:id` | `getCoachById(id)` | 404 `COACH_NOT_FOUND` → adapter returns `null`. |
| GET | `/coaches?speciality=Calistenia` | `getCoachBySpeciality(s)` | Case-insensitive exact match. Empty list if none. |

Coach response:
```json
{
  "id": "…", "name": "Carlos Mendoza", "age": 29,
  "bio": "…",
  "photos": ["https://…", "https://…"],
  "specialities": ["Hipertrofia", "Fuerza"],
  "rating": 4.9, "reviewsCount": 38,
  "monthlyPrice": 150.0,
  "location": "Gym Central & Online",
  "isAvailable": true
}
```

### Favorites (port: `FavoriteRepository`)
The student id comes from the token, not from the path.

| Method | Path | Maps to | Response |
|---|---|---|---|
| PUT | `/favorites/:coachId` | `addFavorite` | 204. Idempotent: existing row is a no-op. |
| DELETE | `/favorites/:coachId` | `removeFavorite` | 204. Idempotent. |
| GET | `/favorites/:coachId` | `isFavorite` | 200 `{ "isFavorite": true }` |
| GET | `/favorites` | `getFavoriteCoaches` | 200 `[Coach, …]`, newest favorite first. |

The `ToggleFavorite` use case calls `isFavorite` then `add`/`remove`. That is two round trips and racy; keep the use case as is for now, and consider a single `POST /favorites/:coachId/toggle` returning `{isFavorite}` as a later optimization.

### Chat (port: `ChatRepository`)
The sender is taken from the token. The client still passes `senderId` through the port, so the server must reject a body whose `senderId` differs from the token (403).

| Method | Path | Maps to | Response |
|---|---|---|---|
| POST | `/chats/:otherUserId/messages` | `sendMessage` | 201 `ChatMessage`. Body `{text}`. Server trims; empty → 400 `EMPTY_MESSAGE`. |
| GET | `/chats/:otherUserId/messages?before=&limit=50` | `getMessages` | 200 `[ChatMessage…]` ascending by `sentAt`. |
| GET (SSE) or WS | `/chats/:otherUserId/stream` | `watchMessages` | Pushes the full ordered list once on connect, then again on each change (this matches the mock's behavior). Prefer WebSocket; SSE is acceptable for v1. |
| POST | `/chats/:otherUserId/read` | — (new) | 204. Marks incoming messages as read. Add a port method only when a screen needs it. |

ChatMessage response:
```json
{ "id": "…", "senderId": "…", "receiverId": "…", "text": "…",
  "sentAt": "2026-11-23T15:04:05Z", "isRead": false }
```

The mock's `_simulateCoachAutoReply` is demo behavior. Do not port it. Remove it from any real adapter.

### Health
`GET /health` → 200 `{ "status": "ok" }`.

---

## 5. Validation and business rules

- Message text: trim, 1–2000 chars. Already enforced in `SendChatMessage`; enforce again on the server.
- A user cannot message themselves (DB `CHECK`).
- Chat is allowed between a student and a coach only. Reject coach↔coach and student↔student with 403 `CHAT_NOT_ALLOWED`.
- Favorites: only students can favorite; the target must be an existing coach (404 otherwise).
- Never trust ids in the body for identity. Identity comes from the JWT.
- Passwords: argon2id or bcrypt (cost ≥ 12). Never log passwords or tokens.
- Rate-limit `/auth/*` and message sending.

---

## 6. Authentication

- Email + password → short-lived JWT access token (15–60 min) and a refresh token. For the first version a single JWT is acceptable.
- Token payload: `sub` (user id), `role`, `exp`.
- Flutter side: add an `AuthRepository` port and a `CurrentSession` holder. `AppDependencies.currentStudentId` is replaced by the session's user id.
- Store the token with `flutter_secure_storage`.

---

## 7. Suggested stack

The user has not chosen one. Default recommendation unless told otherwise:

- Node.js + TypeScript + Fastify (or Express), PostgreSQL, `zod` for request validation.
- Same hexagonal layout on the server so it mirrors the app: `domain/`, `application/`, `infrastructure/` (SQL repositories), `http/` (routes).
- Tests: integration tests against a real Postgres (Docker), one per endpoint group.
- `docker-compose.yml` with `postgres` and `api` services; `.env.example` with `DATABASE_URL`, `JWT_SECRET`, `PORT`.

If the user prefers Firebase, the comment in `dependencies.dart` mentions it as an option; the schema above maps to Firestore collections `users`, `coaches`, `favorites`, `chats/{pairId}/messages`, with `pairId` = the two ids sorted and joined.

---

## 8. Flutter integration steps

1. Fix the defects in section 9 and confirm `flutter analyze` is clean.
2. Add the `http` package (and `web_socket_channel` if using WebSocket) to `pubspec.yaml`.
3. Create `lib/infrastructure/datasources/api/api_client.dart` (base URL, auth header, error mapping to typed exceptions).
4. Create DTO mappers for Coach, Favorite and ChatMessage.
5. Implement `ApiCoachRepository`, `ApiFavoriteRepository`, `ApiChatRepository` implementing the existing ports. `watchMessages` wraps the stream endpoint in a `Stream<List<ChatMessage>>`.
6. In `lib/core/dependencies.dart`, replace the three `Mock*` instantiations with the API versions. Keep the mocks available behind a flag (e.g. `--dart-define=USE_MOCKS=true`) for offline UI work.
7. Add tests: repository tests with a fake `ApiClient`; the use cases already depend only on ports and can use mocks.

---

## 9. Known defects in the current Dart code (fix first)

The code does not compile as it stands.

| File | Problem | Fix |
|---|---|---|
| `lib/domain/models/chat_message.dart` | Constructor ends `this.isRead = false;` with a semicolon inside the parameter list. | Use a comma. |
| `lib/domain/models/coach.dart` | `copyWith` returns `Coach(...)` without a trailing `;`. | Add `;`. |
| `lib/domain/models/favorite.dart` | `copyWith` passes `stuendId:` (typo). | Change to `studentId:`. |
| `lib/domain/models/coach.dart` | Field is `specialities`, but `mock_coaches_data.dart` and `mock_coach_repository.dart` use `specialties`. Mismatch causes a compile error. | Pick one spelling. Recommended: the correct English `specialties` everywhere (model, mock data, repository, and the API/JSON key). This guide uses `specialities` in the API and tables as written in the model; if you rename, rename them here too. |
| `lib/domain/repositories/coach_repository.dart` | `getCoachBySpeciality` is not exposed by any use case. | Add a `GetCoachesBySpeciality` use case when a filter screen exists. |
| `lib/domain/repositories/chat_repository.dart` | `getMessages` is not used by any use case. | Add one or remove it. |
| `lib/core/dependencies.dart` | `AppDependencies._internal()` is called while `late final` fields are assigned. Works, but the singleton cannot be reconfigured for tests. | Optionally add a constructor that accepts repositories. |

Indentation also mixes 4 spaces (domain) and 2 spaces (application, infrastructure). Run `dart format .` once.

---

## 10. Definition of done

- [ ] Section 9 fixed; `flutter analyze` and `flutter test` pass.
- [ ] `backend/` runs with `docker compose up`, migrations applied, seed loaded.
- [ ] Every endpoint in section 4 implemented with validation and the error shape above.
- [ ] Integration tests cover: discovery excludes favorites and unavailable coaches; favorite add/remove is idempotent; message trimming and empty rejection; chat ordering; auth required on protected routes.
- [ ] The three API repositories implement the existing ports and `dependencies.dart` is the only file that changed to switch over.
- [ ] README updated with run instructions and env vars.

## 11. Open questions for the user

Ask these before building the parts they affect; do not guess:

1. Backend stack: Node/TypeScript + Postgres (recommended), or Firebase, or something else?
2. Currency for `monthlyPrice` (Bolivian boliviano, USD)? Store it as a `currency` column if mixed.
3. Do coaches sign up in the app (coach-side screens), or are they created by an admin?
4. Is there a "match" concept (coach must accept) or can any student message any coach?
5. Are photos uploaded by users (needs object storage such as S3) or only URLs?
6. Is there a review system that should drive `rating` and `reviewsCount`, or are they editable values for now?
