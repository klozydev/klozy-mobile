import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:klozy/src/domain/product/entity/product_detail.dart';

@immutable
sealed class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object?> get props => [];
}

final class ProductStarted extends ProductEvent {
  final String id;

  const ProductStarted(this.id);

  @override
  List<Object?> get props => [id];
}

final class ProductAddToCart extends ProductEvent {
  const ProductAddToCart();
}

final class ProductMarkStatus extends ProductEvent {
  final ProductStatus status;

  const ProductMarkStatus(this.status);

  @override
  List<Object?> get props => [status];
}

final class ProductDeleted extends ProductEvent {
  const ProductDeleted();
}

final class ProductReported extends ProductEvent {
  const ProductReported();
}
