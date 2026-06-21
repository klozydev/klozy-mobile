import 'package:klozy/src/domain/notifications/entity/app_notification.dart';
import 'package:klozy/src/domain/notifications/entity/notification_type.dart';

/// Defensive JSON → [AppNotification] (`/v1/me/notifications` is opaque).
AppNotification mapNotification(Object? raw) {
  final json = raw is Map<String, dynamic> ? raw : const <String, dynamic>{};
  final data = json['data'] is Map<String, dynamic>
      ? json['data'] as Map<String, dynamic>
      : const <String, dynamic>{};
  return AppNotification(
    id: _str(json, ['id', '_id']) ?? '',
    type: NotificationType.fromApi(_str(json, ['type'])),
    title: _str(json, ['title']) ?? '',
    body: _str(json, ['body', 'message']) ?? '',
    read: json['read'] == true || json['isRead'] == true,
    createdAt: DateTime.tryParse(_str(json, ['createdAt', 'created']) ?? ''),
    productId: _str(data, ['productId']) ?? _str(json, ['productId']),
    orderId: _str(data, ['orderId']) ?? _str(json, ['orderId']),
    userId: _str(data, ['userId', 'actorId']) ?? _str(json, ['userId']),
    conversationId:
        _str(data, ['conversationId']) ?? _str(json, ['conversationId']),
  );
}

String? _str(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is String && value.isNotEmpty) return value;
  }
  return null;
}
