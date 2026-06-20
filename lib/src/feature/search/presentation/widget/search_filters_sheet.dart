import 'package:flutter/material.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/design/components/ds_button_elevated.dart';
import 'package:klozy/src/design/components/ds_button_outline.dart';
import 'package:klozy/src/design/components/ds_category_tree_picker.dart';
import 'package:klozy/src/design/components/ds_loader.dart';
import 'package:klozy/src/design/components/ds_selectable_chip.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';
import 'package:klozy/src/di/injection.dart';
import 'package:klozy/src/domain/catalog/catalog_repository.dart';
import 'package:klozy/src/domain/catalog/entity/catalog_condition.dart';
import 'package:klozy/src/domain/catalog/entity/catalog_size_value.dart';
import 'package:klozy/src/domain/product/entity/search_facets.dart';
import 'package:klozy/src/feature/search/presentation/bloc/search_filters.dart';
import 'package:klozy/src/feature/search/presentation/widget/filter_section_label_widget.dart';
import 'package:klozy/src/feature/search/presentation/widget/price_range_section_widget.dart';

/// Filters sheet body — category drill-down + (per-category) sizes + condition.
/// Returns the chosen [SearchFilters] via `Navigator.pop`.
///
/// Matches the design spec: there is no price range. Sizes are shown only once
/// a leaf category is picked (size options are category-specific). Conditions
/// are all-selected by default (= no constraint); selecting a strict subset
/// narrows the results. Each multi-value set has a Clear / All toggle.
class SearchFiltersSheet extends StatefulWidget {
  final SearchFilters initial;

  /// Facets of the current result set. When non-null, the size/condition
  /// options are narrowed to values that actually occur in the matched
  /// products (with counts). Null in browse mode → full set for the category.
  final SearchFacets? facets;

  const SearchFiltersSheet({super.key, required this.initial, this.facets});

  @override
  State<SearchFiltersSheet> createState() => _SearchFiltersSheetState();
}

class _SearchFiltersSheetState extends State<SearchFiltersSheet> {
  final CatalogRepository _catalog = locator<CatalogRepository>();

  /// Sizes valid for the currently-selected leaf category. Empty until a leaf
  /// category is chosen.
  List<CatalogSizeValue> _sizesForCategory = const <CatalogSizeValue>[];
  bool _loadingSizes = false;

  /// The full condition catalog and the currently-selected slugs. Conditions
  /// default to *all selected* (= no constraint), per the design.
  List<CatalogCondition> _allConditions = const <CatalogCondition>[];
  bool _loadingConditions = true;

  PickedCategory? _selectedCategory;

  late Set<String> _sizes = <String>{...widget.initial.sizes};
  late Set<String> _conditions = <String>{...widget.initial.conditions};

  /// Price range thumbs (Dhs). Null when the backend facets carry no usable
  /// price range (browse mode or a single-price result set).
  double? _priceLow;
  double? _priceHigh;

  @override
  void initState() {
    super.initState();
    _loadConditions();
    _seedPriceRange();
  }

  /// Backend price bounds for the current result set, or null when unavailable
  /// or degenerate (min == max → nothing to slide).
  ({double min, double max})? get _priceBounds {
    final double? lo = widget.facets?.priceMin?.toDouble();
    final double? hi = widget.facets?.priceMax?.toDouble();
    if (lo == null || hi == null || hi <= lo) return null;
    return (min: lo, max: hi);
  }

  void _seedPriceRange() {
    final ({double min, double max})? bounds = _priceBounds;
    if (bounds == null) return;
    _priceLow = (widget.initial.minPrice?.toDouble() ?? bounds.min).clamp(
      bounds.min,
      bounds.max,
    );
    _priceHigh = (widget.initial.maxPrice?.toDouble() ?? bounds.max).clamp(
      bounds.min,
      bounds.max,
    );
  }

  /// Category facet counts (rolled up over `categoryPathIds`) keyed by id, so
  /// the picker can show counts and hide empty categories. Null in browse mode.
  Map<String, int>? get _categoryCounts => widget.facets == null
      ? null
      : SearchFacets.counts(widget.facets!.categories);

