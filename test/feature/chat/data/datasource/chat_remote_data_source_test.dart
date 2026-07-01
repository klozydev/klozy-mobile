// ignore_for_file: subtype_of_sealed_class, avoid_implementing_value_types
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/feature/chat/data/datasource/chat_remote_data_source.dart';
import 'package:klozy/src/feature/chat/data/response/chat_message_response.dart';
import 'package:klozy/src/feature/chat/data/response/conversation_response.dart';
import 'package:mocktail/mocktail.dart';

// ── Mocks ────────────────────────────────────────────────────────────────────

class _MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

class _MockCollectionReference extends Mock
    implements CollectionReference<Map<String, dynamic>> {}

class _MockDocumentReference extends Mock
    implements DocumentReference<Map<String, dynamic>> {}

class _MockQuery extends Mock implements Query<Map<String, dynamic>> {}

class _MockQuerySnapshot extends Mock
    implements QuerySnapshot<Map<String, dynamic>> {}

class _MockQueryDocumentSnapshot extends Mock
    implements QueryDocumentSnapshot<Map<String, dynamic>> {}

class _MockDocumentSnapshot extends Mock
    implements DocumentSnapshot<Map<String, dynamic>> {}

class _MockWriteBatch extends Mock implements WriteBatch {}

class _MockFirebaseStorage extends Mock implements FirebaseStorage {}

// ── Helpers ───────────────────────────────────────────────────────────────────

