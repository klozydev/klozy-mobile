import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:klozy/src/core/components/app_error_type.dart';
import 'package:klozy/src/domain/notifications/entity/app_notification.dart';

@immutable
sealed class NotificationsState extends Equatable {
  const NotificationsState();

  @override
  List<Object?> get props => [];
}

final class NotificationsLoadingState extends NotificationsState {
  const NotificationsLoadingState();
}

final class NotificationsErrorState extends NotificationsState {
  final AppErrorType type;

  const NotificationsErrorState({required this.type});

  @override
  List<Object?> get props => [type];
}

final class NotificationsLoadedState extends NotificationsState {
  final List<AppNotification> items;

  const NotificationsLoadedState(this.items);

  bool get isEmpty => items.isEmpty;

  @override
  List<Object?> get props => [items];
}
