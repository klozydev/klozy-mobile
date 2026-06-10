// ignore_for_file: use_build_context_synchronously

import 'package:cached_network_image/cached_network_image.dart';
import 'package:core_kosmos/core_kosmos.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:kosmos_chat/backend/kosmos_chat_backend.dart';
import 'package:kosmos_chat/backend/model/tchatGroupSettings/cellule_group_section.dart';
import 'package:kosmos_chat/backend/utils/utils.dart';
import 'package:kosmos_chat/frontend/enums/group_image_position.dart';
import 'package:kosmos_chat/frontend/kosmos_chat_frontend.dart';
import 'package:kosmos_chat/frontend/theme/groupSettings/group_settings_theme_data.dart';
import 'package:kosmos_chat/frontend/widget/components/groupSettings/group_cellule.dart';
import 'package:kosmos_chat/frontend/widget/components/group_user_slidable.dart';
import 'package:ui_kosmos_v4/ui_kosmos_v4.dart';

class GroupInfoPage extends ConsumerStatefulWidget {
  final String tchatId;
  const GroupInfoPage({
    super.key,
    @PathParam("tchatId") required this.tchatId,
  });
  @override
  ConsumerState<GroupInfoPage> createState() => _GroupInfoPageState();
}

class _GroupInfoPageState extends ConsumerState<GroupInfoPage> {
  late TchatBackEndConfig tchatBackendConfigController =
      getTchatBackEndConfig();
  late final List<CelluleGroupSection> groupSettingsSections;
  late final TchatGroupSettingsConfig config;

  late TchatBackEndConfig _backEndConfig = getTchatBackEndConfig();

  @override
  void initState() {
    super.initState();
    config = (getAppModel().dependencies.packages["tchat_group_settings"]
            as TchatGroupSettingsConfig?) ??
        TchatGroupSettingsConfig();
    groupSettingsSections =
        config.groupSettingsCellules.call(ref, widget.tchatId);
    for (var section in groupSettingsSections) {
      final index = groupSettingsSections.indexOf(section);
      groupSettingsSections[index] = _updateOnTapWithRedirect(section);
    }
  }

  CelluleGroupSection _updateOnTapWithRedirect(CelluleGroupSection node) {
    for (var cellule in node.cellules) {
      if (cellule.type == CelluleType.action && cellule.sectionChild != null) {
        final index = node.cellules.indexOf(cellule);
        node.cellules[index] = cellule.copyWith(
            onTap: (_, __, tchatId, {bool? redirectToChildren}) {
          cellule.onTap?.call(context, ref, tchatId);
          AutoRouter.of(context)
              .pushNamed("app/profile/settings/${cellule.tag}");
          return null;
        });
      }
      if (cellule.sectionChild != null) {
        _updateOnTapWithRedirect(cellule.sectionChild!);
      }
    }
    return node;
  }

  @override
  Widget build(BuildContext context) {
    final GroupSettingsThemeData themeData = loadThemeData(
      null,
      "tchat_group_settings",
      () => kDefaultGroupSettingsTheme,
      isDark: ref.watch(isDarkModeProvider).isDarkMode,
    );
    final TchatThemeData tchatThemeData = loadThemeData(
      null,
      "tchat_theme",
      () => kDefaultTchatTheme,
      isDark: ref.watch(isDarkModeProvider).isDarkMode,
    );
    TchatModel? tchat = ref
        .watch(tchatListProvider(FirebaseAuth.instance.currentUser!.uid))
        .tchatList
        ?.firstWhereOrNull((p0) => p0.id == widget.tchatId);
    return getResponsiveValue<Widget>(context,
        defaultValue: _buildPhone(context, tchat, themeData, tchatThemeData),
        phone: _buildPhone(context, tchat, themeData, tchatThemeData));
  }

