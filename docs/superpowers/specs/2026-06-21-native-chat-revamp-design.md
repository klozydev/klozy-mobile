# Native Chat Revamp — Design Spec

_Date: 2026-06-21_

## 1. Goal

Replace the `kosmos_chat`-based chat island with a **native Klozy feature** that is
**pixel-perfect** to `chat-design/project/Klozy Chat.dc.html`, follows the app's
Clean-Architecture + BLoC + AutoRoute conventions, and imports **zero** code from any of
the three kosmos packages (`kosmos_chat`, `core_kosmos`, `ui_kosmos_v4`).

This is **phase 1** of "kill `mobile/packages/`". Chat is the wedge: it is the only feature
that depends solely on `kosmos_chat`, so it can be fully de-kosmos'd now. Deleting
`core_kosmos` / `ui_kosmos_v4` requires migrating every other feature first and is an
explicit **follow-on effort, out of scope here** — but this rewrite establishes the native
pattern those migrations will copy.

## 2. Locked decisions

| Topic | Decision |
| --- | --- |
| Kill scope | Delete `kosmos_chat` now; new chat has zero kosmos imports. `core_kosmos`/`ui_kosmos_v4` deleted later (separate effort). |
| Backend | Keep existing **Firestore** `tchat/*` collections + the NestJS offer/purchase mirror. Same field shapes — existing threads keep working. |
| Chat offers | **Cart-only.** Remove "Make offer" from the attach sheet. Still render incoming offer/purchase cards with Accept/Refuse. |
| Audio | **Full**: in-app voice recording (`record`) + waveform playback (`just_audio`) + audio-file attachments. |
| Media send | **Direct plugins**: `image_picker` + `file_picker` + `firebase_storage`. No kosmos pickers. |
| Reply-to | **Included**: swipe-to-reply + quoted bubble (uses the existing `replyTo` schema field). |

## 3. Firestore schema (must stay compatible)

Native entities map 1:1 to the current docs so existing data and the backend mirror are
untouched.

### `tchat/{tchatId}`
- `id`, `participants: List<String>` (Firebase UIDs), `type` (`oneToOne`), `isGroup`
- `metadata.usersData: Map<String/* backendId|firebaseUid */, {firstname, lastname, pseudo, email, rating, profileImage, displayName}>`
- `lastMessage: <MessageModel json>`, `lastMessageSentAt: Timestamp`, `lastMessageSeenBy: List<String>`
- `chatMutedBy: List<String>`, `blockedByUsers: List<String>`
- `deletedBy: List<{userId, deletedAt}>`, `deletedMessageHistory: Map`
- (group-only fields exist but unused by 1:1 UI: `adminId`, `admins[]`, `tchatName`, `tchatPicture`, …)

### `tchat/{tchatId}/messages/{uuid}`
- `id`, `tchatId`, `senderId`
- `messageType`: `text` | `media` | `audio` | `event` | `offer` | `purchase` | `deleted-message`
- `content: String?`
- `replyTo: <MessageModel json>?` (quoted message)
- `media: List<MediaModel>` where MediaModel = `{id, mediaUrl, mediaRelativePath, mediaType, mediaName, mediaHeight, mediaWidth, mediaDuration, videoThumbnail, videoThumbnailRelativePath}`
- `metadata: Map` — offer: `{productName, productPrice, newProductPrice, offerId, accepted: bool?, cancelled: bool}`; purchase: analogous order fields
- `readBy: List<String>`, `deleteBy: List<String>`, `sendAt: Timestamp`, `sendStatus: String` (`send`), `fromWeb: bool`

### Write rules (port verbatim, kosmos-free)
- **Send**: write `messages/{uuid}` = message json + `sendAt: serverTimestamp`, then `update` thread doc `lastMessage` / `lastMessageSentAt` / `lastMessageSeenBy: [me]`. (Mirrors `MobileMessageController.sendMessage`; no push — notifications are a separate system.)
- **Mark seen**: append my uid to `lastMessageSeenBy` and message `readBy`.
- **Delete conversation (soft, per-user)**: append `{userId: me, deletedAt}` to `deletedBy`; filter list-side.
- **Report & block**: append me to `blockedByUsers` + route to existing report/signalement flow.
- **Offer Accept/Refuse**: call the existing Firebase callable (reimplement `ChatOfferController.handleOffer(accept, offerId)` without `core_kosmos`). No counter-offers, no expiry.

