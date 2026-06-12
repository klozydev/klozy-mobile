import 'package:core_kosmos/core_kosmos.dart';
import 'package:klozy/src/feature/chat/bridge/chat_theme.dart';
import 'package:klozy/src/feature/chat/bridge/mobile_message_controller.dart';
import 'package:klozy/src/feature/chat/bridge/mobile_tchat_controller.dart';
import 'package:klozy/src/feature/chat/bridge/offer_message_builder.dart';
import 'package:klozy/src/feature/chat/bridge/purchase_message_builder.dart';
import 'package:kosmos_chat/backend/controller/cache/hive_controller.dart';
import 'package:kosmos_chat/frontend/widget/components/message_builder.dart';
import 'package:kosmos_chat/kosmos_chat.dart';

/// Registers the chat package configuration into core_kosmos's [AppModel],
/// read later via `getTchatBackEndConfig()` / `getTchatFrontEndConfig()`.
///
/// Called once at startup (see AppInitializer) before any chat surface builds.
/// Offer/purchase message builders are added in a later phase.
void registerChatConfig() {
  registerChatTheme();
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
  // Best-effort: the chat providers read these Hive boxes for offline/cold
  // start; without init() every cache call is a silent no-op (shimmer instead
  // of cached conversations). Chat still works from the live streams if this
  // fails, hence fire-and-forget.
  _initChatCache().ignore();
}

Future<void> _initChatCache() async {
  // Sequential: each init() resets and re-registers the Hive adapters.
  await backendCacheControllerTchat.init('klozy_chat_tchats');
  await backendCacheControllerUser.init('klozy_chat_users');
  await backendCacheControllerMessage.init('klozy_chat_messages');
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
