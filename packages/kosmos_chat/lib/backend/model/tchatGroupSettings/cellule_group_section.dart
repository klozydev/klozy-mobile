import 'dart:async';

import 'package:core_kosmos/core_kosmos.dart';
import 'package:flutter/material.dart';
import 'package:ui_kosmos_v4/ui_kosmos_v4.dart';

/// {@category Model}
/// {@category Settings}
///
/// Contient toutes les données nécessaires à la construction d'une liste de
/// [CelluleGroupSection].
///
class CelluleGroupSection {
  final String Function(BuildContext, WidgetRef) title;
  final List<CelluleGroupModel> cellules;
  // add bottom builder to the current Page Node.
  final Widget Function(BuildContext, WidgetRef)? bottomBuilder;

  const CelluleGroupSection({
    required this.title,
    required this.cellules,
    this.bottomBuilder,
  });

  CelluleGroupSection copyWith({
    String Function(BuildContext, WidgetRef)? title,
    List<CelluleGroupModel>? cellules,
  }) =>
      CelluleGroupSection(
        title: title ?? this.title,
        cellules: cellules ?? this.cellules,
      );
}

class CelluleGroupModel {
  final String tag;

  final String Function(BuildContext, WidgetRef) tileBuilder;

  final String Function(BuildContext, WidgetRef)? subTitleBuilder;

  final CelluleType type;

  /// Prefix
  final String? prefixSvgPath;

  final Widget Function(BuildContext, WidgetRef)? prefixBuilder;

  final bool Function(BuildContext, WidgetRef)? showNotifAlert;

  final FutureOr<bool>? Function(BuildContext, WidgetRef, String)? onTap;

  final FutureOr<bool> Function(BuildContext, WidgetRef, bool, String)?
      onSwitch;

  final bool Function(BuildContext, String)? initialSwitchValue;

  final CelluleGroupSection? sectionChild;

  const CelluleGroupModel({
    required this.tag,
    required this.tileBuilder,
    this.subTitleBuilder,
    this.type = CelluleType.action,
    this.prefixSvgPath,
    this.prefixBuilder,
    this.showNotifAlert,
    this.onTap,
    this.onSwitch,
    this.sectionChild,
    this.initialSwitchValue,
  })  : assert(type == CelluleType.switcher ? onSwitch != null : true),
        assert(type == CelluleType.action ? onTap != null : true);

  CelluleGroupModel copyWith({
    String? tag,
    String Function(BuildContext, WidgetRef)? tileBuilder,
    String Function(BuildContext, WidgetRef)? subTitleBuilder,
    CelluleType? type,
    String? prefixSvgPath,
    Widget Function(BuildContext, WidgetRef)? prefixBuilder,
    bool Function(BuildContext, WidgetRef)? showNotifAlert,
    FutureOr<bool>? Function(BuildContext, WidgetRef, String)? onTap,
    bool Function(BuildContext, WidgetRef, bool, String)? onSwitch,
    bool Function(BuildContext, String)? initialSwitchValue,
    CelluleGroupSection? sectionChild,
  }) =>
      CelluleGroupModel(
        tag: tag ?? this.tag,
        tileBuilder: tileBuilder ?? this.tileBuilder,
        subTitleBuilder: subTitleBuilder ?? this.subTitleBuilder,
        type: type ?? this.type,
        prefixSvgPath: prefixSvgPath ?? this.prefixSvgPath,
        prefixBuilder: prefixBuilder ?? this.prefixBuilder,
        showNotifAlert: showNotifAlert ?? this.showNotifAlert,
        onTap: onTap ?? this.onTap,
        onSwitch: onSwitch ?? this.onSwitch,
        initialSwitchValue: initialSwitchValue ?? this.initialSwitchValue,
        sectionChild: sectionChild ?? this.sectionChild,
      );
}
