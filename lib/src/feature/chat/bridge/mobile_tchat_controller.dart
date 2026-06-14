import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:klozy/src/router/app_router.dart';
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

  /// Resolve a participant's chat display data from Firestore only. The backend
  /// populates `chat_users/{id}` (see FirestoreChatService); the client just
  /// reads it. No REST fallback by design — a customer must not be able to fetch
  /// another customer from the API. Returns an empty map if not yet populated;
  /// the row shows a placeholder until the backend writes the doc.
  @override
  Future<Map<String, dynamic>> getUserData(String userId) async {
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
