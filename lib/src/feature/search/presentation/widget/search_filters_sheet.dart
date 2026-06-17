import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/design/components/ds_button_elevated.dart';
import 'package:klozy/src/design/components/ds_button_outline.dart';
import 'package:klozy/src/design/components/ds_category_tree_picker.dart';
import 'package:klozy/src/design/components/ds_loader.dart';
import 'package:klozy/src/design/components/ds_selectable_chip.dart';
import 'package:klozy/src/design/components/ds_text_field.dart';
import 'package:klozy/src/di/injection.dart';
import 'package:klozy/src/domain/catalog/catalog_repository.dart';
import 'package:klozy/src/domain/catalog/entity/catalog_size_value.dart';
import 'package:klozy/src/domain/product/entity/search_facets.dart';
import 'package:klozy/src/feature/search/presentation/bloc/search_filters.dart';
import 'package:klozy/src/feature/search/presentation/widget/filter_section_label_widget.dart';
import 'package:klozy/src/feature/search/presentation/widget/selected_category_chip_widget.dart';

/// Filters sheet body — category drill-down + (per-category) sizes + price.
/// Returns the chosen [SearchFilters] via `Navigator.pop`.
///
/// Conditions and brands were intentionally removed; sizes are shown only once
/// a leaf category is picked (a category with no children), since size options
/// are category-specific.
class SearchFiltersSheet extends StatefulWidget {
  final SearchFilters initial;

  /// Facets of the current result set. When non-null, the size options are
  /// narrowed to values that actually occur in the matched products (with
  /// counts). Null in browse mode → full set for the category.
  final SearchFacets? facets;

  const SearchFiltersSheet({super.key, required this.initial, this.facets});

  @override
  State<SearchFiltersSheet> createState() => _SearchFiltersSheetState();
}

class _SearchFiltersSheetState extends State<SearchFiltersSheet> {
  final CatalogRepository _catalog = locator<CatalogRepository>();
  late final TextEditingController _minPrice = TextEditingController(
    text: widget.initial.minPrice?.toInt().toString() ?? '',
  );
  late final TextEditingController _maxPrice = TextEditingController(
    text: widget.initial.maxPrice?.toInt().toString() ?? '',
  );

  /// Sizes valid for the currently-selected leaf category. Empty until a leaf
  /// category is chosen.
  List<CatalogSizeValue> _sizesForCategory = const <CatalogSizeValue>[];
  bool _loadingSizes = false;

  PickedCategory? _selectedCategory;

  late Set<String> _sizes = <String>{...widget.initial.sizes};

  @override
  void dispose() {
    _minPrice.dispose();
    _maxPrice.dispose();
    super.dispose();
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

  void _reset() {
    setState(() {
      _selectedCategory = null;
      _sizes = <String>{};
      _sizesForCategory = const <CatalogSizeValue>[];
      _minPrice.clear();
      _maxPrice.clear();
    });
  }

  void _apply() {
    Navigator.of(context).pop(
      SearchFilters(
        categoryId: _selectedCategory?.id,
        categoryPath: _selectedCategory?.path,
        sizes: _sizes,
        minPrice: num.tryParse(_minPrice.text.trim()),
        maxPrice: num.tryParse(_maxPrice.text.trim()),
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

  String _countSuffix(Map<String, int>? counts, String key) =>
      (counts == null || counts[key] == null) ? '' : ' (${counts[key]})';

  @override
  Widget build(BuildContext context) {
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
                if (_selectedCategory != null)
                  SelectedCategoryChipWidget(
                    path: _selectedCategory!.path,
                    onClear: _clearCategory,
                  )
                else
                  DSCategoryTreePicker(
                    repo: _catalog,
                    showBreadcrumb: true,
                    onLeafSelected: _onCategoryPicked,
                  ),
                // Sizes only make sense for a chosen leaf category.
                if (_selectedCategory != null) ...<Widget>[
                  FilterSectionLabelWidget(
                    text: context.l10N.search_filter_size,
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
                              label:
                                  '${s.label}${_countSuffix(_sizeCounts, s.token)}',
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
                FilterSectionLabelWidget(
                  text: context.l10N.search_filter_price,
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: DSTextField(
                        controller: _minPrice,
                        hintText: context.l10N.search_price_min,
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DSTextField(
                        controller: _maxPrice,
                        hintText: context.l10N.search_price_max,
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),
                    ),
                  ],
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
