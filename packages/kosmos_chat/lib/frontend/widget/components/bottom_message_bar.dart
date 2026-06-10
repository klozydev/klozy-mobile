// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:io';

import 'package:core_kosmos/core_kosmos.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gesture_x_detector/gesture_x_detector.dart';
import 'package:kosmos_chat/backend/controller/status_controller.dart';
import 'package:kosmos_chat/backend/provider/media_sender.dart';
import 'package:kosmos_chat/backend/provider/message_list.dart';
import 'package:kosmos_chat/backend/provider/tchat_user_data.dart';
import 'package:kosmos_chat/frontend/utils/pick_image.dart';
import 'package:kosmos_chat/frontend/widget/components/message_builder.dart';
import 'package:kosmos_chat/kosmos_chat.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:shimmer/shimmer.dart';
import 'package:ui_kosmos_v4/notifBanner/notif_banner.dart';
import 'package:ui_kosmos_v4/ui_kosmos_v4.dart';
import 'package:uuid/uuid.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:dartz/dartz.dart' as dz;

bool showEmojiPicker = false;

class BottomMessageBar extends StatefulHookConsumerWidget {
  final TchatModel tchat;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final bool isSendMessageBlocked;
  final bool currentUserBlockedOther;
  final void Function(WidgetRef, TchatModel)? unLockEvent;

  /// CallBack
  final Future<void> Function(BuildContext, WidgetRef, TchatModel, String,
      [MessageModel?])? messageSendCallback;

  /// Theme
  final String? themeName;
  final TchatMessageThemeData? theme;

