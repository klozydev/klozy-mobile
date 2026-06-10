import 'package:core_kosmos/core_kosmos.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kosmos_chat/backend/kosmos_chat_backend.dart';
import 'package:kosmos_chat/backend/utils/utils.dart';
import 'package:kosmos_chat/frontend/kosmos_chat_frontend.dart';

/// {@category Widget}
/// {@category Tchat}
///
/// Cette page permet d'afficher le widget [TchatListWidget]
/// qui permet de visualiser la liste des pages.
/// Cette page récupère les différentes informations à
/// communiquer au Widget [TchatListWidget] via le fichier
/// de configuration [TchatFrontEndConfig] et le fichier
/// de configuration [TchatBackEndConfig].
///
/// Vous pouvez également configurer le thème de la page
/// via le fichier de configuration [TchatThemeData].
/// Ou en passant via la clé "tchat_theme".
class TchatListPage extends StatefulHookConsumerWidget {
  const TchatListPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _TchatListPageState();
}

class _TchatListPageState extends ConsumerState<TchatListPage> {

  late final TchatListingConfig _config = getTchatFrontEndConfig().listing;
  late final TchatBackEndConfig _backendConfig = getTchatBackEndConfig();

  @override
  void initState() {
    if (ref
            .read(tchatListProvider(FirebaseAuth.instance.currentUser!.uid))
            .tchatList ==
        null) {
      ref
          .read(tchatListProvider(FirebaseAuth.instance.currentUser!.uid))
          .init();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final TchatThemeData themeData =
      loadThemeData(null, "tchat_theme", () => kDefaultTchatTheme,
      isDark: ref.watch(isDarkModeProvider).isDarkMode,       );
    if (FirebaseAuth.instance.currentUser?.uid == null) return Container();
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: 
      // color
      themeData.tchatListBackgroundColor ??
      Theme.of(context).scaffoldBackgroundColor,
      child: TchatListWidget(
        theme: themeData,
        topActionSvgAsset: _config.topActionSvgAsset,
        canCreateNewTchat: _config.showTopAction,
        addBackButton: _config.showBackButton,
        topActionEvent: _backendConfig.tchatInterface.tchatListTopActionEvent,
        noTchatBuilder: _config.noTchatRowBuilder,
        tchatRowBuilder: _config.tchatRowBuilder,
        buildTchatRowAction: _config.buildTchatRowAction,
        actionDeleteEvent: _config.actionDeleteEvent,
        actionMoreEvent: _config.actionMoreEvent,
        deleteEvent: _backendConfig.messageInterface.deleteTchat,
        reportAndLockEvent: _backendConfig.messageInterface.reportAndBlockTchat,
        unLockEvent: _backendConfig.messageInterface.unlockTchat,
      ),
    );
  }
}
