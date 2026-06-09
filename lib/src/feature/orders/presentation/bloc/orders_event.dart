import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:klozy/src/domain/orders/entity/order_action.dart';

@immutable
sealed class OrdersEvent extends Equatable {
  const OrdersEvent();

  @override
  List<Object?> get props => [];
}

final class OrdersStarted extends OrdersEvent {
  const OrdersStarted();
}

final class OrdersRoleChanged extends OrdersEvent {
  final OrderRole role;

  const OrdersRoleChanged(this.role);

  @override
  List<Object?> get props => [role];
}
