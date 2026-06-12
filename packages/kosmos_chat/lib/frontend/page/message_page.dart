import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:core_kosmos/core_kosmos.dart';
import 'package:kosmos_chat/backend/provider/message_list.dart';
import 'package:kosmos_chat/backend/provider/tchat_user_data.dart';
import 'package:kosmos_chat/backend/utils/utils.dart';
import 'package:kosmos_chat/frontend/widget/components/custom_voice.dart';
import 'package:kosmos_chat/kosmos_chat.dart';
import 'package:ui_kosmos_v4/ui_kosmos_v4.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// {@category Widget}
/// {@category Tchat}
///
/// Cette page permet d'afficher le widget
/// [MessageViewWidget] qui permet de visualiser
/// la liste des messages d'un tchat.
/// Cette page récupère les différentes informations
/// à communiquer au Widget [MessageViewWidget] via
/// le fichier de configuration [TchatFrontEndConfig]
/// et le fichier de configuration [TchatBackEndConfig].
///
/// Vous pouvez également configurer le thème de la page
/// via le fichier de configuration [TchatThemeData].
/// Ou en passant via la clé "tchat_theme".
class TchatMessagePage extends StatefulHookConsumerWidget {
  final String tchatId;
  final TchatModel? tchat;

  const TchatMessagePage({
    super.key,
    @PathParam("tchatId") required this.tchatId,
    this.tchat,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _TchatMessagePageState();
}

class _TchatMessagePageState extends ConsumerState<TchatMessagePage> {
  late TchatModel? _tchat = widget.tchat ??
      ref
          .read(tchatListProvider(FirebaseAuth.instance.currentUser!.uid))
          .tchatList
          ?.firstWhereOrNull((p0) => p0.id == widget.tchatId);

  /// Configuration and Theme

  late final TchatMessageViewConfig _config = getTchatFrontEndConfig().message;
  late final TchatBackEndConfig _backendConfig = getTchatBackEndConfig();

  @override
  void initState() {
    if (ref
                .read(tchatListProvider(FirebaseAuth.instance.currentUser!.uid))
                .tchatList
                ?.firstWhereOrNull((p0) => p0.id == widget.tchatId) ==
            null &&
        widget.tchat == null) {
      execAfterBuild(() async {
        _tchat = await getTchatBackEndConfig()
            .tchatInterface
            .loadTchatFromId(widget.tchatId);
        for (final String userId in _tchat!.participants) {
          await ref.read(tchatUserListProvider).addUserToList(userId);
        }
        setState(() {});
      });
    }
    playerList.clear();
    super.initState();
  }

  @override
  void dispose() {
    playerList.forEach((key, value) {
      value.pausePlayer();
      value.seekTo(0);
    });
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
       final  TchatMessageThemeData themeData = loadThemeData(
      null, "tchat_message_theme", () => kDefaultTchatMessageTheme,
      isDark: ref.watch(isDarkModeProvider).isDarkMode,       );
    final tchatThemeData = loadThemeData(
      null, "tchat_theme", () => kDefaultTchatTheme,
      isDark: ref.watch(isDarkModeProvider).isDarkMode,       );
    // Capture the provider (not the subscription): `init()` assigns the
    // subscription only after async work, so a subscription captured during
    // the first build is null and the live stream would never be cancelled —
    // leaving the last-opened thread auto-acking incoming messages as read.
    final messageList = ref.read(messageListProvider);
    _tchat = ref
            .watch(tchatListProvider(FirebaseAuth.instance.currentUser!.uid))
            .tchatList
            ?.firstWhereOrNull((p0) => p0.id == widget.tchatId) ??
        _tchat;

    useEffect(() {
      // This effect runs once when the widget is built.
      // Return a function that will be executed on dispose.
      return () {
        // Cancels whatever subscription is current at dispose time.
        messageList.cancelStream();
      };
    }, const []);

    /// If Tchat is null, we show a loader
    /// when we get data, we show the tchat
    if (_tchat == null) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        color:
        tchatThemeData?.tchatListBackgroundColor ??
         Theme.of(context).scaffoldBackgroundColor,
        child: Center(
            child:
                LoaderClassique(activeColor: Theme.of(context).primaryColor)),
      );
    }

    /// Show the tchat with the whole config
    /// and data.
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: tchatThemeData?.tchatListBackgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
      child: MessageViewWidget(
        tchat: _tchat!,
        showHeader: _config.showHeader,
        headerBuilder: _config.headerBuilder,
        showCallButton: _config.showCallButton,
        showVideoCallButton: _config.showVideoCallButton,
        showTchatAction: _config.showTchatAction,
        messageBuilder: _config.messageConfig.messageBuilder,

        /// Event
        onTchatNameClick: _backendConfig.messageInterface.onTchatNameClick,
        onTchatPhotoClick: _backendConfig.messageInterface.onTchatPhotoClick,

        onTapTchatActions: _backendConfig.messageInterface.onTapTchatActions,
        onTapAudioCall: _backendConfig.messageInterface.onTapAudioCall,
        onTapVideoCall: _backendConfig.messageInterface.onTapVideoCall,
        deleteEvent: _backendConfig.messageInterface.deleteTchat,
        reportAndLockEvent: _backendConfig.messageInterface.reportAndBlockTchat,
        unLockEvent: _backendConfig.messageInterface.unlockTchat,

        /// Theme
        theme: themeData,
      ),
    );
  }
}
