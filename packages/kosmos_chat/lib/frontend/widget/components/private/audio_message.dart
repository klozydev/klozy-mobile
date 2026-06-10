import 'package:core_kosmos/core_kosmos.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kosmos_chat/frontend/widget/components/custom_voice.dart';
import 'package:kosmos_chat/frontend/widget/components/private/sending_status.dart';
import 'package:kosmos_chat/kosmos_chat.dart';
import 'package:timeago_flutter/timeago_flutter.dart';

class AudioMessage extends StatefulHookConsumerWidget {
  final MessageModel message;
  final TchatModel tchat;

  /// Theme
  final String? themeName;
  final MessageBoxThemeData? theme;

  const AudioMessage({
    super.key,
    required this.message,
    required this.tchat,

    /// Theme
    this.theme,
    this.themeName,
  });

  @override
  ConsumerState<AudioMessage> createState() => _AudioMessageState();
}

class _AudioMessageState extends ConsumerState<AudioMessage> {
  
  late final bool fromMe =
      widget.message.senderId == FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final MessageBoxThemeData themeData = loadThemeData(widget.theme,
      widget.themeName ?? "message_box", () => kDefaultMessageBoxThemeData,
      isDark: ref.read(isDarkModeProvider).isDarkMode,       );
    TchatFrontEndConfig frontEndConfig = getTchatFrontEndConfig();
    return IntrinsicWidth(
      child: Column(
        crossAxisAlignment:
            !fromMe ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          () {
            switch (frontEndConfig.listing.dateTimeAgoIndicatorStyle) {
              case DateTimeAgoIndicatorStyle.fixedDate:
                return _buildDate(context, themeData);
              case DateTimeAgoIndicatorStyle.timeSinceLastMessage:
                return _buildDateWithDiff(context, themeData);
            }
          }.call(),
          sh(1),
          Row(
            children: [
              CustomVoiceTrack(
                audioSrc: widget.message.media!.first.mediaUrl ?? "",
                message: widget.message,
                tchat: widget.tchat,
                theme: themeData,
              ),
            ],
          ),
          if (fromMe) ...[
            buildSendStatus(
                context, widget.message, widget.tchat, fromMe, themeData),
          ],
        ],
      ),
    );
  }

  Widget _buildDate(BuildContext context, MessageBoxThemeData themeData) {
    final date = widget.message.sendAt ?? DateTime.now();
    final locale = Localizations.localeOf(context).languageCode;

    String formattedTime;
    if (locale == 'fr') {
      // Use 24-hour format for French
      formattedTime =
          "${date.hour.autoPadLeft(2)}:${date.minute.autoPadLeft(2)}";
    } else {
      // Use 12-hour format with AM/PM for other languages
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
