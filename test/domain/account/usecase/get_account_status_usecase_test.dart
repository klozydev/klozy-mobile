import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/domain/account/entity/account_status.dart';
import 'package:klozy/src/domain/account/usecase/get_account_status_usecase.dart';
import 'package:klozy/src/domain/auth/auth_repository.dart';
import 'package:klozy/src/domain/me/entity/me_profile.dart';
import 'package:klozy/src/domain/me/me_repository.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

class _MockMeRepository extends Mock implements MeRepository {}

/// A complete [MeProfile] (all required fields filled, hasAddress true).
const _completeProfile = MeProfile(
  id: 'u1',
  firstName: 'Jane',
  lastName: 'Doe',
  hasAddress: true,
);

/// An incomplete [MeProfile] (missing last name).
const _incompleteProfile = MeProfile(
  id: 'u1',
  firstName: 'Jane',
  hasAddress: false,
);

/// Helper to create a [DioException] with the given HTTP status code.
DioException _dioException(int statusCode) => DioException(
  requestOptions: RequestOptions(path: 'v1/me'),
  response: Response<dynamic>(
    requestOptions: RequestOptions(path: 'v1/me'),
    statusCode: statusCode,
  ),
  type: DioExceptionType.badResponse,
);

void main() {
  late _MockAuthRepository mockAuth;
  late _MockMeRepository mockMe;
  late GetAccountStatusUseCase useCase;

  setUp(() {
    mockAuth = _MockAuthRepository();
    mockMe = _MockMeRepository();
    useCase = GetAccountStatusUseCase(mockAuth, mockMe);
  });

  group('GetAccountStatusUseCase', () {
    test('returns guest when currentUserId is null', () async {
      when(() => mockAuth.currentUserId).thenReturn(null);
      when(() => mockAuth.isAnonymous).thenReturn(false);

      final result = await useCase();

      expect(result, AccountStatus.guest);
      verifyNever(() => mockMe.getMe());
    });

    test('returns legacy when user is anonymous', () async {
      when(() => mockAuth.currentUserId).thenReturn('uid-anon');
      when(() => mockAuth.isAnonymous).thenReturn(true);

      final result = await useCase();

      expect(result, AccountStatus.legacy);
      verifyNever(() => mockMe.getMe());
    });

    test('returns legacy when getMe throws 404', () async {
      when(() => mockAuth.currentUserId).thenReturn('uid-real');
      when(() => mockAuth.isAnonymous).thenReturn(false);
      when(() => mockMe.getMe()).thenThrow(_dioException(404));

      final result = await useCase();

      expect(result, AccountStatus.legacy);
    });

    test('returns legacy when getMe throws 401 (credentials rejected)', () async {
      // A stale Firebase session that the backend refuses (e.g. the account was
      // deleted server-side). The interceptor has already force-refreshed once,
      // so a 401 here is definitive: the user must re-authenticate.
      when(() => mockAuth.currentUserId).thenReturn('uid-real');
      when(() => mockAuth.isAnonymous).thenReturn(false);
      when(() => mockMe.getMe()).thenThrow(_dioException(401));

      final result = await useCase();

      expect(result, AccountStatus.legacy);
    });

    test('returns legacy when getMe throws 403 (forbidden)', () async {
      when(() => mockAuth.currentUserId).thenReturn('uid-real');
      when(() => mockAuth.isAnonymous).thenReturn(false);
      when(() => mockMe.getMe()).thenThrow(_dioException(403));

      final result = await useCase();

      expect(result, AccountStatus.legacy);
    });

    test('returns incompleteOnboarding when profile is not complete', () async {
      when(() => mockAuth.currentUserId).thenReturn('uid-real');
      when(() => mockAuth.isAnonymous).thenReturn(false);
      when(() => mockMe.getMe()).thenAnswer((_) async => _incompleteProfile);

      final result = await useCase();

      expect(result, AccountStatus.incompleteOnboarding);
    });

    test('returns valid when profile is complete', () async {
      when(() => mockAuth.currentUserId).thenReturn('uid-real');
      when(() => mockAuth.isAnonymous).thenReturn(false);
      when(() => mockMe.getMe()).thenAnswer((_) async => _completeProfile);

      final result = await useCase();

      expect(result, AccountStatus.valid);
    });

    test(
      'returns incompleteOnboarding on transient network error (non-404 DioException)',
      () async {
        when(() => mockAuth.currentUserId).thenReturn('uid-real');
        when(() => mockAuth.isAnonymous).thenReturn(false);
        when(() => mockMe.getMe()).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: 'v1/me'),
            type: DioExceptionType.connectionError,
          ),
        );

        final result = await useCase();

        // Safe fallback: do not log the user out on a transient connectivity blip.
        expect(result, AccountStatus.incompleteOnboarding);
      },
    );

    test(
      'returns incompleteOnboarding on 500 server error (non-404 DioException)',
      () async {
        when(() => mockAuth.currentUserId).thenReturn('uid-real');
        when(() => mockAuth.isAnonymous).thenReturn(false);
        when(() => mockMe.getMe()).thenThrow(_dioException(500));

        final result = await useCase();

        expect(result, AccountStatus.incompleteOnboarding);
      },
    );

    test('returns incompleteOnboarding on unexpected exception', () async {
      when(() => mockAuth.currentUserId).thenReturn('uid-real');
      when(() => mockAuth.isAnonymous).thenReturn(false);
      when(() => mockMe.getMe()).thenThrow(Exception('unexpected'));

      final result = await useCase();

      expect(result, AccountStatus.incompleteOnboarding);
    });
  });
}
