import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:intl/intl.dart';

@injectable
class DefaultInterceptor extends Interceptor {
  const DefaultInterceptor();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // The API localizes catalog labels via X-Language (e.g. "en", "ar").
    final language = (Intl.defaultLocale ?? 'en').split(RegExp('[_-]')).first;
    options.headers['Accept'] = 'application/json';
    options.headers['Accept-Language'] = language;
    options.headers['X-Language'] = language;
    options.headers['Content-Type'] = 'application/json';
    super.onRequest(options, handler);
  }
}
