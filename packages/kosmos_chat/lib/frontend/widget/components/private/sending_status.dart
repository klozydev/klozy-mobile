import 'package:core_kosmos/core_kosmos.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kosmos_chat/kosmos_chat.dart';

Widget buildSendStatus(
  BuildContext context,
  MessageModel message,
  TchatModel tchat,
  bool fromMe,
  MessageBoxThemeData themeData,
) {
  if (!fromMe) return const SizedBox.shrink();
  final String statusIcon =
      message.sendStatus == "sending" ? "ic_sending_state" : "ic_send_state";
  final bool readByAll = ([...tchat.participants]..sort()).join(",") ==
      ([...message.readBy]..sort()).join(",");

  Color? color;
  if (fromMe) {
    if (message.sendStatus == "sending") {
      color = themeData.meMessageSendingColor;
    } else {
      color = readByAll
          ? themeData.meMessageReadColor
          : themeData.meMessageSendColor;
    }
  }

  return SvgPicture.asset(
    "assets/svg/$statusIcon.svg",
    package: "kosmos_chat",
    color: color,
    height: themeData.sendStatusIconSize ??
        formatHeight(
            9), //statusIcon.contains("sending") ? formatHeight(18) : null
  );
}
