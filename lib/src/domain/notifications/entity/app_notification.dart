import 'package:equatable/equatable.dart';
import 'package:klozy/src/domain/notifications/entity/notification_type.dart';

/// An in-app notification row. (`AppNotification` to avoid clashing with
/// Flutter's `Notification`.)
class AppNotification extends Equatable {
  final String id;
  final NotificationType type;
  final String title;
  final String body;
  final bool read;
  final DateTime? createdAt;
  final String? productId;
  final String? orderId;
  final String? userId;
  final String? conversationId;

  const AppNotification({
    required this.id,
    required this.type,
    this.title = '',
    this.body = '',
    this.read = false,
    this.createdAt,
    this.productId,
    this.orderId,
    this.userId,
    this.conversationId,
  });

  AppNotification copyWith({bool? read}) {
    return AppNotification(
      id: id,
      type: type,
      title: title,
      body: body,
      read: read ?? this.read,
      createdAt: createdAt,
      productId: productId,
      orderId: orderId,
      userId: userId,
      conversationId: conversationId,
    );
  }

  @override
  List<Object?> get props => [
    id,
    type,
    title,
    body,
    read,
    createdAt,
    productId,
    orderId,
    userId,
    conversationId,
  ];
}
