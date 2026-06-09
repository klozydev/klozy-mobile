import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:klozy/src/core/components/app_error_type.dart';
import 'package:klozy/src/domain/orders/entity/order_action.dart';
import 'package:klozy/src/domain/orders/entity/order_list_item.dart';

@immutable
sealed class OrdersState extends Equatable {
  const OrdersState();

  @override
  List<Object?> get props => [];
}

final class OrdersLoadingState extends OrdersState {
  final OrderRole role;

  const OrdersLoadingState({this.role = OrderRole.buyer});

  @override
  List<Object?> get props => [role];
}

final class OrdersErrorState extends OrdersState {
  final AppErrorType type;
  final OrderRole role;

  const OrdersErrorState({required this.type, this.role = OrderRole.buyer});

  @override
  List<Object?> get props => [type, role];
}

final class OrdersLoadedState extends OrdersState {
  final OrderRole role;
  final List<OrderListItem> inProgress;
  final List<OrderListItem> completed;

  const OrdersLoadedState({
    required this.role,
    required this.inProgress,
    required this.completed,
  });

  bool get isEmpty => inProgress.isEmpty && completed.isEmpty;

  @override
  List<Object?> get props => [role, inProgress, completed];
}
