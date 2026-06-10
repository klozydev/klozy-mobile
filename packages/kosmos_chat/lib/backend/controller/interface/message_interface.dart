import 'dart:async';
import 'dart:io';

import 'package:core_kosmos/core_kosmos.dart';
import 'package:flutter/material.dart';
import 'package:kosmos_chat/backend/kosmos_chat_backend.dart';

/// {@category Model}
/// {@category Tchat}
///
/// Abstract Class Interface.
/// Permet de définir les méthodes de base pour récupérer,
/// envoyer ou intéragir avec les messages du tchat.
///
/// Vous pouvez implémenter cette interface pour créer votre propre
/// système de tchat (ex: avec un tchat MySql).
abstract class MessageInterface {
  const MessageInterface();

  /// Permet de gérer l'évènement lors du click sur
  /// le nom du tchat.
  void onTchatNameClick(BuildContext context, TchatModel tchat,
      [List<SocialUser>? tchatUsers]);

  /// Permet de gérer l'évènement lors du click sur
  /// la photo du tchat.
  void onTchatPhotoClick(BuildContext context, TchatModel tchat,
      [List<SocialUser>? tchatUsers]);

  /// Permet de gérer l'évènement lors du click sur
  /// les actions du tchat.
  FutureOr<void> onTapTchatActions(
      BuildContext context, WidgetRef ref, TchatModel tchat);

  /// Permet de gérer l'action lors du click sur
  /// l'appel audio.
  FutureOr<void> onTapAudioCall(
      BuildContext context, WidgetRef ref, TchatModel tchat,
      [List<SocialUser>? tchatUsers]);

  /// Permet de gérer l'action lors du click sur
  /// l'appel vidéo.
  FutureOr<void> onTapVideoCall(
      BuildContext context, WidgetRef ref, TchatModel tchat,
      [List<SocialUser>? tchatUsers]);

  /// Permet d'envoyer un message.
  Future<void> sendMessage(BuildContext context, WidgetRef ref,
      TchatModel tchat, MessageModel model, String uuid,
      {File? file});

  /// Évenement dans la liste des tchats.
  /// Permet de gérer l'event de click sur les 3 points
  /// d'un tchat, ou encore, l'évenement de suppresion
  /// d'un tchat.
  FutureOr<void> deleteTchat(WidgetRef ref, TchatModel tchat);

  /// Évenement dans la liste des tchats.
  /// Permet de gérer l'event de click sur les 3 points
  /// d'un tchat, ou encore, l'évenement de suppresion
  /// d'un tchat.
  FutureOr<void> reportAndBlockTchat(
      WidgetRef ref, BuildContext context, TchatModel tchat);

  FutureOr<void> unlockTchat(WidgetRef ref, TchatModel tchat);
}
