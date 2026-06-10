# Design: Port `kosmos_chat` into `mobile/` as an isolated island

**Date:** 2026-06-10
**Status:** Approved (design); implementation plan pending
**Source app:** `klozy-flutter-app/` (the `kosmos_chat` package)
**Target app:** `mobile/` (Klozy mobile)

## Goal

Bring the full chat/messaging functionality from `klozy-flutter-app` into `mobile/`,
copied as-is, kept architecturally isolated from `mobile`'s BLoC/clean-arch world, and
wire every entry point in `mobile` to it.

## Confirmed decisions

1. **Approach:** Port the `kosmos_chat` package (and its two local deps) verbatim into
   `mobile/packages/`, as an isolated **Riverpod + Firebase** island. Do NOT rewrite it
   into BLoC/clean-arch.
2. **Firebase:** `mobile` and `klozy-flutter-app` share the **same Firebase project**, so the
   copied chat reads the existing `tchat` / messages data.
3. **Dependency strategy:** Copy all 3 packages, bump their pubspec constraints to `mobile`'s
   versions, and fix them until they compile — **with a Phase-0 spike first** to surface
   `core_kosmos` breakages cheaply.
4. **Custom message types:** Port `offer` and `purchase` bubbles too, bridged to `mobile`'s
   offers/orders system + navigation.
5. **User profile data:** `getUserData` is **bridged to `mobile`'s API**
   (`SocialRepository.getProfile`), not Firestore `users/{id}`.

## The core constraint: dependency versions cannot be isolated

A single Flutter app resolves **exactly one version of every package**. We can isolate the
chat's **code and architecture** (Riverpod/Firestore, separate packages, separate folders) but
**not** its **dependency versions**. The copied packages must compile against `mobile`'s pinned
versions. Confirmed collisions:

| Package | `mobile` pins | chat packages pin | Verdict |
|---|---|---|---|
| `firebase_core` | `4.7.0` | `core_kosmos`: `3.12.1` (exact) | major conflict |
| `auto_route` | `10.1.0+1` | `core_kosmos`: `5.0.4` (exact) | major conflict (5→10 = large API change) |
| `firebase_auth` / `firebase_storage` / `cloud_firestore` | 4.x train | unpinned | must move to the 4.x train |
| Riverpod / hooks / easy_localization / wechat pickers / hive / audio | absent | various | additive, no conflict |

**Coupling measured:** `kosmos_chat` is ~18k LOC / 79 files. It imports the `core_kosmos`
barrel in **49 files** and the `ui_kosmos_v4` barrel in **24 files** (heavy reliance on both).
It uses `AutoRouter`/`pushNamed` ~35× (migratable to auto_route 10) and `.tr()` **140×**
(needs `easy_localization`, additive).

Consequence: literal "copy verbatim" is physically impossible. The three packages' pubspec
constraints are rewritten to `mobile`'s versions and then fixed until they compile. The
dominant risk is `core_kosmos` (a kitchen-sink package: Stripe, analytics, in-app-messaging,
auto_route 5 routing) compiling under firebase 4.x + auto_route 10.x.

## Architecture & isolation boundary

```
mobile/packages/
  core_kosmos/    <- copied verbatim, pubspec constraints bumped, fixed to compile
  ui_kosmos_v4/   <- copied verbatim, bumped, fixed
  kosmos_chat/    <- copied verbatim, bumped, fixed

mobile/lib/src/feature/chat/   <- THE BRIDGE (only place island <-> mobile meet)
  bridge/
    chat_config.dart            init TchatBackEndConfig + TchatFrontEndConfig + theme
    mobile_tchat_controller.dart  extends TchatController; getUserData -> API; openTchat -> auto_route 10
    mobile_message_controller.dart extends MessageInterface; send/delete/block via Firestore; push = no-op (initial)
    offer_message_builder.dart    ported offer bubble -> mobile offers
    purchase_message_builder.dart  ported purchase bubble -> OrderDetailRoute
    user_data_mapper.dart         SocialProfile -> the map shape the chat UI expects
  presentation/
    chat_list_page.dart           @RoutePage wrapper hosting package TchatListPage (the tab)
    chat_thread_page.dart         @RoutePage wrapper hosting package message page (/chat/:tchatId)
    chat_media_picker_page.dart   @RoutePage wrapper for media preview/picker
  entry/
    chat_entry.dart               ChatEntry.open(context, otherUserId) — single entry helper
```

The island's internals stay untouched (BLoC never leaks in; Riverpod never leaks out). All
coupling to `mobile` lives under `feature/chat/bridge/`.

## Root wiring

In `lib/src/app/widget/app.dart` and `lib/src/app/initializer/app_initializer.dart`:

- **`ProviderScope`** wrapping the app root — chat pages are `HookConsumerWidget`s and require a
  Riverpod ancestor. Harmless to existing BLoC/Cubit providers.
