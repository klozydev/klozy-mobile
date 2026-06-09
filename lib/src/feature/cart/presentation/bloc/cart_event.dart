import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

@immutable
sealed class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object?> get props => [];
}

final class CartStarted extends CartEvent {
  const CartStarted();
}

final class CartItemRemoved extends CartEvent {
  final String productId;

  const CartItemRemoved(this.productId);

  @override
  List<Object?> get props => [productId];
}

final class CartOfferMade extends CartEvent {
  final String sellerId;
  final num amount;

  const CartOfferMade({required this.sellerId, required this.amount});

  @override
  List<Object?> get props => [sellerId, amount];
}

final class CartOfferCancelled extends CartEvent {
  final String offerId;

  const CartOfferCancelled(this.offerId);

  @override
  List<Object?> get props => [offerId];
}
