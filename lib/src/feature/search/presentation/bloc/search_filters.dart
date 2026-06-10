import 'package:equatable/equatable.dart';

/// The active search facets. Immutable; mutate via [copyWith].
class SearchFilters extends Equatable {
  final String? rootCategoryId;
  final String? categoryId;
  final String? categoryPath;
  final Set<String> conditions;
  final Set<String> sizes;
  final Set<String> brandIds;
  final num? minPrice;
  final num? maxPrice;

  const SearchFilters({
    this.rootCategoryId,
    this.categoryId,
    this.categoryPath,
    this.conditions = const <String>{},
    this.sizes = const <String>{},
    this.brandIds = const <String>{},
    this.minPrice,
    this.maxPrice,
  });

  bool get hasPrice => minPrice != null || maxPrice != null;

  bool get isEmpty =>
      rootCategoryId == null &&
      categoryId == null &&
      conditions.isEmpty &&
      sizes.isEmpty &&
      brandIds.isEmpty &&
      !hasPrice;

  int get activeCount =>
      (rootCategoryId != null || categoryId != null ? 1 : 0) +
      (conditions.isEmpty ? 0 : 1) +
      (sizes.isEmpty ? 0 : 1) +
      (brandIds.isEmpty ? 0 : 1) +
      (hasPrice ? 1 : 0);

  SearchFilters copyWith({
    String? rootCategoryId,
    String? categoryId,
    String? categoryPath,
    Set<String>? conditions,
    Set<String>? sizes,
    Set<String>? brandIds,
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
      conditions: conditions ?? this.conditions,
      sizes: sizes ?? this.sizes,
      brandIds: brandIds ?? this.brandIds,
      minPrice: clearPrice ? null : (minPrice ?? this.minPrice),
      maxPrice: clearPrice ? null : (maxPrice ?? this.maxPrice),
    );
  }

  @override
  List<Object?> get props => [
    rootCategoryId,
    categoryId,
    categoryPath,
    conditions,
    sizes,
    brandIds,
    minPrice,
    maxPrice,
  ];
}
