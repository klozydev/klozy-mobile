import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:klozy/src/domain/product/products_repository.dart';
import 'package:klozy/src/feature/search/presentation/bloc/search_filters.dart';

@immutable
sealed class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object?> get props => [];
}

final class SearchInitEvent extends SearchEvent {
  const SearchInitEvent();
}

final class SearchQueryChanged extends SearchEvent {
  final String query;

  const SearchQueryChanged(this.query);

  @override
  List<Object?> get props => [query];
}

final class SearchSortChanged extends SearchEvent {
  final ProductSort sort;

  const SearchSortChanged(this.sort);

  @override
  List<Object?> get props => [sort];
}

final class SearchFiltersChanged extends SearchEvent {
  final SearchFilters filters;

  const SearchFiltersChanged(this.filters);

  @override
  List<Object?> get props => [filters];
}

final class SearchLoadMore extends SearchEvent {
  const SearchLoadMore();
}
