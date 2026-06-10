import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:core_kosmos/core_kosmos.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:kosmos_chat/backend/controller/cache/hive_controller.dart';
import 'package:kosmos_chat/backend/controller/interface/tchat_interface.dart';
import 'package:kosmos_chat/backend/controller/isolate/firebase_storage.dart';
import 'package:kosmos_chat/backend/model/enum.dart';
import 'package:kosmos_chat/backend/model/message/message_model.dart';
import 'package:kosmos_chat/backend/model/tchat/tchat_model.dart';
import 'package:kosmos_chat/backend/provider/message_list.dart';
import 'package:kosmos_chat/backend/utils/utils.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:ui_kosmos_v4/ui_kosmos_v4.dart';
import 'package:uuid/uuid.dart';
// ignore: depend_on_referenced_packages
import 'package:dartz/dartz.dart' as dz;

class TchatController implements TchatInterface {
  const TchatController() : super();

  @override
  Future<void> updateMute(String userId, String tchatId, bool mute) async {
    try {
      await FirebaseFirestore.instance.collection("tchat").doc(tchatId).update({
        "chatMutedBy": mute
            ? FieldValue.arrayUnion([userId])
            : FieldValue.arrayRemove([userId])
      });
    } catch (e) {
      rethrow;
    }
  }

  /// Permet de récupérer les données d'un tchat.
  /// Si le tchat existe dans la liste, on le retourne.
  /// Le cas échéant, nous tentons de le récupérer depuis
  /// la base de données.
  ///
  /// Si le tchat n'existe pas, nous retournons null.
  @override
  Future<TchatModel?> getTchatData(String tchatId,
      [List<TchatModel>? tchatList]) async {
    TchatModel? r =
        tchatList?.firstWhereOrNull((element) => element.id == tchatId);
    if (r != null) return r;

    final doc =
        await FirebaseFirestore.instance.collection("tchat").doc(tchatId).get();
    if (doc.exists) {
      return TchatModel.fromJson(doc.data() ?? {}).copyWith(id: doc.id);
    }

    return null;
  }

