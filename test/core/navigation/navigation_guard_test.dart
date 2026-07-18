import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/core/navigation/navigation_guard.dart';

void main() {
  final NavigationGuard guard = NavigationGuard.instance;

  setUp(guard.reset);

  group('shouldNavigate (direct-push cooldown)', () {
    test('allows the first navigation to a target', () {
      expect(guard.shouldNavigate('a'), isTrue);
    });

    test('blocks an identical navigation within the cooldown', () {
      expect(guard.shouldNavigate('a'), isTrue);
      expect(guard.shouldNavigate('a'), isFalse);
      expect(guard.shouldNavigate('a'), isFalse);
    });

    test('never blocks navigation to a different target', () {
      expect(guard.shouldNavigate('a'), isTrue);
      expect(guard.shouldNavigate('b'), isTrue);
    });

    test('allows the same target again once the cooldown elapses', () async {
      expect(guard.shouldNavigate('a'), isTrue);
      expect(guard.shouldNavigate('a'), isFalse);
      await Future<void>.delayed(const Duration(milliseconds: 550));
      expect(guard.shouldNavigate('a'), isTrue);
    });
  });

  group('runExclusive (async launcher in-flight lock)', () {
    test('runs the action', () async {
      int runs = 0;
      await guard.runExclusive('chat:1', () async => runs++);
      expect(runs, 1);
    });

    test(
      'ignores a re-entrant call while the first is still in flight',
      () async {
        int runs = 0;
        final Completer<void> hold = Completer<void>();

        final Future<void> first = guard.runExclusive('chat:1', () async {
          runs++;
          await hold.future;
        });

        // Second trigger arrives before the first resolves — must be a no-op.
        await guard.runExclusive('chat:1', () async => runs++);
        expect(runs, 1);

        hold.complete();
        await first;
        expect(runs, 1);
      },
    );

    test(
      'releases the lock so the key can run again after completion',
      () async {
        int runs = 0;
        await guard.runExclusive('chat:1', () async => runs++);
        await guard.runExclusive('chat:1', () async => runs++);
        expect(runs, 2);
      },
    );

    test('releases the lock even when the action throws', () async {
      await expectLater(
        guard.runExclusive('chat:1', () async => throw Exception('boom')),
        throwsException,
      );
      int runs = 0;
      await guard.runExclusive('chat:1', () async => runs++);
      expect(runs, 1);
    });

    test('does not block a different key running concurrently', () async {
      int runs = 0;
      final Completer<void> hold = Completer<void>();

      final Future<void> first = guard.runExclusive('chat:1', () async {
        runs++;
        await hold.future;
      });
      await guard.runExclusive('chat:2', () async => runs++);
      expect(runs, 2);

      hold.complete();
      await first;
    });
  });
}
