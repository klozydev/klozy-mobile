import 'package:core_kosmos/core_kosmos.dart';
import 'package:kosmos_chat/backend/controller/group_config_controller.dart';
import 'package:kosmos_chat/backend/controller/message_controller.dart';
import 'package:kosmos_chat/backend/kosmos_chat_backend.dart';

/// {@category Config}
/// {@category Tchat}
///
/// Permet de configurer la partie Back-End du package
/// de Kosmos-Tchat.
///
/// Pour configurer celui-ci, vous devez utiliser la clé
/// "tchat_backend" dans votre `PackageDependencies`.
class TchatBackEndConfig extends PackageConfig {
  final TchatInterface tchatInterface;
  final MessageInterface messageInterface;
  final bool showTchatIfNoMessage;
  final bool showTchatIfClosed;
  final GroupConfigInterface groupConfigController;

  TchatBackEndConfig({
    this.tchatInterface = const TchatController(),
    this.messageInterface = const MessageController(),
    this.groupConfigController = const GroupConfigController(),
    this.showTchatIfNoMessage = false,
    this.showTchatIfClosed = false,
  }) : super("tchat_backend");
}
