import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:klozy/src/core/components/app_error_type.dart';
import 'package:klozy/src/domain/orders/entity/order.dart';

@immutable
sealed class OrderDetailState extends Equatable {
  const OrderDetailState();

  @override
  List<Object?> get props => [];
}

final class OrderDetailLoadingState extends OrderDetailState {
  const OrderDetailLoadingState();
}

final class OrderDetailErrorState extends OrderDetailState {
  final AppErrorType type;

  const OrderDetailErrorState({required this.type});

  @override
  List<Object?> get props => [type];
}

/// Transient one-shot signal that an order action failed — consumed by the
/// page listener (snackbar); the bloc re-emits the loaded state right after.
final class OrderActionFailedState extends OrderDetailState {
  const OrderActionFailedState();
}

final class OrderDetailLoadedState extends OrderDetailState {
  final Order order;
  final bool isActing;

  const OrderDetailLoadedState(this.order, {this.isActing = false});

  @override
  List<Object?> get props => [order, isActing];
}
