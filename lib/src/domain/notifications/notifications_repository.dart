import 'package:klozy/src/domain/notifications/entity/app_notification.dart';

/// In-app notification center (`/v1/me/notifications`).
abstract class NotificationsRepository {
  Future<List<AppNotification>> getNotifications({
    int page = 1,
    int limit = 30,
    bool unreadOnly = false,
  });

  Future<int> unreadCount();

  Future<void> markRead(String id);

  Future<void> markAllRead();

  Future<void> remove(String id);
}
