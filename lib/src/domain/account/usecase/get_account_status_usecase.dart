import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:klozy/src/domain/account/entity/account_status.dart';
import 'package:klozy/src/domain/auth/auth_repository.dart';
import 'package:klozy/src/domain/me/me_repository.dart';

/// Resolves the current [AccountStatus] by combining the Firebase identity with
/// the Klozy backend profile:
///
/// 1. `AuthRepository.currentUserId == null` → [AccountStatus.guest].
/// 2. `AuthRepository.isAnonymous` → [AccountStatus.legacy].
/// 3. `MeRepository.getMe()` 404 / empty profile → [AccountStatus.legacy].
/// 4. profile present but `!isProfileComplete` →
///    [AccountStatus.incompleteOnboarding].
/// 5. otherwise → [AccountStatus.valid].
///
/// `getMe()` errors are never re-thrown — session resolution cannot hard-fail:
/// - 404 → legacy (no backend profile).
/// - Transient network/server errors → incompleteOnboarding. Rationale: a
///   Firebase user is confirmed to exist, but we cannot determine their profile
///   state. Routing them to onboarding is the least-destructive safe fallback
///   (they can retry and progress); forcing legacy would sign them out
///   unexpectedly on a mere connectivity blip.
@injectable
class GetAccountStatusUseCase {
  final AuthRepository _authRepository;
  final MeRepository _meRepository;

  GetAccountStatusUseCase(this._authRepository, this._meRepository);

  Future<AccountStatus> call() async {
    // 1. No Firebase user at all → guest.
    if (_authRepository.currentUserId == null) {
      return AccountStatus.guest;
    }

    // 2. Anonymous Firebase user → legacy (no Klozy identity).
    if (_authRepository.isAnonymous) {
      return AccountStatus.legacy;
    }

    // 3–5. A real Firebase user exists; check the backend profile.
    try {
      final profile = await _meRepository.getMe();
      if (!profile.isProfileComplete) {
        return AccountStatus.incompleteOnboarding;
      }
      return AccountStatus.valid;
    } on DioException catch (e) {
      // 404 → no backend profile → treat as legacy (same as anonymous).
      if (e.response?.statusCode == 404) {
        return AccountStatus.legacy;
      }
      // Transient network/server error: Firebase user confirmed but profile
      // state unknown. Return incompleteOnboarding as a safe non-destructive
      // fallback rather than signing the user out on a connectivity blip.
      return AccountStatus.incompleteOnboarding;
    } catch (_) {
      // Any other unexpected error: same safe fallback as transient network.
      return AccountStatus.incompleteOnboarding;
    }
  }
}