## 4. Feature architecture — `lib/src/feature/chat/`

Scaffold with Mason (`mason make feature --name chat`), then replace generated stubs.
Clean Architecture, one class per file, sealed BLoC events/states, package imports,
DS tokens only.

```
feature/chat/
├─ data/
│  ├─ datasource/chat_remote_data_source.dart      # Firestore streams + writes; returns *Response
│  ├─ response/  chat_thread_response.dart, chat_message_response.dart,
│  │             chat_media_response.dart, chat_user_data_response.dart  (@JsonSerializable)
│  ├─ mapper/    chat_thread_mapper.dart, chat_message_mapper.dart       (response → entity)
│  └─ chat_repository_impl.dart
├─ domain/
│  ├─ entity/    chat_thread.dart, chat_message.dart, chat_media.dart,
│  │             chat_participant.dart, message_type.dart (enum), offer_data.dart
│  ├─ usecase/   watch_threads.dart, watch_messages.dart, send_text_message.dart,
│  │             send_media_message.dart, send_audio_message.dart, mark_thread_seen.dart,
│  │             delete_conversation.dart, report_and_block.dart, respond_to_offer.dart,
│  │             open_or_create_thread.dart, upload_chat_media.dart
│  └─ chat_repository.dart
└─ presentation/
   ├─ bloc/
   │  ├─ chat_list/   chat_list_bloc.dart, _event.dart, _state.dart   (threads + unread count)
   │  └─ chat_thread/ chat_thread_bloc.dart, _event.dart, _state.dart (messages, send, record,
   │                  play, reply, offer response, attach, lightbox, menu)
   └─ screen/
      ├─ chat_list_page.dart
      ├─ chat_thread_page.dart
      ├─ states/ (idle / loading / error widgets per page)
      └─ widgets/
         ├─ chat_list_row.dart
         ├─ thread_header.dart
         ├─ message_row.dart            (dispatches by MessageType)
         ├─ text_bubble.dart, image_video_message.dart, audio_message.dart,
         │  file_message.dart, offer_card.dart, purchase_pill.dart, event_message.dart
         ├─ quoted_message.dart         (reply-to preview inside a bubble)
         ├─ composer_bar.dart, recording_bar.dart
         ├─ attach_sheet.dart, thread_menu_sheet.dart
         ├─ audio_waveform.dart         (22 bars + progress)
         └─ media_lightbox.dart
```

**Platform-API rule**: pickers/camera/recorder run in the **widget layer**, results passed
to the BLoC via events (per CLAUDE.md — emitters close before async UI resolves).

## 5. UI spec — pixel-perfect to `Klozy Chat.dc.html`

All colors from `DSColor` (already aligned: `primary #E0CE7D`, `card #141414`, `surface`
black, `danger #EB5353`, alpha-whites `onSurface05…85`). Poppins via `dsTheme()`. No magic
numbers — add `DSSpacing`/`DSBorderRadius`/`DSFontSize` tokens where needed.

### List screen
- Header: "Messages" (24px/700) + circular filter button (38px, `onSurface07` bg).
- Row: 48px circular initial avatar tinted to the participant color (fallback gradient),
  name (700 if unread else 600) + optional `PRO` chip (gold, `brandGlow` bg), last-message
  preview (emoji-prefixed per type), time, unread badge (gold pill, black text).

### Thread screen
- Header (`#0A0A0A` 92% bg, hairline border): back chevron, 34px avatar, name + "Active now"
  (`#A7D2BE`), ⋯ menu.
- Message pane: column, 4px gap; optional dotted wallpaper.
- Bubble base: maxWidth 80%, radius 18px, tail corner 5px. **Me** = gold bg/black text,
  tail bottom-right. **Them** = `#141414`/white, tail bottom-left. Timestamp 10px under bubble.
- **Text**: pre-wrap, 14px/500.
- **Image/Video**: 180px wrapped tile, play overlay on video, tap → lightbox.
- **Audio**: play/pause circle + 22 waveform bars + progress underline + duration; me/them tints.
- **File**: doc icon tile + name (ellipsis) + size.
- **Offer card**: 248px, thumb + title + strikethrough listed price; "Your/<name>'s offer"
  + amount; pending+incoming → Refuse/Accept; mine pending → "Pending response…"; accepted
  (`#A7D2BE`) / refused / cancelled states.
