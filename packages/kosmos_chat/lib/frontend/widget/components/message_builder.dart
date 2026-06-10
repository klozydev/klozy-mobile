// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:core_kosmos/core_kosmos.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:kosmos_chat/backend/provider/message_list.dart';
import 'package:kosmos_chat/backend/provider/tchat_user_data.dart';
import 'package:kosmos_chat/frontend/widget/components/private/media_message.dart';
import 'package:kosmos_chat/frontend/widget/components/private/text_message.dart';
import 'package:kosmos_chat/frontend/widget/components/warning_box.dart';
import 'package:kosmos_chat/kosmos_chat.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:ui_kosmos_v4/ui_kosmos_v4.dart';
import 'package:iconsax/iconsax.dart';
import 'private/audio_message.dart';

/// {@Category Widget}
/// {@Category Tchat}
///
/// Class contenant les builder des messages
/// prédéfinis :
///
/// - "text": [MessageBuilder.textBuilder]
/// - "media": [MessageBuilder.mediaBuilder]
/// - "media": [MessageBuilder.mediaBuilder]
/// - "audio":
/// - "document":
/// - "contact":
/// - "sondage":
/// - "devis":
/// - "location":
///
abstract class MessageBuilder {
  /// Permet de build automatiquement un message
  /// en fonction de son type.
  ///
  /// **/!\ attention**, ne se sert que pour les
  /// messages du tchat. Si vous souhaitez build
  /// un replyTo ou un preview (dans la liste
  /// des tchats) de message, vous devez utiliser
  /// class [ReplyToBuilder] ou [PreviewBuilder].
  ///
  /// Cette fonction va automatiquement récupérer
  /// la configuration des builders.
  /// Elle affichera le builder équivalent au type
  /// du message, ou le builder "text" par défaut.
  static Widget messageBuilder(String type, BuildContext context, WidgetRef ref,
      MessageModel model, TchatModel tchat) {
    final config = getTchatFrontEndConfig().message.messageConfig;
    final mapOfBuilders = config.messageContentBuilders;

    return mapOfBuilders[type]?.call(context, ref, model, tchat) ??
        textBuilder(context, ref, model, tchat);
  }

  /// Permet de build un message de type "text".
  ///
  /// Par défaut, la fonction affichera le
  /// [MessageModel.content] du message. Si celui
  /// -ci est nul, alors on affichera un text par
  /// défaut ("package.tchat.builder.no-message").
  ///
  /// Ce builder est automatiquement utilisé
  /// par la fonction [messageBuilder] si le type
  /// du message n'est pas reconnu.
  static Widget textBuilder(BuildContext context, WidgetRef ref,
          MessageModel model, TchatModel tchat) =>
      TextMessage(
        message: model,
        tchat: tchat,
      );

  static Widget audioBuilder(BuildContext context, WidgetRef ref,
          MessageModel model, TchatModel tchat) =>
      AudioMessage(
        message: model,
        tchat: tchat,
      );

  static Widget eventBuilder(BuildContext context, WidgetRef ref,
          MessageModel model, TchatModel tchat) =>
      WarningMessageBox(
        message: model,
      );

  /// Permet de build un message de type "media".
  ///
  /// Par défaut, la fonction affichera le
  /// [MessageModel.content] du message. Si celui
  /// -ci est nul, alors on affichera un text par
  /// défaut ("package.tchat.builder.no-message").
  ///
  /// Ce builder est automatiquement utilisé
  /// par la fonction [messageBuilder] si le type
  /// du message n'est pas reconnu.
  static Widget mediaBuilder(BuildContext context, WidgetRef ref,
          MessageModel model, TchatModel tchat) =>
      MediaMessage(
        message: model,
        tchat: tchat,
      );
}

/// {@Category Widget}
/// {@Category Tchat}
///
abstract class ReplyToBuilder {
  static Widget replyPreviewBuilder(
      BuildContext context, WidgetRef ref, MessageModel model, TchatModel tchat,
      [bool isMessage = false, bool fromMe = false]) {
    final config = getTchatFrontEndConfig().message.messageConfig;
    final mapOfBuilders = config.replyToBuilders;

    return mapOfBuilders[model.messageType]
            ?.call(context, ref, model, tchat, isMessage, fromMe) ??
        textReply(context, ref, model, tchat, isMessage, fromMe);
  }

