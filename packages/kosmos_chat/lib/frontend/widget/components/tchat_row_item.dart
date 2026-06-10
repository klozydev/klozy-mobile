// ignore_for_file: deprecated_member_use
// add WidgetRef parameter to tchatNameBuilder callback in TchatListingConfig
import 'package:cached_network_image/cached_network_image.dart';
import 'package:core_kosmos/core_kosmos.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/svg.dart';
import 'package:kosmos_chat/backend/kosmos_chat_backend.dart';
import 'package:kosmos_chat/backend/provider/status.dart';
import 'package:kosmos_chat/backend/provider/tchat_user_data.dart';
import 'package:kosmos_chat/frontend/config/tchat_frontend_config.dart';
import 'package:kosmos_chat/frontend/theme/tchat_theme.dart';
import 'package:kosmos_chat/frontend/utils/utils.dart';
import 'package:kosmos_chat/frontend/widget/components/message_builder.dart';
import 'package:timeago_flutter/timeago_flutter.dart';

class TchatRowItem extends StatefulHookConsumerWidget {
  final TchatModel data;

  final ActionPane Function(BuildContext context, TchatModel tchat)?
      buildTchatRowAction;
  final void Function(BuildContext, WidgetRef, TchatModel)? actionMoreEvent;
  final void Function(BuildContext, TchatModel)? actionDeleteEvent;

  /// Ui
  final TchatThemeData? theme;

  const TchatRowItem({
    super.key,
    required this.data,
    this.buildTchatRowAction,
    this.theme,
    this.actionDeleteEvent,
    this.actionMoreEvent,
  });

  @override
  ConsumerState<TchatRowItem> createState() => _TchatRowItemState();
}

class _TchatRowItemState extends ConsumerState<TchatRowItem> {
  final GlobalKey _slidableKey = GlobalKey();
  List<SocialUser> userList = [];

  late SocialUser? otherUser;

