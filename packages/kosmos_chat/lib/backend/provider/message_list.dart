import 'dart:async';
import 'dart:io';
// ignore: depend_on_referenced_packages
import 'package:dartz/dartz.dart' as dz;

import 'package:core_kosmos/core_kosmos.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:kosmos_chat/backend/controller/cache/hive_controller.dart';
import 'package:kosmos_chat/backend/kosmos_chat_backend.dart';
import 'package:kosmos_chat/backend/utils/utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:record/record.dart';
import 'package:ui_kosmos_v4/ui_kosmos_v4.dart';
import 'package:uuid/uuid.dart';

final messageListProvider = ChangeNotifierProvider<MessageListProvider>((ref) {
  return MessageListProvider(ref);
});

class MessageListProvider with ChangeNotifier {
  List<MessageModel>? _messages;

  late TchatBackEndConfig _backEndConfig;

  Ref _ref;
  List<MessageModel>? get messages => _messages;
  String? appPath;
  String _actualTchatId = "";

  String get actualTchatId => _actualTchatId;

  StreamSubscription? _subscription;
  StreamSubscription? get subscription => _subscription;

  MessageModel? replyTo;

  MessageListProvider(this._ref) {
    _backEndConfig = getTchatBackEndConfig();
  }

  Future<void> cancelStream() async {
    _subscription?.cancel();
  }

  Future<void> init(String tchatId) async {
    _actualTchatId = tchatId;
    replyTo = null;
    appPath = (await getApplicationDocumentsDirectory()).path;
    DateTime? minimalDate;
    final tchat = _ref
        .read(tchatListProvider(FirebaseAuth.instance.currentUser!.uid))
        .tchatList
        ?.firstWhereOrNull((p0) => p0.id == tchatId);
    if (tchat != null) {
      final deletedBy = tchat.deletedBy;
      minimalDate = deletedBy
          ?.firstWhereOrNull((element) =>
              element.userId == FirebaseAuth.instance.currentUser!.uid)
          ?.deletedAt;
    }

    _subscription?.cancel();
    _messages = List.from([]);

    /// Load cache data
    _messages = List.from(await backendCacheControllerMessage.loadIf(
      (data, id) => MessageModel.fromJson(data).copyWith(id: id),
      (data) => data["tchatId"] == tchatId,
    ));

    _messages!.sort((a, b) => a.sendAt!.compareTo(b.sendAt!));

    /// Refresh Ui
    notifyListeners();

    final bloquesUsersList =
        _ref.read(userProvider).metadata?.bloquedUsers ?? [];

    /// Load Stream
    _subscription = _backEndConfig.tchatInterface.streamMessageOfTchat(
      tchatId,
      _messages!,
      notifyListeners,
      backendCacheControllerMessage,
      minimalDate,
      bloquesUsersList,
    );
    _backEndConfig.tchatInterface.setLastMessageRead(tchatId);
  }

  void clear([bool notify = false]) {
    _subscription?.cancel();
    _messages = null;
    _actualTchatId = "";
    if (notify) notifyListeners();
  }

  Future<void> sendTextMessage(
      BuildContext context, WidgetRef ref, TchatModel tchat, String message,
      [MessageModel? replyTo]) async {
    assert(tchat.id != null, "Tchat id can't be null");
    assert(message.isNotEmpty, "Message can't be empty");

    final model = MessageModel(
      tchatId: tchat.id!,
      senderId: FirebaseAuth.instance.currentUser!.uid,
      messageType: "text",
      content: message.trim(),
      readBy: [FirebaseAuth.instance.currentUser!.uid],
      sendStatus: "sending",
      sendAt: DateTime.now(),
      replyTo: replyTo,
    );

    final uuid = const Uuid().v4();

    backendCacheControllerMessage
        .save(model, uuid, () => {...model.toJson(), "tchatId": _actualTchatId})
        .then((value) async {
      await _backEndConfig.messageInterface
          .sendMessage(context, ref, tchat, model, uuid);
    });

    replyTo = null;
  }

