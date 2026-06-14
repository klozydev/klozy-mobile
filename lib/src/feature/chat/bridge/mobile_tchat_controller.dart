import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:klozy/src/di/injection.dart';
import 'package:klozy/src/domain/social/social_repository.dart';
import 'package:klozy/src/feature/chat/bridge/user_data_mapper.dart';
import 'package:klozy/src/router/app_router.dart';
import 'package:kosmos_chat/backend/provider/message_list.dart';
import 'package:kosmos_chat/kosmos_chat.dart';

/// Bridges the chat package's [TchatController] into mobile:
/// - user display data is cached in Firestore (`chat_users/{id}`) so the thread
///   list resolves names/avatars from Firebase, not a slow REST round-trip
/// - opening a thread uses mobile's auto_route-10 typed route
class MobileTchatController extends TchatController {
  const MobileTchatController();

  static const String _chatUsersCollection = 'chat_users';

  /// Resolve a participant's chat display data. Firestore-first: the thread list
  /// must not hammer the REST API (Railway, far edge) for every participant on
  /// every load. We read `chat_users/{id}` from Firestore (same already-open
  /// channel as the chat); only on a miss do we hit REST once and write the
  /// result back so no device fetches that user from the backend again.
  @override
  Future<Map<String, dynamic>> getUserData(String userId) async {
    final DocumentReference<Map<String, dynamic>> ref = FirebaseFirestore
        .instance
        .collection(_chatUsersCollection)
        .doc(userId);

    try {
      final DocumentSnapshot<Map<String, dynamic>> snap = await ref.get();
      final Map<String, dynamic>? cached = snap.data();
      if (snap.exists && cached != null) {
        return cached;
      }
    } catch (_) {
      // Firestore read failed — fall through to REST.
    }

    try {
      final profile = await locator<SocialRepository>().getProfile(userId);
      final Map<String, dynamic> map = socialProfileToChatUserMap(profile);
      // Write-through so this user is served from Firestore next time (any
      // device). Best-effort — never block returning the data on the write.
      unawaited(ref.set(map, SetOptions(merge: true)));
      return map;
    } catch (_) {
      return <String, dynamic>{};
    }
  }

  @override
  Future<void> openTchat(
    BuildContext context,
    WidgetRef ref,
    TchatModel tchat,
  ) async {
    assert(tchat.id != null, 'tchat.id required');
    ref.read(messageListProvider).init(tchat.id!);
    if (context.mounted) {
      await context.router.push(ChatThreadRoute(tchatId: tchat.id!));
    }
  }
}
