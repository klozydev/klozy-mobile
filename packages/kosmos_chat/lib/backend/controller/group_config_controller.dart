// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:core_kosmos/core_kosmos.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kosmos_chat/backend/kosmos_chat_backend.dart';
import 'package:kosmos_chat/frontend/theme/groupSettings/group_settings_theme_data.dart';
import 'package:ui_kosmos_v4/ui_kosmos_v4.dart';

class GroupConfigController implements GroupConfigInterface {
  const GroupConfigController() : super();

  @override
  FutureOr<void> deleteMyGroup(
    BuildContext context,
    WidgetRef ref,
    String salonId,
  ) async {
    try {
      final r = await showCupertinoModalPopup<bool>(
        context: context,
        builder: (BuildContext _) => CupertinoAlertDialog(
          title: Text('package.tchat.info.delete-my-group-confirm'.tr()),
          actions: <CupertinoDialogAction>[
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () {
                Navigator.pop(_, false);
              },
              child: Text('utils.no'.tr()),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () {
                Navigator.pop(_, true);
              },
              child: Text('utils.yes'.tr()),
            ),
          ],
        ),
      );
      if (r == null || !r) return;

      PopupAlert.toast(
        context,
        FToast().init(context),
        title: "utils.success".tr(),
        subtitle: "package.tchat.info.delete-group".tr(),
        type: AlertType.success,
      );
      await Future.delayed(const Duration(milliseconds: 500));
      await FirebaseFirestore.instance
          .collection("tchat")
          .doc(salonId)
          .delete();
      await AutoRouter.of(context).maybePop();
      await AutoRouter.of(context).maybePop();
    } catch (e) {
      rethrow;
    }
  }

  @override
  FutureOr<void> leaveGroup(
    BuildContext context,
    WidgetRef ref,
    String salonId,
  ) async {
    try {
      TchatModel? tchat = ref
          .read(tchatListProvider(FirebaseAuth.instance.currentUser!.uid))
          .tchatList
          ?.firstWhereOrNull((element) => element.id == salonId);

      if (tchat == null) return;
      if (tchat.participants.length == 1) {
        final r = await showCupertinoModalPopup<bool>(
          context: context,
          builder: (_) => CupertinoAlertDialog(
            title: Text('package.tchat.info.last-leave-group-confirm'.tr()),
            actions: <CupertinoDialogAction>[
              CupertinoDialogAction(
                isDefaultAction: true,
                onPressed: () {
                  Navigator.pop(_, false);
                },
                child: Text('utils.no'.tr()),
              ),
              CupertinoDialogAction(
                isDestructiveAction: true,
                onPressed: () {
                  Navigator.pop(_, true);
                },
                child: Text('utils.yes'.tr()),
              ),
            ],
          ),
        );
        if (r == null || !r) return;
        PopupAlert.toast(
          context,
          FToast().init(context),
          title: "utils.success".tr(),
          subtitle: "package.tchat.info.delete-group".tr(),
          type: AlertType.success,
        );
        await Future.delayed(const Duration(milliseconds: 500));
        await FirebaseFirestore.instance
            .collection("tchat")
            .doc(salonId)
            .delete();
        await AutoRouter.of(context).maybePop();
        await AutoRouter.of(context).maybePop();
        return;
      }

      final r = await showCupertinoModalPopup<bool>(
        context: context,
        builder: (_) => CupertinoAlertDialog(
          title: Text('package.tchat.info.leave-group-confirm'.tr()),
          actions: <CupertinoDialogAction>[
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () {
                Navigator.pop(_, false);
              },
              child: Text('utils.no'.tr()),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () {
                Navigator.pop(_, true);
              },
              child: Text('utils.yes'.tr()),
            ),
          ],
        ),
      );

      if (r == null || !r) return;
      await FirebaseFirestore.instance.collection("tchat").doc(salonId).update({
        "participants":
            FieldValue.arrayRemove([FirebaseAuth.instance.currentUser!.uid]),
      });
      PopupAlert.toast(
        context,
        FToast().init(context),
        title: "utils.success".tr(),
        subtitle: "package.tchat.info.leave-group".tr(),
        type: AlertType.success,
      );
      await Future.delayed(const Duration(seconds: 1));
      await AutoRouter.of(context).maybePop();
      await AutoRouter.of(context).maybePop();
    } catch (e) {
      rethrow;
    }
  }

  @override
  FutureOr<void> reportGroupMember(
    BuildContext context,
    WidgetRef ref,
    String tchatId,
    String userId,
  ) async {
    TchatGroupSettingsConfig? config = (getAppModel()
        .dependencies
        .packages["tchat_group_settings"] as TchatGroupSettingsConfig?);

    if (config?.reportGroupMember == null) throw UnimplementedError();

    await config?.reportGroupMember?.call(context, ref, tchatId, userId);
  }

  @override
  FutureOr<void> addUserToGroup(
    BuildContext context,
    WidgetRef ref,
    TchatModel tchat,
  ) {
    throw UnimplementedError();
  }

  @override
  FutureOr<void> actionDeleteUserFromGroup(
    BuildContext context,
    WidgetRef ref,
    String salonId,
    SocialUser user,
  ) async {
    try {
      await FirebaseFirestore.instance.collection("tchat").doc(salonId).update({
        "participants": FieldValue.arrayRemove([user.id]),
      });
      if (context.mounted) {
        PopupAlert.toast(
          context,
          FToast().init(context),
          title: "utils.success".tr(),
          subtitle: "package.tchat.info.remove-user".tr(),
          type: AlertType.success,
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  FutureOr<void> actionMoreEventGroupSettings(
    BuildContext context,
    WidgetRef ref,
    String salonId,
    SocialUser user,
    bool isAdmin,
    bool isBlocked,
    bool isMute,
  ) async {
    final String? eventTag = await showCupertinoModalPopup<String>(
      context: context,
      builder: (ctx) => CupertinoActionSheet(
        message: Text(user.pseudo ?? user.firstname),
        actions: [
          CupertinoActionSheetAction(
            child: Text(isMute
                ? "package.tchat.unmute-user".tr()
                : "package.tchat.mute-user".tr()),
            onPressed: () => Navigator.of(ctx).pop(
              isMute ? "unmute-user" : "mute-user",
            ),
          ),
          CupertinoActionSheetAction(
            child: Text("package.tchat.report-user".tr()),
            onPressed: () => Navigator.of(ctx).pop("report-user"),
          ),
          CupertinoActionSheetAction(
            child: Text(
                isBlocked
                    ? "package.tchat.unblock-user".tr()
                    : "package.tchat.block-user".tr(),
                style: const TextStyle(color: Colors.red)),
            onPressed: () => Navigator.of(ctx).pop(
              isBlocked ? "unblock-user" : "block-user",
            ),
          ),
          if (isAdmin)
            CupertinoActionSheetAction(
              child: Text("package.tchat.remove-user".tr(),
                  style: const TextStyle(color: Colors.red)),
              onPressed: () => Navigator.of(ctx).pop("remove-user"),
            ),
        ],
        cancelButton: CupertinoActionSheetAction(
          child: Text("utils.cancel".tr()),
          onPressed: () => Navigator.of(ctx).pop(null),
        ),
      ),
    );
    if (eventTag == null) return;
    switch (eventTag) {
      case "mute-user":
      case "unmute-user":
        try {
          String combinMute =
              "${FirebaseAuth.instance.currentUser!.uid}_${user.id}";
          await FirebaseFirestore.instance
              .collection("tchat")
              .doc(salonId)
              .update({
            "mutedUsersList": eventTag == "mute-user"
                ? FieldValue.arrayUnion([combinMute])
                : FieldValue.arrayRemove([combinMute]),
          });
        } catch (e) {
          rethrow;
        }
        break;
      case "report-user":
        await reportGroupMember(context, ref, salonId, user.id);
        break;
      case "block-user":
      case "unblock-user":
        await FirebaseFirestore.instance
            .collection("users")
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection("metadata")
            .doc("metadata")
            .update({
          "bloquedUsers": eventTag == "block-user"
              ? FieldValue.arrayUnion([user.id])
              : FieldValue.arrayRemove([user.id]),
        });
        TchatModel? tchat = ref
            .watch(tchatListProvider(FirebaseAuth.instance.currentUser!.uid))
            .tchatList
            ?.firstWhere(
                (element) =>
                    element.type == TchatType.oneToOne &&
                    element.participants
                        .contains(FirebaseAuth.instance.currentUser?.uid) &&
                    element.participants.contains(user.id),
                orElse: () => const TchatModel(participants: []));

        if (tchat == null || tchat.participants.isEmpty) return;

        await FirebaseFirestore.instance
            .collection("tchat")
            .doc(tchat.id)
            .update({
          "blockedByUsers": eventTag == "block-user"
              ? FieldValue.arrayUnion([FirebaseAuth.instance.currentUser!.uid])
              : FieldValue.arrayRemove(
                  [FirebaseAuth.instance.currentUser!.uid]),
        });
        break;
      case "remove-user":
        await FirebaseFirestore.instance
            .collection("tchat")
            .doc(salonId)
            .update({
          "participants": FieldValue.arrayRemove([user.id]),
        });
        break;
    }

    if (eventTag != "report-user" && context.mounted) {
      PopupAlert.toast(
        context,
        FToast().init(context),
        title: "utils.success".tr(),
        subtitle: "package.tchat.info.$eventTag".tr(),
        type: AlertType.success,
      );
    }
  }

  @override
  FutureOr<void> onGroupImageClick(
      TchatModel tchat, BuildContext context, WidgetRef ref) async {
    final String? eventTag = await showCupertinoModalPopup<String>(
      context: context,
      builder: (ctx) => CupertinoActionSheet(
        message: Text("utils.what-do-you-want-to-do".tr()),
        actions: [
          CupertinoActionSheetAction(
            child: Text("package.image.from-gallery".tr()),
            onPressed: () => Navigator.of(ctx).pop("from-gallery"),
          ),
          CupertinoActionSheetAction(
            child: Text("package.image.from-camera".tr()),
            onPressed: () => Navigator.of(ctx).pop("from-camera"),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          child: Text("utils.cancel".tr()),
          onPressed: () => Navigator.of(ctx).pop(null),
        ),
      ),
    );

    if (eventTag == null) return;

    final result = await {
      "from-gallery": ImageFileController.pickImageFromGallery,
      "from-camera": ImageFileController.pickImageFromCamera,
    }[eventTag]
        ?.call(context);
    if (result == null) return;

    final url = await ImageFileController.uploadFileToFirebaseStorage(result,
        "/tchat/${tchat.id}/tchatImage.${result.path.split(".").last}}");

    if (url == null && context.mounted) {
      PopupAlert.toast(context, FToast().init(context),
          title: "utils.error".tr(), subtitle: "utils.error-default".tr());
      return;
    }

    await FirebaseFirestore.instance.collection("tchat").doc(tchat.id).update({
      "tchatPicture": url,
    });
  }

  @override
  FutureOr<void> onGroupNameClick(
      TchatModel tchat, BuildContext context, WidgetRef ref) async {
    late final GroupSettingsThemeData themeData =
        loadThemeData(null, "group-settings", () => kDefaultGroupSettingsTheme,
      isDark: ref.watch(isDarkModeProvider).isDarkMode,       
        );

    final TextEditingController controller =
        TextEditingController(text: tchat.tchatName?.tr());
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    String? tchatName = await showModalBottomSheet<String?>(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        context: context,
        builder: (newC) {
          String? value = tchat.tchatName?.tr();
          return StatefulBuilder(builder: (newC, newSetState) {
            return Container(
              padding: pw(19),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    sh(17.5),
                    Divider(
                      color: Colors.grey,
                      thickness: formatHeight(3),
                      height: 0,
                      indent: formatWidth(140),
                      endIndent: formatWidth(140),
                    ),
                    sh(17.5),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Expanded(
                            child: TextFormField(
                          controller: controller,
                          validator: FieldValidator.fieldNotEmpty,
                          onChanged: (v) {
                            newSetState(() {
                              value = v;
                            });
                          },
                          decoration: kDefaultInputDecoration.copyWith(
                            suffix: InkWell(
                              onTap: () {
                                controller.clear();
                              },
                              child: SizedBox(
                                  width: formatWidth(14),
                                  height: formatWidth(14),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.black.withOpacity(.5),
                                    ),
                                    child: Center(
                                      child: Icon(
                                        Icons.clear,
                                        color: Colors.white,
                                        size: formatWidth(8),
                                      ),
                                    ),
                                  )),
                            ),
                          ),
                        )),
                        sw(18),
                        InkWell(
                          onTap: () {
                            if (formKey.currentState?.validate() == false) {
                              return;
                            }
                            Navigator.pop(newC, value);
                          },
                          child: Text(
                            "package.tchat.change-name-confirm-button".tr(),
                            style: themeData.tchatNameSubmitButtonStyle,
                          ),
                        ),
                      ],
                    ),
                    sh(20),
                  ],
                ),
              ),
            );
          });
        });

    if (tchatName == null || tchatName == tchat.tchatName?.tr()) return;
    await FirebaseFirestore.instance.collection("tchat").doc(tchat.id).update({
      "tchatName": tchatName,
    });
  }
}