  Widget _buildPhone(BuildContext context, TchatModel? tchat,
      GroupSettingsThemeData themeData, TchatThemeData tchatThemeData) {
    /// If Tchat is null, we show a loader
    /// when we get data, we show the tchat
    if (tchat == null) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        color: tchatThemeData.tchatListBackgroundColor ??
            Theme.of(context).scaffoldBackgroundColor,
        child: Center(
            child:
                LoaderClassique(activeColor: Theme.of(context).primaryColor)),
      );
    }
    return SingleChildScrollView(
      padding:
          EdgeInsets.only(bottom: context.paddingBottom + formatHeight(20)),
      primary: true,
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
              height: MediaQuery.of(context).padding.top + formatHeight(20)),
          Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              ButtonBack(
                color: themeData.actionIconColor,
                padding: EdgeInsets.symmetric(horizontal: formatWidth(27.5)),
                onTap: () => AutoRouter.of(context).maybePop(),
              ),
            ],
          ),
          sh(20),
          _buildTchatInfo(tchat, tchatThemeData, themeData),
          Padding(
            padding: pw(28),
            child: Column(
              children: [
                Divider(
                  height: formatHeight(35),
                  thickness: .5,
                ),
                _buildSections(context, themeData, tchatThemeData),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSections(BuildContext context, GroupSettingsThemeData themeData,
      TchatThemeData tchatThemeData) {
    final List<Widget> children = [];

    final sections = groupSettingsSections;

    for (final section in sections) {
      children.add(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(section.title.call(context, ref),
                style: themeData.sectionTitleStyle ??
                    DefaultAppStyle.darkBlue(16)),
            sh(9),
            ...section.cellules.map((cell) {
              final isLast = section.cellules.last == cell;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GroupCellule(
                    model: cell,
                    tchatId: widget.tchatId,
                  ),
                  if (!isLast) sh(6.6),
                ],
              );
            }).toList(),
            if (section != sections.last) sh(themeData.sectionSpacing ?? 23),
          ],
        ),
      );
    }

    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ...children,
          sh(18),
          _participants(themeData, tchatThemeData),
          sh(15),
          _bottomGroupActions()
        ]);
  }

  Widget _bottomGroupActions() {
    late final GroupSettingsThemeData themeData = loadThemeData(
      null,
      "group-settings",
      () => kDefaultGroupSettingsTheme,
      isDark: ref.watch(isDarkModeProvider).isDarkMode,
    );
    final tchat = ref
        .watch(tchatListProvider(FirebaseAuth.instance.currentUser!.uid))
        .tchatList
        ?.firstWhereOrNull((p0) => p0.id == widget.tchatId);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "package.tchat.other-actions".tr(),
          style: themeData.sectionTitleStyle ?? DefaultAppStyle.darkBlue(16),
        ),
        sh(8),
        Button(
          text: "package.tchat.delete-conversation".tr(),
          onTap: () async {
            if (tchat != null) {
              await getTchatBackEndConfig()
                  .messageInterface
                  .deleteTchat(ref, tchat);

              await AutoRouter.of(context).maybePop();
              await AutoRouter.of(context).maybePop();
            }
          },
          buttonType: ButtonType.primary,
          theme: themeData.actionThemedata,
        ),
        sh(7),
        Button(
          buttonType: ButtonType.primary,
          text: "package.tchat.leave-group".tr(),
          onTap: () async {
            await getTchatBackEndConfig()
                .groupConfigController
                .leaveGroup(context, ref, tchat!.id!);
          },
          theme: themeData.actionSensitiveThemedata,
        ),
        if (tchat?.adminId == FirebaseAuth.instance.currentUser?.uid) ...[
          sh(7),
          Button(
            buttonType: ButtonType.primary,
            text: "package.tchat.delete-group".tr(),
            onTap: () async {
              await getTchatBackEndConfig()
                  .groupConfigController
                  .deleteMyGroup(context, ref, tchat!.id!);
            },
            theme: themeData.actionSensitiveThemedata,
          ),
        ],
        sh(7),
      ],
    );
  }

  Widget _participants(
      GroupSettingsThemeData themeData, TchatThemeData tchatThemeData) {
    final tchat = ref
        .watch(tchatListProvider(FirebaseAuth.instance.currentUser!.uid))
        .tchatList
        ?.firstWhereOrNull((p0) => p0.id == widget.tchatId);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                "package.tchat.participants".tr(
                  args: [tchat?.participants.length.toString() ?? "0"],
                ),
                style:
                    themeData.sectionTitleStyle ?? DefaultAppStyle.darkBlue(16),
              ),
            ),
            if (tchat?.adminId == FirebaseAuth.instance.currentUser?.uid ||
                tchat?.allUserCanAdmin == true)
              InkWell(
                onTap: () {
                  _backEndConfig.groupConfigController
                      .addUserToGroup(context, ref, tchat!);
                },
                child: Text(
                  "package.tchat.add-participants".tr(),
                  style: themeData.addParticipantTextStyle ??
                      DefaultAppStyle.darkBlue(13),
                ),
              ),
          ],
        ),
        sh(8),
        if (tchat != null)
          ...tchat.participants.map((e) => Padding(
                padding: EdgeInsets.only(bottom: formatHeight(7)),
                child: GroupUserSlidable(
                  theme: tchatThemeData,
                  isAdmin:
                      tchat.adminId == FirebaseAuth.instance.currentUser?.uid,
                  userId: e,
                  tchatId: widget.tchatId,
                  actionDeleteEvent: (context, ref, user) {
                    _backEndConfig.groupConfigController
                        .actionDeleteUserFromGroup(
                      context,
                      ref,
                      widget.tchatId,
                      user,
                    );
                  },
                  actionMoreEvent: (_, ref, user) {
                    _backEndConfig.groupConfigController
                        .actionMoreEventGroupSettings(
                      context,
                      ref,
                      widget.tchatId,
                      user,
                      tchat.adminId == FirebaseAuth.instance.currentUser?.uid,
                      (ref.read(userProvider).metadata?.bloquedUsers ?? [])
                          .contains(user.id),
                      tchat.mutedUsersList.contains(
                          "${FirebaseAuth.instance.currentUser!.uid}_${user.id}"),
                    );
                  },
                ),
              )),
      ],
    );
  }

  Widget _buildTchatInfo(TchatModel tchat, TchatThemeData tchatThemeData,
      GroupSettingsThemeData themeData) {
    String? me = ref.read(userProvider).user?.id ??
        FirebaseAuth.instance.currentUser?.uid;

    final bool isAdmin = tchat.adminId == me || tchat.allUserCanAdmin == true;
    final String? s = tchatThemeData.tchatRowGroupDefaultAsset;
    Widget c = Image.asset(s ?? "assets/images/group_image.png",
        package: s != null ? null : "kosmos_chat", fit: BoxFit.cover);
    String? item = tchat.tchatPicture;
    if (item != null) {
      c = CachedNetworkImage(
        imageUrl: item,
        fit: BoxFit.cover,
        errorWidget: (context, url, error) => Image.asset(
            s ?? "assets/images/group_image.png",
            package: s != null ? null : "kosmos_chat",
            fit: BoxFit.cover),
        placeholder: (context, url) => Image.asset(
            s ?? "assets/images/group_image.png",
            package: s != null ? null : "kosmos_chat",
            fit: BoxFit.cover),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Center(
          child: InkWell(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            overlayColor: MaterialStateProperty.all(Colors.transparent),
            onTap: isAdmin == false
                ? null
                : () async {
                    await tchatBackendConfigController
                        .groupConfigController.onGroupImageClick
                        .call(tchat, context, ref);
                  },
            child: Container(
              width: formatWidth(92),
              height: formatWidth(92),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                      child: Container(
                    width: formatWidth(55),
                    height: formatWidth(55),
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: DefaultColor.lowBlue,
                      borderRadius: BorderRadius.circular(formatWidth(51)),
                    ),
                    child: c,
                  )),
                  if (isAdmin)
                    _getProfilModifButtonPositioned(context, themeData),
                ],
              ),
            ),
          ),
        ),
        sh(11),
        InkWell(
          onTap: isAdmin == false
              ? null
              : () async {
                  await _backEndConfig.groupConfigController.onGroupNameClick
                      .call(tchat, context, ref);
                },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  (tchat.tchatName ?? "package.tchat.new-group").tr(),
                  style: themeData.tchatNameStyle,
                  textAlign: TextAlign.center,
                ),
              ),
              if (isAdmin)
                Row(
                  children: [
                    sw(10),
                    SvgPicture.asset(
                      "assets/svg/edit.svg",
                      package: "kosmos_chat",
                      width: formatWidth(15),
                      color: DefaultColor.darkBlue,
                    ),
                  ],
                )
            ],
          ),
        ),
      ],
    );
  }

  Positioned _getProfilModifButtonPositioned(
      BuildContext context, GroupSettingsThemeData themeData) {
    final child = Column(
      children: [
        Container(
          width: formatWidth(22),
          height: formatWidth(22),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(formatWidth(46)),
            color: Colors.black.withOpacity(.7),
          ),
          child: Center(
              child: SvgPicture.asset("assets/svg/edit.svg",
                  package: "kosmos_chat")),
        ),
      ],
    );

    if (themeData.groupImagePosition == GroupImagePosition.bottomCenter) {
      return Positioned(
          bottom: -formatHeight(12), left: 0, right: 0, child: child);
    } else if (themeData.groupImagePosition == GroupImagePosition.bottomRight) {
      return Positioned(bottom: 0, right: 0, child: child);
    } else {
      return Positioned(bottom: 0, left: 0, child: child);
    }
  }
}