- **Purchase**: centered green-tinted pill "✓ Purchase confirmed · <title> for <amount> Dhs".
- **Reply-to**: swipe a bubble to reply; outgoing/quoted bubble shows a `quoted_message`
  strip (author + snippet) above content; tap scrolls to source.

### Composer / recording
- Idle: attach `+` (38px), rounded input (`#141414`), mic↔send swap on text presence.
- Recording bar: trash-cancel (red) · pulsing red dot + tabular timer + hint · stop-send (gold check).

### Sheets / overlays
- **Attach sheet**: 3-col grid — Photo & Video, Camera, Audio file, Document. **No "Make offer".**
- **Thread menu**: Report & block, Delete conversation (both `danger`).
- **Lightbox**: fullscreen black, close button, image (contain) or video (controls, autoplay).

## 6. Integration seams (kept, de-kosmos'd)

- **Routes** (`lib/src/router/app_router.dart`): keep `ChatRoute` (shell tab) → `ChatListPage`,
  `ChatThreadRoute(:tchatId)` → `ChatThreadPage`. **Remove** `ChatMediaPickerRoute`
  (native attach sheet replaces it).
- **`ChatEntry.open(otherUserId)` / `ChatLauncher`** (`feature/chat/entry/`): keep the public
  API — callers in product details, profile, cart, checkout, orders are unchanged. Rewrite the
  body to use `OpenOrCreateThread` usecase + the existing `_embedUsersData` Firestore write,
  with no kosmos / Riverpod (`messageListProvider` priming removed; BLoC loads on thread open).
- **Shell unread badge** (`feature/shell/presentation/screen/shell_page.dart:82`): replace
  `ref.watch(tchatListProvider(uid)).unreadCount` (Riverpod) with `ChatListBloc` unread count
  via `BlocBuilder`.
- **App init** (`feature/chat/bridge/chat_config.dart` + `app/initializer/app_initializer.dart`):
  delete `registerChatConfig()` and the whole `bridge/` directory.

## 7. Cleanup & dependency changes

### Delete
- `packages/kosmos_chat/` (entire package + path dep).
- `feature/chat/bridge/` (config, theme, controllers, all message builders, styles).
- `feature/chat/presentation/screen/chat_media_picker_page.dart` and the old thin page wrappers.
- `registerChatConfig()` call site.

### `pubspec.yaml`
- **Remove**: `kosmos_chat`.
- **Remove (chat-island-only — verified no non-chat usage)**: `flutter_riverpod`,
  `hooks_riverpod`, `easy_localization`, `flutter_screenutil`. These survive only in
  `app/widget/app.dart` (`ProviderScope` / `ScreenUtilInit` / `EasyLocalization` wrappers) and
  `main.dart` to host the island; remove the wrappers in the same change. **Re-verify with a
  fresh grep at implementation time before deleting each.**
- **Keep**: `timeago_flutter` (used by `profile/.../review_card_widget.dart`), `image_picker`,
  `firebase_storage`.
- **Add**: `file_picker`, `just_audio`, `record`.

### App-wrapper edits (`app/widget/app.dart`, `main.dart`)
- Remove `ProviderScope`, `ScreenUtilInit`, `EasyLocalization` wrappers once chat no longer
  needs them. The app already uses gen-l10n (`context.l10N`) and `MediaQuery`-based sizing
  elsewhere, so these are pure removals — but guard each behind its own grep verification.

### Localization
- Move chat strings into `lib/l10n/app_en.arb` under an `@_chat` group; access via
  `context.l10N`. No `.tr()`.

## 8. Out of scope
- Deleting `core_kosmos` / `ui_kosmos_v4` (every other feature still imports them).
- Group chats (1:1 only; group schema fields ignored).
- Push notifications on new message (handled by the separate notifications system).

## 9. Risks & verifications
- **Firestore parity**: round-trip a real existing thread (read → render → send → reread) to
  confirm field compatibility with the backend mirror, especially offer/purchase `metadata`.
- **Offer callable**: confirm the Firebase callable name/signature behind `ChatOfferController`
  before reimplementing.
- **Dep removals**: each of riverpod/screenutil/easy_localization removal is gated by a
  fresh repo-wide grep; if any non-chat usage appears, keep the dep and note it.
- **Audio**: mic permission handling (iOS/Android) for `record`; graceful "no mic" fallback.
- Quality gates after each phase: `dart format lib`, `flutter analyze lib`, build_runner.
