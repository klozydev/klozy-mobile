import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:klozy/src/di/injection.dart';
import 'package:klozy/src/domain/social/entity/social_profile.dart';
import 'package:klozy/src/domain/social/social_repository.dart';
import 'package:klozy/src/router/app_router.dart';
import 'package:kosmos_chat/backend/provider/message_list.dart';
import 'package:kosmos_chat/kosmos_chat.dart';

/// Single entry point every "message this user" affordance routes through.
/// Finds or creates the 1:1 tchat with [otherUserId], then opens the thread.
class ChatEntry {
  const ChatEntry._();

  static bool _busy = false;

  static Future<void> open(
    BuildContext context, {
    required String otherUserId,
    Map<String, dynamic>? metadata,
  }) async {
    final me = FirebaseAuth.instance.currentUser?.uid;
    if (me == null || _busy) return;
    _busy = true;
    try {
      // Callers pass the backend user id, but the kosmos chat keys threads by
      // Firebase UID (that's what `me` is). Resolve the other user's Firebase
      // UID so both participants — and the backend's offer/purchase mirror —
      // build the same thread id.
      String other = otherUserId;
      SocialProfile? otherProfile;
      try {
        otherProfile = await locator<SocialRepository>().getProfile(
          otherUserId,
        );
        if (otherProfile.firebaseUid.isNotEmpty) {
          other = otherProfile.firebaseUid;
        }
      } catch (_) {}
      const controller = TchatController();
      final existing = await controller.tchatExist(
        TchatType.oneToOne,
        userId: me,
        otherUserId: other,
      );
      final tchatId =
          existing?.id ??
          await controller.createTchat(
            TchatType.oneToOne,
            userId1: me,
            userId2: other,
          );
      if (tchatId == null) return;

      // The thread was created client-side, so the backend's offer/purchase
      // mirror hasn't embedded participant profiles yet. Embed them now from
      // data the FE already has (both profiles), keyed by backend id AND
      // Firebase UID, so the thread list resolves names straight from the doc —
      // no per-user read, no cache. Best-effort.
      await _embedUsersData(tchatId, otherProfile);

      if (!context.mounted) return;
      // Prime the message provider from the root ProviderScope container.
      ProviderScope.containerOf(
        context,
        listen: false,
      ).read(messageListProvider).init(tchatId);
      if (!context.mounted) return;
      await context.router.push(ChatThreadRoute(tchatId: tchatId));
    } finally {
      _busy = false;
    }
  }

  /// Writes `metadata.usersData` (both participants' display fields, keyed by
  /// backend id and Firebase UID) onto the thread doc, matching what the backend
  /// mirror writes. Fetches the current user's own profile (self-query, allowed)
  /// and reuses the already-fetched [otherProfile]. Best-effort — never throws.
  static Future<void> _embedUsersData(
    String tchatId,
    SocialProfile? otherProfile,
  ) async {
    try {
      final String? me = FirebaseAuth.instance.currentUser?.uid;
      SocialProfile? myProfile;
      if (me != null) {
        try {
          myProfile = await locator<SocialRepository>().getProfile(me);
        } catch (_) {}
      }

      final Map<String, dynamic> usersData = <String, dynamic>{};
      for (final SocialProfile? p in <SocialProfile?>[
        myProfile,
        otherProfile,
      ]) {
        if (p == null) continue;
        final Map<String, dynamic> data = <String, dynamic>{
          'firstname': p.displayName,
          'lastname': '',
          'pseudo': p.displayName,
          'email': '',
          'rating': p.rating,
          'profileImage': p.avatarUrl,
          'displayName': p.displayName,
        };
        for (final String key in <String>[p.id, p.firebaseUid]) {
          if (key.isNotEmpty) usersData[key] = data;
        }
      }
      if (usersData.isEmpty) return;

      await FirebaseFirestore.instance.collection('tchat').doc(tchatId).set(
        <String, dynamic>{
          'metadata': <String, dynamic>{'usersData': usersData},
        },
        SetOptions(merge: true),
      );
    } catch (_) {}
  }
}
