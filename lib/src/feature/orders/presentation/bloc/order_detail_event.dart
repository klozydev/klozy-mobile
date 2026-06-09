import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:klozy/src/domain/orders/entity/order_action.dart';

@immutable
sealed class OrderDetailEvent extends Equatable {
  const OrderDetailEvent();

  @override
  List<Object?> get props => [];
}

final class OrderDetailStarted extends OrderDetailEvent {
  final String id;

  const OrderDetailStarted(this.id);

  @override
  List<Object?> get props => [id];
}

final class OrderActionRequested extends OrderDetailEvent {
  final OrderAction action;
  final String? reason;
  final int? rating;
  final String? body;

  const OrderActionRequested(
    this.action, {
    this.reason,
    this.rating,
    this.body,
  });

  @override
  List<Object?> get props => [action, reason, rating, body];
}
