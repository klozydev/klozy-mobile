import 'package:equatable/equatable.dart';

/// The active search facets. Immutable; mutate via [copyWith].
///
/// Mirrors the design's filters sheet: a category drill-down, a per-category
/// size set, a condition set, and a price range. The price bounds come from the
/// backend facets of the current result set; [minPrice]/[maxPrice] are null when
/// the user has not narrowed the range. Empty [sizes]/[conditions] mean "no
/// constraint" — i.e. all values are accepted.
class SearchFilters extends Equatable {
  final String? rootCategoryId;
  final String? categoryId;
  final String? categoryPath;
  final Set<String> sizes;
  final Set<String> conditions;
  final num? minPrice;
  final num? maxPrice;

  const SearchFilters({
    this.rootCategoryId,
    this.categoryId,
    this.categoryPath,
    this.sizes = const <String>{},
    this.conditions = const <String>{},
    this.minPrice,
    this.maxPrice,
  });

  bool get isEmpty =>
      rootCategoryId == null &&
      categoryId == null &&
      sizes.isEmpty &&
      conditions.isEmpty &&
      minPrice == null &&
      maxPrice == null;

  int get activeCount =>
      (rootCategoryId != null || categoryId != null ? 1 : 0) +
      (sizes.isEmpty ? 0 : 1) +
      (conditions.isEmpty ? 0 : 1) +
      (minPrice != null || maxPrice != null ? 1 : 0);

  SearchFilters copyWith({
    String? rootCategoryId,
    String? categoryId,
    String? categoryPath,
    Set<String>? sizes,
    Set<String>? conditions,
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
      conditions: conditions ?? this.conditions,
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
    conditions,
    minPrice,
    maxPrice,
  ];
}
