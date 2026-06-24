import 'package:json_annotation/json_annotation.dart';
import 'package:klozy/src/feature/chat/data/converter/timestamp_converter.dart';
import 'package:klozy/src/feature/chat/data/response/chat_media_response.dart';
import 'package:klozy/src/feature/chat/data/response/chat_offer_response.dart';
import 'package:klozy/src/feature/chat/data/response/chat_purchase_response.dart';
import 'package:klozy/src/feature/chat/data/response/chat_reply_response.dart';

part 'chat_message_response.g.dart';

/// A message doc: `conversations/{conversationId}/messages/{messageId}`.
// explicitToJson so nested objects (replyTo/media/offer/purchase) serialize to
// maps — Firestore can't encode the response instances directly.
@JsonSerializable(explicitToJson: true)
class ChatMessageResponse {
  final String? id;
  final String? conversationId;
  final String? senderId;

  /// `text` | `media` | `audio` | `offer` | `purchase` | `event`.
  final String? type;
  final String? text;
  final List<ChatMediaResponse>? media;
  final ChatReplyResponse? replyTo;
  final ChatOfferResponse? offer;
  final ChatPurchaseResponse? purchase;
  final List<String>? readBy;
  final String? clientId;

  @TimestampConverter()
  final DateTime? createdAt;

  const ChatMessageResponse({
    this.id,
    this.conversationId,
    this.senderId,
    this.type,
    this.text,
    this.media,
    this.replyTo,
    this.offer,
    this.purchase,
    this.readBy,
    this.clientId,
    this.createdAt,
  });

  factory ChatMessageResponse.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ChatMessageResponseToJson(this);
}