  static Widget textReply(
      BuildContext context, WidgetRef ref, MessageModel model, TchatModel tchat,
      [bool isMessage = false, bool fromMe = false]) {
    final TchatMessageThemeData themeData = loadThemeData(
        null, "tchat_message_theme", () => kDefaultTchatMessageTheme,
      isDark: ref.watch(isDarkModeProvider).isDarkMode,       );
    final MessageBoxThemeData replyThemeData =
        loadThemeData(null, "message_box", () => kDefaultMessageBoxThemeData,
      isDark: ref.watch(isDarkModeProvider).isDarkMode,       );

    Color color = (!isMessage
                ? themeData.replyUserStyle
                : (fromMe
                    ? replyThemeData.meReplyMessageUserStyle
                    : replyThemeData.otherReplyMessageUserStyle))
            ?.color ??
        DefaultColor.darkBlue;

    if (tchat.isGroup && !fromMe) {
      final user = ref
          .read(tchatUserListProvider)
          .userList
          .firstWhereOrNull((element) => element.id == model.senderId);
      final int index = user != null
          ? ref.read(tchatUserListProvider).userList.indexOf(user)
          : 0;
      color = (replyThemeData.groupNameColors ??
          [
            Colors.red,
            Colors.green,
            Colors.blue
          ])[index % (replyThemeData.groupNameColors?.length ?? 3)];
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(width: formatWidth(4), color: color),
          Expanded(
            child: Padding(
              padding: themeData.replyToPadding ?? EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ref
                            .watch(tchatUserListProvider)
                            .userList
                            .firstWhereOrNull((p0) => p0.id == model.senderId)
                            ?.pseudo ??
                        ref
                            .watch(tchatUserListProvider)
                            .userList
                            .firstWhereOrNull((p0) => p0.id == model.senderId)
                            ?.firstname ??
                        "None",
                    style: (!isMessage
                            ? themeData.replyUserStyle
                            : (fromMe
                                ? replyThemeData.meReplyMessageUserStyle
                                : replyThemeData.otherReplyMessageUserStyle))
                        ?.copyWith(color: color),
                  ),
                  if (!isMessage) sh(3),
                  Text(
                    model.content ?? "",
                    style: !isMessage
                        ? themeData.replyContentStyle
                        : (fromMe
                            ? replyThemeData.meReplyMessageContentStyle
                            : replyThemeData.otherReplyMessageContentStyle),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget audioReply(
      BuildContext context, WidgetRef ref, MessageModel model, TchatModel tchat,
      [bool isMessage = false, bool fromMe = false]) {
    final TchatMessageThemeData themeData = loadThemeData(
        null, "tchat_message_theme", () => kDefaultTchatMessageTheme);
    final MessageBoxThemeData replyThemeData =
        loadThemeData(null, "message_box", () => kDefaultMessageBoxThemeData,
      isDark: ref.watch(isDarkModeProvider).isDarkMode,       );

    Color color = (!isMessage
                ? themeData.replyUserStyle
                : (fromMe
                    ? replyThemeData.meReplyMessageUserStyle
                    : replyThemeData.otherReplyMessageUserStyle))
            ?.color ??
        DefaultColor.darkBlue;

    if (tchat.isGroup && !fromMe) {
      final user = ref
          .read(tchatUserListProvider)
          .userList
          .firstWhereOrNull((element) => element.id == model.senderId);
      final int index = user != null
          ? ref.read(tchatUserListProvider).userList.indexOf(user)
          : 0;
      color = (replyThemeData.groupNameColors ??
          [
            Colors.red,
            Colors.green,
            Colors.blue
          ])[index % (replyThemeData.groupNameColors?.length ?? 3)];
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(width: formatWidth(4), color: color),
          Expanded(
            child: Padding(
              padding: themeData.replyToPadding ?? EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ref
                            .watch(tchatUserListProvider)
                            .userList
                            .firstWhereOrNull((p0) => p0.id == model.senderId)
                            ?.pseudo ??
                        ref
                            .watch(tchatUserListProvider)
                            .userList
                            .firstWhereOrNull((p0) => p0.id == model.senderId)
                            ?.firstname ??
                        "None",
                    style: (!isMessage
                            ? themeData.replyUserStyle
                            : (fromMe
                                ? replyThemeData.meReplyMessageUserStyle
                                : replyThemeData.otherReplyMessageUserStyle))
                        ?.copyWith(color: color),
                  ),
                  if (!isMessage) sh(3),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        "assets/svg/ic_mic.svg",
                        width: formatWidth(8),
                        color: (!isMessage
                                    ? themeData.replyContentStyle
                                    : (fromMe
                                        ? replyThemeData
                                            .meReplyMessageContentStyle
                                        : replyThemeData
                                            .otherReplyMessageContentStyle))
                                ?.color ??
                            DefaultColor.darkBlue,
                        package: "kosmos_chat",
                      ),
                      sw(5),
                      Text(
                        "package.tchat.preview.reply-audio".tr(),
                        style: !isMessage
                            ? themeData.replyContentStyle
                            : (fromMe
                                ? replyThemeData.meReplyMessageContentStyle
                                : replyThemeData.otherReplyMessageContentStyle),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget mediaReply(
      BuildContext context, WidgetRef ref, MessageModel model, TchatModel tchat,
      [bool isMessage = false, bool fromMe = false]) {
    final TchatMessageThemeData themeData = loadThemeData(
        null, "tchat_message_theme", () => kDefaultTchatMessageTheme,
      isDark: ref.watch(isDarkModeProvider).isDarkMode,       );
    final MediaModel media = model.media!.first;
    final MessageBoxThemeData replyThemeData =
        loadThemeData(null, "message_box", () => kDefaultMessageBoxThemeData,
      isDark: ref.watch(isDarkModeProvider).isDarkMode,       );

    ImageProvider? child;

    Color color = (!isMessage
                ? themeData.replyUserStyle
                : (fromMe
                    ? replyThemeData.meReplyMessageUserStyle
                    : replyThemeData.otherReplyMessageUserStyle))
            ?.color ??
        DefaultColor.darkBlue;

    if (tchat.isGroup && !fromMe) {
      final user = ref
          .read(tchatUserListProvider)
          .userList
          .firstWhereOrNull((element) => element.id == model.senderId);
      final int index = user != null
          ? ref.read(tchatUserListProvider).userList.indexOf(user)
          : 0;
      color = (replyThemeData.groupNameColors ??
          [
            Colors.red,
            Colors.green,
            Colors.blue
          ])[index % (replyThemeData.groupNameColors?.length ?? 3)];
    }

    if (media.mediaRelativePath != null && media.mediaType == AssetType.image) {
      final f = File(
          "${ref.read(messageListProvider).appPath}/${media.mediaRelativePath!}");
      if (f.existsSync()) {
        child = FileImage(f);
      }
    } else if (media.videoThumbnailRelativePath != null &&
        media.mediaType == AssetType.video) {
      final f = File(
          "${ref.read(messageListProvider).appPath}/${media.videoThumbnailRelativePath!}");
      if (f.existsSync()) {
        child = FileImage(f);
      }
    }

    return IntrinsicHeight(
      child: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(width: formatWidth(4), color: color),
          Expanded(
            child: Padding(
              padding: themeData.replyToPadding ?? EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ref
                            .watch(tchatUserListProvider)
                            .userList
                            .firstWhereOrNull((p0) => p0.id == model.senderId)
                            ?.pseudo ??
                        ref
                            .watch(tchatUserListProvider)
                            .userList
                            .firstWhereOrNull((p0) => p0.id == model.senderId)
                            ?.firstname ??
                        "None",
                    style: (!isMessage
                            ? themeData.replyUserStyle
                            : (fromMe
                                ? replyThemeData.meReplyMessageUserStyle
                                : replyThemeData.otherReplyMessageUserStyle))
                        ?.copyWith(color: color),
                  ),
                  sh(3),
                  if (model.content != null)
                    Text(
                      model.content!,
                      style: !isMessage
                          ? themeData.replyContentStyle
                          : (fromMe
                              ? replyThemeData.meReplyMessageContentStyle
                              : replyThemeData.otherReplyMessageContentStyle),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    )
                  else ...[
                    if (media.mediaType == AssetType.image &&
                        model.media!.length == 1)
                      Row(
                        children: [
                          if (!isMessage) ...[
                            Icon(Icons.photo_outlined,
                                size: 16,
                                color: themeData.replyContentStyle?.color ??
                                    DefaultColor.darkBlue),
                            sw(2)
                          ],
                          Text("package.tchat.reply-to.image".tr(),
                              style: (!isMessage
                                  ? themeData.replyContentStyle
                                  : (fromMe
                                      ? replyThemeData
                                          .meReplyMessageContentStyle
                                      : replyThemeData
                                          .otherReplyMessageContentStyle)),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1),
                        ],
                      )
                    else if (media.mediaType == AssetType.video &&
                        model.media!.length == 1)
                      Row(
                        children: [
                          if (!isMessage) ...[
                            Icon(Icons.play_arrow_rounded,
                                size: 16,
                                color: (!isMessage
                                            ? themeData.replyContentStyle
                                            : (fromMe
                                                ? replyThemeData
                                                    .meReplyMessageContentStyle
                                                : replyThemeData
                                                    .otherReplyMessageContentStyle))
                                        ?.color ??
                                    DefaultColor.darkBlue),
                            sw(2)
                          ],
                          Text("package.tchat.reply-to.video".tr(),
                              style: (!isMessage
                                  ? themeData.replyContentStyle
                                  : (fromMe
                                      ? replyThemeData
                                          .meReplyMessageContentStyle
                                      : replyThemeData
                                          .otherReplyMessageContentStyle)),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1),
                        ],
                      )
                    else
                      Row(
                        children: [
                          if (!isMessage) ...[
                            Icon(Icons.photo_outlined,
                                size: 16,
                                color: (!isMessage
                                            ? themeData.replyContentStyle
                                            : (fromMe
                                                ? replyThemeData
                                                    .meReplyMessageContentStyle
                                                : replyThemeData
                                                    .otherReplyMessageContentStyle))
                                        ?.color ??
                                    DefaultColor.darkBlue),
                            sw(2)
                          ],
                          Text(
                              "package.tchat.reply-to.media"
                                  .plural(model.media!.length),
                              style: (!isMessage
                                  ? themeData.replyContentStyle
                                  : (fromMe
                                      ? replyThemeData
                                          .meReplyMessageContentStyle
                                      : replyThemeData
                                          .otherReplyMessageContentStyle)),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1),
                        ],
                      )
                  ],
                ],
              ),
            ),
          ),
          sw(8),
          Container(
            width: isMessage ? formatWidth(40) : formatWidth(40),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                  topRight: Radius.circular(r(8)),
                  bottomRight: Radius.circular(r(8))),
              image: media.mediaUrl != null || child != null
                  ? DecorationImage(
                      fit: BoxFit.cover,
                      image: child ??
                          CachedNetworkImageProvider(
                            media.mediaType == AssetType.image
                                ? media.mediaUrl!
                                : media.videoThumbnail!,
                          ),
                    )
                  : null,
            ),
            child: media.mediaType == AssetType.video
                ? const Center(
                    child: Icon(Icons.play_arrow_rounded, color: Colors.white))
                : null,
          ),
        ],
      ),
    );
  }
}

