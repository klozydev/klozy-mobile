import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:core_kosmos/core_kosmos.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:kosmos_chat/backend/controller/message_controller.dart';
import 'package:kosmos_chat/kosmos_chat.dart';

/// Mobile's message controller for the chat island.
///
/// Extends the package [MessageController] (Firestore-backed send/delete/block)
/// and overrides [sendMessage] to drop the package's push-notification call —
/// mobile's notification system is separate, so push-on-new-message is a no-op
/// for now (see plan: bridge to mobile notifications later).
class MobileMessageController extends MessageController {
  const MobileMessageController();

  @override
  Future<void> sendMessage(
    BuildContext context,
    WidgetRef ref,
    TchatModel tchat,
    MessageModel model,
    String uuid, {
    File? file,
  }) async {
    await FirebaseFirestore.instance
        .collection('tchat')
        .doc(tchat.id)
        .collection('messages')
        .doc(uuid)
        .set(<String, dynamic>{
          ...model.copyWith(sendStatus: 'send').toJson(),
          'sendAt': FieldValue.serverTimestamp(),
        });

    await FirebaseFirestore.instance.collection('tchat').doc(tchat.id).update(
      <String, dynamic>{
        'lastMessage': <String, dynamic>{
          ...model.copyWith(sendStatus: 'send').toJson(),
          'sendAt': FieldValue.serverTimestamp(),
        },
        'deletedMessageHistory': <String, dynamic>{},
        'lastMessageSeenBy': <String>[FirebaseAuth.instance.currentUser!.uid],
        'lastMessageSentAt': FieldValue.serverTimestamp(),
      },
    );

    // Push-on-new-message intentionally omitted (no-op) for now.
  }

  @override
  void onTchatNameClick(
    BuildContext context,
    TchatModel tchat, [
    List<SocialUser>? tchatUsers,
  ]) {
    // No-op: the package navigates to a group-settings route that does not
    // exist in this app's router (group chats are not a mobile feature).
  }
}
