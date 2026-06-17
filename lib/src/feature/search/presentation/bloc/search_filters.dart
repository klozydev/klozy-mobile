import 'package:equatable/equatable.dart';

/// The active search facets. Immutable; mutate via [copyWith].
class SearchFilters extends Equatable {
  final String? rootCategoryId;
  final String? categoryId;
  final String? categoryPath;
  final Set<String> sizes;
  final num? minPrice;
  final num? maxPrice;

  const SearchFilters({
    this.rootCategoryId,
    this.categoryId,
    this.categoryPath,
    this.sizes = const <String>{},
    this.minPrice,
    this.maxPrice,
  });

  bool get hasPrice => minPrice != null || maxPrice != null;

  bool get isEmpty =>
      rootCategoryId == null &&
      categoryId == null &&
      sizes.isEmpty &&
      !hasPrice;

  int get activeCount =>
      (rootCategoryId != null || categoryId != null ? 1 : 0) +
      (sizes.isEmpty ? 0 : 1) +
      (hasPrice ? 1 : 0);

  SearchFilters copyWith({
    String? rootCategoryId,
    String? categoryId,
    String? categoryPath,
    Set<String>? sizes,
    num? minPrice,
    num? maxPrice,
    bool clearCategory = false,
    bool clearPrice = false,
  }) {
    return SearchFilters(
      rootCategoryId: clearCategory
          ? null
          : (rootCategoryId ?? this.rootCategoryId),
      categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
      categoryPath: clearCategory ? null : (categoryPath ?? this.categoryPath),
      sizes: sizes ?? this.sizes,
      minPrice: clearPrice ? null : (minPrice ?? this.minPrice),
      maxPrice: clearPrice ? null : (maxPrice ?? this.maxPrice),
    );
  }

  @override
  List<Object?> get props => [
    rootCategoryId,
    categoryId,
    categoryPath,
    sizes,
    minPrice,
    maxPrice,
  ];
}
