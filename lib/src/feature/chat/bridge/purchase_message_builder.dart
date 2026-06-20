import 'package:core_kosmos/core_kosmos.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/feature/chat/bridge/chat_message_styles.dart';
import 'package:klozy/src/feature/chat/bridge/custom_text_message.dart';
import 'package:klozy/src/router/app_router.dart';
import 'package:kosmos_chat/kosmos_chat.dart';

/// Purchase message bubble (ported from klozy's tchat.config). "View order
/// details" navigates to mobile's order detail (`OrderDetailRoute(id:)`).
Widget purchaseBuilder(
  BuildContext context,
  WidgetRef ref,
  MessageModel message,
  TchatModel tchat,
) {
  final bool fromMe =
      message.senderId == FirebaseAuth.instance.currentUser!.uid;
  final String orderPurchased = 'package.tchat.message.order-purchased'.tr();

  Widget content(MessageBoxThemeData themeData, {required bool me}) {
    final TextStyle base = (me
        ? themeData.meMessageTextStyle
        : themeData.otherMessageTextStyle)!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          orderPurchased,
          style: me
              ? base.copyWith(fontWeight: FontWeight.w400)
              : base.copyWith(color: Colors.white.withValues(alpha: 0.75)),
        ),
        SizedBox(
          width: chatTextWidth(
            orderPurchased,
            base.copyWith(fontWeight: FontWeight.w400),
            MediaQuery.of(context).size.width,
          ),
          child: Divider(
            color: (me ? DSColor.surface : Colors.white).withValues(alpha: 0.2),
            thickness: formatHeight(0.4),
            height: formatHeight(17),
          ),
        ),
        InkWell(
          onTap: () {
            if (context.mounted) {
              context.router.push(
                OrderDetailRoute(id: '${message.metadata['orderId']}'),
              );
            }
          },
          child: Text(
            'package.tchat.message.view-order-details'.tr(),
            style: (me ? chatOnPrimaryStyle : chatWhiteStyle)(
              12,
              FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  if (fromMe) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        CustomTextMessage(
          message: message,
          tchat: tchat,
          contentBuilder: (MessageBoxThemeData themeData) =>
              content(themeData, me: true),
        ),
      ],
    );
  }

  return CustomTextMessage(
    message: message,
    tchat: tchat,
    contentBuilder: (MessageBoxThemeData themeData) =>
        content(themeData, me: false),
  );
}

/// Conversation-list preview text for a purchase message.
Widget previewPurchaseBuilder(
  BuildContext context,
  WidgetRef ref,
  MessageModel message,
  TchatModel tchat,
) {
  final TchatThemeData? themeData = loadThemeData(
    null,
    'tchat_theme',
    () => kDefaultTchatTheme,
  );
  return Text(
    'package.tchat.message.order-purchased'.tr(),
    style: themeData?.tchatRowLastMessageStyle,
    maxLines: 2,
    overflow: TextOverflow.ellipsis,
  );
}
