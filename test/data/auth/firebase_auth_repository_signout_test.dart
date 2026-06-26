import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:klozy/src/core/network/cache/session_cache.dart';
import 'package:klozy/src/data/auth/firebase_auth_repository.dart';
import 'package:klozy/src/domain/me/me_repository.dart';
import 'package:mocktail/mocktail.dart';

class _MockFirebaseAuth extends Mock implements FirebaseAuth {}

class _MockGoogleSignIn extends Mock implements GoogleSignIn {}

class _MockMeRepository extends Mock implements MeRepository {}

void main() {
  late _MockFirebaseAuth mockAuth;
  late _MockGoogleSignIn mockGoogleSignIn;
  late _MockMeRepository mockMe;
  late FirebaseAuthRepository repo;

  setUp(() {
    mockAuth = _MockFirebaseAuth();
    mockGoogleSignIn = _MockGoogleSignIn();
    mockMe = _MockMeRepository();
    repo = FirebaseAuthRepository(
      mockAuth,
      mockGoogleSignIn,
      mockMe,
      SessionCache(),
    );

    when(() => mockGoogleSignIn.signOut()).thenAnswer((_) async {});
    when(() => mockAuth.signOut()).thenAnswer((_) async {});
    when(() => mockMe.invalidate()).thenReturn(null);
  });

  test('signOut calls meRepository.invalidate() before signing out', () async {
    await repo.signOut();

    // invalidate() must have been called once.
    verify(() => mockMe.invalidate()).called(1);
    // And Firebase / Google sign-out must still proceed.
    verify(() => mockGoogleSignIn.signOut()).called(1);
    verify(() => mockAuth.signOut()).called(1);
  });

  test('invalidate is called before Firebase signOut (ordering)', () async {
    final callOrder = <String>[];
    when(() => mockMe.invalidate()).thenAnswer((_) {
      callOrder.add('invalidate');
    });
    when(() => mockGoogleSignIn.signOut()).thenAnswer((_) async {
      callOrder.add('googleSignOut');
      return;
    });
    when(() => mockAuth.signOut()).thenAnswer((_) async {
      callOrder.add('firebaseSignOut');
    });

    await repo.signOut();

    expect(callOrder.first, 'invalidate');
  });
}
