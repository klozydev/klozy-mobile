import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:intl/intl.dart';

@injectable
class DefaultInterceptor extends Interceptor {
  const DefaultInterceptor();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers['Accept'] = 'application/json';
    options.headers['Accept-Language'] = Intl.defaultLocale;
    options.headers['Content-Type'] = 'application/json';
    super.onRequest(options, handler);
  }
}
