import 'package:flutter/material.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';
import 'package:kosmos_chat/frontend/theme/message_box.dart';
import 'package:kosmos_chat/frontend/theme/message_theme.dart';
import 'package:kosmos_chat/frontend/theme/tchat_theme.dart';

/// Klozy dark theming for the kosmos chat island. The package defaults to a
/// dark-blue-on-light palette which is unreadable on Klozy's black surface.
///
/// IMPORTANT: these builders construct the *ThemeData directly and must NOT
/// reference the package `kDefault*` constants. Those constants call ScreenUtil
/// `sp()` at first access, but the themes are registered in `main()` (see
/// registerChatConfig) before ScreenUtil is initialized — touching a kDefault
/// there throws `LateInitializationError: _minTextAdapt`. Every field below is
/// supplied explicitly so nothing the chat widgets force-cast (e.g. the input
/// bar's non-null `inputDecoration.enabledBorder`) is left null.

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
  return BoxDecoration(color: color, borderRadius: BorderRadius.circular(16));
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
  const EdgeInsets bubblePadding = EdgeInsets.symmetric(
    horizontal: 14,
    vertical: 10,
  );
  return MessageBoxThemeData(
    // Inner padding so text isn't flush to (and clipped by) the bubble edges.
    meMessagePadding: bubblePadding,
    otherMessagePadding: bubblePadding,
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
  final OutlineInputBorder border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(16),
    borderSide: const BorderSide(color: DSColor.onSurface15, width: 0.5),
  );
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
    // The input bar force-casts enabledBorder to InputBorder — every border
    // slot must be non-null.
    inputDecoration: InputDecoration(
      filled: true,
      fillColor: DSColor.card,
      hintStyle: _style(14, DSColor.onSurface45),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: border,
      enabledBorder: border,
      disabledBorder: border,
      focusedBorder: border.copyWith(
        borderSide: const BorderSide(color: DSColor.primary, width: 0.5),
      ),
    ),
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
