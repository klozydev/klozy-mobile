import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';
import 'package:klozy/src/core/network/base_url/base_url.dart';

/// Attaches the current user's Firebase ID token as a Bearer credential.
///
/// The Klozy API authenticates every request with a Firebase JWT
/// (`Authorization: Bearer <ID token>`). On a 401 we force-refresh the ID
/// token once via the Firebase SDK and retry the original request — there is
/// no backend refresh endpoint.
@injectable
class AuthenticationInterceptor extends QueuedInterceptor {
  final FirebaseAuth _firebaseAuth;
  final BaseUrl _baseUrl;

  AuthenticationInterceptor(this._firebaseAuth, this._baseUrl);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _idToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final isUnauthorized = err.response?.statusCode == 401;
    final alreadyRetried = err.requestOptions.extra['retried'] == true;

    if (!isUnauthorized ||
        alreadyRetried ||
        _firebaseAuth.currentUser == null) {
      handler.next(err);
      return;
    }

    try {
      final freshToken = await _idToken(forceRefresh: true);
      if (freshToken == null || freshToken.isEmpty) {
        handler.next(err);
        return;
      }
      final retried = await _retry(err.requestOptions, freshToken);
      handler.resolve(retried);
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }

  Future<String?> _idToken({bool forceRefresh = false}) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return null;
    return user.getIdToken(forceRefresh);
  }

  Future<Response<dynamic>> _retry(
    RequestOptions requestOptions,
    String newToken,
  ) {
    final dio = Dio(BaseOptions(baseUrl: _baseUrl.baseUrl));
    requestOptions.headers['Authorization'] = 'Bearer $newToken';
    requestOptions.extra['retried'] = true;
    return dio.fetch<dynamic>(requestOptions);
  }
}
