import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:core_kosmos/core_kosmos.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kosmos_chat/backend/provider/message_list.dart';
import 'package:kosmos_chat/frontend/widget/components/private/sending_status.dart';
import 'package:kosmos_chat/kosmos_chat.dart';
import 'package:timeago_flutter/timeago_flutter.dart';
import 'package:ui_kosmos_v4/ui_kosmos_v4.dart';
import 'package:wechat_camera_picker/wechat_camera_picker.dart';

class MediaMessage extends StatefulHookConsumerWidget {
  final MessageModel message;
  final TchatModel tchat;

  /// Theme
  final String? themeName;
  final MessageBoxThemeData? theme;

  const MediaMessage({
    super.key,
    required this.message,
    required this.tchat,

    /// Theme
    this.themeName,
    this.theme,
  });

  @override
  ConsumerState<MediaMessage> createState() => _MediaMessageState();
}

class _MediaMessageState extends ConsumerState<MediaMessage> {
  
  late final bool fromMe =
      widget.message.senderId == FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    late final MessageBoxThemeData themeData = loadThemeData(widget.theme,
      widget.themeName ?? "message_box", () => kDefaultMessageBoxThemeData,
      isDark: ref.watch(isDarkModeProvider).isDarkMode,);
    TchatFrontEndConfig frontEndConfig = getTchatFrontEndConfig();
    return IntrinsicWidth(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _handleMedia(widget.message.media ?? [], themeData),
          if (widget.message.content != null) ...[
            sh(6),

            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  width: formatWidth(235),
                  child: Padding(
                    padding: EdgeInsets.only(left: formatWidth(12)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            widget.message.content ?? "",
                            style: fromMe
                                ? themeData.meMessageTextStyle
                                : themeData.otherMessageTextStyle,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Row(
            //   children: [
            //     sw(12),
            //     Expanded(
            //       child: Text(
            //         widget.message.content ?? "",
            //         style: fromMe
            //             ? _themeData.meMessageTextStyle
            //             : _themeData.otherMessageTextStyle,
            //       ),
            //     ),
            //   ],
            // ),
          ],
          sh(6),
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              sw(12),
              () {
                switch (frontEndConfig.listing.dateTimeAgoIndicatorStyle) {
                  case DateTimeAgoIndicatorStyle.fixedDate:
                    return _buildDate(context, themeData);
                  case DateTimeAgoIndicatorStyle.timeSinceLastMessage:
                    return _buildDateWithDiff(context, themeData);
                }
              }.call(),
              //_buildDate(context),
              sw(3),
              buildSendStatus(
                  context, widget.message, widget.tchat, fromMe, themeData),
              sw(11),
            ],
          )
        ],
      ),
    );
  }

  Widget _handleMedia(List<MediaModel> list, MessageBoxThemeData themeData) {
    if (list.isEmpty) {
      return Text("package.tchat.message.no-media".tr(),
          style: themeData.meMessageTextStyle);
    }

    if (list.length == 1) {
      final media = list.first;

      if (media.mediaType == AssetType.image) return _buildImage(media, themeData);
      if (media.mediaType == AssetType.video) return _buildVideo(media, themeData);
    } else if (list.length == 2 || list.length == 3) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          list.first.mediaType == AssetType.image
              ? _buildImage(
                  list.first, themeData, Size(formatWidth(130), formatWidth(130)))
              : _buildVideo(
                  list.first, themeData, Size(formatWidth(130), formatWidth(130))),
          sw(3),
          SizedBox(
            width: formatWidth(130),
            height: formatWidth(130),
            child: Stack(
              children: [
                Positioned.fill(
                  child: list[1].mediaType == AssetType.image
                      ? _buildImage(
                          list[1], themeData, Size(formatWidth(130), formatWidth(130)))
                      : _buildVideo(
                          list[1], themeData, Size(formatWidth(130), formatWidth(130))),
                ),
                if (list.length == 3) ...[
                  Positioned.fill(
                    child: InkWell(
                      onTap: () {
                        // AutoRouter.of(context).pushWidget(MediaPreviewerPage(
                        //   media: widget.message.media ?? [],
                        // ));
                        Navigator.push(context, MaterialPageRoute(builder: (_) {
                          return MediaPreviewerPage(
                            media: widget.message.media ?? [],
                          );
                        }));
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text("+2",
                              style:
                                  DefaultAppStyle.white(38, FontWeight.w400)),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              list.first.mediaType == AssetType.image
                  ? _buildImage(
                      list.first, themeData, Size(formatWidth(130), formatWidth(130)))
                  : _buildVideo(
                      list.first, themeData, Size(formatWidth(130), formatWidth(130))),
              sw(3),
              list[1].mediaType == AssetType.image
                  ? _buildImage(
                      list[1], themeData, Size(formatWidth(130), formatWidth(130)))
                  : _buildVideo(
                      list[1], themeData, Size(formatWidth(130), formatWidth(130))),
            ],
          ),
          sh(3),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              list[2].mediaType == AssetType.image
                  ? _buildImage(
                      list[2], themeData, Size(formatWidth(130), formatWidth(130)))
                  : _buildVideo(
                      list[2], themeData, Size(formatWidth(130), formatWidth(130))),
              sw(3),
              SizedBox(
                width: formatWidth(130),
                height: formatWidth(130),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: list[3].mediaType == AssetType.image
                          ? _buildImage(
                              list[3], themeData, Size(formatWidth(130), formatWidth(130)))
                          : _buildVideo(list[3], themeData,
                              Size(formatWidth(130), formatWidth(130))),
                    ),
                    if (list.length > 4) ...[
                      Positioned.fill(
                        child: InkWell(
                          onTap: () {
                            // AutoRouter.of(context).pushWidget(MediaPreviewerPage(
                            //   media: widget.message.media ?? [],
                            // ));
                            Navigator.push(context,
                                MaterialPageRoute(builder: (_) {
                              return MediaPreviewerPage(
                                media: widget.message.media ?? [],
                              );
                            }));
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.black.withOpacity(0.5),
                            ),
                            child: Center(
                              child: Text("+${list.length - 4}",
                                  style: DefaultAppStyle.white(
                                      38, FontWeight.w400)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      );
    }

    return Text(list.length.toString(), style: themeData.meMessageTextStyle);
  }

  Widget _buildImage(MediaModel media, MessageBoxThemeData themeData, [Size? maxSizeConstraint]) {
    Size size = Size.zero;

    if ((media.mediaWidth ?? 0) > (media.mediaHeight ?? 0)) {
      size = Size(double.infinity, formatHeight(206));
    } else {
      size = Size(formatWidth(235), formatHeight(320));
    }

    Widget? child;

    if (media.mediaRelativePath != null) {
      final f = File(
          "${ref.read(messageListProvider).appPath}/${media.mediaRelativePath!}");
      if (f.existsSync()) {
        child = Image.file(f, fit: BoxFit.cover);
      }
    }

    return InkWell(
      onTap: ref.read(selectStatusProvider.notifier).state
          ? null
          : () {
              // AutoRouter.of(context).pushWidget(MediaPreviewerPage(
              //   media: widget.message.media ?? [],
              // ));
              Navigator.push(context, MaterialPageRoute(builder: (_) {
                return MediaPreviewerPage(
                  media: widget.message.media ?? [],
                );
              }));
            },
      child: Container(
        constraints: maxSizeConstraint != null
            ? BoxConstraints(
                maxWidth: maxSizeConstraint.width,
                maxHeight: maxSizeConstraint.height)
            : null,
        width: size.width,
        height: size.height,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
        clipBehavior: Clip.antiAlias,
        child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: child ??
                (media.mediaUrl != null
                    ? CachedNetworkImage(
                        imageUrl: media.mediaUrl!,
                        fit: BoxFit.cover,
                        placeholderFadeInDuration:
                            const Duration(milliseconds: 100),
                        placeholder: (_, __) =>
                            const Center(child: LoaderClassique()),
                        errorWidget: (_, __, ___) => Center(
                            child: Icon(Icons.error,
                                color: themeData.messageErrorColor)),
                      )
                    : const Center(child: LoaderClassique()))),
      ),
    );
  }

  Widget _buildVideo(MediaModel media, MessageBoxThemeData themeData, [Size? maxSizeConstraint]) {
    Size size = Size.zero;

    if ((media.mediaWidth ?? 0) > (media.mediaHeight ?? 0)) {
      size = Size(double.infinity, formatHeight(206));
    } else {
      size = Size(formatWidth(235), formatHeight(320));
    }

    Widget? child;

    if (media.videoThumbnailRelativePath != null) {
      final f = File(
          "${ref.read(messageListProvider).appPath}/${media.videoThumbnailRelativePath!}");
      if (f.existsSync()) {
        child = Image.file(f, fit: BoxFit.cover);
      }
    }

    return InkWell(
      onTap: ref.read(selectStatusProvider.notifier).state
          ? null
          : () {
              Navigator.push(context, MaterialPageRoute(builder: (_) {
                return MediaPreviewerPage(
                  media: widget.message.media ?? [],
                );
              }));
              // AutoRouter.of(context).pushWidget();
            },
      child: Container(
        constraints: maxSizeConstraint != null
            ? BoxConstraints(
                maxWidth: maxSizeConstraint.width,
                maxHeight: maxSizeConstraint.height)
            : null,
        width: size.width,
        height: size.height,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
        child: Stack(
          children: [
            Positioned.fill(
              child: SizedBox(
                width: size.width,
                height: size.height,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: child ??
                      (media.videoThumbnail != null
                          ? CachedNetworkImage(
                              imageUrl: media.videoThumbnail!,
                              fit: BoxFit.cover,
                              placeholderFadeInDuration:
                                  const Duration(milliseconds: 100),
                              placeholder: (_, __) =>
                                  const Center(child: LoaderClassique()),
                              errorWidget: (_, __, ___) => Center(
                                  child: Icon(Icons.error,
                                      color: themeData.messageErrorColor)),
                            )
                          : const Center(child: LoaderClassique())),
                ),
              ),
            ),
            const Center(
              child: Icon(
                Icons.play_arrow_rounded,
                color: Colors.white,
                size: 50,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDate(BuildContext context, MessageBoxThemeData themeData) {
    final date = widget.message.sendAt ?? DateTime.now();
    final isFrench = Localizations.localeOf(context).languageCode == 'fr';

    String formattedTime;
    if (isFrench) {
      formattedTime =
          "${date.hour.autoPadLeft(2)}:${date.minute.autoPadLeft(2)}";
    } else {
      final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
      final period = date.hour >= 12 ? "PM" : "AM";
      formattedTime = "$hour:${date.minute.autoPadLeft(2)} $period";
    }

    return Text(formattedTime,
        style: fromMe
            ? themeData.meSendAtTextStyle
            : themeData.otherSendAtTextStyle);
  }

  Widget _buildDateWithDiff(BuildContext context, MessageBoxThemeData themeData) {
    final date = widget.message.sendAt ?? DateTime.now();
    final Duration diff = DateTime.now().difference(date);

    // Initialize dateString to handle different time formats
    String dateString;

    if (diff.inSeconds < 60) {
      // For messages sent less than a minute ago, show "now"
      dateString = "app.duration.now".tr();
      return Text(dateString,
          style: fromMe
              ? themeData.meSendAtTextStyle
              : themeData.otherSendAtTextStyle);
    } else if (diff.inDays > 0) {
      // For messages older than 1 day, show the date
      dateString = "date.locale-format".tr(namedArgs: {
        "day": date.day.toString().padLeft(2, '0'),
        "month": date.month.toString().padLeft(2, '0'),
        "year": date.year.toString(),
      });
      return Text(dateString,
          style: fromMe
              ? themeData.meSendAtTextStyle
              : themeData.otherSendAtTextStyle);
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

          return Text(dateString,
              style: fromMe
                  ? themeData.meSendAtTextStyle
                  : themeData.otherSendAtTextStyle);
        },
      );
    }
  }
}
