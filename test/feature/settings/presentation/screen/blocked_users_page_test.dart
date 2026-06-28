import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/design/components/ds_loader.dart';
import 'package:klozy/src/di/injection.dart';
import 'package:klozy/src/domain/me/entity/blocked_user.dart';
import 'package:klozy/src/domain/me/me_repository.dart';
import 'package:klozy/src/feature/settings/presentation/screen/blocked_users_page.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../support/ds_harness.dart';

// Returns true for NetworkImageLoadException / HTTP-failure errors that are
// expected in the headless test environment where external URLs are unreachable.
bool _isNetworkImageError(FlutterErrorDetails d) =>
    d.exception.toString().contains('HTTP request failed') ||
    d.exception.toString().contains('NetworkImageLoadException');

// Overrides FlutterError.onError INSIDE the test body (after the test binding
// has set its own handler) so that network-image errors are silently dropped
// for tests that render avatar URLs. Must be called at the top of such tests.
void _suppressNetworkImageErrors() {
  final prev = FlutterError.onError;
  FlutterError.onError = (FlutterErrorDetails d) {
    if (_isNetworkImageError(d)) return;
    prev?.call(d);
  };
  addTearDown(() => FlutterError.onError = prev);
}

class _MockMeRepository extends Mock implements MeRepository {}

class _MockStackRouter extends Mock implements StackRouter {}

const _kUserA = BlockedUser(id: 'ua', displayName: 'Alice');
const _kUserB = BlockedUser(
  id: 'ub',
  displayName: 'Bob',
  avatarUrl: 'https://example.com/bob.png',
);

void main() {
  setUpAll(disableDsFonts);

  late _MockMeRepository mockMe;
  late _MockStackRouter router;

  setUp(() {
    mockMe = _MockMeRepository();
    router = _MockStackRouter();
    when(() => router.maybePop<Object?>()).thenAnswer((_) async => true);

    if (locator.isRegistered<MeRepository>()) {
      locator.unregister<MeRepository>();
    }
    locator.registerSingleton<MeRepository>(mockMe);
  });

  tearDown(() {
    if (locator.isRegistered<MeRepository>()) {
      locator.unregister<MeRepository>();
    }
  });

  Widget _pump() {
    return dsWrapRouted(const BlockedUsersPage(), router: router);
  }

  group('BlockedUsersPage — loading state', () {
    testWidgets('shows DSLoader while getBlocked is in flight', (tester) async {
      // Use Completer — Future.delayed creates a real Timer that the test
      // framework rejects as still-pending on teardown.
      final completer = Completer<List<BlockedUser>>();
      when(() => mockMe.getBlocked()).thenAnswer((_) => completer.future);

      await tester.pumpWidget(_pump());
      await tester.pump(); // one frame — still loading

      expect(find.byType(DSLoader), findsOneWidget);
    });
  });

  group('BlockedUsersPage — empty state', () {
    testWidgets('shows no-blocked message when list is empty', (tester) async {
      when(() => mockMe.getBlocked()).thenAnswer((_) async => const []);

      await tester.pumpWidget(_pump());
      await tester.pumpAndSettle();

      expect(find.byType(DSLoader), findsNothing);
      // l10n key: settings_no_blocked
      expect(find.byType(Center), findsWidgets);
    });

    testWidgets('gracefully shows empty state when getBlocked throws', (
      tester,
    ) async {
      when(() => mockMe.getBlocked()).thenThrow(Exception('network'));

      await tester.pumpWidget(_pump());
      await tester.pumpAndSettle();

      expect(find.byType(DSLoader), findsNothing);
    });
  });

  group('BlockedUsersPage — list state', () {
    testWidgets('shows display names for blocked users', (tester) async {
      // _kUserB has an avatarUrl; suppress the NetworkImageLoadException that
      // the test environment produces when it cannot reach external HTTP URLs.
      _suppressNetworkImageErrors();

      when(
        () => mockMe.getBlocked(),
      ).thenAnswer((_) async => [_kUserA, _kUserB]);

      await tester.pumpWidget(_pump());
      await tester.pumpAndSettle();

      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('Bob'), findsOneWidget);
    });

    testWidgets('shows person icon when avatarUrl is null', (tester) async {
      when(() => mockMe.getBlocked()).thenAnswer((_) async => [_kUserA]);

      await tester.pumpWidget(_pump());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('shows no person icon when avatarUrl is set', (tester) async {
      _suppressNetworkImageErrors();

      when(() => mockMe.getBlocked()).thenAnswer((_) async => [_kUserB]);

      await tester.pumpWidget(_pump());
      await tester.pumpAndSettle();

      // User B has avatar — no fallback person icon
      expect(find.byIcon(Icons.person), findsNothing);
    });
  });

  group('BlockedUsersPage — unblock', () {
    testWidgets('tapping unblock removes user from list', (tester) async {
      _suppressNetworkImageErrors();

      when(
        () => mockMe.getBlocked(),
      ).thenAnswer((_) async => [_kUserA, _kUserB]);
      when(() => mockMe.unblock(any())).thenAnswer((_) async {});

      await tester.pumpWidget(_pump());
      await tester.pumpAndSettle();

      // Find unblock button for Alice (first GestureDetector)
      final unblockButtons = find.byType(GestureDetector);
      await tester.tap(unblockButtons.first);
      await tester.pump();

      expect(find.text('Alice'), findsNothing);
      expect(find.text('Bob'), findsOneWidget);
    });

    testWidgets('unblock calls repo.unblock with correct id', (tester) async {
      when(() => mockMe.getBlocked()).thenAnswer((_) async => [_kUserA]);
      when(() => mockMe.unblock(any())).thenAnswer((_) async {});

      await tester.pumpWidget(_pump());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(GestureDetector).first);
      await tester.pumpAndSettle();

      verify(() => mockMe.unblock('ua')).called(1);
    });

    testWidgets('unblock error does not crash the widget', (tester) async {
      when(() => mockMe.getBlocked()).thenAnswer((_) async => [_kUserA]);
      when(() => mockMe.unblock(any())).thenThrow(Exception('server'));

      await tester.pumpWidget(_pump());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(GestureDetector).first);
      await tester.pumpAndSettle();

      // Optimistic removal already happened; no error crash
      expect(find.text('Alice'), findsNothing);
    });
  });

  group('BlockedUsersPage — navigation', () {
    testWidgets('back button calls router.maybePop', (tester) async {
      when(() => mockMe.getBlocked()).thenAnswer((_) async => const []);

      await tester.pumpWidget(_pump());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
      verify(() => router.maybePop<Object?>()).called(1);
    });
  });
}
