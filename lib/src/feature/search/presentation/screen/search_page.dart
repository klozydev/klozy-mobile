import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:klozy/src/core/components/app_error_widget.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/design/components/ds_bottom_sheet.dart';
import 'package:klozy/src/design/components/ds_category_tree_picker.dart';
import 'package:klozy/src/design/components/ds_loader.dart';
import 'package:klozy/src/design/components/ds_text_field.dart';
import 'package:klozy/src/design/tokens/ds_border_radius.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';
import 'package:klozy/src/design/tokens/ds_spacing.dart';
import 'package:klozy/src/di/injection.dart';
import 'package:klozy/src/domain/catalog/entity/catalog_category.dart';
import 'package:klozy/src/domain/product/entity/product.dart';
import 'package:klozy/src/domain/product/entity/search_facets.dart';
import 'package:klozy/src/domain/product/products_repository.dart';
import 'package:klozy/src/feature/home/presentation/widget/product_card_widget.dart';
import 'package:klozy/src/feature/search/presentation/bloc/search_bloc.dart';
import 'package:klozy/src/feature/search/presentation/bloc/search_event.dart';
import 'package:klozy/src/feature/search/presentation/bloc/search_filters.dart';
import 'package:klozy/src/feature/search/presentation/bloc/search_state.dart';
import 'package:klozy/src/feature/search/presentation/widget/search_category_card_widget.dart';
import 'package:klozy/src/feature/search/presentation/widget/search_filters_sheet.dart';
import 'package:klozy/src/router/app_router.dart';

const _gridDelegate = SliverGridDelegateWithFixedCrossAxisCount(
  crossAxisCount: 2,
  mainAxisSpacing: 8,
  crossAxisSpacing: 8,
  childAspectRatio: 0.56,
);

/// Per-root gradient for the browse category tiles, mirroring the design's
/// `CAT_GRADS`. Keyed by lower-cased root label; unknown roots fall back to a
/// neutral dark gradient.
const Map<String, List<Color>> _catGradients = <String, List<Color>>{
  'women': <Color>[Color(0xFF2A0F1C), Color(0xFF140810)],
  'men': <Color>[Color(0xFF0E1426), Color(0xFF080C18)],
  'kids': <Color>[Color(0xFF10231C), Color(0xFF0A160F)],
};

const List<Color> _catGradientFallback = <Color>[
  Color(0xFF1A1A1A),
  Color(0xFF2A2A2A),
];

/// Browse tile order, matching the design's hardcoded Women / Men / Kids.
/// Known roots lead in this order; any others keep their catalog order after.
const List<String> _rootOrder = <String>['women', 'men', 'kids'];

List<CatalogCategory> _orderedRoots(List<CatalogCategory> roots) {
  final List<CatalogCategory> sorted = List<CatalogCategory>.of(roots);
  int rank(CatalogCategory c) {
    final int i = _rootOrder.indexOf(c.label.toLowerCase());
    return i == -1 ? _rootOrder.length : i;
  }

  sorted.sort(
    (CatalogCategory a, CatalogCategory b) => rank(a).compareTo(rank(b)),
  );
  return sorted;
}

