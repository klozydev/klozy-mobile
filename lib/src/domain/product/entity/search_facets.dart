import 'package:equatable/equatable.dart';

/// A single facet value and how many products in the current result set carry
/// it. `key` is the raw id/slug/token (brandId, condition slug, size token,
/// category id) the UI maps back to a catalog label.
class FacetBucket extends Equatable {
  final String key;
  final int count;

  const FacetBucket({required this.key, required this.count});

  @override
  List<Object?> get props => <Object?>[key, count];
}

/// Filter facets scoped to the current search result set, so the filter sheet
/// only offers values that actually occur in the matched products.
class SearchFacets extends Equatable {
  final List<FacetBucket> brands;
  final List<FacetBucket> conditions;
  final List<FacetBucket> sizes;
  final List<FacetBucket> categories;

  /// Price range of the matched set, in whole AED (Dhs).
  final num? priceMin;
  final num? priceMax;

  const SearchFacets({
    this.brands = const <FacetBucket>[],
    this.conditions = const <FacetBucket>[],
    this.sizes = const <FacetBucket>[],
    this.categories = const <FacetBucket>[],
    this.priceMin,
    this.priceMax,
  });

  static const SearchFacets empty = SearchFacets();

  bool get isEmpty =>
      brands.isEmpty &&
      conditions.isEmpty &&
      sizes.isEmpty &&
      categories.isEmpty;

  /// Lookup of key → count for one dimension.
  static Map<String, int> counts(List<FacetBucket> buckets) => <String, int>{
    for (final FacetBucket b in buckets) b.key: b.count,
  };

  @override
  List<Object?> get props => <Object?>[
    brands,
    conditions,
    sizes,
    categories,
    priceMin,
    priceMax,
  ];
}
