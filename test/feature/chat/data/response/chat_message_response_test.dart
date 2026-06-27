import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/feature/chat/data/response/chat_media_response.dart';
import 'package:klozy/src/feature/chat/data/response/chat_message_response.dart';
import 'package:klozy/src/feature/chat/data/response/chat_offer_response.dart';
import 'package:klozy/src/feature/chat/data/response/chat_purchase_response.dart';
import 'package:klozy/src/feature/chat/data/response/chat_reply_response.dart';

void main() {
  // ── fromJson — scalar fields ─────────────────────────────────────────────────

  group('ChatMessageResponse.fromJson — scalar fields', () {
    test('parses all scalar fields', () {
      final ChatMessageResponse r = ChatMessageResponse.fromJson(
        <String, dynamic>{
          'id': 'msg-1',
          'conversationId': 'conv-1',
          'senderId': 'uid-sender',
          'type': 'text',
          'text': 'Hello!',
          'clientId': 'client-42',
          'readBy': <String>['uid-sender'],
          'createdAt': null,
        },
      );

      expect(r.id, 'msg-1');
      expect(r.conversationId, 'conv-1');
      expect(r.senderId, 'uid-sender');
      expect(r.type, 'text');
      expect(r.text, 'Hello!');
      expect(r.clientId, 'client-42');
      expect(r.readBy, <String>['uid-sender']);
      expect(r.createdAt, isNull);
    });

    test('parses all fields as null when absent', () {
      final ChatMessageResponse r = ChatMessageResponse.fromJson(
        <String, dynamic>{},
      );

      expect(r.id, isNull);
      expect(r.conversationId, isNull);
      expect(r.senderId, isNull);
      expect(r.type, isNull);
      expect(r.text, isNull);
      expect(r.clientId, isNull);
      expect(r.readBy, isNull);
      expect(r.createdAt, isNull);
      expect(r.media, isNull);
      expect(r.replyTo, isNull);
      expect(r.offer, isNull);
      expect(r.purchase, isNull);
    });

    test('parses readBy with multiple uids', () {
      final ChatMessageResponse r = ChatMessageResponse.fromJson(
        <String, dynamic>{
          'readBy': <String>['uid-1', 'uid-2'],
        },
      );

      expect(r.readBy, <String>['uid-1', 'uid-2']);
    });
  });

  // ── fromJson — createdAt via TimestampConverter ───────────────────────────

  group('ChatMessageResponse.fromJson — createdAt', () {
    test('accepts DateTime directly', () {
      final DateTime dt = DateTime(2024, 6, 15, 12, 0, 0);
      final ChatMessageResponse r = ChatMessageResponse.fromJson(
        <String, dynamic>{'createdAt': dt},
      );

      expect(r.createdAt, dt);
    });

    test('accepts int millis', () {
      final DateTime expected = DateTime.fromMillisecondsSinceEpoch(
        1_718_448_000_000,
      );
      final ChatMessageResponse r = ChatMessageResponse.fromJson(
        <String, dynamic>{'createdAt': 1_718_448_000_000},
      );

      expect(r.createdAt, expected);
    });

    test('accepts Firestore Timestamp', () {
      final DateTime dt = DateTime.utc(2024, 6, 15, 12);
      final Timestamp ts = Timestamp.fromDate(dt);
      final ChatMessageResponse r = ChatMessageResponse.fromJson(
        <String, dynamic>{'createdAt': ts},
      );

      expect(r.createdAt, isNotNull);
      expect(r.createdAt!.isAtSameMomentAs(dt), isTrue);
    });

    test('null createdAt yields null', () {
      final ChatMessageResponse r = ChatMessageResponse.fromJson(
        <String, dynamic>{'createdAt': null},
      );

      expect(r.createdAt, isNull);
    });
  });

  // ── fromJson — nested objects ──────────────────────────────────────────────

  group('ChatMessageResponse.fromJson — nested objects', () {
    test('parses replyTo', () {
      final ChatMessageResponse r = ChatMessageResponse.fromJson(
        <String, dynamic>{
          'replyTo': <String, dynamic>{
            'id': 'orig-1',
            'senderId': 'uid-other',
            'type': 'text',
            'text': 'Original',
          },
        },
      );

      expect(r.replyTo, isNotNull);
      expect(r.replyTo!.id, 'orig-1');
      expect(r.replyTo!.text, 'Original');
    });

    test('parses offer', () {
      final ChatMessageResponse r = ChatMessageResponse.fromJson(
        <String, dynamic>{
          'offer': <String, dynamic>{
            'offerId': 'off-1',
            'productName': 'Shoes',
            'listedPrice': 100,
            'offerPrice': 80,
            'accepted': true,
            'cancelled': false,
          },
        },
      );

      expect(r.offer, isNotNull);
      expect(r.offer!.offerId, 'off-1');
      expect(r.offer!.accepted, isTrue);
    });

    test('parses purchase', () {
      final ChatMessageResponse r = ChatMessageResponse.fromJson(
        <String, dynamic>{
          'purchase': <String, dynamic>{
            'orderId': 'ord-1',
            'productName': 'Bag',
            'amount': 150,
          },
        },
      );

      expect(r.purchase, isNotNull);
      expect(r.purchase!.orderId, 'ord-1');
      expect(r.purchase!.amount, 150);
    });

    test('parses media list', () {
      final ChatMessageResponse r = ChatMessageResponse.fromJson(
        <String, dynamic>{
          'media': <Map<String, dynamic>>[
            <String, dynamic>{
              'id': 'media-1',
              'url': 'https://cdn.example.com/img.jpg',
              'type': 'image',
            },
          ],
        },
      );

      expect(r.media, hasLength(1));
      expect(r.media!.first.id, 'media-1');
      expect(r.media!.first.type, 'image');
    });

    test('parses empty media list', () {
      final ChatMessageResponse r = ChatMessageResponse.fromJson(
        <String, dynamic>{'media': <Map<String, dynamic>>[]},
      );

      expect(r.media, isEmpty);
    });
  });

  // ── toJson ──────────────────────────────────────────────────────────────────

  group('ChatMessageResponse.toJson', () {
    test('serialises scalar fields', () {
      const ChatMessageResponse r = ChatMessageResponse(
        id: 'msg-2',
        conversationId: 'conv-2',
        senderId: 'uid-me',
        type: 'text',
        text: 'Hi',
        clientId: 'client-1',
        readBy: <String>['uid-me'],
      );

      final Map<String, dynamic> json = r.toJson();

      expect(json['id'], 'msg-2');
      expect(json['conversationId'], 'conv-2');
      expect(json['senderId'], 'uid-me');
      expect(json['type'], 'text');
      expect(json['text'], 'Hi');
      expect(json['clientId'], 'client-1');
      expect(json['readBy'], <String>['uid-me']);
      expect(json['createdAt'], isNull);
    });

    test('createdAt serialises to Timestamp when set', () {
      final DateTime dt = DateTime.utc(2024, 6, 15, 12);
      final ChatMessageResponse r = ChatMessageResponse(createdAt: dt);

      final Map<String, dynamic> json = r.toJson();

      expect(json['createdAt'], isA<Timestamp>());
      expect(
        (json['createdAt'] as Timestamp).toDate().isAtSameMomentAs(dt),
        isTrue,
      );
    });

    test('serialises nested replyTo via toJson', () {
      const ChatMessageResponse r = ChatMessageResponse(
        replyTo: ChatReplyResponse(id: 'orig-1', type: 'text', text: 'Hi'),
      );

      final Map<String, dynamic> json = r.toJson();

      expect(json['replyTo'], isA<Map<String, dynamic>>());
      expect((json['replyTo'] as Map<String, dynamic>)['id'], 'orig-1');
    });

    test('serialises nested offer via toJson', () {
      const ChatMessageResponse r = ChatMessageResponse(
        offer: ChatOfferResponse(offerId: 'off-1', listedPrice: 100),
      );

      final Map<String, dynamic> json = r.toJson();

      expect(json['offer'], isA<Map<String, dynamic>>());
      expect((json['offer'] as Map<String, dynamic>)['offerId'], 'off-1');
    });

    test('serialises nested purchase via toJson', () {
      const ChatMessageResponse r = ChatMessageResponse(
        purchase: ChatPurchaseResponse(orderId: 'ord-1', amount: 200),
      );

      final Map<String, dynamic> json = r.toJson();

      expect(json['purchase'], isA<Map<String, dynamic>>());
      expect((json['purchase'] as Map<String, dynamic>)['orderId'], 'ord-1');
    });

    test('serialises media list via toJson', () {
      const ChatMessageResponse r = ChatMessageResponse(
        media: <ChatMediaResponse>[
          ChatMediaResponse(id: 'media-1', type: 'image'),
        ],
      );

      final Map<String, dynamic> json = r.toJson();

      expect(json['media'], isA<List<dynamic>>());
      final List<dynamic> mediaList = json['media'] as List<dynamic>;
      expect(mediaList.first, isA<Map<String, dynamic>>());
      expect((mediaList.first as Map<String, dynamic>)['id'], 'media-1');
    });

    test('serialises null optional nested fields as null', () {
      const ChatMessageResponse r = ChatMessageResponse();

      final Map<String, dynamic> json = r.toJson();

      expect(json['replyTo'], isNull);
      expect(json['offer'], isNull);
      expect(json['purchase'], isNull);
      expect(json['media'], isNull);
    });
  });
}
