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
