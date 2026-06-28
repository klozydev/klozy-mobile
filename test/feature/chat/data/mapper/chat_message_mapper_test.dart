import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/feature/chat/data/mapper/chat_message_mapper.dart';
import 'package:klozy/src/feature/chat/data/response/chat_media_response.dart';
import 'package:klozy/src/feature/chat/data/response/chat_message_response.dart';
import 'package:klozy/src/feature/chat/data/response/chat_offer_response.dart';
import 'package:klozy/src/feature/chat/data/response/chat_purchase_response.dart';
import 'package:klozy/src/feature/chat/data/response/chat_reply_response.dart';
import 'package:klozy/src/feature/chat/domain/entity/chat_media.dart';
import 'package:klozy/src/feature/chat/domain/entity/media_type.dart';
import 'package:klozy/src/feature/chat/domain/entity/message_kind.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

const String _myUid = 'uid-me';
const String _myBackendId = 'backend-me';
const String _otherUid = 'uid-other';

/// Fixed reference time so time-label assertions are deterministic.
final DateTime _now = DateTime(2024, 6, 15, 14, 0, 0);

ChatMessageResponse _textResponse({
  String? id = 'msg-1',
  String? conversationId = 'thread-1',
  String? senderId = _myUid,
  String? text = 'Hello!',
  DateTime? createdAt,
  List<String>? readBy,
  String? clientId,
}) => ChatMessageResponse(
  id: id,
  conversationId: conversationId,
  senderId: senderId,
  type: 'text',
  text: text,
  readBy: readBy,
  clientId: clientId,
  createdAt: createdAt,
);

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // -------------------------------------------------------------------------
  // Basic field mapping
  // -------------------------------------------------------------------------

  group('ChatMessageMapper.toEntity — basic fields', () {
    late final dynamic msg;
    setUpAll(() {
      final sentAt = DateTime(2024, 6, 15, 13, 59, 0);
      msg = ChatMessageMapper.toEntity(
        _textResponse(
          createdAt: sentAt,
          readBy: <String>[_myUid],
          clientId: 'client-42',
        ),
        myUid: _myUid,
        myBackendId: _myBackendId,
        now: _now,
      );
    });

    test('id', () => expect(msg.id, 'msg-1'));
    test('threadId', () => expect(msg.threadId, 'thread-1'));
    test('senderId', () => expect(msg.senderId, _myUid));
    test('kind text', () => expect(msg.kind, ChatMessageKind.text));
    test('isMine true', () => expect(msg.isMine, isTrue));
    test('text', () => expect(msg.text, 'Hello!'));
    test('media empty', () => expect(msg.media, isEmpty));
    test('replyTo null', () => expect(msg.replyTo, isNull));
    test('offer null', () => expect(msg.offer, isNull));
    test('purchase null', () => expect(msg.purchase, isNull));
    test('readBy', () => expect(msg.readBy, <String>[_myUid]));
    test('clientId', () => expect(msg.clientId, 'client-42'));
    test(
      'sendStatus send when createdAt present',
      () => expect(msg.sendStatus, 'send'),
    );
    test('timeLabel not empty', () => expect(msg.timeLabel, isNotEmpty));
  });

  // -------------------------------------------------------------------------
  // isMine logic
  // -------------------------------------------------------------------------

  group('ChatMessageMapper.toEntity — isMine', () {
    test('isMine false when senderId is other uid', () {
      final msg = ChatMessageMapper.toEntity(
        _textResponse(senderId: _otherUid),
        myUid: _myUid,
        now: _now,
      );
      expect(msg.isMine, isFalse);
    });

    test('isMine true when senderId matches myBackendId', () {
      final msg = ChatMessageMapper.toEntity(
        _textResponse(senderId: _myBackendId),
        myUid: _myUid,
        myBackendId: _myBackendId,
        now: _now,
      );
      expect(msg.isMine, isTrue);
    });

    test('isMine false when senderId is null', () {
      final msg = ChatMessageMapper.toEntity(
        const ChatMessageResponse(senderId: null),
        myUid: _myUid,
        now: _now,
      );
      expect(msg.isMine, isFalse);
    });

    test('isMine false when senderId is empty', () {
      final msg = ChatMessageMapper.toEntity(
        const ChatMessageResponse(senderId: ''),
        myUid: _myUid,
        now: _now,
      );
      expect(msg.isMine, isFalse);
    });
  });

  // -------------------------------------------------------------------------
  // sendStatus
  // -------------------------------------------------------------------------

  group('ChatMessageMapper.toEntity — sendStatus', () {
    test('sendStatus "sending" when createdAt is null', () {
      final msg = ChatMessageMapper.toEntity(
        _textResponse(createdAt: null),
        myUid: _myUid,
        now: _now,
      );
      expect(msg.sendStatus, 'sending');
    });

    test('sendStatus "send" when createdAt present', () {
      final msg = ChatMessageMapper.toEntity(
        _textResponse(createdAt: DateTime(2024, 6, 15, 10)),
        myUid: _myUid,
        now: _now,
      );
      expect(msg.sendStatus, 'send');
    });
  });

  // -------------------------------------------------------------------------
  // replyTo
  // -------------------------------------------------------------------------

  group('ChatMessageMapper.toEntity — replyTo', () {
    test('replyTo mapped correctly', () {
      const response = ChatMessageResponse(
        id: 'msg-2',
        conversationId: 'thread-1',
        senderId: _myUid,
        type: 'text',
        text: 'Reply here',
        replyTo: ChatReplyResponse(
          id: 'orig-1',
          senderId: _otherUid,
          type: 'text',
          text: 'Original text',
        ),
      );
      final msg = ChatMessageMapper.toEntity(
        response,
        myUid: _myUid,
        now: _now,
      );
      expect(msg.replyTo, isNotNull);
      expect(msg.replyTo!.id, 'orig-1');
      expect(msg.replyTo!.senderId, _otherUid);
      expect(msg.replyTo!.text, 'Original text');
      expect(msg.replyTo!.isMine, isFalse);
    });

    test('replyTo null when response.replyTo is null', () {
      final msg = ChatMessageMapper.toEntity(
        _textResponse(),
        myUid: _myUid,
        now: _now,
      );
      expect(msg.replyTo, isNull);
    });
  });

  // -------------------------------------------------------------------------
  // offer
  // -------------------------------------------------------------------------

  group('ChatMessageMapper.toEntity — offer', () {
    test('offer mapped correctly', () {
      const response = ChatMessageResponse(
        id: 'msg-3',
        conversationId: 'thread-1',
        senderId: _otherUid,
        type: 'offer',
        offer: ChatOfferResponse(
          offerId: 'off-1',
          productName: 'Nike Shoes',
          listedPrice: 100,
          offerPrice: 80,
          accepted: true,
          cancelled: false,
        ),
      );
      final msg = ChatMessageMapper.toEntity(
        response,
        myUid: _myUid,
        now: _now,
      );
      expect(msg.offer, isNotNull);
      expect(msg.offer!.offerId, 'off-1');
      expect(msg.offer!.productName, 'Nike Shoes');
      expect(msg.offer!.listedPrice, 100);
      expect(msg.offer!.offerPrice, 80);
      expect(msg.offer!.accepted, isTrue);
      expect(msg.offer!.cancelled, isFalse);
      expect(msg.kind, ChatMessageKind.offer);
    });

    test('offer cancelled defaults to false when null', () {
      const response = ChatMessageResponse(
        id: 'msg-4',
        conversationId: 'thread-1',
        senderId: _otherUid,
        type: 'offer',
        offer: ChatOfferResponse(
          offerId: 'off-2',
          productName: 'Shoes',
          listedPrice: 50,
          offerPrice: 40,
          // cancelled is null → should default to false
        ),
      );
      final msg = ChatMessageMapper.toEntity(
        response,
        myUid: _myUid,
        now: _now,
      );
      expect(msg.offer!.cancelled, isFalse);
    });
  });

  // -------------------------------------------------------------------------
  // purchase
  // -------------------------------------------------------------------------

  group('ChatMessageMapper.toEntity — purchase', () {
    test('purchase mapped correctly', () {
      const response = ChatMessageResponse(
        id: 'msg-5',
        conversationId: 'thread-1',
        senderId: _myUid,
        type: 'purchase',
        purchase: ChatPurchaseResponse(productName: 'Jacket', amount: 200),
      );
      final msg = ChatMessageMapper.toEntity(
        response,
        myUid: _myUid,
        now: _now,
      );
      expect(msg.purchase, isNotNull);
      expect(msg.purchase!.productName, 'Jacket');
      expect(msg.purchase!.amount, 200);
      expect(msg.kind, ChatMessageKind.purchase);
    });
  });

  // -------------------------------------------------------------------------
  // media
  // -------------------------------------------------------------------------

  group('ChatMessageMapper.toEntity — media', () {
    test('media list mapped correctly', () {
      const response = ChatMessageResponse(
        id: 'msg-6',
        conversationId: 'thread-1',
        senderId: _myUid,
        type: 'media',
        media: <ChatMediaResponse>[
          ChatMediaResponse(
            id: 'media-1',
            url: 'https://cdn.example.com/photo.jpg',
            type: 'image',
            name: 'photo.jpg',
            width: 1080,
            height: 720,
            thumbnailUrl: 'https://cdn.example.com/thumb.jpg',
            relativePath: 'chat_media/conv/media-1.jpg',
          ),
        ],
      );
      final msg = ChatMessageMapper.toEntity(
        response,
        myUid: _myUid,
        now: _now,
      );
      expect(msg.media, hasLength(1));
      expect(msg.media.first.id, 'media-1');
      expect(msg.media.first.url, 'https://cdn.example.com/photo.jpg');
      expect(msg.media.first.type, MediaType.image);
      expect(msg.media.first.name, 'photo.jpg');
      expect(msg.media.first.width, 1080);
      expect(msg.media.first.height, 720);
      expect(msg.media.first.thumbnailUrl, 'https://cdn.example.com/thumb.jpg');
      expect(msg.media.first.relativePath, 'chat_media/conv/media-1.jpg');
      expect(msg.kind, ChatMessageKind.image);
    });

    test('video media → kind video', () {
      const response = ChatMessageResponse(
        id: 'msg-7',
        conversationId: 'thread-1',
        senderId: _myUid,
        type: 'media',
        media: <ChatMediaResponse>[
          ChatMediaResponse(type: 'video', durationMs: 5000),
        ],
      );
      final msg = ChatMessageMapper.toEntity(
        response,
        myUid: _myUid,
        now: _now,
      );
      expect(msg.kind, ChatMessageKind.video);
      expect(msg.media.first.durationMs, 5000);
    });

    test('audio media → kind audio', () {
      const response = ChatMessageResponse(
        id: 'msg-8',
        conversationId: 'thread-1',
        senderId: _myUid,
        type: 'media',
        media: <ChatMediaResponse>[ChatMediaResponse(type: 'audio')],
      );
      final msg = ChatMessageMapper.toEntity(
        response,
        myUid: _myUid,
        now: _now,
      );
      expect(msg.kind, ChatMessageKind.audio);
    });

    test('other media type → kind file', () {
      const response = ChatMessageResponse(
        id: 'msg-9',
        conversationId: 'thread-1',
        senderId: _myUid,
        type: 'media',
        media: <ChatMediaResponse>[ChatMediaResponse(type: 'document')],
      );
      final msg = ChatMessageMapper.toEntity(
        response,
        myUid: _myUid,
        now: _now,
      );
      expect(msg.kind, ChatMessageKind.file);
      expect(msg.media.first.type, MediaType.other);
    });

    test('media type with empty media list → kind file', () {
      const response = ChatMessageResponse(
        id: 'msg-10',
        conversationId: 'thread-1',
        senderId: _myUid,
        type: 'media',
        media: <ChatMediaResponse>[],
      );
      final msg = ChatMessageMapper.toEntity(
        response,
        myUid: _myUid,
        now: _now,
      );
      expect(msg.kind, ChatMessageKind.file);
    });

    test('null media → empty list', () {
      final msg = ChatMessageMapper.toEntity(
        _textResponse(),
        myUid: _myUid,
        now: _now,
      );
      expect(msg.media, isEmpty);
    });
  });

  // -------------------------------------------------------------------------
  // kindFor — all type branches
  // -------------------------------------------------------------------------

  group('ChatMessageMapper.kindFor', () {
    const List<ChatMedia> noMedia = <ChatMedia>[];
    test(
      'text',
      () => expect(
        ChatMessageMapper.kindFor('text', noMedia),
        ChatMessageKind.text,
      ),
    );
    test(
      'audio',
      () => expect(
        ChatMessageMapper.kindFor('audio', noMedia),
        ChatMessageKind.audio,
      ),
    );
    test(
      'offer',
      () => expect(
        ChatMessageMapper.kindFor('offer', noMedia),
        ChatMessageKind.offer,
      ),
    );
    test(
      'purchase',
      () => expect(
        ChatMessageMapper.kindFor('purchase', noMedia),
        ChatMessageKind.purchase,
      ),
    );
    test(
      'event',
      () => expect(
        ChatMessageMapper.kindFor('event', noMedia),
        ChatMessageKind.event,
      ),
    );
    test(
      'null type → text',
      () => expect(
        ChatMessageMapper.kindFor(null, noMedia),
        ChatMessageKind.text,
      ),
    );
    test(
      'unknown type → text',
      () => expect(
        ChatMessageMapper.kindFor('unknown_xyz', noMedia),
        ChatMessageKind.text,
      ),
    );
  });

  // -------------------------------------------------------------------------
  // Null fields — safe defaults
  // -------------------------------------------------------------------------

  group('ChatMessageMapper.toEntity — null id/conversationId/senderId', () {
    test('null id defaults to empty string', () {
      final msg = ChatMessageMapper.toEntity(
        const ChatMessageResponse(
          id: null,
          conversationId: null,
          senderId: null,
        ),
        myUid: _myUid,
        now: _now,
      );
      expect(msg.id, isEmpty);
      expect(msg.threadId, isEmpty);
      expect(msg.senderId, isEmpty);
    });
  });
}
