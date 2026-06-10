import 'package:cached_network_image/cached_network_image.dart';
import 'package:core_kosmos/core_kosmos.dart';
import 'package:flutter/material.dart';
import 'package:kosmos_chat/backend/kosmos_chat_backend.dart';
import 'package:kosmos_chat/backend/provider/tchat_user_data.dart';
import 'package:kosmos_chat/frontend/theme/message_box.dart';
import 'package:kosmos_chat/frontend/utils/utils.dart';
import 'package:kosmos_chat/frontend/widget/components/message_builder.dart';

class MessageBox extends StatefulHookConsumerWidget {
  final TchatModel tchat;
  final MessageModel message;
  final MessageModel? previousMessage;
  final MessageModel? nextMessage;

  final void Function(MessageModel)? onTapReplyTo;

  /// Theme
  final MessageBoxThemeData? theme;
  final String? themeName;

  const MessageBox({
    super.key,
    required this.tchat,
    required this.message,
    this.previousMessage,
    this.nextMessage,
    this.onTapReplyTo,

    /// Theme
    this.theme,
    this.themeName,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MessageBoxState();
}

class _MessageBoxState extends ConsumerState<MessageBox> {
   

  late final bool fromMe =
      widget.message.senderId == ref.read(userProvider).user?.id;
  late final bool isFirstMessage = widget.previousMessage == null ||
      widget.previousMessage?.senderId != widget.message.senderId;
  late final bool isLastMessage = widget.nextMessage == null ||
      widget.nextMessage?.senderId != widget.message.senderId;

  late final config = getTchatFrontEndConfig().message.messageConfig;

  @override
  Widget build(BuildContext context) {
    final MessageBoxThemeData themeData = loadThemeData(widget.theme,
      widget.themeName ?? "message_box", () => kDefaultMessageBoxThemeData,
      isDark: ref.watch(isDarkModeProvider).isDarkMode,       );
    BoxDecoration? decoration = fromMe
        ? themeData.meContainerDecoration
        : themeData.otherContainerDecoration;

    if (fromMe && !isLastMessage) {
      decoration = decoration?.copyWith(
          borderRadius: themeData.mePreviousMessageBorderRadius);
    } else if (!fromMe && !isLastMessage) {
      decoration = decoration?.copyWith(
          borderRadius: themeData.otherPreviousMessageBorderRadius);
    }

    EdgeInsets? padding =
        fromMe ? themeData.meMessagePadding : themeData.otherMessagePadding;
    if (widget.message.messageType == "media") {
      padding = fromMe
          ? themeData.meMediaMessagePadding
          : themeData.otherMediaMessagePadding;
    }

    final sender = ref
        .read(tchatUserListProvider)
        .userList
        .firstWhereOrNull((element) => element.id == widget.message.senderId);

    return Column(
      crossAxisAlignment:
          fromMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (widget.tchat.isGroup &&
                !fromMe &&
                widget.nextMessage?.senderId != widget.message.senderId &&
                (sender?.profileImage != null ||
                    sender?.userProfileImage != null)) ...[
              InkWell(
                onTap: sender?.id != null && config.onMessageImageClick != null
                    ? () {
                        config.onMessageImageClick
                            ?.call(context, ref, sender!.id);
                      }
                    : null,
                child: Container(
                  width: themeData.messageSenderPPSize ?? formatWidth(24),
                  height: themeData.messageSenderPPSize ?? formatWidth(24),
                  decoration: const BoxDecoration(shape: BoxShape.circle),
                  clipBehavior: Clip.antiAlias,
                  child: CachedNetworkImage(
                      imageUrl: sender!.profileImage ??
                          sender.userProfileImage?.compressedUrl ??
                          sender.userProfileImage?.url ??
                          "",
                      fit: BoxFit.cover),
                ),
              ),
              sw(4),
            ] else if (widget.tchat.isGroup &&
                !fromMe &&
                widget.nextMessage?.senderId == widget.message.senderId &&
                (sender?.profileImage != null ||
                    sender?.userProfileImage != null)) ...[
              SizedBox(
                  width: themeData.messageSenderPPSize ?? formatWidth(28)),
            ],
            Container(
              constraints: BoxConstraints(
                  maxWidth: (MediaQuery.of(context).size.width * 0.8 -
                      (widget.tchat.isGroup ? formatWidth(28) : 0)),
                  minWidth: MediaQuery.of(context).size.width * 0.2),
              decoration: decoration,
              child: IntrinsicWidth(
                child: Column(
                  crossAxisAlignment: fromMe
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    if (widget.tchat.isGroup &&
                        !fromMe &&
                        widget.previousMessage?.senderId !=
                            widget.message.senderId) ...[
                      _buildSenderUi(context, themeData, padding ?? EdgeInsets.zero),
                    ],
                    if (widget.message.replyTo != null &&
                        getTchatFrontEndConfig()
                            .message
                            .messageConfig
                            .authorizedReplyToUI
                            .contains(widget.message.messageType)) ...[
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () =>
                                  widget.onTapReplyTo?.call(widget.message),
                              child: Padding(
                                padding: (themeData.replyPadding ??
                                    EdgeInsets.zero),
                                child: Container(
                                  constraints: BoxConstraints(
                                      maxWidth:
                                          (MediaQuery.of(context).size.width *
                                                  0.8 -
                                              (widget.tchat.isGroup
                                                  ? formatWidth(28)
                                                  : 0)),
                                      minWidth:
                                          MediaQuery.of(context).size.width *
                                              0.4),
                                  // padding: themeData.replyToPadding,
                                  clipBehavior: Clip.antiAlias,
                                  decoration: fromMe
                                      ? themeData.meReplyToDecoration
                                      : themeData.otherReplyToDecoration,
                                  child: ReplyToBuilder.replyPreviewBuilder(
                                      context,
                                      ref,
                                      widget.message.replyTo!,
                                      widget.tchat,
                                      true,
                                      fromMe),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    Padding(
                      padding: padding ?? EdgeInsets.zero,
                      child: Row(
                        children: [
                          Expanded(
                              child: MessageBuilder.messageBuilder(
                                  widget.message.messageType,
                                  context,
                                  ref,
                                  widget.message,
                                  widget.tchat)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        _buildSuffix(context),
      ],
    );
  }

  Widget _buildSuffix(BuildContext context) {
    final Widget? second = SubMessageBuilder.buildSubMessage(
        context, ref, widget.message, widget.tchat);

    return second ?? const SizedBox.shrink();
  }

  Widget _buildSenderUi(BuildContext context,
      MessageBoxThemeData themeData,
      [EdgeInsets padding = EdgeInsets.zero]) {
    final user = ref
        .read(tchatUserListProvider)
        .userList
        .firstWhereOrNull((element) => element.id == widget.message.senderId);
    final int index = user != null
        ? ref.read(tchatUserListProvider).userList.indexOf(user)
        : 0;
    final Color color = (themeData.groupNameColors ??
        [
          Colors.red,
          Colors.green,
          Colors.blue
        ])[index % (themeData.groupNameColors?.length ?? 3)];

    if (user == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.only(
          left: themeData.otherMessagePadding?.left ?? formatHeight(10),
          right: padding.right,
          bottom: formatHeight(7),
          top: formatHeight(10)),
      child: Text(
        user.pseudo ?? user.firstname,
        style: (widget.theme?.groupSenderTextStyle ??
                DefaultAppStyle.darkBlue(16, FontWeight.w500))
            .copyWith(color: color),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
