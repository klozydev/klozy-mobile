import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:klozy/src/core/components/app_error_type.dart';
import 'package:klozy/src/domain/product/entity/product.dart';

@immutable
sealed class WishlistFeedState extends Equatable {
  const WishlistFeedState();

  @override
  List<Object?> get props => [];
}

final class WishlistFeedLoading extends WishlistFeedState {
  const WishlistFeedLoading();
}

final class WishlistFeedError extends WishlistFeedState {
  final AppErrorType type;

  const WishlistFeedError(this.type);

  @override
  List<Object?> get props => [type];
}

final class WishlistFeedLoaded extends WishlistFeedState {
  final List<Product> items;
  final bool hasMore;
  final bool loadingMore;

  const WishlistFeedLoaded({
    required this.items,
    this.hasMore = true,
    this.loadingMore = false,
  });

  WishlistFeedLoaded copyWith({
    List<Product>? items,
    bool? hasMore,
    bool? loadingMore,
  }) {
    return WishlistFeedLoaded(
      items: items ?? this.items,
      hasMore: hasMore ?? this.hasMore,
      loadingMore: loadingMore ?? this.loadingMore,
    );
  }

  @override
  List<Object?> get props => [items, hasMore, loadingMore];
}