  /// Permet de récupérer les données de tous les tchat.
  /// Nous retournons un [StreamSubscription] pour pouvoir
  /// écouter les changements.
  ///
  /// Nous écoutons les changements sur la collection "tchat".
  ///
  /// Si les données sont déjà présentes dans la liste, nous
  /// mettons à jour les données.
  /// Par exemple, nous chargeons les données des tchats
  /// présent dans le cache.
  ///
  /// À chaque changement, nous mettons à jour les données
  /// dans le cache.
  ///
  /// Si un tchat est supprimé, nous le supprimons de la
  /// liste (uniquement si celui-ci exitse encore).
  /// Nous le supprimons également du cache.
  ///
  /// - [tchatList] est la liste des tchats déjà existante,
  /// elle est modifiée à chaque changement.
  ///
  /// - [fetchUserData] est la fonction permettant de récupérer
  /// les données d'un utilisateur.
  ///
  /// - [notify] est la fonction permettant de notifier les
  /// widgets qui écoutent les changements.
  ///
  /// - [cachedTchatController] est le contrôleur permettant
  /// de gérer le cache.
  ///
  /// Cette fonction permet de gérer toutes les données
  /// depuis un Back End Firebase. Tout en s'occupant du cache.
  @override
  StreamSubscription streamTchatList(
    Map<String, TchatModel> tchatList,
    FutureOr<void> Function(String)? fetchUserData,
    VoidCallback? notify,
    CachedTchatController cachedTchatController,
  ) {
    if (kDebugMode) {
      printDebug(FirebaseAuth.instance.currentUser!.uid);
      final _ = (FirebaseFirestore.instance
              .collection("tchat")
              .where("participants",
                  arrayContains: FirebaseAuth.instance.currentUser!.uid)
              .get())
          .then((value) => printInfo(value.docs.length));
    }

    final showIfEmpty = getTchatBackEndConfig().showTchatIfNoMessage;

    return FirebaseFirestore.instance
        .collection("tchat")
        .where("participants",
            arrayContains: FirebaseAuth.instance.currentUser!.uid)
        .orderBy("lastMessageSentAt", descending: true)
        .snapshots()
        .listen((event) async {
      if (event.docChanges.isEmpty) return;

      for (final docChange in event.docChanges) {
        String docId = docChange.doc.id;
        switch (docChange.type) {
          /// Événement ajouté.
          case DocumentChangeType.added:
            final isAlreadyExisting = tchatList.containsKey(docId);
            if (isAlreadyExisting) {
              tchatList[docId] = TchatModel.fromJson(docChange.doc.data() ?? {})
                  .copyWith(id: docChange.doc.id);
              await backendCacheControllerTchat.save(
                  tchatList[docId]!, docId, tchatList[docId]!.toJson);
              for (var element in tchatList[docId]?.participants ?? []) {
                await fetchUserData?.call(element);
              }
              break;
            }

            final data = TchatModel.fromJson(docChange.doc.data() ?? {})
                .copyWith(id: docChange.doc.id);
            final deletedData = data.deletedBy?.firstWhereOrNull(
                (p0) => p0.userId == FirebaseAuth.instance.currentUser!.uid);
            //
            bool? existMessageAfterLastDeletedData = false;
            if (deletedData?.deletedAt != null) {
              final message = await FirebaseFirestore.instance
                  .collection("tchat")
                  .doc(data.id)
                  .collection("messages")
                  .where("sendAt",
                      isGreaterThanOrEqualTo:
                          Timestamp.fromDate(deletedData!.deletedAt!))
                  .get();
              if (message.docs.isNotEmpty) {
                existMessageAfterLastDeletedData = true;
              }
            } else {
              final message = await FirebaseFirestore.instance
                  .collection("tchat")
                  .doc(data.id)
                  .collection("messages")
                  .where("sendAt", isLessThan: Timestamp.now())
                  .get();
              if (message.docs.isNotEmpty) {
                existMessageAfterLastDeletedData = true;
              }
            }
            if (!existMessageAfterLastDeletedData && !showIfEmpty) continue;
            tchatList[docId] = data;
            for (var element in data.participants) {
              await fetchUserData?.call(element);
            }
            await backendCacheControllerTchat.save(data, data.id!, data.toJson);
            break;

          /// Événement modifié.
          case DocumentChangeType.modified:
            final exists = tchatList.containsKey(docId);
            if (!exists) {
              final data = TchatModel.fromJson(docChange.doc.data() ?? {})
                  .copyWith(id: docChange.doc.id);
              final deletedDates = List.from(data.deletedBy ?? []);
              deletedDates.sort((a, b) => b.deletedAt!.compareTo(a.deletedAt!));
              final deletedData = deletedDates.firstWhereOrNull(
                  (p0) => p0.userId == FirebaseAuth.instance.currentUser!.uid);
              bool? existMessageAfterLastDeletedData = false;

              if (deletedData?.deletedAt != null) {
                final message = await FirebaseFirestore.instance
                    .collection("tchat")
                    .doc(data.id)
                    .collection("messages")
                    .where("sendAt",
                        isGreaterThan:
                            Timestamp.fromDate(deletedData!.deletedAt!))
                    .get();
                if (message.docs.isNotEmpty) {
                  existMessageAfterLastDeletedData = true;
                }
              } else {
                final message = await FirebaseFirestore.instance
                    .collection("tchat")
                    .doc(data.id)
                    .collection("messages")
                    .where("sendAt", isLessThanOrEqualTo: Timestamp.now())
                    .get();
                if (message.docs.isNotEmpty) {
                  existMessageAfterLastDeletedData = true;
                }
              }
              if (!existMessageAfterLastDeletedData && !showIfEmpty) {
                await backendCacheControllerTchat.delete(docChange.doc.id);
                continue;
              }
              tchatList[docId] = data;
              for (var element in data.participants) {
                await fetchUserData?.call(element);
              }
              await backendCacheControllerTchat.save(
                  data, data.id!, data.toJson);
              // }
              break;
            }

            if (exists) {
              final data = TchatModel.fromJson(docChange.doc.data() ?? {})
                  .copyWith(id: docChange.doc.id);
              final deletedData = data.deletedBy?.firstWhereOrNull(
                  (p0) => p0.userId == FirebaseAuth.instance.currentUser!.uid);
              bool? existMessageAfterLastDeletedData = false;

              if (deletedData?.deletedAt != null) {
                final message = await FirebaseFirestore.instance
                    .collection("tchat")
                    .doc(data.id)
                    .collection("messages")
                    .where("sendAt",
                        isGreaterThan:
                            Timestamp.fromDate(deletedData!.deletedAt!))
                    .get();
                if (message.docs.isNotEmpty) {
                  existMessageAfterLastDeletedData = true;
                }
              } else {
                final message = await FirebaseFirestore.instance
                    .collection("tchat")
                    .doc(data.id)
                    .collection("messages")
                    .where("sendAt", isLessThanOrEqualTo: Timestamp.now())
                    .get();
                if (message.docs.isNotEmpty) {
                  existMessageAfterLastDeletedData = true;
                }
              }
              if (!existMessageAfterLastDeletedData && !showIfEmpty) {
                tchatList.remove(docId);
                await backendCacheControllerTchat.delete(docChange.doc.id);
                continue;
              }
            }
            tchatList[docId] = TchatModel.fromJson(docChange.doc.data() ?? {})
                .copyWith(id: docChange.doc.id);
            for (var element in tchatList[docId]?.participants ?? []) {
              await fetchUserData?.call(element);
            }
            await backendCacheControllerTchat.save(
                tchatList[docId]!, docId, tchatList[docId]!.toJson);
            break;

          /// Événement de suppression.
          case DocumentChangeType.removed:
            tchatList.remove(docId);
            await backendCacheControllerTchat.delete(docChange.doc.id);
            break;
        }
        notify?.call();
      }
      notify?.call();
    });
  }

