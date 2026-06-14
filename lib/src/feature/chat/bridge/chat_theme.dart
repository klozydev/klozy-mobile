import 'package:flutter/material.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';
import 'package:kosmos_chat/kosmos_chat.dart';

/// Klozy dark theming for the kosmos chat island. The package defaults to a
/// dark-blue-on-light palette which is unreadable on Klozy's black surface;
/// these override the list, message bubbles and message-screen colours.

TextStyle _style(
  double size,
  Color color, [
  FontWeight weight = FontWeight.w400,
]) {
  return TextStyle(
    fontFamily: dsFontFamily,
    fontSize: size,
    fontWeight: weight,
    color: color,
  );
}

BoxDecoration _bubble(Color color) {
  return BoxDecoration(
    color: color,
    borderRadius: BorderRadius.circular(16),
  );
}

/// Conversation list (`tchat_theme`).
TchatThemeData klozyTchatTheme() {
  return TchatThemeData(
    tchatListBackgroundColor: DSColor.surface,
    tchatListShimmerBaseColor: DSColor.card,
    tchatListShimmerHighlightColor: DSColor.lowBlack,
    tchatListTitleStyle: _style(18, DSColor.onSurface, FontWeight.w600),
    tchatListIconColor: DSColor.primary,
    tchatListNoTchatStyle: _style(16, DSColor.onSurface, FontWeight.w600),
    tchatListNoTchatContentStyle: _style(14, DSColor.onSurface60),
    tchatRowTitleStyle: _style(15, DSColor.onSurface, FontWeight.w600),
    tchatRowLastMessageStyle: _style(13.5, DSColor.onSurface60),
    tchatRowEventMessageStyle: _style(
      13.5,
      DSColor.onSurface45,
    ).copyWith(fontStyle: FontStyle.italic),
    tchatRowTimeAgoStyle: _style(12, DSColor.onSurface45),
    tchatRowActionIconColor: DSColor.onSurface60,
    tchatRowNotifColor: DSColor.primary,
  );
}

/// Message bubbles (`message_box`).
MessageBoxThemeData klozyMessageBoxTheme() {
  return MessageBoxThemeData(
    // My messages: gold bubble, black text.
    meContainerDecoration: _bubble(DSColor.primary),
    meMessageTextStyle: _style(14, DSColor.surface),
    meSendAtTextStyle: _style(10, DSColor.surface.withValues(alpha: 0.6)),
    meMessageSendingColor: DSColor.surface.withValues(alpha: 0.4),
    meMessageSendColor: DSColor.surface.withValues(alpha: 0.65),
    meMessageReadColor: DSColor.surface,
    // Their messages: dark grey bubble, white text.
    otherContainerDecoration: _bubble(DSColor.popupBackground),
    otherMessageTextStyle: _style(14, DSColor.onSurface),
    otherSendAtTextStyle: _style(10, DSColor.onSurface45),
    messageErrorColor: DSColor.danger,
    groupSenderTextStyle: _style(12, DSColor.primary, FontWeight.w600),
    meReplyMessageUserStyle: _style(12, DSColor.surface, FontWeight.w600),
    meReplyMessageContentStyle: _style(
      12,
      DSColor.surface.withValues(alpha: 0.7),
    ),
    otherReplyMessageUserStyle: _style(12, DSColor.primary, FontWeight.w600),
    otherReplyMessageContentStyle: _style(12, DSColor.onSurface60),
  );
}

/// Message screen — header, input bar, events (`tchat_message_theme`).
TchatMessageThemeData klozyMessageTheme() {
  return TchatMessageThemeData(
    nameTextStyle: _style(16, DSColor.onSurface, FontWeight.w600),
    statusTextStyle: _style(12, DSColor.onSurface45),
    actionButtonColor: DSColor.onSurface,
    actionButtonMoreColor: DSColor.onSurface,
    actionCallColor: DSColor.primary,
    eventTextStyle: _style(12.5, DSColor.onSurface45),
    selectedMessageOverlayColor: DSColor.onSurface10,
    deleteMessageIconColor: DSColor.danger,
    backgroundColor: DSColor.card,
    inputContainerDecoration: _bubble(DSColor.card),
    inputTextStyle: _style(14, DSColor.onSurface),
    inputHintStyle: _style(14, DSColor.onSurface45),
    inputActionColor: DSColor.primary,
    emojiIconColor: DSColor.onSurface45,
    replyToIconColor: DSColor.primary,
    replyUserStyle: _style(12, DSColor.primary, FontWeight.w600),
    replyContentStyle: _style(12, DSColor.onSurface60),
    scrollDownButtonColor: DSColor.primary,
  );
}
