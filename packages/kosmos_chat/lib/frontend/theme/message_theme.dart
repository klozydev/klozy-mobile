import 'package:core_kosmos/core_kosmos.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/material.dart';
import 'package:ui_kosmos_v4/field/theme/form_field_theme.dart';

part 'message_theme.freezed.dart';

/// key = "tchat_message_theme"
@freezed
class TchatMessageThemeData with _$TchatMessageThemeData {
  const factory TchatMessageThemeData({
    final EdgeInsetsGeometry? messageListPadding,
    // tchat background
    final Widget? background,
    final BoxDecoration? tchatHeaderDecoration,
    final EdgeInsetsGeometry? tchatHeaderPadding,

    /// Header
    final Color? actionButtonColor,
    final Color? actionButtonMoreColor,
    final Color? actionCallColor,
    final Size? profilImageSize,
    final double? spacingBetweenPictureAndName,
    final double? spacingBetweenBackButtonAndPicture,
    final TextStyle? nameTextStyle,
    final TextStyle? statusTextStyle,

    /// Event
    final BoxDecoration? eventDecoration,
    final BoxDecoration? dateDecoration,
    final EdgeInsetsGeometry? eventPadding,
    final TextStyle? eventTextStyle,
    final BoxConstraints? eventConstraints,
    final Color? selectedMessageOverlayColor,
    final Color? deleteMessageIconColor,

    /// BottomBar
    ///
    final BorderRadiusGeometry? borderRadius,
    final Color? backgroundColor,
    final List<BoxShadow>? shadows,
    final EdgeInsetsGeometry? contentPadding,
    final InputDecoration? inputDecoration,
    final TextStyle? inputTextStyle,
    final double? inputTextHeight,
    final TextStyle? inputHintStyle,
    final Color? inputActionColor,
    final Widget? emojiIcon,
    final Color? emojiIconColor,

    /// ReplyTo Bar
    final EdgeInsetsGeometry? replyToBackgroundPadding,
    final BoxDecoration? replyToBackgroundDecoration,
    final BoxDecoration? inputContainerDecoration,
    final BoxDecoration? otherReplyToBackgroundDecoration,
    final EdgeInsetsGeometry? replyToPadding,
    final Color? replyToIconColor,
    final BoxDecoration? replyToDecoration,
    final TextStyle? replyUserStyle,
    final TextStyle? replyContentStyle,

    /// ScrollDown Button
    final BoxDecoration? scrollDownButtonDecoration,
    final Color? scrollDownButtonColor,
    final EdgeInsetsGeometry? scrollDownButtonPadding,
  }) = _TchatMessageThemeData;
}

final TchatMessageThemeData kDefaultTchatMessageTheme = TchatMessageThemeData(
  messageListPadding: EdgeInsets.symmetric(horizontal: formatWidth(12.5)),

  /// Event
  eventTextStyle: DefaultAppStyle.darkGrey(15, FontWeight.w500)
      .copyWith(fontFamily: "Helvetica"),
  eventPadding: pwh(8, 15),
  dateDecoration: BoxDecoration(
      color: DefaultColor.lowGrey, borderRadius: BorderRadius.circular(r(7))),
  deleteMessageIconColor: DefaultColor.error,
  selectedMessageOverlayColor: DefaultColor.info.withOpacity(.15),

  /// Header
  actionButtonColor: DefaultColor.darkBlue,
  actionButtonMoreColor: DefaultColor.darkBlue,
  actionCallColor: DefaultColor.darkBlue,
  profilImageSize: Size(formatWidth(45), formatWidth(45)),
  spacingBetweenPictureAndName: formatWidth(9),
  nameTextStyle:
      DefaultAppStyle.darkBlue(20.5).copyWith(fontFamily: "Helvetica"),
  statusTextStyle: DefaultAppStyle.darkSteel(14, FontWeight.w400)
      .copyWith(fontFamily: "Helvetica"),

  /// BottomBar
  borderRadius: BorderRadius.zero,
  // backgroundColor: DefaultColor.lowGrey,
  shadows: [],
  contentPadding: EdgeInsets.fromLTRB(
      formatWidth(9), formatHeight(0), formatWidth(7.5), formatHeight(4)),
  inputTextStyle: DefaultAppStyle.darkBlue(19, FontWeight.w500)
      .copyWith(fontFamily: "Helvetica"),
  inputDecoration: kDefaultInputDecoration.copyWith(
    hintStyle: DefaultAppStyle.grey(20.5, FontWeight.w400)
        .copyWith(fontFamily: "Helvetica"),
    fillColor: Colors.white,
    border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25),
        borderSide:
            BorderSide(width: .5, color: Colors.black.withOpacity(.11))),
    enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25),
        borderSide:
            BorderSide(width: .5, color: Colors.black.withOpacity(.11))),
    focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25),
        borderSide:
            BorderSide(width: .5, color: Colors.black.withOpacity(.11))),
    disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25),
        borderSide:
            BorderSide(width: .5, color: Colors.black.withOpacity(.11))),
  ),
  emojiIconColor: const Color(0xFFC5C8CD),
  inputActionColor: DefaultColor.darkBlue,

  /// ReplyTo
  replyToBackgroundDecoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.only(
        topLeft: Radius.circular(r(35)), topRight: Radius.circular(r(35))),
    boxShadow: [
      BoxShadow(
          color: Colors.black.withOpacity(0.03),
          blurRadius: 30,
          offset: const Offset(0, -10))
    ],
  ),

  replyToIconColor: DefaultColor.darkGrey,
  replyToBackgroundPadding: EdgeInsets.fromLTRB(
      formatWidth(48.5), formatHeight(14), formatWidth(35.5), formatHeight(10)),
  replyToPadding: EdgeInsets.symmetric(
          horizontal: formatWidth(8), vertical: formatHeight(6))
      .copyWith(right: formatWidth(5.5)),
  replyToDecoration: BoxDecoration(
      color: DefaultColor.lowGrey, borderRadius: BorderRadius.circular(r(7))),
  replyUserStyle: DefaultAppStyle.darkBlue(15, FontWeight.w500)
      .copyWith(letterSpacing: -.3, color: const Color(0xFF00b6ff))
      .copyWith(fontFamily: "Helvetica"),
  replyContentStyle: DefaultAppStyle.darkGrey(13.5, FontWeight.w400)
      .copyWith(letterSpacing: -.3)
      .copyWith(fontFamily: "Helvetica"),

  /// ScrollDown Button
  scrollDownButtonDecoration: BoxDecoration(
    color: DefaultColor.lightGrey,
    borderRadius: BorderRadius.only(
        topLeft: Radius.circular(r(35)), bottomLeft: Radius.circular(r(35))),
    boxShadow: [
      BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20)
    ],
  ),
  scrollDownButtonColor: const Color(0xFF00b6ff),
  scrollDownButtonPadding: EdgeInsets.symmetric(
      horizontal: formatWidth(10), vertical: formatHeight(6)),
);
