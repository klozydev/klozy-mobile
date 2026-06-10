
import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:core_kosmos/core_kosmos.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:kosmos_chat/backend/controller/status_controller.dart';
import 'package:kosmos_chat/backend/provider/message_list.dart';
import 'package:kosmos_chat/backend/provider/status.dart';
import 'package:kosmos_chat/backend/provider/tchat_user_data.dart';
import 'package:kosmos_chat/backend/utils/utils.dart';
import 'package:kosmos_chat/frontend/widget/components/bottom_message_bar.dart';
import 'package:kosmos_chat/frontend/widget/components/reply_content.dart';
import 'package:kosmos_chat/frontend/widget/components/warning_box.dart';
import 'package:kosmos_chat/kosmos_chat.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sticky_headers/sticky_headers.dart';
import 'package:ui_kosmos_v4/checkbox/checkbox.dart';
import 'package:ui_kosmos_v4/ui_kosmos_v4.dart';

final scrollProvider = Provider<ScrollData>((ref) {
  return ScrollData();
});

final selectStatusProvider = StateProvider<bool>((ref) {
  return false;
});

class ScrollData {
  ScrollController? controller;

  ScrollData({this.controller});

  void init(ScrollController c) => controller = c;
}

/// {@category Widget}
/// {@category Tchat}
///
/// Ce widget permet d'afficher la liste des messages
/// d'un tchat.
/// Vous pouvez configurer les différents affichages :
///
/// - [showHeader] : Affiche ou non l'entête du tchat
/// - [headerBuilder] : Permet de personnaliser l'entête
/// du tchat.
/// - [showCallButton] : Affiche ou non le bouton d'appel
/// - [showVideoCallButton] : Affiche ou non le bouton
/// d'appel vidéo.
/// - [showTchatAction] : Affiche ou non le bouton d'action
/// sur le tchat.
///
/// Lorsque vous cliquez sur les informations du tchat, dans
/// le header, vous pouvez définir un événement via
/// [onTchatNameOrPhotoClick].
/// Dans le cas ou le tchat est de type [TchatType.oneToOne],
/// le click est sur l'image de profil et le nom du tchat.
/// Dans le cas ou le tchat est de type [TchatType.group],
/// le click est sur l'image de profil et le nom du tchat.
///
/// Par défaut les messages sont wrapper dans une [MessageBox],
/// toutefois, vous pouvez personnaliser l'affichage des
/// messages via [messageBuilder].
///
/// Vous pouvez fournir un thème via la clé "tchat_message_theme"
/// ou via la clé [themeName]. Vous pouvez également
/// fournir un thème [TchatMessageThemeData] via la clé [theme].
class MessageViewWidget extends StatefulHookConsumerWidget {
  final TchatModel tchat;

  /// Config
  final bool showHeader;
  final Widget Function(BuildContext, WidgetRef, TchatModel)? headerBuilder;
  final bool showCallButton;
  final bool showVideoCallButton;
  final bool showTchatAction;

  /// Builder
  final Widget Function(BuildContext, WidgetRef, TchatModel, MessageModel)?
      messageBuilder;

  /// Event
  final void Function(BuildContext, TchatModel, [List<SocialUser>?])?
      onTchatNameClick;
  final void Function(BuildContext, TchatModel, [List<SocialUser>?])?
      onTchatPhotoClick;
  final FutureOr<void> Function(BuildContext, WidgetRef, TchatModel)?
      onTapTchatActions;
  final FutureOr<void> Function(BuildContext, WidgetRef, TchatModel,
      [List<SocialUser>?])? onTapAudioCall;
  final FutureOr<void> Function(BuildContext, WidgetRef, TchatModel,
      [List<SocialUser>?])? onTapVideoCall;

  /// Default event
  final void Function(WidgetRef, BuildContext, TchatModel)? reportAndLockEvent;
  final void Function(WidgetRef, TchatModel)? unLockEvent;
  final FutureOr<void> Function(WidgetRef, TchatModel)? deleteEvent;

  /// Theme
  final String? themeName;
  final TchatMessageThemeData? theme;

