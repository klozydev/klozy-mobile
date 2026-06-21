import 'package:klozy/src/feature/chat/data/mapper/chat_time_formatter.dart';
import 'package:klozy/src/feature/chat/data/response/chat_media_response.dart';
import 'package:klozy/src/feature/chat/data/response/chat_message_response.dart';
import 'package:klozy/src/feature/chat/domain/entity/chat_media.dart';
import 'package:klozy/src/feature/chat/domain/entity/chat_message.dart';
import 'package:klozy/src/feature/chat/domain/entity/media_type.dart';
import 'package:klozy/src/feature/chat/domain/entity/message_kind.dart';
import 'package:klozy/src/feature/chat/domain/entity/offer_data.dart';
import 'package:klozy/src/feature/chat/domain/entity/purchase_data.dart';

/// Maps a Firestore message doc into the render-ready [ChatMessage] entity.
abstract final class ChatMessageMapper {
  static ChatMessage toEntity(
    ChatMessageResponse r, {
    required String myUid,
    String? myBackendId,
    DateTime? now,
  }) {
    final List<ChatMedia> media = (r.media ?? <ChatMediaResponse>[])
        .map(_media)
        .toList();
    final ChatMessageKind kind = kindFor(r.type, media);

    return ChatMessage(
      id: r.id ?? '',
      threadId: r.conversationId ?? '',
      senderId: r.senderId ?? '',
      kind: kind,
      isMine: _isMine(r.senderId, myUid, myBackendId),
      text: r.text,
      media: media,
      replyTo: r.replyTo == null
          ? null
          : ChatMessage(
              id: r.replyTo!.id ?? '',
              threadId: r.conversationId ?? '',
              senderId: r.replyTo!.senderId ?? '',
              kind: kindFor(r.replyTo!.type, const <ChatMedia>[]),
              isMine: _isMine(r.replyTo!.senderId, myUid, myBackendId),
              text: r.replyTo!.text,
            ),
      offer: r.offer == null
          ? null
          : OfferData(
              offerId: r.offer!.offerId ?? '',
              productName: r.offer!.productName ?? '',
              listedPrice: r.offer!.listedPrice ?? 0,
              offerPrice: r.offer!.offerPrice ?? 0,
              accepted: r.offer!.accepted,
              cancelled: r.offer!.cancelled ?? false,
            ),
      purchase: r.purchase == null
          ? null
          : PurchaseData(
              productName: r.purchase!.productName ?? '',
              amount: r.purchase!.amount ?? 0,
            ),
      sentAt: r.createdAt,
      readBy: r.readBy ?? const <String>[],
      sendStatus: r.createdAt == null ? 'sending' : 'send',
      clientId: r.clientId,
      timeLabel: ChatTimeFormatter.label(r.createdAt, now: now),
    );
  }

  /// A message is mine if its sender matches my Firebase uid OR my backend id
  /// (older / server-mirrored messages may carry the backend id).
  static bool _isMine(String? senderId, String myUid, String? myBackendId) {
    if (senderId == null || senderId.isEmpty) return false;
    return senderId == myUid ||
        (myBackendId != null && senderId == myBackendId);
  }

  static ChatMedia _media(ChatMediaResponse m) => ChatMedia(
    id: m.id,
    url: m.url,
    relativePath: m.relativePath,
    type: MediaType.fromRaw(m.type),
    name: m.name,
    width: m.width,
    height: m.height,
    durationMs: m.durationMs,
    thumbnailUrl: m.thumbnailUrl,
  );

  static ChatMessageKind kindFor(String? type, List<ChatMedia> media) {
    switch (type) {
      case 'text':
        return ChatMessageKind.text;
      case 'audio':
        return ChatMessageKind.audio;
      case 'offer':
        return ChatMessageKind.offer;
      case 'purchase':
        return ChatMessageKind.purchase;
      case 'event':
        return ChatMessageKind.event;
      case 'media':
        if (media.isEmpty) return ChatMessageKind.file;
        switch (media.first.type) {
          case MediaType.image:
            return ChatMessageKind.image;
          case MediaType.video:
            return ChatMessageKind.video;
          case MediaType.audio:
            return ChatMessageKind.audio;
          case MediaType.other:
            return ChatMessageKind.file;
        }
      default:
        return ChatMessageKind.text;
    }
  }
}
