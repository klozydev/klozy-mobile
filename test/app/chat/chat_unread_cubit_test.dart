import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/app/chat/chat_unread_cubit.dart';
import 'package:klozy/src/feature/chat/domain/entity/chat_thread.dart';
import 'package:klozy/src/feature/chat/domain/usecase/watch_threads.dart';
import 'package:mocktail/mocktail.dart';

class _MockWatchThreads extends Mock implements WatchThreads {}

class _MockFirebaseAuth extends Mock implements FirebaseAuth {}

class _MockUser extends Mock implements User {}

ChatThread threadWith({required String id, int unread = 0}) {
  return ChatThread(id: id, unreadCount: unread);
}

void main() {
  late _MockWatchThreads mockWatchThreads;
  late _MockFirebaseAuth mockAuth;
  late _MockUser mockUser;

  setUp(() {
    mockWatchThreads = _MockWatchThreads();
    mockAuth = _MockFirebaseAuth();
    mockUser = _MockUser();
  });

  group('no signed-in user at start', () {
    late StreamController<User?> authController;
    late ChatUnreadCubit cubit;

    setUp(() {
      authController = StreamController<User?>.broadcast();
      when(
        () => mockAuth.authStateChanges(),
      ).thenAnswer((_) => authController.stream);
      when(() => mockAuth.currentUser).thenReturn(null);
      cubit = ChatUnreadCubit(mockWatchThreads, mockAuth);
    });

    tearDown(() async {
      await cubit.close();
      await authController.close();
    });

    test('initial state is 0', () {
      expect(cubit.state, 0);
    });

    test('does not call watchThreads when no user', () {
      verifyNever(() => mockWatchThreads());
    });

    test('emits 0 and subscribes to threads when user signs in', () async {
      final threadsController = StreamController<List<ChatThread>>.broadcast();
      when(
        () => mockWatchThreads(),
      ).thenAnswer((_) => threadsController.stream);

      final emitted = <int>[];
      final sub = cubit.stream.listen(emitted.add);

      authController.add(mockUser);
      await Future<void>.delayed(Duration.zero);

      threadsController.add([
        threadWith(id: '1', unread: 1),
        threadWith(id: '2', unread: 0),
        threadWith(id: '3', unread: 2),
      ]);
      await Future<void>.delayed(Duration.zero);

      await sub.cancel();
      await threadsController.close();

      expect(emitted, [2]);
    });
  });

  group('signed-in user at start', () {
    late StreamController<User?> authController;
    late StreamController<List<ChatThread>> threadsController;
    late ChatUnreadCubit cubit;

    setUp(() {
      authController = StreamController<User?>.broadcast();
      threadsController = StreamController<List<ChatThread>>.broadcast();
      when(
        () => mockAuth.authStateChanges(),
      ).thenAnswer((_) => authController.stream);
      when(() => mockAuth.currentUser).thenReturn(mockUser);
      when(
        () => mockWatchThreads(),
      ).thenAnswer((_) => threadsController.stream);
      cubit = ChatUnreadCubit(mockWatchThreads, mockAuth);
    });

    tearDown(() async {
      await cubit.close();
      await authController.close();
      await threadsController.close();
    });

    test('initial state is 0', () {
      expect(cubit.state, 0);
    });

    test('emits count of threads with hasUnread on first batch', () async {
      final emitted = <int>[];
      final sub = cubit.stream.listen(emitted.add);

      threadsController.add([
        threadWith(id: '1', unread: 3),
        threadWith(id: '2', unread: 0),
        threadWith(id: '3', unread: 1),
      ]);
      await Future<void>.delayed(Duration.zero);

      await sub.cancel();

      expect(emitted, [2]);
    });

    test('emits 0 when all threads have been read', () async {
      final emitted = <int>[];
      final sub = cubit.stream.listen(emitted.add);

      threadsController.add([
        threadWith(id: '1', unread: 0),
        threadWith(id: '2', unread: 0),
      ]);
      await Future<void>.delayed(Duration.zero);

      await sub.cancel();

      expect(emitted, [0]);
    });

    test('emits updated count when threads stream emits again', () async {
      final emitted = <int>[];
      final sub = cubit.stream.listen(emitted.add);

      threadsController.add([threadWith(id: '1', unread: 2)]);
      await Future<void>.delayed(Duration.zero);

      threadsController.add([
        threadWith(id: '1', unread: 0),
        threadWith(id: '2', unread: 1),
        threadWith(id: '3', unread: 1),
      ]);
      await Future<void>.delayed(Duration.zero);

      await sub.cancel();

      expect(emitted, [1, 2]);
    });

    test('emits 0 on threads stream error', () async {
      final emitted = <int>[];
      final sub = cubit.stream.listen(emitted.add);

      threadsController.addError(Exception('firestore error'));
      await Future<void>.delayed(Duration.zero);

      await sub.cancel();

      expect(emitted, [0]);
    });

    test('emits 0 when user signs out', () async {
      final emitted = <int>[];
      final sub = cubit.stream.listen(emitted.add);

      authController.add(null);
      await Future<void>.delayed(Duration.zero);

      await sub.cancel();

      expect(emitted, [0]);
    });

    test('re-subscribes to threads when user switches account', () async {
      final secondThreadsController =
          StreamController<List<ChatThread>>.broadcast();
      final emitted = <int>[];
      final sub = cubit.stream.listen(emitted.add);

      // First, sign out.
      authController.add(null);
      await Future<void>.delayed(Duration.zero);

      // Sign in as a different user — new call to watchThreads() needed.
      when(
        () => mockWatchThreads(),
      ).thenAnswer((_) => secondThreadsController.stream);
      authController.add(mockUser);
      await Future<void>.delayed(Duration.zero);

      secondThreadsController.add([threadWith(id: 'a', unread: 4)]);
      await Future<void>.delayed(Duration.zero);

      await sub.cancel();
      await secondThreadsController.close();

      // 0 from sign-out, then 1 from second account's thread.
      expect(emitted, [0, 1]);
    });
  });

  group('close', () {
    test('close does not throw', () async {
      final authController = StreamController<User?>.broadcast();
      when(
        () => mockAuth.authStateChanges(),
      ).thenAnswer((_) => authController.stream);
      when(() => mockAuth.currentUser).thenReturn(null);

      final cubit = ChatUnreadCubit(mockWatchThreads, mockAuth);
      await expectLater(cubit.close(), completes);
      await authController.close();
    });
  });
}
