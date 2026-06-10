import 'package:core_kosmos/core_kosmos.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'tchat_theme.freezed.dart';

/// key = "tchat_theme"
@freezed
class TchatThemeData with _$TchatThemeData {
  const factory TchatThemeData({
    /// Misc
    final Color? tchatListShimmerBaseColor,
    final Color? tchatListShimmerHighlightColor,
    final Color? tchatListBackgroundColor,

    /// Tchat Item Theme
    final TextStyle? tchatListTitleStyle,
    final TextStyle? tchatListNoTchatStyle,
    final TextStyle? tchatListNoTchatContentStyle,
    final Color? tchatListIconColor,

    /// Tchat Row Theme
    final double? tchatRowLeftSpacing,
    final TextStyle? tchatRowTitleStyle,
    @Default(1) final int tchatRowTitleMaxLine,
    final TextStyle? tchatRowLastMessageStyle,
    final TextStyle? tchatRowEventMessageStyle,
    final TextStyle? tchatRowTimeAgoStyle,
    @Default(true) final bool tchatRowShowIcon,
    final Size? tchatRowIconSize,
    final String? tchatRowGroupDefaultAsset,
    final String? tchatRowOtoDefaultAsset,
    final Color? tchatRowActionIconColor,
    final Color? tchatRowNotifColor,
    final Gradient? tchatRowNotifGradient,
    final double? tchatRowActionIconSize,
    final TextStyle? tchatRowEventStyle,

    /// Action Pane
    final BoxDecoration? actionPaneMoreDecoration,
    final BoxDecoration? actionPaneDeleteDecoration,
    final Size? actionPaneSize,
    final Color? actionPaneMoreIconColor,
    final Color? actionPaneDeleteIconColor,
  }) = _TchatThemeData;
}

final TchatThemeData kDefaultTchatTheme = TchatThemeData(
  /// Misc
  tchatListShimmerBaseColor: DefaultColor.lightGrey,
  tchatListShimmerHighlightColor: DefaultColor.lightGrey.withOpacity(0.5),

  /// Tchat Item
  tchatListTitleStyle:
      DefaultAppStyle.darkBlue(16).copyWith(fontFamily: "Helvetica"),
  tchatListIconColor: DefaultColor.darkBlue,
  tchatListNoTchatStyle: DefaultAppStyle.darkBlue(16, FontWeight.w500)
      .copyWith(fontFamily: "Helvetica"),
  tchatListNoTchatContentStyle: DefaultAppStyle.darkGrey(14, FontWeight.w400)
      .copyWith(fontFamily: "Helvetica"),
  tchatRowActionIconColor: DefaultColor.simpleGrey,
  tchatRowNotifColor: DefaultColor.darkBlue,
  tchatRowActionIconSize: formatWidth(14),
  tchatRowTimeAgoStyle: DefaultAppStyle.darkGrey(14.5, FontWeight.w400)
      .copyWith(fontFamily: "Helvetica"),

  /// Tchat Row
  tchatRowLeftSpacing: formatWidth(15),
  tchatRowTitleStyle: DefaultAppStyle.darkBlue(20, FontWeight.w500)
      .copyWith(fontFamily: "Helvetica"),
  tchatRowLastMessageStyle: DefaultAppStyle.darkGrey(15, FontWeight.w500)
      .copyWith(fontFamily: "Helvetica"),
  tchatRowEventMessageStyle: DefaultAppStyle.darkGrey(15, FontWeight.w500)
      .copyWith(fontStyle: FontStyle.italic)
      .copyWith(fontFamily: "Helvetica"),
  tchatRowIconSize: Size(formatWidth(51), formatWidth(51)),
);
