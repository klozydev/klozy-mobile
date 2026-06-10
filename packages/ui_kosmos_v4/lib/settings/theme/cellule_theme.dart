import 'package:core_kosmos/core_kosmos.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'cellule_theme.freezed.dart';

/// {@category Theme}
///
/// Permet de configurer le thème du [SettingsCellule].
@freezed
class SettingsCelluleThemeData with _$SettingsCelluleThemeData {
  const factory SettingsCelluleThemeData({
    final EdgeInsetsGeometry? padding,
    final BoxDecoration? decoration,
    final Color? actionIconColor,
    final double? spaceBetweenCellules,
    final TextStyle? titleStyle,
    final TextStyle? subtitleStyle,
    final Color? prefixIconColor,
    final Color? prefixIconBackgroundColor,
    final Gradient? prefixIconBackgroundGradient,
    final BoxConstraints? celluleConstraints,
  }) = _SettingsCelluleThemeData;
}

final kDefaultCellule = SettingsCelluleThemeData(
  spaceBetweenCellules: formatHeight(6.6),
  celluleConstraints: BoxConstraints(minHeight: formatHeight(62)),
  padding: EdgeInsets.symmetric(
      horizontal: formatWidth(14), vertical: formatHeight(11.5)),
  decoration: BoxDecoration(
      color: DefaultColor.lowGrey, borderRadius: BorderRadius.circular(r(7))),
  actionIconColor: const Color(0xFFA4AAB2),
  titleStyle: DefaultAppStyle.darkBlue(13, FontWeight.w500),
  subtitleStyle: DefaultAppStyle.darkGrey(11, FontWeight.w400),
  prefixIconColor: Colors.white,
  prefixIconBackgroundColor: DefaultColor.darkBlue,
);
