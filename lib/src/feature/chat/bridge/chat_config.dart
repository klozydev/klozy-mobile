import 'package:core_kosmos/core_kosmos.dart';
import 'package:klozy/src/feature/chat/bridge/mobile_message_controller.dart';
import 'package:klozy/src/feature/chat/bridge/mobile_tchat_controller.dart';
import 'package:klozy/src/feature/chat/bridge/offer_message_builder.dart';
import 'package:klozy/src/feature/chat/bridge/purchase_message_builder.dart';
import 'package:kosmos_chat/frontend/widget/components/message_builder.dart';
import 'package:kosmos_chat/kosmos_chat.dart';

/// Registers the chat package configuration into core_kosmos's [AppModel],
/// read later via `getTchatBackEndConfig()` / `getTchatFrontEndConfig()`.
///
/// Called once at startup (see AppInitializer) before any chat surface builds.
/// Offer/purchase message builders are added in a later phase.
void registerChatConfig() {
  if (GetIt.instance.isRegistered<AppModel<Object?>>()) return;
  GetIt.instance.registerSingleton<AppModel<Object?>>(
    AppModel<Object?>(
      appTitle: 'Klozy',
      userConfig: UserConfig<Object?>(
        fromJson: (Map<String, dynamic>? json, String? userType) => json,
      ),
      dependencies: DependenciesConfig(
        packages: <String, PackageConfig>{
          'tchat_backend': _backendConfig(),
          'tchat_frontend': _frontendConfig(),
        },
      ),
    ),
  );
}

TchatBackEndConfig _backendConfig() {
  return TchatBackEndConfig(
    showTchatIfNoMessage: false,
    tchatInterface: const MobileTchatController(),
    messageInterface: const MobileMessageController(),
  );
}

TchatFrontEndConfig _frontendConfig() {
  return TchatFrontEndConfig(
    listing: const TchatListingConfig(
      dateTimeAgoIndicatorStyle: DateTimeAgoIndicatorStyle.timeSinceLastMessage,
      hideHeaderChatList: true,
      showTopAction: false,
      addTopPadding: false,
    ),
    message: const TchatMessageViewConfig(
      messageConfig: TchatMessageConfig(
        subMessageBuilders: <String, MessageBuilderCallback>{
          'offer': subOfferBuilder,
        },
        messageContentBuilders: <String, MessageBuilderCallback>{
          'text': MessageBuilder.textBuilder,
          'audio': MessageBuilder.audioBuilder,
          'media': MessageBuilder.mediaBuilder,
          'event': MessageBuilder.eventBuilder,
          'offer': offerBuilder,
          'purchase': purchaseBuilder,
        },
        previewInListBuilders: <String, MessageBuilderCallback>{
          'text': PreviewBuilder.textPreview,
          'media': PreviewBuilder.mediaPreview,
          'audio': PreviewBuilder.audioPreview,
          'deleted-message': PreviewBuilder.deletedMessageBuilder,
          'offer': previewOfferBuilder,
          'purchase': previewPurchaseBuilder,
        },
        replyToBuilders: <String, ReplyBuilderCallback>{
          'text': ReplyToBuilder.textReply,
          'media': ReplyToBuilder.mediaReply,
          'audio': ReplyToBuilder.audioReply,
        },
      ),
    ),
  );
}
