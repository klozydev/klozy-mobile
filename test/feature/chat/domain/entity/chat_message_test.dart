import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/feature/chat/domain/entity/chat_media.dart';
import 'package:klozy/src/feature/chat/domain/entity/chat_message.dart';
import 'package:klozy/src/feature/chat/domain/entity/media_type.dart';
import 'package:klozy/src/feature/chat/domain/entity/message_kind.dart';
import 'package:klozy/src/feature/chat/domain/entity/offer_data.dart';
import 'package:klozy/src/feature/chat/domain/entity/purchase_data.dart';

void main() {
  const ChatMedia mediaAsset = ChatMedia(
    id: 'med-1',
    url: 'https://example.com/img.jpg',
    type: MediaType.image,
  );

  const OfferData offerPayload = OfferData(
    offerId: 'off-1',
    productName: 'Jacket',
    listedPrice: 500,
    offerPrice: 400,
  );

  const PurchaseData purchasePayload = PurchaseData(
    productName: 'Jacket',
    amount: 400,
  );

  final DateTime sentAt = DateTime(2024, 8, 1, 12);

  group('ChatMessage', () {
    final ChatMessage full = ChatMessage(
      id: 'msg-1',
      threadId: 'thread-1',
      senderId: 'u1',
      kind: ChatMessageKind.text,
      isMine: true,
      text: 'Hello!',
      media: const <ChatMedia>[mediaAsset],
      offer: offerPayload,
      purchase: purchasePayload,
      sentAt: sentAt,
      readBy: const <String>['u2'],
      sendStatus: 'sent',
      clientId: 'client-abc',
      timeLabel: '12:00',
    );

    test('getters return constructor values', () {
      expect(full.id, 'msg-1');
      expect(full.threadId, 'thread-1');
      expect(full.senderId, 'u1');
      expect(full.kind, ChatMessageKind.text);
      expect(full.isMine, isTrue);
      expect(full.text, 'Hello!');
      expect(full.media, <ChatMedia>[mediaAsset]);
      expect(full.offer, offerPayload);
      expect(full.purchase, purchasePayload);
      expect(full.sentAt, sentAt);
      expect(full.readBy, <String>['u2']);
      expect(full.sendStatus, 'sent');
      expect(full.clientId, 'client-abc');
      expect(full.timeLabel, '12:00');
    });

    test('defaults for optional fields', () {
      const ChatMessage minimal = ChatMessage(
        id: 'msg-2',
        threadId: 'thread-1',
        senderId: 'u1',
        kind: ChatMessageKind.text,
        isMine: false,
      );
      expect(minimal.text, isNull);
      expect(minimal.media, isEmpty);
      expect(minimal.replyTo, isNull);
      expect(minimal.offer, isNull);
      expect(minimal.purchase, isNull);
      expect(minimal.sentAt, isNull);
      expect(minimal.readBy, isEmpty);
      expect(minimal.sendStatus, isNull);
      expect(minimal.clientId, isNull);
      expect(minimal.timeLabel, '');
    });

    test('firstMedia returns first element when media is non-empty', () {
      expect(full.firstMedia, mediaAsset);
    });

    test('firstMedia returns null when media is empty', () {
      const ChatMessage noMedia = ChatMessage(
        id: 'msg-3',
        threadId: 'thread-1',
        senderId: 'u1',
        kind: ChatMessageKind.text,
        isMine: false,
      );
      expect(noMedia.firstMedia, isNull);
    });

    test('isSending is true when sendStatus is "sending"', () {
      final ChatMessage sending = full.copyWith(sendStatus: 'sending');
      expect(sending.isSending, isTrue);
    });

    test('isSending is false when sendStatus is "sent"', () {
      expect(full.isSending, isFalse);
    });

    test('isFailed is true when sendStatus is "failed"', () {
      final ChatMessage failed = full.copyWith(sendStatus: 'failed');
      expect(failed.isFailed, isTrue);
    });

    test('isFailed is false when sendStatus is null', () {
      const ChatMessage noStatus = ChatMessage(
        id: 'msg-4',
        threadId: 'thread-1',
        senderId: 'u1',
        kind: ChatMessageKind.text,
        isMine: false,
      );
      expect(noStatus.isFailed, isFalse);
    });

    test('copyWith changes sendStatus', () {
      final ChatMessage updated = full.copyWith(sendStatus: 'failed');
      expect(updated.sendStatus, 'failed');
      expect(updated.id, full.id);
      expect(updated.text, full.text);
    });

    test('copyWith with null sendStatus keeps original sendStatus', () {
      final ChatMessage updated = full.copyWith();
      expect(updated.sendStatus, full.sendStatus);
    });

    test('two instances with same fields are equal', () {
      final ChatMessage other = ChatMessage(
        id: 'msg-1',
        threadId: 'thread-1',
        senderId: 'u1',
        kind: ChatMessageKind.text,
        isMine: true,
        text: 'Hello!',
        media: const <ChatMedia>[mediaAsset],
        offer: offerPayload,
        purchase: purchasePayload,
        sentAt: sentAt,
        readBy: const <String>['u2'],
        sendStatus: 'sent',
        clientId: 'client-abc',
        timeLabel: '12:00',
      );
      expect(full, equals(other));
      expect(full.hashCode, equals(other.hashCode));
    });

    test('instances with different id are not equal', () {
      const ChatMessage other = ChatMessage(
        id: 'msg-X',
        threadId: 'thread-1',
        senderId: 'u1',
        kind: ChatMessageKind.text,
        isMine: false,
      );
      expect(full, isNot(equals(other)));
    });
  });
}
