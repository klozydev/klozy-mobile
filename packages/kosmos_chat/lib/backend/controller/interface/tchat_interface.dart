import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:core_kosmos/core_kosmos.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kosmos_chat/backend/controller/cache/hive_controller.dart';
import 'package:kosmos_chat/backend/kosmos_chat_backend.dart';
import 'package:dartz/dartz.dart' as dz;
import 'package:ui_kosmos_v4/ui_kosmos_v4.dart';

/// {@category Model}
/// {@category Tchat}
///
/// Abstract Class Interface.
/// Permet de définir les méthodes de base pour récupérer,
/// ou intéragir avec les discussions du tchat.
///
/// Vous pouvez implémenter cette interface pour créer votre propre
/// système de tchat (ex: avec un tchat MySql).
abstract class TchatInterface {
  const TchatInterface();

  Future<void> updateMute(String userId, String tchatId, bool muted) {
    throw UnimplementedError();
  }

  /// Permet de stream la liste des tchats de l'utilisateur.
  StreamSubscription streamTchatList(
    Map<String, TchatModel> tchatList,
    FutureOr<void> Function(String)? fetchUserData,
    VoidCallback? notify,
    CachedTchatController cachedTchatController,
  );

  /// Permet de stream la liste des messages d'un tchat.
  StreamSubscription streamMessageOfTchat(
    String tchatId,
    List<MessageModel> messageList,
    VoidCallback? notify,
    CachedTchatController cachedTchatController, [
    DateTime? minimalSendingDate,
    List<String> bloquedUsers = const [],
  ]);

  /// Permet de récupérer les données d'un tchat.
  Future<TchatModel?> getTchatData(String tchatId,
      [List<TchatModel>? tchatList]);

  /// Permet de vérifier si un tchat existe et si
  /// l'utilisateur est bien dans ce tchat.
  Future<DocumentReference?> tchatExist(
    TchatType type, {
    String? userId,
    String? otherUserId,
    String? groupeId,
  });

  /// Permet de charger un TchatModel depuis un id
  Future<TchatModel?> loadTchatFromId(String tchatId);

  /// Permet de créer un nouveau tchat.
  /// Vous ne devez prodiguer que le type de Tchat.
  ///
  /// Si le tchat est de Type [TchatType.oneToOne], vous devez
  /// fournir l'id des 2 utilisateurs.
  ///
  /// Si le tchat est de Type [TchatType.group], vous devez
  /// fournir l'id du créateur.
  Future<String?> createTchat(TchatType tchatType,
      {String? userId1, String? userId2, String? creatorId});

  /// Permet de gérer l'event de click du bouton d'event en haut
  /// à droite de la liste des tchats.
  FutureOr<void> tchatListTopActionEvent(BuildContext context);

  /// Permet de récupérer les données d'un utilisateur
  /// à partir de son id.
  Future<Map<String, dynamic>> getUserData(String userId);

  /// Permet de gérer les évènements à l'ouverture d'un tchat.
  /// Par exemple, vous pouvez utiliser cette méthode pour
  /// récupérer les données d'un tchat, oubien rediriger sur
  /// une page spécifique.
  Future<void> openTchat(BuildContext context, WidgetRef ref, TchatModel tchat);

  /// Permet de définir que l'utilisateur a lu le dernier message
  Future<void> setLastMessageRead(String tchatId);

  /// Permet d'upload les données vers les bases de données.
  void uploadListOfAssetFileToDatabase(
      List<dz.Tuple2<String, dz.Either<MultiPickedAsset, Uint8List>>> assets,
      String tchatId,
      String messageId,
      {void Function(List<dz.Tuple2<String, String>>)? onSuccess,
      void Function(Object)? onError});
}
