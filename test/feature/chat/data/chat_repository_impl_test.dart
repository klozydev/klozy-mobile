// test/feature/chat/data/chat_repository_impl_test.dart
//
// Note: ChatRepositoryImpl constructor calls `locator<EventBus>()` (GetIt) to
// subscribe to ProfileChangedEvent. Tests register a real EventBus in GetIt
// before constructing the repository and reset GetIt after each test group.
//
// `_claimRefreshed` is a static field on ChatRepositoryImpl. Tests prefer the
// `_auth.currentUser == null` shortcut (no _ensureMe call) to avoid cross-test
// state. The respondToOffer tests do not touch auth at all.

import 'dart:io';

import 'package:event_bus/event_bus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:klozy/src/domain/me/entity/me_profile.dart';
import 'package:klozy/src/domain/me/me_repository.dart';
import 'package:klozy/src/domain/offers/offers_repository.dart';
import 'package:klozy/src/feature/chat/data/chat_repository_impl.dart';
import 'package:klozy/src/feature/chat/data/datasource/chat_remote_data_source.dart';
import 'package:klozy/src/feature/chat/data/response/chat_media_response.dart';
import 'package:klozy/src/feature/chat/data/response/chat_message_response.dart';
import 'package:klozy/src/feature/chat/data/response/conversation_response.dart';
import 'package:klozy/src/feature/chat/domain/entity/chat_message.dart';
import 'package:klozy/src/feature/chat/domain/entity/chat_outgoing_media.dart';
import 'package:klozy/src/feature/chat/domain/entity/chat_thread.dart';
import 'package:klozy/src/feature/chat/domain/entity/media_type.dart';
import 'package:klozy/src/feature/chat/domain/entity/message_kind.dart';
import 'package:mocktail/mocktail.dart';

// ── Mocks ──────────────────────────────────────────────────────────────────

class _MockChatRemoteDataSource extends Mock implements ChatRemoteDataSource {}

class _MockFirebaseAuth extends Mock implements FirebaseAuth {}

class _MockMeRepository extends Mock implements MeRepository {}

class _MockOffersRepository extends Mock implements OffersRepository {}

class _MockUser extends Mock implements User {}

class _MockFile extends Mock implements File {}

// ── Helpers ────────────────────────────────────────────────────────────────

ChatRepositoryImpl _make(
  _MockChatRemoteDataSource remote,
  _MockFirebaseAuth auth,
  _MockMeRepository me,
  _MockOffersRepository offers,
) {
  return ChatRepositoryImpl(remote, auth, me, offers);
}

