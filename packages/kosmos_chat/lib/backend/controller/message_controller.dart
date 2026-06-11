import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:core_kosmos/core_kosmos.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kosmos_chat/backend/controller/cache/hive_controller.dart';
import 'package:kosmos_chat/backend/kosmos_chat_backend.dart';
import 'package:kosmos_chat/kosmos_chat.dart';

class MessageController extends MessageInterface {
  const MessageController();

  @override
  FutureOr<void> onTapAudioCall(
      BuildContext context, WidgetRef ref, TchatModel tchat,
      [List<SocialUser>? tchatUsers]) {
    throw UnimplementedError();
  }

  @override
  FutureOr<void> onTapTchatActions(
      BuildContext context, WidgetRef ref, TchatModel tchat) {
    throw UnimplementedError();
  }

  @override
  FutureOr<void> onTapVideoCall(
      BuildContext context, WidgetRef ref, TchatModel tchat,
      [List<SocialUser>? tchatUsers]) {
    throw UnimplementedError();
  }

  @override
  void onTchatNameClick(BuildContext context, TchatModel tchat,
      [List<SocialUser>? tchatUsers]) {
    if (tchat.type == TchatType.group) {
      AutoRouter.of(context).pushNamed("app/tchat/${tchat.id}/settings");
      return;
    }
    return;
  }

  @override
  void onTchatPhotoClick(BuildContext context, TchatModel tchat,
      [List<SocialUser>? tchatUsers]) {
    AutoRouter.of(context).maybePop();
  }

  @override
  Future<void> sendMessage(BuildContext context, WidgetRef ref,
      TchatModel tchat, MessageModel model, String uuid,
      {File? file}) async {
    await FirebaseFirestore.instance
        .collection("tchat")
        .doc(tchat.id)
        .collection("messages")
        .doc(uuid)
        .set(
      {
        ...model.copyWith(sendStatus: "send").toJson(),
        "sendAt": FieldValue.serverTimestamp(),
      },
    );

    await FirebaseFirestore.instance.collection("tchat").doc(tchat.id).update({
      "lastMessage": {
        ...model.copyWith(sendStatus: "send").toJson(),
        "sendAt": FieldValue.serverTimestamp(),
      },
      "deletedMessageHistory": {},
      "lastMessageSeenBy": [FirebaseAuth.instance.currentUser!.uid],
      "lastMessageSentAt": FieldValue.serverTimestamp(),
    });

    final userName = ref.read(userProvider).user?.pseudo ??
        ref.read(userProvider).user?.firstname ??
        "";

    List<String> tchatParticipantsNotMuteTchatOrUser = tchat.type ==
            TchatType.oneToOne
        ? tchat.participants
            .where(
                (element) => element != FirebaseAuth.instance.currentUser!.uid)
            .toList()
        : tchat.participants
            .where((element) =>
                element != FirebaseAuth.instance.currentUser!.uid &&
                !tchat.mutedUsersList.contains(
                    "${element}_${FirebaseAuth.instance.currentUser!.uid}") &&
                !tchat.chatMutedBy.contains(element))
            .toList();
    await NotifPermissionController.sendNotification(
      tchatParticipantsNotMuteTchatOrUser,
      title: "package.tchat.notification.new_message.title".tr(),
      body: "package.tchat.notification.new_message.body".tr(args: [userName]),
      type: "tchat_message",
      metadata: {
        "tchatId": tchat.id,
        "tchatPicture": tchat.tchatPicture,
        "tchatName": tchat.tchatName,
        "tchatType": enumToString(tchat.type),
        "messageId": uuid,
      },
    );
  }

  @override
  FutureOr<void> deleteTchat(WidgetRef ref, TchatModel tchat) async {
    final t = List<TchatDeletedStatus>.from(tchat.deletedBy ?? []);

    final oldDeletedBy = t
        .where((element) =>
            element.userId == FirebaseAuth.instance.currentUser!.uid)
        .toList();
    if (oldDeletedBy.isNotEmpty) {
      t.removeWhere((element) =>
          element.userId == FirebaseAuth.instance.currentUser!.uid);
    }
    TchatDeletedStatus chatDeletedStatus = TchatDeletedStatus(
        userId: FirebaseAuth.instance.currentUser!.uid,
        deletedAt: DateTime.now());
    t.add(chatDeletedStatus);
    tchat = tchat.copyWith(deletedBy: t);
    ref
        .read(tchatListProvider(FirebaseAuth.instance.currentUser!.uid))
        .removeTchat(tchat.id!);
    await backendCacheControllerTchat.delete(tchat.id!);

    try {
      await FirebaseFirestore.instance
          .collection("tchat")
          .doc(tchat.id)
          .update({
        "deletedBy": FieldValue.arrayUnion([chatDeletedStatus.toJson()]),
      });
      if (oldDeletedBy.isNotEmpty) {
        // Delete old deletedBy of users (remove microsecond and millisecond)
        List<dynamic> _ = oldDeletedBy.map((e) => e.toJson()).toList();
        await FirebaseFirestore.instance
            .collection("tchat")
            .doc(tchat.id)
            .update({
          "deletedBy": FieldValue.arrayRemove(_),
        });
      }
    } catch (e) {
      debugPrint(
          "Delete old deletedBy of users ${FirebaseAuth.instance.currentUser?.uid} $e");
    }
  }

  @override
  FutureOr<void> reportAndBlockTchat(
      WidgetRef ref, BuildContext context, TchatModel tchat) async {
    //! Bloque tous les participants du tchat, même pour un groupe.
    final usersInChat = tchat.participants
        .where((element) => element != FirebaseAuth.instance.currentUser!.uid)
        .toList();

    if (tchat.type == TchatType.oneToOne) {
      await FirebaseFirestore.instance
          .collection("tchat")
          .doc(tchat.id)
          .update({
        "blockedByUsers":
            FieldValue.arrayUnion([FirebaseAuth.instance.currentUser!.uid]),
      });
    }
// Blocage des utilisateurs
    // set + merge: le doc metadata peut ne pas exister (apps sans collection
    // users provisionnée) — update() échouerait en not-found.
    await FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection("metadata")
        .doc("metadata")
        .set({
      "bloquedUsers": FieldValue.arrayUnion(usersInChat),
    }, SetOptions(merge: true));
  }

  @override
  FutureOr<void> unlockTchat(WidgetRef ref, TchatModel tchat) async {
    final usersInChat = tchat.participants
        .where((element) => element != FirebaseAuth.instance.currentUser!.uid)
        .toList();

    if (tchat.type == TchatType.oneToOne) {
      await FirebaseFirestore.instance
          .collection("tchat")
          .doc(tchat.id)
          .update({
        "blockedByUsers":
            FieldValue.arrayRemove([FirebaseAuth.instance.currentUser!.uid]),
      });
    }
    await FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection("metadata")
        .doc("metadata")
        .set({
      "bloquedUsers": FieldValue.arrayRemove(usersInChat),
    }, SetOptions(merge: true));
  }
}
