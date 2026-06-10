import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:core_kosmos/core_kosmos.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

abstract class EventController {
  static bool initPushNotifsDone = false;
  static Future<void> initPushNotifs(
      BuildContext mainAppContext,
      FlutterLocalNotificationsPlugin localNotification,
      AndroidNotificationChannel channel,
      [WidgetRef? ref]) async {
    final EventConfiguration config = getAppModel()
            .getDependenciesFromName<EventConfiguration>(
                "kosmos_event_config") ??
        EventConfiguration();
    final enablePushNotif = config.enablePushNotificationConfig;
    final settings = await FirebaseMessaging.instance.getNotificationSettings();

    if (enablePushNotif &&
        (settings.authorizationStatus == AuthorizationStatus.authorized ||
            settings.authorizationStatus == AuthorizationStatus.provisional)) {
      // ignore: use_build_context_synchronously
      await NotifPermissionController.initNotifStream(
        soundIos: config.soundIos,
        soundAndroid: config.soundAndroid,
        mainAppContext: mainAppContext,
        localNotification: localNotification,
        channel: channel,
        onMessage: config.onMessage != null
            ? (a, e) => config.onMessage?.call(a, ref, e)
            : null,
        onMessageBackground: (a, e) {
          initPushNotifsDone = true;
          config.onMessageBackground?.call(a, ref, e);
        },
        onSelectNotification: (a, e) =>
            config.onSelectNotification?.call(a, ref, e),
        onDidReceiveBackgroundNotificationResponse: (a, e) =>
            config.onDidReceiveBackgroundNotificationResponse?.call(a, ref, e),
      );

      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await FirebaseFirestore.instance
              .collection("users")
              .doc(user.uid)
              .collection("metadata")
              .doc("metadata")
              .update({"fcmToken": newToken});
        }
      });
    }
  }

  static Future<void> execInitialNotification(
      BuildContext context, WidgetRef ref) async {
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null && !initPushNotifsDone) {
      initPushNotifsDone = true;
      printDebug(initialMessage.data);
      final EventConfiguration config = getAppModel()
              .getDependenciesFromName<EventConfiguration>(
                  "kosmos_event_config") ??
          EventConfiguration();
      // ignore: use_build_context_synchronously
      config.onMessageBackground?.call(context, ref, initialMessage);
    }
  }
}
