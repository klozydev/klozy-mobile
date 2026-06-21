import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:klozy/src/core/network/cache/session_cache.dart';

/// Serves GET responses from the in-memory [SessionCache] when the request was
/// marked [cacheable]. A hit short-circuits the chain (no token, no network);
/// a miss is forwarded and the successful response is stored on the way back.
@injectable
class CacheInterceptor extends Interceptor {
  CacheInterceptor(this._cache);

  final SessionCache _cache;

  bool _isCacheable(RequestOptions options) =>
      options.method.toUpperCase() == 'GET' &&
      options.extra[kCacheFlag] == true;

  String _key(RequestOptions options) => options.uri.toString();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (_isCacheable(options)) {
      final Response<dynamic>? hit = _cache.get(_key(options));
      if (hit != null) {
        handler.resolve(
          Response<dynamic>(
            requestOptions: options,
            data: hit.data,
            statusCode: 200,
            extra: <String, dynamic>{'from_session_cache': true},
          ),
        );
        return;
      }
    }
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    final RequestOptions options = response.requestOptions;
    if (_isCacheable(options) &&
        response.statusCode == 200 &&
        response.extra['from_session_cache'] != true) {
      _cache.put(
        _key(options),
        response,
        group: options.extra[kCacheGroup] as String?,
      );
    }
    handler.next(response);
  }
}