_MockQueryDocumentSnapshot _makeDoc(String id, Map<String, dynamic> data) {
  final _MockQueryDocumentSnapshot doc = _MockQueryDocumentSnapshot();
  when(() => doc.id).thenReturn(id);
  when(() => doc.data()).thenReturn(data);
  return doc;
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  late _MockFirebaseFirestore mockDb;
  late _MockFirebaseStorage mockStorage;
  late _MockCollectionReference mockCol;
  late _MockCollectionReference mockMsgCol;
  late _MockDocumentReference mockDocRef;
  late _MockDocumentReference mockMsgDocRef;
  late _MockQuery mockQuery;
  late _MockQuerySnapshot mockQuerySnapshot;
  late _MockDocumentSnapshot mockDocSnapshot;
  late _MockWriteBatch mockBatch;
  late ChatRemoteDataSource datasource;

  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
    registerFallbackValue(SetOptions(merge: true));
    // DocumentReference is non-nullable in WriteBatch.set — register a fallback
    // so any() can match it without throwing.
    registerFallbackValue(_MockDocumentReference());
  });

  setUp(() {
    mockDb = _MockFirebaseFirestore();
    mockStorage = _MockFirebaseStorage();
    mockCol = _MockCollectionReference();
    mockMsgCol = _MockCollectionReference();
    mockDocRef = _MockDocumentReference();
    mockMsgDocRef = _MockDocumentReference();
    mockQuery = _MockQuery();
    mockQuerySnapshot = _MockQuerySnapshot();
    mockDocSnapshot = _MockDocumentSnapshot();
    mockBatch = _MockWriteBatch();

    when(() => mockDb.collection('chat')).thenReturn(mockCol);
    when(() => mockCol.doc(any())).thenReturn(mockDocRef);
    when(() => mockDocRef.collection('messages')).thenReturn(mockMsgCol);
    when(() => mockMsgCol.doc()).thenReturn(mockMsgDocRef);
    when(() => mockMsgDocRef.id).thenReturn('auto-msg-id');

    datasource = ChatRemoteDataSource(mockDb, mockStorage);
  });

  // ── conversationId (static) ──────────────────────────────────────────────────

  group('ChatRemoteDataSource.conversationId', () {
    test('sorts uids and joins with underscore', () {
      expect(ChatRemoteDataSource.conversationId('bbb', 'aaa'), 'aaa_bbb');
    });

    test('is commutative', () {
      const String a = 'uid-alice';
      const String b = 'uid-bob';
      expect(
        ChatRemoteDataSource.conversationId(a, b),
        ChatRemoteDataSource.conversationId(b, a),
      );
    });

    test('uid that sorts first appears before underscore', () {
      final String result = ChatRemoteDataSource.conversationId(
        'z-uid',
        'a-uid',
      );
      expect(result, 'a-uid_z-uid');
    });
  });

  // ── watchThreads ─────────────────────────────────────────────────────────────

  group('ChatRemoteDataSource.watchThreads', () {
    void stubThreadQuery() {
      when(
        () => mockCol.where(
          'participantIds',
          arrayContains: any(named: 'arrayContains'),
        ),
      ).thenReturn(mockQuery);
      when(
        () => mockQuery.orderBy(
          'lastMessageAt',
          descending: any(named: 'descending'),
        ),
      ).thenReturn(mockQuery);
    }

    test('emits empty list when no docs', () async {
      stubThreadQuery();
      when(() => mockQuery.snapshots()).thenAnswer(
        (_) => Stream<QuerySnapshot<Map<String, dynamic>>>.value(
          mockQuerySnapshot,
        ),
      );
      when(
        () => mockQuerySnapshot.docs,
      ).thenReturn(<QueryDocumentSnapshot<Map<String, dynamic>>>[]);

      final List<ConversationResponse> result = await datasource
          .watchThreads('my-uid')
          .first;

      expect(result, isEmpty);
    });

    test('filters out conversations deleted for myUid', () async {
      stubThreadQuery();
      final _MockQueryDocumentSnapshot doc = _makeDoc(
        'conv-1',
        <String, dynamic>{
          'participantIds': <dynamic>['my-uid', 'other'],
          'deletedFor': <dynamic>['my-uid'],
          'unreadCounts': <String, dynamic>{},
        },
      );
      when(() => mockQuery.snapshots()).thenAnswer(
        (_) => Stream<QuerySnapshot<Map<String, dynamic>>>.value(
          mockQuerySnapshot,
        ),
      );
      when(
        () => mockQuerySnapshot.docs,
      ).thenReturn(<QueryDocumentSnapshot<Map<String, dynamic>>>[doc]);

      final List<ConversationResponse> result = await datasource
          .watchThreads('my-uid')
          .first;

      expect(result, isEmpty);
    });

    test('includes conversations not deleted for myUid', () async {
      stubThreadQuery();
      final _MockQueryDocumentSnapshot doc = _makeDoc(
        'conv-2',
        <String, dynamic>{
          'participantIds': <dynamic>['my-uid', 'other'],
          'deletedFor': <dynamic>[],
          'unreadCounts': <String, dynamic>{},
        },
      );
      when(() => mockQuery.snapshots()).thenAnswer(
        (_) => Stream<QuerySnapshot<Map<String, dynamic>>>.value(
          mockQuerySnapshot,
        ),
      );
      when(
        () => mockQuerySnapshot.docs,
      ).thenReturn(<QueryDocumentSnapshot<Map<String, dynamic>>>[doc]);

      final List<ConversationResponse> result = await datasource
          .watchThreads('my-uid')
          .first;

      expect(result, hasLength(1));
      expect(result.first.id, 'conv-2');
    });

    test('handles missing deletedFor field (treats as empty)', () async {
      stubThreadQuery();
      final _MockQueryDocumentSnapshot doc = _makeDoc(
        'conv-3',
        <String, dynamic>{
          'participantIds': <dynamic>['my-uid', 'other'],
          // no 'deletedFor' key
          'unreadCounts': <String, dynamic>{},
        },
      );
      when(() => mockQuery.snapshots()).thenAnswer(
        (_) => Stream<QuerySnapshot<Map<String, dynamic>>>.value(
          mockQuerySnapshot,
        ),
      );
      when(
        () => mockQuerySnapshot.docs,
      ).thenReturn(<QueryDocumentSnapshot<Map<String, dynamic>>>[doc]);

      final List<ConversationResponse> result = await datasource
          .watchThreads('my-uid')
          .first;

      expect(result, hasLength(1));
    });
  });

  // ── watchThread ──────────────────────────────────────────────────────────────

  group('ChatRemoteDataSource.watchThread', () {
    test('emits null when doc does not exist', () async {
      when(() => mockDocRef.snapshots()).thenAnswer(
        (_) => Stream<DocumentSnapshot<Map<String, dynamic>>>.value(
          mockDocSnapshot,
        ),
      );
      when(() => mockDocSnapshot.exists).thenReturn(false);
      when(() => mockDocSnapshot.data()).thenReturn(null);

      final ConversationResponse? result = await datasource
          .watchThread('conv-1')
          .first;

      expect(result, isNull);
    });

    test('emits null when doc data is null', () async {
      when(() => mockDocRef.snapshots()).thenAnswer(
        (_) => Stream<DocumentSnapshot<Map<String, dynamic>>>.value(
          mockDocSnapshot,
        ),
      );
      when(() => mockDocSnapshot.exists).thenReturn(true);
      when(() => mockDocSnapshot.data()).thenReturn(null);

      final ConversationResponse? result = await datasource
          .watchThread('conv-1')
          .first;

      expect(result, isNull);
    });

    test('emits ConversationResponse when doc exists', () async {
      when(() => mockDocRef.snapshots()).thenAnswer(
        (_) => Stream<DocumentSnapshot<Map<String, dynamic>>>.value(
          mockDocSnapshot,
        ),
      );
      when(() => mockDocSnapshot.exists).thenReturn(true);
      when(() => mockDocSnapshot.id).thenReturn('conv-1');
      when(() => mockDocSnapshot.data()).thenReturn(<String, dynamic>{
        'participantIds': <dynamic>['uid-a', 'uid-b'],
        'unreadCounts': <String, dynamic>{},
      });

      final ConversationResponse? result = await datasource
          .watchThread('conv-1')
          .first;

      expect(result, isNotNull);
      expect(result!.id, 'conv-1');
      expect(result.participantIds, <String>['uid-a', 'uid-b']);
    });
  });

  // ── findThread ───────────────────────────────────────────────────────────────

  group('ChatRemoteDataSource.findThread', () {
    test('returns computed id when doc exists', () async {
      when(() => mockDocRef.get()).thenAnswer((_) async => mockDocSnapshot);
      when(() => mockDocSnapshot.exists).thenReturn(true);

      final String? result = await datasource.findThread('uid-a', 'uid-b');

      expect(result, ChatRemoteDataSource.conversationId('uid-a', 'uid-b'));
    });

    test('returns null when doc does not exist', () async {
      when(() => mockDocRef.get()).thenAnswer((_) async => mockDocSnapshot);
      when(() => mockDocSnapshot.exists).thenReturn(false);

      final String? result = await datasource.findThread('uid-a', 'uid-b');

      expect(result, isNull);
    });

    test('returns null when get() throws (permission denied)', () async {
      when(() => mockDocRef.get()).thenThrow(
        FirebaseException(plugin: 'cloud_firestore', code: 'permission-denied'),
      );

      final String? result = await datasource.findThread('uid-a', 'uid-b');

      expect(result, isNull);
    });
  });

  // ── createThread ─────────────────────────────────────────────────────────────

  group('ChatRemoteDataSource.createThread', () {
    test('calls set on doc and returns conversation id', () async {
      when(() => mockDocRef.set(any(), any())).thenAnswer((_) async {});

      final String id = await datasource.createThread(
        'uid-a',
        'uid-b',
        participants: <String, dynamic>{
          'uid-a': <String, dynamic>{'userId': 'uid-a'},
        },
      );

      expect(id, ChatRemoteDataSource.conversationId('uid-a', 'uid-b'));
      verify(() => mockDocRef.set(any(), any())).called(1);
    });
  });

  // ── embedParticipants ─────────────────────────────────────────────────────────

  group('ChatRemoteDataSource.embedParticipants', () {
    test('does nothing when participants is empty', () async {
      await datasource.embedParticipants('conv-1', <String, dynamic>{});

      verifyNever(() => mockDocRef.set(any(), any()));
    });

    test('calls set when participants is non-empty', () async {
      when(() => mockDocRef.set(any(), any())).thenAnswer((_) async {});

      await datasource.embedParticipants('conv-1', <String, dynamic>{
        'uid-a': <String, dynamic>{'userId': 'uid-a'},
      });

      verify(() => mockDocRef.set(any(), any())).called(1);
    });

    test('swallows exceptions silently', () async {
      when(
        () => mockDocRef.set(any(), any()),
      ).thenThrow(Exception('network error'));

      await expectLater(
        datasource.embedParticipants('conv-1', <String, dynamic>{
          'uid-a': <String, dynamic>{},
        }),
        completes,
      );
    });
  });

  // ── watchMessages ────────────────────────────────────────────────────────────

  group('ChatRemoteDataSource.watchMessages', () {
    test('emits empty list when no messages', () async {
      when(() => mockMsgCol.orderBy(any())).thenReturn(mockQuery);
      when(() => mockQuery.snapshots()).thenAnswer(
        (_) => Stream<QuerySnapshot<Map<String, dynamic>>>.value(
          mockQuerySnapshot,
        ),
      );
      when(
        () => mockQuerySnapshot.docs,
      ).thenReturn(<QueryDocumentSnapshot<Map<String, dynamic>>>[]);

      final List<ChatMessageResponse> result = await datasource
          .watchMessages('conv-1')
          .first;

      expect(result, isEmpty);
    });

    test('maps docs to ChatMessageResponse with injected id', () async {
      final _MockQueryDocumentSnapshot msgDoc = _makeDoc(
        'msg-1',
        <String, dynamic>{
          'type': 'text',
          'text': 'Hey there',
          'senderId': 'uid-sender',
        },
      );
      when(() => mockMsgCol.orderBy(any())).thenReturn(mockQuery);
      when(() => mockQuery.snapshots()).thenAnswer(
        (_) => Stream<QuerySnapshot<Map<String, dynamic>>>.value(
          mockQuerySnapshot,
        ),
      );
      when(
        () => mockQuerySnapshot.docs,
      ).thenReturn(<QueryDocumentSnapshot<Map<String, dynamic>>>[msgDoc]);

      final List<ChatMessageResponse> result = await datasource
          .watchMessages('conv-1')
          .first;

      expect(result, hasLength(1));
      expect(result.first.id, 'msg-1');
      expect(result.first.text, 'Hey there');
      expect(result.first.type, 'text');
    });
  });

  // ── markThreadSeen ───────────────────────────────────────────────────────────

  group('ChatRemoteDataSource.markThreadSeen', () {
    test('calls set with merge on the doc', () async {
      when(() => mockDocRef.set(any(), any())).thenAnswer((_) async {});

      await datasource.markThreadSeen('conv-1', 'my-uid');

      verify(() => mockDocRef.set(any(), any())).called(1);
    });

    test('swallows exceptions silently', () async {
      when(
        () => mockDocRef.set(any(), any()),
      ).thenThrow(Exception('permission'));

      await expectLater(
        datasource.markThreadSeen('conv-1', 'my-uid'),
        completes,
      );
    });
  });

  // ── deleteConversation ───────────────────────────────────────────────────────

  group('ChatRemoteDataSource.deleteConversation', () {
    test('calls update with arrayUnion on the doc', () async {
      when(() => mockDocRef.update(any())).thenAnswer((_) async {});

      await datasource.deleteConversation('conv-1', 'my-uid');

      verify(() => mockDocRef.update(any())).called(1);
    });
  });

  // ── blockUser ────────────────────────────────────────────────────────────────

  group('ChatRemoteDataSource.blockUser', () {
    test('calls update with arrayUnion on the doc', () async {
      when(() => mockDocRef.update(any())).thenAnswer((_) async {});

      await datasource.blockUser('conv-1', 'my-uid');

      verify(() => mockDocRef.update(any())).called(1);
    });
  });

  // ── sendMessage ──────────────────────────────────────────────────────────────

  group('ChatRemoteDataSource.sendMessage', () {
    setUp(() {
      when(() => mockDocRef.get()).thenAnswer((_) async => mockDocSnapshot);
      when(() => mockDocSnapshot.data()).thenReturn(<String, dynamic>{
        'participantIds': <dynamic>['sender-uid', 'recipient-uid'],
      });
      when(() => mockDb.batch()).thenReturn(mockBatch);
      when(() => mockBatch.commit()).thenAnswer((_) async {});
    });

    test('commits batch for text message', () async {
      await datasource.sendMessage(
        'conv-1',
        senderId: 'sender-uid',
        type: 'text',
        clientId: 'client-1',
        text: 'Hello!',
      );

      verify(() => mockBatch.commit()).called(1);
    });

    test('commits batch for non-text type (no text in conv update)', () async {
      await datasource.sendMessage(
        'conv-1',
        senderId: 'sender-uid',
        type: 'offer',
        clientId: 'client-2',
      );

      verify(() => mockBatch.commit()).called(1);
    });

    test('handles empty participantIds gracefully', () async {
      when(
        () => mockDocSnapshot.data(),
      ).thenReturn(<String, dynamic>{'participantIds': null});

      await datasource.sendMessage(
        'conv-1',
        senderId: 'sender-uid',
        type: 'text',
        clientId: 'client-3',
        text: 'Hi',
      );

      verify(() => mockBatch.commit()).called(1);
    });
  });
}
