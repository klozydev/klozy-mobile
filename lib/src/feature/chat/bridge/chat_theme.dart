import 'package:core_kosmos/core_kosmos.dart';
import 'package:flutter/material.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';
import 'package:kosmos_chat/kosmos_chat.dart';
import 'package:ui_kosmos_v4/field/theme/form_field_theme.dart';

/// Registers the chat island's themes (core_kosmos [AppTheme]) with values
/// matching Klozy's dark design system. Without this the island falls back to
/// its hardcoded light/dark-blue defaults, which are unreadable on Klozy's
/// black surface.
///
/// Registration is deferred to after the first frame: the default theme
/// constants (`kDefaultTchatTheme`, …) call ScreenUtil-backed helpers
/// (`formatWidth`/`r`) which throw until `ScreenUtilInit` (root of the app
/// widget) has built. No chat surface can render before the first frame, so
/// the deferral is safe.
void registerChatTheme() {
  // The chat island reads this static synchronously (isDarkModeProvider);
  // safe to set before the first frame.
  AppTheme.darkMode = true;

  if (GetIt.instance.isRegistered<AppTheme>()) return;
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (GetIt.instance.isRegistered<AppTheme>()) return;
    final appTheme = AppTheme();
    final tchatTheme = _tchatTheme();
    final messageTheme = _messageTheme();
    final messageBoxTheme = _messageBoxTheme();
    appTheme.addTheme<TchatThemeData>(
      'tchat_theme',
      tchatTheme,
      darkTheme: tchatTheme,
    );
    appTheme.addTheme<TchatMessageThemeData>(
      'tchat_message_theme',
      messageTheme,
      darkTheme: messageTheme,
    );
    appTheme.addTheme<MessageBoxThemeData>(
      'message_box',
      messageBoxTheme,
      darkTheme: messageBoxTheme,
    );
    GetIt.instance.registerSingleton<AppTheme>(appTheme);
  });
}

/// Conversation list.
TchatThemeData _tchatTheme() {
  return kDefaultTchatTheme.copyWith(
    tchatListShimmerBaseColor: DSColor.onSurface08,
    tchatListShimmerHighlightColor: DSColor.onSurface15,
    tchatListBackgroundColor: DSColor.surface,
    tchatListTitleStyle: const TextStyle(
      fontFamily: dsFontFamily,
      fontSize: 16,
      color: DSColor.onSurface,
    ),
    tchatListIconColor: DSColor.onSurface,
    tchatListNoTchatStyle: const TextStyle(
      fontFamily: dsFontFamily,
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: DSColor.onSurface,
    ),
    tchatListNoTchatContentStyle: const TextStyle(
      fontFamily: dsFontFamily,
      fontSize: 14,
      color: DSColor.onSurface60,
    ),
    tchatRowActionIconColor: DSColor.onSurface60,
    tchatRowNotifColor: DSColor.primary,
    tchatRowTimeAgoStyle: const TextStyle(
      fontFamily: dsFontFamily,
      fontSize: 14,
      color: DSColor.onSurface45,
    ),
    tchatRowTitleStyle: const TextStyle(
      fontFamily: dsFontFamily,
      fontSize: 17,
      fontWeight: FontWeight.w500,
      color: DSColor.onSurface,
    ),
    tchatRowLastMessageStyle: const TextStyle(
      fontFamily: dsFontFamily,
      fontSize: 15,
      color: DSColor.onSurface60,
    ),
    tchatRowEventMessageStyle: const TextStyle(
      fontFamily: dsFontFamily,
      fontSize: 15,
      fontStyle: FontStyle.italic,
      color: DSColor.onSurface60,
    ),
  );
}

/// Thread view (header, events, bottom input bar, reply bar).
TchatMessageThemeData _messageTheme() {
  const inputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(25)),
    borderSide: BorderSide(width: .5, color: DSColor.onSurface12),
  );
  return kDefaultTchatMessageTheme.copyWith(
    eventTextStyle: const TextStyle(
      fontFamily: dsFontFamily,
      fontSize: 15,
      fontWeight: FontWeight.w500,
      color: DSColor.onSurface60,
    ),
    dateDecoration: BoxDecoration(
      color: DSColor.onSurface10,
      borderRadius: BorderRadius.circular(r(7)),
    ),
    selectedMessageOverlayColor: DSColor.brandGlow,
    deleteMessageIconColor: DSColor.danger,
    actionButtonColor: DSColor.onSurface,
    actionButtonMoreColor: DSColor.onSurface,
    actionCallColor: DSColor.onSurface,
    nameTextStyle: const TextStyle(
      fontFamily: dsFontFamily,
      fontSize: 20.5,
      color: DSColor.onSurface,
    ),
    statusTextStyle: const TextStyle(
      fontFamily: dsFontFamily,
      fontSize: 14,
      color: DSColor.onSurface60,
    ),
    backgroundColor: DSColor.surface,
    inputTextStyle: const TextStyle(
      fontFamily: dsFontFamily,
      fontSize: 17,
      fontWeight: FontWeight.w500,
      color: DSColor.onSurface,
    ),
    inputDecoration: kDefaultInputDecoration.copyWith(
      hintStyle: const TextStyle(
        fontFamily: dsFontFamily,
        fontSize: 17,
        color: DSColor.onSurface45,
      ),
      fillColor: DSColor.onSurface08,
      border: inputBorder,
      enabledBorder: inputBorder,
      focusedBorder: inputBorder,
      disabledBorder: inputBorder,
    ),
    emojiIconColor: DSColor.onSurface45,
    inputActionColor: DSColor.primary,
    replyToBackgroundDecoration: BoxDecoration(
      color: DSColor.card,
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(r(35)),
        topRight: Radius.circular(r(35)),
      ),
    ),
    replyToIconColor: DSColor.onSurface60,
    replyToDecoration: BoxDecoration(
      color: DSColor.onSurface10,
      borderRadius: BorderRadius.circular(r(7)),
    ),
    replyUserStyle: const TextStyle(
      fontFamily: dsFontFamily,
      fontSize: 15,
      fontWeight: FontWeight.w500,
      letterSpacing: -.3,
      color: DSColor.primary,
    ),
    replyContentStyle: const TextStyle(
      fontFamily: dsFontFamily,
      fontSize: 13.5,
      letterSpacing: -.3,
      color: DSColor.onSurface60,
    ),
    scrollDownButtonDecoration: BoxDecoration(
      color: DSColor.card,
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(r(35)),
        bottomLeft: Radius.circular(r(35)),
      ),
    ),
    scrollDownButtonColor: DSColor.primary,
  );
}