  /// Permet de récupérer les messages d'un tchat.
  /// Nous retournons un [StreamSubscription] pour pouvoir
  /// écouter les changements.
  ///
  /// Nous écoutons les changements sur la collection "tchat",
  /// document "id" et sous-collection "messages".
  ///
  /// Si les données sont déjà présentes dans la liste, nous
  /// mettons à jour les données.
  ///
  /// À chaque changement, nous mettons à jour les données
  /// dans le cache.
  ///
  /// Si un message est supprimé, nous le supprimons de la
  /// liste (uniquement si celui-ci exitse encore).
  /// Nous le supprimons également du cache.
  ///
  /// - [tchatId] est l'id du tchat.
  ///
  /// - [messageList] est la liste des messages déjà existante,
  /// elle est modifiée à chaque changement.
  ///
  /// - [notify] est la fonction permettant de notifier les
  /// widgets qui écoutent les changements.
  ///
  /// - [cachedTchatController] est le contrôleur permettant
  /// de gérer le cache.
  ///
  /// Cette fonction permet de gérer toutes les données
  /// depuis un Back End Firebase. Tout en s'occupant du cache.
  @override
  StreamSubscription streamMessageOfTchat(
    String tchatId,
    List<MessageModel> messageList,
    VoidCallback? notify,
    CachedTchatController cachedTchatController, [
    DateTime? minimalSendingDate,
    List<String> bloquedUsers = const [],
  ]) {
    Query<Map<String, dynamic>>? customQuery;

    // new Firebase version doesn't support null value in where clause (> null)
    if (minimalSendingDate == null) {
      customQuery = FirebaseFirestore.instance
          .collection("tchat")
          .doc(tchatId)
          .collection("messages")
          .orderBy("sendAt");
    } else {
      customQuery = FirebaseFirestore.instance
          .collection("tchat")
          .doc(tchatId)
          .collection("messages")
          .where("sendAt", isGreaterThanOrEqualTo: minimalSendingDate)
          .orderBy("sendAt");
    }

    return customQuery.snapshots().listen((event) async {
      if (event.docChanges.isEmpty) return;

      for (final docChange in event.docChanges) {
        switch (docChange.type) {
          /// Événement ajouté.
          case DocumentChangeType.added:
            final fromId = docChange.doc.data()?["sendId"] as String?;
            if (bloquedUsers.contains(fromId ?? "")) continue;
            final isAlreadyExisting =
                messageList.any((element) => element.id == docChange.doc.id);
            if (isAlreadyExisting) {
              final index = messageList
                  .indexWhere((element) => element.id == docChange.doc.id);
              if (index == -1) break;
              messageList[index] =
                  MessageModel.fromJson(docChange.doc.data() ?? {})
                      .copyWith(id: docChange.doc.id);
              backendCacheControllerMessage.save(
                  messageList[index],
                  messageList[index].id!,
                  () => {...messageList[index].toJson(), "tchatId": tchatId});
              if (messageList[index].messageType == "media") {
                for (final MediaModel item in messageList[index].media ?? []) {
                  if (item.mediaRelativePath == null || item.mediaUrl == null) {
                    continue;
                  }
                  if (autoSaveMedia) {
                    ImageFileController.downloadFileAndSaveLocally(
                            Uri.parse(item.mediaUrl!), item.mediaRelativePath!)
                        .then((value) async {
                      if (value != null) {
                        await ImageGallerySaverPlus.saveImage(
                            File(value).readAsBytesSync());
                      }
                    });

                    if (item.videoThumbnailRelativePath != null &&
                        item.videoThumbnail != null) {
                      ImageFileController.downloadFileAndSaveLocally(
                          Uri.parse(item.videoThumbnail!),
                          item.videoThumbnailRelativePath!);
                    }
                  }
                }
              }
              break;
            }

            final data = MessageModel.fromJson(docChange.doc.data() ?? {})
                .copyWith(id: docChange.doc.id);
            if (data.deleteBy
                .contains(FirebaseAuth.instance.currentUser!.uid)) {
              continue;
            }
            messageList.add(data);

            backendCacheControllerMessage.save(
                data, data.id!, () => {...data.toJson(), "tchatId": tchatId});
            if (data.messageType == "media") {
              for (final MediaModel item in data.media ?? []) {
                if (item.mediaRelativePath == null || item.mediaUrl == null) {
                  continue;
                }
                if (autoSaveMedia) {
                  await ImageFileController
                          .downloadFileAndSaveLocallyAndCheckIfExists(
                              Uri.parse(item.mediaUrl!),
                              item.mediaRelativePath!)
                      .then((value) async {
                    if (value != null && value.value2 == false) {
                      if (item.mediaType == AssetType.image) {
                        await ImageGallerySaverPlus.saveImage(
                            File(value.value1).readAsBytesSync());
                      } else {
                        await ImageGallerySaverPlus.saveFile(value.value1);
                      }
                    }
                  });

                  if (item.videoThumbnailRelativePath != null &&
                      item.videoThumbnail != null) {
                    await ImageFileController.downloadFileAndSaveLocally(
                        Uri.parse(item.videoThumbnail!),
                        item.videoThumbnailRelativePath!);
                  }
                }
              }
            }

            if (!data.readBy.contains(FirebaseAuth.instance.currentUser!.uid)) {
              docChange.doc.reference.update({
                "seenBy": FieldValue.arrayUnion(
                    [FirebaseAuth.instance.currentUser!.uid]),
                "readBy": FieldValue.arrayUnion(
                    [FirebaseAuth.instance.currentUser!.uid]),
              });

              data.media?.forEach((element) {
                if (element.mediaType == AssetType.image) {
                  // GallerySaver.saveImage(element.mediaUrl)
                }
              });
            }

            break;

          /// Événement Modification.
          case DocumentChangeType.modified:
            final fromId = docChange.doc.data()?["sendId"] as String?;
            if (bloquedUsers.contains(fromId ?? "")) continue;
            final index = messageList
                .indexWhere((element) => element.id == docChange.doc.id);
            if (index == -1) break;
            final data = MessageModel.fromJson(docChange.doc.data() ?? {})
                .copyWith(id: docChange.doc.id);
            if (data.deleteBy
                .contains(FirebaseAuth.instance.currentUser!.uid)) {
              messageList
                  .removeWhere((element) => element.id == docChange.doc.id);
              backendCacheControllerMessage.delete(docChange.doc.id);
              break;
            }
            messageList[index] = data;
            backendCacheControllerMessage.save(
                messageList[index],
                messageList[index].id!,
                () => {...messageList[index].toJson(), "tchatId": tchatId});
            break;

          /// Événement de suppression.
          case DocumentChangeType.removed:
            messageList
                .removeWhere((element) => element.id == docChange.doc.id);
            backendCacheControllerMessage.delete(docChange.doc.id);
            break;
        }
        notify?.call();
      }
    });
  }

