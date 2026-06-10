import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:klozy/src/data/notifications/notification_mapper.dart';
import 'package:klozy/src/domain/notifications/entity/app_notification.dart';
import 'package:klozy/src/domain/notifications/notifications_repository.dart';

@LazySingleton(as: NotificationsRepository)
class NotificationsRepositoryImpl implements NotificationsRepository {
  final Dio _dio;

  NotificationsRepositoryImpl(this._dio);

  @override
  Future<List<AppNotification>> getNotifications({
    int page = 1,
    int limit = 30,
    bool unreadOnly = false,
  }) async {
    final response = await _dio.get<dynamic>(
      'v1/me/notifications',
      queryParameters: <String, dynamic>{
        'page': page,
        'limit': limit,
        if (unreadOnly) 'unread': true,
      },
    );
    return _list(response.data).map(mapNotification).toList();
  }

  @override
  Future<int> unreadCount() async {
    final response = await _dio.get<dynamic>(
      'v1/me/notifications/unread-count',
    );
    final data = response.data;
    if (data is num) return data.toInt();
    if (data is Map<String, dynamic>) {
      for (final key in const <String>['count', 'unread', 'unreadCount']) {
        final value = data[key];
        if (value is num) return value.toInt();
      }
    }
    return 0;
  }

  @override
  Future<void> markRead(String id) async {
    await _dio.patch<dynamic>('v1/me/notifications/$id/read');
  }

  @override
  Future<void> markAllRead() async {
    await _dio.post<dynamic>('v1/me/notifications/read-all');
  }

  @override
  Future<void> remove(String id) async {
    await _dio.delete<dynamic>('v1/me/notifications/$id');
  }

  @override
  Future<void> registerDeviceToken({
    required String token,
    required String platform,
  }) async {
    await _dio.post<dynamic>(
      'v1/me/device-tokens',
      data: <String, dynamic>{'token': token, 'platform': platform},
    );
  }

  @override
  Future<void> removeDeviceToken(String token) async {
    await _dio.delete<dynamic>(
      'v1/me/device-tokens/${Uri.encodeComponent(token)}',
    );
  }

  List<dynamic> _list(Object? data) {
    if (data is List) return data;
    if (data is Map<String, dynamic>) {
      for (final key in const <String>['data', 'notifications', 'items']) {
        if (data[key] is List) return data[key] as List<dynamic>;
      }
    }
    return const <dynamic>[];
  }
}
