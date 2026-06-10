# Kosmos Digital - Tchat

**/!\ Attention, le tchat de Groupe n'est pas encore prêt, les fonctions et exemple ci-dessous ne fonctionne que pour l'alpha du Tchat One-To-One.**

- [Kosmos Digital - Tchat](#kosmos-digital---tchat)
- [Configurer le tchat](#configurer-le-tchat)
  - [Route et redirection](#route-et-redirection)
  - [Configuration \& Interface](#configuration--interface)
  - [Configuration Back-End](#configuration-back-end)
  - [Tchat One-to-One \& Group](#tchat-one-to-one--group)
  - [Permissions](#permissions)
- [Messages Customs](#messages-customs)
  - [Envoyer un Message Custom](#envoyer-un-message-custom)
  - [Configurer les messages customs](#configurer-les-messages-customs)
  - [Exemple](#exemple)

# Configurer le tchat

Le tchat est basé sur un système d'interface vous permettant de configurer l'intégralité des interactions Front-End et Back-End.

## Route et redirection

Afin d'utiliser les pages de tchat il est important de suivre une nomenclature précise :

```Dart
/// Affiche la liste des tchats
AutoRoute(path: "tchat", page: TchatListPage, initial: true),

/// Affiche un tchat, et ses messages
AutoRoute(path: "tchat/:tchatId", page: TchatMessagePage),

/// Affiche le pciker de media du tchat. !important
AutoRoute(path: "tchat/:tchatId/picker", page: MediaPreviewerPage),
```

Par défaut les pages utilisent le système de `AutoRouter.of(ctx).pushNamed(...)`, il est donc important de suivre cette nomenclature pour les routes (sauf si vous souhaitez override les données du tchat).

Faites également **attention aux logiques de pop** de vos routes.

## Configuration & Interface

Afin de configurer les interactions avec le tchat vous devez utiliser un objet de type `TchatFrontEndConfig` et/ou `TchatBackEndConfig` dans les configurations des packages.

```Dart
packages: {
  // Configuration Front-End
  "tchat_frontend": TchatFrontEndConfig(),

  // Configuration Back-End
  "tchat_backend": TchatBackEndConfig(),
}
```

Pour configurer le Front-End des pages par défaut vous pouvez définir vos paramètres au sein de l'objet `TchatFrontEndConfig`.

```Dart
"tchat_frontend": TchatFrontEndConfig(
  /// Configuration de la page de listing des tchat
  listing: TchatListingConfig(
    //...
  ),

  /// Configuration de la page affichant les messages
  message: TchatMessageViewConfig(
    //...

    /// Important pour configurer les builders customs.
    messageConfig: TchatMessageConfig(
      //...
    ),
  ),
),
```

Afin d'afficher, ou de personnaliser, l'affichage de vos messages, vous avez plusieurs listes de configuration.

- `TchatMessageConfig.messageContentBuilders` pour l'affichage des messages.
- `TchatMessageConfig.previewInListBuilders` pour l'affichage des messages dans la lsite des tchats (dernier message envoyé).
- `TchatMessageConfig.replyToBuilders` pour l'affichage des messages lorsqu'il sont l'objet d'une réponse.
- `TchatMessageConfig.authorizedReplyToUI` liste des messages pouvant affichés la preview du message auquel on répond.

```Dart
/// !Important, lorsque vous modifiez les builders,
/// vous devez remettre les valeurs par défaut (ci-dessous)
this.messageContentBuilders = const {
  "text": MessageBuilder.textBuilder,
  "media": MessageBuilder.mediaBuilder,
  "event": MessageBuilder.eventBuilder,
},

/// !Important, lorsque vous modifiez les builders,
/// vous devez remettre les valeurs par défaut (ci-dessous)
this.previewInListBuilders = const {
  "text": PreviewBuilder.textPreview,
  "media": PreviewBuilder.mediaPreview,
},

/// !Important, lorsque vous modifiez les builders,
/// vous devez remettre les valeurs par défaut (ci-dessous)
this.replyToBuilders = const {
  "text": ReplyToBuilder.textReply,
  "media": ReplyToBuilder.mediaReply,
},

/// Uniquement les messages de types "text" pourront
/// avoir les previews des réponses au dessus du messages.
this.authorizedReplyToUI = const ["text"],
```

## Configuration Back-End

Par défaut, les interfaces de configuration Back-End ont déjà un override :

```Dart
// Configuration Back-End
"tchat_backend": TchatBackEndConfig(
  tchatInterface = const TchatController(),
  messageInterface = const MessageController(),
),
```

Si vous souhaitez utiliser votre propre Back-End, vous devez uniquement créer vos controller en héritant de `TchatInterface` et `MessageInterface`.

## Tchat One-to-One & Group

Les tchats One-To-One et de Groupe fonctionne de la même façon, il n'y a pas besoin de configuration spécifique à faire.

La seule chose nécessaire et de définir le type de tchat `TchatModel.tchatType` dans le model.

## Permissions

Afin de pouvoir utiliser le tchat, votre application à besoin des permissions standart :

1. IOS :

```plist
/// Camera / Micro / Gallery
<key>NSCameraUsageDescription</key>
<string>$AppName a besoin d'avoir accès à votre caméra.</string>
<key>NSMicrophoneUsageDescription</key>
<string>$AppName a besoin d'avoir accès à votre microphone.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>$AppName a besoin d'avoir accès à votre galerie.</string>
<key>UIApplicationSupportsIndirectInputEvents</key>

/// Background Mode & Notification
<key>UIBackgroundModes</key>
<array>
  <string>fetch</string>
  <string>processing</string>
  <string>remote-notification</string>
</array>
```


2. Android:


---

# Messages Customs

Comme vu en [Configuration \& Interface](#configuration--interface) vous pouvez ajouter vos propres types de message (exemple: Devis, ..).

Pour que le tchat utilise votre propre builder, vous devez uniquement définir le type de message ainsi que les Metadata (optionnel).

## Envoyer un Message Custom

Afin d'envoyer un message custom vous pouvez utiliser les fonctions du controller configuré dans votre tchat.
Vous avez à votre disposition plusieurs fonctions pour récupérer la fonction d'envoi de message.

```Dart
getTchatBackEndConfig().messageInterface.sendMessage(context, ref, tchat, model, uuid);
```

- `uuid`: ID unique du message, par défaut, le tchat utilise le package `uuid`.
- `tchat`: Model de votre tchat actuel, l'envoi de messages utilise uniquement informations suivantes : id, tchatPicture, tchatName et tchatType.
- `model`: Votre message

Vous avez ci-dessous la fonction d'envoi de message définir par le controller par défaut :

```Dart
@override
Future<void> sendMessage(BuildContext context, WidgetRef ref, TchatModel tchat, MessageModel model, String uuid) async {
  /// Ajoute votre message au tchat
  await FirebaseFirestore.instance.collection("tchat").doc(tchat.id).collection("messages").doc(uuid).set(
    {
      ...model.copyWith(sendStatus: "send").toJson(),
      "sendAt": FieldValue.serverTimestamp(),
    },
  );

  /// Met à jour le dernier message envoyé dans le tchat.
  await FirebaseFirestore.instance.collection("tchat").doc(tchat.id).update({
    "lastMessage": {
      ...model.copyWith(sendStatus: "send").toJson(),
      "sendAt": FieldValue.serverTimestamp(),
    },
    "lastMessageSeenBy": [FirebaseAuth.instance.currentUser!.uid],
    "lastMessageSentAt": FieldValue.serverTimestamp(),
  });

  /// Permet d'envoyer une push notifications aux autres utilisateurs
  final userName = ref.read(userProvider).user?.firstname ?? "";
  await NotifPermissionController.sendNotification(
    tchat.participants.where((element) => element != FirebaseAuth.instance.currentUser!.uid).toList(),
    title: "package.tchat.notification.new_message.title".tr(),
    body: "package.tchat.notification.new_message.body".tr(args: [userName]),
    type: "tchat_message",
    metadata: {
      "tchatId": tchat.id,
      "tchatPicture": tchat.tchatPicture,
      "tchatName": tchat.tchatName,
      "tchatType": enumToString(tchat.type),
      "messageId": uuid,
    },
  );
}
```

## Configurer les messages customs

Pour afficher les messages customs, merci de vous relater à la section [Configuration \& Interface](#configuration--interface).

## Exemple

Vous avez ci-dessous un exemple de message custom.

_Affichage du message:_

Dans l'exemple ci-dessous, le message custom est de type "example".

```Dart
/// Configuration de l'affichage du message Custom
"tchat_frontend": TchatFrontEndConfig(
  message: TchatMessageViewConfig(
    messageConfig: TchatMessageConfig(
      messageContentBuilders: = const {
        "text": MessageBuilder.textBuilder,
        "media": MessageBuilder.mediaBuilder,
        "event": MessageBuilder.eventBuilder,
        "example": (ctx, ref, tchat, message) => InkWell(...),
      },
    ),
  ),
),
```

_Exemple d'envoi d'un message custom:_

```Dart
/// Envoi du message Custom
await getTchatBackEndConfig().messageInterface.sendMessage(
  context,
  ref,
  tchat,
  MessageModel(
    //...,
    type: "example",
    metadata: {
      "isCompleted": false,
    }
  ), 
  "example-uuid",
);
```

_Exemple de changement d'état du message_

```Dart
/// Changement d'état d'un message Custom
InkWell(
  onTap: () => FirebaseFirestore.instance.collection("tchat").doc(tchat.id).collection("messages").doc(message.id).update({
    "metadata": {
      "isCompleted": true,
    }
  })
  child: Container(
    width: 100,
    height: 100,
    color: (message.metadata?["isCompleted"] ?? false) ? Colors.red : Colors.blue,
  ),
),
```

**_Il est actuellement en développement l'ajout d'un template d'un message de devis. Pour en savoir plus sur ce message, merci de revenir vers @Maxence avant de vous lancer dans un développement._**
