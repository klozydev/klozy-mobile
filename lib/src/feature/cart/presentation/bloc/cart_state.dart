import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:klozy/src/core/components/app_error_type.dart';
import 'package:klozy/src/domain/cart/entity/cart.dart';

@immutable
sealed class CartState extends Equatable {
  const CartState();

  @override
  List<Object?> get props => [];
}

final class CartLoadingState extends CartState {
  const CartLoadingState();
}

final class CartErrorState extends CartState {
  final AppErrorType type;

  const CartErrorState({required this.type});

  @override
  List<Object?> get props => [type];
}

final class CartLoadedState extends CartState {
  final Cart cart;
  final bool isMutating;

  const CartLoadedState(this.cart, {this.isMutating = false});

  @override
  List<Object?> get props => [cart, isMutating];
}
