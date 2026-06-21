import 'package:equatable/equatable.dart';
import 'package:klozy/src/feature/chat/domain/entity/chat_media.dart';
import 'package:klozy/src/feature/chat/domain/entity/message_kind.dart';
import 'package:klozy/src/feature/chat/domain/entity/offer_data.dart';
import 'package:klozy/src/feature/chat/domain/entity/purchase_data.dart';

/// A single chat message. Maps 1:1 to a `chat/{id}/messages/{messageId}` doc.
///
/// [kind] is derived in the mapper from the raw `messageType` (+ media type);
/// [isMine] and [timeLabel] are computed against the current user / clock so
/// the widgets stay presentation-dumb.
class ChatMessage extends Equatable {
  final String id;
  final String threadId;
  final String senderId;
  final ChatMessageKind kind;
  final bool isMine;
  final String? text;
  final List<ChatMedia> media;
  final ChatMessage? replyTo;
  final OfferData? offer;
  final PurchaseData? purchase;
  final DateTime? sentAt;
  final List<String> readBy;
  final String? sendStatus;

  /// Client-generated correlation id — lets the optimistic bubble be matched to
  /// (and replaced by) the real message once the Firestore stream echoes it.
  final String? clientId;

  /// Pre-formatted short timestamp for the bubble (e.g. `10:24`, `now`).
  final String timeLabel;

  const ChatMessage({
    required this.id,
    required this.threadId,
    required this.senderId,
    required this.kind,
    required this.isMine,
    this.text,
    this.media = const <ChatMedia>[],
    this.replyTo,
    this.offer,
    this.purchase,
    this.sentAt,
    this.readBy = const <String>[],
    this.sendStatus,
    this.clientId,
    this.timeLabel = '',
  });

  ChatMessage copyWith({String? sendStatus}) {
    return ChatMessage(
      id: id,
      threadId: threadId,
      senderId: senderId,
      kind: kind,
      isMine: isMine,
      text: text,
      media: media,
      replyTo: replyTo,
      offer: offer,
      purchase: purchase,
      sentAt: sentAt,
      readBy: readBy,
      sendStatus: sendStatus ?? this.sendStatus,
      clientId: clientId,
      timeLabel: timeLabel,
    );
  }

  /// First media asset, if any (images/videos/audio carry a single asset here).
  ChatMedia? get firstMedia => media.isEmpty ? null : media.first;

  bool get isSending => sendStatus == 'sending';

  bool get isFailed => sendStatus == 'failed';

  @override
  List<Object?> get props => <Object?>[
    id,
    threadId,
    senderId,
    kind,
    isMine,
    text,
    media,
    replyTo,
    offer,
    purchase,
    sentAt,
    readBy,
    sendStatus,
    clientId,
    timeLabel,
  ];
}
