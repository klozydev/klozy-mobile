import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:klozy/src/core/components/app_error_type.dart';
import 'package:klozy/src/domain/catalog/entity/catalog_category.dart';
import 'package:klozy/src/domain/product/entity/product.dart';
import 'package:klozy/src/domain/product/entity/search_facets.dart';
import 'package:klozy/src/domain/product/products_repository.dart';
import 'package:klozy/src/feature/search/presentation/bloc/search_filters.dart';

@immutable
sealed class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object?> get props => [];
}

final class SearchLoadingState extends SearchState {
  const SearchLoadingState();
}

final class SearchErrorState extends SearchState {
  final AppErrorType type;

  const SearchErrorState({required this.type});

  @override
  List<Object?> get props => [type];
}

/// Empty query + no filters → category cards + popular items.
final class SearchBrowseState extends SearchState {
  final List<CatalogCategory> categories;
  final List<Product> popular;

  const SearchBrowseState({required this.categories, required this.popular});

  @override
  List<Object?> get props => [categories, popular];
}

final class SearchResultsState extends SearchState {
  final List<Product> results;
  final String query;
  final ProductSort sort;
  final SearchFilters filters;
  final SearchFacets facets;
  final bool isLoadingMore;
  final bool hasMore;

  const SearchResultsState({
    required this.results,
    required this.query,
    required this.sort,
    required this.filters,
    this.facets = SearchFacets.empty,
    this.isLoadingMore = false,
    this.hasMore = true,
  });

  SearchResultsState copyWith({
    List<Product>? results,
    bool? isLoadingMore,
    bool? hasMore,
  }) {
    return SearchResultsState(
      results: results ?? this.results,
      query: query,
      sort: sort,
      filters: filters,
      facets: facets,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
    );
  }

  @override
  List<Object?> get props => [
    results,
    query,
    sort,
    filters,
    facets,
    isLoadingMore,
    hasMore,
  ];
}
