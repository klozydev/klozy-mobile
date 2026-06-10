import 'package:core_kosmos/core_kosmos.dart';
import 'package:kosmos_chat/backend/config/tchat_backend_config.dart';

/// {@category Utils}
/// {@category Tchat}
/// Permet de récupérer la configuration du Back-End du package
TchatBackEndConfig getTchatBackEndConfig() =>
    (getAppModel().dependencies.packages["tchat_backend"]
        as TchatBackEndConfig?) ??
    TchatBackEndConfig();