  Future<void> sendAudioMessage(BuildContext context, WidgetRef ref,
      TchatModel tchat, String assetAudio, AudioRecorder record,
      [MessageModel? replyTo]) async {
    assert(tchat.id != null, "Tchat id can't be null");

    final uuid = const Uuid().v4();
    File file = File(assetAudio);

    final localPath =
        "tchat/${tchat.id}/media/audio/$uuid/${file.path.split("/").last}";
    final r = await ImageFileController.uploadStandartFileToFirebaseStorage(
        file, localPath);
    if (r == null) {
      printError("Error while uploading audio file");
      return;
    }

    final model = MessageModel(
      tchatId: tchat.id!,
      senderId: FirebaseAuth.instance.currentUser!.uid,
      messageType: "audio",
      content: "",
      readBy: [FirebaseAuth.instance.currentUser!.uid],
      sendStatus: "sending",
      sendAt: DateTime.now(),
      replyTo: replyTo,
      media: [MediaModel(mediaUrl: r, mediaRelativePath: localPath)],
    );

    backendCacheControllerMessage
        .save(model, uuid, () => {...model.toJson(), "tchatId": _actualTchatId})
        .then((value) async {
      await _backEndConfig.messageInterface
          .sendMessage(context, ref, tchat, model, uuid, file: file);
    });

    replyTo = null;
  }

  sendMediaMessage(BuildContext context, WidgetRef ref, TchatModel tchat,
      List<dz.Either<MultiPickedAsset, Uint8List>> media,
      [String? message]) async {
    assert(tchat.id != null, "Tchat id can't be null");
    assert(media.isNotEmpty,
        "Vous devez fournir au moins un media pour envoyer le message");
    final tmpList = List<dz.Either<MultiPickedAsset, Uint8List>>.from(media);
    List<MediaModel> mediaList = [];
    final tchatPath = "tchat/${tchat.id}";
    List<dz.Tuple2<String, dz.Either<MultiPickedAsset, Uint8List>>> assetsToUpload =
        [];

    for (final assetX in tmpList) {
      if (assetX.isLeft()) {
        MultiPickedAsset asset = assetX.fold((l) => l, (r) => null)!;
        final uuid = const Uuid().v4();

        /// Set relative path for file
        final relativePath =
            "$tchatPath/$uuid.${asset.mimeType?.split("/").last}";

        String? thumbnailPath;

        /// Set relative path for thumbnail if asset is a video
        if (asset.type == AssetType.video) {
          try {
            Uint8List? thumbData = await asset.thumbnail;
            if (thumbData != null) {
              final appDir = (await getApplicationDocumentsDirectory()).path;
              final thumbPath = "$appDir/$tchatPath/$uuid.jpg";
              File file = await File(thumbPath).create();
              file.writeAsBytesSync(thumbData);
              thumbnailPath = '$tchatPath/$uuid.jpg';
            }
          } catch (e) {
            printExcept(e.toString());
          }
        }

        final mediaModel = MediaModel(
          id: uuid,
          mediaUrl: null,
          mediaRelativePath: relativePath,
          mediaName: uuid,
          mediaType: asset.type == PickedAssetType.image ? AssetType.image : AssetType.video,
          mediaWidth: asset.mediaWidth,
          mediaHeight: asset.mediaHeight,
          videoThumbnail: null,
          videoThumbnailRelativePath: thumbnailPath,
        );
        assetsToUpload.add(dz.Tuple2(uuid, dz.left(asset)));
        mediaList.add(mediaModel);
      } else if (assetX.isRight()) {
        Uint8List data = assetX.fold((l) => null, (r) => r)!;
        final uuid = const Uuid().v4();

        /// Set relative path for file
        final relativePath = "$tchatPath/$uuid.jpg";

        final mediaModel = MediaModel(
          id: uuid,
          mediaUrl: null,
          mediaRelativePath: relativePath,
          mediaName: uuid,
          mediaType: AssetType.image,
          mediaWidth: 0,
          mediaHeight: 0,
          videoThumbnail: null,
          videoThumbnailRelativePath: null,
        );
        assetsToUpload.add(dz.Tuple2(uuid, dz.right(data)));
        mediaList.add(mediaModel);
      }
    }
    final messageUuid = const Uuid().v4();
    _backEndConfig.tchatInterface.uploadListOfAssetFileToDatabase(
      assetsToUpload,
      tchat.id!,
      messageUuid,
      onSuccess: (urls) {
        printWarning("urls: $urls");
      },
      onError: (e) {
        printExcept(e.toString());
      },
    );

    final model = MessageModel(
      tchatId: tchat.id!,
      senderId: FirebaseAuth.instance.currentUser!.uid,
      messageType: "media",
      readBy: [FirebaseAuth.instance.currentUser!.uid],
      sendStatus: "sending",
      content: message,
      sendAt: DateTime.now(),
      replyTo: replyTo,
      media: mediaList,
    );

    backendCacheControllerMessage
        .save(model, messageUuid,
            () => {...model.toJson(), "tchatId": _actualTchatId})
        .then((value) async {
      await _backEndConfig.messageInterface
          .sendMessage(context, ref, tchat, model, messageUuid);
    });

    return assetsToUpload;
  }

