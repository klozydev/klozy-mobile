import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:klozy/src/core/components/app_error_type.dart';
import 'package:klozy/src/domain/product/entity/product_detail.dart';

@immutable
sealed class ProductState extends Equatable {
  const ProductState();

  @override
  List<Object?> get props => [];
}

final class ProductLoadingState extends ProductState {
  const ProductLoadingState();
}

final class ProductErrorState extends ProductState {
  final AppErrorType type;

  const ProductErrorState({required this.type});

  @override
  List<Object?> get props => [type];
}

final class ProductLoadedState extends ProductState {
  final ProductDetail detail;
  final bool inCart;

  const ProductLoadedState({required this.detail, this.inCart = false});

  ProductLoadedState copyWith({ProductDetail? detail, bool? inCart}) {
    return ProductLoadedState(
      detail: detail ?? this.detail,
      inCart: inCart ?? this.inCart,
    );
  }

  @override
  List<Object?> get props => [detail, inCart];
}

final class ProductDeletedState extends ProductState {
  const ProductDeletedState();
}

/// Transient one-shot outcome of an add-to-cart attempt — consumed by the
/// page listener (snackbar + cart badge refresh), filtered out of the
/// builder. The bloc re-emits the loaded state right after it.
final class ProductCartResultState extends ProductState {
  final bool success;

  const ProductCartResultState({required this.success});

  @override
  List<Object?> get props => [success];
}

/// Transient one-shot signal that deleting the listing failed — consumed by
/// the page listener (snackbar), filtered out of the builder.
final class ProductDeleteFailedState extends ProductState {
  const ProductDeleteFailedState();
}