  const MessageViewWidget({
    super.key,
    required this.tchat,
    this.showHeader = true,
    this.headerBuilder,
    this.showCallButton = false,
    this.showVideoCallButton = false,
    this.showTchatAction = true,

    /// Builder
    this.messageBuilder,

    /// Event
    this.onTchatNameClick,
    this.onTchatPhotoClick,
    this.onTapTchatActions,
    this.onTapAudioCall,
    this.onTapVideoCall,

    /// Default event
    this.reportAndLockEvent,
    this.deleteEvent,
    this.unLockEvent,

    /// Theme
    this.themeName,
    this.theme,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _MessageViewWidgetState();
}

class _MessageViewWidgetState extends ConsumerState<MessageViewWidget>
    with WidgetsBindingObserver {
  

  List<SocialUser> userList = [];
  SocialUser? otherUser;
  final ScrollController _scrollController = ScrollController();

  final Map<String, GlobalKey> _messageKey = {};

  int startIndex = 0;
  int endIndex = 50;
  int messagesPerLoad = 50;

  List<MessageModel> selectedMessage = [];
  ValueNotifier<bool> show = ValueNotifier(false);

  @override
  void dispose() {
    /// Défini le statut de l'utilisateur en [TchatingStatus.offline]
    StatusController.setStatus(widget.tchat.id!, TchatingStatus.offline);

    _scrollController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void initState() {
    ref.read(scrollProvider).init(_scrollController);
    _scrollController.addListener(_scrollListener);

    /// Mets à jour l'utilisateur en [TchatingStatus.online]
    /// pour le tchat actuel
    StatusController.setStatus(widget.tchat.id!, TchatingStatus.online);

    /// Initialise les données des utilisateurs du tchat.
    final prov = ref.read(tchatUserListProvider);
    userList.clear();
    for (final element in widget.tchat.participants) {
      final u = prov.getById(element);
      if (u != null) userList.add(u);
    }
    if (widget.tchat.type == TchatType.oneToOne) {
      otherUser = userList.firstWhereOrNull(
          (element) => element.id != FirebaseAuth.instance.currentUser!.uid);
    }

    WidgetsBinding.instance.addObserver(this);
    _scrollController.addListener(() {
      if (_scrollController.hasClients &&
          _scrollController.offset > 100 &&
          !show.value) {
        show.value = true;
      } else if (_scrollController.hasClients &&
          _scrollController.offset < 100 &&
          show.value) {
        show.value = false;
      }
    });
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      /// Mets à jour l'utilisateur en [TchatingStatus.online]
      /// pour le tchat actuel
      StatusController.setStatus(widget.tchat.id!, TchatingStatus.online);
    } else {
      /// Mets à jour l'utilisateur en [TchatingStatus.offline]
      /// pour le tchat actuel
      StatusController.setStatus(widget.tchat.id!, TchatingStatus.offline);
    }
  }

  void _scrollListener() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.offset >=
            (_scrollController.position.maxScrollExtent - 150) &&
        !_scrollController.position.outOfRange) {
      setState(() {
        startIndex = endIndex;
        endIndex += messagesPerLoad;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    late final TchatMessageThemeData themeData = loadThemeData(
      widget.theme,
      widget.themeName ?? "tchat_message_theme",
      () => kDefaultTchatMessageTheme,
      isDark: ref.watch(isDarkModeProvider).isDarkMode);
  late final TchatThemeData tchatThemeData =
      loadThemeData(null, "tchat_theme", () => kDefaultTchatTheme,
      isDark: ref.watch(isDarkModeProvider).isDarkMode,       );
  late final MessageBoxThemeData messageThemeData =
      loadThemeData(null, "message_box", () => kDefaultMessageBoxThemeData,
      isDark: ref.watch(isDarkModeProvider).isDarkMode,       );
    /// Initialise les données des utilisateurs du tchat.
    final prov = ref.watch(tchatUserListProvider);
    userList.clear();
    for (final element in widget.tchat.participants) {
      final u = prov.getById(element);
      if (u == null) {
        ref.read(tchatUserListProvider).loadUserData(element);
      } else {
        userList.add(u);
      }
    }
    if (widget.tchat.type == TchatType.oneToOne) {
      otherUser = userList.firstWhereOrNull(
          (element) => element.id != FirebaseAuth.instance.currentUser!.uid);
    }

    getTchatBackEndConfig().tchatInterface.setLastMessageRead(widget.tchat.id!);

    /// Refresh les données des utilisateurs du tchat.
    /// Uniquement s'il n'y pas de données ou si le
    /// tchat est de type [TchatType.group].
    if (userList.isEmpty || widget.tchat.type == TchatType.group) {
      final prov = ref.read(tchatUserListProvider);
      userList.clear();
      for (final element in widget.tchat.participants) {
        final u = prov.getById(element);
        if (u != null) userList.add(u);
      }

      if (widget.tchat.type == TchatType.oneToOne) {
        otherUser = userList.firstWhereOrNull(
            (element) => element.id != FirebaseAuth.instance.currentUser!.uid);
      }
    }

    /// Charge les messages du tchat.
    final messages = ref.watch(messageListProvider).messages;

    bool isIBlockedOtherUser = false;
    bool isDiscussionBLocked = false;
    final otherId = widget.tchat.participants.firstWhereOrNull(
        (element) => element != FirebaseAuth.instance.currentUser!.uid);

    if (ref.watch(userProvider).metadata!.bloquedUsers.contains(otherId) &&
        !widget.tchat.isGroup) {
      isIBlockedOtherUser = true;
    }

    if (widget.tchat.blockedByUsers.isNotEmpty && !widget.tchat.isGroup) {
      isDiscussionBLocked = true;
    }

    /// Affiche la page avec la liste des messages.
    return LayoutBuilder(builder: (_, c) {
      return SizedBox(
        height: c.biggest.height,
        width: c.biggest.width,
        child: Stack(
          children: [
            if (themeData.background != null)
              SizedBox(
                height: c.biggest.height,
                width: c.biggest.width,
                child: themeData.background,
              ),
            SizedBox(
              height: c.biggest.height,
              width: c.biggest.width,
              child: InkWell(
                onTap: () {
                  FocusScope.of(context).unfocus();
                  if (showEmojiPicker) {
                    setState(() {
                      showEmojiPicker = false;
                    });
                  }
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: c.biggest.width,
                      child: _buildHeader(
                          context, isDiscussionBLocked, isIBlockedOtherUser, tchatThemeData, messageThemeData, themeData),
                    ),
                    Expanded(
                      child: widget.tchat.closed
                          ? _buildClosedTchat(context, tchatThemeData)
                          : messages == null
                              ? _buildShimmerLoading(context, tchatThemeData)
                              : messages.isEmpty
                                  ? _buildEmptyMessage(context, tchatThemeData)
                                  : LayoutBuilder(builder: (_, c) {
                                      return SizedBox(
                                        width: c.maxWidth,
                                        height: c.maxHeight,
                                        child: Stack(
                                          children: [
                                            Positioned.fill(
                                              child: Scrollbar(
                                                controller: ref
                                                    .read(scrollProvider)
                                                    .controller,
                                                child: ListView(
                                                  cacheExtent: 500,
                                                  controller: ref
                                                      .read(scrollProvider)
                                                      .controller,
                                                  padding: !widget.showHeader
                                                      ? EdgeInsets.only(
                                                          top: MediaQuery.of(
                                                                  context)
                                                              .padding
                                                              .top)
                                                      : null,
                                                  physics:
                                                      const AlwaysScrollableScrollPhysics(),
                                                  clipBehavior: Clip.none,
                                                  reverse: true,
                                                  children: _buildEventMessage(
                                                          context,
                                                          isIBlockedOtherUser,
                                                          tchatThemeData,
                                                          messageThemeData,
                                                          themeData)
                                                      .reversed
                                                      .toList(),
                                                ),
                                              ),
                                            ),
                                            ValueListenableBuilder(
                                                valueListenable: show,
                                                builder: (_, val, __) {
                                                  if (!val)
                                                    return const SizedBox();
                                                  return Positioned(
                                                    bottom: formatHeight(15),
                                                    right: 0,
                                                    child: InkWell(
                                                      onTap: () => ref
                                                          .read(scrollProvider)
                                                          .controller
                                                          ?.animateTo(0,
                                                              duration:
                                                                  const Duration(
                                                                      milliseconds:
                                                                          500),
                                                              curve: Curves
                                                                  .easeInOut),
                                                      child: Container(
                                                        padding: themeData
                                                            .scrollDownButtonPadding,
                                                        decoration: themeData
                                                            .scrollDownButtonDecoration,
                                                        child: Container(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  formatWidth(
                                                                      4)),
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        r(100)),
                                                            border: Border.all(
                                                                color: themeData
                                                                        .scrollDownButtonColor ??
                                                                    Theme.of(
                                                                            context)
                                                                        .primaryColor,
                                                                width: 2),
                                                          ),
                                                          child: Icon(
                                                            Icons
                                                                .keyboard_arrow_down_rounded,
                                                            color: themeData
                                                                    .scrollDownButtonColor ??
                                                                Theme.of(
                                                                        context)
                                                                    .primaryColor,
                                                            size:
                                                                formatWidth(22),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                }),
                                          ],
                                        ),
                                      );
                                    }),
                    ),
                    BottomMessageBar(
                      tchat: widget.tchat,
                      messageSendCallback:
                          ref.read(messageListProvider).sendTextMessage,
                      isSendMessageBlocked: isDiscussionBLocked,
                      currentUserBlockedOther: isIBlockedOtherUser,
                      unLockEvent: widget.unLockEvent,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: c.biggest.width,
              child: _buildHeader(
                  context, isDiscussionBLocked, isIBlockedOtherUser, tchatThemeData, messageThemeData, themeData),
            ),
          ],
        ),
      );
    });
  }

  /// Shimmer animation tant que la liste de message
  /// est null.
  Widget _buildShimmerLoading(BuildContext context,TchatThemeData tchatThemeData  ) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      reverse: true,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: formatWidth(26))
            .copyWith(bottom: formatHeight(12)),
        child: Shimmer.fromColors(
          baseColor:
              tchatThemeData.tchatListShimmerBaseColor ?? Colors.grey.shade300,
          highlightColor: tchatThemeData.tchatListShimmerHighlightColor ??
              Colors.grey.shade200,
          direction: ShimmerDirection.ltr,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: formatWidth(243),
                height: formatHeight(70),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(11)
                      .copyWith(bottomLeft: const Radius.circular(1)),
                ),
              ),
              sh(7),
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  width: formatWidth(243),
                  height: formatHeight(70),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(11),
                  ),
                ),
              ),
              sh(3),
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  width: formatWidth(243),
                  height: formatHeight(70),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(11)
                        .copyWith(bottomRight: const Radius.circular(1)),
                  ),
                ),
              ),
              sh(7),
              Container(
                width: formatWidth(243),
                height: formatHeight(70),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(11)
                      .copyWith(bottomLeft: const Radius.circular(1)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// En-Tête de la page, contenant par défaut le bouton
  /// de retour, l'information (photo / nom) du tchat,
  /// ainsi que les boutons d'appel, et d'action sur le tchat.
  Widget _buildHeader(BuildContext context, bool isTchatBlocked,
      bool isCurrentUserBlockedOrtherUser,
      TchatThemeData tchatThemeData,
      MessageBoxThemeData messageThemeData,
      TchatMessageThemeData themeData,
      [bool isActive = true]) {
    if (!widget.showHeader) return const SizedBox.shrink();

    final c = widget.headerBuilder?.call(context, ref, widget.tchat);
    if (c != null) return c;

    final status = ref
        .watch(statusProvider)
        .getTchatingStatus(widget.tchat.id!, widget.tchat.isGroup);
    String? statusString = status?.status == TchatingStatus.offline
        ? chatStatus(status!.lastUpdate!)
        : status?.status.getStatusTchatEvent()?.tr(args: [status.userId]);

    if (status != null &&
        widget.tchat.isGroup &&
        statusString != null &&
        status.status != TchatingStatus.multipleOnline) {
      SocialUser? user =
          userList.firstWhereOrNull((p0) => p0.id == status.userId);
      final userName = user?.pseudo ?? user?.firstname ?? user?.lastname;
      if (userName != null) {
        statusString = "$userName $statusString";
      }
    }

    return Container(
      decoration: themeData.tchatHeaderDecoration ??
          BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
          ),
      width: double.infinity,
      padding: themeData.tchatHeaderPadding ??
          EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + formatHeight(6),
              bottom: formatHeight(8)),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          ButtonBack(
            padding:
                EdgeInsets.only(left: formatWidth(6.5), right: formatWidth(1)),
            onTap: () {
              AutoRouter.of(context).pop();
              showEmojiPicker = false;
            },
          ),
          sw(themeData.spacingBetweenBackButtonAndPicture ?? 3),
          Expanded(
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                if (getTchatFrontEndConfig().message.showTchatPicture) ...[
                  InkWell(
                    onTap: () {
                      if (widget.onTchatPhotoClick != null) {
                        widget.onTchatPhotoClick?.call(context, widget.tchat);
                        return;
                      }
                      AutoRouter.of(context).pop();
                    },
                    child: (isActive)
                        ? _buildTchatImage(context, isTchatBlocked, tchatThemeData, themeData)
                        : _buildTchatImage(context, isTchatBlocked, tchatThemeData, themeData),
                  ),
                  sw(themeData.spacingBetweenPictureAndName ?? 9),
                ] else ...[
                  sw(10),
                ],
                Expanded(
                  child: InkWell(
                    onTap: () {
                      if (widget.onTchatNameClick != null) {
                        widget.onTchatNameClick?.call(context, widget.tchat);
                        return;
                      }
                      AutoRouter.of(context).pop();
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.tchat.isGroup
                              ? widget.tchat.tchatName?.tr() ?? ""
                              : (otherUser?.pseudo?.isNotEmpty == true
                                      ? otherUser?.pseudo
                                      : otherUser?.firstname.isNotEmpty == true
                                          ? otherUser?.firstname
                                          : "package.tchat.user-deleted"
                                              .tr()) ??
                                  "package.tchat.user-deleted".tr(),
                          style: themeData.nameTextStyle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (!isTchatBlocked)
                          SizedBox(
                            height: (statusString != null) ? null : 0,
                            child: Transform.translate(
                              offset: const Offset(0, -2),
                              child: Text((statusString?.tr() ?? ""),
                                  style: themeData.statusTextStyle,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (widget.showVideoCallButton) ...[
            sw(10),
            InkWell(
              onTap: () async => await widget.onTapVideoCall
                  ?.call(context, ref, widget.tchat, userList),
              child: SvgPicture.asset(
                "assets/svg/ic_video_call.svg",
                color: themeData.actionCallColor,
                package: "kosmos_chat",
              ),
            ),
          ],
          if (widget.showCallButton) ...[
            sw(10),
            InkWell(
              onTap: () async => await widget.onTapAudioCall
                  ?.call(context, ref, widget.tchat, userList),
              child: SvgPicture.asset(
                "assets/svg/ic_audio_call.svg",
                color: themeData.actionCallColor,
                package: "kosmos_chat",
              ),
            ),
          ],
          if (widget.showTchatAction)
            InkWell(
              onTap: () async {
                if (widget.onTapTchatActions != null) {
                  try {
                    await widget.onTapTchatActions
                        ?.call(context, ref, widget.tchat);
                  } catch (e) {
                    if (e is UnimplementedError) {
                      return await _defaultActionEvent(context, widget.tchat,
                          isCurrentUserBlockedOrtherUser);
                    }
                    printExcept(e);
                  }
                  return;
                }
                await _defaultActionEvent(
                    context, widget.tchat, isCurrentUserBlockedOrtherUser);
                setState(() {});
              },
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: formatWidth(10)),
                child: Icon(Icons.more_horiz_rounded,
                    size: formatWidth(26),
                    color: themeData.actionButtonMoreColor),
              ),
            )
          else
            sw(10),
          if (selectedMessage.isNotEmpty) ...[
            InkWell(
              onTap: () async =>
                  _buildEventMessageOnPress(context, ref, selectedMessage),
              child: Padding(
                padding: pw(5),
                child: SvgPicture.asset("assets/svg/ic_delete.svg",
                    package: "kosmos_chat",
                    color: themeData.deleteMessageIconColor ??
                        DefaultColor.error),
              ),
            )
          ],
          sw(13.5),
        ],
      ),
    );
  }

  Widget _buildTchatImage(BuildContext context, bool isIBlockedOtherUser, TchatThemeData tchatThemeData,  TchatMessageThemeData themeData) {
    final String? s = widget.tchat.isGroup
        ? tchatThemeData.tchatRowGroupDefaultAsset
        : tchatThemeData.tchatRowOtoDefaultAsset;

    Widget c = Image.asset(
        s ??
            (widget.tchat.isGroup
                ? "assets/images/group_image.png"
                : "assets/images/oto_image.png"),
        package: s != null ? null : "kosmos_chat",
        fit: BoxFit.cover);
    String? item;

    if (widget.tchat.tchatPicture != null) {
      item = widget.tchat.tchatPicture;
    } else if (widget.tchat.type == TchatType.oneToOne &&
        widget.tchat.tchatPicture == null) {
      if (otherUser != null &&
          (otherUser?.profileImage != null ||
              otherUser?.userProfileImage != null)) {
        item = otherUser?.profileImage ??
            otherUser?.userProfileImage?.compressedUrl ??
            otherUser?.userProfileImage?.url;
      }
    }
    if (item != null) {
      c = CachedNetworkImage(
        imageUrl: item,
        fit: BoxFit.cover,
        errorWidget: (context, url, error) => Image.asset(
            s ??
                (widget.tchat.isGroup
                    ? "assets/images/group_image.png"
                    : "assets/images/oto_image.png"),
            package: s != null ? null : "kosmos_chat",
            fit: BoxFit.cover),
        placeholder: (context, url) => Image.asset(
            s ??
                (widget.tchat.isGroup
                    ? "assets/images/group_image.png"
                    : "assets/images/oto_image.png"),
            package: s != null ? null : "kosmos_chat",
            fit: BoxFit.cover),
      );
    }

    return Container(
      width: themeData.profilImageSize?.width ?? formatWidth(55),
      height: themeData.profilImageSize?.height ?? formatWidth(55),
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: DefaultColor.lowBlue,
        shape: BoxShape.circle,
      ),
      child: c,
    );
  }

  List<Widget> _buildEventMessage(
      BuildContext context, bool isIBlockedOtherUser,
      TchatThemeData tchatThemeData, MessageBoxThemeData messageThemeData,
      TchatMessageThemeData themeData) {
    final messageList = List<MessageModel>.from(
        (ref.watch(messageListProvider).messages ?? []));

    MessageModel? prevMessage, nextMessage;
    bool fromMe = false;
    final uuid = FirebaseAuth.instance.currentUser!.uid;

    List<Widget> ret = List.from([]);
    List<Widget> slivers = [];

    final length = messageList.length;

    for (final message in messageList) {
      final index = messageList.indexOf(message);
      if (index < (length - endIndex)) continue;
      if (index == endIndex - 1) {
        ret.add(const Center(child: LoaderClassique()));
      }

      GlobalKey key = GlobalKey();
      _messageKey[message.id!] = key;

      bool nextDate = true;
      if (messageList.last != message) {
        nextMessage = messageList[messageList.indexOf(message) + 1];
        nextDate = nextMessage.sendAt != null &&
            message.sendAt != null &&
            !nextMessage.sendAt!.isSameDay(message.sendAt!);
        if (nextMessage.messageType == "event") nextMessage = null;
      } else {
        nextMessage = null;
      }

      fromMe = message.senderId == uuid;
      final bool sameDate = prevMessage != null &&
          prevMessage.sendAt != null &&
          message.sendAt != null &&
          prevMessage.sendAt!.isSameDay(message.sendAt!);

      final Widget child =
          widget.messageBuilder?.call(context, ref, widget.tchat, message) ??
              MessageBox(
                theme: messageThemeData,
                key: key,
                tchat: widget.tchat,
                message: message,
                onTapReplyTo: (mes) {
                  if (mes.replyTo == null) return;
                  final key = _messageKey[mes.replyTo!.id!]?.currentContext;
                  if (key == null) return;
                  Scrollable.ensureVisible(key,
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut);
                },
                previousMessage: prevMessage,
                nextMessage: !nextDate ? nextMessage : null,
              );

      if (!sameDate && message.sendAt != null) {
        final now = DateTime.now();
        final isToday = prevMessage?.sendAt?.isSameDay(now) ?? false;
        final isYesterday = prevMessage?.sendAt
                ?.isSameDay(now.subtract(const Duration(days: 1))) ??
            false;
        if (prevMessage != null && prevMessage.sendAt != null) {
          ret.add(
              sh(messageThemeData.spacingBetweenMessage ?? formatHeight(7)));

          slivers.add(
            StickyHeader(
              header: Padding(
                padding: EdgeInsets.symmetric(
                    vertical: messageThemeData.spacingBetweenMessage ??
                        formatHeight(7)),
                child: WarningMessageBox(
                  decoration: themeData.dateDecoration,
                  message: MessageModel(
                    tchatId: widget.tchat.id!,
                    senderId: "tchat_${widget.tchat.id!}",
                    messageType: "event",
                    content:
                        "package.tchat.message.${isToday ? "today" : isYesterday ? "yesterday" : "date"}",
                    metadata: {
                      "event_data": {
                        "weekday":
                            "date.day-by-id.${prevMessage.sendAt!.weekday}"
                                .tr(),
                        "day": prevMessage.sendAt!.day.toString(),
                        "month": "date.month-by-id.${prevMessage.sendAt!.month}"
                            .tr(),
                      }
                    },
                  ),
                ),
              ),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: ret,
              ),
            ),
          );
        }
        ret = List.from([]);
      }

      if (prevMessage != null) {
        ret.add(SizedBox(
          height: (prevMessage.senderId == message.senderId && sameDate)
              ? (messageThemeData.spacingBetweenSameSenderMessage ??
                  formatHeight(3))
              : (messageThemeData.spacingBetweenMessage ?? formatHeight(7)),
        ));
      }

      if (message.messageType == "event") {
        ret.add(Padding(
          padding: ph(messageThemeData.spacingBetweenMessage ?? 7),
          child: WarningMessageBox(message: message),
        ));

        continue;
      }

      GlobalKey<CustomCheckBoxState> checkBoxKey = GlobalKey();

      bool canMessageBeDeleted = (getTchatFrontEndConfig()
                      .message
                      .messageConfig
                      .messageCantBeDeleted ??
                  [])
              .contains(message.messageType) ==
          false;
      ret.add(
        IntrinsicHeight(
          child: Stack(
            children: [
              Padding(
                padding: themeData.messageListPadding ?? EdgeInsets.zero,
                key: ValueKey(message.hashCode),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    if (selectedMessage.isNotEmpty && canMessageBeDeleted)
                      Padding(
                        padding: EdgeInsets.only(right: formatWidth(14)),
                        child: CustomCheckBox(
                          key: checkBoxKey,
                          isChecked: selectedMessage.contains(message),
                          type: CheckboxType.square,
                          borderRadius: 100,
                          onChanged: (isChecked) {
                            if (isChecked) {
                              selectedMessage.add(message);
                              ref.read(selectStatusProvider.notifier).state =
                                  true;
                            } else {
                              selectedMessage.remove(message);
                              if (selectedMessage.isEmpty) {
                                ref.read(selectStatusProvider.notifier).state =
                                    false;
                              }
                            }
                            setState(() {});
                          },
                        ),
                      ),
                    Expanded(
                      child: Swipeable(
                        onSwipeLeft: () {
                          HapticFeedback.heavyImpact();
                          ref.read(messageListProvider).setReplyTo(message);
                        },
                        onSwipeRight: () {
                          HapticFeedback.heavyImpact();
                          ref.read(messageListProvider).setReplyTo(message);
                        },
                        mainAxisAlignment: fromMe
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                        direction:
                            fromMe ? ReplyDirection.left : ReplyDirection.right,
                        background: Row(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: fromMe
                              ? MainAxisAlignment.end
                              : MainAxisAlignment.start,
                          children: [
                            sw(45),
                            SvgPicture.asset(
                              "assets/svg/ic_reply.svg",
                              color: messageThemeData.replyToIconColor,
                              package: "kosmos_chat",
                            ),
                            sw(45),
                          ],
                        ),
                        child: GestureDetector(
                          onTap: canMessageBeDeleted
                              ? () {
                                  if (selectedMessage.isNotEmpty) {
                                    if (selectedMessage.contains(message)) {
                                      selectedMessage.remove(message);
                                      checkBoxKey.currentState
                                          ?.changeState(false);
                                      if (selectedMessage.isEmpty) {
                                        ref
                                            .read(selectStatusProvider.notifier)
                                            .state = false;
                                      }
                                    } else {
                                      selectedMessage.add(message);
                                      checkBoxKey.currentState
                                          ?.changeState(true);
                                      ref
                                          .read(selectStatusProvider.notifier)
                                          .state = true;
                                    }
                                    setState(() {});
                                  }
                                }
                              : null,
                          onLongPress: canMessageBeDeleted
                              ? () {
                                  if (selectedMessage.isEmpty) {
                                    ref
                                        .read(selectStatusProvider.notifier)
                                        .state = true;
                                    selectedMessage.add(message);
                                    checkBoxKey.currentState?.changeState(true);
                                    setState(() {});
                                  }
                                }
                              : null,
                          child: child,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (selectedMessage.isNotEmpty &&
                  selectedMessage.contains(message))
                Positioned.fill(
                  child: InkWell(
                    onTap: () {
                      selectedMessage.remove(message);
                      checkBoxKey.currentState?.changeState(false);
                      if (selectedMessage.isEmpty) {
                        ref.read(selectStatusProvider.notifier).state = false;
                      }
                      setState(() {});
                    },
                    child: Container(
                        color: themeData.selectedMessageOverlayColor ??
                            Theme.of(context).primaryColor.withOpacity(0.1)),
                  ),
                ),
            ],
          ),
        ),
      );

      prevMessage = message;
    }

    final now = DateTime.now();
    final isToday = messageList.isNotEmpty
        ? (messageList.last.sendAt ?? now).isSameDay(now)
        : false;
    final isYesterday = messageList.isNotEmpty
        ? messageList.last.sendAt
                ?.isSameDay(now.subtract(const Duration(days: 1))) ??
            false
        : false;

    slivers.add(
      StickyHeader(
        header: Padding(
          padding: EdgeInsets.symmetric(
              vertical:
                  messageThemeData.spacingBetweenMessage ?? formatHeight(7)),
          child: WarningMessageBox(
            decoration: themeData.dateDecoration,
            message: MessageModel(
              tchatId: widget.tchat.id!,
              senderId: "tchat_${widget.tchat.id!}",
              messageType: "event",
              content:
                  "package.tchat.message.${isToday ? "today" : isYesterday ? "yesterday" : "date"}",
              metadata: {
                "event_data": {
                  "weekday":
                      "date.day-by-id.${(messageList.last.sendAt ?? now).weekday}"
                          .tr(),
                  "day": (messageList.last.sendAt ?? now).day.toString(),
                  "month":
                      "date.month-by-id.${(messageList.last.sendAt ?? now).month}"
                          .tr(),
                }
              },
            ),
          ),
        ),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: ret,
        ),
      ),
    );

    if (widget.tchat.type == TchatType.oneToOne) {
      if (widget.tchat.blockedByUsers.isNotEmpty) {
        ret.add(
          Padding(
            padding: ph(messageThemeData.spacingBetweenMessage ?? 7),
            child: WarningMessageBox(
              maxWidthSize: true,
              message: MessageModel(
                messageType: "event",
                senderId: "tchat_${widget.tchat.id!}",
                tchatId: widget.tchat.id!,
                content:
                    "package.tchat.message.blocked-by-${isIBlockedOtherUser ? "you" : "other"}",
              ),
            ),
          ),
        );
      }
    }

    ret.add(sh(18));

    return slivers;
  }

  Widget _buildEmptyMessage(BuildContext context, TchatThemeData tchatThemeData) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: formatWidth(30)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "package.tchat.message.no-message".tr(),
              textAlign: TextAlign.center,
              style: tchatThemeData.tchatListNoTchatStyle,
            ),
            sh(5),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: formatWidth(20)),
              child: Text(
                "package.tchat.message.no-message-body".tr(),
                textAlign: TextAlign.center,
                style: tchatThemeData.tchatListNoTchatContentStyle,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClosedTchat(BuildContext context, TchatThemeData tchatThemeData) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: formatWidth(30)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "package.tchat.closed.title".tr(),
              textAlign: TextAlign.center,
              style: tchatThemeData.tchatListNoTchatStyle,
            ),
            sh(5),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: formatWidth(20)),
              child: Text(
                "package.tchat.closed.subtitle".tr(),
                textAlign: TextAlign.center,
                style: tchatThemeData.tchatListNoTchatContentStyle,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Event lorsque que l'utilisateur appuie sur
  /// l'icone de suppression d'un message après
  /// en avoir sélectionné plusieurs.
  Future<void> _buildEventMessageOnPress(
      BuildContext context, WidgetRef ref, List<MessageModel> messages) async {
    bool onlyMyMessage = messages.firstWhereOrNull(
            (p0) => p0.senderId != FirebaseAuth.instance.currentUser?.uid) ==
        null;

    final t = await showCupertinoModalPopup<bool>(
      context: context,
      builder: (_) {
        return CupertinoActionSheet(
          message: Text("utils.what-do-you-want-to-do".tr()),
          cancelButton: CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(_),
            child: Text('utils.cancel'.tr()),
          ),
          actions: [
            CupertinoActionSheetAction(
              onPressed: () async {
                // get most recent message in tchat before delete
                MessageModel? lastMessageInChat = ref
                    .read(messageListProvider)
                    .messages
                    ?.mostRecentByDate((p0) => p0.sendAt!);
                MessageModel lastMessageDeleted = messages.mostRecentByDate(
                    (p0) => p0
                        .sendAt!)!; // get most recent message in selected messages

                if (lastMessageInChat?.id == lastMessageDeleted.id) {
                  // if the most recent message in tchat is the same as the most recent message in deleted messages
                  //do something
                  List<MessageModel> messagesAfterDelete =
                      ListUtilsFunctions.removeFromList<MessageModel>(
                          ref.read(messageListProvider).messages ?? [],
                          messages,
                          (element, elementToRemove) =>
                              element.id == elementToRemove.id);

                  if (messagesAfterDelete.isEmpty) {
                    try {
                      Map<String, dynamic> map = {};
                      map["deletedMessageHistory.${FirebaseAuth.instance.currentUser!.uid}"] =
                          {
                        "lastMessage": null,
                        "mostRecentDeletedMessageId": lastMessageDeleted.id,
                        "mostRecentDeletedMessageDate":
                            Timestamp.fromDate(DateTime.now()),
                      };
                      await FirebaseFirestore.instance
                          .collection("tchat")
                          .doc(widget.tchat.id)
                          .update(map);
                    } catch (e) {
                      rethrow;
                    }
                  } else {
                    MessageModel? lastMessageToShow = messagesAfterDelete
                        .mostRecentByDate((p0) => p0.sendAt!);
                    try {
                      Map<String, dynamic> map = {};
                      map["deletedMessageHistory.${FirebaseAuth.instance.currentUser!.uid}"] =
                          {
                        "mostRecentDeletedMessageId": lastMessageDeleted.id,
                        "lastMessage": lastMessageToShow?.toJson(),
                        "mostRecentDeletedMessageDate": Timestamp.fromDate(
                            lastMessageInChat?.sendAt ?? DateTime.now()),
                      };
                      await FirebaseFirestore.instance
                          .collection("tchat")
                          .doc(widget.tchat.id)
                          .update(map);
                    } catch (e) {
                      rethrow;
                    }
                  }
                } else {
                  //do nothing because the most recent message in tchat is not the same as the most recent message in deleted messages
                }
                // get list of messages after delete

                for (final message in messages) {
                  FirebaseFirestore.instance
                      .collection("tchat")
                      .doc(widget.tchat.id)
                      .collection("messages")
                      .doc(message.id)
                      .update({
                    "deleteBy": FieldValue.arrayUnion(
                        [FirebaseAuth.instance.currentUser!.uid]),
                  });
                }
                Navigator.pop(_, true);
              },
              isDestructiveAction: true,
              child: Text('package.tchat.event.delete-message'.tr()),
            ),
            if (onlyMyMessage)
              CupertinoActionSheetAction(
                onPressed: () async {
                  List<MessageModel> deletedMessages = [...messages];
                  try {
                    Navigator.pop(_, true);

                    MessageModel? lastMessageInChat = ref
                        .read(messageListProvider)
                        .messages
                        ?.mostRecentByDate((p0) => p0.sendAt!);
                    MessageModel lastMessageDeleted = messages.mostRecentByDate(
                        (p0) => p0
                            .sendAt!)!; // get most recent message in selected messages

                    if (lastMessageInChat?.id == lastMessageDeleted.id) {
                      await FirebaseFirestore.instance
                          .collection("tchat")
                          .doc(widget.tchat.id)
                          .update({
                        "lastMessage": MessageModel(
                                tchatId: widget.tchat.id!,
                                senderId: lastMessageInChat!.senderId,
                                messageType: "deleted-message",
                                sendAt: DateTime.now())
                            .toJson(),
                      });
                    }
                  } catch (e) {
                    rethrow;
                  }

                  for (final message in deletedMessages) {
                    await FirebaseFirestore.instance
                        .collection("tchat")
                        .doc(widget.tchat.id)
                        .collection("messages")
                        .doc(message.id)
                        .delete();
                  }
                },
                isDestructiveAction: true,
                child: Text(
                    'package.tchat.event.delete-message-for-everyone'.tr()),
              ),
          ],
        );
      },
    );
    if (t ?? false) {
      setState(() {
        selectedMessage.clear();
      });
    }
  }

  Future<void> _defaultActionEvent(
      BuildContext context, TchatModel tchat, bool isIBlockedOtherUser) async {
    await showCupertinoModalPopup<void>(
      context: context,
      builder: (_) {
        return CupertinoActionSheet(
          message: Text("utils.what-do-you-want-to-do".tr()),
          cancelButton: CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(_),
            child: Text('utils.cancel'.tr()),
          ),
          actions: [
            if (tchat.isGroup)
              CupertinoActionSheetAction(
                onPressed: () async {
                  Navigator.pop(_);
                  if (widget.onTchatNameClick != null) {
                    widget.onTchatNameClick?.call(context, widget.tchat);
                    return;
                  }

                  // AutoRouter.of(context).pop();
                },
                child: Text('package.tchat.event.see-group'.tr()),
              ),
            if (!isIBlockedOtherUser &&
                !tchat.isGroup &&
                tchat.participants.length <= 2)
              CupertinoActionSheetAction(
                onPressed: () async {
                  widget.reportAndLockEvent?.call(ref, context, tchat);
                  Navigator.pop(_);
                },
                isDestructiveAction: true,
                child: Text('package.tchat.event.report-and-block'.tr()),
              )
            else if (isIBlockedOtherUser &&
                !tchat.isGroup &&
                tchat.participants.length <= 2)
              CupertinoActionSheetAction(
                onPressed: () async {
                  widget.unLockEvent?.call(ref, tchat);
                  Navigator.pop(_);
                },
                isDefaultAction: true,
                child: Text('utils.unlock'.tr()),
              ),
            CupertinoActionSheetAction(
              onPressed: () async {
                await widget.deleteEvent?.call(ref, tchat);
                if (!mounted) return;
                Navigator.pop(_);
                PopupAlert.toast(
                  context,
                  FToast().init(context),
                  title: "utils.success".tr(),
                  subtitle:
                      "package.tchat.info.conversation-deleted-success".tr(),
                  type: AlertType.success,
                );
                AutoRouter.of(context).pop();
              },
              // isDestructiveAction: true,
              child: Text(
                'package.tchat.event.delete-tchat'.tr(),
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}
