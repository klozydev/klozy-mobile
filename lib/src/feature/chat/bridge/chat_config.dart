import 'package:core_kosmos/core_kosmos.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/feature/chat/bridge/chat_theme.dart';
import 'package:klozy/src/feature/chat/bridge/mobile_message_controller.dart';
import 'package:klozy/src/feature/chat/bridge/mobile_tchat_controller.dart';
import 'package:klozy/src/feature/chat/bridge/offer_message_builder.dart';
import 'package:klozy/src/feature/chat/bridge/purchase_message_builder.dart';
import 'package:kosmos_chat/frontend/widget/components/message_builder.dart';
import 'package:kosmos_chat/kosmos_chat.dart';
import 'package:ui_kosmos_v4/button/theme/button_theme.dart';

/// Registers the chat package configuration into core_kosmos's [AppModel],
/// read later via `getTchatBackEndConfig()` / `getTchatFrontEndConfig()`.
///
/// Called once at startup (see AppInitializer) before any chat surface builds.
/// Offer/purchase message builders are added in a later phase.
void registerChatConfig() {
  // Klozy dark chat theming. Register under both the base and "-dark" keys so
  // the package resolves Klozy colours regardless of its isDarkMode flag.
  if (!GetIt.instance.isRegistered<AppTheme>()) {
    final AppTheme appTheme = AppTheme()
      ..addTheme('tchat_theme', klozyTchatTheme(), darkTheme: klozyTchatTheme())
      ..addTheme(
        'message_box',
        klozyMessageBoxTheme(),
        darkTheme: klozyMessageBoxTheme(),
      )
      ..addTheme(
        'tchat_message_theme',
        klozyMessageTheme(),
        darkTheme: klozyMessageTheme(),
      )
      // Back button (header chevron) defaults to dark navy — make it readable
      // on the black chat surface.
      ..addTheme(
        'back_button',
        const KosmosButtonThemeData(iconColor: DSColor.onSurface),
        darkTheme: const KosmosButtonThemeData(iconColor: DSColor.onSurface),
      );
    GetIt.instance.registerSingleton<AppTheme>(appTheme);
  }

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
    // Klozy threads always carry a message (offer/purchase/text), so don't gate
    // them behind an extra per-thread "has any message" Firestore round-trip —
    // that serial check is part of what made the list slow to first paint.
    showTchatIfNoMessage: true,
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