  const BottomMessageBar({
    super.key,
    required this.tchat,
    this.controller,
    this.focusNode,
    this.currentUserBlockedOther = false,
    this.isSendMessageBlocked = false,
    this.unLockEvent,

    /// Callback
    this.messageSendCallback,

    /// Theme
    this.themeName,
    this.theme,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _BottomMessageBarState();
}

class _BottomMessageBarState extends ConsumerState<BottomMessageBar> {
  final messageConfig = getTchatFrontEndConfig().message;
  late final TextEditingController _controller =
      widget.controller ?? TextEditingController();
  

  late final FocusNode _focusNode = widget.focusNode ?? FocusNode();

  late final ScrollController _scrollController = ScrollController();

  bool isAudioRecording = false;
  Offset? position;
  Offset? initialPosition;
  Duration? recDuration;
  Timer? timer;
  bool showDeleteAudio = false;
  String? _path;

  AudioRecorder record = AudioRecorder();

  @override
  void initState() {
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        setState(() {
          showEmojiPicker = false;
        });
      }
    });
    _controller.addListener(() {
      if (_controller.text.isNotEmpty) {
        if (widget.tchat.type == TchatType.group) {
          StatusController.setStatus(widget.tchat.id!, TchatingStatus.typing);
        } else if (widget.tchat.blockedByUsers.isEmpty) {
          StatusController.setStatus(widget.tchat.id!, TchatingStatus.typing);
        } else {
          StatusController.setStatus(widget.tchat.id!, TchatingStatus.offline);
        }
      } else {
        StatusController.setStatus(widget.tchat.id!, TchatingStatus.online);
      }
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
     final TchatMessageThemeData themeData = loadThemeData(
      widget.theme,
      widget.themeName ?? "tchat_message_theme",
      () => kDefaultTchatMessageTheme,
      isDark: ref.watch(isDarkModeProvider).isDarkMode,  );
    final MessageModel? replyTo = ref.watch(messageListProvider).replyTo;

    return Container(
      decoration: BoxDecoration(
          color: replyTo != null
              ? themeData.replyToBackgroundDecoration?.color
              : themeData.inputContainerDecoration?.color ??
                  Theme.of(context).scaffoldBackgroundColor,
          borderRadius: replyTo != null
              ? themeData.replyToBackgroundDecoration?.borderRadius
              : themeData.inputContainerDecoration?.borderRadius),
      child: Column(
        children: [
          messageConfig.bottomBuilder?.call(context, ref, widget.tchat) ??
              const SizedBox.shrink(),
          replyTo != null
              ? _buildReplyToPreview(context, replyTo, themeData)
              : const SizedBox.shrink(),
          Container(
            width: double.infinity,
            padding: themeData.contentPadding?.add(EdgeInsets.only(
                    bottom: showEmojiPicker
                        ? 0
                        : MediaQuery.of(context).padding.bottom)
                .add(EdgeInsets.only(top: formatHeight(4)))),
            decoration: BoxDecoration(
              borderRadius: themeData.borderRadius,
              boxShadow: themeData.shadows,
            ),
            child: _customTextField(context, replyTo != null, themeData),
          ),
          if (Platform.isAndroid)
            Offstage(
              offstage: !showEmojiPicker,
              child: SizedBox(
                height:
                    formatHeight(300) + MediaQuery.of(context).padding.bottom,
                child: Column(
                  children: [
                    Expanded(
                      child: EmojiPicker(
                        // config: Config(
                        //   backspaceColor: themeData.actionButtonColor ??
                        //       DefaultColor.lowGrey,
                        //   bgColor: DefaultColor.lowGrey,
                        // ),
                        onBackspacePressed: () {
                          if (_controller.text.isEmpty) return;
                          // remove last character
                          _controller.text = _controller.text
                              .substring(0, _controller.text.length - 1);
                        },
                        onEmojiSelected: (category, emoji) {
                          _controller.text += emoji.emoji;
                          SchedulerBinding.instance.addPostFrameCallback((_) =>
                              _controller.selection =
                                  TextSelection.fromPosition(TextPosition(
                                      offset: _controller.text.length)));
                        },
                      ),
                    ),
                    Container(
                        height: MediaQuery.of(context).padding.bottom,
                        width: double.infinity,
                        color: DefaultColor.lowGrey),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildReplyToPreview(BuildContext context, MessageModel replyTo, TchatMessageThemeData themeData) {
    return Container(
      width: double.infinity,
      padding: themeData.replyToBackgroundPadding,
      decoration: themeData.replyToBackgroundDecoration,
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: Container(
                decoration: themeData.replyToDecoration,
                clipBehavior: Clip.antiAlias,
                child: ReplyToBuilder.replyPreviewBuilder(
                    context, ref, replyTo, widget.tchat),
              ),
            ),
            InkWell(
              onTap: () => ref.read(messageListProvider).setReplyTo(null),
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: formatWidth(13), vertical: formatHeight(10)),
                child: Icon(Icons.close_rounded,
                    color: themeData.replyToIconColor, size: formatWidth(25)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _checkUnlockTchat(BuildContext context) async {
    bool rep = false;

    final otherId = widget.tchat.participants.firstWhere(
        (element) => element != FirebaseAuth.instance.currentUser!.uid);

    rep = await showCupertinoModalPopup<bool>(
          context: context,
          builder: (_) {
            return CupertinoActionSheet(
              message: Text("package.tchat.event.unlock".tr(args: [
                (ref
                        .read(tchatUserListProvider)
                        .userList
                        .firstWhereOrNull((p0) => p0.id == otherId)
                        ?.pseudo ??
                    ref
                        .read(tchatUserListProvider)
                        .userList
                        .firstWhereOrNull((p0) => p0.id == otherId)
                        ?.firstname ??
                    "")
              ])),
              cancelButton: CupertinoActionSheetAction(
                onPressed: () => Navigator.pop(_, false),
                child: Text('utils.cancel'.tr()),
              ),
              actions: [
                CupertinoActionSheetAction(
                  onPressed: () async {
                    Navigator.pop(_, true);
                    widget.unLockEvent?.call(ref, widget.tchat);
                  },
                  isDestructiveAction: true,
                  child: Text('utils.unlock'.tr()),
                ),
              ],
            );
          },
        ) ??
        false;

    return rep;
  }

  bool isPressed = false;

  Widget _customTextField(BuildContext context, bool isReplyTo, TchatMessageThemeData themeData) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (isAudioRecording)
              _buildAudioRecording(
                  context, (initialPosition!.dx - position!.dx))
            else
              _buildInputText(context, isReplyTo, themeData),
            sw(3),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_controller.text.trim().replaceAll("\n", "").isNotEmpty ||
                    !(getTchatFrontEndConfig()
                            .message
                            .tchatCanSendAudio
                            ?.call(widget.tchat) ??
                        getTchatFrontEndConfig().message.canSendAudio))
                  InkWell(
                    onTap: () async {
                      if (_controller.text
                          .trim()
                          .replaceAll("\n", "")
                          .isEmpty) {
                        return;
                      }
                      if (widget.isSendMessageBlocked &&
                          !widget.tchat.isGroup) {
                        if (!widget.currentUserBlockedOther) {
                          NotifBanner.showToast(
                              context: context,
                              fToast: FToast().init(context),
                              subTitle:
                                  "package.tchat.message.cant-send-message-blocked"
                                      .tr());
                          return;
                        } else {
                          await _checkUnlockTchat(context);
                          return;
                        }
                      }
                      // ignore: use_build_context_synchronously
                      widget.messageSendCallback?.call(
                          context,
                          ref,
                          widget.tchat,
                          _controller.text.autoCapitalize(),
                          ref.read(messageListProvider).replyTo);
                      if (ref.read(scrollProvider).controller?.hasClients ??
                          false) {
                        ref.read(scrollProvider).controller?.animateTo(0,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut);
                      }
                      // ignore: use_build_context_synchronously
                      ref.read(messageListProvider).setReplyTo(null);
                      _controller.clear();
                    },
                    child: Padding(
                      padding: EdgeInsets.only(
                          left: formatWidth(5.95),
                          right: formatWidth(17.5),
                          bottom: formatHeight(3)),
                      child: SvgPicture.asset(
                          getTchatFrontEndConfig()
                                  .message
                                  .sendMessageIconPath ??
                              "assets/svg/ic_send.svg",
                          package: getTchatFrontEndConfig()
                                      .message
                                      .sendMessageIconPath !=
                                  null
                              ? null
                              : "kosmos_chat",
                          color: getTchatFrontEndConfig()
                                      .message
                                      .sendMessageIconPath !=
                                  null
                              ? null
                              : themeData.actionButtonColor),
                    ),
                  )
                else ...[
                  XGestureDetector(
                    behavior: HitTestBehavior.opaque,
                    longPressTimeConsider: 150,
                    onLongPress: (_) async {
                      isPressed = true;

                      if (widget.isSendMessageBlocked &&
                          !widget.tchat.isGroup) {
                        if (!widget.currentUserBlockedOther) {
                          NotifBanner.showToast(
                              context: context,
                              fToast: FToast().init(context),
                              subTitle:
                                  "package.tchat.message.cant-send-message-blocked"
                                      .tr());
                          return;
                        } else {
                          await _checkUnlockTchat(context);
                          return;
                        }
                      }
                      var status = await Permission.microphone.status;

                      if (status.isDenied) {
                        status = await Permission.microphone.request();
                        return;
                      }

                      if (status.isPermanentlyDenied) {
                        // ignore: use_build_context_synchronously
                        final tmp = await showCupertinoDialog<bool?>(
                          context: context,
                          builder: (BuildContext ctx) {
                            return CupertinoAlertDialog(
                              title: Text('package.permission.mic.title'.tr()),
                              content: Text(
                                  "package.permission.mic.redirect-to-settings"
                                      .tr()),
                              actions: [
                                TextButton(
                                  child: Text(
                                    'package.permission.skip'.tr(),
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                  onPressed: () {
                                    Navigator.of(ctx).pop(true);
                                  },
                                ),
                                TextButton(
                                  child: Text(
                                    'package.permission.mic.button'.tr(),
                                    textAlign: TextAlign.center,
                                  ),
                                  onPressed: () async {
                                    Navigator.of(ctx).pop(false);
                                    await openAppSettings();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                        if (tmp == null || tmp) return;
                        openAppSettings();
                        return;
                      }

                      if (await record.hasPermission() && status.isGranted) {
                        if (!isPressed) return;
                      }

                      // Check and request permission
                      if (await record.hasPermission()) {
                        if (!isPressed) return;
                        StatusController.setStatus(
                            widget.tchat.id!, TchatingStatus.audioRec);
                        // Start recording
                        final r =
                            (await getApplicationDocumentsDirectory()).path;

                        _path = '$r/audio/${const Uuid().v1()}.wav';
                        File(_path!).createSync(recursive: true);
                        try {
                          await record.start(
                              const RecordConfig(
                                sampleRate: 44100, // b
                                encoder: AudioEncoder.wav, // by default
                                bitRate: 128000, // by default
                              ),
                              path: _path!);
                        } catch (e) {
                          printExcept(e);
                        }
                      } else {}

                      HapticFeedback.heavyImpact();
                      recDuration = Duration.zero;
                      timer = Timer.periodic(
                          const Duration(seconds: 1),
                          (_) => setState(() => recDuration =
                              Duration(seconds: recDuration!.inSeconds + 1)));
                      setState(() {
                        initialPosition = _.position;
                        position = _.position;
                        isAudioRecording = true;
                      });
                    },
                    onLongPressMove: (event) async {
                      if (showDeleteAudio) return;

                      initialPosition ??= event.position;
                      position = event.position;

                      if ((initialPosition!.dx - position!.dx) >
                          MediaQuery.of(context).size.width * .4) {
                        HapticFeedback.heavyImpact();
                        showDeleteAudio = true;

                        await record.stop();
                        setState(() {});
                      } else {
                        setState(() {});
                      }
                    },
                    onLongPressEnd: () async {
                      isPressed = false;
                      setState(() {});
                      StatusController.setStatus(
                          widget.tchat.id!, TchatingStatus.online);
                      final Duration r = recDuration ?? Duration.zero;
                      recDuration = null;
                      timer?.cancel();
                      if (!showDeleteAudio) {
                        HapticFeedback.heavyImpact();
                        HapticFeedback.heavyImpact();
                      }
                      if (!showDeleteAudio) {
                        await record.stop();
                      }

                      if (mounted &&
                          !showDeleteAudio &&
                          _path != null &&
                          r.inSeconds > 1) {
                        ref.read(messageListProvider).sendAudioMessage(
                            context, ref, widget.tchat, _path!, record);
                      }

                      setState(() {
                        showDeleteAudio = false;
                        initialPosition = null;
                        position = null;
                        isAudioRecording = false;
                      });
                    },
                    child: Padding(
                      padding: EdgeInsets.only(
                          left: formatWidth(10.5),
                          right: formatWidth(17.5),
                          bottom: formatHeight(3)),
                      child: getTchatFrontEndConfig()
                              .message
                              .micBuilder
                              ?.call(context, ref, widget.tchat) ??
                          SvgPicture.asset("assets/svg/ic_mic.svg",
                              package: "kosmos_chat",
                              color: themeData.actionButtonColor,
                              height: formatHeight(26)),
                    ),
                  )
                ],
                sh(10),
              ],
            ),
          ],
        ),
        // if (isAudioRecording && initialPosition != null && position != null)
        //   Positioned(
        //     right: formatWidth(15.5) - (((initialPosition!.dy - position!.dy).abs() > 10) ? formatWidth(10) : (initialPosition!.dy - position!.dy).abs()),
        //     top: -formatHeight(80) - (initialPosition!.dy - position!.dy).abs(),
        //     child: _animatedAudioRecording(context,(initialPosition!.dy - position!.dy).abs()),
        //   ),
      ],
    );
  }

  Widget _buildInputText(BuildContext context, bool isReplyTo, TchatMessageThemeData themeData) {
    return Expanded(
        child: Padding(
      padding: EdgeInsets.only(bottom: formatHeight(10)),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: themeData.inputDecoration?.fillColor,
          borderRadius: (themeData.inputDecoration?.enabledBorder
                      as InputBorder)
                  .isOutline
              ? BorderRadius.circular((themeData.inputDecoration?.enabledBorder
                      as OutlineInputBorder)
                  .borderRadius
                  .topLeft
                  .x)
              : null,
          border: Border.all(
            color:
                themeData.inputDecoration?.enabledBorder is OutlineInputBorder
                    ? (themeData.inputDecoration?.enabledBorder
                            as OutlineInputBorder)
                        .borderSide
                        .color
                    : Colors.transparent,
            width:
                themeData.inputDecoration?.enabledBorder is OutlineInputBorder
                    ? (themeData.inputDecoration?.enabledBorder
                            as OutlineInputBorder)
                        .borderSide
                        .width
                    : 0,
          ),
        ),
        child: IntrinsicHeight(
          child: SizedBox(
            height: themeData.inputTextHeight,
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Scrollbar(
                      controller: _scrollController,
                      child: TextFormField(
                        textCapitalization: TextCapitalization.sentences,
                        controller: _controller,
                        scrollController: _scrollController,
                        focusNode: _focusNode,
                        minLines: 1,
                        style: themeData.inputTextStyle ??
                            DefaultAppStyle.darkBlue(19, FontWeight.w500)
                                .copyWith(fontFamily: "Helvetica"),
                        maxLines: 4,
                        decoration: themeData.inputDecoration?.copyWith(
                          contentPadding: Platform.isIOS
                              ? EdgeInsets.only(left: formatWidth(15))
                              : EdgeInsets.zero,
                          hintStyle: themeData.inputHintStyle,
                          hintText: "package.tchat.message.input-hint".tr(),
                          border: OutlineInputBorder(
                              borderRadius: (themeData.inputDecoration
                                          ?.enabledBorder as InputBorder)
                                      .isOutline
                                  ? BorderRadius.circular((themeData
                                          .inputDecoration
                                          ?.enabledBorder as OutlineInputBorder)
                                      .borderRadius
                                      .topLeft
                                      .x)
                                  : BorderRadius.zero,
                              borderSide:
                                  const BorderSide(color: Colors.transparent)),
                          errorBorder: OutlineInputBorder(
                              borderRadius: (themeData.inputDecoration
                                          ?.enabledBorder as InputBorder)
                                      .isOutline
                                  ? BorderRadius.circular((themeData
                                          .inputDecoration
                                          ?.enabledBorder as OutlineInputBorder)
                                      .borderRadius
                                      .topLeft
                                      .x)
                                  : BorderRadius.zero,
                              borderSide:
                                  const BorderSide(color: Colors.transparent)),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: (themeData.inputDecoration
                                          ?.enabledBorder as InputBorder)
                                      .isOutline
                                  ? BorderRadius.circular((themeData
                                          .inputDecoration
                                          ?.enabledBorder as OutlineInputBorder)
                                      .borderRadius
                                      .topLeft
                                      .x)
                                  : BorderRadius.zero,
                              borderSide:
                                  const BorderSide(color: Colors.transparent)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: (themeData.inputDecoration
                                          ?.enabledBorder as InputBorder)
                                      .isOutline
                                  ? BorderRadius.circular((themeData
                                          .inputDecoration
                                          ?.enabledBorder as OutlineInputBorder)
                                      .borderRadius
                                      .topLeft
                                      .x)
                                  : BorderRadius.zero,
                              borderSide:
                                  const BorderSide(color: Colors.transparent)),
                          disabledBorder: OutlineInputBorder(
                              borderRadius: (themeData.inputDecoration
                                          ?.enabledBorder as InputBorder)
                                      .isOutline
                                  ? BorderRadius.circular((themeData
                                          .inputDecoration
                                          ?.enabledBorder as OutlineInputBorder)
                                      .borderRadius
                                      .topLeft
                                      .x)
                                  : BorderRadius.zero,
                              borderSide:
                                  const BorderSide(color: Colors.transparent)),
                          focusedErrorBorder: OutlineInputBorder(
                              borderRadius: (themeData.inputDecoration
                                          ?.enabledBorder as InputBorder)
                                      .isOutline
                                  ? BorderRadius.circular((themeData
                                          .inputDecoration
                                          ?.enabledBorder as OutlineInputBorder)
                                      .borderRadius
                                      .topLeft
                                      .x)
                                  : BorderRadius.zero,
                              borderSide:
                                  const BorderSide(color: Colors.transparent)),
                          prefixIcon: (Platform.isAndroid)
                              ? InkWell(
                                  onTap: () {
                                    setState(() =>
                                        showEmojiPicker = !showEmojiPicker);
                                    FocusScope.of(context).unfocus();
                                  },
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      themeData.emojiIcon ??
                                          SvgPicture.asset(
                                            "assets/svg/ic_emoji.svg",
                                            package: "kosmos_chat",
                                            color: themeData.emojiIconColor,
                                          ),
                                    ],
                                  ),
                                )
                              : null,
                        ),
                      ),
                    ),
                  ),
                  if (!isReplyTo) ...[
                    if (getTchatFrontEndConfig()
                            .message
                            .tchatCanSendMedia
                            ?.call(widget.tchat) ??
                        getTchatFrontEndConfig().message.canSendMedia) ...[
                      AnimatedSize(
                        duration: const Duration(milliseconds: 150),
                        child:
                            SizedBox(width: _controller.text.isEmpty ? 10 : 0),
                      ),
                      AnimatedSize(
                        duration: const Duration(milliseconds: 150),
                        child: SizedBox(
                          width: _controller.text.isEmpty ? 30 : 0,
                          child: InkWell(
                            onTap: () async {
                              if (widget.isSendMessageBlocked &&
                                  !widget.tchat.isGroup) {
                                if (!widget.currentUserBlockedOther) {
                                  NotifBanner.showToast(
                                      context: context,
                                      fToast: FToast().init(context),
                                      subTitle:
                                          "package.tchat.message.cant-send-message-blocked"
                                              .tr());
                                  return;
                                }
                                {
                                  await _checkUnlockTchat(context);
                                  return;
                                }
                              }
                              if (!mounted) return;
                              ref.read(mediaSenderProvider).clear(false);
                              final imageSource =
                                  await pickImageSourceType(context, null);
                              if (imageSource == null) return;

                              if (!mounted) return;

                              if (imageSource == ImageSource.camera) {
                                final MultiPickedAsset? entity =
                                    await PickImageController
                                        .getImageFromCamera(context);
                                if (entity == null) return;
                                ref
                                    .read(mediaSenderProvider)
                                    .addFiles([dz.left(entity)]);
                              } else {
                                final asset = await PickImageController
                                    .getImageFromGalery(context, 10);
                                if (asset == null || asset.isEmpty) return;
                                ref.read(mediaSenderProvider).addFiles(asset
                                    .map((e) =>
                                        dz.left<MultiPickedAsset, Uint8List>(e))
                                    .toList());
                              }

                              if (!mounted) return;
                              await AutoRouter.of(context).pushNamed(
                                  "/chat/${widget.tchat.id}/picker");
                              ref.read(mediaSenderProvider).clear(false);
                            },
                            child: Center(
                              child: SvgPicture.asset(
                                  "assets/svg/ic_camera.svg",
                                  package: "kosmos_chat",
                                  color: themeData.emojiIconColor),
                            ),
                          ),
                        ),
                      ),
                    ],
                    sw(12),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    ));
  }

  Widget _buildAudioRecording(BuildContext context, double abs) {
    if (abs < 0) abs = 0;

    return Expanded(
      child: SizedBox(
        height: formatWidth(47),
        child: Stack(
          children: [
            Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              width: double.infinity,
            ),
            Positioned(
              top: 0,
              bottom: 0,
              right: abs + formatWidth(20),
              child: Shimmer.fromColors(
                baseColor: DefaultColor.grey,
                highlightColor: Theme.of(context).scaffoldBackgroundColor,
                child: Center(
                  child: Text(
                    "package.tchat.cancel-audio".tr(),
                    style: DefaultAppStyle.grey(16, FontWeight.w500)
                        .copyWith(fontFamily: "Helvetica"),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              bottom: 0,
              child: Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: Row(
                  children: [
                    sw(10),
                    if (showDeleteAudio)
                      SvgPicture.asset("assets/svg/ic_mic.svg",
                          package: "kosmos_chat",
                          color: DefaultColor.error,
                          height: formatHeight(26))
                    else
                      SvgPicture.asset("assets/svg/ic_mic.svg",
                          package: "kosmos_chat",
                          color: DefaultColor.error,
                          height: formatHeight(26)),
                    sw(8),
                    Text(
                      "${recDuration?.inMinutes.autoPadLeft(2) ?? "00"}:${(recDuration?.inSeconds ?? 0 - ((recDuration?.inMinutes ?? 0) * 60)).autoPadLeft(2)}",
                      style: DefaultAppStyle.grey(22, FontWeight.w500),
                    ),
                    sw(3),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget _animatedAudioRecording(BuildContext context, double abs) {
  //   double w = formatWidth(30) + abs;
  //   if (w > formatHeight(55)) w = formatHeight(55);

  //   double h = formatHeight(80) - abs;
  //   if (h < formatHeight(55)) h = formatHeight(55);

  //   return Container(
  //     decoration: BoxDecoration(
  //       color: Theme.of(context).scaffoldBackgroundColor,
  //       borderRadius: BorderRadius.circular(80),
  //     ),
  //     width: w,
  //     height: h,
  //   );
  // }
}