  @override
  Widget build(BuildContext context) {
    final prov = ref.read(tchatUserListProvider);
    TchatFrontEndConfig frontEndConfig = getTchatFrontEndConfig();

    userList.clear();
    for (final element in widget.data.participants) {
      final u = prov.getById(element);
      if (u != null) userList.add(u);
    }

    if (!widget.data.isGroup) {
      otherUser = userList.firstWhereOrNull(
          (element) => element.id != FirebaseAuth.instance.currentUser!.uid);
    }

    final bool lastMessageSeen = !widget.data.lastMessageSeenBy
        .contains(FirebaseAuth.instance.currentUser!.uid);

    return Slidable(
      key: _slidableKey,
      endActionPane: widget.data.type == TchatType.group
          ? null
          : widget.buildTchatRowAction?.call(context, widget.data) ??
              ActionPane(
                extentRatio: .4,
                motion: const BehindMotion(),
                children: _buildEndAction(context),
              ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          SizedBox(width: widget.theme?.tchatRowLeftSpacing ?? formatWidth(26)),
          if (widget.theme?.tchatRowShowIcon ?? true) ...[
            InkWell(
              highlightColor: Colors.transparent,
              onTap: frontEndConfig.listing.onTchatRowListImageClick == null
                  ? null
                  : () {
                      frontEndConfig.listing.onTchatRowListImageClick!
                          .call(context, ref, widget.data);
                    },
              child: _buildTchatImage(context),
            ),
            sw(18),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  constraints: BoxConstraints(minHeight: formatWidth(51)),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child:
                                  
                                  frontEndConfig.listing.tchatNameBuilder?.call(context, ref, widget.data, widget.theme) ?? Text(
                                    widget.data.isGroup
                                        ? widget.data.tchatName ??
                                            "package.tchat.list.group-default-title"
                                                .tr()
                                        : (otherUser?.pseudo?.isNotEmpty ??
                                                false)
                                            ? otherUser!.pseudo!
                                            : (otherUser?.firstname
                                                        .isNotEmpty ??
                                                    false)
                                                ? otherUser!.firstname
                                                : "package.tchat.list.oto-default-title"
                                                    .tr(),
                                    maxLines:
                                        widget.theme?.tchatRowTitleMaxLine,
                                    overflow: TextOverflow.ellipsis,
                                    style: widget.theme?.tchatRowTitleStyle,
                                  ),
                                ),
                                // Two type of Date Indicator
                                () {
                                  switch (frontEndConfig
                                      .listing.dateTimeAgoIndicatorStyle) {
                                    case DateTimeAgoIndicatorStyle.fixedDate:
                                      return _buildDate(
                                          context, lastMessageSeen);
                                    case DateTimeAgoIndicatorStyle
                                          .timeSinceLastMessage:
                                      return _buildDateWithDiff(
                                          context, lastMessageSeen);
                                  }
                                }.call(),
                              ],
                            ),
                            sh(4),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                    child: Transform.translate(
                                        offset: const Offset(0, -2),
                                        child: _buildSubContentText(context))),
                                Row(
                                  children: [
                                    if (lastMessageSeen) ...[
                                      sw(7),
                                      Center(
                                        child: Container(
                                          width: formatWidth(11),
                                          height: formatWidth(11),
                                          decoration: BoxDecoration(
                                            color: widget.theme
                                                        ?.tchatRowNotifGradient !=
                                                    null
                                                ? null
                                                : widget.theme
                                                        ?.tchatRowNotifColor ??
                                                    DefaultColor.darkBlue,
                                            gradient: widget
                                                .theme?.tchatRowNotifGradient,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ),
                                    ],
                                    sw(7),
                                    Center(
                                      child: Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        color: widget.theme
                                                ?.tchatRowActionIconColor ??
                                            DefaultColor.simpleGrey,
                                        size: widget.theme
                                                ?.tchatRowActionIconSize ??
                                            formatWidth(14),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                      sw(18),
                    ],
                  ),
                ),
                sh(5),
                const Divider(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTchatImage(BuildContext context) {
    final String? s = widget.data.isGroup
        ? widget.theme?.tchatRowGroupDefaultAsset
        : widget.theme?.tchatRowOtoDefaultAsset;

    Widget c = Image.asset(
        s ??
            (widget.data.isGroup
                ? "assets/images/group_image.png"
                : "assets/images/oto_image.png"),
        package: s != null ? null : "kosmos_chat",
        fit: BoxFit.cover);

    if (widget.data.tchatPicture != null) {
      c = CachedNetworkImage(
        imageUrl: widget.data.tchatPicture!,
        fit: BoxFit.cover,
        errorWidget: (context, url, error) => Image.asset(
            s ??
                (widget.data.isGroup
                    ? "assets/images/group_image.png"
                    : "assets/images/oto_image.png"),
            package: s != null ? null : "kosmos_chat",
            fit: BoxFit.cover),
        placeholder: (context, url) => Image.asset(
            s ??
                (widget.data.isGroup
                    ? "assets/images/group_image.png"
                    : "assets/images/oto_image.png"),
            package: s != null ? null : "kosmos_chat",
            fit: BoxFit.cover),
      );
    }

    if (!widget.data.isGroup) {
      final u = userList.firstWhereOrNull(
          (element) => element.id != FirebaseAuth.instance.currentUser!.uid);
      if (u != null && (u.profileImage != null || u.userProfileImage != null)) {
        c = CachedNetworkImage(
          imageUrl: u.profileImage ??
              u.userProfileImage?.compressedUrl ??
              u.userProfileImage?.url ??
              "",
          fit: BoxFit.cover,
          errorWidget: (context, url, error) => Image.asset(
              s ??
                  (widget.data.isGroup
                      ? "assets/images/group_image.png"
                      : "assets/images/oto_image.png"),
              package: s != null ? null : "kosmos_chat",
              fit: BoxFit.cover),
          placeholder: (context, url) => Image.asset(
              s ??
                  (widget.data.isGroup
                      ? "assets/images/group_image.png"
                      : "assets/images/oto_image.png"),
              package: s != null ? null : "kosmos_chat",
              fit: BoxFit.cover),
        );
      }
    }

    return Container(
      width: widget.theme?.tchatRowIconSize?.width ?? formatWidth(51),
      height: widget.theme?.tchatRowIconSize?.height ?? formatWidth(51),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: DefaultColor.lowBlue,
        borderRadius: BorderRadius.circular(
            widget.theme?.tchatRowIconSize?.width ?? formatWidth(51)),
      ),
      child: c,
    );
  }

  Widget _buildSubContentText(BuildContext context) {
    final r = ref
        .watch(statusProvider)
        .getTchatingStatus(widget.data.id!, widget.data.isGroup);

    String? s = r?.status.getStatusEvent();
    if (!widget.data.isGroup && widget.data.blockedByUsers.isNotEmpty) {
      s = null;
    }
    if (s != null) {
      return Text(s.tr(),
          style: widget.theme?.tchatRowEventStyle ??
              widget.theme?.tchatRowEventMessageStyle);
    }

    if (widget.data.deletedMessageHistory
        .containsKey(FirebaseAuth.instance.currentUser!.uid)) {
      if (widget
              .data
              .deletedMessageHistory[FirebaseAuth.instance.currentUser!.uid]!
              .mostRecentDeletedMessageId ==
          widget.data.lastMessage?.id) {
        if (widget
                .data
                .deletedMessageHistory[FirebaseAuth.instance.currentUser!.uid]!
                .lastMessage ==
            null) {
          return Text(
            "package.tchat.list.new-conversation".tr(),
            style: widget.theme?.tchatRowLastMessageStyle,
            maxLines: 2,
          );
        } else {
          return PreviewBuilder.previewBuilder(
              context,
              ref,
              widget
                  .data
                  .deletedMessageHistory[
                      FirebaseAuth.instance.currentUser!.uid]!
                  .lastMessage!,
              widget.data);
        }
      }
    }
    if (widget.data.lastMessage == null ||
        (widget.data.lastMessage!.sendAt != null &&
            (widget.data.deletedBy
                    ?.where((element) =>
                        element.userId ==
                            FirebaseAuth.instance.currentUser!.uid &&
                        (element.deletedAt
                                ?.isAfter(widget.data.lastMessage!.sendAt!) ??
                            false))
                    .isNotEmpty ??
                false))) {
      return Text(
        "package.tchat.list.new-conversation".tr(),
        style: widget.theme?.tchatRowLastMessageStyle,
        maxLines: 2,
      );
    }

    if (widget.data.closed == true) {
      return Text(
        "package.tchat.list.closed-conversation".tr(),
        style: widget.theme?.tchatRowLastMessageStyle,
        maxLines: 2,
      );
    }

    return PreviewBuilder.previewBuilder(
        context, ref, widget.data.lastMessage!, widget.data);
  }

  List<Widget> _buildEndAction(BuildContext context) {
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
                      widget.actionMoreEvent?.call(context, ref, widget.data);
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
              Center(
                child: Builder(builder: (_) {
                  return InkWell(
                    onTap: () async {
                      await Slidable.of(context)?.close();

                      if (mounted) {
                        widget.actionDeleteEvent?.call(context, widget.data);
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

  Widget _buildDate(BuildContext context, bool lastMessageSeen) {
    final date = widget.data.lastMessage?.sendAt ?? DateTime.now();
    final Duration diff = DateTime.now().difference(date);
    String? dateString;
    if (Localizations.localeOf(context).languageCode != 'fr') {
      final hour = date.hour > 12 ? date.hour - 12 : date.hour;
      final period = date.hour >= 12 ? "PM" : "AM";
      dateString =
          "${hour.toString().padLeft(2, "0")}:${date.minute.toString().padLeft(2, "0")} $period";
    } else {
      dateString =
          "${date.hour.toString().padLeft(2, "0")}:${date.minute.toString().padLeft(2, "0")}";
    }

    if (diff.inDays > 1) {
      dateString = "date.locale-format".tr(namedArgs: {
        "day": date.day.toString().padLeft(2, "0"),
        "month": date.month.toString().padLeft(2, "0"),
        "year": date.year.toString(),
      });
    }
    return Text(dateString, style: widget.theme?.tchatRowTimeAgoStyle);
  }

  Widget _buildDateWithDiff(BuildContext context, bool lastMessageSeen) {
    final date = widget.data.lastMessage?.sendAt ?? DateTime.now();
    final Duration diff = DateTime.now().difference(date);

    // Initialize dateString to handle different time formats
    String dateString;

    if (diff.inSeconds < 60) {
      // For messages sent less than a minute ago, show "now"
      dateString = "app.duration.now".tr();
      return Text(dateString, style: widget.theme?.tchatRowTimeAgoStyle);
    } else if (diff.inDays > 0) {
      // For messages older than 1 day, show the date
      dateString = "date.locale-format".tr(namedArgs: {
        "day": date.day.toString().padLeft(2, '0'),
        "month": date.month.toString().padLeft(2, '0'),
        "year": date.year.toString(),
      });
      return Text(dateString, style: widget.theme?.tchatRowTimeAgoStyle);
    } else {
      return Timeago(
        refreshRate: const Duration(minutes: 1),
        date: date,
        builder: (_, __) {
          final Duration diff0 = DateTime.now().difference(date);
          if (diff0.inHours > 0) {
            // For messages sent today but more than an hour ago, show hours
            dateString = '${diff0.inHours}h';
          } else {
            // For messages sent less than an hour ago, show minutes
            dateString = '${diff0.inMinutes}min';
          }

          return Text(dateString, style: widget.theme?.tchatRowTimeAgoStyle);
        },
      );
    }
  }
}
