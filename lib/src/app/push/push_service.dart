import 'dart:async';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:injectable/injectable.dart';
import 'package:klozy/src/app/notifications/notifications_cubit.dart';
import 'package:klozy/src/domain/notifications/notifications_repository.dart';
import 'package:klozy/src/router/app_router.dart';

/// FCM wiring: permission, token registration (`/v1/me/device-tokens`),
/// foreground badge refresh, and notification-tap deep links. Entirely
/// best-effort — push must never break the app.
@lazySingleton
class PushService {
  final FirebaseMessaging _messaging;
  final NotificationsRepository _repository;
  final NotificationsCubit _notificationsCubit;
  final AppRouter _router;

  bool _initialized = false;
  String? _token;
  StreamSubscription<String>? _tokenSub;
  StreamSubscription<RemoteMessage>? _foregroundSub;
  StreamSubscription<RemoteMessage>? _openedSub;

  PushService(
    this._messaging,
    this._repository,
    this._notificationsCubit,
    this._router,
  );

  String get _platform => Platform.isIOS ? 'IOS' : 'ANDROID';

  /// Call once after sign-in (idempotent). Requests permission, registers the
  /// device token, and hooks refresh/foreground/tap handlers.
  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    try {
      final settings = await _messaging.requestPermission();
      if (settings.authorizationStatus == AuthorizationStatus.denied) return;

      // Show system banners while the app is foregrounded (iOS).
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      await _registerToken(await _messaging.getToken());
      _tokenSub = _messaging.onTokenRefresh.listen(_registerToken);

      // Foreground push → keep the bell badge in sync.
      _foregroundSub = FirebaseMessaging.onMessage.listen(
        (RemoteMessage _) => _notificationsCubit.refresh(),
      );

      // Tap on a push (background → foreground) → deep link.
      _openedSub = FirebaseMessaging.onMessageOpenedApp.listen(_openFromPush);

      // App launched from a terminated state via a push.
      final initial = await _messaging.getInitialMessage();
      if (initial != null) _openFromPush(initial);
    } catch (_) {
      // Best-effort: missing APNs config etc. must not break startup.
    }
  }

  Future<void> _registerToken(String? token) async {
    if (token == null || token.isEmpty) return;
    _token = token;
    try {
      await _repository.registerDeviceToken(token: token, platform: _platform);
    } catch (_) {}
  }

  void _openFromPush(RemoteMessage message) {
    final data = message.data;
    final productId = data['productId'];
    final orderId = data['orderId'];
    final userId = data['userId'];
    if (productId is String && productId.isNotEmpty) {
      _router.push(ProductRoute(id: productId));
    } else if (orderId is String && orderId.isNotEmpty) {
      _router.push(OrderDetailRoute(id: orderId));
    } else if (userId is String && userId.isNotEmpty) {
      _router.push(UserProfileRoute(userId: userId));
    } else {
      _router.push(const NotificationsRoute());
    }
    _notificationsCubit.refresh();
  }

  /// Call on logout / account deletion: removes the token server-side and
  /// invalidates it locally so the signed-out device stops receiving pushes.
  Future<void> unregister() async {
    final token = _token;
    _token = null;
    if (token != null) {
      try {
        await _repository.removeDeviceToken(token);
      } catch (_) {}
    }
    try {
      await _messaging.deleteToken();
    } catch (_) {}
    await _tokenSub?.cancel();
    await _foregroundSub?.cancel();
    await _openedSub?.cancel();
    _initialized = false;
  }
}
