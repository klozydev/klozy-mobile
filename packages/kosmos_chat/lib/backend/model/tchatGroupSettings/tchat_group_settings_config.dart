import 'package:core_kosmos/core_kosmos.dart';
import 'package:flutter/material.dart';
import 'package:kosmos_chat/backend/model/tchatGroupSettings/cellule_group_section.dart';

class TchatGroupSettingsConfig extends PackageConfig {
  final List<CelluleGroupSection> Function(WidgetRef, String)
      groupSettingsCellules;
  final Function(BuildContext, WidgetRef, String, String)? reportGroupMember;

  final Function(
      BuildContext,
      WidgetRef,
      // tchat id
      String,
      // user id
      String)? onPariticpantImageClick;
  final bool? showPariticpantPhoneNumber;

  TchatGroupSettingsConfig({
    this.groupSettingsCellules = _defaultSettingsSection,
    this.reportGroupMember,
    this.onPariticpantImageClick,
    this.showPariticpantPhoneNumber = true,
  }) : super("tchat_group_settings");
}

List<CelluleGroupSection> _defaultSettingsSection(
        WidgetRef ref, String tchatId) =>
    <CelluleGroupSection>[];
