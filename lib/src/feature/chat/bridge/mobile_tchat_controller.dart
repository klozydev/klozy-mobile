import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:klozy/src/router/app_router.dart';
import 'package:kosmos_chat/backend/cache/embedded_user_cache.dart';
import 'package:kosmos_chat/backend/provider/message_list.dart';
import 'package:kosmos_chat/kosmos_chat.dart';

/// Bridges the chat package's [TchatController] into mobile:
/// - user display data is read from Firestore (`chat_users/{id}`), which the
///   backend (trusted admin SDK) is the only writer of. Clients NEVER call the
///   REST API to resolve another user — that would let any customer query
///   another customer's data. Read-only, Firebase-only.
/// - opening a thread uses mobile's auto_route-10 typed route
class MobileTchatController extends TchatController {
  const MobileTchatController();

  static const String _chatUsersCollection = 'chat_users';

  /// Resolve a participant's chat display data — Firebase only, never the REST
  /// API (a customer must not be able to query another customer).
  ///
  /// Primary path is instant: the participant's profile is embedded in the
  /// thread doc (`tchat.usersData`), which the single thread-list query already
  /// returned, so [EmbeddedUserCache] serves it with zero extra reads. Only if a
  /// thread predates the embedded data do we fall back to a `chat_users/{id}`
  /// Firestore read.
  @override
  Future<Map<String, dynamic>> getUserData(String userId) async {
    final Map<String, dynamic>? embedded = EmbeddedUserCache.get(userId);
    if (embedded != null) return embedded;

    try {
      final DocumentSnapshot<Map<String, dynamic>> snap = await FirebaseFirestore
          .instance
          .collection(_chatUsersCollection)
          .doc(userId)
          .get();
      return snap.data() ?? <String, dynamic>{};
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