  Future<void> _loadConditions() async {
    List<CatalogCondition> conditions = const <CatalogCondition>[];
    try {
      conditions = await _catalog.getConditions();
    } catch (_) {}
    if (!mounted) return;
    setState(() {
      _allConditions = conditions;
      _loadingConditions = false;
      // Default: all selected (no constraint) unless the caller arrived with a
      // narrower selection already applied.
      if (_conditions.isEmpty) {
        _conditions = conditions.map((CatalogCondition c) => c.slug).toSet();
      }
    });
  }

  /// Loads the size tokens for the chosen leaf category. Sizes are
  /// category-specific, so there's nothing to show until one is picked.
  Future<void> _loadSizesFor(String categoryId) async {
    setState(() => _loadingSizes = true);
    List<CatalogSizeValue> sizes = const <CatalogSizeValue>[];
    try {
      sizes = await _catalog.getSizeConfig(categoryId);
    } catch (_) {}
    if (!mounted) return;
    setState(() {
      _sizesForCategory = sizes;
      _loadingSizes = false;
      // Sizes default to *all selected* (= no constraint), per the design.
      // A narrower selection that arrived with the sheet is preserved.
      if (_sizes.isEmpty) {
        _sizes = sizes.map((CatalogSizeValue s) => s.token).toSet();
      }
    });
  }

  void _onCategoryPicked(PickedCategory picked) {
    setState(() {
      _selectedCategory = picked;
      // A different category invalidates the previous size selection.
      _sizes = <String>{};
      _sizesForCategory = const <CatalogSizeValue>[];
    });
    _loadSizesFor(picked.id);
  }

  void _clearCategory() {
    setState(() {
      _selectedCategory = null;
      _sizes = <String>{};
      _sizesForCategory = const <CatalogSizeValue>[];
    });
  }

  void _toggleAllConditions() {
    setState(() {
      final Set<String> all = _allConditions
          .map((CatalogCondition c) => c.slug)
          .toSet();
      _conditions = _conditions.length == all.length ? <String>{} : all;
    });
  }

  void _toggleAllSizes() {
    setState(() {
      final Set<String> all = _visibleSizes
          .map((CatalogSizeValue s) => s.token)
          .toSet();
      _sizes = _sizes.length == all.length ? <String>{} : all;
    });
  }

  void _reset() {
    setState(() {
      _selectedCategory = null;
      _sizes = <String>{};
      _sizesForCategory = const <CatalogSizeValue>[];
      _conditions = _allConditions.map((CatalogCondition c) => c.slug).toSet();
      // Price back to the full backend bounds (= no constraint).
      final ({double min, double max})? bounds = _priceBounds;
      _priceLow = bounds?.min;
      _priceHigh = bounds?.max;
    });
  }

  void _apply() {
    // All-selected conditions mean "no constraint" → send an empty set so the
    // active-filter chip doesn't appear and the query stays unfiltered.
    final bool allConditions =
        _allConditions.isNotEmpty &&
        _conditions.length == _allConditions.length;
    // Same rule for sizes: all-selected means "no constraint" → empty set.
    final bool allSizes =
        _sizesForCategory.isNotEmpty &&
        _sizes.length == _sizesForCategory.length;
    // Price counts as a constraint only when a thumb moved off the full bounds.
    final ({double min, double max})? bounds = _priceBounds;
    num? appliedMin;
    num? appliedMax;
    if (bounds != null && _priceLow != null && _priceHigh != null) {
      if (_priceLow! > bounds.min) appliedMin = _priceLow!.round();
      if (_priceHigh! < bounds.max) appliedMax = _priceHigh!.round();
    }
    Navigator.of(context).pop(
      SearchFilters(
        categoryId: _selectedCategory?.id,
        categoryPath: _selectedCategory?.path,
        sizes: allSizes ? <String>{} : _sizes,
        conditions: allConditions ? <String>{} : _conditions,
        minPrice: appliedMin,
        maxPrice: appliedMax,
      ),
    );
  }

