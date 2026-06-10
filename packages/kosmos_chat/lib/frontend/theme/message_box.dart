import 'package:core_kosmos/core_kosmos.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/material.dart';

part 'message_box.freezed.dart';

@freezed
class MessageBoxThemeData with _$MessageBoxThemeData {
  const factory MessageBoxThemeData({
    final double? extentRatio,
    final double? sendStatusIconSize,
    final double? spacingBetweenMessage,
    final double? spacingBetweenSameSenderMessage,
    final double? messageSenderPPSize,
    final Color? replyToIconColor,
    final Color? messageErrorColor,

    /// Message Box when i was the sender
    final BoxDecoration? meContainerDecoration,
    final BorderRadiusGeometry? mePreviousMessageBorderRadius,
    final TextStyle? meMessageTextStyle,
    final TextStyle? meSendAtTextStyle,
    final Color? meMessageSendingColor,
    final Color? meMessageSendColor,
    final Color? meMessageReadColor,
    final EdgeInsets? meMessagePadding,
    final EdgeInsets? meMediaMessagePadding,
    final Color? meAudioColor,
    final Color? meAudioTrackColor,
    final Color? meAudioBackTrackColor,
    final TextStyle? meAudioTrackTextStyle,

    /// Message Box when other user was
    /// the receiver
    final BoxDecoration? otherContainerDecoration,
    final BorderRadiusGeometry? otherPreviousMessageBorderRadius,
    final TextStyle? otherMessageTextStyle,
    final TextStyle? otherSendAtTextStyle,
    final EdgeInsets? otherMessagePadding,
    final EdgeInsets? otherMediaMessagePadding,
    final Color? otherAudioColor,
    final TextStyle? otherAudioTrackTextStyle,
    final Color? otherAudioReadColor,
    final Color? otherAudioFullReadColor,
    final Color? otherAudioTrackColor,
    final Color? otherAudioBackTrackColor,
    final TextStyle? groupSenderTextStyle,

    /// Reply to
    final BoxDecoration? otherReplyToDecoration,
    final BoxDecoration? meReplyToDecoration,
    final EdgeInsets? replyToPadding,

    /// ReplyTo Message
    final TextStyle? meReplyMessageUserStyle,
    final TextStyle? meReplyMessageContentStyle,
    final Color? meReplyMessageToIconColor,
    final TextStyle? otherReplyMessageUserStyle,
    final TextStyle? otherReplyMessageContentStyle,
    final Color? otherReplyMessageToIconColor,
    final EdgeInsetsGeometry? replyPadding,
    final Widget? Function(bool fromMe, bool play)? messageAudioControl,

    /// Group Color
    final List<Color>? groupNameColors,
  }) = _MessageBoxThemeData;
}