void main() {
  late _MockChatRemoteDataSource mockRemote;
  late _MockFirebaseAuth mockAuth;
  late _MockMeRepository mockMe;
  late _MockOffersRepository mockOffers;
  late ChatRepositoryImpl repo;

  setUpAll(() {
    // Register a real EventBus so the constructor's locator<EventBus>() resolves.
    GetIt.instance.registerSingleton<EventBus>(EventBus());
    // Fallback values for non-primitive types used with any() in stubs.
    registerFallbackValue(_MockFile());
    registerFallbackValue(MediaType.image);
    registerFallbackValue(const ChatMediaResponse());
  });

  tearDownAll(() async {
    await GetIt.instance.reset();
  });

  setUp(() {
    mockRemote = _MockChatRemoteDataSource();
    mockAuth = _MockFirebaseAuth();
    mockMe = _MockMeRepository();
    mockOffers = _MockOffersRepository();

    repo = _make(mockRemote, mockAuth, mockMe, mockOffers);
  });

  // ── currentUserId ────────────────────────────────────────────────────────

  group('currentUserId', () {
    test('returns null before any _ensureMe call', () {
      expect(repo.currentUserId, isNull);
    });
  });

  // ── watchThreads ─────────────────────────────────────────────────────────

  group('watchThreads', () {
    test('yields nothing when auth.currentUser is null', () async {
      when(() => mockAuth.currentUser).thenReturn(null);

      final Stream<List<ChatThread>> stream = repo.watchThreads();
      final List<List<ChatThread>> emits = await stream.toList();

      expect(emits, isEmpty);
      verifyNever(() => mockRemote.watchThreads(any()));
    });

    test('maps thread list when authenticated', () async {
      final user = _MockUser();
      when(() => user.uid).thenReturn('firebase-uid');
      when(() => mockAuth.currentUser).thenReturn(user);
      when(() => mockMe.getMe()).thenAnswer(
        (_) async => const MeProfile(
          id: 'backend-id',
          firstName: 'John',
          lastName: 'Doe',
        ),
      );
      when(() => user.getIdToken(any())).thenAnswer((_) async => 'token');

      // Use fromJson to avoid strict constructor types.
      final ConversationResponse conv = ConversationResponse.fromJson(
        <String, dynamic>{
          'id': 'thread-1',
          'participantIds': <String>['backend-id', 'other-id'],
          'participants': <String, dynamic>{
            'backend-id': <String, dynamic>{'userId': 'backend-id'},
            'other-id': <String, dynamic>{'userId': 'other-id'},
          },
          'unreadCounts': <String, int>{},
        },
      );

      when(() => mockRemote.watchThreads('backend-id')).thenAnswer(
        (_) => Stream<List<ConversationResponse>>.value(<ConversationResponse>[
          conv,
        ]),
      );

      final Stream<List<ChatThread>> stream = repo.watchThreads();
      final List<List<ChatThread>> emits = await stream.toList();

      expect(emits, hasLength(1));
      expect(emits.first, hasLength(1));
      expect(emits.first.first.id, 'thread-1');
    });
  });

  // ── watchMessages ─────────────────────────────────────────────────────────

  group('watchMessages', () {
    test('yields nothing when auth.currentUser is null', () async {
      when(() => mockAuth.currentUser).thenReturn(null);

      final Stream<List<ChatMessage>> stream = repo.watchMessages('thread-1');
      final List<List<ChatMessage>> emits = await stream.toList();

      expect(emits, isEmpty);
      verifyNever(() => mockRemote.watchMessages(any()));
    });
  });

  // ── watchThread ──────────────────────────────────────────────────────────

  group('watchThread', () {
    test('yields nothing when auth.currentUser is null', () async {
      when(() => mockAuth.currentUser).thenReturn(null);

      final Stream<ChatThread?> stream = repo.watchThread('thread-1');
      final List<ChatThread?> emits = await stream.toList();

      expect(emits, isEmpty);
      verifyNever(() => mockRemote.watchThread(any()));
    });
  });

  // ── openOrCreateThread ───────────────────────────────────────────────────

  group('openOrCreateThread', () {
    test('returns null when auth.currentUser is null', () async {
      when(() => mockAuth.currentUser).thenReturn(null);

      final String? result = await repo.openOrCreateThread('other-user');
      expect(result, isNull);
      verifyNever(() => mockRemote.findThread(any(), any()));
    });

    test('returns null when otherUserId is empty', () async {
      final user = _MockUser();
      when(() => user.uid).thenReturn('fb-uid');
      when(() => mockAuth.currentUser).thenReturn(user);
      when(() => user.getIdToken(any())).thenAnswer((_) async => 'tok');
      when(() => mockMe.getMe()).thenAnswer(
        (_) async =>
            const MeProfile(id: 'me-id', firstName: 'Jane', lastName: 'Doe'),
      );

      // Use a fresh repo so _meLoaded resets
      final ChatRepositoryImpl freshRepo = _make(
        mockRemote,
        mockAuth,
        mockMe,
        mockOffers,
      );
      final String? result = await freshRepo.openOrCreateThread('');
      expect(result, isNull);
    });

    test('returns existing thread when findThread returns an id', () async {
      final user = _MockUser();
      when(() => user.uid).thenReturn('fb-uid-2');
      when(() => mockAuth.currentUser).thenReturn(user);
      when(() => user.getIdToken(any())).thenAnswer((_) async => 'tok');
      when(() => mockMe.getMe()).thenAnswer(
        (_) async =>
            const MeProfile(id: 'my-id', firstName: 'A', lastName: 'B'),
      );
      when(
        () => mockRemote.findThread('my-id', 'other-id'),
      ).thenAnswer((_) async => 'thread-existing');
      when(
        () => mockRemote.embedParticipants(any(), any()),
      ).thenAnswer((_) async {});

      final ChatRepositoryImpl freshRepo = _make(
        mockRemote,
        mockAuth,
        mockMe,
        mockOffers,
      );
      final String? result = await freshRepo.openOrCreateThread('other-id');
      expect(result, 'thread-existing');
    });

    test('creates a new thread when findThread returns null', () async {
      final user = _MockUser();
      when(() => user.uid).thenReturn('fb-uid-3');
      when(() => mockAuth.currentUser).thenReturn(user);
      when(() => user.getIdToken(any())).thenAnswer((_) async => 'tok');
      when(() => mockMe.getMe()).thenAnswer(
        (_) async =>
            const MeProfile(id: 'my-id-3', firstName: 'C', lastName: 'D'),
      );
      when(
        () => mockRemote.findThread('my-id-3', 'other-3'),
      ).thenAnswer((_) async => null);
      when(
        () => mockRemote.createThread(
          any(),
          any(),
          participants: any(named: 'participants'),
        ),
      ).thenAnswer((_) async => 'thread-new');

      final ChatRepositoryImpl freshRepo = _make(
        mockRemote,
        mockAuth,
        mockMe,
        mockOffers,
      );
      final String? result = await freshRepo.openOrCreateThread('other-3');
      expect(result, 'thread-new');
    });
  });

  // ── sendText ─────────────────────────────────────────────────────────────

  group('sendText', () {
    test('does nothing when auth.currentUser is null', () async {
      when(() => mockAuth.currentUser).thenReturn(null);

      await repo.sendText('thread-1', 'Hello', clientId: 'c1');

      verifyNever(
        () => mockRemote.sendMessage(
          any(),
          senderId: any(named: 'senderId'),
          type: any(named: 'type'),
          clientId: any(named: 'clientId'),
        ),
      );
    });
  });

  // ── markSeen ─────────────────────────────────────────────────────────────

  group('markSeen', () {
    test('does nothing when auth.currentUser is null', () async {
      when(() => mockAuth.currentUser).thenReturn(null);

      await repo.markSeen('thread-1');
      verifyNever(() => mockRemote.markThreadSeen(any(), any()));
    });
  });

  // ── deleteConversation ───────────────────────────────────────────────────

  group('deleteConversation', () {
    test('does nothing when auth.currentUser is null', () async {
      when(() => mockAuth.currentUser).thenReturn(null);

      await repo.deleteConversation('thread-1');
      verifyNever(() => mockRemote.deleteConversation(any(), any()));
    });
  });

  // ── reportAndBlock ───────────────────────────────────────────────────────

  group('reportAndBlock', () {
    test('does nothing when auth.currentUser is null', () async {
      when(() => mockAuth.currentUser).thenReturn(null);

      await repo.reportAndBlock('thread-1', 'other-user');
      verifyNever(() => mockRemote.blockUser(any(), any()));
    });
  });

  // ── respondToOffer ───────────────────────────────────────────────────────

  group('respondToOffer', () {
    test('returns immediately when offerId is empty', () async {
      await repo.respondToOffer('', accept: true);

      verifyNever(() => mockOffers.acceptOffer(any()));
      verifyNever(() => mockOffers.declineOffer(any()));
    });

    test('calls acceptOffer when accept is true', () async {
      when(() => mockOffers.acceptOffer('offer-1')).thenAnswer((_) async {});

      await repo.respondToOffer('offer-1', accept: true);

      verify(() => mockOffers.acceptOffer('offer-1')).called(1);
      verifyNever(() => mockOffers.declineOffer(any()));
    });

    test('calls declineOffer when accept is false', () async {
      when(() => mockOffers.declineOffer('offer-2')).thenAnswer((_) async {});

      await repo.respondToOffer('offer-2', accept: false);

      verify(() => mockOffers.declineOffer('offer-2')).called(1);
      verifyNever(() => mockOffers.acceptOffer(any()));
    });
  });

  // ── Authenticated-path helpers ─────────────────────────────────────────────
  //
  // These tests share a common "logged-in user" setup. Each creates a fresh
  // repo so the _meLoaded / _myId state is isolated and _ensureMe runs once.

  _MockUser mockUser(String uid) {
    final user = _MockUser();
    when(() => user.uid).thenReturn(uid);
    when(() => user.getIdToken(any())).thenAnswer((_) async => 'token');
    return user;
  }

  void stubAuth(_MockUser user, String backendId) {
    when(() => mockAuth.currentUser).thenReturn(user);
    when(() => mockMe.getMe()).thenAnswer(
      (_) async =>
          MeProfile(id: backendId, firstName: 'Test', lastName: 'User'),
    );
  }

  // ── openOrCreateThread — self-message guard ───────────────────────────────

  group('openOrCreateThread — self-message guard', () {
    test('returns null when otherUserId equals myId', () async {
      final user = mockUser('fb-uid-self');
      stubAuth(user, 'backend-self');

      final ChatRepositoryImpl freshRepo = _make(
        mockRemote,
        mockAuth,
        mockMe,
        mockOffers,
      );
      final String? result = await freshRepo.openOrCreateThread('backend-self');

      expect(result, isNull);
    });
  });

  // ── watchMessages — authenticated ─────────────────────────────────────────

  group('watchMessages — authenticated', () {
    test('maps remote messages to ChatMessage list', () async {
      final user = mockUser('fb-uid-wm');
      stubAuth(user, 'backend-wm');

      final ChatMessageResponse msg = ChatMessageResponse.fromJson(
        <String, dynamic>{
          'id': 'msg-1',
          'conversationId': 'thread-1',
          'senderId': 'backend-wm',
          'type': 'text',
          'text': 'Hey',
          'readBy': <String>['backend-wm'],
        },
      );
      when(() => mockRemote.watchMessages('thread-1')).thenAnswer(
        (_) =>
            Stream<List<ChatMessageResponse>>.value(<ChatMessageResponse>[msg]),
      );

      final ChatRepositoryImpl freshRepo = _make(
        mockRemote,
        mockAuth,
        mockMe,
        mockOffers,
      );
      final List<List<ChatMessage>> emits = await freshRepo
          .watchMessages('thread-1')
          .toList();

      expect(emits, hasLength(1));
      expect(emits.first, hasLength(1));
      expect(emits.first.first.id, 'msg-1');
      expect(emits.first.first.text, 'Hey');
    });
  });

  // ── watchThread — authenticated ───────────────────────────────────────────

  group('watchThread — authenticated', () {
    test('maps remote conversation to ChatThread', () async {
      final user = mockUser('fb-uid-wt');
      stubAuth(user, 'backend-wt');

      final ConversationResponse conv = ConversationResponse.fromJson(
        <String, dynamic>{
          'id': 'thread-wt',
          'participantIds': <String>['backend-wt', 'other-id'],
          'participants': <String, dynamic>{
            'backend-wt': <String, dynamic>{'userId': 'backend-wt'},
            'other-id': <String, dynamic>{'userId': 'other-id'},
          },
          'unreadCounts': <String, int>{},
        },
      );
      when(
        () => mockRemote.watchThread('thread-wt'),
      ).thenAnswer((_) => Stream<ConversationResponse?>.value(conv));

      final ChatRepositoryImpl freshRepo = _make(
        mockRemote,
        mockAuth,
        mockMe,
        mockOffers,
      );
      final List<ChatThread?> emits = await freshRepo
          .watchThread('thread-wt')
          .toList();

      expect(emits, hasLength(1));
      expect(emits.first, isNotNull);
      expect(emits.first!.id, 'thread-wt');
    });

    test('maps null remote conversation to null entity', () async {
      final user = mockUser('fb-uid-wt2');
      stubAuth(user, 'backend-wt2');

      when(
        () => mockRemote.watchThread('thread-null'),
      ).thenAnswer((_) => Stream<ConversationResponse?>.value(null));

      final ChatRepositoryImpl freshRepo = _make(
        mockRemote,
        mockAuth,
        mockMe,
        mockOffers,
      );
      final List<ChatThread?> emits = await freshRepo
          .watchThread('thread-null')
          .toList();

      expect(emits, hasLength(1));
      expect(emits.first, isNull);
    });
  });

  // ── sendText — authenticated ──────────────────────────────────────────────

  group('sendText — authenticated', () {
    test('delegates to remote.sendMessage without replyTo', () async {
      final user = mockUser('fb-uid-st');
      stubAuth(user, 'backend-st');

      when(
        () => mockRemote.sendMessage(
          any(),
          senderId: any(named: 'senderId'),
          type: any(named: 'type'),
          clientId: any(named: 'clientId'),
          text: any(named: 'text'),
          replyTo: any(named: 'replyTo'),
        ),
      ).thenAnswer((_) async {});

      final ChatRepositoryImpl freshRepo = _make(
        mockRemote,
        mockAuth,
        mockMe,
        mockOffers,
      );
      await freshRepo.sendText('thread-1', 'Hello!', clientId: 'c1');

      verify(
        () => mockRemote.sendMessage(
          'thread-1',
          senderId: 'backend-st',
          type: 'text',
          clientId: 'c1',
          text: 'Hello!',
          replyTo: null,
        ),
      ).called(1);
    });

    test('builds replyTo from ChatMessage and delegates', () async {
      final user = mockUser('fb-uid-st2');
      stubAuth(user, 'backend-st2');

      when(
        () => mockRemote.sendMessage(
          any(),
          senderId: any(named: 'senderId'),
          type: any(named: 'type'),
          clientId: any(named: 'clientId'),
          text: any(named: 'text'),
          replyTo: any(named: 'replyTo'),
        ),
      ).thenAnswer((_) async {});

      const ChatMessage replyMsg = ChatMessage(
        id: 'orig-1',
        threadId: 'thread-1',
        senderId: 'uid-other',
        kind: ChatMessageKind.text,
        isMine: false,
        text: 'original',
        timeLabel: '',
      );

      final ChatRepositoryImpl freshRepo = _make(
        mockRemote,
        mockAuth,
        mockMe,
        mockOffers,
      );
      await freshRepo.sendText(
        'thread-1',
        'Reply!',
        clientId: 'c2',
        replyTo: replyMsg,
      );

      verify(
        () => mockRemote.sendMessage(
          'thread-1',
          senderId: 'backend-st2',
          type: 'text',
          clientId: 'c2',
          text: 'Reply!',
          replyTo: any(named: 'replyTo'),
        ),
      ).called(1);
    });
  });

  // ── markSeen — authenticated ──────────────────────────────────────────────

  group('markSeen — authenticated', () {
    test('delegates to remote.markThreadSeen', () async {
      final user = mockUser('fb-uid-ms');
      stubAuth(user, 'backend-ms');

      when(
        () => mockRemote.markThreadSeen(any(), any()),
      ).thenAnswer((_) async {});

      final ChatRepositoryImpl freshRepo = _make(
        mockRemote,
        mockAuth,
        mockMe,
        mockOffers,
      );
      await freshRepo.markSeen('thread-1');

      verify(
        () => mockRemote.markThreadSeen('thread-1', 'backend-ms'),
      ).called(1);
    });
  });

  // ── deleteConversation — authenticated ───────────────────────────────────

  group('deleteConversation — authenticated', () {
    test('delegates to remote.deleteConversation', () async {
      final user = mockUser('fb-uid-dc');
      stubAuth(user, 'backend-dc');

      when(
        () => mockRemote.deleteConversation(any(), any()),
      ).thenAnswer((_) async {});

      final ChatRepositoryImpl freshRepo = _make(
        mockRemote,
        mockAuth,
        mockMe,
        mockOffers,
      );
      await freshRepo.deleteConversation('thread-1');

      verify(
        () => mockRemote.deleteConversation('thread-1', 'backend-dc'),
      ).called(1);
    });
  });

  // ── reportAndBlock — authenticated ───────────────────────────────────────

  group('reportAndBlock — authenticated', () {
    test('delegates to remote.blockUser with myId', () async {
      final user = mockUser('fb-uid-rb');
      stubAuth(user, 'backend-rb');

      when(() => mockRemote.blockUser(any(), any())).thenAnswer((_) async {});

      final ChatRepositoryImpl freshRepo = _make(
        mockRemote,
        mockAuth,
        mockMe,
        mockOffers,
      );
      await freshRepo.reportAndBlock('thread-1', 'other-user');

      verify(() => mockRemote.blockUser('thread-1', 'backend-rb')).called(1);
    });
  });

  // ── sendMedia — authenticated ─────────────────────────────────────────────

  group('sendMedia — authenticated', () {
    test('uploads file then delegates to remote.sendMessage', () async {
      final user = mockUser('fb-uid-sm');
      stubAuth(user, 'backend-sm');

      const ChatMediaResponse uploadedMedia = ChatMediaResponse(
        id: 'media-1',
        url: 'https://cdn.example.com/file.jpg',
        type: 'image',
      );
      when(
        () => mockRemote.uploadFile(
          any(),
          any(),
          any(),
          name: any(named: 'name'),
          durationMs: any(named: 'durationMs'),
        ),
      ).thenAnswer((_) async => uploadedMedia);

      when(
        () => mockRemote.sendMessage(
          any(),
          senderId: any(named: 'senderId'),
          type: any(named: 'type'),
          clientId: any(named: 'clientId'),
          media: any(named: 'media'),
        ),
      ).thenAnswer((_) async {});

      final _MockFile mockFile = _MockFile();
      when(() => mockFile.path).thenReturn('/tmp/photo.jpg');

      final ChatRepositoryImpl freshRepo = _make(
        mockRemote,
        mockAuth,
        mockMe,
        mockOffers,
      );
      await freshRepo.sendMedia(
        'thread-1',
        ChatOutgoingMedia(file: mockFile, type: MediaType.image),
        clientId: 'c-media',
      );

      verify(
        () => mockRemote.uploadFile(
          'thread-1',
          any(),
          MediaType.image,
          name: any(named: 'name'),
          durationMs: any(named: 'durationMs'),
        ),
      ).called(1);
      verify(
        () => mockRemote.sendMessage(
          'thread-1',
          senderId: 'backend-sm',
          type: 'media',
          clientId: 'c-media',
          media: any(named: 'media'),
        ),
      ).called(1);
    });
  });

  // ── sendAudio — authenticated ─────────────────────────────────────────────

  group('sendAudio — authenticated', () {
    test('uploads audio then delegates to remote.sendMessage', () async {
      final user = mockUser('fb-uid-sa');
      stubAuth(user, 'backend-sa');

      const ChatMediaResponse uploadedAudio = ChatMediaResponse(
        id: 'audio-1',
        url: 'https://cdn.example.com/voice.m4a',
        type: 'audio',
        durationMs: 8000,
      );
      when(
        () => mockRemote.uploadFile(
          any(),
          any(),
          any(),
          name: any(named: 'name'),
          durationMs: any(named: 'durationMs'),
        ),
      ).thenAnswer((_) async => uploadedAudio);

      when(
        () => mockRemote.sendMessage(
          any(),
          senderId: any(named: 'senderId'),
          type: any(named: 'type'),
          clientId: any(named: 'clientId'),
          media: any(named: 'media'),
        ),
      ).thenAnswer((_) async {});

      final _MockFile mockFile = _MockFile();
      when(() => mockFile.path).thenReturn('/tmp/voice.m4a');

      final ChatRepositoryImpl freshRepo = _make(
        mockRemote,
        mockAuth,
        mockMe,
        mockOffers,
      );
      await freshRepo.sendAudio(
        'thread-1',
        ChatOutgoingMedia(
          file: mockFile,
          type: MediaType.audio,
          durationMs: 8000,
        ),
        clientId: 'c-audio',
      );

      verify(
        () => mockRemote.uploadFile(
          'thread-1',
          any(),
          MediaType.audio,
          name: any(named: 'name'),
          durationMs: 8000,
        ),
      ).called(1);
      verify(
        () => mockRemote.sendMessage(
          'thread-1',
          senderId: 'backend-sa',
          type: 'audio',
          clientId: 'c-audio',
          media: any(named: 'media'),
        ),
      ).called(1);
    });
  });
}