  Map<String, int>? get _sizeCounts =>
      widget.facets == null ? null : SearchFacets.counts(widget.facets!.sizes);

  /// Sizes for the category, narrowed to those that actually occur in the
  /// current result set when facets are available.
  List<CatalogSizeValue> get _visibleSizes {
    final Map<String, int>? m = _sizeCounts;
    if (m == null) return _sizesForCategory;
    return _sizesForCategory
        .where((CatalogSizeValue s) => m.containsKey(s.token))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final Set<String> allConditionSlugs = _allConditions
        .map((CatalogCondition c) => c.slug)
        .toSet();
    final bool conditionsAllSelected =
        _allConditions.isNotEmpty &&
        _conditions.length == allConditionSlugs.length;
    final bool sizesAllSelected =
        _visibleSizes.isNotEmpty && _sizes.length == _visibleSizes.length;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Flexible(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                FilterSectionLabelWidget(
                  text: context.l10N.search_filter_category,
                ),
                DSCategoryTreePicker(
                  repo: _catalog,
                  showBreadcrumb: true,
                  chipLayout: true,
                  categoryCounts: _categoryCounts,
                  onLeafSelected: _onCategoryPicked,
                  onSelectionCleared: _clearCategory,
                ),
                if (_priceBounds != null)
                  PriceRangeSectionWidget(
                    min: _priceBounds!.min,
                    max: _priceBounds!.max,
                    low: _priceLow,
                    high: _priceHigh,
                    onChanged: (RangeValues v) => setState(() {
                      _priceLow = v.start;
                      _priceHigh = v.end;
                    }),
                  ),
                // Sizes only make sense for a chosen leaf category.
                if (_selectedCategory != null) ...<Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      FilterSectionLabelWidget(
                        text: context.l10N.search_filter_size,
                      ),
                      if (_visibleSizes.isNotEmpty)
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: _toggleAllSizes,
                          child: Text(
                            sizesAllSelected
                                ? context.l10N.search_filter_clear
                                : context.l10N.search_filter_all,
                            style: const TextStyle(
                              fontFamily: dsFontFamily,
                              fontSize: DSFontSize.bodyMedium,
                              fontWeight: DSFontWeight.semiBold,
                              color: DSColor.primary,
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (_loadingSizes)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: SizedBox(height: 40, child: DSLoader()),
                    )
                  else if (_visibleSizes.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _visibleSizes
                          .map(
                            (CatalogSizeValue s) => DSSelectableChip(
                              label: s.label,
                              selected: _sizes.contains(s.token),
                              onTap: () => setState(
                                () => _sizes.contains(s.token)
                                    ? _sizes.remove(s.token)
                                    : _sizes.add(s.token),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                ],
                // Condition — all selected by default, with a Clear / All toggle.
                Padding(
                  padding: EdgeInsets.zero,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      FilterSectionLabelWidget(
                        text: context.l10N.search_filter_condition,
                      ),
                      if (_allConditions.isNotEmpty)
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: _toggleAllConditions,
                          child: Text(
                            conditionsAllSelected
                                ? context.l10N.search_filter_clear
                                : context.l10N.search_filter_all,
                            style: const TextStyle(
                              fontFamily: dsFontFamily,
                              fontSize: DSFontSize.bodyMedium,
                              fontWeight: DSFontWeight.semiBold,
                              color: DSColor.primary,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                if (_loadingConditions)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: SizedBox(height: 40, child: DSLoader()),
                  )
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _allConditions
                        .map(
                          (CatalogCondition c) => DSSelectableChip(
                            label: c.label,
                            selected: _conditions.contains(c.slug),
                            onTap: () => setState(
                              () => _conditions.contains(c.slug)
                                  ? _conditions.remove(c.slug)
                                  : _conditions.add(c.slug),
                            ),
                          ),
                        )
                        .toList(),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: <Widget>[
            Expanded(
              child: DSButtonOutline(
                text: context.l10N.search_filter_reset,
                onPressed: _reset,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DSButtonElevated(
                text: context.l10N.search_filter_show_results,
                onPressed: _apply,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