final MessageBoxThemeData kDefaultMessageBoxThemeData = MessageBoxThemeData(
  extentRatio: .65,
  sendStatusIconSize: formatHeight(9),
  spacingBetweenMessage: formatHeight(7),
  spacingBetweenSameSenderMessage: formatHeight(2),
  replyToIconColor: DefaultColor.darkGrey,
  messageErrorColor: DefaultColor.error,

  /// Me user
  meContainerDecoration: BoxDecoration(
    color: DefaultColor.darkBlue,
    borderRadius: BorderRadius.only(
      topLeft: Radius.circular(r(11)),
      topRight: Radius.circular(r(11)),
      bottomLeft: Radius.circular(r(11)),
    ),
  ),
  mePreviousMessageBorderRadius: BorderRadius.circular(r(11)),
  meMessagePadding: EdgeInsets.fromLTRB(
      formatWidth(14.5), formatHeight(9), formatWidth(13.5), formatHeight(10)),
  meMessageTextStyle: DefaultAppStyle.white(16, FontWeight.w400)
      .copyWith(fontFamily: "Helvetica"),
  meSendAtTextStyle: DefaultAppStyle.lightGrey(13, FontWeight.w400).copyWith(
      fontFamily: "Helvetica"), //.copyWith(color: Colors.white.withOpacity(.8))
  meMessageSendingColor: Colors.white.withOpacity(.5),
  meMessageSendColor: Colors.white.withOpacity(.5),
  meMessageReadColor: DefaultColor.white,
  meAudioTrackTextStyle: TextStyle(
    color: Colors.grey,
    fontSize: formatHeight(12),
  ),
  otherAudioTrackTextStyle: TextStyle(
    color: Colors.grey,
    fontSize: formatHeight(12),
  ),
  meMediaMessagePadding: EdgeInsets.fromLTRB(
      formatWidth(2.5), formatHeight(3), formatWidth(2.5), formatHeight(10)),

  /// Other user
  otherContainerDecoration: BoxDecoration(
    color: DefaultColor.lowGrey,
    borderRadius: BorderRadius.only(
      topLeft: Radius.circular(r(11)),
      topRight: Radius.circular(r(11)),
      bottomRight: Radius.circular(r(11)),
    ),
  ),
  otherPreviousMessageBorderRadius: BorderRadius.circular(r(11)),
  otherMessageTextStyle: DefaultAppStyle.darkBlue(16, FontWeight.w400)
      .copyWith(fontFamily: "Helvetica"),
  otherMessagePadding: EdgeInsets.fromLTRB(
      formatWidth(14.5), formatHeight(9), formatWidth(13.5), formatHeight(10)),
  otherSendAtTextStyle: DefaultAppStyle.darkGrey(13, FontWeight.w400)
      .copyWith(fontFamily: "Helvetica"),
  otherMediaMessagePadding: EdgeInsets.fromLTRB(
      formatWidth(2.5), formatHeight(3), formatWidth(2.5), formatHeight(10)),

  /// Reply To
  replyToPadding: EdgeInsets.symmetric(
          horizontal: formatWidth(12), vertical: formatHeight(5))
      .copyWith(right: formatWidth(3.5)),
  meReplyToDecoration: BoxDecoration(
      color: DefaultColor.white.withOpacity(.12),
      borderRadius: BorderRadius.circular(r(7))),
  otherReplyToDecoration: BoxDecoration(
      color: DefaultColor.darkBlue.withOpacity(.03),
      borderRadius: BorderRadius.circular(r(7))),

  meReplyMessageUserStyle: DefaultAppStyle.white(15.5, FontWeight.w500)
      .copyWith(color: const Color(0xFF00b6ff))
      .copyWith(fontFamily: "Helvetica"),
  meReplyMessageContentStyle: DefaultAppStyle.lightGrey(15, FontWeight.w400)
      .copyWith(fontFamily: "Helvetica"),
  meReplyMessageToIconColor: DefaultColor.lightGrey,
  otherReplyMessageUserStyle: DefaultAppStyle.darkBlue(15.5, FontWeight.w400)
      .copyWith(color: const Color(0xFFFF65A7))
      .copyWith(fontFamily: "Helvetica"),
  otherReplyMessageContentStyle: DefaultAppStyle.darkGrey(15, FontWeight.w400)
      .copyWith(fontFamily: "Helvetica"),
  otherReplyMessageToIconColor: DefaultColor.darkGrey,
  replyPadding: EdgeInsets.symmetric(
          horizontal: formatWidth(5), vertical: formatHeight(5))
      .copyWith(bottom: 0),

  /// Audio
  otherAudioColor: const Color(0xFF044AE6),
  otherAudioFullReadColor: const Color(0xFF0ADB6B),
  otherAudioReadColor: DefaultColor.darkBlue,
  otherAudioTrackColor: const Color(0xFF044AE6),
  otherAudioBackTrackColor: Colors.black.withOpacity(.07),
  meAudioColor: Colors.white,
  meAudioTrackColor: Colors.white,
  meAudioBackTrackColor: Colors.white.withOpacity(.4),

  /// Group
  groupNameColors: const [
    Color(0xFFffbe0b),
    Color(0xFFfb5607),
    Color(0xFFff006e),
    Color(0xFF8338ec),
    Color(0xFF3a86ff),
    Color(0xFF8ac926),
    Color(0xFFff595e),
  ],
);