@RoutePage()
class SearchPage extends StatefulWidget implements AutoRouteWrapper {
  const SearchPage({super.key});

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider<SearchBloc>(
      create: (_) => locator<SearchBloc>()..add(const SearchInitEvent()),
      child: this,
    );
  }

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _query = TextEditingController();
  final ScrollController _scroll = ScrollController();
  Timer? _debounce;
  ProductSort _sort = ProductSort.popular;
  SearchFilters _filters = const SearchFilters();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 400) {
        context.read<SearchBloc>().add(const SearchLoadMore());
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _query.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _onQuery(String value) {
    setState(() {});
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      context.read<SearchBloc>().add(SearchQueryChanged(value));
    });
  }

  void _selectSort(ProductSort sort) {
    setState(() => _sort = sort);
    context.read<SearchBloc>().add(SearchSortChanged(sort));
  }

  void _applyFilters(SearchFilters filters) {
    setState(() => _filters = filters);
    context.read<SearchBloc>().add(SearchFiltersChanged(filters));
  }

  /// Tapping a root category card opens the hierarchical drill-down page seeded
  /// inside that root. Selecting a leaf runs a leaf-scoped search.
  Future<void> _openCategoryDrill(
    BuildContext context,
    CatalogCategory root,
  ) async {
    final Object? result = await context.router.push(
      SearchCategoryRoute(root: root),
    );
    if (result is PickedCategory) {
      _applyFilters(
        SearchFilters(categoryId: result.id, categoryPath: result.path),
      );
    }
  }

  Future<void> _openFilters() async {
    // Pass the facets from the latest results so the sheet only offers values
    // that actually occur in the matched set (null in browse → full catalog).
    final SearchState state = context.read<SearchBloc>().state;
    final SearchFacets? facets = state is SearchResultsState
        ? state.facets
        : null;
    final result = await DSBottomSheet.show<SearchFilters>(
      context,
      title: context.l10N.search_filters,
      child: SearchFiltersSheet(initial: _filters, facets: facets),
    );
    if (result != null) _applyFilters(result);
  }

  String _sortLabel(BuildContext context, ProductSort sort) {
    return switch (sort) {
      ProductSort.popular => context.l10N.search_sort_popular,
      ProductSort.latest => context.l10N.search_sort_latest,
      ProductSort.priceAsc => context.l10N.search_sort_price_asc,
      ProductSort.priceDesc => context.l10N.search_sort_price_desc,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DSColor.surface,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            _header(),
            _sortRow(),
            const SizedBox(height: DSSpacing.xxs),
            Expanded(
              child: BlocBuilder<SearchBloc, SearchState>(
                builder: (BuildContext context, SearchState state) {
                  return switch (state) {
                    SearchLoadingState() => const DSLoader(),
                    SearchErrorState(:final type) => AppErrorWidget(
                      type: type,
                      onRetry: () => context.read<SearchBloc>().add(
                        const SearchInitEvent(),
                      ),
                    ),
                    SearchBrowseState() => _browse(context, state),
                    SearchResultsState() => _results(state),
                  };
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: DSTextField(
        controller: _query,
        hintText: context.l10N.search_hint,
        prefixIcon: Icons.search_rounded,
        autofocus: false,
        onChanged: _onQuery,
        trailing: _query.text.isEmpty
            ? null
            : GestureDetector(
                onTap: () {
                  _query.clear();
                  _onQuery('');
                },
                child: const Icon(
                  Icons.close,
                  size: 18,
                  color: DSColor.onSurface45,
                ),
              ),
      ),
    );
  }

  /// Sort row, with the Filters pill as its first chip (design: Filters then
  /// Popular/Latest/Price↑/Price↓ on one horizontally scrolling row).
  Widget _sortRow() {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: <Widget>[
          _filtersPill(),
          ...ProductSort.values.map((ProductSort sort) {
            final bool active = sort == _sort;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => _selectSort(sort),
                child: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: active ? DSColor.onSurface : DSColor.onSurface07,
                    borderRadius: BorderRadius.circular(DSBorderRadius.chip),
                    border: active
                        ? null
                        : Border.all(color: DSColor.onSurface15, width: 0.5),
                  ),
                  child: Text(
                    _sortLabel(context, sort),
                    style: TextStyle(
                      fontFamily: dsFontFamily,
                      fontSize: DSFontSize.bodyMedium,
                      fontWeight: active
                          ? DSFontWeight.semiBold
                          : DSFontWeight.regular,
                      color: active ? DSColor.surface : DSColor.onSurface75,
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  /// Filters trigger as a bordered pill. Active (≥1 filter) → faint gold fill,
  /// gold border and gold content; idle → faint surface fill, hairline border.
  Widget _filtersPill() {
    final bool active = _filters.activeCount > 0;
    final Color content = active ? DSColor.primary : DSColor.onSurface75;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: _openFilters,
        behavior: HitTestBehavior.opaque,
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: active
                ? DSColor.primary.withValues(alpha: 0.1)
                : DSColor.onSurface07,
            borderRadius: BorderRadius.circular(DSBorderRadius.chip),
            border: Border.all(
              color: active ? DSColor.primary : DSColor.onSurface15,
              width: 0.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(Icons.tune_rounded, size: 16, color: content),
              const SizedBox(width: 6),
              Text(
                active
                    ? context.l10N.search_filters_with_count(
                        _filters.activeCount,
                      )
                    : context.l10N.search_filters,
                style: TextStyle(
                  fontFamily: dsFontFamily,
                  fontSize: DSFontSize.bodyMedium,
                  fontWeight: DSFontWeight.semiBold,
                  color: content,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _browse(BuildContext context, SearchBrowseState state) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      children: <Widget>[
        Text(
          context.l10N.search_browse_categories,
          style: const TextStyle(
            fontFamily: dsFontFamily,
            fontSize: DSFontSize.titleLarge,
            fontWeight: DSFontWeight.semiBold,
            color: DSColor.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: _orderedRoots(state.categories).take(3).map((
            CatalogCategory c,
          ) {
            final List<Color> grad =
                _catGradients[c.label.toLowerCase()] ?? _catGradientFallback;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: SearchCategoryCardWidget(
                  category: c,
                  gradient: grad,
                  onTap: () => _openCategoryDrill(context, c),
                ),
              ),
            );
          }).toList(),
        ),
        if (state.popular.isNotEmpty) ...<Widget>[
          const SizedBox(height: 24),
          Text(
            context.l10N.search_popular_now,
            style: const TextStyle(
              fontFamily: dsFontFamily,
              fontSize: DSFontSize.titleLarge,
              fontWeight: DSFontWeight.semiBold,
              color: DSColor.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: _gridDelegate,
            itemCount: state.popular.length,
            itemBuilder: (BuildContext context, int i) =>
                ProductCardWidget(product: state.popular[i]),
          ),
        ],
      ],
    );
  }

  Widget _results(SearchResultsState state) {
    if (state.results.isEmpty) {
      return Center(
        child: Text(
          context.l10N.search_no_results,
          style: const TextStyle(
            fontFamily: dsFontFamily,
            fontSize: DSFontSize.bodyLarge,
            color: DSColor.onSurface45,
          ),
        ),
      );
    }
    return CustomScrollView(
      controller: _scroll,
      slivers: <Widget>[
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
          sliver: SliverToBoxAdapter(
            child: Text(
              context.l10N.search_result_count(state.results.length) +
                  (state.query.trim().isEmpty
                      ? ''
                      : context.l10N.search_result_for_query(
                          state.query.trim(),
                        )),
              style: const TextStyle(
                fontFamily: dsFontFamily,
                fontSize: DSFontSize.bodyMedium,
                color: DSColor.onSurface45,
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          sliver: SliverGrid.builder(
            gridDelegate: _gridDelegate,
            itemCount: state.results.length,
            itemBuilder: (BuildContext context, int i) {
              final Product p = state.results[i];
              return ProductCardWidget(product: p);
            },
          ),
        ),
        if (state.isLoadingMore)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: DSColor.primary,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
