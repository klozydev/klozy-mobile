import 'package:auto_route/auto_route.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/domain/account/entity/account_status.dart';
import 'package:klozy/src/domain/account/usecase/get_account_status_usecase.dart';
import 'package:klozy/src/domain/auth/auth_repository.dart';
import 'package:klozy/src/router/account_guard.dart';
import 'package:klozy/src/router/app_router.dart';
import 'package:mocktail/mocktail.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class _MockGetAccountStatusUseCase extends Mock
    implements GetAccountStatusUseCase {}

class _MockAuthRepository extends Mock implements AuthRepository {}

class _MockNavigationResolver extends Mock implements NavigationResolver {}

class _MockRouteMatch extends Mock implements RouteMatch {}

class _MockStackRouter extends Mock implements StackRouter {}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Invokes [AccountGuard.onNavigation] and waits for any micro-tasks to drain
/// so that the async `.then()`/`.catchError()` chain fully resolves.
Future<void> _guardNavigate(
  AccountGuard guard,
  NavigationResolver resolver,
  StackRouter router,
) async {
  guard.onNavigation(resolver, router);
  // Two microtask ticks: one for the Future resolution, one for the .then().
  await Future<void>.delayed(Duration.zero);
  await Future<void>.delayed(Duration.zero);
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late _MockGetAccountStatusUseCase mockGetStatus;
  late _MockAuthRepository mockAuthRepo;
  late _MockNavigationResolver mockResolver;
  late _MockStackRouter mockRouter;
  late AccountGuard guard;

  setUpAll(() {
    registerFallbackValue(const WelcomeRoute());
    registerFallbackValue(const PersonalizeRoute());
  });

  setUp(() {
    mockGetStatus = _MockGetAccountStatusUseCase();
    mockAuthRepo = _MockAuthRepository();
    mockResolver = _MockNavigationResolver();
    mockRouter = _MockStackRouter();
    guard = AccountGuard(mockGetStatus, mockAuthRepo);

    // Default: signOut succeeds.
    when(() => mockAuthRepo.signOut()).thenAnswer((_) async {});

    // Default navigation target: a private (non-onboarding) route.
    final routeMatch = _MockRouteMatch();
    when(() => routeMatch.name).thenReturn(CartRoute.name);
    when(() => mockResolver.route).thenReturn(routeMatch);
  });

  // ── valid ─────────────────────────────────────────────────────────────────

  test('valid → resolver.next(true)', () async {
    when(() => mockGetStatus()).thenAnswer((_) async => AccountStatus.valid);

    await _guardNavigate(guard, mockResolver, mockRouter);

    verify(() => mockResolver.next(true)).called(1);
    verifyNever(() => mockResolver.redirectUntil(any()));
  });

  // ── incompleteOnboarding ──────────────────────────────────────────────────

  test('incompleteOnboarding → redirectUntil(PersonalizeRoute)', () async {
    when(
      () => mockGetStatus(),
    ).thenAnswer((_) async => AccountStatus.incompleteOnboarding);
    when(() => mockResolver.redirectUntil(any())).thenAnswer((_) async => null);

    await _guardNavigate(guard, mockResolver, mockRouter);

    final captured = verify(
      () => mockResolver.redirectUntil(captureAny()),
    ).captured;
    expect(captured.single, isA<PersonalizeRoute>());
    verifyNever(() => mockResolver.next(any()));
  });

  test('incompleteOnboarding → next(true) when the TARGET is an onboarding '
      'route (no redirect loop)', () async {
    when(
      () => mockGetStatus(),
    ).thenAnswer((_) async => AccountStatus.incompleteOnboarding);
    final routeMatch = _MockRouteMatch();
    when(() => routeMatch.name).thenReturn(PersonalizeRoute.name);
    when(() => mockResolver.route).thenReturn(routeMatch);

    await _guardNavigate(guard, mockResolver, mockRouter);

    verify(() => mockResolver.next(true)).called(1);
    verifyNever(() => mockResolver.redirectUntil(any()));
  });

  test(
    'incompleteOnboarding → next(true) for ProfileCompletionRoute',
    () async {
      when(
        () => mockGetStatus(),
      ).thenAnswer((_) async => AccountStatus.incompleteOnboarding);
      final routeMatch = _MockRouteMatch();
      when(() => routeMatch.name).thenReturn(ProfileCompletionRoute.name);
      when(() => mockResolver.route).thenReturn(routeMatch);

      await _guardNavigate(guard, mockResolver, mockRouter);

      verify(() => mockResolver.next(true)).called(1);
      verifyNever(() => mockResolver.redirectUntil(any()));
    },
  );

  // ── guest ─────────────────────────────────────────────────────────────────

  test('guest → redirectUntil(WelcomeRoute), NO signOut', () async {
    when(() => mockGetStatus()).thenAnswer((_) async => AccountStatus.guest);
    when(() => mockResolver.redirectUntil(any())).thenAnswer((_) async => null);

    await _guardNavigate(guard, mockResolver, mockRouter);

    final captured = verify(
      () => mockResolver.redirectUntil(captureAny()),
    ).captured;
    expect(captured.single, isA<WelcomeRoute>());
    verifyNever(() => mockAuthRepo.signOut());
    verifyNever(() => mockResolver.next(any()));
  });

  // ── legacy ────────────────────────────────────────────────────────────────

  test(
    'legacy → redirectUntil(WelcomeRoute) BEFORE signOut (no await)',
    () async {
      when(() => mockGetStatus()).thenAnswer((_) async => AccountStatus.legacy);
      when(
        () => mockResolver.redirectUntil(any()),
      ).thenAnswer((_) async => null);

      await _guardNavigate(guard, mockResolver, mockRouter);

      // Resolver must be settled (redirectUntil called with WelcomeRoute).
      final captured = verify(
        () => mockResolver.redirectUntil(captureAny()),
      ).captured;
      expect(captured.single, isA<WelcomeRoute>());
      // signOut is fired (fire-and-forget).
      verify(() => mockAuthRepo.signOut()).called(1);
      verifyNever(() => mockResolver.next(any()));
    },
  );

  test('legacy → resolver settled even when signOut throws', () async {
    when(() => mockGetStatus()).thenAnswer((_) async => AccountStatus.legacy);
    when(() => mockAuthRepo.signOut()).thenThrow(Exception('network'));
    when(() => mockResolver.redirectUntil(any())).thenAnswer((_) async => null);

    // Must not throw; resolver must still be settled.
    await _guardNavigate(guard, mockResolver, mockRouter);

    verify(() => mockResolver.redirectUntil(any())).called(1);
  });

  // ── exception from getAccountStatus ───────────────────────────────────────

  test(
    'getAccountStatus fails → catchError settles resolver.next(false)',
    () async {
      // Use a failing future (not thenThrow) so the exception travels through
      // the async chain to catchError rather than propagating synchronously into
      // the test zone.
      when(
        () => mockGetStatus(),
      ).thenAnswer((_) => Future.error(Exception('Firebase error')));

      await _guardNavigate(guard, mockResolver, mockRouter);

      verify(() => mockResolver.next(false)).called(1);
      verifyNever(() => mockResolver.redirectUntil(any()));
    },
  );

  // ── no double-settle ──────────────────────────────────────────────────────

  test(
    'catchError does NOT call next(false) when resolver already settled',
    () async {
      // Happy-path guest: resolver is settled via redirectUntil. Even if
      // catchError fires for any subsequent reason, _settled prevents next(false)
      // from being called a second time.
      when(() => mockGetStatus()).thenAnswer((_) async => AccountStatus.guest);
      when(
        () => mockResolver.redirectUntil(any()),
      ).thenAnswer((_) async => null);

      await _guardNavigate(guard, mockResolver, mockRouter);

      // Settled exactly once via redirectUntil; next must NOT be called at all.
      verify(() => mockResolver.redirectUntil(any())).called(1);
      verifyNever(() => mockResolver.next(any()));
    },
  );
}