/// {@Category Widget}
/// {@Category Tchat}
///
abstract class SubMessageBuilder {
  static Widget? buildSubMessage(BuildContext context, WidgetRef ref,
      MessageModel model, TchatModel tchat) {
    final config = getTchatFrontEndConfig().message.messageConfig;
    final mapOfBuilders = config.subMessageBuilders;

    return mapOfBuilders?[model.messageType]?.call(context, ref, model, tchat);
  }
}

/// {@Category Widget}
/// {@Category Tchat}
///
abstract class PreviewBuilder {
  static Widget previewBuilder(BuildContext context, WidgetRef ref,
      MessageModel model, TchatModel tchat) {
    final config = getTchatFrontEndConfig().message.messageConfig;
    final mapOfBuilders = config.previewInListBuilders;

    return mapOfBuilders[model.messageType]?.call(context, ref, model, tchat) ??
        textPreview(context, ref, model, tchat);
  }

  static Widget textPreview(BuildContext context, WidgetRef ref,
      MessageModel model, TchatModel tchat) {
    final TchatThemeData? themeData =
        loadThemeData(null, "tchat_theme", () => kDefaultTchatTheme,
      isDark: ref.watch(isDarkModeProvider).isDarkMode,       );

    return Text(
      model.content ?? "",
      style: themeData?.tchatRowLastMessageStyle,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  static Widget deletedMessageBuilder(BuildContext context, WidgetRef ref,
      MessageModel model, TchatModel tchat) {
    final TchatThemeData? themeData =
        loadThemeData(null, "tchat_theme", () => kDefaultTchatTheme,
      isDark: ref.watch(isDarkModeProvider).isDarkMode,       );

    return Text(
      "package.tchat.deleted-message-row-info".tr(),
      style: themeData?.tchatRowLastMessageStyle,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  static Widget mediaPreview(BuildContext context, WidgetRef ref,
      MessageModel model, TchatModel tchat) {
    final TchatThemeData? themeData =
        loadThemeData(null, "tchat_theme", () => kDefaultTchatTheme,
      isDark: ref.watch(isDarkModeProvider).isDarkMode,       );

    final bool mediahaveContent = model.content != null;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          model.media?.first.mediaType == AssetType.image
              ? Iconsax.gallery
              : Iconsax.video_square,
          color: themeData?.tchatRowLastMessageStyle?.color ??
              DefaultColor.darkBlue,
          size: formatWidth(12),
        ),
        sw(2),
        Expanded(
          child: Text(
            mediahaveContent
                ? (model.content ?? "")
                : "package.tchat.preview.media".plural(model.media!.length),
            style: themeData?.tchatRowLastMessageStyle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  static Widget audioPreview(BuildContext context, WidgetRef ref,
      MessageModel model, TchatModel tchat) {
    final TchatThemeData? themeData =
        loadThemeData(null, "tchat_theme", () => kDefaultTchatTheme,
      isDark: ref.watch(isDarkModeProvider).isDarkMode,       );

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SvgPicture.asset(
          "assets/svg/ic_mic.svg",
          width: formatWidth(12),
          color: themeData?.tchatRowLastMessageStyle?.color ??
              DefaultColor.darkBlue,
          package: "kosmos_chat",
        ),
        sw(4),
        Expanded(
          child: Text(
            "package.tchat.preview.audio".tr(),
            style: themeData?.tchatRowLastMessageStyle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
