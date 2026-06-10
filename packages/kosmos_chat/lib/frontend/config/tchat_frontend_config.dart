import 'package:core_kosmos/core_kosmos.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:kosmos_chat/backend/kosmos_chat_backend.dart';
import 'package:kosmos_chat/frontend/theme/tchat_theme.dart';
import 'package:kosmos_chat/frontend/widget/components/message_builder.dart';

typedef MessageBuilderCallback = Widget Function(
    BuildContext, WidgetRef, MessageModel, TchatModel);
typedef ReplyBuilderCallback = Widget
    Function(BuildContext, WidgetRef, MessageModel, TchatModel, [bool, bool]);

class TchatFrontEndConfig extends PackageConfig {
  final TchatListingConfig listing;
  final TchatMessageViewConfig message;
  final bool useDateFormatWithLocal;

  TchatFrontEndConfig({
    this.listing = const TchatListingConfig(),
    this.message = const TchatMessageViewConfig(),
    this.useDateFormatWithLocal = false,
  }) : super("tchat_frontend");
}

class TchatMessageViewConfig {
  final TchatMessageConfig messageConfig;

  /// Header (par défaut, affiche le nom du tchat ainsi
  /// que les actions de suppression, appel audio et vidéo
  /// sous réserve de configuration).
  /// Uniquement si [showHeader] est à true.
  final Widget Function(BuildContext, WidgetRef, TchatModel)? headerBuilder;

  /// This configuration will be used on above of the message bar and reply bar.
  final Widget Function(BuildContext, WidgetRef, TchatModel)? bottomBuilder;
  final Widget Function(BuildContext, WidgetRef, TchatModel)? micBuilder;
  final bool showHeader;
  final bool showCallButton;

  final bool showVideoCallButton;
  final bool showTchatAction;
  final bool showTchatPicture;
  final bool canSendMedia;
  final bool Function(TchatModel)? tchatCanSendAudio;
  final bool Function(TchatModel)? tchatCanSendMedia;

  final bool canSendAudio;
  final String? sendMessageIconPath;
  final FutureVoidCallbackWithContext? onActionPressedEvent;

  const TchatMessageViewConfig({
    this.messageConfig = const TchatMessageConfig(),
    this.headerBuilder,
    this.showHeader = true,
    this.showCallButton = false,
    this.showVideoCallButton = false,
    this.micBuilder,
    this.bottomBuilder,
    this.showTchatAction = true,
    this.showTchatPicture = true,
    this.onActionPressedEvent,
    this.canSendAudio = true,
    this.canSendMedia = true,
    this.sendMessageIconPath,
    this.tchatCanSendAudio,
    this.tchatCanSendMedia,
  });
}

class TchatMessageConfig {
  final Map<String, MessageBuilderCallback> messageContentBuilders;
  final Map<String, MessageBuilderCallback>? subMessageBuilders;
  final Map<String, MessageBuilderCallback> previewInListBuilders;
  final Map<String, ReplyBuilderCallback> replyToBuilders;
  final List<String> authorizedReplyToUI;
  final List<String>? messageCantBeDeleted;
  final Widget Function(BuildContext, WidgetRef, TchatModel, MessageModel)?
      messageBuilder;
  final void Function(BuildContext, WidgetRef, String? userId)?
      onMessageImageClick;

  const TchatMessageConfig({
    this.subMessageBuilders,
    this.messageCantBeDeleted,
    this.onMessageImageClick,
    this.messageContentBuilders = const {
      "text": MessageBuilder.textBuilder,
      "audio": MessageBuilder.audioBuilder,
      "media": MessageBuilder.mediaBuilder,
      "event": MessageBuilder.eventBuilder,
    },
    this.previewInListBuilders = const {
      "text": PreviewBuilder.textPreview,
      "media": PreviewBuilder.mediaPreview,
      "audio": PreviewBuilder.audioPreview,
      "deleted-message": PreviewBuilder.deletedMessageBuilder,
    },
    this.replyToBuilders = const {
      "text": ReplyToBuilder.textReply,
      "media": ReplyToBuilder.mediaReply,
      "audio": ReplyToBuilder.audioReply,
    },
    this.authorizedReplyToUI = const ["text"],
    this.messageBuilder,
  });
}

class TchatListingConfig {
  /// Top action (by default, used to create a new tchat)
  final bool showTopAction;

  final String? topActionSvgAsset;
  final bool showBackButton;
  final bool hideHeaderChatList;
  // add top padding to  chat list Page
  final bool addTopPadding;

  /// Tchat Row (by default, used to display a tchat)
  final Widget Function(BuildContext, TchatModel, TchatThemeData?)?
      tchatRowBuilder;

  final Widget Function(BuildContext,WidgetRef, TchatModel, TchatThemeData?)?
      tchatNameBuilder;
  final Widget Function(BuildContext)? noTchatRowBuilder;
  final ActionPane Function(BuildContext context, TchatModel tchat)?
      buildTchatRowAction;

  final void Function(BuildContext, WidgetRef, TchatModel)?
      onTchatRowListImageClick;

  /// Tchat Action Pane
  final void Function(BuildContext, WidgetRef, TchatModel)? actionMoreEvent;
  final void Function(BuildContext, TchatModel)? actionDeleteEvent;
  final DateTimeAgoIndicatorStyle dateTimeAgoIndicatorStyle;

  const TchatListingConfig({
    this.showTopAction = true,
    this.showBackButton = false,
    this.hideHeaderChatList = false,
    this.addTopPadding = true,
    this.dateTimeAgoIndicatorStyle = DateTimeAgoIndicatorStyle.fixedDate,
    this.topActionSvgAsset,
    this.tchatRowBuilder,
    this.tchatNameBuilder,
    this.noTchatRowBuilder,
    this.buildTchatRowAction,
    this.actionDeleteEvent,
    this.actionMoreEvent,
    this.onTchatRowListImageClick,
  });
}

enum DateTimeAgoIndicatorStyle {
  fixedDate,
  timeSinceLastMessage,
}
