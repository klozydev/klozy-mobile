import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

@immutable
sealed class NotificationsEvent extends Equatable {
  const NotificationsEvent();

  @override
  List<Object?> get props => [];
}

final class NotificationsStarted extends NotificationsEvent {
  const NotificationsStarted();
}

final class NotificationsReadAll extends NotificationsEvent {
  const NotificationsReadAll();
}

final class NotificationMarkedRead extends NotificationsEvent {
  final String id;

  const NotificationMarkedRead(this.id);

  @override
  List<Object?> get props => [id];
}

final class NotificationRemoved extends NotificationsEvent {
  final String id;

  const NotificationRemoved(this.id);

  @override
  List<Object?> get props => [id];
}