  // // Future<List<dz.Tuple2<String, dz.Either<AssetEntity, Uint8List>>>>
  // //     sendMediaMessage(BuildContext context, WidgetRef ref, TchatModel tchat,
  // //         List<dz.Either<AssetEntity, Uint8List>> media,
  // //         [String? message]) async {
  // //   assert(tchat.id != null, "Tchat id can't be null");
  // //   assert(media.isNotEmpty,
  // //       "Vous devez fournir au moins un media pour envoyer le message");

  // //   final tmpList = List<dz.Either<AssetEntity, Uint8List>>.from(media);

  // //   List<MediaModel> mediaList = [];
  // //   List<dz.Tuple2<String, dz.Either<AssetEntity, Uint8List>>> assetsToUpload =
  // //       [];

  // //   final tchatPath = "tchat/${tchat.id}";

  // //   for (final asset in tmpList) {
  // //     final uuid = const Uuid().v4();

  // //     /// Set relative path for file
  // //     final relativePath =
  // //         "$tchatPath/$uuid.${asset.mimeType?.split("/").last}";

  // //     String? thumbnailPath;

  // //     /// Set relative path for thumbnail if asset is a video
  // //     if (asset.type == AssetType.video) {
  // //       try {
  // //         Uint8List? thumbData = await asset.thumbnailData;
  // //         if (thumbData != null) {
  // //           final appDir = (await getApplicationDocumentsDirectory()).path;
  // //           final thumbPath = "$appDir/$tchatPath/$uuid.jpg";
  // //           File file = await File(thumbPath).create();
  // //           file.writeAsBytesSync(thumbData);
  // //           thumbnailPath = '$tchatPath/$uuid.jpg';
  // //         }
  // //       } catch (e) {
  // //         printExcept(e.toString());
  // //       }
  // //     }

  // //     final mediaModel = MediaModel(
  // //       id: uuid,
  // //       mediaUrl: null,
  // //       mediaRelativePath: relativePath,
  // //       mediaName: asset.title ?? uuid,
  // //       mediaType: asset.type,
  // //       mediaWidth: asset.width.toDouble(),
  // //       mediaHeight: asset.height.toDouble(),
  // //       videoThumbnail: null,
  // //       videoThumbnailRelativePath: thumbnailPath,
  // //     );
  // //     assetsToUpload.add(dz.Tuple2(uuid, dz.left(asset)));
  // //     mediaList.add(mediaModel);
  // //   }

  // //   final messageUuid = const Uuid().v4();
  // //   _backEndConfig.tchatInterface.uploadListOfAssetFileToDatabase(
  // //     assetsToUpload,
  // //     tchat.id!,
  // //     messageUuid,
  // //     onSuccess: (urls) {
  // //       printWarning("urls: $urls");
  // //     },
  // //     onError: (e) {
  // //       printExcept(e.toString());
  // //     },
  // //   );

  // //   final model = MessageModel(
  // //     tchatId: tchat.id!,
  // //     senderId: FirebaseAuth.instance.currentUser!.uid,
  // //     messageType: "media",
  // //     readBy: [FirebaseAuth.instance.currentUser!.uid],
  // //     sendStatus: "sending",
  // //     content: message,
  // //     sendAt: DateTime.now(),
  // //     replyTo: replyTo,
  // //     media: mediaList,
  // //   );

  // //
  // //   backendCacheControllerMessage
  // //       .save(model, messageUuid,
  // //           () => {...model.toJson(), "tchatId": _actualTchatId})
  // //       .then((value) async {
  // //     await _backEndConfig.messageInterface
  // //         .sendMessage(context, ref, tchat, model, messageUuid);
  // //   });

  // //   return assetsToUpload;
  // // }

  Future<void> setReplyTo(MessageModel? message) async {
    replyTo = message;
    notifyListeners();
  }
}
