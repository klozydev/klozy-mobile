import 'package:cached_network_image/cached_network_image.dart';
import 'package:core_kosmos/core_kosmos.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:kosmos_chat/backend/provider/tchat_user_data.dart';
import 'package:kosmos_chat/frontend/theme/groupSettings/group_cellule_theme_data.dart';
import 'package:kosmos_chat/kosmos_chat.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class GroupUserSlidable extends ConsumerStatefulWidget {
  final String userId;
  final bool isAdmin;
  final String tchatId;

  final TchatThemeData? theme;

  final void Function(BuildContext, WidgetRef, SocialUser user)?
      actionMoreEvent;
  final void Function(BuildContext, WidgetRef, SocialUser user)?
      actionDeleteEvent;

  const GroupUserSlidable({
    super.key,
    required this.userId,
    required this.tchatId,
    this.isAdmin = false,
    this.theme,
    this.actionDeleteEvent,
    this.actionMoreEvent,
  });

  @override
  ConsumerState<GroupUserSlidable> createState() => _GroupUserSlidableState();
}

class _GroupUserSlidableState extends ConsumerState<GroupUserSlidable> {
  
  final GlobalKey _slidableKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    TchatGroupSettingsConfig config = (getAppModel()
          .dependencies
          .packages["tchat_group_settings"] as TchatGroupSettingsConfig?) ??
      TchatGroupSettingsConfig();
  late final GroupCelluleThemeData themeData =
      loadThemeData(null, "group_cellule", () => kDefaultGroupCellule,
      isDark: ref.watch(isDarkModeProvider).isDarkMode,       );
    final prov = ref.read(tchatUserListProvider);
    SocialUser? otherUser = prov.getById(widget.userId);
    Widget c = Image.asset(
        widget.theme?.tchatRowOtoDefaultAsset ??
            "assets/images/group_image.png",
        package: widget.theme?.tchatRowOtoDefaultAsset != null
            ? null
            : "kosmos_chat",
        fit: BoxFit.cover);

    // ignore: deprecated_member_use
    if (otherUser?.profileImage != null ||
        otherUser?.userProfileImage != null) {
      c = CachedNetworkImage(
        imageUrl: otherUser?.profileImage ??
            otherUser?.userProfileImage?.compressedUrl ??
            otherUser?.userProfileImage?.url ??
            "",
        fit: BoxFit.cover,
        errorWidget: (context, url, error) => Image.asset(
            widget.theme?.tchatRowOtoDefaultAsset ??
                "assets/images/group_image.png",
            package: widget.theme?.tchatRowOtoDefaultAsset != null
                ? null
                : "kosmos_chat",
            fit: BoxFit.cover),
        placeholder: (context, url) => Image.asset(
            widget.theme?.tchatRowOtoDefaultAsset ??
                "assets/images/group_image.png",
            package: widget.theme?.tchatRowOtoDefaultAsset != null
                ? null
                : "kosmos_chat",
            fit: BoxFit.cover),
      );
    }
    return Slidable(
      endActionPane: otherUser?.id == FirebaseAuth.instance.currentUser?.uid
          ? null
          : ActionPane(
              extentRatio: widget.isAdmin ? 0.4 : 0.25,
              motion: const BehindMotion(),
              children: _buildEndAction(context, otherUser),
            ),
      key: _slidableKey,
      child: Container(
        width: double.infinity,
        padding: themeData.padding ??
            EdgeInsets.symmetric(
              horizontal: formatWidth(13),
              vertical: formatWidth(13),
            ),
        decoration: themeData.decoration,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        constraints: BoxConstraints(minHeight: formatHeight(62)),
        child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              InkWell(
                onTap: config.onPariticpantImageClick != null
                    ? () {
                        config.onPariticpantImageClick!(
                          context,
                          ref,
                          widget.tchatId,
                          widget.userId,
                        );
                      }
                    : null,
                child: Container(
                  width: formatWidth(37),
                  height: formatWidth(37),
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: DefaultColor.lowBlue,
                    borderRadius: BorderRadius.circular(formatWidth(51)),
                  ),
                  child: c,
                ),
              ),
              sw(13),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      otherUser?.pseudo ?? otherUser?.firstname ?? "No name",
                      style: themeData.titleStyle,
                      maxLines: otherUser?.pseudo != null ||
                              otherUser?.firstname != null
                          ? 1
                          : 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (config.showPariticpantPhoneNumber == true)
                      Text(otherUser?.phone ?? "No name",
                          style: themeData.subtitleStyle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ]),
      ),
    );
  }

  List<Widget> _buildEndAction(BuildContext context, SocialUser? otherUser) {
    return [
      Expanded(
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Builder(builder: (context) {
                  return InkWell(
                    onTap: () {
                      Slidable.of(context)?.close();
                      if (otherUser != null) {
                        widget.actionMoreEvent?.call(context, ref, otherUser);
                      }
                    },
                    child: Container(
                      width: widget.theme?.actionPaneSize?.width ??
                          formatWidth(45),
                      height: widget.theme?.actionPaneSize?.height ??
                          formatWidth(45),
                      decoration: widget.theme?.actionPaneMoreDecoration ??
                          BoxDecoration(
                            color: DefaultColor.darkBlue.withOpacity(.05),
                            borderRadius:
                                BorderRadius.circular(formatWidth(14)),
                          ),
                      child: Center(
                        child: SvgPicture.asset(
                          "assets/svg/ic_more.svg",
                          package: "kosmos_chat",
                          color: widget.theme?.actionPaneMoreIconColor,
                        ),
                      ),
                    ),
                  );
                }),
              ),
              sw(10),
              if (widget.isAdmin)
                Center(
                  child: Builder(builder: (context) {
                    return InkWell(
                      onTap: () async {
                        Slidable.of(context)?.close();

                        final r = await showCupertinoModalPopup<bool>(
                          context: context,
                          builder: (BuildContext context) =>
                              CupertinoAlertDialog(
                            title: Text(
                                'package.tchat.info.delete-user-confirm'.tr()),
                            actions: <CupertinoDialogAction>[
                              CupertinoDialogAction(
                                isDefaultAction: true,
                                onPressed: () {
                                  Navigator.pop(context, false);
                                },
                                child: Text('utils.no'.tr()),
                              ),
                              CupertinoDialogAction(
                                isDestructiveAction: true,
                                onPressed: () {
                                  Navigator.pop(context, true);
                                },
                                child: Text('utils.yes'.tr()),
                              ),
                            ],
                          ),
                        );

                        if (r == true && mounted && otherUser != null) {
                          widget.actionDeleteEvent
                              ?.call(context, ref, otherUser);
                        }
                      },
                      child: Container(
                        width: widget.theme?.actionPaneSize?.width ??
                            formatWidth(45),
                        height: widget.theme?.actionPaneSize?.height ??
                            formatWidth(45),
                        decoration: widget.theme?.actionPaneDeleteDecoration ??
                            BoxDecoration(
                              color: DefaultColor.error,
                              borderRadius:
                                  BorderRadius.circular(formatWidth(14)),
                            ),
                        child: Center(
                          child: SvgPicture.asset(
                            "assets/svg/ic_delete.svg",
                            package: "kosmos_chat",
                            color: widget.theme?.actionPaneDeleteIconColor,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
            ],
          ),
        ),
      )
    ];
  }
}
