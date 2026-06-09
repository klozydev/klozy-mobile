import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:klozy/src/core/components/app_error_type.dart';
import 'package:klozy/src/domain/catalog/entity/catalog_category.dart';
import 'package:klozy/src/domain/product/entity/product.dart';

@immutable
sealed class FeedState extends Equatable {
  const FeedState();

  @override
  List<Object?> get props => [];
}

final class FeedLoading extends FeedState {
  const FeedLoading();
}

final class FeedError extends FeedState {
  final AppErrorType type;

  const FeedError(this.type);

  @override
  List<Object?> get props => [type];
}

final class FeedReady extends FeedState {
  final List<CatalogCategory> categories;
  final String? selectedRootId;
  final List<Product> items;
  final bool isLoadingMore;
  final bool hasMore;

  const FeedReady({
    required this.categories,
    required this.items,
    this.selectedRootId,
    this.isLoadingMore = false,
    this.hasMore = true,
  });

  FeedReady copyWith({
    String? selectedRootId,
    bool resetSelectedRoot = false,
    List<Product>? items,
    bool? isLoadingMore,
    bool? hasMore,
  }) {
    return FeedReady(
      categories: categories,
      selectedRootId: resetSelectedRoot
          ? null
          : (selectedRootId ?? this.selectedRootId),
      items: items ?? this.items,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
    );
  }

  @override
  List<Object?> get props => [
    categories,
    selectedRootId,
    items,
    isLoadingMore,
    hasMore,
  ];
}
