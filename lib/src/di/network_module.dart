import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:klozy/src/core/network/base_url/base_url.dart';
import 'package:klozy/src/core/network/base_url/dev_base_url.dart';
import 'package:klozy/src/core/network/base_url/prod_base_url.dart';
import 'package:klozy/src/core/network/interceptors/authentication_interceptor.dart';
import 'package:klozy/src/core/network/interceptors/default_interceptor.dart';
import 'package:klozy/src/core/network/interceptors/logging_interceptor.dart';

@module
abstract class NetworkModule {
  @injectable
  Dio getDio(
    AuthenticationInterceptor authenticationInterceptor,
    DefaultInterceptor defaultInterceptor,
    LoggingInterceptor loggingInterceptor,
    BaseUrl baseUrl,
  ) {
    final dio = Dio();
    dio.options = BaseOptions(
      baseUrl: baseUrl.baseUrl,
      connectTimeout: const Duration(minutes: 1),
      receiveTimeout: const Duration(minutes: 1),
      sendTimeout: const Duration(minutes: 1),
    );
    dio.interceptors.add(defaultInterceptor);
    dio.interceptors.add(authenticationInterceptor);
    dio.interceptors.add(loggingInterceptor);
    return dio;
  }

  @injectable
  BaseUrl getBaseUrl() {
    if (kDebugMode) {
      return DevBaseUrl();
    }
    return ProdBaseUrl();
  }
}
