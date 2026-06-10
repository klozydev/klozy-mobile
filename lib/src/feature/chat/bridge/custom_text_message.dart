import 'package:core_kosmos/core_kosmos.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kosmos_chat/frontend/widget/components/private/sending_status.dart';
import 'package:kosmos_chat/kosmos_chat.dart';
import 'package:timeago_flutter/timeago_flutter.dart';

class CustomTextMessage extends StatefulHookConsumerWidget {
  final MessageModel message;
  final TchatModel tchat;

  /// Theme
  final String? themeName;
  final MessageBoxThemeData? theme;

  final Widget Function(MessageBoxThemeData themeData)? contentBuilder;

  const CustomTextMessage({
    super.key,
    required this.message,
    required this.tchat,

    /// Theme
    this.theme,
    this.themeName,
    this.contentBuilder,
  });

  @override
  ConsumerState<CustomTextMessage> createState() => _CustomTextMessageState();
}

class _CustomTextMessageState extends ConsumerState<CustomTextMessage> {
  late final MessageBoxThemeData _themeData = loadThemeData(
    widget.theme,
    widget.themeName ?? 'message_box',
    () => kDefaultMessageBoxThemeData,
  );
  late final bool fromMe =
      widget.message.senderId == FirebaseAuth.instance.currentUser!.uid;
  late final bool isOnlyEmojis;

  final RegExp emojiRegex = RegExp(
    r'^[\u{1F000}-\u{1F6FF}\u{1F900}-\u{1F9FF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}\u{1F300}-\u{1F5FF}\u{1F680}-\u{1F6FF}\u{1F1E0}-\u{1F1FF}\u{1F900}-\u{1F9FF}\u{1F018}-\u{1F270}\u{1F600}-\u{1F64F}\u{1F910}-\u{1F96B}\u{1F980}-\u{1F991}\u{1F9C0}-\u{1F9C2}\u{1F9E0}-\u{1F9FF}]+$',
    unicode: true,
  );

  late final lowStringSize =
      widget.message.content!.isNotEmpty &&
      widget.message.content!.length < 12 &&
      widget.message.replyTo == null;

  @override
  void initState() {
    isOnlyEmojis = emojiRegex.hasMatch(widget.message.content!);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final TchatFrontEndConfig frontEndConfig = getTchatFrontEndConfig();
    return IntrinsicWidth(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            children: [
              Padding(
                padding: EdgeInsets.only(
                  bottom: !lowStringSize ? 0 : formatHeight(4),
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth:
                        MediaQuery.of(context).size.width * .7 -
                        (widget.tchat.isGroup ? formatWidth(28) : 0),
                  ),
                  child: widget.contentBuilder != null
                      ? widget.contentBuilder!(_themeData)
                      : Text(
                          widget.message.content ?? '',
                          style:
                              (fromMe
                                      ? _themeData.meMessageTextStyle
                                      : _themeData.otherMessageTextStyle)
                                  ?.copyWith(
                                    fontSize: isOnlyEmojis
                                        ? formatHeight(32)
                                        : null,
                                  ),
                        ),
                ),
              ),
              if (lowStringSize && !isOnlyEmojis) ...[
                sw(8),
                Transform.translate(
                  offset: Offset(0, formatHeight(4)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      () {
                        switch (frontEndConfig
                            .listing
                            .dateTimeAgoIndicatorStyle) {
                          case DateTimeAgoIndicatorStyle.fixedDate:
                            return _buildDate(context);
                          case DateTimeAgoIndicatorStyle.timeSinceLastMessage:
                            return _buildDateWithDiff(context);
                        }
                      }.call(),
                      //_buildDate(context),
                      sw(3),
                      if (fromMe)
                        buildSendStatus(
                          context,
                          widget.message,
                          widget.tchat,
                          fromMe,
                          _themeData,
                        ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          if (!lowStringSize || isOnlyEmojis) ...[
            sh(1),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                () {
                  switch (frontEndConfig.listing.dateTimeAgoIndicatorStyle) {
                    case DateTimeAgoIndicatorStyle.fixedDate:
                      return _buildDate(context);
                    case DateTimeAgoIndicatorStyle.timeSinceLastMessage:
                      return _buildDateWithDiff(context);
                  }
                }.call(),
                const Spacer(),
                if (fromMe)
                  buildSendStatus(
                    context,
                    widget.message,
                    widget.tchat,
                    fromMe,
                    _themeData,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDate(BuildContext context) {
    final date = widget.message.sendAt ?? DateTime.now();

    final isFrench = Localizations.localeOf(context).languageCode == 'fr';
    final hour = date.hour;
    final minute = date.minute;

    String formattedTime;
    if (isFrench) {
      formattedTime = '${hour.autoPadLeft(2)}:${minute.autoPadLeft(2)}';
    } else {
      final period = hour >= 12 ? 'PM' : 'AM';
      final hour12 = hour % 12 == 0 ? 12 : hour % 12;
      formattedTime = '$hour12:${minute.autoPadLeft(2)} $period';
    }

    return Text(
      formattedTime,
      style: fromMe
          ? _themeData.meSendAtTextStyle
          : _themeData.otherSendAtTextStyle,
    );
  }

  Widget _buildDateWithDiff(BuildContext context) {
    final date = widget.message.sendAt ?? DateTime.now();
    final Duration diff = DateTime.now().difference(date);

    // Initialize dateString to handle different time formats
    String dateString;

    if (diff.inSeconds < 60) {
      // For messages sent less than a minute ago, show "now"
      dateString = 'app.duration.now'.tr();
      return Text(
        dateString,
        style: fromMe
            ? _themeData.meSendAtTextStyle
            : _themeData.otherSendAtTextStyle,
      );
    } else if (diff.inDays > 0) {
      // For messages older than 1 day, show the date
      dateString = 'date.locale-format'.tr(
        namedArgs: {
          'day': date.day.toString().padLeft(2, '0'),
          'month': date.month.toString().padLeft(2, '0'),
          'year': date.year.toString(),
        },
      );
      return Text(
        dateString,
        style: fromMe
            ? _themeData.meSendAtTextStyle
            : _themeData.otherSendAtTextStyle,
      );
    } else {
      return Timeago(
        refreshRate: const Duration(minutes: 1),
        date: date,
        builder: (_, _) {
          final Duration diff0 = DateTime.now().difference(date);
          if (diff0.inHours > 0) {
            // For messages sent today but more than an hour ago, show hours
            dateString = '${diff0.inHours}h';
          } else {
            // For messages sent less than an hour ago, show minutes
            dateString = '${diff0.inMinutes}min';
          }

          return Text(
            dateString,
            style: fromMe
                ? _themeData.meSendAtTextStyle
                : _themeData.otherSendAtTextStyle,
          );
        },
      );
    }
  }
}
