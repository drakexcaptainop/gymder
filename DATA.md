# DATA.md — Contrato de datos de Gymder

Este documento describe el contrato vigente entre dominio, repositorios, mocks, migraciones y la futura UI. La aplicación tiene dos roles: **estudiante** y **coach**.

## 1. Estado actual y fuentes de verdad

- `gymder.dbml`: modelo relacional de referencia.
- `migrations/0001_init_schema.sql`: esquema SQLite usado por el backend local/mock.
- `migrations/0002_triggers.sql`: reglas de integridad y efectos automáticos.
- `seed/seed.sql`: dataset reproducible.
- `lib/domain/`: modelos y puertos consumidos por la UI.
- `lib/application/`: casos de uso que debe invocar la UI.
- `lib/infrastructure/repositories/mock_*`: implementación en memoria, conectada en `AppDependencies`.

Todavía no existe servidor REST ni autenticación real. La UI debe desarrollarse contra los casos de uso de `AppDependencies`, nunca leyendo las listas mock directamente. Un backend remoto futuro debe implementar los mismos puertos.

## 2. Identidades

`profiles.id` identifica a la persona y es el valor usado como `senderId`, `recipientId` y `readerId`.

Un coach tiene dos identificadores distintos:

- `coaches.id`: identifica la ficha profesional y se usa en planes, favoritos, solicitudes y reseñas.
- `coaches.profile_id`: identifica a la persona y se usa en chat y notificaciones.

Identidades disponibles para desarrollar UI:

| Rol | Nombre | profile id | coach id |
|---|---|---|---|
| Estudiante | Jorge Barahona | `10000000-0000-4000-8000-000000000005` | — |
| Coach | Carlos Mendoza | `10000000-0000-4000-8000-000000000002` | `20000000-0000-4000-8000-000000000001` |

`AppDependencies` expone `currentStudentId`, `currentCoachProfileId` y `currentCoachId`. Son identidades de desarrollo; serán reemplazadas por una sesión autenticada.

## 3. Entidades

### Coach

Combina `coaches`, `profiles`, `coach_media` y estadísticas derivadas de `reviews`.

- `id`, `profileId`, `name`
- `specialty`, `bio`, `city`, `modality`
- `startingPrice`, `currencyCode`
- `trialClassAvailable`, `trialClassPrice`
- `isVerified`, `isAvailable`
- `photos`
- `rating`, `reviewsCount` derivados; nunca editables directamente

### Favorite

Clave compuesta `(studentId, coachId)`. No tiene ID propio. Sólo perfiles con rol estudiante pueden crear favoritos.

### ContactRequest

Solicitud de un estudiante a un coach. Estados: `pending`, `accepted`, `declined`, `cancelled`.

Incluye `studentName`, `studentAvatarPath`, `coachName` y `coachAvatarPath` como datos de presentación derivados para que las listas de ambos roles no necesiten consultas adicionales.

- El estudiante crea y puede cancelar una solicitud pendiente.
- El coach lista las solicitudes que recibió y puede aceptar o rechazar una pendiente.
- Aceptar crea o reutiliza la conversación.
- Aceptar o rechazar notifica al estudiante.
- Sólo puede existir una solicitud pendiente por pareja estudiante/coach.

### Conversation y ConversationSummary

`Conversation` representa la relación aceptada entre estudiante y coach.

`ConversationSummary` es la proyección para una fila de la bandeja de chat de cualquiera de los roles:

- `conversationId`
- `otherProfileId`, `otherDisplayName`, `otherAvatarPath`
- `lastMessage`
- `unreadCount`
- `updatedAt`

### ChatMessage

- `id`, `conversationId`, `senderId`, `text`, `sentAt`, `readAt`
- El receptor se deduce de la conversación.
- Texto recortado de 1 a 2000 caracteres.
- Sólo los participantes pueden enviar o marcar mensajes como leídos.
- El contenido es inmutable; únicamente puede fijarse `readAt` una vez.

### Plan

Niveles `start`, `plus`, `pro`. Un coach tiene como máximo un plan por nivel. La consulta para UI devuelve sólo planes activos, ordenados por nivel.

### Review

Una reseña por pareja `(studentId, coachId)`, calificación de 1 a 5 y comentario opcional. El estudiante sólo puede reseñar a un coach con quien tenga conversación. Crear una reseña notifica al coach y actualiza las estadísticas derivadas que devuelven discovery, detalle y favoritos.

### AppNotification

Tipos:

- `contactRequestCreated`: para el coach.
- `contactRequestResolved`: para el estudiante.
- `reviewCreated`: para el coach.

Se ordenan de más reciente a más antigua y pueden marcarse como leídas.

### Ad y AdEvent

Los anuncios se muestran sólo si están activos y dentro de su ventana de fechas. Impresiones y clics son eventos append-only y pueden ser anónimos.

## 4. Casos de uso para la UI