  /// Permet de créer un tchat OtO ou de groupe.
  ///
  /// Dans le cas ou le tchat est de type [TchatType.oneToOne],
  /// nous utilisons [userId1] et [userId2] pour créer l'id du
  /// tchat.
  ///
  /// Dans le cas ou le tchat est de type [TchatType.group],
  /// nous utilisons [creatorId] ainsi qu'un [Uuid] basé sur
  /// le timestamp pour créer l'id du tchat.
  @override
  Future<String?> createTchat(TchatType tchatType,
      {String? userId1,
      String? userId2,
      String? creatorId,
      String? groupeId,
      String? tchatName,
      List<String>? participants}) async {
    final showIfEmpty = getTchatBackEndConfig().showTchatIfNoMessage;
    try {
      if (tchatType == TchatType.group) {
        assert(
          tchatType == TchatType.group &&
              (participants?.length ?? 0) >= 1 &&
              creatorId != null,
          "Pour créer un tchat de groupe, vous devez fournir au moins 1 participant with creatorId in",
        );
      }

      final Map<String, dynamic> payload = {
        "type": enumToString(tchatType),
        "lastMessageSentAt": FieldValue.serverTimestamp(),
        "isGroup": tchatType == TchatType.group,
      };
      String id = "";

      if (tchatType == TchatType.oneToOne) {
        assert(userId1 != null && userId2 != null,
            "Pour créer un Tchat OneToOne, vous devez fournir les 2 userId");
        List<String> combin_ids = [userId1!, userId2!].toList();
        combin_ids.sort();
        id = "${combin_ids.first}_${combin_ids[1]}";
        payload.addAll({
          "participants": [userId1, userId2],
          "adminId": userId1,
          // avoid to have notif when another user create a new tchat and no message is sent
          if (!showIfEmpty) "lastMessageSeenBy": [userId2],
        });
      } else if (tchatType == TchatType.group) {
        assert(creatorId != null,
            "Pour créer un Tchat Group, vous devez fournir l'id du créateur");
        final uuid = const Uuid().v1();
        id = groupeId ?? "${creatorId!}_$uuid";
        payload.addAll({
          "participants": participants,
          "id": id,
          "adminId": creatorId,
          "tchatName": tchatName ?? "package.tchat.new-group".tr(),
        });
      }

      await FirebaseFirestore.instance.collection("tchat").doc(id).set(payload);

      return id;
    } catch (e) {
      printExcept(e);
      return null;
    }
  }