/// Message bubbles. Own messages: gold bubble with dark content; other user:
/// dark card bubble with light content.
MessageBoxThemeData _messageBoxTheme() {
  return kDefaultMessageBoxThemeData.copyWith(
    replyToIconColor: DSColor.onSurface60,
    messageErrorColor: DSColor.danger,

    /// Me
    meContainerDecoration: BoxDecoration(
      color: DSColor.primary,
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(r(11)),
        topRight: Radius.circular(r(11)),
        bottomLeft: Radius.circular(r(11)),
      ),
    ),
    meMessageTextStyle: const TextStyle(
      fontFamily: dsFontFamily,
      fontSize: 16,
      color: DSColor.surface,
    ),
    meSendAtTextStyle: TextStyle(
      fontFamily: dsFontFamily,
      fontSize: 13,
      color: DSColor.surface.withValues(alpha: .6),
    ),
    meMessageSendingColor: DSColor.surface.withValues(alpha: .5),
    meMessageSendColor: DSColor.surface.withValues(alpha: .5),
    meMessageReadColor: DSColor.surface,
    meReplyToDecoration: BoxDecoration(
      color: DSColor.surface.withValues(alpha: .12),
      borderRadius: BorderRadius.circular(r(7)),
    ),
    meReplyMessageUserStyle: const TextStyle(
      fontFamily: dsFontFamily,
      fontSize: 15.5,
      fontWeight: FontWeight.w500,
      color: DSColor.surface,
    ),
    meReplyMessageContentStyle: TextStyle(
      fontFamily: dsFontFamily,
      fontSize: 15,
      color: DSColor.surface.withValues(alpha: .6),
    ),
    meReplyMessageToIconColor: DSColor.surface.withValues(alpha: .6),
    meAudioColor: DSColor.surface,
    meAudioTrackColor: DSColor.surface,
    meAudioBackTrackColor: DSColor.surface.withValues(alpha: .3),
    meAudioTrackTextStyle: TextStyle(
      fontFamily: dsFontFamily,
      fontSize: formatHeight(12),
      color: DSColor.surface.withValues(alpha: .6),
    ),

    /// Other user
    otherContainerDecoration: BoxDecoration(
      color: DSColor.card,
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(r(11)),
        topRight: Radius.circular(r(11)),
        bottomRight: Radius.circular(r(11)),
      ),
    ),
    otherMessageTextStyle: const TextStyle(
      fontFamily: dsFontFamily,
      fontSize: 16,
      color: DSColor.onSurface,
    ),
    otherSendAtTextStyle: const TextStyle(
      fontFamily: dsFontFamily,
      fontSize: 13,
      color: DSColor.onSurface60,
    ),
    otherReplyToDecoration: BoxDecoration(
      color: DSColor.onSurface06,
      borderRadius: BorderRadius.circular(r(7)),
    ),
    otherReplyMessageUserStyle: const TextStyle(
      fontFamily: dsFontFamily,
      fontSize: 15.5,
      color: DSColor.primary,
    ),
    otherReplyMessageContentStyle: const TextStyle(
      fontFamily: dsFontFamily,
      fontSize: 15,
      color: DSColor.onSurface60,
    ),
    otherReplyMessageToIconColor: DSColor.onSurface60,
    otherAudioColor: DSColor.primary,
    otherAudioReadColor: DSColor.primary,
    otherAudioTrackColor: DSColor.primary,
    otherAudioBackTrackColor: DSColor.onSurface15,
    otherAudioTrackTextStyle: const TextStyle(
      fontFamily: dsFontFamily,
      fontSize: 12,
      color: DSColor.onSurface60,
    ),
    groupSenderTextStyle: const TextStyle(
      fontFamily: dsFontFamily,
      fontSize: 13,
      fontWeight: FontWeight.w500,
      color: DSColor.onSurface60,
    ),
  );
}
