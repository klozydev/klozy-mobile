import 'package:core_kosmos/core_kosmos.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/feature/chat/bridge/chat_message_styles.dart';
import 'package:klozy/src/feature/chat/bridge/chat_offer_controller.dart';
import 'package:klozy/src/feature/chat/bridge/custom_text_message.dart';
import 'package:klozy/src/router/app_router.dart';
import 'package:kosmos_chat/kosmos_chat.dart';
import 'package:ui_kosmos_v4/button/button.dart';

/// Offer message bubble (ported from klozy's tchat.config). Accept/refuse hit
/// the shared Firebase callable via [ChatOfferController]; "view summary"
/// navigates to mobile's cart.
Widget offerBuilder(
  BuildContext context,
  WidgetRef ref,
  MessageModel message,
  TchatModel tchat,
) {
  final bool fromMe =
      message.senderId == FirebaseAuth.instance.currentUser!.uid;
  final bool isCancelled = message.metadata['cancelled'] == true;

  if (fromMe) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        CustomTextMessage(
          message: message,
          tchat: tchat,
          contentBuilder: (MessageBoxThemeData themeData) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              RichText(
                text: TextSpan(
                  text:
                      '${'package.tchat.message.order-requested'.tr(namedArgs: {'product_name': '${message.metadata['productName']}'})} ',
                  style: themeData.meMessageTextStyle?.copyWith(
                    fontWeight: FontWeight.w400,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: "${message.metadata['productPrice']} aed",
                      style: themeData.meMessageTextStyle?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w400,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                    TextSpan(
                      text: ' - ',
                      style: themeData.meMessageTextStyle?.copyWith(
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                      ),
                    ),
                    TextSpan(
                      text: "${message.metadata['newProductPrice']} aed",
                      style: themeData.meMessageTextStyle?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (message.metadata['accepted'] != null || isCancelled)
                Divider(
                  color: Colors.white.withValues(alpha: 0.2),
                  thickness: formatHeight(0.4),
                  height: formatHeight(17),
                ),
              if (isCancelled)
                Text(
                  'Cancelled',
                  style: chatWhiteStyle(12, FontWeight.w500).copyWith(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontStyle: FontStyle.italic,
                  ),
                )
              else if (message.metadata['accepted'] == true)
                Row(
                  children: <Widget>[
                    Text(
                      'Accepted',
                      style: chatWhiteStyle(12, FontWeight.w500).copyWith(
                        color: Colors.white.withValues(alpha: 0.75),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    sw(12),
                    InkWell(
                      onTap: () {
                        if (context.mounted) {
                          context.router.push(const CartRoute());
                        }
                      },
                      child: Text(
                        'View summary',
                        style: chatWhiteStyle(
                          12,
                          FontWeight.w500,
                        ).copyWith(color: Colors.white),
                      ),
                    ),
                  ],
                )
              else if (message.metadata['accepted'] == false)
                Text(
                  'Refused',
                  style: chatWhiteStyle(10, FontWeight.w300).copyWith(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontStyle: FontStyle.italic,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  return CustomTextMessage(
    message: message,
    tchat: tchat,
    contentBuilder: (MessageBoxThemeData themeData) => Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        RichText(
          text: TextSpan(
            text: message.content ?? '',
            style: themeData.otherMessageTextStyle,
            children: <TextSpan>[
              TextSpan(
                text:
                    '${'package.tchat.message.order-requested'.tr(namedArgs: {'product_name': '${message.metadata['productName']}'})} ',
                style: themeData.otherMessageTextStyle?.copyWith(
                  color: Colors.white.withValues(alpha: 0.75),
                ),
              ),
              TextSpan(
                text: "${message.metadata['productPrice']} aed",
                style: themeData.otherMessageTextStyle?.copyWith(
                  color: Colors.white.withValues(alpha: 0.75),
                  decoration: TextDecoration.lineThrough,
                ),
              ),
              TextSpan(
                text: ' - ',
                style: themeData.otherMessageTextStyle?.copyWith(
                  color: Colors.white.withValues(alpha: 0.75),
                ),
              ),
              TextSpan(
                text: "${message.metadata['newProductPrice']} aed",
                style: themeData.otherMessageTextStyle?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Divider(
          color: Colors.white.withValues(alpha: 0.2),
          thickness: formatHeight(0.4),
          height: formatHeight(17),
        ),
        if (isCancelled)
          Text(
            'Cancelled',
            style: chatWhiteStyle(10, FontWeight.w300).copyWith(
              color: Colors.white.withValues(alpha: 0.75),
              fontStyle: FontStyle.italic,
            ),
          )
        else if (message.metadata['accepted'] == true)
          Row(
            children: <Widget>[
              Text(
                'Accepted',
                style: chatWhiteStyle(10, FontWeight.w300).copyWith(
                  color: Colors.white.withValues(alpha: 0.75),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          )
        else if (message.metadata['accepted'] == false)
          Text(
            'Refused',
            style: chatWhiteStyle(10, FontWeight.w300).copyWith(
              color: Colors.white.withValues(alpha: 0.75),
              fontStyle: FontStyle.italic,
            ),
          )
        else
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              InkWell(
                onTap: () {
                  if (context.mounted) {
                    const ChatOfferController().handleOffer(
                      false,
                      '${message.metadata['offerId'] ?? ''}',
                    );
                  }
                },
                child: SizedBox(
                  height: formatHeight(32),
                  child: Center(
                    child: Padding(
                      padding: EdgeInsetsDirectional.only(end: formatWidth(26)),
                      child: Text('Refuse', style: chatWhiteStyle(12)),
                    ),
                  ),
                ),
              ),
              Button(
                onTap: () async {
                  if (context.mounted) {
                    await const ChatOfferController().handleOffer(
                      true,
                      '${message.metadata['offerId'] ?? ''}',
                    );
                  }
                },
                height: formatHeight(32),
                width: formatWidth(81),
                buttonType: ButtonType.primary,
                decoration: BoxDecoration(
                  color: DSColor.primary,
                  borderRadius: BorderRadius.circular(formatHeight(9)),
                ),
                child: Text('Accept', style: chatWhiteStyle(12)),
              ),
            ],
          ),
        sh(2),
      ],
    ),
  );
}

/// Sub-message indicator under an offer (cancelled state only).
Widget subOfferBuilder(
  BuildContext context,
  WidgetRef ref,
  MessageModel message,
  TchatModel tchat,
) {
  if (message.metadata['cancelled'] == true) {
    return Padding(
      padding: EdgeInsets.only(top: formatHeight(2)),
      child: Text(
        'Cancelled',
        style: chatWhiteStyle(10, FontWeight.w300).copyWith(
          color: Colors.white.withValues(alpha: 0.75),
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }
  return const SizedBox.shrink();
}

/// Conversation-list preview text for an offer message.
Widget previewOfferBuilder(
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
    'package.tchat.message.order-requested'.tr(
      namedArgs: <String, String>{
        'product_name': '${message.metadata['productName']}',
      },
    ),
    style: themeData?.tchatRowLastMessageStyle,
    maxLines: 2,
    overflow: TextOverflow.ellipsis,
  );
}
