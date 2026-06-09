import 'package:equatable/equatable.dart';

/// The active search facets. Immutable; mutate via [copyWith].
class SearchFilters extends Equatable {
  final String? rootCategoryId;
  final String? categoryId;
  final String? categoryPath;
  final Set<String> conditions;
  final Set<String> sizes;

  const SearchFilters({
    this.rootCategoryId,
    this.categoryId,
    this.categoryPath,
    this.conditions = const <String>{},
    this.sizes = const <String>{},
  });

  bool get isEmpty =>
      rootCategoryId == null &&
      categoryId == null &&
      conditions.isEmpty &&
      sizes.isEmpty;

  int get activeCount =>
      (rootCategoryId != null || categoryId != null ? 1 : 0) +
      (conditions.isEmpty ? 0 : 1) +
      (sizes.isEmpty ? 0 : 1);

  SearchFilters copyWith({
    String? rootCategoryId,
    String? categoryId,
    String? categoryPath,
    Set<String>? conditions,
    Set<String>? sizes,
    bool clearCategory = false,
  }) {
    return SearchFilters(
      rootCategoryId: clearCategory
          ? null
          : (rootCategoryId ?? this.rootCategoryId),
      categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
      categoryPath: clearCategory ? null : (categoryPath ?? this.categoryPath),
      conditions: conditions ?? this.conditions,
      sizes: sizes ?? this.sizes,
    );
  }

  @override
  List<Object?> get props => [
    rootCategoryId,
    categoryId,
    categoryPath,
    conditions,
    sizes,
  ];
}
