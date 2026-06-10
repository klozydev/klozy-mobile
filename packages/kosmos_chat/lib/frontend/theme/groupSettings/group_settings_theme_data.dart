import 'package:core_kosmos/core_kosmos.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kosmos_chat/frontend/enums/group_image_position.dart';
import 'package:ui_kosmos_v4/ui_kosmos_v4.dart';

part 'group_settings_theme_data.freezed.dart';

/// {@category Theme}
/// {@category KosmosSettings}
///
/// Thème Data contenant toutes les configurations des pages de settings.
/// Par défaut, les widgets du package utilisent le thème défini dans [kDefaultSettingsTheme].
///
/// Vous pouvez le configurer via "kosmos-settings".
///
@freezed
class GroupSettingsThemeData with _$GroupSettingsThemeData {
  const factory GroupSettingsThemeData({
    final Color? actionIconColor,
    final TextStyle? tchatNameStyle,
    final TextStyle? sectionTitleStyle,
    final double? sectionSpacing,
    final TextStyle? tchatNameSubmitButtonStyle,
    final TextStyle? addParticipantTextStyle,
    final GroupImagePosition? groupImagePosition,
    final KosmosButtonThemeData? actionThemedata,
    final KosmosButtonThemeData? actionSensitiveThemedata,
  }) = _GroupSettingsThemeData;
}

final GroupSettingsThemeData kDefaultGroupSettingsTheme =
    GroupSettingsThemeData(
  actionIconColor: DefaultColor.darkBlue,
  addParticipantTextStyle: TextStyle(
    color: const Color(0XFF4179B2),
    fontSize: sp(13),
    fontWeight: FontWeight.w600,
  ),
  sectionTitleStyle: DefaultAppStyle.darkBlue(16),
  sectionSpacing: formatHeight(23),
  groupImagePosition: GroupImagePosition.bottomRight,
  tchatNameSubmitButtonStyle: TextStyle(
    color: DefaultColor.info,
    fontSize: sp(13),
    fontWeight: FontWeight.w600,
  ),
  actionThemedata: KosmosButtonThemeData(
    padding: EdgeInsets.symmetric(
        vertical: formatHeight(20), horizontal: formatWidth(12)),
    decoration: BoxDecoration(
      color: const Color(0XFFF5F5F5).withOpacity(.67),
      borderRadius: BorderRadius.circular(formatWidth(7)),
    ),
    buttonTextStyle: TextStyle(
        color: Colors.black, fontSize: sp(13), fontWeight: FontWeight.w600),
  ),
  actionSensitiveThemedata: KosmosButtonThemeData(
    padding: EdgeInsets.symmetric(
        vertical: formatHeight(20), horizontal: formatWidth(12)),
    decoration: BoxDecoration(
      color: const Color(0XFFF5F5F5).withOpacity(.67),
      borderRadius: BorderRadius.circular(formatWidth(7)),
    ),
    buttonTextStyle: TextStyle(
        color: Colors.red, fontSize: sp(13), fontWeight: FontWeight.w600),
  ),
  tchatNameStyle: TextStyle(
    color: DefaultColor.darkBlue,
    fontSize: 18.sp,
    fontWeight: FontWeight.w600,
  ),
);