Todos están disponibles desde `AppDependencies()`.

### Compartidos

- `getCoachDetail`
- `getCoachPlans`
- `getCoachReviews`
- `getConversationSummaries`
- `getChatMessages`
- `sendChatMessage`
- `markChatMessagesRead`
- `watchChatMessages`
- `getNotifications`
- `getUnreadNotificationCount`
- `markNotificationRead`

### Estudiante

- `getDiscoveryCoaches`
- `getCoachesBySpecialty`
- `toggleFavorite`
- `getFavoriteCoaches`
- `requestContact`
- `getMyContactRequests`
- `cancelContactRequest`
- `createReview`
- `getActiveAds`
- `trackAdEvent`

### Coach

- `getCoachContactRequests`
- `resolveContactRequest` con estado `accepted` o `declined`
- Casos compartidos de chat y notificaciones usando `currentCoachProfileId`

## 5. Flujos esperados

### Solicitud aceptada

1. Estudiante ejecuta `requestContact`.
2. Coach recibe `contactRequestCreated`.
3. Coach consulta `getCoachContactRequests`.
4. Coach ejecuta `resolveContactRequest(..., accepted)`.
5. Se crea la conversación y el estudiante recibe `contactRequestResolved`.
6. Ambos roles usan `getConversationSummaries`, `sendChatMessage` y `watchChatMessages`.

### Solicitud rechazada

El flujo es igual, pero `declined` no crea conversación. El estudiante recibe la notificación de resolución y consulta el estado actualizado en `getMyContactRequests`.

### Lectura del chat

Al abrir una conversación, la UI ejecuta `markChatMessagesRead` con el profile ID de la sesión y luego consume el historial/stream. El método sólo marca mensajes entrantes pendientes.

## 6. Correspondencia con SQLite

| Dominio | Tabla/vista |
|---|---|
| Coach | `coaches` + `profiles` + `coach_media` + `coach_stats` |
| Favorite | `favorites` |
| ContactRequest | `contact_requests` |
| Conversation | `conversations` |
| ChatMessage | `messages` |
| Plan | `plans` |
| Review | `reviews` + join a `profiles` para `studentName` |
| AppNotification | `notifications` |
| Ad / AdEvent | `ads` / `ad_events` |

Reglas que deben conservar futuros adaptadores:

- Coaches inactivos no aparecen en discovery ni reciben solicitudes nuevas.
- Favoritos sólo para estudiantes y de forma idempotente.
- Resolver una solicitud ya resuelta falla.
- Sólo aceptar abre conversación.
- Sólo participantes escriben o leen una conversación.
- Una reseña requiere conversación y es única por estudiante/coach.
- Rating y cantidad de reseñas se derivan de los datos actuales.

## 7. Seed y mocks

El seed y los mocks contienen el mismo catálogo funcional:

- 3 coaches, 3 estudiantes y 1 perfil administrativo.
- 8 planes.
- 3 favoritos.
- 3 solicitudes: aceptada, pendiente y rechazada.
- 1 conversación con 3 mensajes.
- 1 reseña.
- 6 notificaciones resultantes.
- 2 anuncios y 3 eventos publicitarios.

Los IDs generados por triggers para notificaciones pueden diferir; destinatario, tipo, referencia, fecha y estado de lectura deben coincidir.

## 8. Manejo de errores en UI

Los mocks usan:

- `ArgumentError` para parámetros inválidos, como rating o estado de resolución.
- `StateError` para recurso inexistente, participante incorrecto, duplicado o transición no permitida.
- `SendChatMessage` devuelve `null` para texto vacío o mayor a 2000 caracteres.

La UI debe convertirlos en mensajes para el usuario y no mostrar excepciones crudas.

## 9. Backend remoto futuro

Para producción faltan autenticación, servidor/API, almacenamiento persistente y adaptadores remotos. La implementación debe:

1. Mantener intactos los modelos y puertos de `lib/domain` salvo cambio de producto explícito.
2. Colocar DTO/mappers fuera del dominio.
3. Tomar identidad y rol de la sesión, nunca de IDs confiados al cuerpo de una petición.
4. Implementar autorización para estudiante y coach.
5. Mantener los mocks seleccionables para desarrollo y pruebas de UI.
6. Replicar las reglas de las migraciones y los efectos de sus triggers.

## 10. Definition of done de la capa mock

- [x] Flujos de estudiante disponibles.
- [x] Flujo de solicitudes para coach disponible.
- [x] Chat bidireccional, resumen y lectura disponibles.
- [x] Planes, reseñas, notificaciones y anuncios disponibles.
- [x] Seed y mocks sincronizados funcionalmente.
- [x] Migraciones ejecutables sin `bookings`.
- [x] Análisis estático y pruebas automatizadas requeridos antes de cada entrega.
- [ ] Autenticación y backend remoto de producción; fuera del alcance de la capa mock.