- **`EasyLocalization`** wrapper + copied chat translation JSON assets — the package calls
  `.tr()` 140×; rewriting is infeasible, so `easy_localization` is added and coexists with
  `mobile`'s existing gen-l10n. `context.l10N` keeps working unchanged.
- **Chat config init** in `AppInitializer.initialize()` — registers `TchatBackEndConfig`,
  `TchatFrontEndConfig`, and the chat theme into `core_kosmos`'s config registry **before** any
  chat surface builds.

## The bridges (`feature/chat/bridge/`)

| Bridge | Responsibility |
|---|---|
| `MobileTchatController` (extends `TchatController`) | overrides `getUserData(id)` → `locator<SocialRepository>().getProfile(id)`, maps name/avatar into the map the chat UI expects; overrides `openTchat()` to navigate via auto_route 10 |
| `MobileMessageController` (extends `MessageInterface`) | send/delete/block via Firestore (as-is); **push-on-new-message → no-op initially** (mobile's notification system is separate; flagged follow-up) |
| `offerBuilder` / `purchaseBuilder` | ported and bridged to `mobile`'s offers/orders: accept/refuse → mobile offers use case; "view order details" → `OrderDetailRoute` |

Current-user identity needs **no bridge** — both apps use `FirebaseAuth.instance.currentUser.uid`.

## Routing (auto_route 10)

- Chat **tab** (`/chat`, already a shell child): placeholder `ChatPage` replaced by a wrapper
  hosting the package `TchatListPage`.
- New `ChatThreadRoute` (`/chat/:tchatId`): hosts the package message page, guarded by
  `AuthGuard`.
- New media-picker route hosting the package media preview/picker.

The package's string-based navigation is redirected through these typed wrappers (via the
overridden `openTchat`), so the package source barely changes.

## Firebase

Add to `mobile`'s pubspec (all on the firebase_core **4.x** train): `cloud_firestore`,
`firebase_database`, `firebase_storage`, `cloud_functions`. Same shared project → chat reads
existing `tchat`/messages. Realtime DB powers typing/online status; Storage holds media. User
profiles resolve via `mobile`'s API (decision 5), not Firestore `users`.

## Entry points (all wired through `ChatEntry.open`)

| Entry point | `mobile` location | Action |
|---|---|---|
| Chat **tab** | shell index 2 | replace placeholder with real list |
| Other-user **profile** | `profile/.../profile_actions_widget.dart` message icon | wire `onMessage` |
| **Product** detail seller card | `product/.../product_seller_card_widget.dart` (`product_messaging_coming_soon` cb) | wire |
| **Order** detail counterpart | `orders/.../order_counterpart_card_widget.dart` (`orders_messaging_coming_soon` cb) | wire |
| **Cart** summary seller | mobile cart summary widget | wire if present |
| **Notification** tap (chat type) | notifications tap handler | wire |
| **Offers** row | `offer_row_widget.dart` — entity lacks `counterpartId` | **deferred** (needs `Offer.counterpartId`); flagged |

## Phasing (spike-gated)

- **Phase 0 — Spike (GATE):** vendor 3 packages, bump pubspec constraints to `mobile`'s
  versions, get `flutter pub get` to resolve, `flutter analyze` the packages green (fix
  firebase 3→4 + auto_route 5→10 breakages). **If `core_kosmos` proves a tarpit, stop and
  pivot to slim-vendor before sinking more effort.**
- **Phase 1:** root wiring (ProviderScope + EasyLocalization + config init) → chat **list tab
  renders real conversations**.
- **Phase 2:** message route + `openChat` flow + `getUserData`→API bridge → **open a 1:1 chat,
  send text/media/audio**.
- **Phase 3:** offer/purchase bubbles bridged to `mobile` offers/orders.
- **Phase 4:** wire remaining entry points + unread **chat badge** count on the tab.
- **Phase 5:** polish — push-notification decision, empty/error states, `dart run build_runner
  build`, `flutter analyze lib`, `dart format`, manual smoke test.

## Risks & open items

- **Primary risk:** Phase 0 `core_kosmos` compilation under firebase 4.x + auto_route 10.x may
  cascade. The spike de-risks this before any wiring.
- **easy_localization + gen-l10n coexistence** at the root (`EasyLocalization` provides its own
  localization delegates/locale; must not break `mobile`'s existing `MaterialApp.router` locale
  config). Validated during Phase 1.
- **Push-on-new-message** starts as a no-op; revisit whether to bridge to `mobile`'s in-app
  notification center later.
- **Offers entry point** deferred pending an `Offer.counterpartId` field.
- **Firestore/Realtime DB/Storage** must be enabled in the shared Firebase project and the
  FlutterFire plugins configured for `mobile`'s app id.

## Out of scope

- Rewriting chat into BLoC/clean-arch.
- Group chat UX changes beyond what the package already supports.
- Changing the existing Firestore schema or security rules (managed by `klozy-flutter-app`).
