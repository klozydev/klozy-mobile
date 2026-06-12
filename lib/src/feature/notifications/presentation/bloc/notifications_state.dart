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
  final bool hasMore;
  final bool isLoadingMore;

  const NotificationsLoadedState(
    this.items, {
    this.hasMore = false,
    this.isLoadingMore = false,
  });

  bool get isEmpty => items.isEmpty;

  NotificationsLoadedState copyWith({
    List<AppNotification>? items,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return NotificationsLoadedState(
      items ?? this.items,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [items, hasMore, isLoadingMore];
}
