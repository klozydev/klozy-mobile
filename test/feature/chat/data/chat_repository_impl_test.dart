// test/feature/chat/data/chat_repository_impl_test.dart
//
// Note: ChatRepositoryImpl constructor calls `locator<EventBus>()` (GetIt) to
// subscribe to ProfileChangedEvent. Tests register a real EventBus in GetIt
// before constructing the repository and reset GetIt after each test group.
//
// `_claimRefreshed` is a static field on ChatRepositoryImpl. Tests prefer the
// `_auth.currentUser == null` shortcut (no _ensureMe call) to avoid cross-test
// state. The respondToOffer tests do not touch auth at all.

import 'package:event_bus/event_bus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:klozy/src/domain/me/entity/me_profile.dart';
import 'package:klozy/src/domain/me/me_repository.dart';
import 'package:klozy/src/domain/offers/offers_repository.dart';
import 'package:klozy/src/feature/chat/data/chat_repository_impl.dart';
import 'package:klozy/src/feature/chat/data/datasource/chat_remote_data_source.dart';
import 'package:klozy/src/feature/chat/data/response/conversation_response.dart';
import 'package:klozy/src/feature/chat/domain/entity/chat_message.dart';
import 'package:klozy/src/feature/chat/domain/entity/chat_thread.dart';
import 'package:mocktail/mocktail.dart';

// ── Mocks ──────────────────────────────────────────────────────────────────

class _MockChatRemoteDataSource extends Mock implements ChatRemoteDataSource {}

class _MockFirebaseAuth extends Mock implements FirebaseAuth {}

class _MockMeRepository extends Mock implements MeRepository {}

class _MockOffersRepository extends Mock implements OffersRepository {}

class _MockUser extends Mock implements User {}

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
      final _MockUser user = _MockUser();
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
      final _MockUser user = _MockUser();
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
      final _MockUser user = _MockUser();
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
      final _MockUser user = _MockUser();
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
}