  @override
  FutureOr<void> tchatListTopActionEvent(BuildContext context) {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> getUserData(String userId) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .get()
        .then((value) async {
      return value.data() ?? {};
    });
  }

  @override
  Future<void> openTchat(
      BuildContext context, WidgetRef ref, TchatModel tchat) async {
    assert(tchat.id != null, "Vous devez fournir l'id du tchat");

    ref.read(messageListProvider).init(tchat.id!);
    await AutoRouter.of(context).pushNamed("app/tchat/${tchat.id}");
    return;
  }

  Future<bool> openOTOchat(
      BuildContext context, WidgetRef ref, String userId1, String userId2,
      {Function(String tchatId)? beforeRedirection}) async {
    try {
      String? id;
      DocumentReference<Object?>? tchatRef = await tchatExist(
          TchatType.oneToOne,
          userId: userId1,
          otherUserId: userId2);
      if (tchatRef == null) {
        String? idTchat = await createTchat(TchatType.oneToOne,
            userId1: userId1, userId2: userId2);
        id = idTchat;
      } else {
        id = tchatRef.id;
      }
      if (id == null) return false;
      ref.read(messageListProvider).init(id);
      await beforeRedirection?.call(id);
      if (context.mounted) {
        await AutoRouter.of(context).pushNamed("app/tchat/$id");
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> setLastMessageRead(String tchatId) {
    return FirebaseFirestore.instance.collection("tchat").doc(tchatId).update({
      "lastMessageSeenBy":
          FieldValue.arrayUnion([FirebaseAuth.instance.currentUser!.uid])
    });
  }

  @override
  void uploadListOfAssetFileToDatabase(
    List<dz.Tuple2<String, dz.Either<MultiPickedAsset, Uint8List>>> assets,
    String tchatId,
    String messageId, {
    void Function(List<dz.Tuple2<String, String>> p1)? onSuccess,
    void Function(Object p1)? onError,
  }) async {
    final Map<String, dynamic>? result =
        await uploadListOfAssetsAndBytesToFirebase(tchatId, assets);
    final List<Map<String, dynamic>>? items =
        (result?["data"] as List<dynamic>?)
            ?.map((e) => e as Map<String, dynamic>)
            .toList();

    final messageData = (await FirebaseFirestore.instance
        .collection("tchat")
        .doc(tchatId)
        .collection("messages")
        .doc(messageId)
        .get());
    if (!messageData.exists) return;
    MessageModel model =
        MessageModel.fromJson(messageData.data() ?? {}).copyWith(id: messageId);
    final List<MediaModel> media = List.from(model.media ?? []);
    for (final item in items ?? []) {
      final index =
          media.indexWhere((element) => element.id == item["idInMessage"]);
      if (index == -1) continue;
      media[index] = media[index].copyWith(
          mediaUrl: item["url"], videoThumbnail: item["videoThumbnail"]);
    }
    model = model.copyWith(media: media);
    await FirebaseFirestore.instance
        .collection("tchat")
        .doc(tchatId)
        .collection("messages")
        .doc(messageId)
        .update(model.toJson());
  }

  // // void uploadListOfAssetFileToDatabaseX(
  // //   List<dz.Tuple2<String, dz.Either<AssetEntity, Uint8List>>> assets,
  // //   String tchatId,
  // //   String messageId, {
  // //   void Function(List<dz.Tuple2<String, String>> p1)? onSuccess,
  // //   void Function(Object p1)? onError,
  // // }) async {
  // //   final Map<String, dynamic> json = {
  // //     "tchatId": tchatId,
  // //     "assets": assets
  // //         .map((e) => {"idInMessage": e.value1, "assetId": e.value2.id})
  // //         .toList(),
  // //   };

  // //   final String? encodedJson =
  // //       await uploadListOfAssetFileToFirebase(jsonEncode(json));

  // //

  // //   if (encodedJson == null) return;

  // //   final data = jsonDecode(encodedJson) as Map<String, dynamic>;
  // //   final List<Map<String, dynamic>>? items = (data["data"] as List<dynamic>?)
  // //       ?.map((e) => e as Map<String, dynamic>)
  // //       .toList();
  // //   final messageData = (await FirebaseFirestore.instance
  // //       .collection("tchat")
  // //       .doc(tchatId)
  // //       .collection("messages")
  // //       .doc(messageId)
  // //       .get());
  // //   if (!messageData.exists) return;
  // //   MessageModel model =
  // //       MessageModel.fromJson(messageData.data() ?? {}).copyWith(id: messageId);
  // //   final List<MediaModel> media = List.from(model.media ?? []);
  // //   for (final item in items ?? []) {
  // //     final index =
  // //         media.indexWhere((element) => element.id == item["idInMessage"]);
  // //     if (index == -1) continue;
  // //     media[index] = media[index].copyWith(
  // //         mediaUrl: item["url"], videoThumbnail: item["videoThumbnail"]);
  // //   }
  // //   model = model.copyWith(media: media);
  // //   await FirebaseFirestore.instance
  // //       .collection("tchat")
  // //       .doc(tchatId)
  // //       .collection("messages")
  // //       .doc(messageId)
  // //       .update(model.toJson());
  // // }

  @override
  Future<DocumentReference?> tchatExist(TchatType type,
      {String? userId, String? otherUserId, String? groupeId}) async {
    if (type == TchatType.oneToOne) {
      assert(userId != null && otherUserId != null,
          "Pour vérifier l'existence d'un tchat OneToOne, vous devez fournir les 2 userId");
    } else if (type == TchatType.group) {
      assert(groupeId != null,
          "Pour vérifier l'existence d'un tchat Group, vous devez fournir l'id du groupe");
    }

    String id = TchatType.group == type ? groupeId! : "";
    if (type == TchatType.oneToOne) {
      List<String> combin_ids = [userId!, otherUserId!].toList();
      combin_ids.sort();
      id = "${combin_ids.first}_${combin_ids[1]}";
    }
    final r =
        await FirebaseFirestore.instance.collection("tchat").doc(id).get();
    if (!r.exists && type == TchatType.oneToOne) {
      final id2 =
          type == TchatType.oneToOne ? "${otherUserId!}_${userId!}" : groupeId!;
      final r2 =
          await FirebaseFirestore.instance.collection("tchat").doc(id2).get();
      if (r2.exists) return r2.reference;
    }
    return r.exists ? r.reference : null;
  }

  @override
  Future<TchatModel?> loadTchatFromId(String tchatId) async {
    final ref =
        await FirebaseFirestore.instance.collection("tchat").doc(tchatId).get();
    if (!ref.exists) return null;
    return TchatModel.fromJson(ref.data() ?? {}).copyWith(id: ref.id);
  }
}
