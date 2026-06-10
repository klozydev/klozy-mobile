import 'package:core_kosmos/core_kosmos.dart';
import 'package:kosmos_chat/frontend/config/tchat_frontend_config.dart';

/// {@category Utils}
/// {@category Tchat}
/// Permet de récupérer la configuration du Front-End du package
TchatFrontEndConfig getTchatFrontEndConfig() =>
    (getAppModel().dependencies.packages["tchat_frontend"] as TchatFrontEndConfig?) ?? TchatFrontEndConfig();
